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

test('the guide lists every phase and fills the prompt', async ($, on) => {
  const filled: string[] = []
  on('prompt.fill', (_, e) => {
    filled.push(e.text)

    return { isFilled: true }
  })

  for (const surface of SURFACES) {
    const ui = await $.ui.mount({ ...GUIDE, surface })
    expect(await ui.find({ type: 'Text', text: /Review and ship/ })).toBeDefined()
    await ui.press({ key: 'spec' })
    await ui.unmount()
  }

  expect(filled).toEqual(['/pickle:spec ', '/pickle:spec '])
})
