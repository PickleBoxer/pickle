import type { ElementTable, RenderSurface } from 'claude-code'

// pickle's marks: the welcome band's, picked by the `logo` option, and the
// guide pane's tile. The terminal draws Raster and Image, the other surfaces
// Svg, so each mark names both.

export const LOGOS = ['tile', 'tile-text', 'badge', 'pixel', 'pixel-tall'] as const
export type Logo = (typeof LOGOS)[number]

export const isLogo = (value: unknown): value is Logo =>
  LOGOS.some(logo => logo === value)

const GREEN = '#8bc34a'
const DARK = '#558b2f'
const BUMP = '#33691e'
const SHINE = '#c5e1a5'
const INK = '#1b2e0b'
const TERMINAL_DEFAULT = 0x01000000

const hex = (color: string) => parseInt(color.slice(1), 16)

const B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

const toBase64 = (bytes: Uint8Array) => {
  let out = ''
  for (let i = 0; i < bytes.length; i += 3) {
    const n = ((bytes[i] ?? 0) << 16) | ((bytes[i + 1] ?? 0) << 8) | (bytes[i + 2] ?? 0)
    out += B64[(n >> 18) & 63]
    out += B64[(n >> 12) & 63]
    out += i + 1 < bytes.length ? B64[(n >> 6) & 63] : '='
    out += i + 2 < bytes.length ? B64[n & 63] : '='
  }
  return out
}

const PALETTE: Record<string, number> = {
  L: hex(GREEN),
  D: hex(DARK),
  B: hex(BUMP),
  H: hex(SHINE),
  K: hex(INK),
}

// Two pixel rows per cell: the top pixel is the foreground of '▀', the bottom
// one its background; a lone bottom pixel is '▄' on the terminal's default.
const rasterCells = (bitmap: readonly string[]) => {
  const columns = bitmap[0]?.length ?? 0
  const rows = Math.ceil(bitmap.length / 2)
  const words = new Uint32Array(columns * rows * 3)

  for (let r = 0; r < rows; r += 1) {
    for (let c = 0; c < columns; c += 1) {
      const top = PALETTE[bitmap[r * 2]?.[c] ?? '.']
      const bottom = PALETTE[bitmap[r * 2 + 1]?.[c] ?? '.']
      const [glyph, fg, bg] =
        top !== undefined
          ? [0x2580, top, bottom ?? TERMINAL_DEFAULT]
          : bottom !== undefined
            ? [0x2584, bottom, TERMINAL_DEFAULT]
            : [0x20, TERMINAL_DEFAULT, TERMINAL_DEFAULT]
      const i = (r * columns + c) * 3
      words[i] = glyph
      words[i + 1] = fg
      words[i + 2] = bg
    }
  }

  return { columns, rows, cells: toBase64(new Uint8Array(words.buffer)) }
}

const PIXEL = rasterCells(['.LLBLLBL.', 'DLLLBLLLD'])

const PIXEL_TALL = rasterCells([
  '..LLLBLLLB..',
  '.LHHLLLLBLL.',
  'LLBLLLBLLLLD',
  '.DLLLBLLLDD.',
])

const P_GLYPH = [
  '.####.',
  '##..##',
  '##..##',
  '##..##',
  '#####.',
  '##....',
  '##....',
  '##....',
]

// 12x12 pixels, 12 by 6 cells: the guide pane's tile, the "p" at column 3, row 2.
const TILE_BIG = rasterCells(
  Array.from({ length: 12 }, (_, y) =>
    Array.from({ length: 12 }, (_, x) => {
      const isCorner = (x === 0 || x === 11) && (y < 2 || y > 9)
      const isEdge = (x < 2 || x > 9) && (y === 0 || y === 11)
      if (isCorner || isEdge) return '.'
      return P_GLYPH[y - 2]?.[x - 3] === '#' ? 'K' : 'L'
    }).join(''),
  ),
)

// 16x16 pixels: a rounded green square with a dark "p", the Svg tile's twin.
const tilePixels = () => {
  const size = 16
  const radius = 4
  const px = new Uint8Array(size * size * 4)

  for (let y = 1; y < size - 1; y += 1) {
    for (let x = 1; x < size - 1; x += 1) {
      const cx = Math.min(Math.max(x + 0.5, 1 + radius), size - 1 - radius)
      const cy = Math.min(Math.max(y + 0.5, 1 + radius), size - 1 - radius)
      if ((x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2 > radius ** 2) continue

      const v = hex(P_GLYPH[y - 5]?.[x - 5] === '#' ? INK : GREEN)
      const i = (y * size + x) * 4
      px[i] = (v >> 16) & 255
      px[i + 1] = (v >> 8) & 255
      px[i + 2] = v & 255
      px[i + 3] = 255
    }
  }

  return { rgba: toBase64(px), width: size, height: size }
}

const TILE = tilePixels()

const TILE_SVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
  <rect x="1" y="1" width="14" height="14" rx="4" fill="${GREEN}"/>
  <text x="8" y="12" font-family="ui-monospace, monospace" font-size="11" font-weight="700" text-anchor="middle" fill="${INK}">p</text>
</svg>`

const PICKLE_SVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 16">
  <g transform="rotate(-10 24 8)">
    <ellipse cx="24" cy="8" rx="21" ry="6.2" fill="${GREEN}" stroke="${DARK}" stroke-width="1.4"/>
    <path d="M11 5.4 Q24 2.6 37 5.4" stroke="${SHINE}" stroke-width="1.3" fill="none" stroke-linecap="round"/>
    <circle cx="13" cy="9" r="1.1" fill="${BUMP}"/>
    <circle cx="20" cy="10.6" r="1.1" fill="${BUMP}"/>
    <circle cx="27" cy="8.4" r="1.1" fill="${BUMP}"/>
    <circle cx="34" cy="10.2" r="1.1" fill="${BUMP}"/>
  </g>
</svg>`

export const drawLogo = (
  els: ElementTable,
  surface: RenderSurface,
  logo: Logo,
) => {
  const { Text } = els

  if (logo === 'badge') {
    return (
      <Text backgroundColor={GREEN} color={INK} weight="bold">
        {' pickle '}
      </Text>
    )
  }

  if (surface === 'terminal' && 'Raster' in els) {
    const { Image, Raster } = els

    switch (logo) {
      case 'tile':
        return <Image key="logo" source={TILE} columns={2} rows={1} alt="pickle" />
      case 'tile-text':
        return (
          <Text backgroundColor={GREEN} color={INK} weight="bold">
            {' p '}
          </Text>
        )
      case 'pixel':
        return <Raster key="logo" {...PIXEL} />
      case 'pixel-tall':
        return <Raster key="logo" {...PIXEL_TALL} />
    }
  }

  if ('Svg' in els) {
    const { Svg } = els

    return logo === 'pixel' || logo === 'pixel-tall' ? (
      <Svg source={PICKLE_SVG} alt="pickle" width={36} height={12} />
    ) : (
      <Svg source={TILE_SVG} alt="pickle" width={14} height={14} />
    )
  }

  return (
    <Text color={GREEN} weight="bold">
      pickle
    </Text>
  )
}

export const drawGuideMark = (els: ElementTable, surface: RenderSurface) => {
  if (surface === 'terminal' && 'Raster' in els) {
    const { Raster } = els

    return <Raster key="guide-mark" {...TILE_BIG} />
  }

  if ('Svg' in els) {
    const { Svg } = els

    return <Svg source={TILE_SVG} alt="pickle" width={40} height={40} />
  }

  const { Text } = els

  return (
    <Text backgroundColor={GREEN} color={INK} weight="bold">
      {' p '}
    </Text>
  )
}
