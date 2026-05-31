# gaaraujo.github.io

Personal academic website for **Gustavo A. Araújo R.**, built with [Quarto](https://quarto.org) and deployed to [GitHub Pages](https://pages.github.com/) from the `docs/` folder.

Live site: [https://gaaraujo.github.io](https://gaaraujo.github.io)

## Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) (1.4+) — install system-wide, not in conda
- PowerShell (used by the post-render script to create `docs/.nojekyll`)
- [Conda](https://docs.conda.io/) (optional) — only needed for runnable Python examples

## Python environment (optional)

Static pages do not require Python. Activate the conda env when you add executable `{python}` chunks to examples or posts (e.g. OpenSeesPy).

```powershell
conda env create -f environment.yml
conda activate gaaraujo-website
```

Update after changing `environment.yml`:

```powershell
conda env update -f environment.yml --prune
```

Quarto uses whichever Python is active in your shell when you render.

## Preview locally

```powershell
conda activate gaaraujo-website   # optional; skip for static pages
quarto preview
```

## Render for production

```powershell
quarto render
```

Output is written to `docs/`. The post-render script (`scripts/post-render.sh`) adds `docs/.nojekyll` for GitHub Pages. Requires `bash` (Git for Windows on local machines; preinstalled on Linux CI).

## Publish to GitHub Pages

1. Render the site: `quarto render`
2. Commit and push `docs/` along with source files
3. In the repository **Settings → Pages**, set:
   - **Source:** Deploy from a branch
   - **Branch:** `main` (or your default branch)
   - **Folder:** `/docs`

GitHub runs the built-in **pages build and deployment** workflow on each push. It serves the committed `docs/` folder and does **not** need the private Overleaf `cv-source/` checkout (the PDF in `assets/cv/cv.pdf` is committed instead).

## Site structure

| Path | Purpose |
|------|---------|
| `_quarto.yml` | Site configuration, navbar, footer |
| `index.qmd` | Home |
| `about.qmd`, `research.qmd`, `publications.qmd`, `cv.qmd`, `contact.qmd` | Main pages |
| `posts/` | Blog posts (auto-listed) |
| `examples/` | Code examples (auto-listed) |
| `projects/` | Research projects (auto-listed) |
| `talks/` | Presentations (auto-listed) |
| `assets/` | Images, CV PDF, static files |

## Adding content

Add new entries as `index.qmd` files inside the relevant listing folder:

- Posts: `posts/YYYY-MM-DD-short-slug/index.qmd`
- Examples: `examples/example-slug/index.qmd`
- Projects: `projects/project-slug/index.qmd`
- Talks: `talks/talk-slug/index.qmd`

After adding or editing content, run `quarto render` and commit both the source files and the updated `docs/` output.

If rendering fails on Windows with a locked `site_libs`, `*_files`, or `.quarto/project-cache` path, stop any running `quarto preview` or stale Quarto/Deno process and rerun `quarto render`.

## CV (Overleaf sync)

The CV PDF is **not** edited directly on the website. It is built from LaTeX source in a local `cv-source/` folder that clones your [Overleaf project](https://git.overleaf.com/6440339541540a8edd971bfa). That folder is gitignored and is not part of CI.

### First-time setup

```powershell
.\scripts\sync-cv.ps1
quarto render
```

`sync-cv.ps1` clones `cv-source/` from Overleaf on first run if it is missing.

Requires **Git** and a LaTeX install with `latexmk` (TeX Live or MiKTeX). Commit the rebuilt `assets/cv/cv.pdf` after syncing — GitHub Pages uses that file, not the Overleaf repo.

### Update workflow

1. Edit your CV in **Overleaf** (or commit and push from the `cv/` folder).
2. Sync and rebuild:

```powershell
.\scripts\sync-cv.ps1
quarto render
```

3. Commit `assets/cv/cv.pdf` and `docs/` changes, then push.

Use `.\scripts\sync-cv.ps1 -SkipPull` to rebuild from local `cv-source/` source without pulling from Overleaf.
