import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

// Three ways into pickle: a welcome band above the prompt, a tip on the
// first task-shaped prompt, and a guide pane opened by /pickle-guide.

const GUIDE = 'guide'
const TASK = /\b(build|implement|add|create|refactor|migrate|fix|ship)\b/i
const EDITS = new Set(['Edit', 'Write', 'NotebookEdit'])

const isWelcomeHidden = atom(
  { plugin: 'pickle', key: 'isWelcomeHidden' } as const,
  false,
)

const PHASES = [
  {
    name: 'Start',
    items: [
      ['pickle-mode', 'map a task to the workflow skills'],
      ['sharpen', 'rewrite a rough prompt'],
      ['setup', 'set up this repo for pickle'],
    ],
  },
  {
    name: 'Define and plan',
    items: [
      ['spec', 'write a spec before code'],
      ['plan', 'break work into tasks'],
      ['constraints', 'pin down the constraints'],
    ],
  },
  {
    name: 'Build and verify',
    items: [
      ['build', 'implement in small steps'],
      ['test', 'test-first'],
      ['code-simplify', 'simplify without changing behaviour'],
    ],
  },
  {
    name: 'Review and ship',
    items: [
      ['review', 'review the change'],
      ['webperf', 'audit web performance'],
      ['ship', 'pre-launch checklist'],
    ],
  },
  {
    name: 'Understand',
    items: [
      ['teach', 'explain how and why code works'],
      ['audit-architecture', 'audit state and data'],
      ['improve-codebase-architecture', 'find deepening opportunities'],
      ['reflect', 'review this session'],
    ],
  },
] as const

export const register: Register = on => {
  let isTipped = false
  let edits = 0

  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'pickle-guide',
      description: "Open a pane of pickle's commands and skills",
    })

    return next(e)
  })

  on('command.run', { command: 'pickle-guide' }, async $ => {
    await $.ui.open({ id: GUIDE, title: 'pickle' })

    return { text: 'pickle guide opened.' }
  })

  on('prompt.submit', async ($, e, next) => {
    edits = 0

    if (e.command?.name.startsWith('pickle:')) {
      isTipped = true
      await update($, isWelcomeHidden, () => true)
    } else if (!isTipped && !e.command && !e.isMeta && TASK.test(e.text)) {
      isTipped = true
      $.ui.toast(
        'Tip: /pickle:pickle-mode <task> picks the workflow skills for a task like this one',
      )
    }

    return next(e)
  })

  on('tool.call', ($, e, next) => {
    if (EDITS.has(e.tool)) {
      edits += 1
    }

    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const done = await next(e)

    if (edits > 0) {
      void $.prompt.suggest({ text: '/pickle:review' })
    }

    return done
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey || (await read($, isWelcomeHidden))) {
      return next(e)
    }

    const { Box, Button, Text } = $.ui.resolve(e)

    return (
      <Box flexDirection="column">
        <Text>
          <Text bold>pickle</Text>
          <Text dimColor> · describe a task after one of these, or just type</Text>
        </Text>
        <Box gap={1}>
          <Button
            key="mode"
            label="Pickle mode"
            hotkey="1"
            onPress={() => $.prompt.fill({ text: '/pickle:pickle-mode ' })}
          />
          <Button
            key="sharpen"
            label="Sharpen a prompt"
            hotkey="2"
            onPress={() => $.prompt.fill({ text: '/pickle:sharpen ' })}
          />
          <Button
            key="setup"
            label="Set up this repo"
            hotkey="3"
            onPress={() => $.prompt.fill({ text: '/pickle:setup' })}
          />
          <Button
            key="guide"
            label="All commands"
            hotkey="4"
            onPress={() => $.ui.open({ id: GUIDE, title: 'pickle' })}
          />
          <Button
            key="hide"
            label="Hide"
            onPress={() => update($, isWelcomeHidden, () => true)}
          />
        </Box>
      </Box>
    )
  })

  on('ui.render', { component: 'Pane', requestId: GUIDE }, async ($, e) => {
    const { Box, Button, Text } = $.ui.resolve(e)

    return (
      <Box flexDirection="column" gap={1}>
        <Text dimColor>Pick one to put it in the prompt box.</Text>
        {PHASES.map(phase => (
          <Box key={phase.name} flexDirection="column">
            <Text bold>{phase.name}</Text>
            {phase.items.map(([name, what]) => (
              <Box key={name} gap={1}>
                <Button
                  key={name}
                  label={`/pickle:${name}`}
                  onPress={() => $.prompt.fill({ text: `/pickle:${name} ` })}
                />
                <Text dimColor>{what}</Text>
              </Box>
            ))}
          </Box>
        ))}
      </Box>
    )
  })
}
