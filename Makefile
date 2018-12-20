FILENAME=project

.PHONY: watch

${FILENAME}.pdf: ${FILENAME}.md ${FILENAME}.bib
	pandoc -f markdown+tex_math_single_backslash $< --bibliography=${FILENAME}.bib -s -o $@

watch: ${FILENAME}.md ${FILENAME}.bib
	ls $^ | entr make
