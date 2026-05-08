## Why

Cuando el dueño abre la app no tiene una señal visual rápida de que está corriendo el build de su fork (`CarlosBarreto/voicebox`) y no el binario upstream (`jamiepine/voicebox`). Eso confunde al iterar sobre la app: cualquier diferencia se atribuye al cambio del momento en lugar de "estoy en mi fork". Un theme propio, personal, opt-in, resuelve la ambigüedad sin tocar la experiencia de los usuarios upstream y sin convertir el fork en un re-skin productivo.

## What Changes

- Agregar un theme nuevo `senordev` como **cuarta opción** del selector de Settings, coexistiendo con `system` / `light` / `dark`. El nombre es deliberadamente personal (no asociado a ninguna marca) para que el theme se entienda como "el look del fork de Carlos", no como branding de un producto.
- Extender el union `Theme` en el store de UI para incluir `'senordev'` como valor válido.
- Adaptar la lógica de aplicación del theme: en lugar de togglear únicamente la clase `dark` en `<html>`, manejar tres estados mutuamente excluyentes (`""` para light, `"dark"`, `"senordev"`) vía `data-theme`.
- Definir el bloque CSS `[data-theme="senordev"] { … }` con la paleta extraída del mockup de referencia `media/Agiotech Studio _standalone_.html` (los tokens HSL se mapean a las variables shadcn existentes; el archivo del mockup conserva su nombre original como artefacto de origen).
- Añadir la key `settings.theme.options.senordev` en los locales `en`, `ja`, `zh-CN`, `zh-TW` con label `"SenorDev"` literal en los cuatro.
- **No-cambio**: el theme `system` sigue resolviendo a `light`/`dark` según OS — nunca a `senordev`. Para activar `senordev` el usuario lo elige explícitamente.
- **No-cambio (V1)**: solo modo claro. No se entrega variante `senordev-dark` en este alcance; queda como cambio futuro si emerge necesidad.

## Capabilities

### New Capabilities

- `ui-theme`: sistema de themes del UI de la app desktop. Cubre el catálogo de themes disponibles, su persistencia, la resolución de `system`, y cómo se aplican al DOM. Antes de este cambio el comportamiento existía pero no estaba especificado; este cambio lo formaliza al mismo tiempo que agrega `senordev`.

### Modified Capabilities

(ninguna — no hay specs previos en `openspec/specs/` porque el repo recién inicializó openspec)

## Impact

- **Archivos upstream modificados** (autorizado por D-011 en `project_docs/decisions.md`):
  - `app/src/index.css` — bloque `[data-theme="senordev"]` nuevo con tokens HSL.
  - `app/src/stores/uiStore.ts` — union `Theme` y función `applyTheme`.
  - `app/src/hooks/useThemeSync.ts` — resolución para 4 estados.
  - `app/src/components/ServerTab/ThemeSelect.tsx` — `<SelectItem value="senordev">`.
  - `app/src/i18n/locales/{en,ja,zh-CN,zh-TW}/translation.json` — key `settings.theme.options.senordev`.
- **Archivos del fork**:
  - `FORK_NOTES.md` § Divergencias visibles lista la entrada del theme.
  - `project_docs/decisions.md` D-011 documenta la decisión.
- **Sin impacto** en: backend Python, sidecar TTS, MCP server, modelos, schema de Tauri, build/release.
- **Sync upstream**: a partir de este cambio, `git merge --ff-only upstream/main` puede fallar en conflictos sobre los archivos enumerados. Workflow de fallback documentado en `FORK_NOTES.md`.
- **Riesgo de regresión**: bajo. El theme es aditivo y opt-in; los tests existentes (si los hay) no deberían pegarle. Validación visual cubre `light` y `dark` siguen idénticos.
- **Reversibilidad**: alta. Eliminar el bloque `[data-theme="senordev"]`, la 4ta opción del selector, y el valor del union devuelve el fork al estado upstream sin tocar otro código.
