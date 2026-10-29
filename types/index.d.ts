export type IsHidden = boolean

declare module 'claude-code' {
  interface PluginState {
    pickle: { isWelcomeHidden: IsHidden }
  }
}
