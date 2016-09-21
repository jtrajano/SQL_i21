GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMEULA WHERE strVersionNumber = '15.4' AND strText like '%EVALUATION AGREEMENT%')
BEGIN
	DELETE FROM tblSMEULA WHERE strVersionNumber = '15.4'
END

GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMEULA WHERE strVersionNumber = '15.4')
BEGIN
INSERT INTO tblSMEULA(strVersionNumber, strText)
VALUES ('15.4', N'<!DOCTYPE html>
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
font-family:"Arial","sans-serif"''>As used in this Agreement, the following terms have the following meanings:</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.1 &quot;Affiliate&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means, with respect to a specified Person, any Person which directly or 
indirectly controls, is controlled by, or is under common control with the 
specified Person as of the date of this Agreement, for as long 
as such relationship remains in effect. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.2 &quot;Authorized User&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means, with respect to a Customer electing SaaS Services under the Proposal, 
Customer’s account administrator or employees, representatives, consultants, contractors, agents and any third 
party to whom the Customer gives permission to access the  SaaS 
Services via user identification and password combination or any method requiring authentication 
of an individual’s identity. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.3 &quot;Confidential Information&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means all business information disclosed by one party to the other in 
connection with this Agreement unless it is or later becomes publicly available 
through no fault of the other party or it was or later 
is rightfully developed or obtained by the other party from independent sources 
free from any duty of confidentiality. Without limiting the generality of the 
foregoing, Confidential Information will include Customer''s data and the details of Customer''s 
computer operations and will also include Proprietary Items of iRely.  Confidential 
Information will also include the terms of this Agreement and the Proposals, 
but not the fact that this Agreement has been signed, the identity 
of the parties hereto or the identity of the products licensed or 
services provided under this Agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.4 &quot;Documentation&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means iRely’s written specifications for the Software, in the form provided by 
iRely to Customer. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.5 &quot;Hosting Services&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means, for a Customer electing iRely-Hosted Software services under the Proposal, the 
hosting services by which iRely provides access to and use of the 
Software from a hosting network, as may be further described in the 
Proposal. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.6 &quot;including&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means including but not limited to. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.7 &quot;Person&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means any individual, sole proprietorship, joint venture, partnership, corporation, company, firm, association, 
cooperative, trust, estate, government, governmental agency, regulatory authority or other entity of 
any nature. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.8 &quot;Professional Services&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means, collectively, the support and professional services provided by iRely under this 
Agreement, including all installation, training, consulting, custom modification programming, support relating to 
custom modification programming and other professional services, as applicable, specified in applicable 
Proposals and otherwise as provided under this Agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.9 &quot;Proposals&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means, collectively, the initial Proposal from iRely to Customer, as executed by 
iRely and Customer and as such describes the type of service (Customer-Installed 
Software, iRely-Hosted Software, or SaaS services) provided to Customer; all other mutually 
agreeable written quotes, proposals and statements of work issued under this Agreement; 
and all other Customer requests for Professional Services, whether oral or written, 
to the extent such are accepted by iRely. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.10 &quot;Proprietary Items&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means, collectively, the Software and Documentation, all deliverables provided as a result 
of or in connection with this Agreement, the object code and the 
source code for the Software, the visual expressions, screen formats, report formats 
and other design features of the Software, all development tools and methodologies 
used in connection with the Software, SaaS Services and Professional Services, as 
applicable, all ideas, methods, algorithms, formulae and concepts used in developing and/or 
incorporated into the Software, Documentation or deliverables provided as a result of 
or in connection with this Agreement, all future modifications, revisions, updates, releases, 
refinements, improvements and enhancements of the Software, Documentation or deliverables provided as 
a result of or in connection with this Agreement, all derivative works 
(as such term is used in the U.S. copyright laws) based upon 
any of the foregoing and all copies of the foregoing. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.11 &quot;SaaS Services&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means, for a Customer electing SaaS Services under the Proposal the services 
by which iRely provides access to and use of the Software from 
a hosting network, as may be further described in the Proposal. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>1.12 &quot;Software&quot;</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> means, collectively, the iRely software identified in the Proposal, including all applicable 
interfaces supplied by iRely hereunder, and all applicable additional iRely and third-party 
software identified in the Proposal and made available by iRely hereunder, such 
additional software subject to the terms of this Agreement and applicable written 
software license agreement(s) third-party vendors, as the case may be. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>2.<span 
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>LICENSE AND SOFTWARE SERVICES</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>2.1 Grant of License.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> If Customer will have  elected under the Proposal the Customer-Installed Software 
or iRely-Hosted Software options, as applicable, iRely hereby grants to Customer a 
personal, non-transferable (except as provided herein), non-exclusive, limited-scope license to use, in 
accordance with this Agreement, one (1) copy of the Software on one 
(1) server, and to create one (1) copy of the Software solely 
for archival purposes, as the Software may be periodically modified, revised and 
updated in accordance with this Agreement. Customer may use the Software and 
Documentation only in the ordinary course of its business operations and for 
its own business purposes. The Software will be installed and used only 
at Customer’s location(s) and by the number of users specified in the 
Proposal. If Customer will previously have been issued by iRely a license 
for the Software and has requested the iRely-Hosted Software service option under 
the Proposal, the license granted hereunder will replace the previously granted license. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>2.2 Hosting Services.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> If Customer will have elected the iRely-Hosted Software services option under the 
Proposal, in addition to the license granted by iRely under Section 2.1, 
iRely hereby grants Customer a subscription to receive the Hosting Services in 
accordance with the terms and conditions of this Agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>2.3 SaaS Services.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> If Customer will have elected the SaaS Services option under the Proposal, 
iRely hereby grants Customer a subscription to receive the SaaS Services in 
accordance with the terms and conditions of this Agreement.  Customer may 
use the SaaS Services only in the ordinary course of its business 
operations and for its own business purposes. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>2.4 Authorized Users.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer is responsible for the compliance by all Authorized Users with this 
Agreement and for all use of Authorized User accounts and confidentiality of 
passwords. Customer will promptly notify iRely in the event that an Authorized 
User’s password has been lost, stolen or otherwise compromised.  Customer will 
use commercially reasonable efforts to prevent unauthorized access to or use of 
the Hosting Services or SaaS Services, as applicable, and will notify iRely 
promptly of any such unauthorized access or use.  The numbers and 
location of Authorized Users may be limited in the applicable Proposals. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>3.<span 
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>DELIVERY, SUPPORT AND PROFESSIONAL SERVICES</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>3.1 Delivery.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> If Customer will have elected the Customer-Installed Software option under the Proposal, 
iRely will deliver to Customer a copy of the Software and Documentation 
on or before the date specified in the Proposal, or if no 
specific date is provided in the Proposal, within a commercially reasonable time. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>3.2 Maintenance and Support Services.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> If Customer will have elected, as applicable, the Customer-Installed Software or iRely-Hosted 
Software service options under the Proposal, iRely will provide to Customer the 
Software maintenance and support Services set forth in the Proposal.  Such 
Services will relate to the then current version of the Software and 
the two (2) releases immediately preceding such current release.  iRely will 
use commercially reasonable efforts to support other older Software release at iRely’s 
then current time and materials rates and otherwise on the terms set 
forth in this Agreement.  If Customer will have elected the SaaS 
Services option under the Proposal, iRely shall use commercially reasonable efforts to 
investigate problems with the SaaS Services reported by Customer. If iRely determines 
that the SaaS Services problem is the result of a material reproducible 
error, defect, or malfunction in the SaaS Services, and such problem represents 
a material nonconformance with iRely’s specifications for the SaaS Services, iRely will 
make commercially reasonable efforts to correct the problem. An iRely representative will 
provide Customer with a correction, a report/determination that further research is required, 
or confirmation that the SaaS Services work in accordance with iRely specifications. 
 Maintenance and SaaS services will be adjusted annually for yearly escalation 
of costs.  The yearly annual increase will typically be about 2.5% 
per year, but this may fluctuate depending on economic factors. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>3.3 Professional Services.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> In addition to iRely’s Services under Section 3.2, at Customer''s reasonable request, 
iRely will provide installation, training, consulting, custom modification programming, support relating to 
custom modifications and other Professional Services, as and when described in applicable 
Proposals and at the fees and on the other terms and conditions 
set forth in such Proposals.  All such Proposals will be subject 
to the terms and conditions of this Agreement.  Service rates may 
increase yearly based on market conditions and the cost/value of billable time. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>3.4 Acceptance.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Applicable Software deliverables under all Proposals will be accepted by Customer when 
the acceptance criteria, if any, specified in applicable Proposals have been met. 
 Where no Software acceptance criteria are specified, such deliverables will be 
deemed accepted upon the earlier of:  (a) thirty (30) days after 
delivery to Customer, provided that Customer does not notify iRely of any 
material defects in such deliverables; or (b) the date upon which such 
deliverables are used in production by Customer.  SaaS Services and Hosting 
Services will be deemed accepted upon use in production by Customer. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>3.5 Other Terms of Services.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> All subsequent Proposals will include the following items:  (a) a description 
of the Professional Services and other services to be performed; (b) any 
deliverables and/or milestones; (c) the tasks and resources Customer will provide; and 
(d) pricing and payment terms.  Customer will not engage or use 
any non-iRely personnel in connection with any Professional Services, other than Customer 
personnel reasonably required in connection with such Professional Services, without the prior 
written consent of iRely. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>4.<span 
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>CUSTOMER''S OTHER OBLIGATIONS</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h2 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.25in; 
margin-bottom:.0001pt;text-indent:0in''><span style=''font-size:10.0pt;
font-family:"Arial","sans-serif"''>Customer will cooperate with iRely as reasonably necessary for iRely to perform its obligations under this Agreement.  Customer will devote all equipment, facilities, personnel and other resources identified in the Proposals or otherwise reasonably required to install, implement and use the Customer-Installed Software and to implement and use the iRely-Hosted Software services.  iRely will not be responsible for any delays or additional fees and costs associated with Customer’s failure to timely perform its obligations under this Section 4.</span></h2>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>5.<span 
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>PAYMENTS</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.1 Fees Specified in the Proposals.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer will pay to iRely, as applicable, the Software license fees, Hosting 
Services subscription fees, SaaS Services subscription fees, Professional Services fees and other 
fees as set forth in applicable Proposals and as and when specified 
in Section 5.4. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.2 Additional Fees.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Unless otherwise expressly provided in applicable Proposals, Professional Services fees will be 
billable to Customer at iRely’s then current standard time and materials rates. 
 Customer will promptly reimburse iRely for all reasonable travel, lodging and 
per diem expenses incurred by iRely personnel in connection with their performance 
of the Professional Services. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.3 Taxes.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> The fees and other amounts payable by Customer to iRely under this 
Agreement do not include any taxes of any jurisdiction that may be 
assessed or imposed in connection with the services provided hereunder and, as 
applicable, upon the copies of the Software and Documentation delivered to Customer, 
the license granted under this Agreement and the services provided hereunder, or 
any taxes otherwise assessed or imposed in connection with the transactions contemplated 
by this Agreement, including sales, use, excise, value added, personal property, export, 
import and withholding taxes, excluding only taxes based upon iRely''s net income. 
 Customer will directly pay any such taxes assessed against it, and 
Customer will promptly reimburse iRely for any such taxes payable or collectable 
by iRely. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.4 Payment Terms.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> All fees will be invoiced by iRely as and when incurred.  
All invoices will be sent to Customer''s address stated on the first 
page of this Agreement, unless otherwise agreed by the parties. Payments will 
be made by automated clearing house (ACH) electronic funds transfer in accordance 
with ACH instructions provided in writing by iRely. Interest at the rate 
of eighteen percent (18%) per annum (or, if lower, the maximum rate 
permitted by applicable law) will accrue on any amount not paid by 
Customer to iRely when due under this Agreement, and will be payable 
by Customer to iRely on demand. All fees and other amounts paid 
by Customer under this Agreement are non-refundable. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.5 Audit.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> iRely or its representatives may inspect and audit Customer’s servers and facilities 
to determine Customer’s compliance with the Software license and Authorized Users limitations 
set forth inSection 2 and otherwise provided in this Agreement.  If 
iRely determines that a noncompliance has occurred, in addition to iRely’s other 
remedies,  Customer will promptly pay iRely, as applicable, all additional software 
license and service fees due iRely, together with all reasonable out-of-pocket costs 
and expenses of such audit.  
5.6   Certain Remedies for 
Nonpayment.  If Customer fails to pay to iRely, within ten (10) 
days after iRely makes written demand therefor, any past-due amount payable under 
this Agreement (including interest thereon) that is not the subject of a 
good faith dispute, in addition to all other rights and remedies which 
iRely may have at law or in equity, iRely may, in its 
sole discretion and without further notice to Customer, immediately suspend all applicable 
SaaS Services, Hosting Services,  Professional Services and the performance of any 
or all of its other obligations under this Agreement, and iRely will 
have no liability with respect to Customer’s use of the applicable Software, 
SaaS Services, Hosting Services, Professional Services or other iRely services hereunder until 
all past due amounts are settled.  iRely reserves the right to 
impose a reconnection fee in the event Customer’s access to the SaaS 
Services is suspended and thereafter Customer requests renewed access to the SaaS 
Services. For the purposes of this Agreement, a “good faith dispute” means 
a good faith dispute by Customer of certain amounts invoiced under this 
Agreement.  A good faith dispute will be deemed to exist only 
if (a) Customer has given written notice of the dispute to iRely 
promptly after receiving the invoice and (b) the notice explains Customer''s position 
in reasonable detail.  A good faith dispute will not exist as 
to an invoice in its entirety merely because certain amounts on the 
invoice have been disputed. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>5.7 Marketing Material.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Our overall pricing has been discounted with the assumption that customers will 
allow use of their name on various announcements and marketing materials for 
iRely.  If Customer does not allow this activity, built-in price discount 
will be considered null and void and overall pricing will be higher. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>6.<span 
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>DISCLAIMERS, EXCLUSIONS AND LIMITATIONS</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>6.1 Force Majeure.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Neither party will be liable for, nor will either party be considered 
in breach of this Agreement due to, any failure to perform its 
obligations under this Agreement (other than its payment obligations) as a result 
of a cause beyond its control, including any act of God or 
a public enemy or terrorist, act of any military, civil or regulatory 
authority, change in any law or regulation, fire, flood, earthquake, storm or 
other like event, disruption or outage of communications (including the Internet or 
other networked environment), power or other utility, labor problem, unavailability of supplies, 
extraordinary conditions or any other cause, whether similar or dissimilar to any 
of the foregoing, which could not have been prevented by the non-performing 
party with reasonable care. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>6.2 Disclaimer.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> THE SOFTWARE, HOSTING SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND 
SERVICES PROVIDED TO CUSTOMER HEREUNDER ARE “AS IS”, AND iRELY MAKES NO 
REPRESENTATIONS OR WARRANTIES, ORAL OR WRITTEN, EXPRESS OR IMPLIED, ARISING FROM COURSE 
OF DEALING, COURSE OF PERFORMANCE, USAGE OF TRADE, QUALITY OF INFORMATION, QUIET 
ENJOYMENT OR OTHERWISE, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
PURPOSE, TITLE, NON-INTERFERENCE, OR NON-INFRINGEMENT WITH RESPECT TO THE SOFTWARE, HOSTING SERVICES, 
SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND SERVICES PROVIDED TO CUSTOMER 
HEREUNDER OR WITH RESPECT TO ANY OTHER MATTER PERTAINING TO THIS AGREEMENT. 
CUSTOMER’S USE OF THE SOFTWARE, HOSTING SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND 
OTHER GOODS AND SERVICES PROVIDED TO CUSTOMER HEREUNDER WILL NOT BE DEEMED 
LEGAL, TAX OR INVESTMENT ADVICE. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>6.3 Limitations.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> iRELY''S TOTAL LIABILITY UNDER THIS AGREEMENT WILL UNDER NO CIRCUMSTANCES EXCEED THE 
AMOUNT ACTUALLY PAID BY CUSTOMER TO iRELY UNDER THIS AGREEMENT DURING THE 
THREE (3) MONTHS PRIOR TO THE EVENT OF LIABILITY, LESS ALL AMOUNTS 
PAID BY iRELY TO CUSTOMER UNDER OR IN CONNECTION WITH THIS AGREEMENT. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>6.4 Consequential Damage Exclusion.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> UNDER NO CIRCUMSTANCES WILL iRELY (OR ANY iRELY AFFILIATES PROVIDING SOFTWARE, HOSTING 
SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND SERVICES PROVIDED TO 
CUSTOMER HEREUNDER) BE LIABLE TO CUSTOMER, ANY AUTHORIZED USER OR ANY OTHER 
PERSON FOR LOST REVENUES, LOST PROFITS, LOSS OF BUSINESS, TRADING LOSSES, OR 
ANY INCIDENTAL, INDIRECT, EXEMPLARY, CONSEQUENTIAL, SPECIAL OR PUNITIVE DAMAGES OF ANY KIND, 
INCLUDING SUCH DAMAGES ARISING FROM ANY BREACH OF THIS AGREEMENT OR ANY 
TERMINATION OF THIS AGREEMENT, WHETHER SUCH LIABILITY IS ASSERTED ON THE BASIS 
OF CONTRACT, TORT (INCLUDING NEGLIGENCE OR STRICT LIABILITY) OR OTHERWISE AND WHETHER 
OR NOT FORESEEABLE, EVEN IF iRELY HAS BEEN ADVISED OR WAS AWARE 
OF THE POSSIBILITY OF SUCH LOSS OR DAMAGES. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>6.5 Interruptions and Delays.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer acknowledges that the Hosting Services and SaaS Services may be subject 
to limitations, delays, and other problems inherent in the use of the 
internet and electronic communications. iRely is not responsible for any delays, delivery 
failures, improper delivery, service interruptions or other damage resulting from such problems, 
including interruptions and delays due to planned and unscheduled maintenance. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>6.6 Open Negotiation.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer and iRely have freely and openly negotiated this Agreement and all 
Proposals, including the pricing, with the knowledge that the liability of iRely 
is to be limited in accordance with the provisions of this Agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>6.7 Freedom to Develop.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer acknowledges that iRely is engaged in the development of software for 
clients other than Customer, and that iRely can and will develop software 
and provide services for its other customers and will utilize and market 
Proprietary Items, including those developed under this Agreement, without any restrictions hereunder.6.8 
   Other Limitations.  In addition to the other limitations 
and exclusions under this Agreement, iRely will have no liability to Customer 
under the following circumstances:  Customer fails to follow iRely’s instructions relating 
to, as applicable, the Software, Hosting Services or SaaS Services; and/or the 
Software, Hosting Services or SaaS Services, as applicable, are used in violation 
of this Agreement; as applicable, the Software is configured, customized, installed or 
maintained by anyone other than iRely; as applicable, Customer modifies any Software 
without the prior written consent of iRely; and/or the Software, Hosting Services 
or SaaS Services are used in conjunction with any hardware, software, products 
or interfaces not specified by iRely.  The obligations of iRely under 
this Agreement run only to Customer and not to its Affiliates, Authorized 
Users or any other Persons. Under no circumstances will any Affiliate, Authorized 
User or client of Customer or any other Person be considered a 
third-party beneficiary of this Agreement or otherwise entitled to any rights or 
remedies under this Agreement, even if such Affiliates, Authorized Users, clients or 
other Persons are provided access to any Hosting Services, SaaS Services or 
Professional Services.  Customer will have no rights or remedies against iRely 
except as specifically provided in this Agreement. No action or claim of 
any type relating to this Agreement may be brought or made by 
Customer more than one (1) year after Customer first has knowledge of 
the basis for the action or claim. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>7.<span 
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>CONFIDENTIALITY AND OWNERSHIP</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>7.1 Confidential Information.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> During the term of this Agreement and in perpetuity thereafter, each party 
will keep in confidence all of the Confidential Information of the other 
party, and will not use such Confidential Information of the other party 
without such other party’s prior written consent.  No party will disclose 
the Confidential Information of any other party to any Person, except to 
its own employees, agents and independent contractors to whom it is necessary 
to disclose the Confidential Information for the sole purpose of performing their 
duties and/or exercising their rights under this Agreement, and who have agreed 
to receive it under terms at least as restrictive as those specified 
in this Agreement.  Each party will maintain the confidentiality of the 
Confidential Information, with not less than the standard of care that an 
ordinarily prudent business would exercise to maintain the secrecy of its own 
most confidential information. Each party will immediately give notice to the other 
party of any unauthorized use or disclosure of any Confidential Information.  
Each party agrees to assist the other party in remedying such unauthorized 
use or disclosure of Confidential Information.  Upon either party’s request, the 
other party will return all copies of Confidential Information and proprietary materials 
or information, and all copies and notes made thereof, received from hereunder, 
or destroy all Confidential Information and copies and notes made thereof, and 
provide a certification in writing to such effect. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>7.2 Proprietary Items and Ownership.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> The Proprietary Items are trade secrets and proprietary property of iRely, having 
great commercial value to iRely.  All Proprietary Items provided to Customer 
under this Agreement are being provided on a strictly confidential and limited 
use basis. Customer will not, directly or indirectly, communicate, publish, display, loan, 
give or otherwise disclose any Proprietary Item to any Person, or permit 
any Person to have access to or possession of any Proprietary Item. 
 Title to all Proprietary Items and all related patent, copyright, trademark, 
trade secret, intellectual property and other ownership rights will be and remain 
exclusively with iRely, even with respect to such items that were created 
by iRely specifically for or on behalf of Customer. This Agreement is 
not an agreement of sale, and no title, patent, copyright, trademark, trade 
secret, intellectual property or other ownership rights to any Proprietary Items are 
transferred to Customer by virtue of this Agreement.  All copies of 
Proprietary Items in Customer''s possession will remain the exclusive property of iRely 
and will be deemed to be on loan to Customer during the 
term of this Agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>7.3 Use Restrictions.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer will not do, attempt to do, nor permit any other Person 
to do, any of the following:  (a) use any Proprietary Item 
for any purpose, at any location or in any manner not specifically 
authorized by this Agreement; (b) make or retain any copy of any 
Proprietary Item except as specifically authorized by this Agreement; (c) create or 
recreate the source code for the Software, or re-engineer, reverse engineer, decompile 
or disassemble the Software; (d) modify, adapt, translate or create derivative works 
based upon the Software or Documentation, or combine or merge any part 
of the Software or Documentation with or into any other software or 
documentation; (e) refer to or otherwise use any Proprietary Item as part 
of any effort either to develop a program having any functional attributes, 
visual expressions or other features similar to those of the Software or 
to compete with iRely or its Affiliates; (f) remove, erase or tamper 
with any copyright or other proprietary notice printed or stamped on, affixed 
to, or encoded or recorded in any Proprietary Item, or fail to 
preserve all copyright and other proprietary notices in any copy of any 
Proprietary Item made by Customer; or (g) sell, market, license, sublicense, distribute 
or otherwise grant to any Person, including any outsourcer, vendor, consultant or 
partner, any right to use any Proprietary Item, whether on Customer''s behalf 
or otherwise. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>7.4 Notice and Remedy of Breaches.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Each party will promptly give written notice to the other of any 
actual or suspected breach by it of any of the provisions of 
this Section 7, whether or not intentional, and the breaching party will, 
at its expense, take all steps reasonably requested by the other party 
to prevent or remedy the breach. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>7.5 Enforcement.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Each party acknowledges that the restrictions in this Agreement are reasonable and 
necessary to protect the other''s legitimate business interests.  Each party acknowledges 
that any breach of any of the provisions of this Section 7 
will result in irreparable injury to the other for which money damages 
could not adequately compensate.  If there is a breach, then the 
injured party will be entitled, in addition to all other rights and 
remedies which it may have at law or in equity, to have 
a decree of specific performance or an injunction issued by any competent 
court, requiring the breach to be cured or enjoining all Persons involved 
from continuing the breach.  The existence of any claim or cause 
of action that a party or any other Person may have against 
the other party will not constitute a defense or bar to the 
enforcement of any of the provisions of this Section 7. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>8.<span 
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>TERM AND TERMINATION</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>8.1 Term.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> This Agreement, and Customer’s subscription to the Hosting Services or SaaS Services, 
as applicable, begins on the date set forth on the first page 
hereof and continues for the term specified in the initial Proposal.  
Upon expiration of such initial term, the term and Customer’s subscription for 
the Hosting Services or SaaS Services will renew for successive one (1) 
year renewal terms, unless either party delivers to the other written notice 
of termination at least ninety (90) days before expiration of the then 
current term. If Customer will have elected the Customer-Installed Software or iRely-Hosted 
Software options, as applicable, Customer’s Software license hereunder continues until terminated in 
accordance with this Agreement.  Either party may terminate this Agreement at 
any time in accordance with Sections 8.2 or 8.3, as the case 
may be.  The term of subsequent Proposals (i.e., Proposals other than 
the initial Proposal) continues until the Professional Services under such Proposals are 
deemed complete by iRely or until such Proposals are sooner terminated in 
accordance with Sections 8.2 or 8.3, as the case may be. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>8.2 Termination by Customer.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer may terminate any Professional Services under Proposals entered into after the 
date of this Agreement (i.e., Proposals other than the initial Proposal) for 
any reason upon thirty (30) days’ prior written notice to iRely.  
 Customer may immediately terminate this Agreement by giving written notice of 
termination to iRely, upon the occurrence of any of the following events: 
 (a) iRely breaches any of its material obligations under this Agreement 
and does not cure the breach within sixty (60) days (provided that 
the breach is susceptible to cure) after Customer gives written notice to 
iRely describing the breach in reasonable detail; or (b) iRely dissolves or 
liquidates or otherwise discontinues all or a significant part of its business 
operations. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>8.3 Termination by iRely.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> iRely may terminate any Professional Services under Proposals entered into after the 
date of this Agreement (i.e., Proposals other than the initial Proposal) for 
any reason upon thirty (30) days’ prior written notice to Customer.  
 iRely may immediately terminate this Agreement by giving written notice of 
termination to Customer, upon the occurrence of any of the following events: 
(a) Customer fails to pay to iRely, within ten (10) days after 
iRely makes written demand therefor, any past-due amount payable under this Agreement 
(including interest thereon) that is not the subject of a good faith 
dispute; (b) Customer breaches any of its other material obligations under this 
Agreement and does not cure the breach within thirty (30) days (provided 
that the breach is susceptible to cure) after iRely gives written notice 
to Customer describing the breach in reasonable detail; or (c) Customer dissolves 
or liquidates or otherwise discontinues all or a significant part of its 
business operations. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>8.4 Effect of Termination.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Upon a termination of this Agreement, whether under this Section 8 or 
otherwise, Customer will:  (a) discontinue all use of all Software, Documentation 
Hosting Services, SaaS Services and Professional Services, as applicable; (b) promptly return 
to iRely all copies of the Software and Documentation, as applicable, and 
all other Proprietary Items then in Customer''s possession; and (c) give written 
notice to iRely certifying that all copies of the Software and Documentation, 
as applicable, have been permanently deleted from Customer’s computers. Customer will remain 
liable for all payments due to iRely with respect to the period 
ending on the date of termination.  Customer acknowledges and agrees that 
iRely has no obligation to retain Customer data after termination, and that 
such Customer data may be irretrievably deleted thirty (30) days after termination 
of this Agreement.  The provisions of Sections 5, 6, 7, 8.4 
and 9 will survive any termination of this Agreement, whether under this 
Section 8 or otherwise. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>9.<span 
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>OTHER PROVISIONS</span></h1>


<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.1 Notices.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> All notices, consents and other communications under or regarding this Agreement will 
be in writing and will be deemed to have been received on 
the earlier of the date of actual receipt, the third business day 
after being mailed by first class certified air mail or the first 
business day after being sent by a reputable overnight delivery service.  
Any notice may be given by facsimile, provided that a signed written 
original is sent by one of the foregoing methods within twenty-four (24) 
hours thereafter.  Customer''s address for notices is stated on the first 
page of this Agreement.  iRely''s address for notices is 4242 Flagstaff 
Cove, Fort Wayne, IN 46815 USA, Attention: Contract Administration.  In the 
case of (a) any notice by Customer alleging a breach of this 
Agreement by iRely or (b) a termination of this Agreement, Customer will 
also send a copy to iRely, attention:  COO. Either party may 
change its address for notices by giving written notice of the new 
address to the other party in accordance with this Section 9.1. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.2 Parties in Interest.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> This Agreement will bind, benefit and be enforceable by and against iRely 
and Customer and, to the extent permitted hereby, their respective successors and 
assigns.  Customer will not assign this Agreement or any of its 
rights hereunder, nor delegate any of its obligations hereunder, without iRely’s prior 
written consent, except that such consent will not be required in the 
case of an assignment to (a) a purchaser of or successor to 
substantially all of Customer''s business (unless such purchaser or successor is a 
software, data processing or computer services vendor that is a competitor of 
iRely or any of its Affiliates) or (b) an Affiliate of Customer, 
provided that the scope of the license granted under this Agreement, as 
applicable, does not change and Customer guarantees to iRely in writing the 
obligations of the assignee. Any assignment by Customer in breach of this 
Section 9.2 will be void.  Any express assignment of this Agreement, 
any change in control of Customer, any acquisition of additional business by 
Customer (by asset acquisition, merger or otherwise by operation of law) and 
any assignment by merger or otherwise by operation of law, will constitute 
an assignment of this Agreement by Customer for purposes of this Section 
9.2. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.3 Relationship.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> The relationship between the parties created by this Agreement is that of 
independent contractors and not partners, joint venturers or agents. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.4 Entire Understanding; Counterparts.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> This Agreement, which includes and incorporates the Proposals and any other addenda 
hereto, states the entire understanding between the parties with respect to its 
subject matter, and supersedes all prior proposals, marketing materials, negotiations and other 
written or oral communications between the parties with respect to the subject 
matter of this Agreement.  This Agreement may be executed in one 
or more counterparts, each of which will be deemed an original and 
all of which together will constitute one and the same instrument. If 
this Agreement is executed via facsimile, each party hereto will provide the 
other party with an original executed signature page within five (5) days 
following the execution of this Agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.5 Modification, Waiver and Conflicts.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> No modification of this Agreement, and no waiver of any breach of 
this Agreement, will be effective unless in writing and signed by an 
authorized representative of the party against whom enforcement is sought.  This 
Agreement may not be modified or amended by electronic means without written 
agreement of the parties with respect to formats and protocols.  No 
waiver of any breach of this Agreement, and no course of dealing 
between the parties, will be construed as a waiver of any subsequent 
breach of this Agreement. In the event of any conflict between this 
Agreement and the Proposals, the terms of this Agreement will govern. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.6 Severability.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> A determination that any provision of this Agreement is invalid or unenforceable 
will not affect the other provisions of this Agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.7 Headings.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Section headings are for convenience of reference only and will not affect 
the interpretation of this Agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.8 Negotiated Terms.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> The parties agree that the terms and conditions of this Agreement are 
the result of negotiations between the parties and that this Agreement will 
not be construed in favor of or against any party by reason 
of the extent to which any party or its professional advisors participated 
in the preparation of this Agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.9 Non-Solicitation.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer will not, directly or through one or more Customer Affiliates, hire 
or offer to hire any programmer, trainer or member of a data 
processing or customer support team of iRely at any time when such 
Person is employed or engaged by iRely or during the twelve (12) 
months after such employment or engagement ends.  For purposes of this 
provision, “hire” means to employ as an employee or to engage as 
an independent contractor, whether on a full-time, part-time or temporary basis.  
This provision will remain in effect during the term of this Agreement 
and for a period of one (1) year after expiration or termination 
of this Agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.10 Governing Law and Jurisdiction.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> This Agreement will be construed and enforced in accordance with the laws 
of the State of Indiana, USA, excluding choice of law.  In 
any action relating to this Agreement, (a) each of the parties irrevocably 
consents to the exclusive jurisdiction and venue of the federal and state 
courts located in the State of Indiana, (b) each of the parties 
irrevocably waives the right to trial by jury, (c) each of the 
parties irrevocably consents to service of process by first class certified mail, 
return receipt requested, postage prepaid, to the address at which the party 
is to receive notice hereunder and (d) the prevailing party will be 
entitled to recover its reasonable attorney''s fees (including, if applicable, charges for 
in-house counsel), court costs and other legal expenses from the other party. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>9.11 Export Laws; Restricted Rights.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Customer will comply with all applicable United States export laws and regulations. 
 Customer will not export or re-export directly or indirectly (including via 
remote access) any part of the Software or Documentation, as applicable, or 
any Proprietary Items or Confidential Information to any jurisdiction outside the United 
States.  If Customer is an agency of the U.S. Government, the 
Software, Hosting Services and SaaS Services, as applicable, are provided with “Restricted 
Rights” and that their use, duplication or disclosure is governed by DFARS 
252.227-7103 (c)(1)(ii) or FAR 52.227-19m, as applicable. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify''><span style=''font-size:10.0pt''>10.<span 
style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>EVALUATION AGREEMENT</span></h1>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>10.1 iRely Evaluation Offering.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> iRely grants you a nonexclusive, nontransferable, revocable, time-limited 
license to use the software product(s) ("Software"), in object code format, and any included documentation, free of charge for the 
Evaluation Term for the sole and limited purpose of evaluating the Software. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>10.2 Evaluation Term.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> The evaluation right and license terminates as of the date agreed to in the 
proposal or other form of written documentation, but terminates no later than one year from the date of first access.  Upon or prior 
to termination, user agrees to either: (a) Purchase a full license for the Software or purchase a SaaS offering pursuant to the 
terms in this Customer Master Agreement; or (b) Return any access information provided; or upon request by iRely, destroy the 
access information of Software and all copies of any accompanying documentation and certify in writing that it has been destroyed.  
At the end of the Evaluation Term, iRely will terminate access to the environment if a SaaS offering.  iRely may immediately terminate 
this Agreement upon written notice if breach of any terms or conditions of this Agreement occurs.  In such event, user will cease 
using the service or return or destroy the access information and software, as specified above. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>10.3 Ownership; Confidentiality.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> The Software and SaaS Offering is owned and copyrighted by Vendor.  All right, title, 
and interest, including all intellectual property, are and shall remain the sole property of Vendor.  Other than as specified in this Agreement, user 
obtains no right in and to the Software.  User agrees not to remove from view ay copyright legend, trademark or confiedentiality notice appearing on 
the Software or SaaS offering.  User further agrees not to reverse engineer, reverse compile, translate the Software or make any attempt to discover 
the source code of teh Software, now will user permit any third party to do the same.  The iRely Software and SaaS Offering are confidential 
information of iRely and user agrees not to disclose the Software or SaaS Offering or the results of any performance or functional 
evaluation or test of the Software or SaaS Offering to any third party without the prior written approval of iRely. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>10.4 Content.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> User assumes sole responsibility for acquiring any authorization(s) necessary for interfaces and hypertext 
links to third party systems or websites and the accuracy of materials published via iRely''s Software and SaaS Offering, including without limitation, user''s content, 
descriptive claims, warranties, guarantees, nature of business and the address of where business is conducted. User assumes sole responsibility that the content 
uploaded and published via iRely''s Software and SaaS Offering does not infringe upon or violate any third party rights or includes the intellectual property of 
a third party without the prior written consent of such third party. In no event shall iRely or its licensors be responsible for any content, products, or other 
materials on or available from third-party sites which is not provided by iRely.  Notwithstanding the foregoing, iRely reserves the right, in its sole discretion, 
to exclude or remove from the iRely Software and SaaS Offering any interfaces or hypertext links to third party systems, websites, any content or other content not 
supplied by iRely which, in iRely’s sole reasonable discretion, may violate or infringe any law or third party rights, provided that such right shall not place an 
obligation on iRely to monitor or exert editorial control over the iRely Software and SaaS Offering. iRely does not own any data, information or material that you 
submit to and publish via iRely''s Software and SaaS Offering in the course of using the iRely Software and SaaS Offering.  You shall have sole responsibility for 
the accuracy, quality, integrity, legality, reliability, appropriateness, and intellectual property ownership or right to use of all your content, and iRely shall 
not be responsible or liable for the deletion, correction, destruction, damage, loss or failure to store any content.  iRely reserves the right to withhold, remove 
and/or discard content without notice for any breach, including, without limitation, non-payment.  Upon termination for cause, your right to access or use content 
immediately ceases, and iRely shall have no obligation to maintain or forward any your content. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>10.5 Limited Warranty and Limitations of Liability.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> Please refer to Section 6 of this agreement. 
</span></h3>

<p class=MsoNormal>&nbsp;</p>

<h3 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:-.25in''><a
name="_Ref456628893"><b><span style=''font-size:10.0pt;font-family:"Arial","sans-serif"''>10.6 General.</span></b></a><span
style=''font-size:10.0pt;font-family:"Arial","sans-serif"''> User may not assign or otherwise transfer, by operation of law or otherwise, any rights under this Agreement without iRely''s 
prior written consent. This Agreement constitutes the entire understanding between the parties regarding the subject matter hereof and supersedes any prior agreements or understandings, 
whether written or oral. This Agreement shall be governed by the laws of the State of Indiana without regard to conflicts of law provisions and both parties submit to the exclusive 
jurisdiction of courts of the State of Indiana.
</span></h3>


<h1 style=''margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:.5in;
margin-bottom:.0001pt;text-align:justify;text-indent:0in''>&nbsp;</h1>

</div>

</body>

</html>
')
END

GO