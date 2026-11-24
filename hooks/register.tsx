import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import { drawLogo, isLogo } from './logo'

// Three ways into pickle: a welcome band above the prompt, a tip on the
// first task-shaped or long prompt, and a guide pane opened by /pickle-guide.
// After a turn it suggests the next step: correct after the user corrects a
// repeated mistake (once), review after edits, reflect after a review or ship
// that changed nothing.

const GUIDE = 'guide'
const GREEN = '#8bc34a'
const TASK = /\b(build|implement|add|create|refactor|migrate|fix|ship)\b/i
const CORRECTION =
  /\b(i told you|told you (before|already)|how many times|you keep|i already said|stop (doing|using|adding)|we never|same mistake)\b/i
const LONG_ASK = 600
const EDITS = new Set(['Edit', 'Write', 'NotebookEdit'])
const FINISHERS = new Set(['pickle:review', 'pickle:ship'])

const isWelcomeHidden = atom(
  { plugin: 'pickle', key: 'isWelcomeHidden' } as const,
  false,
)

const PHASES = [
  {
    name: 'Start',
    items: [
      ['pickle-mode', 'map a task to the workflow skills'],
      ['reframe', 'learn the words for what you build'],
      ['sharpen', 'rewrite a rough prompt'],
      ['in-your-own-words', 'restate your goal before work starts'],
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
      ['no-comments', 'delete comments, flag workarounds'],
    ],
  },
  {
    name: 'Review and ship',
    items: [
      ['review', 'review the change'],
      ['webperf', 'audit web performance'],
      ['ship', 'pre-launch checklist'],
      ['reflect', 'review this session'],
      ['correct', 'make repeated mistakes impossible'],
    ],
  },
  {
    name: 'Understand',
    items: [
      ['teach', 'explain how and why code works'],
      ['audit-architecture', 'audit state and data'],
      ['improve-codebase-architecture', 'find deepening opportunities'],
    ],
  },
] as const

export const register: Register = (on, options) => {
  const logo = isLogo(options.logo) ? options.logo : 'tile'

  let isTipped = false
  let edits = 0
  let isFinishing = false
  let isCorrection = false
  let isCorrectSuggested = false

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
    isFinishing = FINISHERS.has(e.command?.name ?? '')
    isCorrection = !e.command && !e.isMeta && CORRECTION.test(e.text)
    const isLong = e.text.length > LONG_ASK

    if (e.command?.name.startsWith('pickle:')) {
      isTipped = true
      await update($, isWelcomeHidden, () => true)
    } else if (!isTipped && !e.command && !e.isMeta && isLong) {
      isTipped = true
      $.ui.toast(
        '🥒 Long ask. /pickle:in-your-own-words checks it was understood first',
      )
    } else if (!isTipped && !e.command && !e.isMeta && TASK.test(e.text)) {
      isTipped = true
      $.ui.toast(
        '🥒 Looks like a task. /pickle:pickle-mode picks the skills for it',
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

    if (isCorrection && !isCorrectSuggested) {
      isCorrectSuggested = true
      void $.prompt.suggest({ text: '/pickle:correct' })
    } else if (edits > 0) {
      void $.prompt.suggest({ text: '/pickle:review' })
    } else if (isFinishing) {
      void $.prompt.suggest({ text: '/pickle:reflect' })
    }

    return done
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey || (await read($, isWelcomeHidden))) {
      return next(e)
    }

    const els = $.ui.resolve(e)
    const { Box, Button } = els

    return (
      <Box gap={1} alignItems="center">
        {drawLogo(els, e.surface, logo)}
        <Button
          key="mode"
          label="Pickle mode"
          hotkey="1"
          variant="primary"
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
          dimColor
          onPress={() => $.ui.open({ id: GUIDE, title: 'pickle' })}
        />
        <Button
          key="hide"
          role="dismiss"
          plain
          dimColor
          label="hide"
          onPress={() => update($, isWelcomeHidden, () => true)}
        />
      </Box>
    )
  })

  on('ui.render', { component: 'Pane', requestId: GUIDE }, async ($, e) => {
    const { Box, Button, Text } = $.ui.resolve(e)

    return (
      <Box flexDirection="column" gap={1}>
        {PHASES.map(phase => (
          <Box key={phase.name} flexDirection="column">
            <Text color={GREEN} weight="bold" size="caption">
              {phase.name.toUpperCase()}
            </Text>
            {phase.items.map(([name, what]) => (
              <Box key={`row-${name}`} hover={{ backgroundColor: 'subtle' }}>
                <Box width={30}>
                  <Button
                    key={name}
                    plain
                    label={name}
                    onPress={() => $.prompt.fill({ text: `/pickle:${name} ` })}
                  />
                </Box>
                <Text dimColor wrap="truncate-end">
                  {what}
                </Text>
              </Box>
            ))}
          </Box>
        ))}
        <Text dimColor italic>
          Pick one to put it in the prompt box. Type /pickle: for the rest.
        </Text>
      </Box>
    )
  })
}
