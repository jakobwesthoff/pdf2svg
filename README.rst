=======
Pdf2Svg
=======

What is Pdf2Svg?
================

Pdf2Svg is a simple commandline utility to convert all pages of a PDF
(Portable Document Format) to a bunch of SVG (Scalable Vector Graphics) files.

Intentions
==========

This tool has been created as a fast hack to create usable data for a HTML5
based widget to display the slides of given talks directly in the my blog.

I have tried solutions involving different kinds of known vector editing tools
like inkscape pdf2ps and co. before. Unfortunately I had no luck creating
usable, good looking svgs out of arbitrary pdf slides. Therefore I quickly
hacked my own solution.

Used technologies / Requirements
================================

- Vala Compiler Version >=0.9.7
- CMake Version >=2.6
- Poppler with glib bindings
- Cairo >= 1.8.10

Usage
=====

Using the application is quite simple. If it is invoked only providing the PDF
source file it will generate a bunch of SVGs (one for each page) in the current
working directory::

    pdf2svg some_pdf_presentation.pdf

The output directory as well as characteristics of the outputted filenames can
be controlled using commandline options::

    pdf2svg Version DEVELOPMENT Copyright 2010 Jakob Westhoff
    Usage:
      pdf2svg [OPTION...] <pdf-file>
    
    Help Options:
      -h, --help                 Show help options
    
    Application Options:
      -o, --output=DIRECTORY     Directory used to store the created SVG files. (Default: Current working directory)
      -p, --prefix=PREFIX        Prefix used for the created SVG files. (Default: Input filename with the extension stripped)
      -d, --digits=N             Number of digits to use for page numbering. (Default: 3)




..
   Local Variables:
   mode: rst
   fill-column: 79
   End: 
   vim: et syn=rst tw=79
