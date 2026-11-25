import type { On, PromptSubmitCommand } from 'claude-code'
import { expect, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'

const SURFACES = ['terminal', 'desktop'] as const

// A prompt typed at the composer, as the engine raises it.
const submit = ($: Engine, text: string, command?: PromptSubmitCommand) =>
  $.prompt.submit({
    text,
    wait: false,
    origin: { kind: 'composer' },
    ...(command && { command }),
  })

const complete = ($: Engine) =>
  $.turn.complete({
    reason: 'answer',
    answer: '',
    durationMs: 1,
    isAborted: false,
    turnId: 't',
  })

// Stands for the engine, which draws the band when the plugin passes.
const engineDraws = (on: On) =>
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)

    return <Text>engine</Text>
  })

const BAND = {
  plugin: 'pickle',
  component: 'AbovePrompt',
  props: {
    hasSurvey: false,
    isCollapsed: false,
    isWorking: false,
    maxRows: 10,
    bodyColumns: 80,
    scroll: { offset: 0, bodyRows: 10 },
    view: {},
  },
} as const

const GUIDE = {
  plugin: 'pickle',
  component: 'Pane',
  requestId: 'guide',
  props: {
    title: 'pickle',
    isFocused: false,
    bodyColumns: 40,
    placement: 'dock',
    scroll: { offset: 0, bodyRows: 40 },
    view: {},
  },
} as const

test('the band fills the prompt with pickle-mode, on each surface', async ($, on) => {
  const filled: string[] = []
  on('prompt.fill', (_, e) => {
    filled.push(e.text)

    return { isFilled: true }
  })

  for (const surface of SURFACES) {
    const ui = await $.ui.mount({ ...BAND, surface })
    await ui.press({ key: 'mode' })
    await ui.unmount()
  }

  expect(filled).toEqual(['/pickle:pickle-mode ', '/pickle:pickle-mode '])
})

const LOGO_ELEMENTS = {
  tile: { terminal: { type: 'Image' }, desktop: { type: 'Svg' } },
  'tile-text': {
    terminal: { type: 'Text', text: ' p ' },
    desktop: { type: 'Svg' },
  },
  badge: {
    terminal: { type: 'Text', text: ' pickle ' },
    desktop: { type: 'Text', text: ' pickle ' },
  },
  pixel: { terminal: { type: 'Raster' }, desktop: { type: 'Svg' } },
  'pixel-tall': { terminal: { type: 'Raster' }, desktop: { type: 'Svg' } },
} as const

for (const [logo, queries] of Object.entries(LOGO_ELEMENTS)) {
  test(`the ${logo} logo draws on each surface`, { options: { logo } }, async $ => {
    for (const surface of SURFACES) {
      const ui = await $.ui.mount({ ...BAND, surface })
      expect(await ui.find(queries[surface])).toBeDefined()
      await ui.unmount()
    }
  })
}

test('the band draws the tile logo by default', async $ => {
  const ui = await $.ui.mount({ ...BAND, surface: 'desktop' })
  const tile = await ui.find({ type: 'Svg' })
  expect(tile?.props.source).toMatch(/<rect/)
  await ui.unmount()
})

test('the band hides after Hide', async ($, on) => {
  engineDraws(on)
  const ui = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await ui.find({ key: 'mode' })).toBeDefined()

  await ui.press({ key: 'hide' })
  await ui.unmount()

  const again = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await again.find({ key: 'mode' })).toBeUndefined()
  await again.unmount()
})

test('a pickle command hides the band, an ordinary prompt does not', async ($, on) => {
  engineDraws(on)
  on('prompt.submit', (_, e) => ({ text: e.text }))

  await submit($, 'what does this repo do?')
  const shown = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await shown.find({ key: 'mode' })).toBeDefined()
  await shown.unmount()

  await submit($, '/pickle:review', { name: 'pickle:review', args: '' })
  const hidden = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await hidden.find({ key: 'mode' })).toBeUndefined()
  await hidden.unmount()
})

test('a task-shaped prompt gets the pickle-mode tip once', async ($, on) => {
  const toasts: string[] = []
  on('ui.toast', (_, e) => {
    toasts.push(e.text)

    return { value: undefined }
  })
  on('prompt.submit', (_, e) => ({ text: e.text }))

  await submit($, 'what does this repo do?')
  await submit($, 'add a dark mode toggle')
  await submit($, 'now build the settings page')

  expect(toasts).toHaveLength(1)
  expect(toasts[0]).toMatch(/pickle:pickle-mode/)
})

test('a turn with edits suggests a review', async ($, on) => {
  const suggested: string[] = []
  on('prompt.suggest', (_, e) => {
    suggested.push(e.text)

    return { isShown: true }
  })
  on('prompt.submit', (_, e) => ({ text: e.text }))
  on('tool.call', () => ({ result: {} }))
  on('turn.complete', () => ({ text: '' }))

  await submit($, 'explain the layout')
  await complete($)
  expect(suggested).toEqual([])

  await submit($, 'rename the helper')
  await $.tool.call({ tool: 'Edit', file_path: 'a.ts', old_string: 'a', new_string: 'b' })
  await complete($)
  expect(suggested).toEqual(['/pickle:review'])
})

test('a review or ship with no edits suggests reflect', async ($, on) => {
  const suggested: string[] = []
  on('prompt.suggest', (_, e) => {
    suggested.push(e.text)

    return { isShown: true }
  })
  on('prompt.submit', (_, e) => ({ text: e.text }))
  on('tool.call', () => ({ result: {} }))
  on('turn.complete', () => ({ text: '' }))

  await submit($, 'what changed?')
  await complete($)
  expect(suggested).toEqual([])

  await submit($, '/pickle:review', { name: 'pickle:review', args: '' })
  await $.tool.call({ tool: 'Edit', file_path: 'a.ts', old_string: 'a', new_string: 'b' })
  await complete($)
  expect(suggested).toEqual(['/pickle:review'])

  await submit($, '/pickle:review', { name: 'pickle:review', args: '' })
  await complete($)
  await submit($, '/pickle:ship', { name: 'pickle:ship', args: '' })
  await complete($)
  expect(suggested).toEqual(['/pickle:review', '/pickle:reflect', '/pickle:reflect'])
})

test('a long first ask gets the in-your-own-words tip instead', async ($, on) => {
  const toasts: string[] = []
  on('ui.toast', (_, e) => {
    toasts.push(e.text)

    return { value: undefined }
  })
  on('prompt.submit', (_, e) => ({ text: e.text }))

  await submit($, `Thread from support: search is broken again. ${'They renamed a product and search misses it. '.repeat(20)}`)
  await submit($, 'add a dark mode toggle')

  expect(toasts).toHaveLength(1)
  expect(toasts[0]).toMatch(/pickle:in-your-own-words/)
})

test('a correction suggests correct once, ahead of review', async ($, on) => {
  const suggested: string[] = []
  on('prompt.suggest', (_, e) => {
    suggested.push(e.text)

    return { isShown: true }
  })
  on('prompt.submit', (_, e) => ({ text: e.text }))
  on('tool.call', () => ({ result: {} }))
  on('turn.complete', () => ({ text: '' }))

  await submit($, 'run the tests again')
  await complete($)
  expect(suggested).toEqual([])

  await submit($, 'remove the console.log, I told you we never ship those')
  await $.tool.call({ tool: 'Edit', file_path: 'a.ts', old_string: 'a', new_string: 'b' })
  await complete($)
  expect(suggested).toEqual(['/pickle:correct'])

  await submit($, 'you keep adding it back')
  await $.tool.call({ tool: 'Edit', file_path: 'a.ts', old_string: 'a', new_string: 'b' })
  await complete($)
  expect(suggested).toEqual(['/pickle:correct', '/pickle:review'])
})

test('the guide opens with the tile, title, version and tagline', async ($, on) => {
  const paths: string[] = []
  on('fs.read', (_, e) => {
    paths.push(e.path)

    return { value: JSON.stringify({ name: 'pickle', version: '1.2.3' }) }
  })
  on('command.register', (_, e) => ({ value: { command: e.name } }))
  on('session.start', () => ({ cwd: '/' }))
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  for (const [surface, mark] of [['terminal', 'Raster'], ['desktop', 'Svg']] as const) {
    const ui = await $.ui.mount({ ...GUIDE, surface })
    expect(await ui.find({ type: mark })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: ' v1.2.3' })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /picked per task/ })).toBeDefined()
    await ui.unmount()
  }
  expect(paths).toEqual([expect.stringMatching(/\.claude-plugin\/plugin\.json$/)])
})

test('the guide lists every phase and fills the prompt', async ($, on) => {
  const filled: string[] = []
  on('prompt.fill', (_, e) => {
    filled.push(e.text)

    return { isFilled: true }
  })

  for (const surface of SURFACES) {
    const ui = await $.ui.mount({ ...GUIDE, surface })
    expect(await ui.find({ type: 'Text', text: /review and ship/i })).toBeDefined()
    await ui.press({ key: 'spec' })
    await ui.unmount()
  }

  expect(filled).toEqual(['/pickle:spec ', '/pickle:spec '])
})
