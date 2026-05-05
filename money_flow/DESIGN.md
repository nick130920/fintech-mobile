---
name: MoneyFlow
description: >-
  A modern personal-finance app whose default look is an atmospheric, glassmorphic
  dark surface tinted with the brand's signature electric blue. A sibling light
  theme is provided as an override.
mode: dark
device: mobile

colors:
  primary: "#007BFF"
  on-primary: "#FFFFFF"
  primary-container: "#003F80"
  on-primary-container: "#CFE5FF"
  inverse-primary: "#003F80"
  primary-fixed: "#CFE5FF"
  primary-fixed-dim: "#9DCBFF"
  on-primary-fixed: "#001D36"
  on-primary-fixed-variant: "#003F80"

  secondary: "#94A3B8"
  on-secondary: "#0F172A"
  secondary-container: "#1E293B"
  on-secondary-container: "#E2E8F0"
  secondary-fixed: "#E2E8F0"
  secondary-fixed-dim: "#CBD5E1"
  on-secondary-fixed: "#0F172A"
  on-secondary-fixed-variant: "#334155"

  tertiary: "#F87171"
  on-tertiary: "#FFFFFF"
  tertiary-container: "#7F1D1D"
  on-tertiary-container: "#FECACA"
  tertiary-fixed: "#FECACA"
  tertiary-fixed-dim: "#FCA5A5"
  on-tertiary-fixed: "#450A0A"
  on-tertiary-fixed-variant: "#7F1D1D"

  error: "#EF4444"
  on-error: "#FFFFFF"
  error-container: "#7F1D1D"
  on-error-container: "#FCA5A5"

  background: "#0A0F14"
  on-background: "#F8FAFC"
  surface: "#0A0F14"
  on-surface: "#F8FAFC"
  surface-variant: "#334155"
  on-surface-variant: "#CBD5E1"
  surface-tint: "#007BFF"
  surface-dim: "#0A0F14"
  surface-bright: "#1E293B"
  surface-container-lowest: "#06090C"
  surface-container-low: "#0F172A"
  surface-container: "#1E293B"
  surface-container-high: "#293548"
  surface-container-highest: "#334155"

  outline: "#94A3B8"
  outline-variant: "#334155"
  inverse-surface: "#F8FAFC"
  inverse-on-surface: "#0F172A"

  income: "#007BFF"
  expense: "#F87171"
  expense-today: "#F97316"
  status-good: "#4ADE80"
  status-warning: "#FBBF24"
  status-danger: "#F87171"
  success: "#10B981"
  warning: "#F59E0B"
  info: "#3B82F6"

  brand-gradient-start: "#00D4FF"
  brand-gradient-mid: "#007BFF"
  brand-gradient-end: "#001D6C"

overlays:
  scrim: "rgba(0, 0, 0, 0.40)"
  glass-tint-soft: "rgba(0, 123, 255, 0.05)"
  glass-tint-medium: "rgba(0, 123, 255, 0.10)"
  glass-tint-strong: "rgba(0, 123, 255, 0.15)"
  glass-card-base: "rgba(255, 255, 255, 0.03)"
  glass-card-border: "rgba(255, 255, 255, 0.05)"
  glass-shine: "rgba(255, 255, 255, 0.30)"
  glass-shine-strong: "rgba(255, 255, 255, 0.40)"
  text-disabled: "rgba(248, 250, 252, 0.40)"
  text-watermark: "rgba(248, 250, 252, 0.10)"
  divider: "rgba(0, 123, 255, 0.10)"
  cta-glow: "rgba(0, 123, 255, 0.30)"
  success-soft: "rgba(16, 185, 129, 0.15)"
  warning-soft: "rgba(245, 158, 11, 0.15)"
  error-soft: "rgba(239, 68, 68, 0.15)"
  info-soft: "rgba(59, 130, 246, 0.15)"

gradients:
  brand-wave:
    type: linear
    angle: 90
    stops:
      - { offset: 0.0, color: "#00D4FF" }
      - { offset: 0.5, color: "#007BFF" }
      - { offset: 1.0, color: "#001D6C" }
  glass-card-dark:
    type: linear
    angle: 135
    stops:
      - { offset: 0.0, color: "rgba(0, 123, 255, 0.15)" }
      - { offset: 1.0, color: "rgba(0, 123, 255, 0.08)" }
  glass-card-heavy-dark:
    type: linear
    angle: 135
    stops:
      - { offset: 0.0, color: "rgba(0, 123, 255, 0.25)" }
      - { offset: 1.0, color: "rgba(0, 123, 255, 0.18)" }
  button-glass-primary:
    type: linear
    angle: 135
    stops:
      - { offset: 0.0, color: "rgba(0, 123, 255, 0.80)" }
      - { offset: 1.0, color: "rgba(0, 123, 255, 0.60)" }
  button-glass-floating:
    type: linear
    angle: 135
    stops:
      - { offset: 0.0, color: "rgba(0, 123, 255, 0.95)" }
      - { offset: 1.0, color: "rgba(0, 123, 255, 0.80)" }

typography:
  fontFamily: Inter
  display-lg:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: "700"
    lineHeight: 48px
    letterSpacing: -0.02em
  display-md:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: "700"
    lineHeight: 44px
    letterSpacing: -0.02em
  display-sm:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: "700"
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: "700"
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: "700"
    lineHeight: 32px
    letterSpacing: 0em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: "700"
    lineHeight: 28px
    letterSpacing: 0em
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: "600"
    lineHeight: 28px
    letterSpacing: 0em
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: "600"
    lineHeight: 24px
    letterSpacing: 0em
  title-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: "600"
    lineHeight: 22px
    letterSpacing: 0em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: "400"
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "400"
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: "400"
    lineHeight: 16px
    letterSpacing: 0em
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "500"
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: "500"
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: "500"
    lineHeight: 14px
    letterSpacing: 0.04em
  custom-amount-hero:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: "700"
    lineHeight: 34px
    letterSpacing: -0.01em
  custom-amount-card:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: "700"
    lineHeight: 24px
    letterSpacing: 0em
  custom-eyebrow:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: "600"
    lineHeight: 16px
    letterSpacing: 0.10em
    textTransform: uppercase

spacing:
  base: 8px
  step-1: 4px
  step-2: 8px
  step-3: 12px
  step-4: 16px
  step-5: 24px
  step-6: 32px
  step-7: 40px
  step-8: 48px
  step-xxl: 64px
  screen-padding: 24px
  card-padding: 16px
  card-padding-lg: 24px
  glass-padding: 20px
  section-gap: 32px
  card-gap: 16px
  field-gap: 8px
  inline-gap: 12px

rounded:
  none: 0
  xs: 4px
  sm: 8px
  DEFAULT: 12px
  md: 14px
  lg: 16px
  xl: 20px
  pill: 9999px

border:
  width:
    hairline: 1px
    default: 1px
    emphasized: 2px
    accent: 4px
  style:
    solid: solid

elevation:
  0: 0
  1: 1
  2: 2
  3: 3
  4: 4
  5: 5

shadows:
  none: none
  card-light: "0 2px 6px rgba(0, 0, 0, 0.05)"
  card-dark: "0 4px 12px rgba(0, 0, 0, 0.30)"
  hover-light: "0 6px 15px rgba(0, 0, 0, 0.10)"
  hover-dark: "0 6px 15px rgba(0, 0, 0, 0.30)"
  cta-glow: "0 8px 15px rgba(0, 123, 255, 0.30)"
  modal: "0 12px 32px rgba(0, 0, 0, 0.20)"
  snackbar: "0 2px 8px rgba(0, 0, 0, 0.10)"

blur:
  glass-light-soft: 2px
  glass-light-medium: 4px
  glass-light-heavy: 8px
  glass-dark-soft: 8px
  glass-dark-medium: 15px
  glass-dark-heavy: 25px
  button-primary: 10px
  button-secondary: 15px
  button-outline: 8px
  button-floating: 20px

opacity:
  text-primary: 1.00
  text-secondary: 0.80
  text-tertiary: 0.60
  text-quaternary: 0.40
  text-disabled: 0.35
  divider: 0.10
  watermark: 0.20

motion:
  duration:
    instant: 0ms
    fast: 150ms
    base: 200ms
    medium: 300ms
    slow: 400ms
    pronounced: 600ms
    cinematic: 1200ms
    pulse-cycle: 2000ms
  easing:
    standard: cubic-bezier(0.4, 0, 0.2, 1)
    ease-in: cubic-bezier(0.4, 0, 1, 1)
    ease-out: cubic-bezier(0, 0, 0.2, 1)
    ease-in-out: cubic-bezier(0.4, 0, 0.2, 1)
    ease-out-cubic: cubic-bezier(0.33, 1, 0.68, 1)
    elastic: cubic-bezier(0.34, 1.56, 0.64, 1)
  primitives:
    entry-card:
      duration: 400ms
      easing: "{motion.easing.ease-out}"
      keyframes:
        from: { scale: 0.95, opacity: 0 }
        to: { scale: 1.0, opacity: 1 }
    entry-card-cinematic:
      duration: 1200ms
      easing: "{motion.easing.ease-out}"
      keyframes:
        from: { scale: 0.95, opacity: 0 }
        to: { scale: 1.0, opacity: 1 }
    list-item-slide-in:
      duration: 400ms
      easing: "{motion.easing.ease-out-cubic}"
      stagger: 50ms
      keyframes:
        from: { translateX: "20%", opacity: 0 }
        to: { translateX: "0%", opacity: 1 }
    hover-lift-card:
      duration: 200ms
      easing: "{motion.easing.standard}"
      keyframes:
        to: { scale: 1.02 }
    hover-lift-list:
      duration: 150ms
      easing: "{motion.easing.standard}"
      keyframes:
        to: { scale: 1.01 }
    press-scale:
      duration: 200ms
      easing: "{motion.easing.ease-in-out}"
      keyframes:
        to: { scale: 0.95 }
    pulse-cta:
      duration: 2000ms
      easing: "{motion.easing.ease-in-out}"
      repeat: infinite-yoyo
      keyframes:
        from: { scale: 1.0 }
        to: { scale: 1.05 }
    ripple:
      duration: 600ms
      easing: "{motion.easing.ease-out}"
      keyframes:
        from: { radius: 0, opacity: 1 }
        to: { radius: "50% diagonal", opacity: 0 }
    snackbar-enter:
      duration: 300ms
      easing: "{motion.easing.ease-out}"
      keyframes:
        from: { translateY: -50px, opacity: 0 }
        to: { translateY: 0, opacity: 1 }

iconography:
  family: Material Symbols Outlined
  default-size: 22px
  small-size: 16px
  large-size: 24px
  hero-size: 56px
  empty-state-size: 64px
  watermark-opacity: 0.20
  stroke-style: line-based with rounded caps
  recurring:
    - account_balance_wallet
    - shopping_cart
    - trending_up
    - receipt
    - analytics
    - event_repeat
    - notifications_outlined
    - settings_outlined
    - person
    - add_card
    - keyboard_arrow_down
    - arrow_forward_ios
    - check_circle_outline
    - error_outline
    - warning_amber_outlined
    - info_outline

breakpoints:
  phone: 0
  phone-lg: 414px
  tablet: 600px
  desktop: 1024px

z-index:
  base: 0
  raised: 1
  drawer: 100
  bottom-sheet: 200
  modal: 300
  snackbar: 400
  popover: 500
  tooltip: 600

components:
  app-bar:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    typography: "{typography.title-md}"
    rounded: "{rounded.none}"
    padding: "{spacing.step-4}"
    height: 56px
  text-button:
    backgroundColor: transparent
    textColor: "{colors.primary}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.sm}"
    padding: "{spacing.step-3}"
  icon-button:
    backgroundColor: "{colors.surface-container}"
    textColor: "{colors.on-surface-variant}"
    rounded: "{rounded.pill}"
    padding: "{spacing.step-3}"
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.title-sm}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-4}"
  button-primary-disabled:
    backgroundColor: "{colors.primary-container}"
    textColor: "{overlays.text-disabled}"
    typography: "{typography.title-sm}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-4}"
  button-glass-primary:
    backgroundColor: "{gradients.button-glass-primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.title-sm}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-4}"
  button-glass-floating:
    backgroundColor: "{gradients.button-glass-floating}"
    textColor: "{colors.on-primary}"
    typography: "{typography.title-sm}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-4}"
  button-glass-outline:
    backgroundColor: "{overlays.glass-tint-medium}"
    textColor: "{colors.primary}"
    typography: "{typography.title-sm}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-4}"
  glass-card-light:
    backgroundColor: "{overlays.glass-card-base}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    padding: "{spacing.glass-padding}"
  glass-card-medium:
    backgroundColor: "{gradients.glass-card-dark}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    padding: "{spacing.step-5}"
  glass-card-heavy:
    backgroundColor: "{gradients.glass-card-heavy-dark}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    padding: "{spacing.step-5}"
  glass-list-item:
    backgroundColor: "{gradients.glass-card-dark}"
    textColor: "{colors.on-surface}"
    typography: "{typography.title-sm}"
    rounded: "{rounded.lg}"
    padding: "{spacing.step-4}"
  input-field:
    backgroundColor: "{colors.surface-container}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-md}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-4}"
  amount-input:
    backgroundColor: "{colors.surface-container-high}"
    textColor: "{colors.on-surface}"
    typography: "{typography.custom-amount-hero}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-4}"
  selector-row:
    backgroundColor: "{colors.surface-container}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-md}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-4}"
  chip-info:
    backgroundColor: "{overlays.glass-tint-medium}"
    textColor: "{colors.primary}"
    typography: "{typography.label-md}"
    rounded: "{rounded.pill}"
    padding: "{spacing.step-3}"
  badge-success:
    backgroundColor: "{overlays.success-soft}"
    textColor: "{colors.status-good}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.pill}"
    padding: "{spacing.step-2}"
  badge-warning:
    backgroundColor: "{overlays.warning-soft}"
    textColor: "{colors.status-warning}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.pill}"
    padding: "{spacing.step-2}"
  badge-danger:
    backgroundColor: "{overlays.error-soft}"
    textColor: "{colors.status-danger}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.pill}"
    padding: "{spacing.step-2}"
  progress-bar:
    backgroundColor: "{colors.surface-container}"
    textColor: "{colors.primary}"
    rounded: "{rounded.sm}"
    padding: "0px"
  bottom-sheet:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    typography: "{typography.headline-sm}"
    rounded: "{rounded.xl}"
    padding: "{spacing.step-5}"
  snackbar-error:
    backgroundColor: "{overlays.error-soft}"
    textColor: "{colors.error}"
    typography: "{typography.body-md}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-3}"
  snackbar-success:
    backgroundColor: "{overlays.success-soft}"
    textColor: "{colors.success}"
    typography: "{typography.body-md}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-3}"
  snackbar-warning:
    backgroundColor: "{overlays.warning-soft}"
    textColor: "{colors.warning}"
    typography: "{typography.body-md}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-3}"
  snackbar-info:
    backgroundColor: "{overlays.info-soft}"
    textColor: "{colors.info}"
    typography: "{typography.body-md}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-3}"
  empty-state:
    backgroundColor: transparent
    textColor: "{colors.on-surface-variant}"
    typography: "{typography.title-md}"
    rounded: "{rounded.none}"
    padding: "{spacing.step-5}"
  skeleton-block:
    backgroundColor: "{colors.surface-container}"
    textColor: "{colors.surface-container-high}"
    rounded: "{rounded.DEFAULT}"
    padding: "0px"
  divider:
    backgroundColor: "{overlays.divider}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.none}"
    padding: "0px"
  category-tile-income:
    backgroundColor: "{overlays.glass-tint-strong}"
    textColor: "{colors.primary}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-3}"
  category-tile-expense:
    backgroundColor: "{overlays.error-soft}"
    textColor: "{colors.expense}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-3}"
  bank-account-card:
    backgroundColor: "{overlays.glass-card-base}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-md}"
    rounded: "{rounded.DEFAULT}"
    padding: "{spacing.step-4}"
  dashboard-header:
    backgroundColor: "{overlays.glass-tint-soft}"
    textColor: "{colors.on-surface}"
    typography: "{typography.title-md}"
    rounded: "{rounded.none}"
    padding: "{spacing.step-4}"

themes:
  dark:
    background: "{colors.background}"
    surface: "{colors.surface}"
    on-surface: "{colors.on-surface}"
    glass-style: atmospheric-blur
    aesthetic: deep navy backdrop with electric blue glass
  light:
    overrides:
      background: "#F6F8FA"
      on-background: "#0F172A"
      surface: "#F6F8FA"
      on-surface: "#0F172A"
      surface-variant: "#E2E8F0"
      on-surface-variant: "#334155"
      surface-dim: "#D9DEE6"
      surface-bright: "#FFFFFF"
      surface-container-lowest: "#FFFFFF"
      surface-container-low: "#F8FAFC"
      surface-container: "#F1F5F9"
      surface-container-high: "#E9EFF5"
      surface-container-highest: "#E2E8F0"
      outline: "#64748B"
      outline-variant: "#CBD5E1"
      primary-container: "#CFE5FF"
      on-primary-container: "#003F80"
      secondary-container: "#E2E8F0"
      on-secondary-container: "#0F172A"
      tertiary-container: "#FECACA"
      on-tertiary-container: "#7F1D1D"
      error-container: "#FECACA"
      on-error-container: "#7F1D1D"
      inverse-surface: "#0F172A"
      inverse-on-surface: "#F1F5F9"
      inverse-primary: "#9DCBFF"
    glass-style: tonal-soft
    aesthetic: clean, professional, slate-on-white
---

## Brand & Style

MoneyFlow is a personal-finance product whose visual identity is built around
the metaphor of **money as a flowing current**. The brand wave-mark — three
parallel ribbons crossing left-to-right in a cyan → mid-blue → deep-navy
gradient (`#00D4FF → #007BFF → #001D6C`) — sets the entire system's tone:
confident, modern, technological, and unmistakably financial.

The interface is **dual-surface**, with the **dark theme as the primary**
expression. The dark canvas (`#0A0F14`) becomes a stage for stacked layers of
frosted blue glass: cards float on diagonal `rgba(0, 123, 255, 0.15 → 0.08)`
gradients, white-alpha edges suggest light refraction, and a subtle ambient
shadow grounds each surface. The light theme is a clean, slate-on-white
override for daytime / accessibility contexts; both themes share the same
electric-blue accent (`#007BFF`), the same Inter typography, and the same
Material 3 token spine.

Personality is **calm-but-decisive**: gentle entry animations and subtle
hover lifts make the UI feel alive without being playful, while bold amounts,
strong primary CTAs, and deliberate semantic color usage signal that this is
a tool you can trust with money.

## Colors

The palette is anchored by a single **primary blue** (`#007BFF`) that drives
brand, links, primary buttons, focus rings, and progress fills. Everything
else is built around a **slate neutral spine** (50–900) and a small, opinionated
set of semantic colors.

- **Primary action:** Bright cobalt blue. Used solid for CTAs, at 5–15% alpha
  for chip backgrounds and focus rings (see `overlays.glass-tint-*`), and at
  30% alpha for floating-button glow shadows.
- **Income & positive trend:** The primary blue doubles as the income color —
  earning money is a brand-positive event.
- **Expense:** A muted, friendly red (`#F87171`) that stays away from
  alarm-red. It signals "money out" without scolding. Promoted to `tertiary`
  in the M3 role mapping.
- **Today's spending / urgency:** A warm orange (`#F97316`) is reserved for
  "Gastos de Hoy" and other immediacy cues.
- **Status palette:** A green / amber / red trio (`#4ADE80`, `#FBBF24`,
  `#F87171`) drives budget-health indicators, badges, and status pills, each
  paired with a 15%-alpha background overlay.
- **Semantic feedback (snackbars / inline alerts):** Saturated icon hues
  (`success #10B981`, `warning #F59E0B`, `error #EF4444`, `info #3B82F6`)
  paired with very soft tinted backgrounds in `overlays.*-soft`.
- **Surfaces (dark — primary):** Near-black `#0A0F14` canvas; elevated
  containers walk a slate ramp from `#06090C` (lowest) → `#334155` (highest).
  Glass cards float on top via blue-tinted gradients (`gradients.glass-card-*`)
  with a 1 px white-alpha border (`overlays.glass-shine`) to suggest a
  refracting edge.
- **Surfaces (light — override):** Canvas `#F6F8FA`; ramp `#FFFFFF` →
  `#E2E8F0`. Glass cards in light theme use the slate ramp directly with a
  subtle 2 px backdrop blur and a 20% outline border instead of white-alpha
  refraction.

Text on surfaces steps down by **alpha hierarchy** rather than by hue:
**100% → 80% → 60% → 40%** is the standard ladder for primary, secondary,
tertiary and quaternary on-surface text.

## Typography

The product is set in **Inter** end-to-end, chosen for its neutral mechanical
clarity and for how cleanly numerals render at currency-amount sizes. The
type scale follows Material 3 (`display / headline / title / body / label`)
with a strict three-step ramp (`lg / md / sm`) per role, plus three custom
roles needed by financial UI:

- **`custom-amount-hero`** (28 px / 700, kerned tight) for budget total,
  balances, and the leading number of the dashboard.
- **`custom-amount-card`** (18 px / 700) for in-card balances and per-row
  amounts in transaction lists.
- **`custom-eyebrow`** (12 px / 600, ALL CAPS, +0.10em letter-spacing in
  primary blue) — the system's signature label treatment, used to introduce
  hero metrics (e.g. "PRESUPUESTO MENSUAL").

Buttons are 16 px / 600 — substantial enough to feel tappable on mobile but
not so heavy that secondary actions overwhelm content. Body / metadata sit
at 14 / 12 px and step down via **on-surface alpha** rather than a separate
gray ramp. Number formatting is delegated to the runtime locale/currency
layer; the design system reserves consistent typography for amount roles
regardless of currency code.

## Layout & Spacing

Everything snaps to an **8 px grid**. The canonical scale is `step-1 (4) /
step-2 (8) / step-3 (12) / step-4 (16) / step-5 (24) / step-6 (32) /
step-7 (40) / step-8 (48) / step-xxl (64)`. Steps `4` and `5` (16 / 24 px)
carry the most weight in production layouts.

- **Screen padding:** `24 px` on sides for content forms; dashboards use
  `16 px` outer padding so glass cards can breathe edge-to-edge.
- **Card padding:** `16 px` for compact metric cards, `20 px` for default
  glass containers, `24 px` for the hero "Presupuesto Mensual" card.
- **Section rhythm:** `32 px` of vertical whitespace separates major
  dashboard sections (budget → daily overview → bank accounts → recent
  transactions). Within a section, `16 px` is the standard card-to-card gap
  and `24 px` separates the section title from its content.
- **Form rhythm:** Field label ⇢ input is `8 px`. Stacked fields are
  separated by `16 px`. Optional or auxiliary fields are tucked into an
  expandable section to keep primary forms uncluttered.
- **Bank-account horizontals:** A 200 × 160 px card width with a 16 px
  inter-card gap is reserved for horizontally scrolling collections.

Layouts default to a single mobile column. Two-column grids appear only for
balance + today's-spending overview cards on the dashboard.

## Elevation & Depth

Depth in MoneyFlow is expressed through **two simultaneous languages**:

1. **Dark theme (primary):** translucent glass surfaces with **backdrop blur**
   layered over a deep navy canvas — atmospheric, premium.
2. **Light theme:** subtle ambient shadows over white-on-slate surfaces —
   classic, conservative fintech.

The glass stack is graded into three levels (see `components.glass-card-*`):

- **Light glass:** 2–8 px blur, 5% surface alpha. Used for secondary cards
  (e.g. individual bank-account tiles in horizontal carousels).
- **Medium glass:** 4–15 px blur, 10–15% alpha — the **default card** style.
  Most dashboard surfaces, list items, and modal sheets land here.
- **Heavy glass:** 8–25 px blur, 18–25% alpha — reserved for focal cards
  (the budget hero) and overlay surfaces.

Glass surfaces in dark theme always carry:

- A diagonal 135° linear-gradient fill that lightens toward the top-left
  (`gradients.glass-card-dark`).
- A **1 px white border at 30% alpha** (`overlays.glass-shine`, bumped to 40%
  on hover via `overlays.glass-shine-strong`) to mimic a refracting edge.
  Light-theme equivalents use a 1 px `outline-variant` at 20% opacity.
- A soft drop shadow `shadows.card-dark` (`0 4px 12px rgba(0,0,0,0.30)`).
  Light-theme uses `shadows.card-light` (`0 2px 6px rgba(0,0,0,0.05)`).

Hover state — applied only on desktop / web — adds:

- A `1.01–1.02×` scale-up (`motion.primitives.hover-lift-*`).
- An additional luminance gradient overlay on glass buttons.
- A subtle border-alpha bump from 30% → 40%.

A performance scaler (0.4–1.0) clamps blur strength on older or low-end
devices and is bypassed entirely below the 0.6 threshold or under
`prefers-reduced-motion`. The light theme skips backdrop-filter altogether.

## Shapes

Corner radii follow a tight scale (`xs 4 / sm 8 / DEFAULT 12 / md 14 / lg 16
/ xl 20 / pill 9999`), with `12 px` doing the heaviest lifting:

- **Cards & glass containers:** `lg` (16 px). Soft enough to feel modern,
  structured enough to hold dense data.
- **Buttons & inputs:** `DEFAULT` (12 px). Friendly without losing the
  rectangular discipline a financial UI rewards.
- **Pills & chips:** `pill` (9999 px) for status badges, info chips
  ("Rollover diario"), and notification dots.
- **Modal / bottom-sheet tops:** `xl` (20 px) on the top corners only, with
  a 40 × 4 px grabber handle at 30% alpha.
- **Avatars & circular icon buttons:** `pill` (full circle).
- **Accent bars:** A `4 px` left-edge accent bar carries per-account brand
  colors on bank-account cards.

Iconography follows the same gentle visual register: outlined Material
Symbols at 22 px default, line-based with rounded caps so they harmonize
with the soft container radii. A single oversized icon at 56 px and 20%
opacity is used as a watermark in the budget hero card to suggest a
data-rich surface without crowding it.

## Motion

Motion is calm and purposeful — animations communicate hierarchy and
freshness, never flair. All primitives are defined declaratively under
`motion.primitives.*` with from/to keyframes:

- **Entry animations** for cards run 400 ms (1200 ms for the budget hero):
  `scale 0.95 → 1.0` paired with `opacity 0 → 1`, eased out.
- **List items** slide in from the right (`translateX 20% → 0`,
  ease-out-cubic, 400 ms) with a 50 ms stagger per index, producing a soft
  cascade.
- **Hover** on cards is 200 ms / `1.02×`, on list rows 150 ms / `1.01×`.
- **Press** on buttons scales to `0.95×` for 200 ms with ease-in-out.
- **Floating CTAs** carry an idle pulse: `1.0 ↔ 1.05` over a 2 s yoyo, with a
  per-instance jittered start delay so multiple CTAs never pulse in lockstep.
- **Ripples** fan from the touch point with a radial expansion to half the
  diagonal, fading from full to zero alpha across 600 ms.
- **Snackbars** drop in from above the safe area: `translateY -50 px → 0`
  with `opacity 0 → 1` over 300 ms, dismissed automatically after 4 s.

A `prefers-reduced-motion` preference downgrades motion globally — the
performance scale halves and entry/list animations are skipped.

## Components

### Glass Cards

The product's defining surface. Three intensities (`glass-card-light /
medium / heavy`) scale blur and alpha between light and dark themes. Cards
accept optional entry animations, hover effects, and a custom tint color
(which biases the dark-theme gradient toward a per-card hue, e.g. error-red
for warning summaries).

The default rounded corner is `lg` (16 px), default padding is
`glass-padding` (20 px), the default border is a 1 px `glass-shine`
white-alpha edge (light theme: 1 px `outline-variant` at 20%), and the
default shadow is `shadows.card-dark` (light theme: `shadows.card-light`).

### Buttons

Two parallel button systems coexist:

- **Material elevated button** (`button-primary`) — solid `#007BFF`, 50 px
  tall, full-width by default, 12 px corners, 16 px / 600 label. This is the
  workhorse for forms and confirmations.
- **Glassmorphism button** (`button-glass-*`) — translucent gradient fills
  with backdrop blur, 24 × 16 padding, optional pulse and ripple. Variants:
  - `primary` solid blue gradient on a 10 px blur,
  - `outline` transparent with a 2 px primary border on an 8 px blur,
  - `floating` higher-saturation gradient with a `cta-glow` shadow and a
    20 px blur — used for FABs and home-row primary actions.

### Inputs

Form fields fill with `surface-container` (slate-100 light / slate-800 dark),
wear a 12 px radius and a 1 px outline that swaps to a 2 px primary border
on focus and a 1 px error border on validation failure. Labels live above
fields at 14 px / 500. Amount inputs use a dedicated treatment (`amount-input`):
a leading currency symbol at 24 px / 700 muted, followed by an inline 24 px /
700 numeric value — the field reads as a unified "price tag" rather than a
generic text box.

### List Items

Transaction rows and selectable list items reuse the medium-glass card
treatment: 16 px radius, 16 px padding, 12 px bottom margin, 1 px white-alpha
border. They lay out as `[leading icon] · [title + subtitle] · [trailing
amount]` with a 16 px gutter on either side of the leading slot. Slide-in
entry animation is enabled by default; hover lift is enabled on desktop.

### Status & Information Chips

Chips and pills are pill-shaped (`pill`), padded `12 × 6`, and use 10–15%
alpha tinted fills with a matching saturated text color. The "Rollover
diario" info chip is the canonical example: primary-blue at 10% fill, 20%
border, primary-blue text at 12 px / 600, with a leading `event_repeat`
icon and a trailing `info_outline` cue.

### Progress Bar

Budget and goal progress is rendered as a 10 px-tall bar with a 5 px radius.
The track is `surface-container` (slate-800 dark / slate-200 light); the
fill is solid primary blue. No gradient or shimmer — clarity beats
decoration here.

### Snackbars

Snackbars appear as overlays at the top of the screen, 16 px from the safe
area, with a 12 px radius and a soft drop shadow. Each variant
(`snackbar-error / success / warning / info`) pairs a saturated icon hue
with a very soft tinted background and a matching 20%-alpha border. A
leading 32 px icon chip carries the icon at 10% alpha background, followed
by a 14 px / 500 message and a small dismiss `close` button.

### Empty States

Empty states center a 64 px outlined icon at 35% on-surface alpha, an 18 px /
700 title, a 14 px / 400 supporting line at 65% alpha, and an optional
primary action button — never glassmorphic, always solid Material primary,
to keep the call-to-action unambiguous.

### Bottom Sheets & Modals

Modal bottom sheets fill 60% of viewport height by default, top corners
rounded to 20 px, and start with a 40 × 4 px grabber handle at 30% alpha.
The title sits at 20 px / 700, content padding is 24 px, and the modal
background is the theme's solid `surface` color (not glass) so its contents
read clearly against the blurred page below.

### Skeletons

Loading states use a shimmer over solid 12 px-radius blocks filled with
`surface-container`. Dashboard, transaction list, and card skeletons mirror
their real components' layout 1:1 so the swap into real content is visually
silent.

### Logo

The brand mark is **three parallel waves** rendered at a 2.5 : 1 (width :
height) ratio. The default fill is the cyan-to-navy linear gradient
(`gradients.brand-wave`); a single-color rendering is permitted for
monochrome contexts (white on dark backgrounds, primary blue on light). When
paired with the wordmark, "MoneyFlow" is set in Inter Black (900) at 25% of
the icon's width with a tight `-0.5 px` letter-spacing.

The logo ships in four canonical sizes:
- **icon-only 32 px** for compact app bars,
- **small 32 px** with optional wordmark for nav contexts,
- **medium 64 px** with wordmark for modals and welcome cards,
- **large 120 px** with wordmark for splash and onboarding moments.
