# PreTeXt Worksheet Demo

This is an example of how I have hacked PreTeXt to create stand-alone worksheets that can be compiled by LaTeX.  To add this feature to your project, do the following:

1. In `project.ptx`, add a target for "worksheets",

```xml
    <target name="worksheets" format="custom" xsl="pretext-latex-extras.xsl"/>
```

2. Copy the `xsl` folder from this repository to your project.  This folder contains the `pretext-latex-extras.xsl` file that is needed to create the worksheets.

3. In `docinfo.ptx`, add two commands inside the `<macros>` element: `\def\thecourse{MATH 101}` and `\def\theterm{Fall 2024}`, changing them to match your course and term.

Now to create .tex files for all the worksheets in your book, simply run `pretext build worksheets`.  The resulting files will be put in `output/worksheets/`.  (This can be changed by adding `output-dir="activities"` as an attribute on the `worksheets` target in `project.ptx`.)