## Context

El UI de voicebox usa el patrón shadcn/ui con tokens HSL definidos en [`app/src/index.css`](../../../app/src/index.css). Hay dos themes hoy:

- `light` — bloque `:root { … }` (líneas 45-72).
- `dark` — bloque `.dark { … }` (líneas 74-100), aplicado vía clase en `<html>`.

El estado del theme vive en [`app/src/stores/uiStore.ts`](../../../app/src/stores/uiStore.ts) con tipo `Theme = 'light' | 'dark' | 'system'`, persistido en `localStorage` bajo `voicebox-ui`. La aplicación al DOM la hace [`useThemeSync.ts`](../../../app/src/hooks/useThemeSync.ts) togglando la clase `dark` en `<html>` con `matchMedia('(prefers-color-scheme: dark)')` cuando el valor es `system`.

El selector visible está en [`ThemeSelect.tsx`](../../../app/src/components/ServerTab/ThemeSelect.tsx) con tres `<SelectItem>` y los labels viven en `app/src/i18n/locales/{en,ja,zh-CN,zh-TW}/translation.json` bajo `settings.theme.options`.

La paleta target del theme `senordev` se extrajo del mockup de referencia personal del dueño, archivado en `media/Agiotech Studio _standalone_.html` (decodificado en `media/_template_decoded.html`). El nombre del archivo del mockup conserva su título original; en este cambio el theme se rebautiza `senordev` para mantenerlo como look personal del fork, sin asociarlo a ninguna marca. Variables CSS canónicas del mockup: `--primary: #00B6CC`, `--secondary: #091D41`, `--neutral: #F5F8FA`, `--text-muted: #5B6A86`, `--success: #0E9F6E`, `--warning: #D89B1E`, `--danger: #C8392B`.

## Goals / Non-Goals

**Goals:**
- Theme `senordev` accesible desde Settings como cuarta opción del selector.
- Mapeo coherente entre la paleta canónica del mockup y los tokens shadcn que el resto de la app ya consume — sin tocar componentes individuales.
- Persistencia y rehidratación funcionando igual que `light`/`dark` (mismo store, misma lógica `partialize`).
- Cambios contenidos en la lista enumerada por D-011, sin sangrar a otros archivos upstream.
- Reversibilidad: un solo `git revert` o eliminar el bloque `[data-theme="senordev"]` devuelve el fork al estado upstream.

**Non-Goals:**
- Variante `senordev-dark`. Solo modo claro en V1.
- Branding del producto: no se cambia logo, nombre del binario, ni copy de la app.
- Componentes nuevos: no se agregan badges del estilo "studio · runtime · workspace" del mockup; el alcance se queda en CSS tokens.
- Sidebar gradient (`#ECF2F6 → #E0E8EE`) del mockup. Shadcn usa color sólido en `--sidebar`; replicar el gradient requeriría tocar el componente Sidebar y eso queda fuera.
- Proponer el theme upstream. D-011 lo declara look personal del fork, no candidato a generalización.

## Decisions

### D-C1 — Cuarta opción coexistiendo, no reemplazo

**Decisión**: extender el union `Theme` a `'light' | 'dark' | 'system' | 'senordev'` y agregar un cuarto `<SelectItem>`. NO reemplazar `light`.

**Por qué**: respeta el contrato con el usuario que ya eligió `light` antes del cambio. Reversibilidad alta. El usuario decide explícitamente cuándo activar el theme del fork.

**Alternativa considerada**: theme único `senordev` que reemplaza `light`. Rechazada — implica decidir por el usuario qué look tiene su modo claro, y cualquier divergencia con upstream pasaría a ser involuntaria en lugar de opt-in.

### D-C2 — Tokens HSL, no hex literales

**Decisión**: traducir la paleta hex del mockup a tuplas HSL sin la wrapper `hsl()`, replicando exactamente el patrón de `:root` y `.dark` en [`index.css`](../../../app/src/index.css#L45). Ejemplo: `#00B6CC` → `186 100% 40%`.

**Por qué**: el `@theme` block (líneas 4-43) consume las variables como `hsl(var(--primary))`. Si se inyectan como hex, los componentes que componen colores con alpha (ej. `hsl(var(--accent) / 0.5)` en `.sidebar-logo`) se rompen. Mantener HSL preserva la composabilidad.

**Conversiones (calculadas a partir de los hex canónicos)**:

| Hex | HSL | Token shadcn |
|---|---|---|
| `#00B6CC` | `186 100% 40%` | `--primary`, `--ring` |
| `#E8F7F9` | `184 53% 94%` | `--accent` (no usado — ver Risks) |
| `#091D41` | `222 76% 15%` | `--foreground`, `--accent-foreground`, `--secondary-foreground` |
| `#FFFFFF` | `0 0% 100%` | `--background`, `--primary-foreground` |
| `#F5F8FA` | `204 23% 97%` | `--card`, `--popover`, `--muted` |
| `#E4ECF1` | `205 24% 92%` | `--border`, `--input`, `--secondary` |
| `#5B6A86` | `220 19% 44%` | `--muted-foreground` |
| `#0E9F6E` | `156 84% 34%` | `--chart-2` |
| `#D89B1E` | `40 76% 48%` | `--chart-4` |
| `#C8392B` | `5 65% 48%` | `--destructive` |
| `#ECF2F6` | `210 24% 95%` | `--sidebar` (color sólido — sin gradient en V1) |

**Token de radio**: el mockup usa cards más redondeados (`border-radius: 12px`) que el `--radius: 0.5rem` del light. Subir a `--radius: 0.625rem` para acercar el look sin romper la escala `--radius-sm/md/lg`.

### D-C3 — Resolución vía `dataset.theme` en `<html>`, no múltiples clases

**Decisión**: cambiar [`useThemeSync.ts`](../../../app/src/hooks/useThemeSync.ts) y `applyTheme` en [`uiStore.ts`](../../../app/src/stores/uiStore.ts#L12) para escribir el theme resuelto en `document.documentElement.dataset.theme` (`""` para light, `"dark"`, `"senordev"`) Y mantener la clase `dark` solo cuando aplica.

Selector CSS para el bloque nuevo: `[data-theme="senordev"] { … }`, paralelamente al `:root` actual y al `.dark` actual.

**Por qué**: tres themes mutuamente excluyentes con clases requiere asegurar que solo una esté activa al mismo tiempo (`classList.toggle('dark', …)` ya no basta). `dataset.theme` es naturalmente un valor único. Sostiene la clase `dark` en paralelo para no romper:
- `app/src/index.css:160` — selector `.dark .sidebar-logo` (glow del logo).
- Componentes con lógica condicional en `dark:` de tailwind (varias).

**Alternativa considerada**: solo togglear clases (`senordev` y `dark` mutuamente excluyentes). Rechazada — más invasiva, requiere `classList.remove('dark')` cuando se va a `senordev` y viceversa, y la clase `dark` está usada por shadcn dark mode en `tailwind.config`, así que perderla en `senordev` es lo correcto pero más quebradizo si se nos olvida re-añadirla al volver.

**Por escribir ambos**: `data-theme` para el selector del bloque CSS nuevo, clase `dark` para mantener compat con tailwind dark variant. Cuando el theme es `senordev`, la clase `dark` está ausente (porque `senordev` es modo claro).

### D-C4 — `system` ignora `senordev`

**Decisión**: `resolveTheme('system')` sigue devolviendo solo `'light'` o `'dark'`. Para activar `senordev` el usuario debe seleccionarlo explícitamente.

**Por qué**: `system` es un contrato con el OS — "seguir lo que tiene la máquina". Mapear `senordev` ahí violaría la expectativa. El theme del fork es opt-in, no automático.

**Implicación**: cuando el usuario selecciona `senordev`, esa elección se persiste y no la sobreescribe ningún cambio del OS. Si después selecciona `system`, vuelve al binario light/dark estándar.

### D-C5 — i18n en cuatro locales (no agregar `es` ahora)

**Decisión**: añadir la key `settings.theme.options.senordev` solo en los locales que ya existen: `en`, `ja`, `zh-CN`, `zh-TW`. NO crear locale `es` en este cambio.

**Por qué**: traducciones al español es una iniciativa separada del roadmap (Fase 2 — Tropicalización). Ese cambio toca docs + UI completos y debería ir en su propio openspec change. Mezclar agrega scope creep.

**Etiqueta canónica del label**: `"SenorDev"` literal en los cuatro locales. No se traduce — es nombre propio del theme personal del fork. CamelCase `SenorDev` (visible) y kebab `senordev` (identificador).

## Risks / Trade-offs

- **Conflictos de merge con upstream** → cubierto por workflow de fallback en `FORK_NOTES.md` § sync. Costo aceptado por D-011.
- **Componentes con colores hardcoded** → algunos componentes shadcn pueden tener `bg-blue-500` literal en lugar de `bg-primary`. Si los hay, el theme no se les aplica. Mitigación: durante validación visual (Fase E2 del plan), escanear cada tab y reportar componentes con colores fijos como tarea futura — no se arreglan en este cambio (sería scope creep y divergencia adicional fuera de D-011).
- **Loaders con `--accent` directo** → [`index.css:168`](../../../app/src/index.css#L168) hace `background-color: hsl(var(--accent)) !important` en `.line-scale > div`. Como `senordev` mapearía `--accent` a `184 53% 94%` (cyan muy claro), los loaders quedan casi invisibles sobre fondo claro. Mitigación aplicada: `--accent` se asigna a `186 100% 40%` (mismo que `--primary`) para que los loaders mantengan contraste, sacrificando la sutileza del tinte cyan en hover. Trade-off aceptado.
- **Glow del logo** (`.dark .sidebar-logo`) → solo se aplica en `dark`. En `senordev` no hay glow (queda igual que en light). Acceptable.
- **Persistencia de valor inválido** → si un usuario tiene `theme: 'senordev'` persistido y luego hace downgrade a una versión sin el theme, el store rehidrata un valor que el union no acepta. Mitigación: `normalizeTheme` en el store cae a `'system'` ante valores fuera del union. No requiere migración explícita.
- **Sin tests automáticos del theme system** → no hay tests visuales en el repo. La validación es manual (Fase E2). Trade-off aceptado: agregar tests visuales es trabajo separado.

## Migration Plan

No aplica — feature aditiva en cliente local. No hay datos a migrar, no hay deploy. Activación: el usuario abre Settings y selecciona `SenorDev` en el dropdown del theme.

**Rollback**: revertir el commit del cambio. Los usuarios que tenían `theme: 'senordev'` persistido caen al fallback `system` automáticamente al rehidratar contra el union sin `'senordev'`.

## Open Questions

1. ¿El theme `senordev` debe forzar la clase `dark` ausente, incluso si el usuario tenía `dark` antes? Sí — al cambiar a `senordev`, `useThemeSync` debe `classList.remove('dark')` y `dataset.theme = 'senordev'`. Cubierto en D-C3.
2. ¿Algún componente del mockup que sea capability nueva del UI (titlebar, sidebar gradient)? Excluidos por Non-Goals. Si emergen como necesidad, son cambios openspec separados.
3. ¿Renombrar también el archivo `media/Agiotech Studio _standalone_.html` para evitar la marca en el filename? Se decidió **no** en este alcance — el archivo es artefacto fuente histórico ya commiteado; renombrarlo agrega ruido de git por nada. El theme y todo lo público usan `senordev`.
