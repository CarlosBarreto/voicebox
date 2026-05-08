# FORK_NOTES — voicebox

> Este archivo documenta la postura, el workflow y las decisiones operativas de este fork.
> Vive en el fork (`CarlosBarreto/voicebox`) y NO existe en el upstream (`jamiepine/voicebox`).
> Si llegas aquí desde una clonación: este es un fork sincronizado, no un re-write.

---

## Identificación

- **Fork**: https://github.com/CarlosBarreto/voicebox.git
- **Upstream**: https://github.com/jamiepine/voicebox.git
- **Owner del fork**: Carlos Barreto (Agiotech)
- **Idioma de trabajo del fork**: español mexicano (docs/notas del fork). El producto sigue siendo en inglés.

---

## Postura del fork

Fork **sincronizado con divergencia acotada y enumerable**. Definición operativa:

- Seguimos `upstream/main` con `git fetch upstream` periódico.
- Hay un único punto de divergencia autorizado en `main`: el theme `senordev` (ver § Divergencias visibles).
- Fuera de esa lista enumerada, la divergencia sigue siendo cero. El trabajo "del fork" vive en archivos que **no existen en upstream** (este `FORK_NOTES.md`, traducciones futuras en carpetas nuevas, openspec/, etc.).
- Cualquier ampliación de la divergencia requiere una D-NNN nueva en `project_docs/decisions.md` con justificación.

Espejo conceptual: postura **un grado más divergente** que `CarlosBarreto/OpenSpec` (que sigue en divergencia cero).

---

## ¿Por qué existe este fork?

Tres razones, en orden:

1. **Aprender** voicebox a fondo: stack (Bun+Tauri+FastAPI), engines TTS, flujo MCP.
2. **Tropicalizar** la documentación al español (futuro: `docs/content/docs/es/`) — candidato natural a PR upstream cuando esté maduro.
3. **Evaluar integración** con el ecosistema agéntico de Agiotech (Mictlán) como motor de voz, vía el MCP server expuesto por voicebox. La decisión de caso de uso primario está pendiente.

No buscamos:
- ❌ Hacer un re-skin productivo del fork (más allá del theme `senordev` autorizado por D-011, que es look personal opt-in y no rediseño del producto).
- ❌ Hostear voicebox como servicio cloud (viola la promesa local-first del producto).
- ❌ Renombrar el binario, publicar a npm, ni cambiar `package.json` core.

---

## Qué pertenece al fork vs qué pertenece al Mictlán

El owner del fork mantiene un **Sistema Maestro Agéntico (SMP)** local en `project_docs/`. Ese folder NO se commitea al fork público.

| Recurso | Vive en | ¿Se commitea al fork? |
|---|---|---|
| Código upstream (`app/`, `backend/`, `tauri/`, `web/`, `landing/`, `docs/`) | repo | sí (via sync con upstream) |
| `FORK_NOTES.md` (este archivo) | repo raíz | **sí** |
| Traducciones futuras | carpeta nueva (TBD) | sí (candidato a PR upstream) |
| `project_docs/` (SMP del Mictlán) | repo raíz | **no** (excluido vía `.git/info/exclude`) |
| `PROJECT.md` (ficha canónica del Mictlán) | repo raíz | **no** (excluido vía `.git/info/exclude`) |
| `data/` (modelos, voces, capturas) | repo raíz | **no** (gitignored upstream + privacidad) |
| Tokens HuggingFace, credenciales | en ningún lado del repo | **nunca** |

Si trabajas en este fork y te descubres modificando archivos upstream para personalizarlos más allá de la lista enumerada por D-011, para y revisa `project_docs/boundaries.md`. Probablemente lo correcto sea (a) abrir un PR upstream o (b) abrir un proyecto separado.

---

## Workflow de sincronización con upstream

Sync periódico (sugerido: semanal). Comandos:

```bash
# Desde la raíz del fork
git fetch upstream
git checkout main
git merge --ff-only upstream/main   # intenta fast-forward primero
git push origin main
```

**Si el `--ff-only` falla**, no es necesariamente alarma — desde D-011 (2026-05-08) hay divergencia esperable en los archivos del theme `senordev`. Verificar primero que el conflicto sea solo en esa lista enumerada:

```bash
git merge upstream/main                          # merge normal, deja conflictos
git diff --name-only --diff-filter=U             # archivos en conflicto
```

Si **todos** los archivos en conflicto están en la lista de D-011 (`app/src/index.css`, `app/src/stores/uiStore.ts`, `app/src/hooks/useThemeSync.ts`, `app/src/components/ServerTab/ThemeSelect.tsx`, `app/src/i18n/locales/*/translation.json`), resolver manualmente preservando el bloque `[data-theme="senordev"]` y la 4ta opción del theme. Si aparece **cualquier otro archivo en conflicto**, parar y revisar qué se introdujo fuera del scope autorizado por D-011.

Si el merge no es fast-forward y los conflictos están **fuera** de la lista de D-011, **algo divergió de forma no autorizada** y hay que entender qué pasó antes de continuar:

```bash
git log --oneline main..upstream/main      # commits nuevos en upstream
git log --oneline upstream/main..main      # commits propios en main (no debería haber)
```

Si hay commits propios en `main` no autorizados por D-001, considerar moverlos a una branch nueva antes de re-alinear con upstream:

```bash
git branch local-changes
git reset --hard upstream/main
git push origin main --force-with-lease    # ⚠️ confirmar antes
```

> **Nota**: `--force-with-lease` solo si nadie más colabora en el fork. Hoy somos un solo owner; cuando deje de serlo, revisar este workflow.

---

## Decisiones operativas (resumen)

Detalle completo en `project_docs/decisions.md` (local). Resumen para colaboradores que clonen el fork:

| ID | Decisión |
|---|---|
| D-001 | Fork sincronizado, divergencia mínima. |
| D-002 | SMP del Mictlán vive en `project_docs/`, NO en `docs/`. |
| D-003 | Bun como package manager (heredado de upstream). No introducir npm/pnpm/yarn. |
| D-004 | Biome como única herramienta de lint/format. No introducir ESLint/Prettier. |
| D-005 | Sidecar Python en puerto **17493** (fijo). |
| D-006 | No publicar a npm/registry. No renombrar el binario. |
| D-007 | Modelos HuggingFace gated: documentar setup, NO commitear tokens. |
| D-008 | `data/` ignorado y NO sincronizado a backups externos. |
| D-009 | `project_docs/` y `PROJECT.md` excluidos localmente vía `.git/info/exclude` (no `.gitignore`, que se commitearía). |
| D-010 | El MCP server local es la interfaz canónica de integración con otros proyectos. Cliente sí, copia no. |
| D-011 | Divergencia productiva mínima vía theme `senordev` (lista enumerada de archivos). Acota D-001 sin reemplazarla. |

---

## Divergencias visibles

Lista canónica y enumerable de archivos upstream que el fork modifica. Esta lista es la métrica operativa de D-001 + D-011: si un archivo upstream está modificado y **no aparece aquí**, hay un problema (ya sea un cambio no autorizado o falta de documentación).

| # | Cambio | Archivos tocados | Decisión origen | Fecha | PR upstream |
|---|---|---|---|---|---|
| 1 | Theme `senordev` (4ta opción del selector — look personal del fork) | `app/src/index.css`, `app/src/stores/uiStore.ts`, `app/src/hooks/useThemeSync.ts`, `app/src/components/ServerTab/ThemeSelect.tsx`, `app/src/i18n/locales/{en,ja,zh-CN,zh-TW}/translation.json` | D-011 | 2026-05-08 | No (look personal del fork, no se generaliza) |

Comando útil para auditar divergencia real vs declarada:

```bash
git fetch upstream
git diff upstream/main --name-only
# todos los archivos que aparezcan deberían estar en la tabla de arriba
# o ser archivos que no existen en upstream (FORK_NOTES.md, openspec/, etc.)
```

Archivos que **no existen en upstream** y por tanto no requieren listarse aquí: `FORK_NOTES.md`, `openspec/` (specs y propuestas openspec), `.claude/` (slash commands + skills generados por `openspec init --tools claude`), `dev-fork.ps1` y `dev-fork.sh` (helpers de setup `bun install` + `bun run dev` para arrancar el fork en una máquina nueva), traducciones futuras en carpetas nuevas.

---

## Cómo proponer cambios upstream

Cualquier cambio que toque archivos compartidos debería plantearse como PR a `jamiepine/voicebox`:

```bash
git checkout -b fix/algo-pequeno upstream/main
# ... editar ...
git push origin fix/algo-pequeno
gh pr create --repo jamiepine/voicebox --base main --head CarlosBarreto:fix/algo-pequeno
```

Candidatos típicos:
- Docs en español (cuando la traducción esté lista).
- Fixes específicos de Windows (build, paths, drivers).
- Ejemplos de uso del MCP server con clientes específicos (Claude Code, Cursor, Cline).

Lo que NO se propone upstream:
- Cambios de UX o look personales del fork (ej. theme `senordev`) que no se generalicen.
- Telemetría o logs adicionales solo útiles para el owner.

---

## Disclaimers

- **Marca**: voicebox es marca de Jamie Pine / contribuidores upstream. Este fork no la reclama.
- **Soporte**: este fork no ofrece soporte. Para issues del producto, abrir issue en upstream.
- **Cloud**: voicebox es local-first por diseño. Hostearlo en un servidor compartido viola el contrato del producto y rompe la promesa de privacidad. Si necesitas un servicio cloud, ese sería un proyecto distinto, no este fork.
- **Privacidad**: las muestras de voz, modelos descargados, y outputs en `data/` permanecen locales. No se sincronizan a ningún backup externo.

---

## Mantenimiento

- **Owner**: Carlos Barreto.
- **Revisión de continuidad**: ~30 días después del clone (≈ 2026-06-07). Posibles salidas: mantener fork activo / convertir a mirror pasivo / archivar.
- **Sync rate objetivo**: semanal.

---

_Última actualización: 2026-05-08 (Fase A→D del theme `senordev` — D-011, openspec change `add-senordev-theme`, e implementación en archivos enumerados)._
