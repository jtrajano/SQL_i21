GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMEULA WHERE strVersionNumber = '15.4' AND strText like '%EVALUATION AGREEMENT%')
BEGIN
	DELETE FROM tblSMEULA WHERE strVersionNumber = '15.4'
END

GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMEULA WHERE strVersionNumber = '15.4' AND strText like '%Governing Law; Arbitration; Exclusive Jurisdiction.%')
BEGIN
	DELETE FROM tblSMEULA WHERE strVersionNumber = '15.4'
END

GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMEULA WHERE strVersionNumber = '20.1' AND strText like '%Governing Law%')
BEGIN
	DELETE FROM tblSMEULA WHERE strVersionNumber = '20.1'
END

GO

IF EXISTS(SELECT TOP 1 1 FROM tblSMEULA WHERE strVersionNumber = '20.1.1')
BEGIN
	DELETE FROM tblSMEULA WHERE strVersionNumber = '20.1.1'
END

GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMEULA WHERE strVersionNumber = '20.1.1')
BEGIN
INSERT INTO tblSMEULA(strVersionNumber, strText)
VALUES ('20.1.1', N'<!DOCTYPE html>
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
"Arial","sans-serif";letter-spacing:1.0pt''>iRely Master Agreement</span></p>

<p>&nbsp;</p>
    <p><strong>YOU AGREE THAT BY PLACING AN ORDER THROUGH AN ORDERING DOCUMENT, SUCH AS A PROPOSAL OR SOW FOR PROFESSIONAL SERVICES, THAT INCORPORATES THESE GENERAL TERMS,</strong> <strong>YOU AGREE TO FOLLOW AND BE BOUND BY THE TERMS AND CONDITIONS OF THE ORDERING DOCUMENT AND THESE GENERAL TERMS. IF YOU ARE PLACING SUCH AN ORDER ON BEHALF OF A COMPANY OR OTHER LEGAL ENTITY, YOU REPRESENT THAT YOU HAVE THE AUTHORITY TO BIND SUCH ENTITY TO THE TERMS AND CONDITIONS OF THE ORDERING DOCUMENT AND THIS MASTER AGREEMENT AND THE APPLICABLE SCHEDULES AS DEFINED HEREIN.&nbsp; IF YOU DO NOT HAVE SUCH AUTHORITY, OR IF YOU OR SUCH ENTITY DO NOT AGREE TO FOLLOW AND BE BOUND BY THE TERMS AND CONDITIONS OF THE ORDERING DOCUMENT AND THESE GENERAL TERMS, YOU SHALL NOT PLACE AN ORDER OR USE PRODUCTS OR SERVICES OFFERINGS.</strong></p>
<p style="text-align: center;"><strong>PROVIDER</strong>&nbsp;<strong>MASTER AGREEMENT</strong></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; THIS MASTER AGREEMENT (together with any applicable Ordering Document and all applicable Schedules, the "Agreement"), is effective as of the date (the "Effective Date") the Ordering Document(s) is executed by Provider LLC<strong>,</strong> a Delaware limited liability company with a principal place of business located at 4242 Flagstaff Cove, Ft. Wayne, Indiana, 46815 ("Provider") and the entity that has executed such Ordering Document(s) ("Customer") Provider</p>
<p><br></p>
<p><strong>1.&nbsp;SCOPE OF MASTER AGREEMENT AND SCHEDULES</strong></p>
<p>This Agreement includes several Schedules appended hereto. Each applicable Schedule is incorporated herein by reference.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 1.1. Schedule 1 – Proposal, defines the scope of goods and services to be provided under this Master Agreement. Once executed by both parties, a Proposal becomes an Ordering Document hereunder.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 1.2. Schedule 2.1 – Software License, governs the license of the Software if the Customer has selected to use the Software installed on its own servers or as hosted by Provider</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 1.3. Schedule 2.2 – Software as a Service License, governs the purchase of the SaaS Services if the Customer has selected to use the SaaS Services.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 1.4. Schedule 3 – Implementation Process Schedule, describes the implementation process.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 1.5. Schedule 4 – Maintenance Schedule, describes the Maintenance Services Provider will provide to Customer.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 1.6. Schedule 5 – Invoicing and Payment Schedule, describes how Provider will invoice Customer and Customer''s payment obligations.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 1.7. Schedule 6 – Change Procedure Schedule, describes the process by which the parties shall may the scope of goods and services during the Term of this Master Agreement.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 1.8. Schedule 7 – Hosting Schedule, Provider governs Provider''s hosting of Customer data on its servers.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 1.9. Schedule 8 – Privacy Policy, describes Provider''s privacy policies.</p>
<p><br></p>
<p><strong>2. DEFINITIONS</strong></p>
<p>The following definitions apply to this Master Agreement and the attached Schedules. Additional capitalize terms used in this Master Agreement or attached Schedules shall have the meaning described therein.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.1. "Affiliate" means any corporation or other entity controlled by, controlling, or under common control with any party, and "control" means the direct or indirect beneficial ownership of a majority interest in the voting stock, or other ownership interests, of such corporation or entity, or the power to elect at least a majority of the directors or trustees of such corporation or entity, or majority control of such corporation or entity, or such other relationship, which in fact constitutes actual control.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.2. "Application" means the modules, platform, user interfaces, on-line help, and associated Documentation of Provider to which Customer may have access pursuant to the Software as a Service License.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.3. "Customer Data" means any data, information, content, or material, which Customer or its Affiliates enter, load onto, or use in connection with the Application, and all results from processing the same while using the Application.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.4. "Documentation" means the user and technical information, provided to Customer by Provider, regarding the access and use of the Application by means of an on-line help system describing the operation of the Application under normal circumstances.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.5. "Fees" means the License Fee, Subscription Fee, Maintenance Fees, Hosting Fee and Professional Services Fees.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.6. "Hosting Fee" means the fee for Provider to host the Software and Customer''s related data on behalf of Customer.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.7. "Intellectual Property Rights" means, on a worldwide basis, any (i)&nbsp;copyrights and copyrightable works, whether registered or unregistered; (ii) trademarks, service marks, trade dress, logos, registered designs, trade and business names (including internet domain names, corporate names, and e-mail address names), whether registered or unregistered; (iii) patents, patent applications, patent disclosures, mask works and inventions (whether patentable or not); (iv) trade secrets, know-how, data privacy rights, database rights, know-how, and rights in designs; and (v) all other forms of intellectual property or proprietary rights, and derivative works thereof, in each case in every jurisdiction worldwide.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.8. "License Fee" means the one-time Software license fee.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.9. "Maintenance Fee" means the annual fee for Maintenance Services.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.10. "Ordering Document" means any executed Proposal or SOW, which upon execution represents a binding commitment to purchase Products or Services.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.11. "Professional Services Fees" means fees for Professional Services, paid at Provider''s then current standard rates.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.12. "Professional Services" means custom software development and other support services provided by Provider in connection with implementation or ongoing use of the Products, which are specifically quoted and billed at the Professional Service Fee Rates listed on Schedule 5 – Invoicing and Payments.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.13. "SOW" means a Statement of Work, which sets forth the deliverables, timelines and cost estimate for Professional Services as a result of the Change Procedure described in Schedule 6 – Change Procedure or for Professional Services.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.14. "Subscription" means the right to use and access the Application as described in Schedule 2.2, SaaS License, upon payment of the Subscription Fee.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.15. "Subscription Fee" means the fee for the Subscription, and to receive the Standard Support Services, during the corresponding Subscription period.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.16. "Update" means any patch, bug fix, correction, update, upgrade, enhancement, minor release, or other modification by Provider to an Application, that is generally small in scope, made generally available by Provider to its then-current customers.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 2.17. "User(s)" means Customer''s employees and Affiliates authorized to use the Application in accordance with this Agreement and supplied user identifications and/or passwords in accordance with this Agreement.</p>
<p><br></p>
<p><strong>3. INTELLECTUAL PROPERTY RIGHTS</strong></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 3.1.&nbsp;<span style="text-decoration: underline;">Customer Intellectual Property</span>. "Customer IP" means Customer''s Confidential Information, materials, inventions, and data. The Customer IP shall be owned by Customer. Provider may not use, access, reproduce, publish, sell, license, display, or exploit (collectively, "Use") any Customer IP without Customer''s prior written consent. Provider shall have the right to Use Customer IP to perform the Services and Customer grants Provider a limited, royalty-free, non-exclusive, revocable, terminable license to Use the Customer IP as necessary for Provider to perform the Services.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 3.2.&nbsp;<u>Provider</u><span style="text-decoration: underline;"> Intellectual Property</span>. "Provider IP" means any item or material, and any modifications, enhancements or feedback thereon, including intellectual property (such as written materials, software, its configurations and standard reporting and interfaces, websites or patented inventions) or physical assets (such as equipment or other products), that is: (a) owned, leased or licensed by Provider or Provider''s Affiliates or subcontractors (other than licensed from Customer hereunder); or (b) furnished by Provider in connection with the Services. For the avoidance of doubt, Provider IP includes the Products, Software and Documentation. The Provider IP shall be owned by Provider. Customer shall not use Provider IP for any purpose not expressly permitted in this Agreement.</p>
<p><br></p>
<p><strong>4. PRODUCTS, SERVICES, AND DELIVERABLES</strong></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 4.1. "Products" means hardware or software (the "Software") licensed by Provider as set forth in either Schedule 2.1 – Software License or Schedule 2.2 – Software as a Service License.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 4.2. "Services" means the services described in the Ordering Document.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 4.3. "Deliverables" means information and other materials prepared for Customer during the performance of the Services and pursuant to an Implementation Project Plan or in connection with other Professional Services.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 4.4. All Services shall be performed in a workmanlike and professional manner by qualified representatives of Provider who are fluent in written and spoken English.</p>
<p><br></p>
<p><strong>5. MAINTENANCE SERVICES</strong></p>
<p>&nbsp; &nbsp; Please refer to Schedule 4 – Provider Maintenance Agreement.</p>
<p><br></p>
<p><strong>6. PAYMENT AND INVOICING</strong></p>
<p>&nbsp; &nbsp; Please refer to Schedule 5 – Payment and Invoicing.</p>
<p><br></p>
<p><strong>7. CONFIDENTIAL INFORMATION</strong></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 7.1. <span style="text-decoration: underline;">Confidential Information</span>. "Confidential Information" means all financial, technical, strategic, marketing, and other information relating to a disclosing party (the "Disclosing Party") or its actual or prospective business, products, or technology that may be, or has been, furnished or disclosed to the other party (the "Recipient") by, or acquired by Recipient directly or indirectly from the Disclosing Party, whether disclosed orally or in writing or electronically or some other form, and shall include the terms and conditions and pricing information of this Agreement, and the Application (including, without limitation, Documentation, source code, translations, compilations, implementation methodologies, partial copies, and derivative works).</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 7.2. <u>Limitations</u>. Confidential Information does not include that which was: (i) as of the Effective Date of this Agreement, generally known to the public without breach of this Agreement; (ii) is or became generally known to the public after the date of this Agreement other than as a result of the act or omission of Recipient or Recipient''s Affiliates; (iii) was already in the possession of the Recipient without any obligation of confidence; (iv) released by Disclosing Party with its written consent to third parties without restriction on use and disclosure; (v) lawfully received by Recipient from a third party without an obligation of confidence; (vi) independently developed by Recipient outside the scope of this relationship by personnel not having access to any Confidential Information; or (vii) is required to be disclosed in accordance with a judicial or governmental order or decree, provided that the Recipient provides prompt notice of the order or decree to the Disclosing Party and reasonably cooperates with the Disclosing Party to limit the disclosure and use of the applicable information.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 7.3. <span style="text-decoration: underline;">Non-Disclosure</span>. Recipient shall: (i)&nbsp;use at least the same degree of care that it uses with respect to its own confidential information, but in no event less than a reasonable degree of care to avoid disclosure, publication or dissemination of the other party''s Confidential Information; (ii) disclose Confidential Information only to its personnel, Affiliates and subcontractors who have a need to know such information and are bound by a confidentiality agreement with Recipient; and (iii) promptly report any loss of any Confidential Information to the Disclosing Party.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 7.4. <span style="text-decoration: underline;">Notices</span>. Recipient shall not: (i)&nbsp;alter or remove from any Confidential Information of the Disclosing Party any proprietary legend, or (ii) decompile, disassemble or reverse engineer the Confidential Information (and any information derived in violation of such covenant shall automatically be deemed Confidential Information owned exclusively by the Disclosing Party).</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 7.5.&nbsp;<span style="text-decoration: underline;">Return of Confidential Information</span>. Upon the written request of the Disclosing Party or termination or expiration of this Agreement, and regardless of whether a dispute may exist, Recipient shall return or destroy (as instructed by Disclosing Party) all Confidential Information of Disclosing Party in its possession or control and cease all further use thereof.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 7.6. <span style="text-decoration: underline;">Injunctive Relief</span>. Recipient acknowledges that violation of the provisions of this <span style="text-decoration: underline;">Section 7</span> would cause irreparable harm to Disclosing Party not adequately compensable by monetary damages. In addition to other relief, it is agreed that injunctive relief shall be available without the necessity of posting bond to prevent any actual or threatened violation of such provisions.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 7.7. <span style="text-decoration: underline;">PII</span>. "Personally Identifiable Information" or "PII" means information which can be used to distinguish or trace an individual''s identity, either alone or when combined with other personal or identifying information, which is linked or linkable to a specific individual. If Provider has access to PII (except for business contact information and e-mail addresses of the Customer), such access will likely be incidental. The intended purpose of the Application is not to accept or use PII. Customer shall retain control of its PII. To the extent Provider has incidental access to Customer PII, Provider shall use or disclose PII only: (i)&nbsp;in furtherance of or in performing the services pursuant to this Agreement and the relevant Ordering Document; (ii) pursuant to a lawful subpoena, service of process, or otherwise required or permitted by law; (iii) as directed or instructed by Customer; or (iv) with prior informed consent of the individual about whom the PII pertains.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 7.8 <span style="text-decoration: underline;">Non-Exclusive Agreement</span>. Provider may solicit and perform similar Services on behalf of companies that Customer may consider to be its direct or indirect competitors, provided that Customer''s Confidential Information shall be treated as set forth in this Section 7.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 7.9 <span style="text-decoration: underline;">Publicity</span>. Provider shall have the right, and Customer hereby consents, to 1) list Customer''s logo as a Provider client on Provider''s website and on marketing materials and include a link to Customer''s website and company introduction; and 2) mention Customer as a Provider Customer during sales pitches to Provider prospects. Provider will seek Customer''s consent prior to using Customer''s name in White Papers or other similar written material.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 7.10 <span style="text-decoration: underline;">Survival</span>. This Section shall survive termination of this Agreement for a period of 3 years.</p>
<p><br></p>
<p><strong>8. INDEMNIFICATION</strong></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 8.1 <span style="text-decoration: underline;">Mutual Indemnity</span>.&nbsp;Each party ("Indemnifying Party") will indemnify, pay and reimburse for, defend and hold harmless the other party, its&nbsp;Affiliates, and their respective employees, directors, managers, officers, partners, shareholders, contractors, and agents&nbsp;(collectively, the "Indemnified Persons"), from and against any and all claims, liabilities, demands, suits, actions, or other proceedings brought by third parties (each a "Claim"), and all losses, damage, judgments, payments made in settlement, and costs and expense, including reasonable attorneys'' fees and disbursements and court costs as a result of such Claims ("Damages") arising out of: (a) willful misconduct or fraud by the Indemnifying Party, its personnel, subcontractors, or agents; (b)&nbsp;the breach or alleged breach of any representation, warranty, or covenant of this Agreement or the inaccuracy of any representation made by Indemnified Persons herein, or (c) a party''s failure to comply with any applicable law, including any Data Protection Law.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 8.2 <span style="text-decoration: underline;">Customer Indemnity</span>. Customer shall defend Provider against any Claims, and indemnify Provider for any Damages, arising out of a claim alleging: (i) that use of the Customer Data infringes the rights of, or has caused harm to, a third party; or (ii) infringement of third-party rights arising from the combination of the Application with any of Customer products, service, hardware or business process(s).</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 8.3 <span style="text-decoration: underline;">Indemnification Procedures</span>.&nbsp;An Indemnified Person must promptly give written notice to the Indemnifying Party of any Claim. The Indemnifying Party may elect to retain counsel of its choice to represent&nbsp;the&nbsp;Indemnified Person in connection with any&nbsp;Claim and will pay all fees and costs of such counsel.&nbsp;An Indemnified Person may participate at its own expense and through legal counsel of its choice in any such&nbsp;Claim. The Indemnifying Party will not settle any Claim without the prior written consent of&nbsp;the Indemnified Person, which shall not be unreasonably withheld. However, the Indemnified Person may assume control of the defense of the Claim and retain counsel reasonably acceptable to the Indemnifying Party, if (a) the Indemnifying Party does not to assume control of the defense; (b) conflicts of interest exist between the parties with respect to the Claim; or (c) the other party to the Claim is seeking relief which in an Indemnified Person''s reasonable judgment may adversely affect the Indemnified Person''s business. In this case, the fees, charges, and disbursements of no more than one counsel per jurisdiction selected by the Indemnified Person will be reimbursed by the Indemnifying Party.</p>
<p><br></p>
<p><strong>9. CHANGE CONTROL PROCEDURE</strong></p>
<p>Please refer to Schedule 6 – Change Control&nbsp;Schedule.</p>
<p><br></p>
<p><strong>10. TERM; TERMINATION</strong></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 10.1. <span style="text-decoration: underline;">Term</span>. The initial term of the Agreement shall commence on the Effective Date specified in the first executed Ordering Document and shall continue in full force and effect and unless extended or terminated earlier pursuant to this Agreement or stated in such Ordering Document (the "Initial Term"). Once the Agreement is commenced, its term will continue so long as the initial term</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 10.2. <span style="text-decoration: underline;">Renewal Term</span>. Certain Products or Services will automatically renew in accordance with the relevant Ordering Document (each a "Renewal Term"), unless a party delivers written notice of its intent to cancel at least 60 days before the expiration of the Initial Term or the then current Renewal Term. Unless otherwise set forth in an Ordering Document, SaaS Subscriptions and Software Maintenance will each automatically renew for additional one-year Renewal Terms at the end of the Initial Term and each Renewal Term.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 10.3.&nbsp;<span style="text-decoration: underline;">Termination</span>.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 10.3.1. Either&nbsp;party may terminate this Agreement, (i)&nbsp;upon thirty (30) days prior written notice, in the event that the other party materially breaches a provision of the Agreement and fails to cure such breach within the thirty (30) days after it receives such notice (or immediately, if such breach is not capable of being cured) or (ii)&nbsp;in accordance with Section&nbsp;9 (Force Majeure).</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 10.3.2. Either party may terminate this Agreement immediately upon written notice, if the other party becomes insolvent; or files, or has filed against it and not dismissed within sixty (60) days, a petition for bankruptcy.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 10.3.3.Provider may terminate this Agreement on thirty (30) days written notice if Customer fails to make timely payments hereunder.&nbsp;</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 10.4 <span style="text-decoration: underline;">Procedures Upon Termination</span>. When the Agreement terminates or expires:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 10.4.1. Customer will pay Provider for all Services performed and expenses incurred by Provider prior to the date of termination. In the event the Agreement has been terminated early not due to Provider''s breach or insolvency, then Customer shall repay any discounts set forth in the Ordering Document governing the unfinished Term.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 10.4.2. Provider will: (i)&nbsp;deliver to Customer all Deliverables and Products for which Customer has fully paid; (ii) and immediately discontinue (and cause its contractors and personnel to immediately discontinue) all use of Customer Materials. Upon termination or expiration of Agreement, this clause does not permit Customer to retain Provider Materials for any purpose and Customer must return Provider Materials within 10 days.</p>
<p><br></p>
<p><strong>11. FORCE MAJEURE</strong></p>
<p>Neither party will be liable under, or deemed to be in breach of, this Agreement for any delay or failure in performance under this Agreement or the applicable Order Document that is caused by any of the following events: acts of God, civil or military authority, war; fires; power outages; earthquakes; floods; unusually severe weather; strikes or labor disputes (excluding Provider''s subcontractors); delays in transportation or delivery as a result of a Force Majeure Event; epidemics; terrorism or threats of terrorism; and any similar event that is beyond the reasonable control of the non-performing party ("Force Majeure Event"). This section does not excuse either party''s obligation to take reasonable steps to follow its normal disaster recovery procedures or Customer''s obligations to pay for Products and Services ordered or delivered. The party affected by the Force Majeure Event must diligently attempt to perform (including through alternate means).&nbsp;During a Force Majeure Event, the parties will negotiate changes to this Agreement in good faith to address the Force Majeure Event in a fair and equitable manner. If a Force Majeure Event continues for ten (10) days or longer, and the non-performing party is delayed or unable to perform under this Agreement or any Order Document because of the Force Majeure Event, then the performing party will have the right to terminate this Agreement or the Order Document, in whole or in part, upon written notice to the non-performing party.</p>
<p><br></p>
<p><strong>12. DISCLAIMERS AND LIMITATIONS OF LIABILITIES</strong> <strong>&nbsp;</strong></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 12.1. Except as expressly set forth in this Agreement, neither party makes, and each such party hereby specifically disclaims, all representations and warranties express or implied, arising by law or otherwise, arising under or relating to this Agreement.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 12.2. EXCEPT AS OTHERWISE STATED IN THE AGREEMENT, THE SOFTWARE, HOSTING SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND SERVICES PROVIDED TO CUSTOMER HEREUNDER ARE "AS IS", AND PROVIDER MAKES NO REPRESENTATIONS OR WARRANTIES, ORAL OR WRITTEN, EXPRESS OR IMPLIED, ARISING FROM COURSE OF DEALING, COURSE OF PERFORMANCE, USAGE OF TRADE, QUALITY OF INFORMATION, QUIET ENJOYMENT OR OTHERWISE, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, NON-INTERFERENCE, OR NON-INFRINGEMENT WITH RESPECT TO THE SOFTWARE, HOSTING SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND SERVICES PROVIDED TO CUSTOMER HEREUNDER OR WITH RESPECT TO ANY OTHER MATTER PERTAINING TO THIS AGREEMENT. CUSTOMER''S USE OF THE SOFTWARE, HOSTING SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND SERVICES PROVIDED TO CUSTOMER HEREUNDER WILL NOT BE DEEMED LEGAL, TAX OR INVESTMENT ADVICE.&nbsp;</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 12.3. PROVIDER''S TOTAL LIABILITY UNDER THIS AGREEMENT WILL UNDER NO CIRCUMSTANCES EXCEED THE AMOUNT ACTUALLY PAID BY CUSTOMER TO PROVIDER UNDER THIS AGREEMENT DURING THE THREE (3) MONTHS PRIOR TO THE EVENT OF LIABILITY.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 12.4. UNDER NO CIRCUMSTANCES WILL PROVIDER (OR ANY PROVIDER AFFILIATES PROVIDING SOFTWARE, HOSTING SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND SERVICES TO CUSTOMER HEREUNDER) BE LIABLE TO CUSTOMER, ANY AUTHORIZED USER OR ANY OTHER PERSON FOR LOST REVENUES, LOST PROFITS, LOSS OF BUSINESS, TRADING LOSSES, OR ANY INCIDENTAL, INDIRECT, EXEMPLARY, CONSEQUENTIAL, SPECIAL OR PUNITIVE DAMAGES OF ANY KIND, INCLUDING SUCH DAMAGES ARISING FROM ANY BREACH OF THIS AGREEMENT OR ANY TERMINATION OF THIS AGREEMENT, WHETHER SUCH LIABILITY IS ASSERTED ON THE BASIS OF CONTRACT, TORT (INCLUDING NEGLIGENCE OR STRICT LIABILITY) OR OTHERWISE AND WHETHER OR NOT FORESEEABLE, EVEN IF PROVIDER HAS BEEN ADVISED OR WAS AWARE OF THE POSSIBILITY OF SUCH LOSS OR DAMAGES.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 12.5. Provider will have no liability to Customer under the following circumstances:&nbsp; Customer fails to follow Provider''s instructions relating to the Software, Hosting Services or SaaS Services; the Software, Hosting Services or SaaS Services are used in violation of this Agreement; the Software is configured, customized, installed or maintained by anyone other than Provider; Customer modifies any Software without the prior written consent of Provider; and/or the Software, Hosting Services or SaaS Services are used in conjunction with any hardware, software, products or interfaces not specified by Provider. &nbsp;The obligations of Provider under this Agreement run only to Customer and not to its Affiliates, Authorized Users or any other persons. Under no circumstances will any Affiliate, Authorized User or client of Customer or any other person be considered a third-party beneficiary of this Agreement or otherwise entitled to any rights or remedies under this Agreement, even if such Affiliates, Authorized Users, clients or other persons are provided access to any Hosting Services, SaaS Services or Professional Services.&nbsp; Customer will have no rights or remedies against Provider except as specifically provided in this Agreement. No action or claim of any type relating to this Agreement may be brought or made by Customer more than one (1) year after Customer first has knowledge of the basis for the action or claim.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 12.6. The exclusions, disclaimers and limitations provided in this Agreement have been considered by the parties in the pricing of the Goods and Services provided in this Agreement.</p>
<p><br></p>
<p><strong>13.1. NOTICES</strong></p>
<p>All notices from one party to the other under this Agreement will be in writing and will be deemed given when (i) delivered personally with receipt signature; (ii) sent via certified mail with return receipt requested; or (iii) (iv) sent by commercially recognized air courier service with receipt signature required, to the following address:</p>
<p><br></p>
<p><strong>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</strong>if to iRely, LLC:</p>
<p><em>Provider, LLC</em></p>
<p><em>4242 Flagstaff Cove</em></p>
<p><em>Ft. Wayne, Indiana, 46815</em></p>
<p><em>ATTENTION: Chris Pelz (<a href="mailto:chris.pelz@irely.com" class="external-link" rel="nofollow">chris.pelz@irely.com</a>)</em></p>
<p><br></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; if to CUSTOMER:</p>
<p><em>[NAME &amp; ADDRESS]&nbsp;</em></p>
<p><em>ATTENTION: ____________________________________________</em></p>
<p><em>and</em></p>
<p><em>ATTENTION: ____________________________________________</em></p>
<p><br></p>
<p><strong>14. REPRESENTATIONS AND WARRANTIES OF CUSTOMER</strong></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 14.1. <span style="text-decoration: underline;">Representations and Warranties</span>. Customer represents and warrants to Provider that:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 14.1.1. Customer owns Customer Data or has all necessary rights to use and input Customer Data into the Application;</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 14.1.2. Customer Data shall not infringe upon any third-party Intellectual Property Rights or violate any rights against defamation or rights of privacy; and</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 14.1.3. Customer has not falsely identified itself nor provided any false information to gain access to the Application and that Customer''s billing information is correct.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 14.2. <span style="text-decoration: underline;">EU Data Transfer</span>. If Customer resides in the European Union (EU) or if any transfer of information between Customer and the Application is governed by the European Union Data Protection Directive or national laws implementing that Directive, then Customer expressly consents to the transfer of such information outside of the European Union to the United States and to such other countries as may be contemplated by the features and activities of the Application under this Agreement. Customer will indemnify Provider against all claims asserted against it under the GDRP.</p>
<p><br></p>
<p><strong>15. EXPORT CONTROL</strong></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 15.1. <span style="text-decoration: underline;">Export Laws</span>. Export laws and regulations of the United States and any other relevant local export laws and regulations apply to the Products. Customer agrees that such export laws govern its use of the Products (including technical data) and Services provided under the Master Agreement, and Customer agrees to comply with all such export laws and regulations (including "deemed export" and "deemed re-export" regulations). Customer further agrees that no data, information, Product and/or Deliverables will be exported, directly or indirectly, in violation of these laws, or will be used for any purpose prohibited by these laws including, without limitation, nuclear, chemical, or biological weapons proliferation, or development of missile technology.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 15.2. <span style="text-decoration: underline;">No Representations</span>. Provider and its licensors make no representation that the Products and Services are appropriate or available for use in other locations. Customer is solely responsible for compliance with all applicable laws, including without limitation export and import regulations of other countries. Any diversion of the Customer Data contrary to U.S. and other relevant law is prohibited.</p>
<p><br></p>
<p><strong>16. INTEGRATION AND AMENDMENTS</strong></p>
<p>This Agreement and the attached Schedules constitute a complete and exclusive final written expression of the terms of agreement between the Parties regarding the subject matter hereof. It supersedes all earlier and contemporaneous agreements, understandings and negotiations concerning the subject matter. The Parties may amend this Agreement only in writing, and no oral representation or course of dealing shall modify this Agreement.</p>
<p><br></p>
<p><strong>17. SECURITY, NO CONFLICTS</strong></p>
<p>Each party shall inform the other of any information made available to the other party that is classified or restricted data, shall comply with the security requirements imposed by any state or local government, or by the United States Government, and shall return all such material upon request. Each party represents and warrants that its participation in this Agreement does not conflict with any contractual or other obligation of the party or create any conflict of interest and shall promptly notify the other party if any such conflict arises during the Term.</p>
<p><br></p>
<p><strong>18. INSURANCE</strong></p>
<p>Each party shall maintain adequate insurance protection covering its respective activities hereunder, including coverage for statutory workers'' compensation, comprehensive general liability for bodily injury and tangible property damage, and shall provide Certificates of Insurance to the other party, upon reasonable request, evidencing such coverage and amounts.</p>
<p><br></p>
<p><strong>19. GOVERNING LAW AND DISPUTES</strong></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 19.1. The construction and performance of this Agreement shall be governed by the substantive laws of the United States and the laws of the State of Delaware, without regard to its conflicts of law''s provisions. The United Nations Convention on Contracts for the International Sale of Goods shall not apply to this Agreement. Any claim by one party against the other party must be brought within one year after it arose.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 19.2. Any controversy or claim arising out of or relating to this Agreement, or the breach thereof, shall be settled by arbitration administered by the American Arbitration Association in accordance with its Commercial Arbitration Rules, and judgment on the award rendered by the arbitrator(s) may be entered in any court having jurisdiction thereof. The arbitration shall be conducted in Allen County, Indiana by a single arbitrator appointed by the AAA. Any appeal of the arbitration decision shall be brought exclusively in the federal or state courts situated in Delaware. Customer consents to personal jurisdiction and venue in Delaware.</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; 19.3. Provider shall be entitled to its reasonable attorneys'' fees, costs and expenses if it prevails in any legal dispute with Customer.</p>
<p><br></p>
<p><strong>20. PRIVACY POLICY AND GDPR</strong></p>
<p>Schedule 8 contains Provider''s Privacy Policy.</p>
<p><br></p>
<p><strong>21. ASSIGNMENT OR CHANGE IN CONTROL</strong></p>
<p>This Agreement may not be assigned by either party without the prior written approval of the other party, but may be assigned without consent in the event of a merger or reorganization in which the surviving entity owns or controls more than 50% of the acquired party and agrees in writing to assume the obligations under this Agreement. Any purported assignment in violation of this section shall be void. Any actual or proposed change in control of Customer that results, or would result, in a direct competitor of Provider directly or indirectly owning or controlling 50% or more of Customer shall entitle Provider to terminate this Agreement for cause immediately upon written notice.</p>
<p><br></p>
<p><strong>22. SEVERABILITY</strong></p>
<p>If any provision of this Agreement is held by a court of competent jurisdiction to be invalid or unenforceable, then such provision(s) shall be construed, as nearly as possible, to reflect the intentions of the invalid or unenforceable provision(s), with all other provisions remaining in full force and effect.</p>
<p><br></p>
<p><strong>23. NO AGENCY</strong></p>
<p>The Parties acknowledge and agree that each is an independent contractor, and nothing herein constitutes a joint venture, partnership, employment, or agency between Customer and Provider because of this Agreement or use of the Application. Neither party shall have the right to bind the other party or cause it to incur liability.</p>
<p><br></p>
<p><strong>24. WAIVER</strong></p>
<p>The failure of either party to enforce any right or provision in this Agreement shall not constitute a waiver of such right or provision unless acknowledged and agreed to by such party in writing.</p>
<p><br></p>
<p><strong>25. NON-SOLICITATION</strong></p>
<p>During the Term of this Agreement and for a period of one year thereafter, neither party will, except with the other party''s prior written approval, solicit the employment of any employee, consultant or subcontractor of such other party that directly participated in the activities set forth in this Agreement. The foregoing shall specifically not apply to general solicitations of employment issued by either party to which an employee of the other may voluntarily respond.</p>
<p><br></p>
<p><strong>26. SURVIVABILITY</strong></p>
<p>Provisions that survive termination or expiration are those relating to limitation of liability, infringement indemnity, payment and others which by their nature are intended to survive.</p>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <p>&nbsp;</p>

</body>

</html>
')
END

GO