## 1. Baseline antes de tocar archivos upstream

- [x] 1.1 Ejecutar `git diff upstream/main --name-only` y confirmar que la salida coincide con la lista declarada en `FORK_NOTES.md` § Divergencias visibles. Guardar el output como baseline previa al cambio.
- [ ] 1.2 Verificar que `bun install` corre limpio desde la raíz (Fase 1 del roadmap del fork — pendiente). Si falla por algo no relacionado al theme, parar y reportar.
- [ ] 1.3 Snapshot visual del estado pre-cambio: capturar `light` y `dark` desde `bun run dev` para diff visual posterior. Guardar en `media/screenshots/baseline/`.

## 2. Tokens CSS del theme `senordev`

- [x] 2.1 En `app/src/index.css`, agregar el bloque `[data-theme="senordev"] { … }` después del bloque `.dark { … }` (línea ~100). Usar exclusivamente HSL sin wrapper `hsl()`, replicando el patrón del bloque `:root`.
- [x] 2.2 Definir las variables shadcn según la tabla de mapeo de `design.md` § D-C2: `--background`, `--foreground`, `--card`, `--card-foreground`, `--popover`, `--popover-foreground`, `--primary`, `--primary-foreground`, `--secondary`, `--secondary-foreground`, `--muted`, `--muted-foreground`, `--accent`, `--accent-foreground`, `--destructive`, `--destructive-foreground`, `--border`, `--input`, `--ring`, `--sidebar`, `--radius`, `--chart-1` a `--chart-5`.
- [x] 2.3 Asignar `--accent: 186 100% 40%` (igual que `--primary`) para no romper los loaders del bloque `.line-scale > div` en `index.css:168` que dependen de `--accent` para visibilidad — riesgo documentado en `design.md` § Risks.
- [x] 2.4 Subir `--radius` a `0.625rem` dentro del bloque `senordev` para acercar el feel del mockup sin romper la escala derivada (`--radius-sm/md/lg`).

## 3. Extender el modelo de theme en el store

- [x] 3.1 En `app/src/stores/uiStore.ts`, ampliar `export type Theme = 'light' | 'dark' | 'system' | 'senordev'`.
- [x] 3.2 Modificar `function applyTheme(theme: Theme)` para que (a) escriba `document.documentElement.dataset.theme = resolved === 'light' ? '' : resolved`, y (b) agregue/quite la clase `dark` solo cuando `resolved === 'dark'`.
- [x] 3.3 Verificar que `resolveTheme('system')` sigue devolviendo solo `'light'` o `'dark'` — NO debe devolver `'senordev'` jamás (D-C4).
- [x] 3.4 Confirmar que `partialize` y `onRehydrateStorage` no requieren cambio adicional — el union extendido es backward-compatible para valores `'light'`/`'dark'`/`'system'` ya persistidos.
- [x] 3.5 Endurecer la rehidratación: si el valor leído de localStorage no pertenece al nuevo union, normalizar a `'system'` antes de `applyTheme` (Spec § "Valor persistido inválido cae a default").

## 4. Sincronizador del theme

- [x] 4.1 En `app/src/hooks/useThemeSync.ts`, reescribir el `useEffect` para manejar 4 estados. La lógica debe (a) resolver el theme efectivo, (b) limpiar `dataset.theme` y `classList` antes de aplicar, (c) escribir ambos atributos según D-C3. Implementación delgada: importa `applyTheme` desde el store y delega.
- [x] 4.2 El listener de `matchMedia('(prefers-color-scheme: dark)')` SOLO se registra cuando el theme es `'system'` — para `'senordev'` nunca debe escuchar al OS.
- [x] 4.3 Verificar que el cleanup del effect remueve el listener correctamente al cambiar de `system` a cualquier otro valor.

## 5. UI del selector

- [x] 5.1 En `app/src/components/ServerTab/ThemeSelect.tsx`, agregar un cuarto `<SelectItem value="senordev">{t('settings.theme.options.senordev')}</SelectItem>` después del item `dark`.
- [x] 5.2 Confirmar que el orden visual queda: System, Light, Dark, SenorDev — coincide con el orden declarado en el spec.

## 6. i18n

- [x] 6.1 Editar `app/src/i18n/locales/en/translation.json` y agregar `"senordev": "SenorDev"` dentro de `settings.theme.options` (después de `"dark"`).
- [x] 6.2 Mismo cambio en `app/src/i18n/locales/ja/translation.json`.
- [x] 6.3 Mismo cambio en `app/src/i18n/locales/zh-CN/translation.json`.
- [x] 6.4 Mismo cambio en `app/src/i18n/locales/zh-TW/translation.json`.
- [x] 6.5 Validar JSON formal en cada archivo (parse Python explícito ejecutado, los 4 archivos parsean limpio; `bun run lint` queda como pre-commit del usuario una vez instale node_modules).

## 7. Validación

- [ ] 7.1 `bun run lint` — debe pasar sin warnings en los archivos tocados.
- [ ] 7.2 `bun run dev` — abrir la app, navegar a Settings → seleccionar `SenorDev` → verificar que el theme se aplica.
- [ ] 7.3 QA visual por tab: Profiles, Voices, Generation, Server, Settings — capturar screenshot de cada uno con el theme `senordev` activo. Guardar en `media/screenshots/senordev-theme/`.
- [ ] 7.4 QA de regresión: alternar a `Light` y luego a `Dark` y verificar que ambos siguen idénticos al snapshot baseline (1.3).
- [ ] 7.5 QA de persistencia: con `senordev` seleccionado, cerrar y reabrir la app — debe quedar en `senordev`.
- [ ] 7.6 QA de `system`: con `system` seleccionado, alternar el OS entre claro/oscuro — la app debe seguir light/dark, NO `senordev`.
- [ ] 7.7 Documentar en `FORK_NOTES.md` cualquier componente con colores hardcoded que no responda al theme (no se arreglan en este cambio — son scope creep).

## 8. Cierre del cambio openspec

- [ ] 8.1 `openspec validate add-senordev-theme` — debe pasar.
- [ ] 8.2 Confirmar que `git diff upstream/main --name-only` ahora lista exactamente los archivos declarados en `proposal.md` § Impact + los archivos del fork (FORK_NOTES.md, openspec/, .claude/, media/, project_docs/).
- [ ] 8.3 Commit en branch `feat_CarlosB_theme` (ya autorizado por D-011) y merge a `main` cuando QA visual quede verde.
- [ ] 8.4 `openspec archive add-senordev-theme --skip-specs` (las specs ya viven en `openspec/specs/ui-theme/spec.md` tras el archive — confirmar comportamiento del CLI antes de elegir flag).
- [ ] 8.5 Actualizar `FORK_NOTES.md` con el commit hash final del merge a `main` y un screenshot del theme aplicado.
