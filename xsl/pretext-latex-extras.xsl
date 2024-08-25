<?xml version='1.0'?><!-- As XML file -->

<!--********************************************************************
Copyright 2013 Robert A. Beezer, 2018 Oscar Levin

This file is part of MathBook XML.

MathBook XML is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 or version 3 of the
License (at your option).

MathBook XML is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MathBook XML.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************-->

<!-- http://pimpmyxslt.com/articles/entity-tricks-part2/ -->
<!DOCTYPE xsl:stylesheet [
    <!ENTITY % entities SYSTEM "entities.ent">
    %entities;
]>

<!-- Identify as a stylesheet -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
  xmlns:xml="http://www.w3.org/XML/1998/namespace" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns:date="http://exslt.org/dates-and-times" 
  xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl date str">

  <!-- Build off of standard latex xsl: -->
  <xsl:import href="./core/pretext-latex.xsl" />

  <!-- Intend output for rendering by pdflatex -->
  <xsl:output method="text" />


  <!-- Parameters to pass via xsltproc "stringparam" on command-line            -->
  <!-- Or make a thin customization layer and use 'select' to provide overrides -->
  <!-- Produce all content (or select individually below): -->
  <xsl:param name="everything" select="'no'"/>

  <!-- Individual extras: -->
  <!-- Produce activities: -->
  <xsl:param name="activities" select="'no'"/>
  <!-- Produce stand-alone worksheets: -->
  <xsl:param name="worksheets" select="'yes'"/>
  <!-- Produce (the start of) lecture notes: -->
  <xsl:param name="notes" select="'no'"/>
  <!-- Others to be added as needed -->

  <!-- TODO: add options to limit what content gets included (perhaps per format) -->

  <!-- TODO: Allow choices of chunk size (currently chunk at section for most things, but at activity for activities).  Might not be necessary.  I could always chunk and include using docmute -->


  <!-- This is where I need to split up files based on chunk level -->
  <!-- Also, probably change file names based on content? -->
  <xsl:template match="/">
    <!-- Generate includable preambles as needed -->
    <xsl:if test="$everything='yes' or $activities='yes'">
      <xsl:call-template name="activities-preamble-file"/>
      <xsl:call-template name="activities-main-file" />
    </xsl:if>
    <xsl:if test="$everything='yes' or $worksheets='yes'">
      <xsl:call-template name="worksheets-preamble-file"/>
      <xsl:call-template name="worksheets-main-file" />
    </xsl:if>
    <xsl:if test="$everything='yes' or $notes='yes'">
      <xsl:call-template name="notes-preamble-file"/>
      <xsl:call-template name="notes-main-file" />
    </xsl:if>
  </xsl:template>

  <!-- Default behavior is to skip all elements unless defined below. -->
  <xsl:template match="*" mode="activities">
    <xsl:apply-templates select="*" mode="activities" />
  </xsl:template>
  <xsl:template match="*" mode="worksheets">
    <xsl:apply-templates select="*" mode="worksheets" />
  </xsl:template>
  <xsl:template match="*" mode="notes">
    <xsl:apply-templates select="*" mode="notes" />
  </xsl:template>



  <xsl:template match="worksheet" mode="worksheets">
    <xsl:variable name="filename">
        <xsl:call-template name="ws-id"/>
      <text>.tex</text>
    </xsl:variable>
    <xsl:text>\input{</xsl:text>
    <xsl:value-of select="$filename" />
    <xsl:text>}&#xa;&#xa;</xsl:text>
    <!-- <xsl:text>\subsection*{</xsl:text>
  <xsl:apply-templates select="." mode="long-name" />
  <xsl:text>}&#xa;</xsl:text>
  <xsl:apply-templates select="*" mode="slides"/> -->
    <xsl:call-template name="worksheets-subfiles"/>
    <!-- <xsl:call-template name="start-activity" />
  <xsl:apply-templates select="."/>
  <xsl:call-template name="end-activity" /> -->
  </xsl:template>


  <!-- Produce nice filenames: -->
  <xsl:template name="type-and-number">
    <xsl:variable name="filename">
      <xsl:apply-templates select="." mode="type-name" />
      <xsl:text>_</xsl:text>
      <xsl:apply-templates select="." mode="number" />
    </xsl:variable>
    <xsl:value-of select="translate(translate($filename, '!', ''), '.', '-')"/>
  </xsl:template>

  <xsl:template name="ws-id">
    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="@xml:id">
          <xsl:value-of select="@xml:id" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>ws_</xsl:text>
          <xsl:apply-templates select="." mode="title-simple"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="translate(translate(translate($filename, '!', ''), '.', '-'), ' ', '-')"/>
  </xsl:template>





  <xsl:template match="solution">
  </xsl:template>



  <!-- Start and end of activities -->
  <!-- These will eventually get more, including comments -->
  <!--   which include section numbers to easily identify them -->
  <xsl:template name="start-activity">
    <!-- <xsl:text>\begin{frame}[allowframebreaks, plain]&#xa; &#xa;</xsl:text> -->
    <!-- <xsl:variable name="cptj-value">
      <xsl:apply-templates select="." mode="number"/>
    </xsl:variable> -->
    <xsl:text>\setcounter{cpjt}{</xsl:text>
    <xsl:apply-templates select="." mode="serial-number"/>
    <xsl:text>}&#xa;\addtocounter{cpjt}{-1}&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="end-activity">
    <!-- <xsl:text>\end{frame}&#xa; &#xa;</xsl:text> -->
    <xsl:text>&#xa;\clearpage</xsl:text>

  </xsl:template>


  <xsl:template name="start-worksheet" />
  <xsl:template name="end-worksheet" />



  <!-- ########################################### -->
  <!-- Templates to generate files:                -->
  <!-- ########################################### -->

  <!-- To generate single file which includes everything: -->
  <xsl:template name="activities-main-file">
    <exsl:document href="activities.tex" method="text">
      <xsl:text>\documentclass{book}&#xa;&#xa;</xsl:text>
      <xsl:text>\input{activities-preamble.tex}&#xa;</xsl:text>
      <!-- <xsl:text>% Include a file allowing course customizations &#xa;</xsl:text> -->
      <!-- <xsl:text>\@input{../customize.tex}&#xa;</xsl:text> -->
      <xsl:text>\begin{document}&#xa;&#xa;</xsl:text>
      <xsl:apply-templates select="*" mode="activities"/>
      <xsl:text>\end{document}&#xa;</xsl:text>
    </exsl:document>
  </xsl:template>

  <xsl:template name="worksheets-main-file">
    <exsl:document href="worksheets.tex" method="text">
      <xsl:text>\documentclass{book}&#xa;&#xa;</xsl:text>
      <xsl:text>\input{worksheets-preamble.tex}&#xa;</xsl:text>
      <!-- <xsl:text>% Include a file allowing course customizations &#xa;</xsl:text> -->
      <!-- <xsl:text>\@input{../customize.tex}&#xa;</xsl:text> -->
      <xsl:text>\begin{document}&#xa;&#xa;</xsl:text>
      <xsl:apply-templates select="*" mode="worksheets"/>
      <xsl:text>\end{document}&#xa;</xsl:text>
    </exsl:document>
  </xsl:template>


  <xsl:template name="notes-main-file">
    <exsl:document href="./notes/notes.tex" method="text">
      <xsl:text>\documentclass{article}&#xa;&#xa;</xsl:text>
      <xsl:text>\input{notes-preamble.tex}&#xa;</xsl:text>
      <!-- <xsl:text>% Include a file allowing course customizations &#xa;</xsl:text> -->
      <!-- <xsl:text>\@input{../customize.tex}&#xa;</xsl:text> -->
      <xsl:text>\begin{document}&#xa;</xsl:text>
      <xsl:apply-templates select="*" mode="notes"/>
      <xsl:text>\end{document}&#xa;</xsl:text>
    </exsl:document>
  </xsl:template>


  <!-- Subfiles: -->
  <xsl:template name="activities-subfiles">
    <xsl:variable name="filename">
      <!-- <text>activities/</text> -->
      <!-- <xsl:apply-templates select="." mode="long-name" /> -->
      <xsl:call-template name="type-and-number"/>
      <text>.tex</text>
    </xsl:variable>
    <exsl:document href="{$filename}" method="text">
      <xsl:text>\documentclass{book}&#xa;&#xa;</xsl:text>
      <xsl:text>\input{../activities-preamble.tex}&#xa;</xsl:text>
      <!-- <xsl:text>% Include a file allowing course customizations &#xa;</xsl:text> -->
      <!-- <xsl:text>\@input{../../customize.tex}&#xa;</xsl:text> -->
      <xsl:text>\begin{document}&#xa;</xsl:text>
      <!-- <xsl:text>\subsection*{</xsl:text>
    <xsl:apply-templates select="." mode="long-name" />
    <xsl:text>}&#xa;</xsl:text> -->
      <!-- <xsl:apply-templates select="*" mode="activities"/> -->
      <xsl:call-template name="start-activity" />
      <xsl:apply-templates select="."/>
      <xsl:call-template name="end-activity" />
      <xsl:text>\end{document}&#xa;</xsl:text>
    </exsl:document>
  </xsl:template>

  <xsl:template name="worksheets-subfiles">
    <xsl:variable name="filename">
      <!-- <text>activities/</text> -->
      <!-- <xsl:apply-templates select="." mode="long-name" /> -->
      <xsl:call-template name="ws-id"/>
      <text>.tex</text>
    </xsl:variable>
    <exsl:document href="{$filename}" method="text">
      <xsl:text>\documentclass{book}&#xa;&#xa;</xsl:text>
      <xsl:text>\input{worksheets-preamble.tex}&#xa;</xsl:text>
      <!-- <xsl:text>% Include a file allowing course customizations &#xa;</xsl:text> -->
      <!-- <xsl:text>\@input{../../customize.tex}&#xa;</xsl:text> -->
      <xsl:text>\begin{document}&#xa;</xsl:text>
      <!-- <xsl:text>\subsection*{</xsl:text>
    <xsl:apply-templates select="." mode="long-name" />
    <xsl:text>}&#xa;</xsl:text> -->
      <!-- <xsl:apply-templates select="*" mode="activities"/> -->
      <xsl:call-template name="start-worksheet" />
      <xsl:apply-templates select="."/>
      <xsl:call-template name="end-worksheet" />
      <xsl:text>\end{document}&#xa;</xsl:text>
    </exsl:document>
  </xsl:template>





  <!-- To generate single file with preambles: -->

  <xsl:template name="activities-preamble-file">
    <exsl:document href="activities-preamble.tex" method="text">
      <xsl:call-template name="activities-preamble"/>
    </exsl:document>
  </xsl:template>

  <xsl:template name="worksheets-preamble-file">
    <exsl:document href="worksheets-preamble.tex" method="text">
      <xsl:call-template name="worksheets-preamble"/>
    </exsl:document>
  </xsl:template>

  <xsl:template name="notes-preamble-file">
    <exsl:document href="notes-preamble.tex" method="text">
      <xsl:call-template name="notes-preamble"/>
    </exsl:document>
  </xsl:template>




  <!-- ########################################### -->
  <!-- End of main sheet.  Below is only preambles -->
  <!-- ########################################### -->



  <!-- Activities: -->
  <xsl:template name="activities-preamble">
    <!-- Hack to avoid error when compiling article -->
    <!-- <xsl:text>\newcommand*{\chaptername}{Chapter}</xsl:text>
  <xsl:text>\newcounter{chapter}</xsl:text> -->
    <!-- Preamble pulled from mathbook-latex.xsl -->
    <xsl:call-template name="latex-preamble"/>
    <xsl:text>% Include docmute package to include files that can themselves compile. &#xa;</xsl:text>
    <xsl:text>\usepackage{docmute}&#xa;</xsl:text>
    <xsl:text>\usepackage{import}&#xa;</xsl:text>
    <xsl:text>\pagestyle{empty}&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="worksheets-preamble">
    <!-- Hack to avoid error when compiling article -->
    <!-- <xsl:text>\newcommand*{\chaptername}{Chapter}</xsl:text>
  <xsl:text>\newcounter{chapter}</xsl:text> -->
    <!-- Preamble pulled from mathbook-latex.xsl -->
    <xsl:call-template name="latex-preamble"/>
    <xsl:text>% Include docmute package to include files that can themselves compile. &#xa;</xsl:text>
    <xsl:text>\usepackage{docmute}&#xa;</xsl:text>
    <xsl:text>\usepackage{import}&#xa;</xsl:text>
    <xsl:text>\pagestyle{plain}&#xa;</xsl:text>
  </xsl:template>

  <!-- Notes: -->
  <xsl:template name="notes-preamble">
    <xsl:call-template name="latex-preamble"/>
  </xsl:template>




<!-- Set up title and headers for worksheets -->
<!-- Macros for \thecourse and \theterm must be defined in -->
  <xsl:template name="titlesec-section-style">
    <xsl:text>\titleformat{\section}
    {\large\filcenter\scshape\bfseries}
    {\thesection}
    {1em}
    {#1}
    [\large\authorsptx]&#xa;</xsl:text>
    <xsl:text>\titleformat{name=\section,numberless}[block]
    {\large\filcenter\bfseries}
    {}
    {0.0em}
    {\vskip -3em #1}&#xa;</xsl:text>
    <xsl:text>\titlespacing*{\section}{0pt}{0pt}{2em}&#xa;</xsl:text>
  </xsl:template>


</xsl:stylesheet>
