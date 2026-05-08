## ADDED Requirements

### Requirement: Catálogo de themes disponibles

El sistema SHALL ofrecer al usuario cuatro valores válidos para el theme del UI: `system`, `light`, `dark`, y `senordev`. Cualquier otro valor SHALL ser tratado como inválido y normalizado al default `system` durante la rehidratación del store.

#### Scenario: Selector expone las cuatro opciones

- **WHEN** el usuario abre la pestaña Settings → General y despliega el control de Theme
- **THEN** el control muestra exactamente cuatro opciones, en este orden: `System`, `Light`, `Dark`, `SenorDev`
- **AND** cada opción tiene un label localizado en `en`, `ja`, `zh-CN` y `zh-TW`

#### Scenario: Valor persistido inválido cae a default

- **WHEN** el store rehidrata un valor `theme` que no pertenece al union (ej. `"banana"`, o un legacy que ya no existe)
- **THEN** el sistema aplica `system` y NO emite error visible al usuario

### Requirement: Resolución del theme `system`

Cuando el theme seleccionado es `system`, el sistema SHALL resolver el theme efectivo a `light` o `dark` según `prefers-color-scheme` del OS, y SHALL reaccionar a cambios de esa media query mientras la app está abierta. El sistema NO SHALL resolver `system` a `senordev` bajo ninguna circunstancia.

#### Scenario: OS en modo claro

- **WHEN** el theme persistido es `system` y `window.matchMedia('(prefers-color-scheme: dark)').matches` es `false`
- **THEN** el theme efectivo aplicado al DOM es `light`

#### Scenario: OS en modo oscuro

- **WHEN** el theme persistido es `system` y `window.matchMedia('(prefers-color-scheme: dark)').matches` es `true`
- **THEN** el theme efectivo aplicado al DOM es `dark`

#### Scenario: OS cambia mientras la app está abierta

- **WHEN** el theme persistido es `system` y el usuario alterna el modo claro/oscuro del OS
- **THEN** el DOM refleja el cambio sin requerir reload

### Requirement: Aplicación del theme al DOM

El sistema SHALL aplicar el theme efectivo al elemento `<html>` mediante dos mecanismos coordinados: el atributo `data-theme` (con valor `""`, `"dark"`, o `"senordev"`) y la clase `dark` (presente solo cuando el theme efectivo es exactamente `dark`). En cualquier momento, el atributo y la clase SHALL ser consistentes entre sí.

#### Scenario: Theme efectivo light

- **WHEN** el theme efectivo es `light`
- **THEN** `<html>` NO tiene clase `dark`
- **AND** `<html>.dataset.theme` es ausente o cadena vacía

#### Scenario: Theme efectivo dark

- **WHEN** el theme efectivo es `dark`
- **THEN** `<html>` tiene clase `dark`
- **AND** `<html>.dataset.theme === "dark"`

#### Scenario: Theme efectivo senordev

- **WHEN** el theme efectivo es `senordev`
- **THEN** `<html>` NO tiene clase `dark`
- **AND** `<html>.dataset.theme === "senordev"`

### Requirement: Persistencia del theme

El sistema SHALL persistir el valor seleccionado por el usuario en `localStorage` bajo la key `voicebox-ui` y SHALL rehidratar ese valor en el siguiente arranque, aplicándolo al DOM antes del primer render visible cuando sea posible.

#### Scenario: Selección persiste entre sesiones

- **WHEN** el usuario selecciona `senordev` en Settings y reinicia la app
- **THEN** al abrir de nuevo, el theme efectivo es `senordev`
- **AND** el selector muestra `SenorDev` como opción activa

#### Scenario: System sigue siendo default para usuarios nuevos

- **WHEN** un usuario abre la app por primera vez (sin valor persistido)
- **THEN** el theme efectivo es `system` resuelto contra el OS

### Requirement: Tokens CSS del theme `senordev`

Cuando el theme efectivo es `senordev`, el sistema SHALL exponer las variables CSS de shadcn (`--background`, `--foreground`, `--card`, `--primary`, `--accent`, `--muted-foreground`, `--border`, `--ring`, `--destructive`, `--sidebar`, etc.) con valores HSL que reflejan la paleta canónica del mockup `media/Agiotech Studio _standalone_.html` (artefacto fuente, conserva su nombre original). Los valores SHALL ir definidos en un único bloque CSS seleccionado por `[data-theme="senordev"]`.

#### Scenario: Tokens primario y fondo coinciden con el mockup

- **WHEN** el theme efectivo es `senordev`
- **THEN** `getComputedStyle(document.documentElement).getPropertyValue('--primary')` resuelve a `186 100% 40%` (equivalente a `#00B6CC`)
- **AND** `--background` resuelve a `0 0% 100%`
- **AND** `--foreground` resuelve a `222 76% 15%` (equivalente a `#091D41`)

#### Scenario: Tokens shadcn restantes están todos definidos

- **WHEN** el theme efectivo es `senordev`
- **THEN** todas las variables consumidas por el bloque `@theme` de `app/src/index.css` (`--card`, `--card-foreground`, `--popover`, `--popover-foreground`, `--secondary`, `--muted`, `--accent`, `--accent-foreground`, `--destructive`, `--border`, `--input`, `--ring`, `--sidebar`, `--radius`, `--chart-1` a `--chart-5`) están definidas en el bloque `[data-theme="senordev"]`
- **AND** ningún componente del UI hereda variables del bloque `:root` light de forma involuntaria

### Requirement: Themes existentes preservados

Los themes `light` y `dark` SHALL seguir comportándose exactamente como antes del cambio. Los selectores CSS `:root` y `.dark` en `app/src/index.css` SHALL permanecer sin modificación de tokens.

#### Scenario: Theme light idéntico al estado pre-cambio

- **WHEN** el usuario tenía `theme: 'light'` antes del cambio y abre la app después
- **THEN** la apariencia es bit-exacta a la versión anterior (mismos hex, mismo radius, mismo border)

#### Scenario: Theme dark idéntico al estado pre-cambio

- **WHEN** el usuario tenía `theme: 'dark'` antes del cambio y abre la app después
- **THEN** la apariencia es bit-exacta a la versión anterior

### Requirement: i18n del label `senordev`

El sistema SHALL exponer el label visible del theme `senordev` mediante la clave `settings.theme.options.senordev` en los locales `en`, `ja`, `zh-CN`, y `zh-TW`. El valor del label SHALL ser `"SenorDev"` en los cuatro locales (no se traduce — es nombre propio).

#### Scenario: Label presente en cada locale

- **WHEN** se carga cualquiera de los locales soportados
- **THEN** `t('settings.theme.options.senordev')` retorna la cadena `"SenorDev"`
- **AND** no aparece la clave cruda (sin traducir) en el UI
