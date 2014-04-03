GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMEULA WHERE strVersionNumber = '14.1')
BEGIN
INSERT INTO tblSMEULA(strVersionNumber, strText)
VALUES ('14.1', N'<!DOCTYPE html>
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<meta name=Generator content="Microsoft Word 14 (filtered)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
@font-face
	{font-family:Univers;
	panose-1:0 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:"Univers Bold";
	panose-1:0 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:"Arial Narrow";
	panose-1:2 11 6 6 2 2 2 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:10.0pt;
	font-family:"Times New Roman","serif";}
h1
	{mso-style-link:"Heading 1 Char";
	margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:6.0pt;
	margin-left:.5in;
	text-indent:-.5in;
	page-break-after:avoid;
	font-size:12.0pt;
	font-family:"Univers Bold","serif";}
h2
	{mso-style-link:"Heading 2 Char";
	margin-top:0in;
	margin-right:0in;
	margin-bottom:6.0pt;
	margin-left:1.0in;
	text-align:justify;
	text-indent:-.5in;
	font-size:11.0pt;
	font-family:"Univers","sans-serif";
	font-weight:normal;}
h3
	{mso-style-link:"Heading 3 Char";
	margin-top:0in;
	margin-right:0in;
	margin-bottom:6.0pt;
	margin-left:1.5in;
	text-indent:-.5in;
	font-size:11.0pt;
	font-family:"Univers","sans-serif";
	font-weight:normal;}
h4
	{mso-style-link:"Heading 4 Char";
	margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:1.75in;
	margin-bottom:.0001pt;
	text-indent:-.25in;
	font-size:12.0pt;
	font-family:"Univers","sans-serif";
	font-weight:normal;}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-link:"Balloon Text Char";
	margin:0in;
	margin-bottom:.0001pt;
	font-size:8.0pt;
	font-family:"Tahoma","sans-serif";}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.5in;
	margin-bottom:.0001pt;
	font-size:10.0pt;
	font-family:"Times New Roman","serif";}
p.MsoListParagraphCxSpFirst, li.MsoListParagraphCxSpFirst, div.MsoListParagraphCxSpFirst
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.5in;
	margin-bottom:.0001pt;
	font-size:10.0pt;
	font-family:"Times New Roman","serif";}
p.MsoListParagraphCxSpMiddle, li.MsoListParagraphCxSpMiddle, div.MsoListParagraphCxSpMiddle
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.5in;
	margin-bottom:.0001pt;
	font-size:10.0pt;
	font-family:"Times New Roman","serif";}
p.MsoListParagraphCxSpLast, li.MsoListParagraphCxSpLast, div.MsoListParagraphCxSpLast
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.5in;
	margin-bottom:.0001pt;
	font-size:10.0pt;
	font-family:"Times New Roman","serif";}
span.Heading1Char
	{mso-style-name:"Heading 1 Char";
	mso-style-link:"Heading 1";
	font-family:"Univers Bold","serif";
	font-weight:bold;}
span.Heading2Char
	{mso-style-name:"Heading 2 Char";
	mso-style-link:"Heading 2";
	font-family:"Univers","sans-serif";}
span.Heading3Char
	{mso-style-name:"Heading 3 Char";
	mso-style-link:"Heading 3";
	font-family:"Univers","sans-serif";}
span.Heading4Char
	{mso-style-name:"Heading 4 Char";
	mso-style-link:"Heading 4";
	font-family:"Univers","sans-serif";}
span.BalloonTextChar
	{mso-style-name:"Balloon Text Char";
	mso-style-link:"Balloon Text";
	font-family:"Tahoma","sans-serif";}
p.Legal2L3, li.Legal2L3, div.Legal2L3
	{mso-style-name:Legal2_L3;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:12.0pt;
	margin-left:0in;
	text-align:justify;
	text-autospace:none;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.Legal2L1, li.Legal2L1, div.Legal2L1
	{mso-style-name:Legal2_L1;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:12.0pt;
	margin-left:0in;
	text-align:justify;
	text-autospace:none;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
span.11
	{mso-style-name:"1\.1";
	font-weight:bold;
	text-decoration:underline;}
.MsoChpDefault
	{font-size:10.0pt;
	font-family:"Calibri","sans-serif";}
@page WordSection1
	{size:595.3pt 841.9pt;
	margin:7.1pt 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
 /* List Definitions */
 ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
-->
</style>

</head>
<body lang=EN-US link=blue vlink=purple>

<div class=WordSection1>

<p class=MsoNormal>&nbsp;</p>

<p class=MsoNormal>&nbsp;</p>

<p class=MsoNormal align=center style=''text-align:center;line-height:115%;
text-autospace:none''><span style=''font-size:14.0pt;line-height:115%;font-family:
"Arial","sans-serif";letter-spacing:1.0pt''>iRely Software License
and Services Agreement</span></p>

<p class=MsoNormal>&nbsp;</p>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>1.<span
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>CERTAIN DEFINITIONS</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.25in;
margin-bottom:.0001pt;text-indent:0in''><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>As used in this Agreement, the following
terms have the following meanings:</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.1 &quot;<u>Affiliate</u>&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means, with respect
to a specified Person, any Person which directly or indirectly controls, is
controlled by, or is under common control with the specified Person as of the
date of this Agreement, for as long as such relationship remains in effect.</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.2<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>&quot;<u>Confidential
Information</u>&quot;</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
means all business information disclosed by one party to the other in
connection with this Agreement unless it is or later becomes publicly available
through no fault of the other party or it was or later is rightfully developed
or obtained by the other party from independent sources free from any duty of
confidentiality. Without limiting the generality of the foregoing, Confidential
Information will include Customer''s data and the details of Customer''s computer
operations and will also include Proprietary Items of iRely. Confidential
Information will also include the terms of this Agreement and the Proposal, but
not the fact that this Agreement has been signed, the identity of the parties
hereto or the identity of the products licensed under this Agreement.</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.3<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''><u>Documentation</u></span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means iRely''s
written specifications for the Software, in the form provided by iRely to
Customer.</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.4<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>&quot;<u>including</u>&quot;</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means including but
not limited to.</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456629882"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.5<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>&quot;<u>Person</u>&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means any
individual, sole proprietorship, joint venture, partnership, corporation,
company, firm, association, cooperative, trust, estate, government,
governmental agency, regulatory authority or other entity of any nature.</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.6<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>&quot;<u>Proprietary
Items</u>&quot;</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
means, collectively, the Software and Documentation, the object code and the
source code for the Software, the visual expressions, screen formats, report
formats and other design features of the Software, all ideas, methods,
algorithms, formulae and concepts used in developing and/or incorporated into
the Software or Documentation, all future modifications, revisions, updates,
releases, refinements, improvements and enhancements of the Software or
Documentation, all derivative works (as such term is used in the U.S. copyright
laws) based upon any of the foregoing and all copies of the foregoing.</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.7<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''><u>Software</u></span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means the iRely
software identified in the Proposal, including all interfaces supplied by iRely
hereunder.</span></h3>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:0in''><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>&nbsp;</span></h1>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>2.<span
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>LIMITED LICENSE</span></h1>

<p class=MsoNormal>&nbsp;</p>

<p class=MsoListParagraphCxSpFirst style=''text-align:justify;text-indent:-.25in''><b><span
style=''font-family:"Arial","sans-serif"''>2.1<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-family:"Arial","sans-serif"''>Grant.</span></b><a name="_Ref456625895"></a><a
name=DESIGNATED></a><a name=DC></a><a name=DL></a><span style=''font-family:
"Arial","sans-serif"''>iRely hereby grants to Customer a personal,
non-transferable (except as provided herein), non-exclusive, limited-scope
license to use, in accordance with this Agreement, one (1) copy of the Software
on one (1) server, and to create </span><span style=''font-family:"Arial","sans-serif"''>one
(1) copy of the Software solely for archival purposes, as the Software may be
modified, revised and updated in accordance with this Agreement.</span></p>

<p class=MsoListParagraphCxSpLast style=''margin-left:.75in''><span
style=''font-family:"Arial","sans-serif"''>&nbsp;</span></p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif";letter-spacing:-.1pt''>2.2<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Scope. </span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Customer may use the
Software and Documentation only in the ordinary course of its busine</span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>ss operations and for
its own business purposes. <span style=''letter-spacing:-.1pt''>The Software will
be installed and used only at Customer''s location(s) and by the number of users
specified in</span> the Proposal<span style=''letter-spacing:-.1pt''>.</span></span></h2>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:0in''><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif";letter-spacing:-.1pt''>&nbsp;</span></h2>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>2.3<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Users</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>. Logins must be
unique.&nbsp; Users cannot share login profiles.&nbsp; Each user must have a
unique user login in order to access the system<a name="_GoBack"></a>.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.25in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><span
style=''font-size:10.0pt''>3.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>DELIVERY,
SUPPORT AND PROFESSIONAL SERVICES</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><a name="_Ref458513499"></a><a
name=INSTALLATION></a><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>3.1 Delivery.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> iRely will deliver
to Customer a copy of the Software and Documentation on or before the date
specified in the Proposal, or if no specific date is provided in the Proposal,
within a commercially reasonable </span><a name="_Ref507473477"></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>time.</span></h2>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><a name="_Ref507473782"></a><a
name=TRAINING></a><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>3.2<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Maintenance and
Support Services.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
iRely will provide to Customer the Software maintenance and support services
set forth in the Proposal.</span><span style=''font-size:10.0pt;font-family:
"Arial","sans-serif"''> Such services will relate to the then current version
of the Software and the two (2) releases immediately preceding such current
release. iRely will use commercially reasonable efforts to support other older
releases, the time and materials rates specified in <u>Section 3.3</u> and
otherwise on the terms set forth in this Agreement. Customer must give 30
days written notice if they would no longer would like maintenance and support
service. iRely may adjust maintenance and support services by a cost of living
adjustment (COLA) on an annual basis. A COLA adjustment may be made to base
dues once a year when an assessment is performed.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref507473437"></a><a name=SGOBLIG></a><a name=SUPPORT></a><a
name=SERVICES></a><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>3.3<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Professional
Services. </span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>At
Customer''s reasonable request and subject to the availability of iRely''s
personnel, iRely will provide to Customer, in addition to the professional
services specified in the Proposal, additional installation, training,
consulting, custom modification programming, support relating to custom
modifications and other professional services </span><span style=''font-size:
10.0pt;font-family:"Arial","sans-serif"''>at iRely''s then current standard time
and materials rates.</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt''><span style=''font-size:10.0pt''>4.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>CUSTOMER''S
OTHER OBLIGATIONS</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.25in;
margin-bottom:.0001pt;text-indent:0in''><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>Customer will provide to iRely access to the
applicable Customer location(s) specified in the Proposal and to Customer''s
equipment, data and employees, and will otherwise cooperate with iRely, as
reasonably necessary for iRely to perform its obligations under this
Agreement. Customer will devote all equipment, facilities, personnel and other
resources reasonably necessary to (a) install and implement the Software; (b)
begin using the Software on a timely basis as contemplated by this Agreement;
and (c) satisfy any Customer requirements described in the Proposal. iRely
will not be responsible for any delays or additional fees and costs associated
with Customer''s failure to timely perform its obligations under this <u>Section
4</u>.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt''><a name="_Ref456468383"></a><a name=PAYMENTS></a><span
style=''font-size:10.0pt''>5.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>PAYMENTS</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><a name=ILF></a><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.1<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Fees Specified in the
Proposal.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
Customer will pay to iRely the Software license fees, services fees and other
fees as set forth in the Proposal and as and when specified in <u>Section 5.4</u>.</span></h2>

<p class=MsoNormal><span style=''font-family:"Arial","sans-serif"''>&nbsp;</span></p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><a name="_Ref456624976"></a><a
name="SERVICE_FEES"></a><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.2 Additional
Fees.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
If services beyond those specified in the Proposal are requested by Customer
pursuant to <u>Section 3.3</u> or otherwise under this Agreement, iRely will
quote such services and Customer will pay to iRely fees for such services at
the rates specified in such quote</span><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>. </span><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>Customer will promptly reimburse iRely for
all reasonable travel, lodging and per diem expenses incurred by iRely
personnel in connection with their performance of services hereunder. </span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><a name=REIMBURSE></a><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.3 Taxes.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> The fees and other
amounts payable by Customer to iRely under this Agreement do not include any
taxes of any jurisdiction that may be assessed or imposed upon the copies of
the Software and Documentation delivered to Customer, the license granted under
this Agreement or the services provided under this Agreement, or otherwise
assessed or imposed in connection with the transactions contemplated by this
Agreement, including sales, use, excise, value added, personal property,
export, import and withholding taxes, excluding only taxes based upon iRely''s
net income. Customer will directly pay any such taxes assessed against it, and
Customer will promptly reimburse iRely for any such taxes payable or
collectable by iRely.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>5.4<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Payment
Terms.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
All fees will be invoiced by iRely as and when incurred. All invoices will be
sent to Customer''s address for invoices stated in the Proposal. Payments may be
made by check to the iRely address listed on the invoice or by wiring the
invoice amount in accordance with the wiring instructions provided in writing
by iRely. Interest at the rate of eighteen percent (18%) per annum (or, if
lower, the maximum rate permitted by applicable law) will accrue on any amount
not paid by Customer to iRely when due under this Agreement, and will be
payable by Customer to iRely on demand. All fees and other amounts paid by
Customer under this Agreement are non-refundable<a name="W_L"></a>.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<p class=Legal2L3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:.5in;margin-bottom:.0001pt;text-indent:-.25in''><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.5<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Audit.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> iRely or its
representatives may inspect and audit Customer''s servers and facilities to
determine Customer''s compliance with the Software license limitations set forth
in <u>Section 2</u> and otherwise provided in this Agreement. If iRely
determines that a noncompliance has occurred, in addition to iRely''s other
remedies, Customer will promptly pay iRely all additional software license and
service fees due iRely, together with all reasonable out-of-pocket costs and
expenses of such audit.</span></p>

<p class=Legal2L3 style=''margin-bottom:0in;margin-bottom:.0001pt''><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>&nbsp;</span></p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.6<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Certain Remedies for
Nonpayment.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
If Customer fails to pay to iRely, within ten (10) days after iRely makes
written demand therefor, any past-due amount payable under this Agreement
(including interest thereon) that is not the subject of a good faith dispute,
in addition to all other rights and remedies which iRely may have at law or in
equity, iRely may, in its sole discretion and without further notice to
Customer, suspend performance of any or all of its obligations under this
Agreement, and iRely will have no liability with respect to Customer''s use of
the Software until all past due amounts are settled. For the purposes of this
Agreement, a &quot;<u>good faith dispute</u>&quot; means a good faith dispute
by Customer of certain amounts invoiced under this Agreement. A good faith
dispute will be deemed to exist only if (a) Customer has given written notice
of the dispute to iRely promptly after receiving the invoice and (b) the notice
explains Customer''s position in reasonable detail. A good faith dispute will
not exist as to an invoice in its entirety merely because certain amounts on
the invoice have been disputed.</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.25in;
margin-bottom:.0001pt;text-indent:-.25in''><a name="_Ref507473844"><span
style=''font-size:10.0pt''>6.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>DISCLAIMERS,
EXCLUSIONS AND LIMITATIONS</span></a></h1>

<p class=MsoNormal><a name=PERFORMANCE></a><a name=INFRINGE></a>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>6.1<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Force
Majeure.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
Neither party will be liable for, nor will either party be considered in breach
of this Agreement due to, any failure to perform its obligations under this
Agreement (other than its payment obligations) as a result of a cause beyond
its control, including any act of God or a public enemy or terrorist, act of
any military, civil or regulatory authority, change in any law or regulation,
fire, flood, earthquake, storm or other like event, disruption or outage of
communications (including the Internet or other networked environment), power
or other utility, labor problem, unavailability of supplies, extraordinary
conditions or any other cause, whether similar or dissimilar to any of the
foregoing, which could not have been prevented by the non-performing party with
reasonable care.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>6.2<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Disclaimer.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> The software,
documentation, services and other items provided to customer hereunder are as
is, and iRely makes no representations or warranties, oral or written, express
or implied, arising from course of dealing, course of performance, usage of
trade, quality of information, quiet enjoyment or otherwise, including implied
warranties of merchantability, fitness for a particular purpose, title,
non-interference, or non-infringement with respect to the software, documentation
or services provided under this agreement or with respect to any other matter
pertaining to this agreement. Customer''s use of the software or services
provided under this agreement shall not be deemed legal, tax or investment
advice.</span></h2>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>6.3<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Limitations.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> iRely''s total
liability under this agreement will under no circumstances exceed the amount
actually paid by customer to iRely under this agreement during the twelve (12)
months prior to the event of liability, less all amounts paid by iRely to
customer under or in connection with this agreement. </span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>6.4<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Consequential
damage exclusion</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>.
Under no circumstances will iRely (or any iRely affiliates providing software
or services under this agreement) be liable to customer or any other person for
lost revenues, lost profits, loss of business, trading losses, or any
incidental, indirect, exemplary, consequential, special or punitive damages of
any kind, including such damages arising from any breach of this agreement or
any termination of this agreement, whether such liability is asserted on the
basis of contract, tort (including negligence or strict liability) or otherwise
and whether or not foreseeable, even if iRely has been advised or was aware of
the possibility of such loss or damages.</span></h2>

<p class=MsoNormal><span style=''font-family:"Arial","sans-serif"''>&nbsp;</span></p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>6.5<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Open
negotiation</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>.
Customer and iRely have freely and openly negotiated this agreement and the
proposal, including the pricing, with the knowledge that the liability of iRely
is to be limited in accordance with the provisions of this agreement.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>6.6<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Other
Limitations. </span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>In
addition to the other limitations and exclusions under this Agreement<b>, </b>iRely
shall have no liability to Customer under the following circumstances: Customer
fails to follow iRely''s instructions relating to the Software; the Software is
used in violation of this Agreement; the Software is configured, customized,
installed or maintained by anyone other than iRely; Customer modifies the
Software without the prior written consent of iRely; and/or the Software is
used in conjunction with any hardware, software, products or interfaces not
specified by iRely. The obligations of iRely under this Agreement run only to
Customer and not to its Affiliates or any other Persons. Under no circumstances
will any Affiliate or customer of Customer or any other Person be considered a
third-party beneficiary of this Agreement or otherwise entitled to any rights
or remedies under this Agreement, even if such Affiliates, customers or other
Persons are provided access to the Software or data maintained in the
Software. Customer will have no rights or remedies against iRely except as
specifically provided in this Agreement. No action or claim of any type
relating to this Agreement may be brought or made by Customer more than one (1)
year after Customer first has knowledge of the basis for the action or claim.</span></h2>

<h1 style=''margin-left:.25in;text-indent:-.25in''><a name=RESTRICTIONS></a><span
style=''font-size:10.0pt''>7.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>CONFIDENTIALITY
AND OWNERSHIP</span></h1>

<h2 style=''margin-left:.5in;text-indent:-.25in''><a name="_Ref26671589"></a><a
name=NONDISCLOSE></a><a name=TERMINATION></a><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>7.1<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Confidential
Information.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
During the term of this Agreement and in perpetuity thereafter, each party
shall keep in confidence all of the Confidential Information of the other
party, and shall not use such Confidential Information of the other party
without such other party''s prior written consent. No party shall disclose the
Confidential Information of any other party to any Person, except to its own
employees, agents and independent contractors to whom it is necessary to
disclose the Confidential Information for the sole purpose of performing their
duties and/or exercising their rights under this Agreement, and who have agreed
to receive it under terms at least as restrictive as those specified in this
Agreement. Each party shall maintain the confidentiality of the Confidential
Information, with not less than the standard of care that an ordinarily prudent
business would exercise to maintain the secrecy of its own most confidential
information. Each party shall immediately give notice to the other party of any
unauthorized use or disclosure of any Confidential Information. Each party
agrees to assist the other party in remedying such unauthorized use or
disclosure of Confidential Information. Upon either party''s request, the other
party shall return all copies of Confidential Information and proprietary
materials or information, and all copies and notes made thereof, received from
hereunder, or destroy all Confidential Information and copies and notes made
thereof, and provide a certification in writing to such effect.</span></h2>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>7.2<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Proprietary
Items and Ownership.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
The Proprietary Items are trade secrets and proprietary property of iRely,
having great commercial value to iRely. All Proprietary Items provided to
Customer under this Agreement are being provided on a strictly confidential and
limited use basis. Customer will not, directly or indirectly, communicate,
publish, display, loan, give or otherwise disclose any Proprietary Item to any
Person, or permit any Person to have access to or possession of any Proprietary
Item. Title to all Proprietary Items and all related patent, copyright,
trademark, trade secret, intellectual property and other ownership rights will
be and remain exclusively with iRely, even with respect to such items that were
created by iRely specifically for or on behalf of Customer. This Agreement is
not an agreement of sale, and no title, patent, copyright, trademark, trade
secret, intellectual property or other ownership rights to any Proprietary
Items are transferred to Customer by virtue of this Agreement. All copies of
Proprietary Items in Customer''s possession will remain the exclusive property
of iRely and will be deemed to be on loan to Customer during the term of this
Agreement.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif";letter-spacing:-.1pt''>7.3<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Use Restrictions.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer will not
do, attempt to do, nor permit any other Person to do, any of the following:
(a) use any Proprietary Item for any purpose, at any location or in any manner
not specifically authorized by this Agreement; (b) <span style=''letter-spacing:
-.1pt''>make or retain any copy of any Proprietary Item except as specifically
authorized by this Agreement; (c) create or recreate the source code for the
Software, or re-engineer, reverse engineer, decompile or disassemble the
Software; (d) modify, adapt, translate or create derivative works based upon
the Software or Documentation, or combine or merge any part of the Software or
Documentation with or into any other software or documentation; (e) refer to or
otherwise use any Proprietary Item as part of any effort either to develop a
program having any functional attributes, visual expressions or other features
similar to those of the Software or to compete with iRely or its Affiliates;
(f) remove, erase or tamper with any copyright or other proprietary notice
printed or stamped on, affixed to, or encoded or recorded in any Proprietary
Item, or fail to preserve all copyright and other proprietary notices in any
copy of any Proprietary Item made by Customer; or (g) sell, market, license,
sublicense, distribute or otherwise grant to any Person, including any
outsourcer, vendor, consultant or partner, any right to use any Proprietary
Item, whether on Customer''s behalf or otherwise.</span></span></h2>

<p class=MsoListParagraph style=''margin-left:.75in''>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>7.4<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Notice
and Remedy of Breaches.</span></b><span style=''font-size:10.0pt;font-family:
"Arial","sans-serif"''> Each party will promptly give written notice to the
other of any actual or suspected breach by it of any of the provisions of this <u>Section
7</u>, whether or not intentional, and the breaching party will, at its
expense, take all steps reasonably requested by the other party to prevent or
remedy the breach.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>7.5<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Enforcement.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Each party acknowledges
that the restrictions in this Agreement are reasonable and necessary to protect
the other''s legitimate business interests. Each party acknowledges that any
breach of any of the provisions of this <u>Section 7</u> will result in
irreparable injury to the other for which money damages could not adequately
compensate. If there is a breach, then the injured party will be entitled, in
addition to all other rights and remedies which it may have at law or in
equity, to have a decree of specific performance or an injunction issued by any
competent court, requiring the breach to be cured or enjoining all Persons
involved from continuing the breach. The existence of any claim or cause of
action that a party or any other Person may have against the other party will
not constitute a defense or bar to the enforcement of any of the provisions of
this <u>Section 7</u>.</span></h2>

<h1 style=''margin-left:.25in;text-indent:-.25in''><span style=''font-size:10.0pt''>8.<span
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>TERM AND TERMINATION</span></h1>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>8.1 Term. </span></b><span style=''font-size:
10.0pt;font-family:"Arial","sans-serif"''>The term of this Agreement begins on
the date set forth on the first page hereof and continues until terminated in
accordance with <u>Sections 8.2</u> or <u>8.3</u>, as the case may be.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>8.2 Termination by Customer. </span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Customer may
immediately terminate this Agreement, by giving written notice of termination
to iRely, upon the occurrence of any of the following events: (a) iRely
breaches any of its material obligations under this Agreement and does not cure
the breach within sixty (60) days (provided that the breach is susceptible to
cure) after Customer gives written notice to iRely describing the breach in
reasonable detail; or (b) iRely dissolves or liquidates or otherwise
discontinues all or a significant part of its business operations.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>8.3<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Termination
by iRely.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
iRely may immediately terminate this Agreement and the license granted
hereunder, by giving written notice of termination to Customer, upon the
occurrence of any of the following events: (a) Customer fails to pay to iRely,
within ten (10) days after iRely makes written demand therefor, any past-due
amount payable under this Agreement (including interest thereon) that is not
the subject of a good faith dispute; (b) Customer breaches any of its other
material obligations under this Agreement and does not cure the breach within
thirty (30) days (provided that the breach is susceptible to cure) after iRely
gives written notice to Customer describing the breach in reasonable detail; or
(c) Customer dissolves or liquidates or otherwise discontinues all or a
significant part of its business operations.</span></h2>

<p class=MsoListParagraph style=''margin-left:.75in''>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><a name="_Ref26671621"><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>8.4<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Effect of
Termination.</span></b></a><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Upon a
termination of this Agreement, whether under this Section 8 or otherwise,
Customer will: (a) discontinue all use of all affected Software and
Documentation; (b) promptly return to iRely all copies of the Software and
Documentation and all other Proprietary Items then in Customer''s possession;
and (c) give written notice to iRely certifying that all copies of the Software
and Documentation have been permanently deleted from Customer''s computers.
Customer will remain liable for all payments due to iRely with respect to the
period ending on the date of termination. The provisions of <u>Sections</u> <u>5</u>,
<u>6</u>, <u>7</u>, <u>8.4</u> and <u>9</u> will survive any termination of
this Agreement, whether under this <u>Section 8</u> or otherwise. </span></h2>

<h1 style=''margin-left:.25in;text-indent:-.25in''><a name="_Ref456628820"><span
style=''font-size:10.0pt''>9.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>OTHER
PROVISIONS</span></a></h1>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><a name=NOTICE></a><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.1 Notices.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> All notices,
consents and other communications under or regarding this Agreement will be in
writing and will be deemed to have been received on the earlier of the date of
actual receipt, the third business day after being mailed by first class
certified air mail or the first business day after being sent by a reputable
overnight delivery service. Any notice may be given by facsimile, provided
that a signed written original is sent by one of the foregoing methods within
twenty-four (24) hours thereafter. Customer''s address for notices is stated in
the Proposal. iRely''s address for notices is </span><span style=''font-size:
10.0pt;font-family:"Arial","sans-serif"''>4242 Flagstaff Cove, Fort Wayne, IN
46815 USA, <span style=''letter-spacing:-.1pt''>Attention: Contract
Administration. In the case of (a) any notice by Customer alleging a breach of
this Agreement by iRely or (b) a termination of this Agreement, Customer will
also send a copy to iRely, attention: COO. Either party may change its address
for notices by giving written notice of the new address to the other party in
accordance with this <u>Section 9.1</u>.</span></span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><a name="_Ref456447207"></a><a
name=PARTIES></a><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.2<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></b><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Parties in Interest</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>. </span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>This Agreement will
bind, benefit and be enforceable by and against iRely and Customer and, to the
extent permitted hereby, their respective successors and assigns. </span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Customer will not
assign this Agreement or any of its rights hereunder, nor delegate any of its
obligations hereunder, without iRely''s prior written consent, except that such
consent will not be required in the case of an assignment to (i) a purchaser of
or successor to substantially all of Customer''s business (unless such purchaser
or successor is a software, data processing or computer services vendor that is
a competitor of iRely or any of its Affiliates) or (ii) an Affiliate of
Customer, provided that the scope of the license granted under this Agreement
does not change and Customer guarantees the obligations of the assignee. Any
assignment by Customer in breach of this <u>Section 9.2</u> will be void. <a
name="_Ref456629348">Any express assignment of this Agreement, any change in
control of Customer, any acquisition of additional business by Customer (by
asset acquisition, merger or otherwise by operation of law) and any assignment
by merger or otherwise by operation of law, will constitute an assignment of
this Agreement by Customer for purposes of this <u><span style=''letter-spacing:
-.1pt''>Section </span></u></a><u><span style=''letter-spacing:-.1pt''>9.2</span></u>.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>9.3<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Relationship.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> The relationship
between the parties created by this Agreement is that of independent
contractors and not partners, joint venturers or agents.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>9.4<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Entire
Understanding; Counterparts.</span></b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''> This Agreement, which includes and
incorporates the Proposal and any other schedules, exhibits and addenda hereto,
states the entire understanding between the parties with respect to its subject
matter, and supersedes all prior proposals, marketing materials, negotiations
and other written or oral communications between the parties with respect to
the subject matter of this Agreement. This Agreement may be executed in one or
more counterparts, each of which will be deemed an original and all of which
together will constitute one and the same instrument. If this Agreement is
executed via facsimile, each party hereto will provide the other party with an
original executed signature page within five (5) days following the execution
of this Agreement.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>9.5<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Modification,
Waiver and Conflicts.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
No modification of this Agreement, and no waiver of any breach of this
Agreement, will be effective unless in writing and signed by an authorized
representative of the party against whom enforcement is sought. This Agreement
may not be modified or amended by electronic means without written agreement of
the parties with respect to formats and protocols. No waiver of any breach of
this Agreement, and no course of dealing between the parties, will be construed
as a waiver of any subsequent breach of this Agreement. In the event of any
conflict between this Agreement and the Proposal or any schedules to this
Agreement, the terms of this Agreement will govern.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>9.6<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Severability.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> A determination
that any provision of this Agreement is invalid or unenforceable will not
affect the other provisions of this Agreement.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>9.7<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Headings.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Section headings are
for convenience of reference only and will not affect the interpretation of
this Agreement.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-.25in''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>9.8<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><span class=11><span style=''font-size:10.0pt;font-family:
"Arial","sans-serif"''>Negotiated Terms. </span></span><span style=''font-size:
10.0pt;font-family:"Arial","sans-serif"''>The parties agree that the terms and
conditions of this Agreement are the result of negotiations between the parties
and that this Agreement will not be construed in favor of or against any party
by reason of the extent to which any party or its professional advisors
participated in the preparation of this Agreement.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-22.5pt''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>9.9<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Non-Solicitation.</span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer shall not,
directly or through one or more subsidiaries or other controlled entities, hire
or offer to hire any programmer, trainer or member of a data processing or
customer support team of iRely at any time when such Person is employed or
engaged by iRely or during the twelve (12) months after such employment or
engagement ends. For purposes of this provision, hire means to employ as an
employee or to engage as an independent contractor, whether on a full-time,
part-time or temporary basis. This provision will remain in effect during the
term of this Agreement and for a period of one (1) year after expiration or
termination of this Agreement</span>.</h2>

<p class=Legal2L1 style=''margin-bottom:0in;margin-bottom:.0001pt''><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>&nbsp;</span></p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-22.5pt''><b><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>9.10<span style=''font:7.0pt "Times New Roman"''>&nbsp;
</span></span></b><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Governing
Law and Jurisdiction.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>
This agreement will be construed and enforced in accordance with the laws of
the state of Indiana, usa, excluding choice of law</span><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>. </span></b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>In any action
relating to this Agreement, (a) each of the parties irrevocably consents to the
exclusive jurisdiction and venue of the federal and state courts located in the
State of Indiana, (b) each of the parties irrevocably waives the right to trial
by jury, (c) each of the parties irrevocably consents to service of process by
first class certified mail, return receipt requested, postage prepaid, to the
address at which the party is to receive notice hereunder and (d) the
prevailing party will be entitled to recover its reasonable attorney''s fees
(including, if applicable, charges for in-house counsel), court costs and other
legal expenses from the other party.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-indent:-22.5pt''><span class=11><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif";text-decoration:none''>9.11<span
style=''font:7.0pt "Times New Roman"''>&nbsp; </span></span></span><b><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Export Laws;
Restricted Rights.</span></b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>Customer
will comply with all applicable United States export laws and regulations.
Customer will not export or re-export directly or indirectly (including via
remote access) any part of the Software or any Proprietary Items or Confidential
Information to any jurisdiction outside the United States. <span class=11>If
Customer is an agency of the U.S. Government, the Software is provided with
Restricted Rights and that its use, duplication or disclosure is governed by
DFARS 252.227-7103 (c)(1)(ii) or FAR 52.227-19m, as applicable.</span></span></h2>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:0in''>&nbsp;</h1>

</div>

</body>

</html>
')
END

GO