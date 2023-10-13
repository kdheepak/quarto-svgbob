# quarto-svgbob

Render svgbob diagrams directly in your quarto documents. 

## Installing

```bash
quarto add kdheepak/quarto-svgbob
```

This will install the extension under the `_extensions` subdirectory. If you're using version
control, you will want to check in this directory.

## Usage

Here is how you add the filter to a page (it can also be added to a `_quarto.yml` project file with
the same syntax):

```markdown
---
title: "My Document"
filters:
  - quarto-svgbob
---
```

And then add the following markdown in your quarto file:

````markdown
```svgbob

       .---.
      /-o-/--
   .-/ / /->
  ( *  \/
   '-.  \
      \ /
       '
```
````

Make sure you have `svgbob` installed. `svgbob_cli` must be available in your PATH.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).
 
See this for HTML preview: https://kdheepak.com/quarto-svgbob/
