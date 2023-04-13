

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMEULA WHERE strVersionNumber = '22.1.1')
BEGIN
INSERT INTO tblSMEULA(strVersionNumber, strText)
VALUES ('22.1.1', N'<!DOCTYPE html>
<html>

<head>
<meta http-equiv=Content-Type content="text/html;charset=utf-8">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 15">
<meta name=Originator content="Microsoft Word 15">

<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-469750017 -1073732485 9 0 511 0;}
@font-face
	{font-family:"Segoe UI";
	panose-1:2 11 5 2 4 2 4 2 2 3;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-469750017 -1073683329 9 0 511 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-parent:"";
	margin-top:0in;
	margin-right:.2pt;
	margin-bottom:6.95pt;
	margin-left:27.5pt;
	text-align:justify;
	text-justify:inter-ideograph;
	text-indent:-27.5pt;
	line-height:103%;
	mso-pagination:widow-orphan;
	font-size:10.5pt;
	mso-bidi-font-size:11.0pt;
	font-family:"Segoe UI",sans-serif;
	mso-fareast-font-family:"Segoe UI";
	color:black;}
h1
	{mso-style-priority:9;
	mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-parent:"";
	mso-style-link:"Heading 1 Char";
	mso-style-next:Normal;
	margin-top:0in;
	margin-right:.3pt;
	margin-bottom:6.9pt;
	margin-left:.5pt;
	text-align:justify;
	text-justify:inter-ideograph;
	text-indent:-.5pt;
	line-height:103%;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	mso-outline-level:1;
	mso-list:l0 level1 lfo2;
	font-size:10.5pt;
	mso-bidi-font-size:11.0pt;
	font-family:"Segoe UI",sans-serif;
	mso-fareast-font-family:"Segoe UI";
	color:black;
	mso-font-kerning:0pt;
	mso-bidi-font-weight:normal;}
h2
	{mso-style-priority:9;
	mso-style-qformat:yes;
	mso-style-parent:"";
	mso-style-link:"Heading 2 Char";
	mso-style-next:Normal;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:6.25pt;
	margin-left:122.1pt;
	text-align:center;
	text-indent:-.5pt;
	line-height:107%;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	mso-outline-level:2;
	font-size:10.5pt;
	mso-bidi-font-size:11.0pt;
	font-family:"Segoe UI",sans-serif;
	mso-fareast-font-family:"Segoe UI";
	color:black;
	font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
span.Heading2Char
	{mso-style-name:"Heading 2 Char";
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-parent:"";
	mso-style-link:"Heading 2";
	mso-ansi-font-size:10.5pt;
	font-family:"Segoe UI",sans-serif;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	font-style:italic;
	mso-bidi-font-style:normal;}
span.Heading1Char
	{mso-style-name:"Heading 1 Char";
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-parent:"";
	mso-style-link:"Heading 1";
	mso-ansi-font-size:10.5pt;
	font-family:"Segoe UI",sans-serif;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	font-weight:bold;
	mso-bidi-font-weight:normal;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
.MsoChpDefault
	{mso-style-type:export-only;
	mso-default-props:yes;
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:"Times New Roman";
	mso-fareast-theme-font:minor-fareast;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-theme-font:minor-bidi;}
.MsoPapDefault
	{mso-style-type:export-only;
	margin-bottom:8.0pt;
	line-height:107%;}
 /* Page Definitions */
 @page
	{mso-footnote-separator:url("iRely%20Master%20Agreement%2011-5-2022_files/header.htm") fs;
	mso-footnote-continuation-separator:url("iRely%20Master%20Agreement%2011-5-2022_files/header.htm") fcs;
	mso-endnote-separator:url("iRely%20Master%20Agreement%2011-5-2022_files/header.htm") es;
	mso-endnote-continuation-separator:url("iRely%20Master%20Agreement%2011-5-2022_files/header.htm") ecs;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.05in 71.5pt 73.35pt 1.0in;
	mso-header-margin:.5in;
	mso-footer-margin:35.9pt;
	mso-even-footer:url("iRely%20Master%20Agreement%2011-5-2022_files/header.htm") ef1;
	mso-footer:url("iRely%20Master%20Agreement%2011-5-2022_files/header.htm") f1;
	mso-first-footer:url("iRely%20Master%20Agreement%2011-5-2022_files/header.htm") ff1;
	mso-paper-source:0;}
div.WordSection1
	{page:WordSection1;}
 /* List Definitions */
 @list l0
	{mso-list-id:806121721;
	mso-list-type:hybrid;
	mso-list-template-ids:-1178562202 1720240126 -794121490 94289306 1891398236 -1744164246 2062846036 2146704322 1637386008 397029504;}
@list l0:level1
	{mso-level-style-link:"Heading 1";
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l0:level2
	{mso-level-number-format:alpha-lower;
	mso-level-text:%2;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l0:level3
	{mso-level-number-format:roman-lower;
	mso-level-text:%3;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l0:level4
	{mso-level-text:%4;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:1.75in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l0:level5
	{mso-level-number-format:alpha-lower;
	mso-level-text:%5;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:2.25in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l0:level6
	{mso-level-number-format:roman-lower;
	mso-level-text:%6;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:2.75in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l0:level7
	{mso-level-text:%7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:3.25in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l0:level8
	{mso-level-number-format:alpha-lower;
	mso-level-text:%8;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:3.75in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l0:level9
	{mso-level-number-format:roman-lower;
	mso-level-text:%9;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:4.25in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l1
	{mso-list-id:1485123247;
	mso-list-type:hybrid;
	mso-list-template-ids:1824322702 -1987050888 66772354 1537928094 -1855708806 -1064239886 -2131078222 1033011204 -1382387588 -666225568;}
@list l1:level1
	{mso-level-start-at:11;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l1:level2
	{mso-level-number-format:alpha-lower;
	mso-level-text:%2;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l1:level3
	{mso-level-number-format:roman-lower;
	mso-level-text:%3;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l1:level4
	{mso-level-text:%4;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:1.75in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l1:level5
	{mso-level-number-format:alpha-lower;
	mso-level-text:%5;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:2.25in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l1:level6
	{mso-level-number-format:roman-lower;
	mso-level-text:%6;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:2.75in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l1:level7
	{mso-level-text:%7;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:3.25in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l1:level8
	{mso-level-number-format:alpha-lower;
	mso-level-text:%8;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:3.75in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
@list l1:level9
	{mso-level-number-format:roman-lower;
	mso-level-text:%9;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:4.25in;
	text-indent:0in;
	mso-ansi-font-size:10.5pt;
	mso-bidi-font-size:10.5pt;
	mso-ascii-font-family:"Segoe UI";
	mso-fareast-font-family:"Segoe UI";
	mso-hansi-font-family:"Segoe UI";
	mso-bidi-font-family:"Segoe UI";
	color:black;
	border:none;
	mso-ansi-font-weight:bold;
	mso-bidi-font-weight:bold;
	mso-ansi-font-style:normal;
	text-underline:black;
	text-decoration:none;
	text-underline:none;
	text-decoration:none;
	text-line-through:none;
	vertical-align:baseline;}
ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"Table Normal";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-parent:"";
	mso-padding-alt:0in 5.4pt 0in 5.4pt;
	mso-para-margin-top:0in;
	mso-para-margin-right:0in;
	mso-para-margin-bottom:8.0pt;
	mso-para-margin-left:0in;
	line-height:107%;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-theme-font:minor-bidi;}
</style>
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="1026"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=EN-PH style=''tab-interval:.5in;word-wrap:break-word''>

<div class=WordSection1>

<p class=MsoNormal align=left style=''margin:0in;text-align:left;text-indent:
0in;line-height:107%''><a
href="http://help.irelyserver.com/display/DOC/Schedule+2.2+-+iRely+SAAS+Agreement"><span
style=''font-size:20.0pt;mso-bidi-font-size:11.0pt;line-height:107%;color:#3B73AF''>Master
Agreement</span></a><a
href="http://help.irelyserver.com/display/DOC/Schedule+2.2+-+iRely+SAAS+Agreement"><span
style=''font-size:20.0pt;mso-bidi-font-size:11.0pt;line-height:107%;color:#172B4D;
text-decoration:none;text-underline:none''> </span></a></p>

<p class=MsoNormal align=left style=''margin:0in;text-align:left;text-indent:
0in;line-height:107%''><span style=''font-size:20.0pt;mso-bidi-font-size:11.0pt;
line-height:107%''><span style=''mso-spacerun:yes''> </span></span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;
margin-left:-.25pt;text-indent:-.5pt''><b style=''mso-bidi-font-weight:normal''>YOU
AGREE THAT, BY PLACING AN ORDER THROUGH A PROVIDER ORDERING DOCUMENT SUCH AS A
PROPOSAL OR SOW FOR PROFESSIONAL SERVICES, SUCH ORDERING DOCUMENT INCORPORATES
AND IS GOVERNED BY THE TERMS OF THIS MASTER AGREEMENT, AND THAT</b> <b
style=''mso-bidi-font-weight:normal''>YOU AGREE TO BE BOUND BY THE TERMS AND
CONDITIONS OF THE ORDERING DOCUMENT AND THIS MASTER AGREEMENT. </b><span
style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.25pt;margin-left:0in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin:0in;text-indent:0in''>THIS MASTER AGREEMENT
(together with all applicable Ordering Documents, as defined below, and all
applicable schedules thereto, the &quot;<u style=''text-underline:black''>Master
Agreement</u>&quot;), is effective as of the date (the &quot;<u
style=''text-underline:black''>Effective</u> <u style=''text-underline:black''>Date</u>&quot;)
on which the initial Ordering Document is entered into by <span class=SpellE>iRely</span>
LLC<b style=''mso-bidi-font-weight:normal''>,</b> a Delaware limited liability
company, with a principal place of business located at 4242 Flagstaff Cove,
Ft.<span style=''mso-spacerun:yes''>  </span>Wayne, Indiana, 46815 (&quot;<u
style=''text-underline:black''>Provider</u>&quot;) and the other party to such
initial Ordering Document (&quot;<u style=''text-underline:black''>Customer</u>&quot;),
with a principal place of business as specified in such Ordering Document.<span
style=''mso-spacerun:yes''>  </span>Customer and Provider are hereafter referred
to collectively as the “<u style=''text-underline:black''>Parties</u>” and sometimes
individually as a “<u style=''text-underline:black''>Party</u>”. </p>

<p class=MsoNormal align=left style=''margin:0in;text-align:left;text-indent:
0in;line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:.5pt;margin-left:-.25pt;
text-indent:0in;mso-list:none''>BACKGROUND </h1>

<p class=MsoNormal align=left style=''margin:0in;text-align:left;text-indent:
0in;line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin:0in;text-indent:0in''>Provider is in the
business of providing licensed access to software applications for managing
extended enterprise data and development, implementation and other services for
such applications.<span style=''mso-spacerun:yes''>  </span>Customer wishes to
obtain licensed access to such applications and certain project management,
development, implementation, consulting and other services from Provider, on
the terms and conditions of this Master Agreement and Schedules thereto. </p>

<p class=MsoNormal align=left style=''margin:0in;text-align:left;text-indent:
0in;line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:0in;text-indent:0in''>NOW, THEREFORE, in consideration of the mutual
promises, covenants and conditions contained herein, and for other good and
valuable consideration, the receipt and sufficiency thereof the Parties hereby
acknowledge, the Parties hereby agree as follows, such agreement evidenced by
the Parties’ execution of the initial Ordering Document between the Parties
and/or electronic assent provided in connection with such Ordering Document
(or, as applicable, by means of any other commercially reasonable method of
indicating the Parties’ assent): </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.15pt;margin-left:0in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;margin-left:
35.25pt;text-indent:-.5in;mso-list:l0 level1 lfo2''><![if !supportLists]><span
style=''mso-bidi-font-size:10.5pt;line-height:103%;mso-bidi-font-weight:bold''><span
style=''mso-list:Ignore''>1.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>SCOPE OF AGREEMENT AND SCHEDULES<span
style=''font-weight:normal''> </span></h1>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:35.25pt;text-indent:0in''>This Master Agreement includes applicable
Schedules, described below, that specify the types of Products and Services
ordered by Customer through applicable Ordering Documents.<span
style=''mso-spacerun:yes''>  </span>Each applicable Schedule is incorporated
herein by reference.<span style=''mso-spacerun:yes''>  </span>Provider’s current
forms of the Schedules listed below are available at<span
style=''mso-spacerun:yes''>  </span><a href="http://help.irelyserver.com/"><span
style=''color:blue''>http://help.irelyserver.com/</span></a><a
href="http://help.irelyserver.com/"><span style=''color:black;text-decoration:
none;text-underline:none''>,</span></a> as such forms may be periodically
updated by Provider. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>1.1. <b style=''mso-bidi-font-weight:normal''>Schedule 1 –
Proposal</b>, defines the scope of products and services to be provided under
this Master Agreement and applicable Schedules.<span style=''mso-spacerun:yes''> 
</span>Once agreed to by both Parties, each Proposal and SOW become an “<u
style=''text-underline:black''>Ordering Document</u>” hereunder. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>1.2.<span style=''mso-spacerun:yes''> </span><b
style=''mso-bidi-font-weight:normal''>Schedule 2.1 – Software License Agreement</b>,
governs the licensing of Software, if Customer has elected to use the Software
installed on its own servers or as hosted by Provider. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>1.3. <b style=''mso-bidi-font-weight:normal''>Schedule 2.2 –
SaaS Agreement</b>, governs the provision of the SaaS Services, if Customer has
elected to use the SaaS Services. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>1.4. <b style=''mso-bidi-font-weight:normal''>Schedule 3 –
Statement of Work (SOW),</b> describes the implementation process and related
services and processes for the Application. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>1.5. <b style=''mso-bidi-font-weight:normal''>Schedule 4 –
Maintenance Agreement</b>, describes the Maintenance Services that Provider may
provide to Customer. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>1.6. <b style=''mso-bidi-font-weight:normal''>Schedule 5 –
Invoicing and Payment</b>, describes Provider’s invoicing procedures and
Customer''s payment obligations. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>1.7. <b style=''mso-bidi-font-weight:normal''>Schedule 6 –
Change Procedure,</b> describes the process by which the Parties may make
changes to the scope of products and services during the Term of this Master
Agreement. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>1.8. <b style=''mso-bidi-font-weight:normal''>Schedule 7 –
Hosting Agreement</b>, governs Provider''s hosting of the Application and
Customer Data on its servers. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.05pt;margin-left:0in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;margin-left:
35.25pt;text-indent:-.5in;mso-list:l0 level1 lfo2''><![if !supportLists]><span
style=''mso-bidi-font-size:10.5pt;line-height:103%;mso-bidi-font-weight:bold''><span
style=''mso-list:Ignore''>2.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>DEFINITIONS<span style=''font-weight:normal''> </span></h1>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:35.25pt;text-indent:0in''>For the purposes of this Master Agreement
and Schedules, the terms set forth below have the applicable meanings ascribed
in this <u style=''text-underline:black''>Section 2</u>.<span
style=''mso-spacerun:yes''>  </span>Additional capitalized terms defined
elsewhere in this Master Agreement or Schedules have the respective meanings
ascribed therein. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.1. &quot;<u style=''text-underline:black''>Affiliate</u>&quot;
means, with respect to a specified Person, any Person which directly or
indirectly controls, is controlled by, or is under common control with the
specified Person as of the date of this Master Agreement, for as long as such
relationship remains in effect; &quot;<u style=''text-underline:black''>control</u>&quot;
and cognates means the direct or indirect beneficial ownership of a majority
interest in the voting stock, or other ownership interests, of such Person, or
the power to elect at least a majority of the directors or trustees of such
Person, or majority control of such Person, or such other relationship that
constitutes actual control. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.2. &quot;<u style=''text-underline:black''>Application</u>&quot;
means, collectively, the Products, Deliverables, and Services to which Customer
may have access pursuant to this Master Agreement and applicable Schedules. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.3. &quot;<u style=''text-underline:black''>Confidential
Information</u>&quot; means all financial, technical, strategic, marketing, and
other information relating to a disclosing Party or its actual or prospective
business, products, or technology that may be, or has been, furnished or
disclosed to the other Party by, or acquired by receiving Party, directly or
indirectly from the disclosing Party, whether disclosed orally or in writing or
electronically or some other form. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.4.<span style=''mso-spacerun:yes''> </span>“<u
style=''text-underline:black''>Customer Data</u>&quot; means any data,
information, content or material which Customer or its Affiliates enter, load
onto, or use in connection with the Application, and all results from
processing such items through the Application. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.5. &quot;<u style=''text-underline:black''>Deliverables</u>&quot;
means Software modifications and other items created by Provider for Customer
during the performance of Professional Services and pursuant to an
Implementation Project Plan. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.6. &quot;<u style=''text-underline:black''>Documentation</u>&quot;
means the materials created by or on behalf of Provider that describe or relate
to the functional, operational or performance capabilities of the Application,
regardless of whether such materials are in written or digital form, including all
operator’s and user manuals, training materials, guides, commentary, technical,
design or functional specifications, requirements documents, product
descriptions, proposals, schedules, listings and other materials related to the
Software. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.7. &quot;<u style=''text-underline:black''>Fees</u>&quot;
means, collectively, the applicable license, subscription, maintenance,
hosting, professional services and other Provider fees described in the
Ordering Documents and payable in accordance with <b style=''mso-bidi-font-weight:
normal''>Schedule 5-Invoicing and Payment.</b> </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.8. &quot;<u style=''text-underline:black''>Intellectual
Property Rights</u>&quot; means all (a) copyrights and copyrightable works,
whether registered or unregistered; (b) trademarks, service marks, trade dress,
logos, registered designs, trade and business names (including internet domain
names, corporate names, and e-mail addresses), whether registered or
unregistered; (c) patents, patent applications, patent disclosures, mask works
and inventions (whether patentable or not); (d) trade secrets, know-how, data
privacy rights, database rights, know-how, and rights in designs; and (e) all
other forms of intellectual property or proprietary rights, and derivative
works thereof; in each case in every jurisdiction worldwide. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.4pt;margin-bottom:7.6pt;
margin-left:62.75pt;line-height:98%''>2.9. &quot;<u style=''text-underline:black''>Ordering
Document</u>&quot; means, collectively, <b style=''mso-bidi-font-weight:normal''>Schedule
1 - Proposal</b> to this Master Agreement and all subsequent proposals and SOWs
agreed to by the Parties in accordance with this Master Agreement. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.10. &quot;<u style=''text-underline:black''>Permitted
Users</u>&quot; means employees of Customer and of Customer Affiliates who are
expressly authorized to use the Application in accordance with this Master
Agreement and who are specifically supplied user identifications and/or
passwords in accordance with this Master Agreement. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.4pt;margin-bottom:7.6pt;
margin-left:62.75pt;line-height:98%''>2.11. “<u style=''text-underline:black''>Person</u>”
means any individual, sole proprietorship, joint venture, partnership,
corporation, company, firm, association, cooperative, trust, estate,
government, governmental agency, regulatory authority or other entity of any
nature. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.12. &quot;<u style=''text-underline:black''>Products</u>&quot;
means, collectively, the Software and Documentation provided by Provider as set
forth in either <b style=''mso-bidi-font-weight:normal''>Schedule 2.1 – Software
License Agreement</b> or <b style=''mso-bidi-font-weight:normal''>Schedule 2.2 –
SaaS Agreement</b>, as applicable. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.13. &quot;<u style=''text-underline:black''>Professional
Services</u>&quot; means custom software development and other professional
services provided by Provider in connection with implementation or ongoing use
of the Application. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.4pt;margin-bottom:7.6pt;
margin-left:62.75pt;line-height:98%''>2.14. “<u style=''text-underline:black''>Proprietary
Provider Items</u>” means, collectively, the Application, the object code and
the source code for the Application, the visual expressions, screen formats,
report formats and other design features of the Application, all development
tools and methodologies used in connection with the Application and other
Provider services, as applicable, all ideas, methods, algorithms, formulae and
concepts used in developing and/or incorporated into the Application, all
future modifications, revisions, updates, releases, refinements, improvements
and enhancements of the Application, all Intellectual Property Rights in such
foregoing items, and all copies of the foregoing. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.15. &quot;<u style=''text-underline:black''>Services</u>&quot;
means, collectively, the Professional Services and all other services described
in the Ordering Documents. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.16.<span style=''mso-spacerun:yes''>  </span>“<u
style=''text-underline:black''>Software</u>” means the Provider software
described in <b style=''mso-bidi-font-weight:normal''>Schedule 2.1 – Software
License Agreement </b>or <b style=''mso-bidi-font-weight:normal''>Schedule 2.2 –
SaaS Agreement</b>, as applicable, including all Updates to such software. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.17. &quot;<u style=''text-underline:black''>SOW</u>&quot;
means a Statement of Work created as described in <u style=''text-underline:
black''>Schedule 3 – Statement of</u> <u style=''text-underline:black''>Work</u>,
which sets forth the Deliverables, timelines and cost estimates for
Professional Services required as a result of the implementation process or
otherwise as a result of a Change Procedure described in <b style=''mso-bidi-font-weight:
normal''>Schedule 6 – Change Procedure</b>, such SOW constituting Customer’s
acceptance of Provider’s costs and other terms and conditions for such
Professional Services and Deliverables. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>2.18. &quot;<u style=''text-underline:black''>Subscription</u>&quot;
means Customer’s right to use and access the Application as described in<b
style=''mso-bidi-font-weight:normal''> <u style=''text-underline:black''>Schedule
2.2 – SaaS Agreement</u></b>, upon payment of all applicable subscription Fees.
</p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.15pt;margin-left:.5in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;margin-left:
35.25pt;text-indent:-.5in;mso-list:l0 level1 lfo2''><![if !supportLists]><span
style=''mso-bidi-font-size:10.5pt;line-height:103%;mso-bidi-font-weight:bold''><span
style=''mso-list:Ignore''>3.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>PERFORMANCE OF SERVICES<span style=''font-weight:
normal''> </span></h1>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:35.25pt;text-indent:0in''>Provider will use commercially reasonable
efforts to ensure that all Services will be performed in a workmanlike and
professional manner by qualified representatives of Provider who are fluent in
written and spoken English. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.15pt;margin-left:.5in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;margin-left:
35.25pt;text-indent:-.5in;mso-list:l0 level1 lfo2''><![if !supportLists]><span
style=''mso-bidi-font-size:10.5pt;line-height:103%;mso-bidi-font-weight:bold''><span
style=''mso-list:Ignore''>4.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>MAINTENANCE SERVICES<span style=''font-weight:
normal''> </span></h1>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:35.25pt;text-indent:0in''>Maintenance Services available to Customer
are as described in <b style=''mso-bidi-font-weight:normal''>Schedule 4 –
Maintenance Agreement.</b> </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.15pt;margin-left:0in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;margin-left:
35.25pt;text-indent:-.5in;mso-list:l0 level1 lfo2''><![if !supportLists]><span
style=''mso-bidi-font-size:10.5pt;line-height:103%;mso-bidi-font-weight:bold''><span
style=''mso-list:Ignore''>5.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>PAYMENT AND INVOICING<span style=''font-weight:
normal''> </span></h1>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:35.25pt;text-indent:0in''>Invoicing and payment terms for Products
and Services is described in <b style=''mso-bidi-font-weight:normal''>Schedule 5
– Payment and Invoicing</b>. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:.5pt;margin-left:0in;text-align:left;text-indent:0in;line-height:
107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:.5pt;margin-left:35.25pt;
text-indent:-.5in;mso-list:l0 level1 lfo2''><![if !supportLists]><span
style=''mso-bidi-font-size:10.5pt;line-height:103%;mso-bidi-font-weight:bold''><span
style=''mso-list:Ignore''>6.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>CONFIDENTIALITY AND OWNERSHIP<span
style=''font-weight:normal''> </span></h1>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:.5pt;margin-left:.75in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>6.1.<span style=''font-family:"Arial",sans-serif;
mso-fareast-font-family:Arial''> </span><u style=''text-underline:black''>Confidential
Information</u>.<span style=''mso-spacerun:yes''>  </span>During the term of this
Master Agreement and in perpetuity thereafter, each Party will keep in
confidence all of the Confidential Information of the other <span class=GramE>party,
and</span> will not use such Confidential Information of the other Party
without such other Party’s prior written consent.<span
style=''mso-spacerun:yes''>  </span>No Party will disclose the Confidential
Information of any other party to any Person, except to its own employees,
agents and independent contractors to whom it is necessary to disclose the
Confidential Information </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:63.35pt;text-indent:0in''>for the sole purpose of performing their
duties and/or exercising their rights under this Master Agreement, and who have
agreed to receive the Confidential Information under terms at least as
restrictive as those specified in this Master Agreement.<span
style=''mso-spacerun:yes''>  </span>Each Party will maintain the confidentiality
of the other Party’s Confidential Information using, at a minimum, the standard
of care that an ordinarily prudent Person would exercise to maintain the
secrecy of its own most confidential information.<span
style=''mso-spacerun:yes''>  </span>Each Party will immediately give notice to
the other Party of any unauthorized use or disclosure of the other Party’s Confidential
Information.<span style=''mso-spacerun:yes''>  </span>Each Party agrees to assist
the other Party in remedying such unauthorized use or disclosure of
Confidential Information.<span style=''mso-spacerun:yes''>  </span>Each Party
will return or destroy all copies of Confidential Information of the other
Party, upon the other Party’s reasonable request, and will provide a
certification in writing to such effect. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:.65pt;margin-left:63.35pt;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.4pt;margin-bottom:0in;
margin-left:62.75pt;line-height:98%''>6.2.<span style=''font-family:"Arial",sans-serif;
mso-fareast-font-family:Arial''> </span><u style=''text-underline:black''>Proprietary
Provider Items and Ownership</u>.<span style=''mso-spacerun:yes''>  </span>The
Proprietary Provider Items are trade secrets and proprietary property of
Provider, having great commercial value to Provider.<span
style=''mso-spacerun:yes''>  </span>All Proprietary Provider Items made available
to Customer under this Master Agreement are being provided on a strictly
confidential and limited-use basis.<span style=''mso-spacerun:yes''>  </span>Customer
will not, directly or indirectly, communicate, publish, display, loan, give or
otherwise disclose any Proprietary Provider Item to any Person, or permit any
Person to have access to or possession of any Proprietary Provider Item.<span
style=''mso-spacerun:yes''>  </span>Title to all Proprietary Provider Items and
all related Intellectual Property Rights will be and remain exclusively with
Provider, even with respect to such items that were created by Provider
specifically for or on behalf of Customer and <span class=GramE>whether or not</span>
such were created with reference to Customer IP (as defined below).<span
style=''mso-spacerun:yes''>  </span>This Master Agreement is not an agreement of
sale, and no Intellectual Property Rights to any Proprietary Provider Items are
transferred to Customer by virtue of this Master Agreement.<span
style=''mso-spacerun:yes''>  </span>All copies of Proprietary Provider Items in
Customer''s possession will remain the exclusive property of Provider and will
be deemed to be on loan to Customer during the term of this Master Agreement. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:.65pt;margin-left:63.35pt;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:62.75pt''>6.3.<span style=''font-family:"Arial",sans-serif;
mso-fareast-font-family:Arial''> </span><u style=''text-underline:black''>Customer
Intellectual Property</u>.<span style=''mso-spacerun:yes''>  </span>For the
purposes of this Master Agreement, &quot;<u style=''text-underline:black''>Customer</u>
<u style=''text-underline:black''>IP</u>&quot; means all Customer Confidential
Information, Customer Data and all Intellectual Property Rights in such
items.<span style=''mso-spacerun:yes''>  </span>Customer IP will be <span
class=GramE>owned<span style=''mso-spacerun:yes''>  </span>exclusively</span> by
Customer.<span style=''mso-spacerun:yes''>  </span>Provider will have the right
to use Customer IP as reasonably necessary for Provider to provide access to
Customer of the Application and to perform the Services and Provider’s other
obligations hereunder.<span style=''mso-spacerun:yes''>  </span>Customer
represents and warrants to Provider that Customer owns all Customer IP or has
all necessary rights to use and input Customer IP into the Application;
Customer IP will not infringe upon any third-party Intellectual Property Rights
or violate any rights against defamation or rights of privacy; and Customer has
not falsely identified itself nor provided any false information to gain access
to the Application, and that Customer''s billing information is correct.<span
style=''mso-spacerun:yes''>  </span>If Customer resides or operates in the
European Union (“<u style=''text-underline:black''>EU</u>”) or if any transfer of
information between Customer and the Application is governed by the EU Data
Protection Directive, EU General Data Protection Regulation (“<u
style=''text-underline:black''>GDPR</u>”), or similar directives and regulations,
and national laws implementing such directives and regulations, then Customer
expressly consents to, except to the extent prohibited by applicable law, the
transfer of such information outside of the EU to the United States and to such
other countries as may be required by Provider for the proper operation of the
Application under this Master Agreement.<span style=''mso-spacerun:yes''> 
</span>Customer will indemnify Provider against all third-party liability
arising from such transfer. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:.5pt;margin-left:63.35pt;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.4pt;margin-bottom:0in;
margin-left:62.75pt;line-height:98%''>6.4.<span style=''font-family:"Arial",sans-serif;
mso-fareast-font-family:Arial''> </span><u style=''text-underline:black''>Use
Restrictions</u>.<span style=''mso-spacerun:yes''>  </span>Customer will not do,
attempt to do, nor permit any other Person to do, any of the following:<span
style=''mso-spacerun:yes''>  </span>(a) use any Proprietary Provider Items for
any purpose, at any location or in any manner not specifically authorized by this
Master Agreement; (b) make or retain any copy of any Proprietary Provider Items
except as specifically authorized by this Master Agreement; (c) create or
recreate the source code for the Application, or reengineer, reverse engineer,
decompile or disassemble the Application; (d) modify, adapt, translate or
create derivative works based upon the Application, or combine or merge any
part of the Application with or into any other software or documentation; (e)
refer to or otherwise use any Proprietary Provider Items as part of any effort
either to develop a program having any functional attributes, visual
expressions or other features similar to those of the Application or to compete
with Provider or its Affiliates; (f) remove, erase or tamper with any copyright
or other proprietary notice printed or stamped on, affixed to, or encoded or
recorded in any Proprietary Provider Items, or fail to preserve all copyright
and other proprietary notices in any copy of any Proprietary Provider Items
made by Customer; or (g) sell, market, license, sublicense, distribute or
otherwise grant to any Person, including any outsourcer, vendor, consultant or
partner, any right to use any Proprietary Provider Items, whether on Customer''s
behalf or otherwise, except as specifically and expressly authorized in this
Master Agreement. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:.5pt;margin-left:63.35pt;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:62.75pt''>6.5.<span style=''font-family:"Arial",sans-serif;
mso-fareast-font-family:Arial''> </span><u style=''text-underline:black''>Provider
Right to Develop</u>.<span style=''mso-spacerun:yes''>   </span>Customer
acknowledges that Provider is engaged in the development of software for
clients other than Customer, and that Provider can and will develop software
and provide services for its other clients and will utilize and market
software, services and other items, including Deliverables, Maintenance
Services and all other Products and Services created under or in connection
with this Master Agreement, without any restrictions hereunder or any
obligations to Customer, and may solicit and provide similar Products and
Services on behalf of Persons that Customer may consider to be its direct or
indirect competitors, provided that Customer''s Confidential Information will
remain subject to the confidentiality and nondisclosure restrictions set forth
in <u style=''text-underline:black''>Section 6.1</u>. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:.65pt;margin-left:0in;text-align:left;text-indent:0in;line-height:
107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.4pt;margin-bottom:0in;
margin-left:62.75pt;line-height:98%''>6.6.<span style=''font-family:"Arial",sans-serif;
mso-fareast-font-family:Arial''> </span><u style=''text-underline:black''>Notice
and Remedy of Breaches</u>.<span style=''mso-spacerun:yes''>  </span>Each Party
will promptly give written notice to the other of any actual or suspected
breach by it of any of the provisions of this <u style=''text-underline:black''>Section
6</u>, <span class=GramE>whether or not</span> intentional, and the breaching
Party will, at its expense, take all steps reasonably requested by the other
Party to prevent or remedy the breach. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:.65pt;margin-left:0in;text-align:left;text-indent:0in;line-height:
107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.4pt;margin-bottom:7.6pt;
margin-left:62.75pt;line-height:98%''>6.7.<span style=''font-family:"Arial",sans-serif;
mso-fareast-font-family:Arial''> </span><u style=''text-underline:black''>Enforcement</u>.<span
style=''mso-spacerun:yes''>  </span>Each Party acknowledges that the restrictions
in this Master Agreement are reasonable and necessary to protect the other''s
legitimate business interests.<span style=''mso-spacerun:yes''>  </span>Each
Party acknowledges that any breach of any of the provisions of this <u
style=''text-underline:black''>Section 6 </u>will result in irreparable injury to
the other for which money damages could not adequately compensate.<span
style=''mso-spacerun:yes''>  </span>If there is a breach, then the injured Party
will be entitled, in addition to all other rights and remedies which it may
have at law or in equity and notwithstanding the provisions of <u
style=''text-underline:black''>Section 11.5.2</u>, to have a decree of specific
performance or an injunction issued by any competent court, requiring the
breach to be cured or enjoining all Persons involved from continuing the
breach.<span style=''mso-spacerun:yes''>  </span>The existence of any claim or
cause of action that a Party or any other Person may have against the other
Party will not constitute a defense or bar to the enforcement of any of the
provisions of this <u style=''text-underline:black''>Section 6</u>. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.15pt;margin-left:0in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;margin-left:
35.25pt;text-indent:-.5in;mso-list:l0 level1 lfo2''><![if !supportLists]><span
style=''mso-bidi-font-size:10.5pt;line-height:103%;mso-bidi-font-weight:bold''><span
style=''mso-list:Ignore''>7.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>CHANGE CONTROL PROCEDURE<span style=''font-weight:
normal''> </span></h1>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.4pt;margin-bottom:7.6pt;
margin-left:35.25pt;text-indent:0in;line-height:98%''>Provider’s current
procedures for managing changes to the Application or Services are as set forth
in <b style=''mso-bidi-font-weight:normal''>Schedule 6 – Change Control.</b> </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.15pt;margin-left:0in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;margin-left:
35.25pt;text-indent:-.5in;mso-list:l0 level1 lfo2''><![if !supportLists]><span
style=''mso-bidi-font-size:10.5pt;line-height:103%;mso-bidi-font-weight:bold''><span
style=''mso-list:Ignore''>8.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>TERM; TERMINATION<span style=''font-weight:normal''>
</span></h1>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:57.8pt;text-indent:-22.55pt''>8.1.<span style=''mso-spacerun:yes''> 
</span><u style=''text-underline:black''>Initial Term</u>.<span
style=''mso-spacerun:yes''>  </span>The initial term of this Master Agreement
begins on the Effective Date specified in the first executed Ordering Document
and continues in full force and effect for the applicable term specified in
such Ordering Document and, if longer, the applicable terms specified in
subsequent Ordering Documents, unless such term is extended or terminated
earlier pursuant to this Master Agreement or as stated in such Ordering
Documents (the &quot;<u style=''text-underline:black''>Initial Term</u>&quot;). </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:57.8pt;text-indent:-22.55pt''><span class=GramE>8.2<span
style=''mso-spacerun:yes''>  </span><u style=''text-underline:black''>Renewal</u></span><u
style=''text-underline:black''> Terms</u>.<span style=''mso-spacerun:yes''> 
</span>Certain Products and Services will automatically renew in accordance
with the relevant Ordering Documents (each a &quot;<u style=''text-underline:
black''>Renewal Term</u>&quot;; the Initial Term and Renewal Term are collectively
referred to as the “<u style=''text-underline:black''>Term</u>”), unless a Party
delivers written notice to the other Party of its intent to terminate at least
sixty (60) days before the expiration of the then current Term, unless the
applicable Ordering Document specifies a different period of notice.<span
style=''mso-spacerun:yes''>  </span>Unless otherwise set forth in an Ordering
Document, both SaaS Subscriptions and Maintenance Services will automatically
renew for additional one (1) year Renewal Terms at the end of the then current
Term. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.15pt;margin-left:35.75pt;text-align:left;text-indent:-.5pt;
line-height:107%''>8.3. <u style=''text-underline:black''>Termination</u>. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:1.25in;text-indent:-31.45pt''>8.3.1. Either Party may terminate this
Master Agreement and all applicable Schedules at any time during the Term:<span
style=''mso-spacerun:yes''>  </span>(a) upon thirty (30) days’ prior written
notice to the other Party, if the other Party breaches a material provision of
this Master Agreement or applicable Schedules and fails to cure such breach
within thirty (30) days after it receives such notice (or immediately, if such
breach is not reasonably capable of being cured during such period) or (b) as
provided in <u style=''text-underline:black''>Section 9</u> of this Master
Agreement. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:1.25in;text-indent:-31.45pt''>8.3.2. Either Party may terminate this
Master Agreement and all applicable Schedules immediately upon written notice
if the other Party becomes insolvent or files, or has filed against it, a
petition for bankruptcy, provided that such petition is not dismissed within
sixty (60) days. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:1.25in;text-indent:-31.45pt''>8.3.3. Provider may terminate this
Master Agreement and all applicable Schedules on thirty (30) days’ written
notice if Customer fails to make timely payments hereunder. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:35.25pt;text-indent:0in''>8.4 <u style=''text-underline:black''>Effect
of Termination</u>.<span style=''mso-spacerun:yes''>  </span>When this Master
Agreement terminates or expires for any reason: </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:1.20in;text-indent:-31.45pt''><span
style=''mso-spacerun:yes''> </span>8.4.1.<span style=''mso-spacerun:yes''> </span>Customer will pay Provider for all Products provided, Services <span
class=GramE>performed</span> and expenses incurred by Provider on or before the
date of termination.<span style=''mso-spacerun:yes''>  </span>If this Master
Agreement was terminated before the end of the then current Term for reasons
other than Provider''s breach or insolvency, then Customer will repay all
discounts set forth in the Ordering Document with respect to the
early-terminated Term. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:1.25in;text-indent:-31.45pt''>8.4.2.<span
style=''mso-spacerun:yes''> </span>Provider will discontinue (and cause its
contractors and personnel to discontinue) all use of Customer IP.<span
style=''mso-spacerun:yes''>   </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.4pt;margin-bottom:7.6pt;
margin-left:1.25in;text-indent:-31.45pt;line-height:98%''>8.4.3. Customer will<span
class=GramE>:<span style=''mso-spacerun:yes''>  </span>(</span>a) immediately
discontinue all use of the Application, (b) promptly return to Provider all
copies of the Software and Documentation and all other Proprietary Provider
Items then in Customer''s possession and (c) give written notice to Provider
certifying that all copies of the Products have been permanently deleted from
its computers.<span style=''mso-spacerun:yes''>  </span>Customer will remain
liable for all payments due to Provider with respect to the period ending on
the date of termination.<span style=''mso-spacerun:yes''>  </span>The provisions
of <u style=''text-underline:black''>Section 5</u> (with respect to payments due
and payable upon termination), <u style=''text-underline:black''>Section 6</u>,
this <u style=''text-underline:black''>Section 8</u>, <u style=''text-underline:
black''>Section 10</u> and <u style=''text-underline:black''>Section 11</u> will
survive any termination of this Master Agreement, whether under this <u
style=''text-underline:black''>Section 8</u> or otherwise. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.15pt;margin-left:0in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;margin-left:
35.25pt;text-indent:-.5in;mso-list:l0 level1 lfo2''><![if !supportLists]><span
style=''mso-bidi-font-size:10.5pt;line-height:103%;mso-bidi-font-weight:bold''><span
style=''mso-list:Ignore''>9.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>FORCE MAJEURE<span style=''font-weight:normal''> </span></h1>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:35.25pt;text-indent:0in''>Neither Party will be liable under or
deemed to be in breach of this Master Agreement for any delay or failure in
performance under this Master Agreement or an applicable Ordering Document that
is caused by any of the following events: <span
style=''mso-spacerun:yes''> </span>acts of God, civil or military authority; act,
order or requirement of any governmental or regulatory authority or body; war;
fires; power outages; earthquakes; floods; unusually severe weather; strikes or
labor disputes; disruptions of labor forces or supply chains; delays in
transportation or delivery; epidemics, pandemics or viral or communicable
disease outbreaks; quarantines; national emergencies; terrorism or threats of
terrorism; and any similar event that is beyond the reasonable control of the non-performing
Party (collectively, a &quot;<u style=''text-underline:black''>Force Majeure
Event</u>&quot;).<span style=''mso-spacerun:yes''>  </span>This <u
style=''text-underline:black''>Section 9</u> does not excuse either Party''s
obligation to take reasonable steps to follow its normal disaster recovery
procedures or Customer''s obligations to pay for Products and Services ordered
or delivered.<span style=''mso-spacerun:yes''>  </span>The Party affected by the
Force Majeure Event must diligently attempt to perform <span class=GramE>all of</span>
its obligations hereunder.<span style=''mso-spacerun:yes''>  </span>During a
Force Majeure Event, the Parties will use commercially reasonable efforts to
negotiate changes to this Master Agreement in good faith to address the Force
Majeure Event in a fair and equitable manner.<span style=''mso-spacerun:yes''> 
</span>If a Force Majeure Event continues for ten (10) days or longer, and if
the non-performing Party is delayed or unable to perform under this Master
Agreement or any Ordering Document because of the Force Majeure Event, then the
performing Party will have the right to terminate this Master Agreement and
applicable Schedules, in whole or in part, immediately upon written notice to
the non-performing Party. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.05pt;margin-left:0in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;margin-left:
35.25pt;text-indent:-.5in;mso-list:l0 level1 lfo2''><![if !supportLists]><span
style=''mso-bidi-font-size:10.5pt;line-height:103%;mso-bidi-font-weight:bold''><span
style=''mso-list:Ignore''>10.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>DISCLAIMERS AND LIMITATIONS OF LIABILITIES<span
style=''font-weight:normal''> </span><span style=''mso-spacerun:yes''> </span><span
style=''font-weight:normal''><span style=''mso-spacerun:yes''> </span></span></h1>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:63.0pt;text-indent:-27.0pt''><b style=''mso-bidi-font-weight:normal''>10.1.
<u style=''text-underline:black''>NO WARRANTIES</u>.<span
style=''mso-spacerun:yes''>  </span>THE APPLICATION, DELIVERABLES, HOSTING
SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES, MAINTENANCE SERVICES AND OTHER </b></p>

<p class=MsoNormal align=right style=''margin-top:0in;margin-right:.5pt;
margin-bottom:0in;margin-left:0in;text-align:right;text-indent:0in;line-height:
107%''><b style=''mso-bidi-font-weight:normal''>PRODUCTS AND SERVICES PROVIDED TO
CUSTOMER HEREUNDER ARE &quot;AS IS&quot;, </b></p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:63.5pt;
text-indent:0in;mso-list:none''>AND PROVIDER MAKES NO REPRESENTATIONS OR
WARRANTIES, ORAL OR WRITTEN, EXPRESS OR IMPLIED, ARISING FROM COURSE OF
DEALING, COURSE OF PERFORMANCE, USAGE OF TRADE, QUALITY OF INFORMATION, QUIET
ENJOYMENT OR OTHERWISE, INCLUDING IMPLIED WARRANTIES OF </h1>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;
margin-left:63.5pt;text-indent:-.5pt''><b style=''mso-bidi-font-weight:normal''>MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE, NONINTERFERENCE, OR NON-INFRINGEMENT
WITH RESPECT TO THE APPLICATION, DELIVERABLES, HOSTING SERVICES, SAAS SERVICES,
PROFESSIONAL SERVICES, MAINTENANCE SERVICES AND OTHER PRODUCTS AND SERVICES
PROVIDED TO CUSTOMER HEREUNDER OR WITH RESPECT TO ANY OTHER MATTER PERTAINING
TO THIS MASTER AGREEMENT OR SCHEDULES HERETO.<span style=''mso-spacerun:yes''> 
</span>CUSTOMER''S USE OF THE APPLICATION, DELIVERABLES, HOSTING SERVICES, SAAS
SERVICES, PROFESSIONAL SERVICES, MAINTENANCE SERVICES AND OTHER PRODUCTS AND
SERVICES PROVIDED TO CUSTOMER HEREUNDER WILL NOT BE DEEMED LEGAL, TAX OR
INVESTMENT ADVICE. </b></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;
margin-left:63.0pt;text-indent:-27.0pt''><b style=''mso-bidi-font-weight:normal''>10.2.
<u style=''text-underline:black''>LIMITATION ON LIABILITY</u>.<span
style=''mso-spacerun:yes''>  </span>PROVIDER''S TOTAL LIABILITY UNDER THIS MASTER
AGREEMENT AND SCHEDULES HERETO WILL UNDER NO CIRCUMSTANCES EXCEED THE AMOUNT OF
THE FEES ACTUALLY PAID BY CUSTOMER TO PROVIDER UNDER THIS MASTER AGREEMENT AND
SCHEDULES HERETO DURING THE THREE (3) MONTHS PRIOR TO THE EVENT OF LIABILITY,
LESS ALL AMOUNTS PAID BY PROVIDER TO CUSTOMER IN CONNECTION WITH ANY OTHER
EVENTS OF LIABILITY HEREUNDER.</b> </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:63.0pt;text-indent:-27.0pt''><b style=''mso-bidi-font-weight:normal''>10.3.
<u style=''text-underline:black''>EXCLUSION OF DAMAGES</u>.<span
style=''mso-spacerun:yes''>  </span>UNDER NO CIRCUMSTANCES WILL PROVIDER (OR ANY
PROVIDER AFFILIATES PROVIDING PRODUCTS, DELIVERABLES, HOSTING SERVICES, SAAS
SERVICES, PROFESSIONAL SERVICES, MAINTENANCE SERVICES AND OTHER PRODUCTS AND
SERVICES TO CUSTOMER HEREUNDER) BE LIABLE TO CUSTOMER, ANY PERMITTED USER, ANY
CLIENT OR AFFILIATE OF CUSTOMER, OR </b></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;
margin-left:63.5pt;text-indent:-.5pt''><b style=''mso-bidi-font-weight:normal''>ANY
OTHER PERSON FOR LOST REVENUES, LOST PROFITS, LOSS OF BUSINESS, TRADING LOSSES,
OR ANY INCIDENTAL, INDIRECT, EXEMPLARY, CONSEQUENTIAL, SPECIAL OR PUNITIVE
DAMAGES OF ANY KIND, INCLUDING SUCH DAMAGES ARISING FROM ANY BREACH OF THIS MASTER
AGREEMENT OR SCHEDULES HERETO, OR FROM ANY TERMINATION OF THIS MASTER AGREEMENT
OR SCHEDULES HERETO, WHETHER SUCH LIABILITY IS ASSERTED ON THE BASIS OF
CONTRACT, TORT (INCLUDING NEGLIGENCE OR STRICT LIABILITY) OR OTHERWISE AND
WHETHER OR NOT FORESEEABLE, EVEN IF PROVIDER HAS BEEN ADVISED OR WAS AWARE OF
THE POSSIBILITY OF SUCH LOSS OR DAMAGES.</b> </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:62.75pt''>10.4.<span style=''mso-spacerun:yes''>  </span><u
style=''text-underline:black''>Additional Limitations and Exclusions</u>.<span
style=''mso-spacerun:yes''>  </span>Provider will have no liability to Customer
under the following circumstances:<span style=''mso-spacerun:yes''> 
</span>Customer fails to fully observe Provider''s instructions relating to the
Application, Hosting Services, Maintenance Services, SaaS Services,
Professional Services or other Services provided by Provider; the Application,
Hosting Services, Maintenance Services, SaaS Services, Professional Services or
other Services provide by Provider are used in violation of this Master
Agreement and applicable Schedules; the Application is configured, customized,
installed or maintained by any Person other than Provider; Customer modifies
any portion of the Application without the prior written consent of Provider;
and/or the Application, Hosting Services, Maintenance Services, SaaS Services,
Professional Services and other Services provided by Provider are used in
conjunction with any hardware, software, products or interfaces not expressly
specified by Provider.<span style=''mso-spacerun:yes''>  </span>The obligations
of Provider under this Master Agreement run only to Customer and not to its
Affiliates, Permitted Users, clients or any other Persons.<span
style=''mso-spacerun:yes''>  </span>Under no circumstances will any Affiliate, Permitted
User or client of Customer or any other Person be considered a third-party
beneficiary of this Master Agreement or otherwise entitled to any rights or
remedies under this Master Agreement, even if such Affiliates, Permitted Users,
clients or other Persons are provided access to the Application or any Hosting
Services, SaaS Services, Professional Services, Maintenance Services or other
Services hereunder.<span style=''mso-spacerun:yes''>  </span>Customer will have
no rights or remedies against Provider except as specifically provided in this
Master Agreement.<span style=''mso-spacerun:yes''>  </span>No action or claim of
any type relating to this Master Agreement or applicable Schedules may be
brought or made by Customer more than one (1) year after Customer first has
knowledge of the basis for the action or claim.<span style=''mso-spacerun:yes''> 
</span>The exclusions, disclaimers and limitations set forth in this Master
Agreement have been considered and accepted by the Parties in the pricing of
the Application, Products and Services provided in this Master Agreement. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.15pt;margin-left:0in;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;
margin-left:.5in;text-indent:-.5in;mso-list:l1 level1 lfo1''><![if !supportLists]><b><span
style=''mso-bidi-font-size:10.5pt;line-height:103%''><span style=''mso-list:Ignore''>11.<span
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span></b><![endif]><b style=''mso-bidi-font-weight:normal''>OTHER
PROVISIONS. </b></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:66.8pt;text-indent:-31.55pt''>11.1. <u style=''text-underline:black''>Notices</u><b
style=''mso-bidi-font-weight:normal''>.<span style=''mso-spacerun:yes''>  </span></b>All
notices from a Party to the other Party under this Master Agreement will be in
writing and will be deemed given when<span class=GramE>:<span
style=''mso-spacerun:yes''>  </span>(</span>a) delivered personally with receipt
signature; (b) sent via certified mail with return receipt requested; or (c)
sent by commercially recognized air courier service with receipt signature
required, to the following address: </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:94.55pt;text-indent:0in''>if to <span class=SpellE>iRely</span>,
LLC: </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.7pt;margin-left:121.35pt;text-align:left;text-indent:-.5pt''><span
class=SpellE><i style=''mso-bidi-font-style:normal''>iRely</i></span><i
style=''mso-bidi-font-style:normal''>, LLC</i> </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.7pt;margin-left:121.35pt;text-align:left;text-indent:-.5pt''><i
style=''mso-bidi-font-style:normal''>4242 Flagstaff Cove</i> </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.7pt;margin-left:121.35pt;text-align:left;text-indent:-.5pt''><i
style=''mso-bidi-font-style:normal''>Ft.<span style=''mso-spacerun:yes''> 
</span>Wayne, Indiana, 46815</i> </p>

<h2 style=''margin-top:0in;margin-right:44.95pt;margin-bottom:6.25pt;margin-left:
26.9pt''>ATTENTION: Chris <span class=SpellE>Pelz</span> (<u style=''text-underline:
black''>chris.pelz@irely.com</u>)<span style=''font-style:normal''> </span></h2>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:7.05pt;margin-left:94.55pt;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.95pt;margin-left:0in;text-align:left;text-indent:0in;
tab-stops:center 133.25pt''><span style=''mso-spacerun:yes''> </span><span
style=''mso-tab-count:1''>                               </span>if to CUSTOMER: </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.7pt;margin-left:121.35pt;text-align:left;text-indent:-.5pt''><i
style=''mso-bidi-font-style:normal''>[NAME &amp; ADDRESS] </i><span
style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:74.75pt;
margin-bottom:0in;margin-left:121.35pt;text-align:left;text-indent:-.5pt;
line-height:152%''><i style=''mso-bidi-font-style:normal''>ATTENTION:
____________________________________________</i> <i style=''mso-bidi-font-style:
normal''>and</i> </p>

<h2 style=''margin-left:26.9pt''>ATTENTION:
____________________________________________<span style=''font-style:normal''> </span></h2>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.2pt;margin-left:94.55pt;text-align:left;text-indent:0in;
line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:66.8pt;text-indent:-31.55pt''>11.2. <u style=''text-underline:black''>Export
Control</u>.<span style=''mso-spacerun:yes''>  </span>Export laws and regulations
of the United States and any other relevant local export laws and regulations
apply to the Application.<span style=''mso-spacerun:yes''>  </span>Customer
acknowledges and </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:67.55pt;text-indent:0in''>agrees that such export laws govern its
use of the Application (including technical data) and Services provided under
this Master Agreement, and Customer will fully comply with all such export laws
and regulations (including &quot;deemed export&quot; and &quot;deemed
reexport&quot; regulations).<span style=''mso-spacerun:yes''>  </span>Customer
further agrees that no Products will be exported, directly or indirectly, in
whole or in part, in violation of these laws, or will be used for any purpose
prohibited by these laws.<span style=''mso-spacerun:yes''>  </span>Provider makes
no representation that the Application is appropriate or available for use in
any <span class=GramE>particular locations</span>.<span
style=''mso-spacerun:yes''>  </span>Customer is solely responsible for compliance
with all applicable laws, including export and import regulations of other
countries. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:66.8pt;text-indent:-31.55pt''>11.3. <u style=''text-underline:black''>Publicity</u>.<span
style=''mso-spacerun:yes''>  </span>Customer hereby grants Provider the right (a)
to name Customer as a Provider client, to use Customer’s name and logo on
Provider''s websites and on written and digital marketing materials and to
include links to Customer''s website and company introduction; the foregoing in
all modalities of Provider’s marketing efforts; and (b) to refer to Customer as
a Provider Customer during sales pitches to Provider prospects.<span
style=''mso-spacerun:yes''>  </span>Provider will seek Customer''s consent before
using Customer''s name in white papers or other similar written materials. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:66.8pt;text-indent:-31.55pt''>11.4. <u style=''text-underline:black''>Integration
and Amendments</u>.<span style=''mso-spacerun:yes''>  </span>This Master
Agreement and applicable Schedules constitute a complete and exclusive final
written expression of the terms of agreement between the Parties regarding the
subject matter hereof.<span style=''mso-spacerun:yes''>  </span>This Master
Agreement supersedes all earlier and contemporaneous proposals, agreements,
understandings and negotiations concerning the subject matter hereof.<span
style=''mso-spacerun:yes''>  </span>In the event of a conflict or inconsistency
between this Master Agreement and any Schedule, the terms of this Master
Agreement will prevail, provided that if this Master Agreement is silent on or
does not expressly provide for or address a right, limitation or obligation,
then the applicable Schedule will govern and control this Master Agreement to
the extent the Schedule expressly provides for or addresses a right, limitation
or obligation hereunder.<span style=''mso-spacerun:yes''>  </span>The Parties may
amend this Master Agreement only in writing, and no oral representation or
course of dealing will modify this Master Agreement. </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.15pt;margin-left:35.75pt;text-align:left;text-indent:-.5pt;
line-height:107%''>11.5. <u style=''text-underline:black''>Governing Law; Dispute
Resolution</u>.<span style=''mso-spacerun:yes''>   </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.9pt;
margin-left:99.0pt;text-indent:-31.45pt''>11.5.1. <b style=''mso-bidi-font-weight:
normal''>THE CONSTRUCTION AND PERFORMANCE OF THIS MASTER AGREEMENT AND SCHEDULES
HERETO WILL BE GOVERNED BY THE SUBSTANTIVE LAWS OF THE STATE OF DELAWARE,
UNITED STATES OF AMERICA, WITHOUT REGARD TO CONFLICTS OF LAWS PROVISIONS.<span
style=''mso-spacerun:yes''>  </span>THE UNITED NATIONS CONVENTION ON CONTRACTS
FOR THE INTERNATIONAL SALE OF GOODS WILL NOT APPLY TO THIS MASTER AGREEMENT.</b><span
style=''mso-spacerun:yes''>   </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:99.0pt;text-indent:-31.45pt''>11.5.2. Any controversy or claim
arising out of or relating to this Master Agreement, or the breach thereof,
will be settled by arbitration administered by the American Arbitration
Association (AAA) in accordance with its Commercial Arbitration Rules, and
judgment on the award rendered by the arbitrator(s) may be entered in any court
having jurisdiction thereof.<span style=''mso-spacerun:yes''>  </span>The
arbitration will be conducted in Allen County, Indiana by a single arbitrator
appointed by the AAA.<span style=''mso-spacerun:yes''>  </span>Any appeal of the
arbitration decision will be brought exclusively in the federal or state courts
situated in the State of Delaware.<span style=''mso-spacerun:yes''> 
</span>Customer hereby consents to exclusive personal jurisdiction and venue in
Delaware. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:66.8pt;text-indent:-31.55pt''>11.6. <u style=''text-underline:black''>Assignment</u>.<span
style=''mso-spacerun:yes''>  </span>This Master Agreement will bind, benefit and
be enforceable by and against Provider and Customer and, to the extent
permitted hereby, their respective successors and assigns.<span
style=''mso-spacerun:yes''>  </span>Customer will not assign this Master
Agreement or any of its rights hereunder, nor delegate any of its obligations
hereunder, without Provider’s prior written consent, except that such consent
will not be required in the case of an assignment to (a) a purchaser of or
successor to substantially all of Customer''s business (unless such purchaser or
successor is a software, data processing or computer services vendor that is a
competitor of Provider or any of its Affiliates), provided that the scope of
the rights granted this Master Agreement and the number of Permitted Users,
permitted locations and similar license or use conditions does not change and
that the purchaser or successor pays Provider’s then current relicensing fees,
or (b) an Affiliate of Customer, provided that the scope of the rights granted
this Master Agreement and the number of Permitted Users, permitted locations and
similar license or use conditions does not change and that Customer guarantees
in writing the obligations of the assignee hereunder.<span
style=''mso-spacerun:yes''>  </span>Any assignment by Customer in breach of this <u
style=''text-underline:black''>Section 11.6</u> will be void.<span
style=''mso-spacerun:yes''>  </span>Any express assignment of this Master
Agreement, any change in control of Customer, any acquisition of additional
business by Customer (by asset acquisition, merger or otherwise by operation of
law) and any assignment by merger or otherwise by operation of law, will
constitute an assignment of this Master Agreement by Customer for purposes of
this <u style=''text-underline:black''>Section 11.6</u>. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:6.95pt;
margin-left:66.8pt;text-indent:-31.55pt''>11.7. <u style=''text-underline:black''>Severability;
Certain Terms</u>.<span style=''mso-spacerun:yes''>   </span>If any provision of
this Master Agreement is held by a court of competent jurisdiction to be
invalid or unenforceable, then such provision will be construed, as nearly as
possible, to reflect the intentions of the original provision, with all other
provisions remaining in full force and effect.<span
style=''mso-spacerun:yes''>    </span>For the purposes of this Master Agreement, “<u
style=''text-underline:black''>including</u>” and cognates thereof means
“including but not limited to”. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:66.8pt;text-indent:-31.55pt''>11.8. <u style=''text-underline:black''>No
Agency</u>.<span style=''mso-spacerun:yes''>  </span>The Parties acknowledge and
agree that each is an independent contractor, and nothing herein constitutes a
joint venture, partnership, employment, or agency between Customer and
Provider.<span style=''mso-spacerun:yes''>  </span>Neither Party will have the
right to bind the other Party or cause it to incur liability. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:5.5pt;
margin-left:66.8pt;text-indent:-31.55pt''>11.9. <u style=''text-underline:black''>Waive</u>r.<span
style=''mso-spacerun:yes''>  </span>The failure of either Party to enforce any
right or provision in this Master Agreement will not constitute a waiver of
such right or provision unless expressly acknowledged and agreed to by such Party
in writing. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:0in;margin-bottom:5.6pt;
margin-left:66.8pt;text-indent:-31.55pt''>11.10. <u style=''text-underline:black''>Non-Solicitation</u>.<span
style=''mso-spacerun:yes''>  </span>During the Term and for a period of one (1)
year thereafter, neither Party will, except with the other Party''s prior
written approval, solicit the employment of any employee, consultant or
subcontractor of such other Party that directly participated in the activities
set forth in this Master Agreement.<span style=''mso-spacerun:yes''>  </span>The
foregoing will specifically not apply to general solicitations of employment
issued by either Party to which an employee of the other Party may voluntarily
respond. </p>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.3pt;margin-bottom:5.95pt;
margin-left:67.3pt;text-indent:-32.05pt;line-height:98%''>11.11. <u
style=''text-underline:black''>Counterparts; Electronic Signatures</u>.<span
style=''mso-spacerun:yes''>  </span>This Master Agreement <span style=''color:
#333333''>may be executed in multiple counterparts, each of which shall be
deemed to be an original, but together they shall constitute one and the same
instrument.<span style=''mso-spacerun:yes''>  </span>Facsimile and .pdf
signatures shall </span></p>

<p class=MsoNormal style=''margin-top:0in;margin-right:-.3pt;margin-bottom:5.95pt;
margin-left:67.55pt;text-indent:0in;line-height:98%''><span style=''color:#333333''>be
deemed valid and binding to the same extent as the original and the Parties
affirmatively consent to the use thereof, with no such consent having been
withdrawn. Each Party agrees that this Master Agreement and any Schedules and
other documents to be delivered in connection with this Master Agreement may be
executed by means of an electronic signature that complies with the federal
Electronic Signatures in Global and National Commerce Act, state enactments of
the Uniform Electronic Transactions Act, and/or any other relevant electronic
signatures law, in each case to the extent applicable.<span
style=''mso-spacerun:yes''>  </span>Any electronic signatures appearing on this
Master Agreement and such other Schedules and documents are the same as
handwritten signatures for the purposes of validity, enforceability, and
admissibility.<span style=''mso-spacerun:yes''>  </span>Each Party hereto shall
be entitled to conclusively rely upon, and shall have no liability with respect
to, any electronic signature or faxed, scanned, or photocopied manual signature
of any other Party and shall have no duty to investigate, confirm or otherwise
verify the validity or authenticity thereof.</span> </p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.7pt;margin-left:0in;text-align:left;text-indent:0in;line-height:
107%''><span style=''mso-spacerun:yes''> </span></p>

<p class=MsoNormal align=left style=''margin-top:0in;margin-right:0in;
margin-bottom:6.7pt;margin-left:.5pt;text-align:left;text-indent:-.5pt''><i
style=''mso-bidi-font-style:normal''>By clicking the &quot;I agree&quot; box in
connection with the initial Ordering Document between you and Provider or, as
applicable, by means of another commercially reasonable method of indicating
your assent, you acknowledge that you are entering into a legally binding
agreement with Provider, and that you have read, understood, and agreed to the
terms of this Master Agreement and the terms of all applicable Schedules.</i> </p>

<p class=MsoNormal align=left style=''margin:0in;text-align:left;text-indent:
0in;line-height:107%''><span style=''mso-spacerun:yes''> </span></p>

</div>

</body>

</html>

')
END

GO