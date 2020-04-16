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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMEULA WHERE strVersionNumber = '20.1')
BEGIN
INSERT INTO tblSMEULA(strVersionNumber, strText)
VALUES ('20.1', N'<!DOCTYPE html>
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

<p class=MsoNormal>&nbsp;</p>

<p class=MsoNormal>&nbsp;</p>

<p>&nbsp;</p>
    <p>THIS MASTER AGREEMENT (the “<strong>Agreement</strong>”), effective as of acceptance of agreement between<span> </span><strong>Customer (“Customer”)<span> </span></strong>and <strong><span> </span>iRely LLC, (&quot;iRely&quot;). </strong></p>
    <p><strong>1) SCOPE OF MASTER AGREEMENT AND SCHEDULES</strong></p>
    <p>This Agreement includes several Schedules appended hereto, each of which is incorporated herein by reference. Note: All schedules may not be applicable</p>
    <ul>
        <li>Schedule 1 – Proposal defines the scope of goods and services to be provided under this Master Agreement.</li>
        <li>Schedule 2.1 – License defines the rights granted in the Software should the Customer select to have the Software installed on its own servers.</li>
        <li>Schedule 2.2 – SaaS defines the rights granted in the Software should the Customer select Software as a Service.</li>
        <li>Schedule 3 – Statement of Work and Service Agreement describes what iRely will provided to Customer.</li>
        <li>Schedule 4 – Maintenance Agreement describes how iRely will maintain the Software provided to Customer.</li>
        <li>Schedule 5 – Invoicing and Payment describes how iRely will invoice Customer and Customer’s payment obligations.</li>
        <li>Schedule 6 – Change Procedure describes the process by which the parties shall modify the scope of goods and services during the Term of this Master Agreement.</li>
        <li>Schedule 7 – Should the Customer choose to have iRely host Customer data on its servers, the Hosting Agreement provides the terms and conditions by which iRely will host Customer data on its servers.</li>
        <li>Schedule 8 – Privacy Policy provides iRely’s privacy policies and GDPR compliance.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>2) DEFINITIONS</strong></p>
    <p>The following definitions apply to this Master Agreement and the attached Schedules. Additional capitalize terms used in this Master Agreement or attached Schedules shall have the meaning described therein.</p>
    <p><strong> </strong></p>
    <ul>
        <li>“Affiliate(s)” means any corporation or other entity controlled by, controlling, or under common control with any Party, and “Control” means the direct or indirect beneficial ownership of a majority interest in the voting stock, or other ownership interests, of such corporation or entity, or the power to elect at least a majority of the directors or trustees of such corporation or entity, or majority control of such corporation or entity, or such other relationship, which in fact constitutes actual control.</li>
        <li>“Application” means the modules, platform, user interfaces, on-line help, and associated Documentation of iRely to which Customer may have access.</li>
        <li>“Customer Data” means any data, information, content, or material, which Customer or its Affiliates enter, load onto, or use in connection with the Application, and all results from processing the same while using the Application.</li>
        <li>“Documentation” means the user and technical information, provided to Customer by iRely, regarding the access and use of the Application by means of an on-line help system describing the operation of the Application under normal circumstances.</li>
        <li>“Hosted” means the execution of the Application on a Server as directed by iRely, without any installation of software source code or object code, on a computer owned or operated by Customer.</li>
        <li>“Initial Term” means the first period this Agreement is in effect, beginning on the Effective Date and continuing for the period stated in Schedule 1 - Proposal, and for which the applicable Subscription Fee has been paid.</li>
        <li>“Intellectual Property Rights” means, on a worldwide basis, any (i) copyrights and copyrightable works, whether registered or unregistered; (ii) trademarks, service marks, trade dress, logos, registered designs, trade and business names (including internet domain names, corporate names, and e-mail address names), whether registered or unregistered; (iii) patents, patent applications, patent disclosures, mask works and inventions (whether patentable or not); (iv) trade secrets, know-how, data privacy rights, database rights, know-how, and rights in designs; and (v) all other forms of intellectual property or proprietary rights, and derivative works thereof, in each case in every jurisdiction worldwide.</li>
        <li>“Renewal Term” means each successive twelve-month period following the Initial Term, during which the Agreement shall remain in effect, provided, Customer pays the applicable Subscription Fee in advance, and the Agreement is not otherwise terminated.</li>
        <li>“Subscription” means the use and access rights to the Application granted by iRely to Customer and related responsibilities, as described in this Agreement.</li>
        <li>“Subscription Fee” means, in U.S. Dollars, the fee to access and use features of the Application, and to receive the Standard Support Services, during the corresponding Subscription Period.</li>
        <li>“Term” means the period this Agreement is in effect, including the Initial Term and any Renewal Term(s).</li>
        <li>“Update” means any patch, bug fix, correction, update, upgrade, enhancement, minor release, or other modification by iRely to an Application, that is generally small in scope, made generally available by iRely to all its paid-subscription and paid-maintenance customers.</li>
        <li>“User(s)” means Customer’s employees and Affiliates authorized to use the Application in accordance with this Agreement and supplied user identifications and/or passwords in accordance with this Agreement.</li>
        <li>“Versions” means a major release of the Application configuration identified by a number to the left of the decimal point (e.g. 5.0, 6.0), and which generally involves the introduction of significant feature additions, broad upgrades to the user interface, and/or architectural improvements to the technology platform, and may involve the introduction of new modules that iRely, in its sole discretion, decides to make available.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>3) INTELLECTUAL PROPERTY RIGHTS</strong></p>
    <ul>
        <li>Customer Intellectual Property. “Customer IP” means Customer’s Confidential Information, materials, inventions, and data. The Customer IP shall be owned by Customer. Provider may not use, access, reproduce, publish, sell, license, display, or exploit (collectively, “Use”) any Customer IP without Customer’s prior written consent. Except as set forth herein, Provider shall have the right to Use Customer IP to perform the Services. Customer grants Provider a limited, royalty-free, non-exclusive, revocable, terminable license to Use the Customer IP as necessary for Provider to perform the Services. Schedule 2 – iRely License sets forth the License terms. Alternatively, if Customer has selected Software as a Service (“SaaS”), Schedule 2 – iRely SaaS sets forth the applicable terms. Provider’s Use of Customer IP shall not create any right in its favor and if any such right, title, or interest is created by operation of law.</li>
        <li>Provider Intellectual Property. “Provider IP” means any item or material, including intellectual property (such as written materials, software, its configurations and standard reporting and interfaces, websites or patented inventions) or physical assets (such as equipment or other products), that is: (a) owned, leased or licensed by Provider or Provider’s Affiliates or subcontractors (other than licensed from Customer hereunder); or (b) furnished by Provider in connection with the Services. “Provider IP” includes all modifications or enhancements. The Provider IP shall be owned by Provider. Please refer to Schedule 2 – iRely License for details on granting of license. Customer shall not use Provider IP for any purpose not expressly permitted in this Agreement.</li>
        <li>If the Customer has chosen to Host its license application, please refer to Schedule 7 – iRely Hosting, for details on the hosting arrangement.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>4) PRODUCTS, SERVICES, AND DELIVERABLES</strong></p>
    <ul>
        <li>“Products” means hardware or software sold or licensed by Provider as set forth in either Schedule 2.1 (License) or 2.2 (Saas).</li>
        <li>“Services” include (i) the services described in the Agreement, including all Schedules, and (ii) those services, responsibilities and activities, whether described in this Agreement that are reasonably necessary for the proper performance and provision of the services described in this Agreement.</li>
        <li>“Deliverables” means information and other materials prepared for Customer during the performance of the Services. Please refer to Schedule 3 – iRely SOW and Service Agreement. </li>
        <li>All Services shall be performed in a workmanlike and professional manner by qualified representatives of Provider who are fluent in written and spoken English. Provider shall minimize any disruption of Customer’s business operations and optimize Customer’s use of the Software.</li>
        <li>Non-Exclusive Agreement. iRely may solicit and perform similar Services on behalf of companies that Customer may consider to be its direct or indirect competitors. Information regarding Customer, products, programs, services, procedures are confidential and proprietary to Customer. iRely shall not divulge or use such information in a manner that will impair Customer’s competitive position in the marketplace. This restriction does not apply to information of a public nature or that is already known to iRely prior to disclosure to it by Customer.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>5) MAINTENANCE SERVICES</strong></p>
    <p>Please refer to Schedule 4 – iRely Maintenance Agreement.</p>
    <p>
        <br />
    </p>
    <p><strong>6) PAYMENT AND INVOICING</strong></p>
    <p>Please refer to Schedule 5 – Payment and Invoicing. </p>
    <p>
        <br />
    </p>
    <p><strong>7) CONFIDENTIAL INFORMATION</strong></p>
    <ul>
        <li>A Party receiving Confidential Information (as defined below) shall be the “Recipient” and the Party disclosing such information shall be the “Disclosing Party.”</li>
        <li>Confidential Information. “Confidential Information” means all financial, technical, strategic, marketing, and other information relating to the Disclosing Party or its actual or prospective business, products, or technology that may be, or has been, furnished or disclosed to Recipient by, or acquired by Recipient directly or indirectly from the Disclosing Party, whether disclosed orally or in writing or electronically or some other form, and shall include the terms and conditions and pricing information of this Agreement, and the iRely’s Application (including, without limitation, Documentation, source code, translations, compilations, implementation methodologies, partial copies, and derivative works).</li>
        <li>Confidential Information does not include that which was: (i) as of the Effective Date of this Agreement, generally known to the public without breach of this Agreement; (ii) is or became generally known to the public after the date of this Agreement other than as a result of the act or omission of Recipient or Recipient’s Affiliates; (iii) was already in the possession of the Recipient without any obligation of confidence; (iv) released by Disclosing Party with its written consent to third parties without restriction on use and disclosure; (v) lawfully received by Recipient from a third party without an obligation of confidence; or (vi) independently developed by Recipient outside the scope of this relationship by personnel not having access to any Confidential Information; or (vii) is required to be disclosed in accordance with a judicial or governmental order or decree, provided that the Recipient provides prompt notice of the order or decree to the Disclosing Party and reasonably cooperates with the Disclosing Party to limit the disclosure and use of the applicable information.</li>
        <li>Non-Disclosure. From receipt of Confidential Information, the Recipient shall do the following:
            <ul>
                <li>use at least the same degree of care that it uses with respect to its own confidential information, but in no event less than a reasonable degree of care to avoid disclosure, publication or dissemination of the other Party’s Confidential Information;</li>
                <li>disclose Confidential Information only to its personnel who have a need to know;</li>
                <li>disclose Confidential Information only to third parties who have entered into an appropriate confidential disclosure agreement with the Recipient, prior to any disclosure of Confidential Information, and to whom such disclosure has been previously authorized in writing by the Disclosing Party; and</li>
                <li>promptly report any loss of any Confidential Information to the Disclosing Party.</li>
            </ul>
        </li>
        <li>Notices. Recipient shall not: (i) alter or remove from any Confidential Information of the Disclosing Party any proprietary legend, or (ii) decompile, disassemble or reverse engineer the Confidential Information (and any information derived in violation of such covenant shall automatically be deemed Confidential Information owned exclusively by the Disclosing Party).</li>
        <li>Return of Confidential Information. Upon the written request of the Disclosing Party or termination or expiration of this Agreement, and regardless of whether a dispute may exist, Recipient shall return or destroy (as instructed by Disclosing Party) all Confidential Information of Disclosing Party in its possession or control and cease all further use thereof.</li>
        <li>Injunctive Relief. Recipient acknowledges that violation of the provisions of this Confidentiality Section would cause irreparable harm to Disclosing Party not adequately compensable by monetary damages. In addition to other relief, it is agreed that injunctive relief shall be available without the necessity of posting bond to prevent any actual or threatened violation of such provisions.</li>
        <li>“Personally Identifiable Information” or “PII” means information which can be used to distinguish or trace an individual’s identity, either alone or when combined with other personal or identifying information, which is linked or linkable to a specific individual. If iRely has access to PII (except for business contact information and e-mail addresses of the Customer), such access will likely be incidental. The intended purpose of the Application is not to accept or use PII. Customer shall retain control of its PII. To the extent iRely has incidental access to Customer PII, iRely shall use or disclose PII only: (i) in furtherance of or in performing the services pursuant to this Agreement and the relevant Statement of Work; (ii) pursuant to a lawful subpoena, service of process, or otherwise required or permitted by law; (iii) as directed or instructed by Customer; or (iv) with prior informed consent of the individual about whom the PII pertains.</li>
        <li>Survival. This Section shall survive termination of this Agreement.</li>
        <li>Publicity. iRely shall have the right, and Customer hereby consents, to 1) list Customer’s logo as an iRely client on iRely’s website and on marketing materials and include a link to Customer’s website and company introduction; and 2) mention Customer as an iRely Customer during sales pitches to iRely prospects. iRely will seek Customer’s consent prior to using Customer’s name in White Papers or other similar written material.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>8) INDEMNIFICATION</strong></p>
    <ul>
        <li>Mutual Indemnity. Each party (“Indemnifying Party”) will indemnify, pay and reimburse for, defend and hold harmless the other party, its Affiliates, and their respective employees, directors, managers, officers, partners, shareholders, contractors, and agents (collectively, the “Indemnified Persons”), from and against any and all claims, liabilities, demands, suits, actions, or other proceedings brought by third parties (each a “Claim”), and all losses, damage, judgments, payments made in settlement, and costs and expense, including reasonable attorneys’ fees and disbursements and court costs as a result of such Claims: (a) relating to bodily injury or death of any person or damage, loss, or theft to real and/or tangible personal property arising out of negligence, dishonest or willful acts, or omissions to the extent directly or indirectly caused by the Indemnifying Party, its personnel, subcontractors, or agents; or (b) relating to or arising out of the Indemnifying Party’s, its personnel, subcontractors’, or agents’ performance of its obligations under this Agreement; or (c) the breach or alleged breach of any representation, warranty, or covenant of this Agreement or the inaccuracy of any representation made by Indemnified Persons herein, or (d) Party’s failure to comply with any applicable law, including any Data Protection Law.</li>
        <li>Indemnification Procedures. An Indemnified Person must promptly give written notice to the Indemnifying Party of any Claim. The Indemnifying Party may elect to retain counsel of its choice to represent the Indemnified Person in connection with any Claim and will pay all fees and costs of such counsel. An Indemnified Person may participate at its own expense and through legal counsel of its choice in any such Claim. The Indemnifying Party will not settle any Claim without the prior written consent of the Indemnified Person, which shall not be unreasonably withheld. However, the Indemnified Person may assume control of the defense of the Claim and retain counsel reasonably acceptable to the Indemnifying Party, if (a) the Indemnifying Party does not to assume control of the defense; (b) conflicts of interest exist between the parties with respect to the Claim; or (c) the other party to the Claim is seeking relief which in an Indemnified Person’s reasonable judgment may adversely affect the Indemnified Person’s business. In this case, the fees, charges, and disbursements of no more than one counsel per jurisdiction selected by the Indemnified Person will be reimbursed by the Indemnifying Party.</li>
        <li>Infringement Indemnification.
            <ul>
                <li>iRely shall defend Customer against any third-party claims, costs, damages, losses, liabilities, and expenses (including reasonable attorneys’ fees and costs) finally adjudicated by a court of competent jurisdiction and arising out of a claim alleging that the Application directly infringes a valid registered U.S. patent issued as of the Effective Date, provided, that Customer does the following: (a) promptly gives written notice of the claim to iRely; (b) gives iRely sole control of the defense and settlement of the claim (provided that Customer may not settle or defend any claim without prior review and agreement by Customer); (c) provides to iRely all available information and reasonable assistance; and (d) has not compromised or settled such claim.</li>
                <li>Customer shall defend iRely against any third-party claims, costs, damages, losses, liabilities, and expenses (including reasonable attorneys’ fees and costs) arising out of a claim alleging: (i) that use of the Customer Data infringes the rights of, or has caused harm to, a third party; or (ii) infringement of third-party rights arising from the combination of the Application with any of Customer products, service, hardware or business process(s), provided that iRely does the following: (a) promptly gives written notice of the claim to Customer; (b) gives Customer sole control of the defense and settlement of the claim (provided that Customer may not settle or defend any claim without prior review and agreement by iRely); (c) provides to Customer all available information and reasonable assistance; and (d) has not compromised or settled such claim.</li>
            </ul>
        </li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>9) CHANGE CONTROL PROCEDURE</strong></p>
    <p>Please refer to Schedule 6 – Change Control Procedure</p>
    <p>
        <br />
    </p>
    <p><strong>10) TERM; TERMINATION</strong></p>
    <ul>
        <li>Initial Term. The initial term of this Agreement shall commence on the Effective Date herein and shall continue in full force and effect and unless extended or terminated earlier pursuant to this Agreement or stated in a Schedule.</li>
        <li>Renewal Term. Customer shall have the right to renew this Agreement and the applicable Schedule(s). Such Renewal Term will automatically renew unless Customer provides Provider with written notice of its intent to cancel at least 60 days before the expiration of the Initial Term or the then current Renewal Term.</li>
        <li>Either party may terminate this Agreement, (i) upon thirty (30) days prior written notice, in the event that the other party materially breaches a provision of the Agreement and fails to cure such breach within the thirty (30) days after it receives such notice (or immediately, if such breach is not capable of being cured) or (ii) in accordance with Section 9 (Force Majeure).</li>
        <li>Either party may terminate this Agreement immediately upon written notice, if the other Party becomes insolvent; or files, or has filed against it and not dismissed within sixty (60) days, a petition for bankruptcy.</li>
        <li>Provider may terminate this Agreement on sixty (60) days written notice if Customer fails to make timely payments hereunder.</li>
        <li>When the Agreement terminates or expires:
            <ul>
                <li>Customer will pay Provider for all Services performed and expenses incurred by Provider prior to the date of termination.</li>
                <li>Provider will: (i) deliver to Customer all Deliverables and Products for which Customer has paid; (ii) and immediately discontinue (and cause its contractors and personnel to immediately discontinue) all use of Customer Materials. Upon termination or expiration of Agreement, this clause does not permit Customer to retain Provider Materials for any purpose and Customer must return Provider Materials within 10 days.</li>
            </ul>
        </li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>11) F</strong><strong>ORCE MAJEURE</strong></p>
    <p>Neither party will be liable under, or deemed to be in breach of, this Agreement for any delay or failure in performance under this Agreement or the applicable Order Document that is caused by any of the following events: acts of God, civil or military authority, the public enemy, or war; accidents; fires; explosions; power surges; earthquakes; floods; unusually severe weather; strikes or labor disputes (excluding Provider’s subcontractors); delays in transportation or delivery as a result of a Force Majeure Event; epidemics; terrorism or threats of terrorism; and any similar event that is beyond the reasonable control of the non-performing party (“Force Majeure Event”). The party affected by the Force Majeure Event must diligently attempt to perform (including through alternate means). During a Force Majeure Event, the parties will negotiate changes to this Agreement in good faith to address the Force Majeure Event in a fair and equitable manner. If a Force Majeure Event continues for ten (10) days or longer, and the non-performing party is delayed or unable to perform under this Agreement or any Order Document because of the Force Majeure Event, then the other party will have the right to terminate this Agreement or the Order Document, in whole or in part, upon written notice to the non-performing party.</p>
    <p><strong> </strong></p>
    <p><strong>12) DISCLAIMERS AND LIMITATIONS OF LIABILITIES  </strong></p>
    <ul>
        <li>Except as expressly set forth in this Agreement, neither Party makes, and each such Party hereby specifically disclaims, all representations and warranties express or implied, arising by law or otherwise, arising under or relating to this Agreement.</li>
        <li>EXCEPT AS OTHERWISE STATED IN THE AGREEMENT, THE SOFTWARE, HOSTING SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND SERVICES PROVIDED TO CUSTOMER HEREUNDER ARE “AS IS”, AND iRely MAKES NO REPRESENTATIONS OR WARRANTIES, ORAL OR WRITTEN, EXPRESS OR IMPLIED, ARISING FROM COURSE OF DEALING, COURSE OF PERFORMANCE, USAGE OF TRADE, QUALITY OF INFORMATION, QUIET ENJOYMENT OR OTHERWISE, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, NON-INTERFERENCE, OR NON-INFRINGEMENT WITH RESPECT TO THE SOFTWARE, HOSTING SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND SERVICES PROVIDED TO CUSTOMER HEREUNDER OR WITH RESPECT TO ANY OTHER MATTER PERTAINING TO THIS AGREEMENT. CUSTOMER’S USE OF THE SOFTWARE, HOSTING SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND SERVICES PROVIDED TO CUSTOMER HEREUNDER WILL NOT BE DEEMED LEGAL, TAX OR INVESTMENT ADVICE. </li>
        <li>iRely''S TOTAL LIABILITY UNDER THIS AGREEMENT WILL UNDER NO CIRCUMSTANCES EXCEED THE AMOUNT ACTUALLY PAID BY CUSTOMER TO iRely UNDER THIS AGREEMENT DURING THE THREE (3) MONTHS PRIOR TO THE EVENT OF LIABILITY.</li>
        <li>UNDER NO CIRCUMSTANCES WILL iRely (OR ANY iRely AFFILIATES PROVIDING SOFTWARE, HOSTING SERVICES, SAAS SERVICES, PROFESSIONAL SERVICES AND OTHER GOODS AND SERVICES TO CUSTOMER HEREUNDER) BE LIABLE TO CUSTOMER, ANY AUTHORIZED USER OR ANY OTHER PERSON FOR LOST REVENUES, LOST PROFITS, LOSS OF BUSINESS, TRADING LOSSES, OR ANY INCIDENTAL, INDIRECT, EXEMPLARY, CONSEQUENTIAL, SPECIAL OR PUNITIVE DAMAGES OF ANY KIND, INCLUDING SUCH DAMAGES ARISING FROM ANY BREACH OF THIS AGREEMENT OR ANY TERMINATION OF THIS AGREEMENT, WHETHER SUCH LIABILITY IS ASSERTED ON THE BASIS OF CONTRACT, TORT (INCLUDING NEGLIGENCE OR STRICT LIABILITY) OR OTHERWISE AND WHETHER OR NOT FORESEEABLE, EVEN IF iRely HAS BEEN ADVISED OR WAS AWARE OF THE POSSIBILITY OF SUCH LOSS OR DAMAGES.</li>
        <li>iRely will have no liability to Customer under the following circumstances: Customer fails to follow iRely’s instructions relating to, as applicable, the Software, Hosting Services or SaaS Services; and/or the Software, Hosting Services or SaaS Services, as applicable, are used in violation of this Agreement; as applicable, the Software is configured, customized, installed or maintained by anyone other than iRely; as applicable, Customer modifies any Software without the prior written consent of iRely; and/or the Software, Hosting Services or SaaS Services are used in conjunction with any hardware, software, products or interfaces not specified by iRely. The obligations of iRely under this Agreement run only to Customer and not to its Affiliates, Authorized Users or any other Persons. Under no circumstances will any Affiliate, Authorized User or client of Customer or any other Person be considered a third-party beneficiary of this Agreement or otherwise entitled to any rights or remedies under this Agreement, even if such Affiliates, Authorized Users, clients or other Persons are provided access to any Hosting Services, SaaS Services or Professional Services. Customer will have no rights or remedies against iRely except as specifically provided in this Agreement. No action or claim of any type relating to this Agreement may be brought or made by Customer more than one (1) year after Customer first has knowledge of the basis for the action or claim.</li>
        <li>The exclusions, disclaimers and limitations provided in this Agreement have been considered by the Parties in the pricing of the Goods and Services provided in this Agreement.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>13) NOTICES</strong></p>
    <p>All notices from one Party to the other under this Agreement will be in writing and will be deemed given when (i) delivered personally with receipt signature; (ii) sent via certified mail with return receipt requested; (iii) sent via telex, telecopier or fax, all with confirmation of receipt; or (iv) sent by commercially recognized air courier service with receipt signature required, to the following address:</p>
    <p style="text-align: center;">if to iRely:</p>
    <p>
        <br />
    </p>
    <p style="text-align: center;">iRely, LLC</p>
    <p style="text-align: center;">4242 Flagstaff Cove</p>
    <p style="text-align: center;">Ft. Wayne, Indiana, 46815</p>
    <p style="text-align: center;">ATTENTION: Chris Pelz (<a class="external-link" style="text-decoration: none;" href="mailto:chris.pelz@irely.com" rel="nofollow">chris.pelz@iRely.com</a>)</p>
    <p>
        <br />
    </p>
    <p style="text-align: center;">if to CUSTOMER:</p>
    <p>
        <br />
    </p>
    <p style="text-align: center;">[NAME &amp; ADDRESS]</p>
    <p style="text-align: center;">ATTENTION: ____________________________________________</p>
    <p style="text-align: center;">and</p>
    <p style="text-align: center;">ATTENTION: ____________________________________________</p>
    <p><strong> </strong></p>
    <p><strong> </strong></p>
    <p><strong>14) REPRESENTATIONS AND WARRANTIES OF CUSTOMER</strong></p>
    <ul>
        <li>Customer owns Customer Data or has all necessary rights to use and input Customer Data into the Application;</li>
        <li>Customer Data shall not infringe upon any third-party Intellectual Property Rights or violate any rights against defamation or rights of privacy;</li>
        <li>Customer has not falsely identified itself nor provided any false information to gain access to the Application and that Customer’s billing information is correct.</li>
        <li>If Customer resides in the European Union (EU) or if any transfer of information between Customer and the Application is governed by the European Union Data Protection Directive or national laws implementing that Directive, then Customer expressly consents to the transfer of such information outside of the European Union to the United States and to such other countries as may be contemplated by the features and activities of the Application under this Agreement. Customer will indemnify iRely against all claims asserted against it under the GDRP.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>15) EXPORT CONTROL</strong></p>
    <ul>
        <li>iRely provides services and uses software and technology that may be subject to U.S. export controls administered by the U.S. Department of Commerce, the U.S. Department of Treasury Office of Foreign Assets Control, and other U.S. agencies and other international export control regulations. Customer shall comply strictly with all relevant export laws and assume sole responsibility for obtaining licenses to export or re-export as may be required for Customer Data.</li>
        <li>The Application may use encryption technology that is subject to licensing requirements under the U.S. Export Administration Regulations.</li>
        <li>iRely and its licensors make no representation that the Application is appropriate or available for use in other locations. Customer is solely responsible for compliance with all applicable laws, including without limitation export and import regulations of other countries. Any diversion of the Customer Data contrary to U.S. and other relevant law is prohibited. None of the Customer Data, nor any information acquired using the Application, is or will be used for nuclear activities, chemical, or biological weapons, or missile projects, unless specifically authorized by the U.S. government or appropriate European body for such purposes.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>16) INTEGRATION AND AMENDMENTS</strong></p>
    <p>This Agreement and the attached Schedules constitute a complete and exclusive final written expression of the terms of agreement between the Parties regarding the subject matter hereof. It supersedes all earlier and contemporaneous agreements, understandings and negotiations concerning the subject matter. The Parties may amend this Agreement only in writing, and no oral representation or course of dealing shall modify this Agreement.</p>
    <p>
        <br />
    </p>
    <p><strong>17) SECURITY, NO CONFLICTS</strong></p>
    <p>Each Party shall inform the other of any information made available to the other Party that is classified or restricted data, shall comply with the security requirements imposed by any state or local government, or by the United States Government, and shall return all such material upon request. Each Party represents and warrants that its participation in this Agreement does not conflict with any contractual or other obligation of the Party or create any conflict of interest and shall promptly notify the other Party if any such conflict arises during the Term.</p>
    <p>
        <br />
    </p>
    <p><strong>18) INSURANCE</strong></p>
    <p>Each Party shall maintain adequate insurance protection covering its respective activities hereunder, including coverage for statutory workers'' compensation, comprehensive general liability for bodily injury and tangible property damage, and shall provide Certificates of Insurance to the other Party, upon reasonable request, evidencing such coverage and amounts.</p>
    <p>
        <br />
    </p>
    <p><strong>19) GOVERNING LAW AND DISPUTES</strong></p>
    <ul>
        <li>The construction and performance of this Agreement shall be governed by the substantive laws of the United Stated and the laws of the State of Indiana, without regard to its conflicts of law’s provisions. The United Nations Convention on Contracts for the International Sale of Goods shall not apply to this Agreement. Any claim by one Party against the other Party must be brought within one year after it arose.</li>
        <li>Any controversy or claim arising out of or relating to this Agreement, or the breach thereof, shall be settled by arbitration administered by the American Arbitration Association in accordance with its Commercial Arbitration Rules, and judgment on the award rendered by the arbitrator(s) may be entered in any court having jurisdiction thereof. The arbitration shall be conducted in Allen County, Indiana by a single arbitrator appointed by the AAA. Any appeal of the arbitration decision shall be brought exclusively in the federal or state courts situated in Allen County, Indiana. Customer consents to personal jurisdiction and venue in Allen County, Indiana.</li>
        <li>iRely shall be entitled to its reasonable attorneys’ fees, costs and expenses if it prevails in any legal dispute with Customer.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>20) GDPR</strong></p>
    <p>Schedule 8 contains iRely’s Privacy Policy.</p>
    <p>
        <br />
    </p>
    <p><strong>21) ASSIGNMENT OR CHANGE IN CONTROL</strong></p>
    <p>This Agreement may not be assigned by either Party without the prior written approval of the other Party but may be assigned without consent in the event of a merger or reorganization in which the surviving entity owns or controls more than 50% of the acquired Party and agrees in writing to assume the obligations under this Agreement. Any purported assignment in violation of this section shall be void. Any actual or proposed change in control of Customer that results, or would result, in a direct competitor of iRely directly or indirectly owning or controlling 50% or more of Customer shall entitle iRely to terminate this Agreement for cause immediately upon written notice.</p>
    <p><strong> </strong></p>
    <p><strong>22) SEVERABILITY</strong></p>
    <p>If any provision of this Agreement is held by a court of competent jurisdiction to be invalid or unenforceable, then such provision(s) shall be construed, as nearly as possible, to reflect the intentions of the invalid or unenforceable provision(s), with all other provisions remaining in full force and effect.</p>
    <p><strong> </strong></p>
    <p><strong>23) NO AGENCY</strong></p>
    <p>The Parties acknowledge and agree that each is an independent contractor, and nothing herein constitutes a joint venture, partnership, employment, or agency between Customer and iRely because of this Agreement or use of the Application. Neither Party shall have the right to bind the other Party or cause it to incur liability.</p>
    <p>
        <br />
    </p>
    <p><strong>24) WAIVER</strong></p>
    <p>The failure of either Party to enforce any right or provision in this Agreement shall not constitute a waiver of such right or provision unless acknowledged and agreed to by such Party in writing.</p>
    <p>
        <br />
    </p>
    <p><strong>25) NON-SOLICITATION</strong></p>
    <p>During the Term of this Agreement and for a period of one year thereafter, neither party will, except with the other Party’s prior written approval, solicit the employment of any employee, consultant or subcontractor of such other Party that directly participated in the activities set forth in this Agreement. The foregoing shall specifically not apply to general solicitations of employment issued by either Party to which an employee of the other may voluntarily respond.</p>
    <p>
        <br />
    </p>
    <p><strong>26) CUSTOMER LIST</strong></p>
    <p>Customer consents to the use of Customer’s name and the Customer’s logo, exactly in the form as provided by Customer to iRely, in iRely''s customer list on its website and in its marketing materials, during the Term of this Agreement. Customer agrees to work with iRely to provide a testimonial 6 months after they go live on the iRely system.</p>
    <p>
        <br />
    </p>
    <p><strong>27) SURVIVABILITY</strong></p>
    <p>The following Sections shall survive termination of this Agreement: 1, 5, 6, 7(E), 8, 12, 15, 16, 19(D), 20, 24, 25, 27, 29, and 31.</p>
    <p>
        <br />
    </p>
    <p><em>By clicking the &quot;I agree&quot; box you acknowledge that you are entering into a legally binding contract with iRely, and that you have read, understood, and agreed to the terms set forth herein, including all applicable schedules.</em></p>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <h1 class="with-breadcrumbs"><a style="text-decoration: none;" href="http://help.irelyserver.com/display/DOC/Schedule+2.1+-+irely+Software+License+Agreement">Schedule 2.1 - iRely Software License Agreement</a></h1>
    <p>This SOFTWARE LICENSE AGREEMENT (the<span> </span><strong>“License Agreement”</strong>), a Schedule to the Master Services Agreement (the “<strong>Master</strong><span> </span><strong>Agreement</strong>”), is effective as of acceptance of agreement between<span> </span><strong>Customer</strong><span> </span>(“<strong>Customer</strong>”) and<span> </span><strong>iRely, LLC<span> </span></strong>(“<strong>Provider</strong>”). This License Agreement shall be governed by and is incorporated by reference into the Master Agreement. The parties agree:</p>
    <p>
        <br />
    </p>
    <p><strong>1) SOFTWARE LICENSE</strong></p>
    <ul>
        <li>Grant of License. Provider hereby grants to Customer for the use and benefit of its permitted users (“<strong>Permitted Users</strong>”) a revocable, royalty-bearing, personal, non-transferable, non-sublicensable, limited-scope license to use Provider’s software (the “<strong>Software</strong>”) and documentation (“<strong>Documentation</strong>”) described in the<span> </span><u>iRely Master Agreement</u><span> </span>solely for the Customer in the ordinary course of business operations and for its own business purposes. The Software and Documentation will be used only at Customer’s locations(s) and only by the number of users specified in the Proposal.</li>
        <li>Product and Documentation. The Software is a “Product” as defined in the Agreement. Provided the Maintenance Agreement remains in effect, the Software includes any updates, upgrades, patches, new versions, new releases, bug fixes, technological improvements and enhanceme The Documentation includes materials created by or on behalf of Provider that describe or relate to the functional, operational, or performance capabilities of the Software, regardless of whether such materials are printed or electronic, including but not limited to: all operator’s and user manuals, training materials, guides, commentary, technical, design or functional specifications, requirements documents, product descriptions, proposals, schedules, listings and other materials related to the Software.</li>
        <li>Provider shall provide permanent passwords or license keys for all licensed Software that requires passwords or license keys for proper and complete operation thereof. Provider owns all rights, title and interest in and to the Software and Documentation and has the right to grant the licenses granted in this Licensing A</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>2) INSTALLATION OF SOFTWARE</strong></p>
    <ul>
        <li>Upon execution of the Agreement, including all Schedules, and payment of the Royalty, Provider shall install the Software within a commercially reasonable time at Customer’s designated location(s) and provide a link to the online help desk. If there is delay in signing the Agreement or receiving payment, the project plan and anticipated go live date will adjust to accommodate such delay. </li>
        <li>Customer shall designate a primary contact to assist with installation of software and ensure all technical requirements are met.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>3) COPIES</strong></p>
    <ul>
        <li>License Copies. Customer and Permitted Users shall have the right to make one operational copy and one backup copy for archival purposes.</li>
        <li>Documentation Copies. Customer may reproduce the Documentation as reasonably necessary to support internal use of the Software.</li>
        <li>Software Rights to Use. Copies of the Software created or transferred pursuant to this Agreement are licensed, not sold, and Customer receives no title to or ownership of any copy or of the Software itself. Furthermore, Customer receives no rights to the Software other than those specifically granted above. Customer shall not: (a) copy, modify, derivate, distribute, publicly display, publicly perform, or sublicense the Software; (b) use the Software for service bureau or time-sharing purposes or in any other way allow third parties to exploit the Software; or (c) reverse engineer, decompile, disassemble, or otherwise attempt to derive any of the Software’s source code.</li>
        <li>Emergency Use of Software on Other Computer(s). Customer shall have the right to temporarily use the Software and Documentation on back-up computers at any location for disaster recovery and emergency purposes. As soon as practical after cessation of the disaster or emergency, Customer and its Affiliates shall remove the Software and Documentation from the back-up computers. Customer and its Affiliates shall also have the right to periodically activate and test the Software on such back-up computers for evaluating and verifying emergency and disaster recovery techniques and procedures. If license keys, passwords or other information from Provider are required to use the Software on such other computers, Provider shall provide to Customer.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>4) EXCESS USE</strong><strong> </strong></p>
    <ul>
        <li>Customer’s License is limited to the specific number of users stated in the Proposal. Customer may purchase additional user Licenses. iRely’s remedy for such non-compliance will be to collect additional fees from Customer for such additional use. Such additional fees will be calculated on a pro rata basis based upon the agreed fees for the relevant Softwa Should non-compliance be deemed to be an intentional act, iRely may consider action a material breach of the Master Agreement.</li>
        <li>iRely may inspect and audit Customer’s servers and facilities to determine Customer’s compliance with the Software license and Authorized Users limitations. If iRely determines that a noncompliance has occurred, in addition to iRely’s other remedies, Customer will promptly pay iRely, as applicable, all additional software license and service fees due iRely, together with all reasonable out-of-pocket costs and expenses of such audit. </li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>5) ACCEPTANCE</strong></p>
    <p>Applicable Software deliverables under all Proposals will be accepted by Customer when the acceptance criteria, if any, specified in applicable Proposals have been met. Where no Software acceptance criteria are specified, such deliverables will be deemed accepted upon contract execution.</p>
    <p>
        <br />
    </p>
    <p><strong>6) WARRANTY</strong> </p>
    <ul>
        <li>Provider is duly organized, validly existing and in good standing under the laws of the state of its incorporation (ii) has all requisite power and authority to enter into a perform its obligations under this agreement and execution of this agreement is not in violation of any other agreement to which Provider has previously assented; and (iii) has not been the subject of any actions, suits, or proceedings that may have an adverse effect on its ability to fulfill its obligations under this agreement or on its operations, business, properties, assets, or conditio</li>
        <li>All Services provided by Provider shall be performed in a workmanlike and professional manner by properly qualified representatives of Provider who are fluent in written and spoken Englis</li>
        <li>Provided Customer uses the Software, Enhancements and Documents for their intended use, the use of the Software, Enhancements and Documentation by Customer does not violate United States law.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>7) INTELLECTUAL PROPERTY OWNERSHIP; LICENSES</strong></p>
    <ul>
        <li>Software. Software is owned by Provide This License Agreement does not grant any additional rights to Customer beyond those expressly set forth. Provider shall own all computer programs and enhancements developed for Customer.</li>
        <li>Data. Customer shall own all right, title and interest to data input and output arising out of the use of the Software.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>8) PROVIDER INTELLECTUAL PROPERTY INDEMNITY</strong></p>
    <ul>
        <li>Indemnified Claims. Provider shall defend and indemnify Customer against any “<u>Indemnified Claim</u>,” meaning any third-party claim, suit, or proceeding arising out of, related to, or alleging direct infringement of any patent, copyright, trade secret, or other intellectual property right by the Software. Provider’s obligations set forth in this Section 1 do not apply to the extent that an Indemnified Claim arises out of: (a) Customer’s breach of this Agreement; (b) revisions to the Software made without Provider’s written consent; (c) Customer’s failure to incorporate Upgrades that would have avoided the alleged infringement, provided Provider offered such Upgrades without charges not otherwise required pursuant to this Agreement; (d) Provider’s modification of Software in compliance with specifications provided by Customer; or (e) use of the Software in combination with hardware or software not provided by Provider. In the event of an Indemnified Claim, Provider may exercise its right to terminate licenses and require return of the Software.</li>
        <li>Litigation &amp; Additional Terms. Provider’s obligations pursuant to Section 1 above will be excused to the extent that Customer’s failure to provide prompt notice of the Indemnified Claim or to cooperate reasonably with the defense to such claims. Provider will control the defense of any Indemnified Claim, including appeals, negotiations, and any settlement or compromise thereof; provided Customer will have the right, not to be exercised unreasonably, to reject any settlement or compromise that requires that it admit wrongdoing or liability or subjects it to any ongoing affirmative obligations.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>9) FEES</strong></p>
    <p>Fees associated with the Software are outlined in<span> </span><u>Schedule 1 – Proposal</u>. Invoicing and payment terms are outlined in<span> </span><u>Schedule 5 – Charging and Invoicing</u>.</p>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <p><em>By clicking the &quot;I agree&quot; box you acknowledge that you are entering into a legally binding contract with iRely, and that you have read, understood, and agreed to the terms set forth herein, including all applicable schedules.</em></p>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <h1 class="with-breadcrumbs"><a href="http://help.irelyserver.com/display/DOC/Schedule+2.2+-+irely+SAAS+Agreement" style="text-decoration: none;">Schedule 2.2 - iRely SAAS Agreement</a></h1>
    <p>
        <br />
    </p>
    <p>This Subscription Agreement (the<span> </span><strong>“SaaS Agreement”</strong>), a support Schedule to the Master Services Agreement (the “<strong>Master</strong><span> </span><strong>Agreement</strong>”), is effective as of acceptance of agreement between<span> </span><strong>Customer</strong><span> </span>(“<strong>Customer</strong>”) and<span> </span><strong>iRely, LLC<span> </span></strong>(“<strong>Provider</strong>”). This SaaS Agreement shall be governed by and is incorporated by reference into the Master Agreement.</p>
    <p>
        <br />
    </p>
    <p>iRely is in the business of providing (i) access to its hosted software applications for managing extended enterprise data, and (ii) implementation services for such applications. Customer shall obtain access to such applications on a subscription basis under the terms and conditions of this Agreement.</p>
    <p>
        <br />
    </p>
    <p>In consideration of the mutual promises and covenants set forth herein and for other good and valuable consideration, the receipt and sufficiency of which are acknowledged, the Parties agree as follows:</p>
    <p>
        <br />
    </p>
    <p><strong> 1) </strong><strong>DESCRIPTION OF APPLICATION AND SERVICES</strong></p>
    <ul>
        <li>Subscribing to the Application. iRely shall provide to Customer access and use of the Hosted Application described in the Proposal(s), for the Subscription Period specified therein, in consideration of payment of the applicable Subscription Fees, according to the terms and conditions of such Proposal and this Agreement.</li>
        <li>Additional Proposals. Additional Proposals may be entered into by the Parties to subscribe to additional or different features of the Application. Unless designated as replacing a specific outstanding Proposal, a new Proposal will be considered in addition to currently outstanding Proposals. Additional Proposals shall be executed manually by the Parties or submitted electronically through iRely’s online ordering system.</li>
        <li>Accessing User Accounts. User IDs shall be required to access and use the Application. Customer will access and use the Application only through the User IDs and only in accordance with the Subscription terms and other restrictions in this Agreement. Customer shall be responsible for issuing User IDs to such employees and Affiliates as it determines in its sole discretion, in accordance with this Agreement.</li>
        <li>Standard Support Services. iRely shall provide the Support Services as set forth in Schedule 4 – iRely Maintenance Agreement, and for which payment shall be included in the Subscription Fee, unless otherwise specified in the Proposal.</li>
        <li>Hosting and Subcontractors. iRely may in its sole discretion engage, or has engaged, third-parties (“Subcontractors”) to perform Hosting of the Application or other Support Services under this Agreement.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>  2) SUBSCRIPTION RIGHTS AND RESTRICTIONS</strong></p>
    <ul>
        <li>Subscription Grant. For each Application feature referenced on a Proposal, and for which the applicable Subscription Fee is paid when due, iRely hereby grants to Customer a nonexclusive, non-transferrable, worldwide, limited Subscription to do the following: (i) access the Hosted Application through the User IDs; (ii) load Customer Data into the Application; (iii) use the Application for Customer’s own internal business purposes; and (iv) operate the features of the Application during the Subscription Period according to the Documentation, all subject to the terms and conditions of the Proposals and this Agreement. All rights not expressly granted to Customer herein are reserved to iRely and its licensors.</li>
        <li>Type of Subscription. The Subscription grant above is limited to the number of Users specified on the applicable Proposal.</li>
        <li>Subscription Restrictions.
            <ul>
                <li>Customer shall not access, or allow access to, the Application if Customer is in direct competition with iRely, except with iRely’s prior written consent. Customer may not access the Application for purposes of monitoring its availability, performance, or functionality, or for any other benchmarking or competitive purposes. Customer shall not (i) license, sublicense, sell, resell, transfer, assign, distribute, or otherwise commercially exploit or make available to any third party the Application in any way; (ii) modify or make derivative works of the Application; (iii) create Internet “links” to the Application on any other server or wireless or Internet-based device; or (iv) reverse engineer or access the Application in order to (a) build a competitive product or service; (b) build a product using similar ideas, features, functions or graphics of the Application; or (c) copy any ideas, features, functions or graphics of the Application.</li>
                <li>Customer shall not: (i) send spam or otherwise duplicative or unsolicited messages in violation of applicable laws; (ii) send or store infringing, obscene, threatening, libelous, or otherwise unlawful or tortuous material, including material harmful to children or violative of third party privacy rights; (iii) send or store material containing software viruses, worms, Trojan horses, or other harmful computer code, files, scripts, agents, or programs; (iv) interfere with or disrupt the integrity or performance of the Application or the data contained therein; or (v) attempt to gain unauthorized access to the Application or its related systems or networks; (vi) input any data or information into the Application that is: credit card or debit card information, personal banking, financial account information, social security numbers, HIPAA-protected data, or personal confidential information concerning individuals.</li>
                <li>Customer shall not permit Users to share User IDs with each other or with third parties. Customer acknowledges that: (i) iRely shall rely on the validity of any User ID, instruction or information that meets the Application’s automated criteria or which is believed by iRely to be genuine; (ii) iRely may assume a person entering a User ID and password is, in fact, that User; and (iii) iRely may assume the latest email addresses and registration information for Users on file with iRely are accurate and current.</li>
            </ul>
        </li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>3) CUSTOMER RESPONSIBILITIES</strong></p>
    <ul>
        <li>User IDs. Customer shall select its Users in its sole discretion and shall issue to each individual User a User ID to access the Application subject to the limitations and obligations herein, and provided, that Customer shall be responsible for all activity occurring under Customer’s User accounts. Customer shall: (i) notify iRely immediately of any unauthorized use of any password or account or any other known or suspected breach of security; (ii) report to iRely immediately and use reasonable efforts to stop immediately any unauthorized copying or distribution of Customer Data that is known or suspected by Customer or Users; and (iii) not impersonate another iRely customer or provide false identity information to gain access to or use the Application. Customer shall be responsible for its Users’ compliance with the terms of this Agreement and shall ensure that Users shall be obligated in writing to protect User IDs and the Application at least to the extent as provided in this Agreement.</li>
        <li>Data Preparation and Configuration. Customer will ensure that: (i) it maintains Customer Data in proper format as specified by the Documentation or the Statement of Work in a Professional Services Agreement and that its Customer Data does not include personal identifying information (“PII”); (ii) its Personnel are familiar with the use and operation of the Application; and (iii) it does not introduce other software, data, or equipment having an adverse impact on the Application. Following any initial implementation assistance by iRely, Customer shall load the Customer Data and configure the Application, any Updates, and its internal processes, as needed, to operate the Application and any Updates in Customer’s computing environment. Customer, not iRely, shall have sole responsibility for the accuracy, quality, integrity, legality, reliability, appropriateness and right to use of all Customer Data, and iRely shall not be responsible or liable for any deletion, correction, destruction, damage, loss, or failure to store any Customer Data that is caused by Customer or User or the use or misuse of User IDs by a third party.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>4) RESERVATION OF RIGHTS AND iRely </strong><strong>OWNERSHIP</strong></p>
    <p>This Agreement is not a sale and does not convey to Customer any rights of ownership in or related to the Application, or to the Intellectual Property Rights therein owned by iRely. iRely’s name, iRely’s logo, and the product names associated with the Application are trademarks of iRely or third parties, and no right or license is granted to use them. iRely (and its licensors) shall exclusively own all right, title, and interest in and to the Application, copies, modifications, and derivative works thereof. iRely shall own any suggestions, ideas, enhancement requests, feedback, recommendations, or other information provided by Customer or any other party relating to the Application, including all related Intellectual Property Rights thereto, specifically excluding Customer Data.</p>
    <p>
        <br />
    </p>
    <p><strong>5. CUSTOMER DATA OWNERSHIP</strong></p>
    <p>Customer (and its licensors) shall exclusively own all right, title and interest in and to Customer Data and Intellectual Property Rights thereto.</p>
    <p>
        <br />
    </p>
    <p><strong>6. FEES AND PAYMENT</strong></p>
    <ul>
        <li>Subscription Fees and Payment. Customer shall pay the Subscription Fees, in advance, for the rights to access and use the Application during the applicable Subscription Period, as set forth in the Proposal(s), attached to the Master Agreement as Schedule 1. Subscription Fees shall be invoiced annually before the corresponding Subscription Period, which dates may be specified in the Proposal. Invoices shall be due and payable within thirty (30) days of the invoice date, and in no event later than one day before the start of the applicable Subscription Period. Any future Proposals shall be at iRely’s then-published rates or as otherwise agreed by the Parties in the Proposal. All payment obligations for Subscription Fees are non-cancelable and all amounts paid are nonrefundable. Please refer to Schedule 5 – Invoicing and Payment for additional details.</li>
        <li>Data Storage and Backup Fees. The Subscription Fees include the amounts of online data storage and weekly data backups as set forth in the Proposal. If the amount of disk storage required exceeds these limits, Customer will be charged the then-current storage fees at the time the Subscription Fee is due. iRely shall use reasonable efforts to notify Customer when its usage approaches ninety percent (90%) of the allotted storage space; however, any failure by iRely to notify Customer shall not affect Customer’s responsibility for such additional storage charges. Any additional data storage shall be at iRely’s then applicable rates or as otherwise agreed in an Proposal.</li>
        <li>Professional Services Fees. iRely shall invoice Customer weekly in arrears for Professional Services performed pursuant to any Professional Services Agreement at the rates set forth therein. Please refer to Schedule 5 – Payment and Invoicing for additional details.</li>
        <li>Late Payment, Suspension. Customer may not withhold or “setoff” any amounts due hereunder. In addition to any other legal remedies, iRely reserves the right to suspend or terminate Customer’s access to the Application until all amounts due are paid in full after giving Customer advance written notice and an opportunity to cure as specified herein in the Section relating to Termination. Any late payment shall be subject to any costs of collection, including reasonable attorneys’ fees, and shall bear interest at the rate of one percent (1.5%) per month, or the highest rate permitted by law, until paid.</li>
        <li>Prices quoted do not include, and Customer shall pay, any and all applicable taxes, including without limitation, sales, use, gross receipts, value-added, GST, personal property, or other tax (including interest and penalties imposed thereon) on the transactions contemplated herein, other than taxes based on the net income or profits of iRely.</li>
        <li>Pricing Terms. All prices are stated and payable in U.S. Dollars. All pricing terms are confidential, and Customer shall not disclose them to any third party.</li>
        <li>iRely will issue an invoice to Customer each year at the end of a Term or as otherwise mutually agreed upon, unless either Party has given notice of non-renewal.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>7. DATA PROTECTION AND INFORMATION SECURITY</strong></p>
    <p>iRely shall maintain and enforce reasonable technical and organizational safeguards against accidental or unlawful destruction, loss, alteration or unauthorized disclosure or access of the Customer Data that are at least equal to industry standards for applications similar to the Application. However, because the success of this process depends on equipment, software, and services over which iRely has limited control, Customer agrees that iRely has no responsibility or liability for the deletion or failure to store any Customer Data or communications maintained or transmitted by the Application. Customer shall be responsible for backing up its own Customer Data. Customer has set no limit on the number of transmissions Customer may send or receive through the Application or the amount of storage space used, except as provided in the Proposal, and Customer’s volume of transmissions may affect its Subscription Fees.</p>
    <p>
        <br />
    </p>
    <p><strong>8. REPRESENTATIONS AND WARRANTIES OF iRely</strong></p>
    <ul>
        <li>iRely represents and warrants that:
            <ul>
                <li>for a period of one hundred eighty days (180) from the date the Application, or a new Version, is made available to Customer, the Application, or new Version, shall perform substantially in accordance with the Documentation under normal use and circumstances;</li>
                <li>Standard Support Services shall be performed in a professional and workmanlike manner; and</li>
                <li>iRely shall, prior to making a new feature of the Application available, (a) scan it with commercially available anti-virus software and shall use reasonable efforts to remove viruses capable of being detected with such software, (b) not intentionally include in the Application any viruses, worms, trap doors, Trojan horses or other malicious code.</li>
            </ul>
        </li>
        <li>The warranties above shall be contingent upon the existence of all the following conditions: (i) the Application is implemented and operated by Customer in accordance with the Documentation; (ii) Customer notifies iRely of any warranty defect as promptly as reasonably possible after becoming aware of such defect, but in no event more than ten (10) calendar days after becoming aware of such defect; (iii) Customer has properly used all Updates made available with respect to the Application, and any updates recommended by iRely with respect to any third-party software products that affect the performance of the Application; (iv) Customer has properly maintained all associated equipment and software and provided the environmental conditions in accordance with applicable written specifications provided by the applicable manufacturer of such equipment and software; (v) Customer has not introduced other equipment or software that causes an adverse impact on the Application; (vi) Customer has paid all amounts due hereunder and is not in default of any provision of this Agreement; (vii) any legacy software with respect to which the Application is to operate contains clearly defined interfaces and correct integration code, and (viii) Customer has made no changes (nor permitted any changes to be made other than by or with the express approval of iRely) to the Application, except as may be permitted herein.</li>
        <li>The Parties negotiated this Section and it reflects a fair allocation of risk. Customer’s exclusive remedies, and iRely’s sole liability, with respect to any breach of this Section 10 will be, at iRely’s option, for iRely to (i) promptly correct the applicable material defects that affect performance of and access to the Application (provided that, Customer notifies iRely in writing of such defect within the applicable warranty period); (ii) provide a workaround that is substantially similar in form and function reasonable acceptable to Customer; or (iii) if neither of the foregoing are reasonably practicable, accept termination of Customer’s access and use of the Application and refund to Customer a pro-rata portion of unused, pre-paid Subscription Fees.</li>
        <li>iRely shall cooperate with Customer, at Customer’s sole expense, with respect to any investigation, inquiry or audit by any regulatory authority that supervises, oversees or regulates Customer during the Term of this Agreement and for such time thereafter as may be required by applicable law.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><em>By clicking the &quot;I agree&quot; box you acknowledge that you are entering into a legally binding contract with iRely, and that you have read, understood, and agreed to the terms set forth herein, including all applicable schedules.</em></p>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <h1 class="with-breadcrumbs"><a style="text-decoration: none;" href="http://help.irelyserver.com/display/DOC/Schedule+3+-+irely+Statement+of+Work+and+Service+Agreement">Schedule 3 - iRely Statement of Work and Service Agreement</a></h1>
    <p>
        <br />
    </p>
    <p>This<span> </span><strong>Statement of Work</strong><span> </span>(&quot;<strong>SOW</strong>&quot;), a support Schedule to the Master Services Agreement (the “<strong>Master</strong><span> </span><strong>Agreement</strong>”), is effective as of<span> </span><strong><em>CURRENT<span> </span></em></strong><strong><em>DATE</em></strong>, between<span> </span><strong>Customer</strong><span> </span>(“<strong>Customer</strong>”) and<span> </span><strong>iRely, LLC<span> </span></strong>(“<strong>iRely</strong>”). This Statement of Work shall be governed by and is incorporated by reference into the Master Agreement.</p>
    <p>
        <br />
    </p>
    <p><strong>1) PRIMARY OBJECTIVE</strong></p>
    <p>iRely will provide Project Management and Consulting services to assist Customer with the implementation of the iRely i21 solution as defined in the sections below.</p>
    <p><strong><em> </em></strong></p>
    <p><strong>2) RESPONSIBILITY MATRIX</strong></p>
    <p>This Responsibility Matrix covers Realization, Final Preparation and Go-Live/Support phases of the project and the following key activities/deliverables apply. The following legend is applicable to the deliverable lists in this section:</p>
    <p>
        <br />
    </p>
    <p>Responsible (R): Having an obligation to execute or provide deliverable as part of a job or role on project. Those who do the work to achieve the task.</p>
    <p>
        <br />
    </p>
    <p>Consulted (C): Provides required Advice/Information to execute or provide deliverable. Those whose opinions are sought, typically subject matter experts; and with whom there is two-way communication.</p>
    <p>
        <br />
    </p>
    <p>Informed (I): Being informed about the deliverable details and knowledgeable and aware about the deliverable in order to respond if required. Those who are kept up-to-date on progress, often only on completion of the task or deliverable; and with whom there is just one-way communication.</p>
    <p>
        <br />
    </p>
    <p>Accountable (A): Role on project that should be able to explain or substantiate the logic or reason behind the deliverable. The one person to oversee the correct and thorough completion of the deliverable or task, and the one who delegates work to the Responsible. An Accountable must sign off (Approve) on the work that the Responsible provides. There must be only one Accountable specified for each task or deliverable.</p>
    <p>
        <br />
    </p>
    <table class="wrapped confluenceTable">
        <colgroup>
            <col />
            <col />
            <col />
            <col />
        </colgroup>
        <thead>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Stage</strong></p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Activity</strong></p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Customer</strong></p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>iRely</strong></p>
                </td>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td style="text-align: left;" rowspan="11" class="confluenceTd">
                    <p>
                        <br />
                    </p>
                    <p><strong>Stage 1</strong></p>
                    <p><strong> </strong></p>
                    <p>Discovery -
                        <br />Solution Blueprint and Functional Design
                        <br />
                        <br />
                    </p>
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>
                        <br />
                    </p>
                    <p>The activities of the Discovery Stage are centered primarily on three aspects:</p>
                    <p>
                        <br />
                    </p>
                    <p>Create and establish:</p>
                    <p>Project team</p>
                    <p>Steering committee</p>
                    <p>Project charter</p>
                    <p>Clear measurable goals and objectives</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Project governance</p>
                    <p>Roles and responsibilities</p>
                    <p>Reporting requirements</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>I</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Data conversion strategy</p>
                    <p>Only open transactions (or full conversion)</p>
                    <p>Cutover strategy</p>
                    <p>Data will be provided in iRely formats for conversion</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Business/Functional aspects of the project. Areas of focus include:</p>
                    <p>Software Orientation for Project Team</p>
                    <p>System Review (on demo system)</p>
                    <p>Base function and setup</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Conducting Business Analysis Sessions</p>
                    <p>Review Customer’s business flows</p>
                    <p>Use Case Design - Using a series of customer specific scenarios, the project team will demonstrate the system inputs, processes and outputs to illustrate the manner in which the system will be utilized at go-live.</p>
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Identifying Transaction Data, Reference Data and Security Profiles that will be required at Go-live (commence the compilation of such data)</p>
                    <p>Master Data</p>
                    <p>Open transactions</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>C</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Determining modifications to system, if any</p>
                    <p>Determining the End User Training Strategy</p>
                    <p>Determining the User Acceptance and Parallel Test Strategies (commence the compilation of the required scenarios and test cases) Preparing and Approving the Discovery Document</p>
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Determining the Deployment Strategy</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AC</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>
                        <br />
                    </p>
                    <p>Business process re-engineering, if any</p>
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Integration planning - Definition, design, specification of any intended integrations</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>C</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Create Detailed project plan based upon results of discovery stage</p>
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>C (?)</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" rowspan="6" class="confluenceTd">
                    <p><strong>Stage 2</strong></p>
                    <p>
                        <br />
                    </p>
                    <p>Design, Configuration and Build
                        <br />
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>
                        <br />
                    </p>
                    <p>During this stage, our efforts are principally on two areas: Configure the standard solution and design/build new RICEFWs*. Specific steps are:</p>
                    <p>
                        <br />
                    </p>
                    <p>a. Configuring set up data</p>
                    <p>b. Loading and approving Reference Data &amp; Security Profiles</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>c. Configuring views to meet reporting requirements</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>d. Detailed design, Coding, Review and Approval of Integrations between i21 and other systems</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>C</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>e. Loading and Configuring Integrations </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>f. Detailed Design, Coding, Review and Approval of Modifications</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R (?)</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>g. Installing &amp; Configuring Test &amp; Production environments
                        <br />
                        <br />
                    </p>
                    <p>*RICEFW - Reports, Interfaces, Conversions, Extensions, Forms and Workflow</p>
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" rowspan="2" class="confluenceTd">
                    <p><strong>Stage 3</strong></p>
                    <p><strong> </strong></p>
                    <p>Testing</p>
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>
                        <br />
                    </p>
                    <p>During this stage, we will have a detailed execution of test plans. iRely will assist Customer by recording and sharing results that are required for Customer audit needs.
                        <br />
                        <br />
                    </p>
                    <p>Execute standard Unit and Functional test scripts</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R (?)</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Execute Client Functional Test Plan &amp; Evaluate results</p>
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R (?)</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" rowspan="2" class="confluenceTd">
                    <p><strong>Stage 4</strong></p>
                    <p>
                        <br />
                    </p>
                    <p>UAT – User Acceptance Testing</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>
                        <br />
                    </p>
                    <p>The UAT will provide validation to confirm and approve the production-ready environment:
                        <br />
                        <br />
                    </p>
                    <p>Execute Key User Training (“Train the Trainers”)</p>
                    <p>Simulation of daily activities in i21</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Execute Client User Acceptance Test Plan &amp; evaluate results</p>
                    <p>There could be multiple rounds of UAT</p>
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" rowspan="6" class="confluenceTd">
                    <p><strong>Stage 5</strong></p>
                    <p>
                        <br />
                    </p>
                    <p>Go-live and Hypercare
                        <br />
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" rowspan="2" class="confluenceTd">
                    <p>
                        <br />
                    </p>
                    <p>Deployment activities include:</p>
                    <p>
                        <br />
                    </p>
                    <p>Execute Production Parallel Test Plan &amp; Evaluate results</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>
                        <br />
                    </p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Go/No-Go Decision for Go-Live</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>C</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Cutover from Legacy Systems to i21 in Production Environment</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>R</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Post Go-Live Support</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>C</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Transition to Support</p>
                    <p>
                        <br />
                    </p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>AR</p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>C</p>
                </td>
            </tr>
        </tbody>
    </table>
    <p>
        <br />
    </p>
    <p><strong>3) CUSTOMER RESPONSIBILITIES</strong></p>
    <ul>
        <li>Customer will dedicate appropriate personnel to the project as and when required.
            <ul>
                <li>Customer will assign a lead project manager that will serve as the primary point of contact for the project.</li>
                <li>Customer will have overall accountability for the project.</li>
                <li>Customer resources will have the overall responsibility for:
                    <ul>
                        <li>Customer resource coordination &amp; deliverables;</li>
                        <li>Identifying and documenting business scenarios;</li>
                        <li>User Acceptance &amp; Parallel Test Cases;</li>
                        <li>Compilation and Cleansing of Reference Data;</li>
                        <li>Determination of Security Profiles;</li>
                        <li>Executing User Acceptance Testing;</li>
                        <li>Provide the final requirements documentation for all interfaces and modifications;</li>
                        <li>Reviewing and approving any design documentation produced for interfaces and modifications;</li>
                        <li>Serve as primary point of contact for any needed third-party communications;</li>
                        <li>Providing the necessary physical and computer access required to Customer assets once the SOW is fully executed;</li>
                        <li>Customer will provide necessary project work environment conducive to the accomplishment of the project outlined in this SOW.</li>
                    </ul>
                </li>
            </ul>
        </li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>4) iRely RESPONSIBILITIES</strong></p>
    <ul>
        <li>iRely will provide a Project Manager. The Project Manager will facilitate the activities supported by the SOW. The Project Manager will work in conjunction with Customer’s Project Manager to ensure the project is progressing within the mutually agreed upon project timeline and budget.</li>
        <li>Completion of services as outlined in the five-stage implementation process above.</li>
        <li>Organize the execution of its obligations under the terms of this SOW as to providing appropriate enhancements/fixes, as well as support.</li>
        <li>Provide suitably qualified technical resources familiar with the Services.</li>
        <li>Delivering the project’s final Solution/deliverables in a timely manner and obtain Customer sign-off.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>5) ASSUMPTIONS</strong></p>
    <p><strong> </strong>Professional Services under agreement may include:</p>
    <ul>
        <li>Services for five-stage implementation process as described above;</li>
        <li>Project Management;</li>
        <li>Any modifications to the requirements contained in this SOW require written permission from both Customer and iRely project management, following the Change Control Procedure;</li>
        <li>Customer will be dealing directly with iRely and will not be dealing with a third party relating to any of the activities in this SOW;</li>
        <li>iRely personnel assigned to the work under the terms of this SOW are technically qualified to grant Customer access to the Software, train Customer personnel and support Customer through the completion of this SOW;</li>
        <li>Customer personnel are available and have the time to receive appropriate training and move the project forward;</li>
        <li>The project will be executed remotely or occasionally on customer site as mutually determined between the parties;</li>
        <li>iRely will not store Customer confidential information and Customer will not use iRely confidential information;</li>
        <li>Testing will be conducted on a Production environment or Production like and dedicated environment for iRely consultants and for customer testing purposes;</li>
        <li>The success of the implementation project is primarily the role of the customer.</li>
    </ul>
    <p><strong> </strong></p>
    <p><strong>6) OUT OF SCOPE - REQUIRES CHANGE PROCEDURE</strong></p>
    <ul>
        <li>Planning or engineering work to be performed by iRely. New enhancements or reports.</li>
        <li>Functionality modifications and additions that need additional programming.</li>
        <li>Reports/Documents modifications and additions that need additional programming.</li>
        <li>Data Conversion.</li>
        <li>Any additional integrations that are not included in this SOW.</li>
        <li>Technical support.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>7) TIMETABLE AND CHANGE PROCEDURE</strong></p>
    <p>
        <br />
    </p>
    <p><strong><em>Timetable</em></strong></p>
    <p>iRely will begin developing the Solution on the Effective Date hereof and shall continue providing services and support until the Software is successfully implemented.</p>
    <p><strong><em> </em></strong></p>
    <p><strong><em>Acceptance</em></strong></p>
    <p>Service is deemed accepted and consumed as service is delivered.</p>
    <p>
        <br />
    </p>
    <p><strong><em>Change Control Procedure</em></strong></p>
    <p>In the event the parties determine that the scope of this SOW requires modification, they will use the Change Control Procedure. Please refer to Schedule 6 – iRely Change Procedure.</p>
    <p>
        <br />
    </p>
    <p><strong>8) TERM</strong></p>
    <p>The Services to be performed by iRely pursuant to this SOW shall commence on or about DATE and shall be completed by approximately DATE as shown in the project plan attached in this SOW. This assumes no change in scope and availability of needed resources from Customer. Should scope change or should customer availability become an issue, the dates for completion will be adjusted accordingly. Services shall be completed according to this SOW. Customer will take into consideration Customer’s allocation of its resources required for the completion of the necessary tasks under the terms of this SOW.</p>
    <p><strong> </strong></p>
    <p><strong>9) iRely FEES AND MILESTONES</strong><strong> </strong></p>
    <ul>
        <li>Implementation and customization services are billed based on time and material. Please refer to Schedule 5 – Invoicing and Payment, for rates and further details.</li>
        <li>Customizations identified during implementation will follow the Change Control Procedure in Schedule 6. Customization may impact the Go-live date, and the parties will mutually agree to modify the Go-live date accordingly.</li>
        <li>Invoicing for Professional Services are issued on a weekly basis. If payment is not received based on the terms of the agreement, iRely will be unable to deliver continued services until the issue is resolved.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>10) ISSUE ESCALATION PROCEDURE</strong><strong> </strong></p>
    <ul>
        <li>In the event that either party determines it is not getting adequate resolution to a problem that may have a material impact upon its obligations under this SOW or the completion of the work intended hereunder, the following represents the escalation path to be followed:</li>
        <li>When a conflict arises, the parties will first strive to work out the problem internally. If the person immediately involved cannot resolve the conflict within 48 hours, the Customer Project Manager and iRely Project Manager will meet to resolve the issue.
            <ul>
                <li>If, after two business days, the issue remains unresolved, either party may insist the issue be raised to the highest level of management to both parties.</li>
                <li>If the issue is resolved, the resolution will be addressed in accordance with the Change Control Procedure.</li>
                <li>If the issue remains unresolved, the Change Control Procedure will be put on hold so that the project can continue to move forward. The issue will remain open until both parties agree to a resolution or for 90 days, whichever is sooner. After 90 days, the Change will be closed.</li>
            </ul>
        </li>
    </ul>
    <p>
        <br />
    </p>
    <p><em>By clicking the &quot;I agree&quot; box you acknowledge that you are entering into a legally binding contract with iRely, and that you have read, understood, and agreed to the terms set forth herein, including all applicable schedules.</em></p>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <h1 class="with-breadcrumbs"><a style="text-decoration: none;" href="http://help.irelyserver.com/display/DOC/Schedule+4+-+irely+Maintenance+Agreement">Schedule 4 - iRely Maintenance Agreement</a></h1>
    <p>
        <br />
    </p>
    <p>This Maintenance and Support Agreement (the “<strong>Maintenance Agreement</strong>”) a support Schedule to the Master Services Agreement (the “Master Agreement”) is effective as of acceptance of agreement (the “Effective Date”) by and between CUSTOMER, (&quot;Customer&quot;) and iRely, LLC (“iRely”). This Maintenance Agreement shall be governed by and is incorporated by reference into the Master Agreement. Customer and iRely are hereafter referred to collectively as the “Parties” and individually as a “Party.”</p>
    <p>WHEREAS, iRely and Customer are entered into a Master Agreement including a Software Licensing Agreement, and</p>
    <p>WHEREAS, iRely is a provider of support and maintenance Services for the Software as specified in the applicable Schedule; and</p>
    <p>WHEREAS, Customer desires to obtain maintenance and support services from iRely on matters related to the Software; and</p>
    <p>WHEREAS, iRely wishes to provide such support and maintenance to Customer.</p>
    <p>WHEREAS language is different from other agreements </p>
    <p>NOW, THEREFORE, in consideration of the mutual promises, covenants and conditions contained herein, and for other good and valuable Services. </p>
    <p>
        <br />
    </p>
    <p><strong>1) iRely MAINTENANCE SERVICES</strong></p>
    <ul>
        <li>iRely will provide Software support and maintenance services (collectively, &quot;Maintenance Services&quot;) to CUSTOMER during the term set forth in the Master Agreement. Maintenance Services consist of three primary components.
            <ul>
                <li>Software maintenance services that relate to tax and other accounting and regulatory changes. These changes are monitored by Customer and iRely and built into the software release cycle. This also covers cost related to improving processes and simplifying system functions.</li>
                <li>Software development services consisting of new features and additions based on collective discussion with Customers that are added to the Software to improve its</li>
                <li>
                    <p>Software support services consisting of tools used to assist with troubleshooting Software issues. This includes help manuals, help desk tools, help desk ticketing system, telephone support, error correction, and the knowledgeable support team iRely employs.</p>
                </li>
            </ul>
        </li>
        <li>
            <p>Additional services will be provided by iRely upon Customer request at the standard professional services rates presented in<span> </span><u>Schedule 5 – Invoicing and Payments</u>.</p>
        </li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>2) ERROR CORRECTION SERVICES</strong></p>
    <ul>
        <li>An “Error” is an event in which the Software does not perform as intended.</li>
        <li>Correction of Errors. iRely will exercise reasonable efforts to investigate and correct all Errors reported to iRely by Customer as Errors in accordance with this Schedule. Customer will inform iRely of any Errors by submitting a help desk ticket in iRely’s help desk system (or by phone if help desk system is not functioning correctly). In order to ensure timely resolution to errors, Customer must report, at a minimum, the following information:
            <ul>
                <li>Version of Software</li>
                <li>Instructions on how to reproduce the reported Error</li>
                <li>User(s) impacted</li>
                <li>Any other necessary and/or useful information relating to identifying and reproducing the reported error.</li>
            </ul>
        </li>
        <li>Error Classification. iRely has 4 severity levels for Error classification. Each level has its own service level as described further in this section.</li>
    </ul>
    <p>
        <br />
    </p>
    <table class="wrapped confluenceTable">
        <colgroup>
            <col />
            <col />
            <col />
        </colgroup>
        <tbody>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Priority</strong></p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Description</strong></p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Action</strong></p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Sev 1 - Blocker</strong></p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Customer Production Issues Only</strong></p>
                    <p>This is only used for Customers running live in production. This is the Highest priority and takes highest precedence. </p>
                    <p>Some examples of when this should be used: </p>
                    <ul>
                        <li>i21 is unusable with no workaround </li>
                        <li>System is Down </li>
                        <li>Complete loss of productivity </li>
                        <li>No access to the system</li>
                    </ul>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A patch is required in a Blocker build ASAP.3. </p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Sev 2 - Critical</strong></p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <ul>
                        <li>This is either a development blocker or critical customer issue. </li>
                        <li>May have a customer impact. </li>
                        <li>An issue that blocks programming and/or testing work. </li>
                        <li>Anything that impedes getting a build or a server updated. </li>
                        <li>Used for UAP </li>
                        <li>The turnaround for this is the same as a Blocker </li>
                        <li>Part of the Blocker build </li>
                        <li>QC Testing bugs</li>
                    </ul>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A patch is required in a Blocker build</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Sev 3 - Major</strong></p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <ul>
                        <li>Significantly impacts the customers ability to use the application properly. </li>
                        <li>An issue that doesn''t function as expected/designed or causes other functionality to fail to meet requirements. </li>
                        <li>An issue that is not blocking the customer’s daily production process but the function is critical for periodic execution. </li>
                        <li>Examples include: batch posting, printing reports, closing year, import/export process, etc. </li>
                        <li>A workaround can usually be provided for such issues.</li>
                    </ul>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>Fix will take place in next Maintenance build.</p>
                    <p>Resolution time based on SLA.</p>
                </td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">
                    <p><strong>Sev 4 - Minor</strong></p>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <ul>
                        <li>Relatively minor issues that do not affect the customer''s ability to use the application. </li>
                        <li>An issue that leads to minor or no loss of function (e.g. cosmetic issues) where easy workaround is present. </li>
                        <li>Cosmetic problem like misspelling words or misspelling text. </li>
                        <li>These issues should not impede execution of any customer business function.</li>
                    </ul>
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <p>A fix can typically wait until the next major version.</p>
                </td>
            </tr>
        </tbody>
    </table>
    <p>
        <br />
    </p>
    <p>2.3.1. Solution path for each level of Severity is defined in the following charts based on plan type:</p>
    <p>
        <br />
    </p>
    <p><strong><em>STANDARD SUPPORT PLAN</em></strong></p>
    <table class="wrapped confluenceTable">
        <colgroup>
            <col />
            <col />
            <col />
            <col />
            <col />
        </colgroup>
        <thead>
            <tr>
                <td style="text-align: left;" class="confluenceTd"><u>Severity Level</u></td>
                <td style="text-align: left;" class="confluenceTd"><u>Response Time</u></td>
                <td style="text-align: left;" class="confluenceTd"><u>Patch Required</u></td>
                <td style="text-align: left;" class="confluenceTd"><u>Resolution Time</u></td>
                <td style="text-align: left;" class="confluenceTd"><u>Version Update</u></td>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td style="text-align: left;" class="confluenceTd">Severity 1</td>
                <td style="text-align: left;" class="confluenceTd">4 Hours from creation of Help Desk Ticket</td>
                <td style="text-align: left;" class="confluenceTd">Yes</td>
                <td style="text-align: left;" class="confluenceTd">12 Hours</td>
                <td style="text-align: left;" class="confluenceTd">Current Version</td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">Severity 2</td>
                <td style="text-align: left;" class="confluenceTd">4 Hours from creation of Help Desk Ticket</td>
                <td style="text-align: left;" class="confluenceTd">Yes</td>
                <td style="text-align: left;" class="confluenceTd">12 Hours</td>
                <td style="text-align: left;" class="confluenceTd">Current Version</td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">Severity 3</td>
                <td style="text-align: left;" class="confluenceTd">8 Hours from creation of Help Desk Ticket</td>
                <td style="text-align: left;" class="confluenceTd">Possibly</td>
                <td style="text-align: left;" class="confluenceTd">3 Business Days</td>
                <td style="text-align: left;" class="confluenceTd">Current or Next Maintenance Release</td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">Severity 4</td>
                <td style="text-align: left;" class="confluenceTd">48 Hours from creation of Help Desk Ticket</td>
                <td style="text-align: left;" class="confluenceTd">No</td>
                <td style="text-align: left;" class="confluenceTd">By next major release</td>
                <td style="text-align: left;" class="confluenceTd">Next Major Version</td>
            </tr>
        </tbody>
    </table>
    <p>
        <br />
    </p>
    <p><em>NOTE: TIME BASED ON AN AVERAGE TIMEFRAME FOR 1 MONTH</em></p>
    <p>
        <br />
    </p>
    <p><strong><em>PREMIUM SUPPORT PLAN</em></strong></p>
    <table class="wrapped confluenceTable">
        <colgroup>
            <col />
            <col />
            <col />
            <col />
            <col />
        </colgroup>
        <thead>
            <tr>
                <td style="text-align: left;" class="confluenceTd"><u>Severity Level</u></td>
                <td style="text-align: left;" class="confluenceTd"><u>Response Time</u></td>
                <td style="text-align: left;" class="confluenceTd"><u>Patch Required</u></td>
                <td style="text-align: left;" class="confluenceTd"><u>Resolution Time</u></td>
                <td style="text-align: left;" class="confluenceTd"><u>Version Update</u></td>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td style="text-align: left;" class="confluenceTd">Severity 1</td>
                <td style="text-align: left;" class="confluenceTd">2 Hours from creation of Help Desk Ticket</td>
                <td style="text-align: left;" class="confluenceTd">Yes</td>
                <td style="text-align: left;" class="confluenceTd">8 Hours</td>
                <td style="text-align: left;" class="confluenceTd">Current Version</td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">Severity 2</td>
                <td style="text-align: left;" class="confluenceTd">4 Hours from creation of Help Desk Ticket</td>
                <td style="text-align: left;" class="confluenceTd">Possibly</td>
                <td style="text-align: left;" class="confluenceTd">2 Business Days</td>
                <td style="text-align: left;" class="confluenceTd">Current or Next Maintenance Release</td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">Severity 3</td>
                <td style="text-align: left;" class="confluenceTd">32 Hours from creation of Help Desk Ticket</td>
                <td style="text-align: left;" class="confluenceTd">No</td>
                <td style="text-align: left;" class="confluenceTd">By next major release</td>
                <td style="text-align: left;" class="confluenceTd">Next Major Version</td>
            </tr>
            <tr>
                <td style="text-align: left;" class="confluenceTd">Severity 4</td>
                <td style="text-align: left;" class="confluenceTd">
                    <br />
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <br />
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <br />
                </td>
                <td style="text-align: left;" class="confluenceTd">
                    <br />
                </td>
            </tr>
        </tbody>
    </table>
    <p>
        <br />
    </p>
    <p><em>NOTE: TIME BASED ON AN AVERAGE TIMEFRAME FOR 1 MONTH</em></p>
    <p>
        <br />
    </p>
    <p>2.3.2. If iRely is unable to complete resolution within such timeframe, iRely will continue to work to resolve such Error on a continuous basis (i.e., 24x7) until resolved.</p>
    <p>
        <br />
    </p>
    <p><strong>3) EXCLUSIONS</strong></p>
    <ul>
        <li>iRely shall have no obligation to support Software in respect of Errors attributable to the following circumstances.</li>
        <li>Altered or damaged Software (unless modified by iRely);</li>
        <li>Software problems caused by Customer’s negligence, abuse or misapplication, use of Software other than as specified;</li>
        <li>Software installed on any computer hardware that is not supported by iRely; or</li>
        <li>Other causes beyond the control of iRely.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>4) RELEASES</strong></p>
    <ul>
        <li>iRely has one major, primary release each year. iRely defines this as the “.1” version and is the first major release of software in each new year. As Customers onboard into iRely’s release schedule, all efforts are made to schedule all customers to the newest .1 version. Thereafter, the goal is for customers to have yearly updates to the next .1 version of the software.</li>
        <li>iRely has one additional, official release each year. iRely defines the additional release as the .3 version. The .3 version is dedicated to new customers in the process of onboarding to iRely. The .3 version is focused on new development primarily geared towards new customers requiring development effort.</li>
        <li>iRely also has multiple maintenance releases within each version of the software. Each official release has at least 3 maintenance releases. Maintenance release occur at least every 60 days.</li>
        <li>iRely will provide to Customer the Maintenance Services for the current version of the Software and the one (1) release immediately preceding such current release. iRely will use commercially reasonable efforts to support other older Software release at iRely’s then current time and materials rates and otherwise on the terms set forth in this Agreement.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>5) </strong><strong>COVERED SUPPORT SERVICES</strong></p>
    <p>Services covered under this agreement include the following:</p>
    <ul>
        <li>Isolate, document, and find circumventions for reported Errors;</li>
        <li>Answer questions about specific details of procedures (including but not limited to discussing available features, options and limitations);</li>
        <li>Work with iRely software development staff to provide safe hot fixes for Errors;</li>
        <li>Address concerns with printed or online documentation by providing additional examples or explanations for concepts that require clarification;</li>
        <li>Address specific questions and concerns that are related to the maintenance of iRely software;</li>
        <li>Unlimited help desk ticketing system and toll-free telephone consultation, regarding the use and trouble-shooting of the Software and Enhancements; or</li>
        <li>Logging service calls received from Customer, along with the eventual solution and correction time within iRely Help Desk ticketing system.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>6) </strong><strong>ADDITIONAL SERVICES</strong></p>
    <p>From time to time after completion of the initial Services, Customer may request that iRely perform various additional services (“Additional Services”) for Customer.</p>
    <ul>
        <li>iRely will make such Services available to Customer based on the rates schedule in<span> </span><u>SCHEDULE 5 – INVOICING AND PAYMENT.</u></li>
        <li>Customer and iRely shall enter into a written Statement of Work or Proposal if the request is for development or extensive training.</li>
        <li>Customer is not required to give written notice if the request is for smaller training sessions (defined as less than 8 hours) or Technical Services.</li>
        <li>If a written document is required, work will not begin until approval has been provided.</li>
        <li>Additional Services related to development or new feature/function will include an adjustment to the annual maintenance rate. Adjustment will be billed prorate in current year and will be included in future annual maintenance invoices.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>7)<span> </span></strong><strong>TERM AND TERMINATION</strong></p>
    <p>Maintenance Services will usually run with the Master Agreement, in which event the Term and Termination provisions in the Master Agreement control. If Customer wishes to terminate Maintenance separately from the Master Agreement, then the following provisions shall apply.</p>
    <ul>
        <li>Term.
            <ul>
                <li>Initial Term. The initial term of this Agreement shall commence on day of contract execution and shall continue in full force and effect and unless extended or terminated earlier pursuant to this Agreement or stated in a Schedule, shall continue for three (3) years thereafter (the “Initial Term”).</li>
                <li>Renewal Term. Customer shall have the right, but not the obligation, to renew this Agreement. Such Renewal Term will automatically renew unless Customer provides iRely with written notice of its intent to cancel prior to the expiration of the Initial Term or the then current Renewal Term.</li>
            </ul>
        </li>
        <li>Termination.
            <ul>
                <li>Cause. Either party will be entitled to terminate this Agreement (in whole or in part) or any affected Schedule (in whole or in part) immediately upon written notice (specifying the effective date of termination) if the other party commits a material breach of performance or non-performance of its obligations of this Agreement (and if such breach is capable of being cured within thirty (30) days after notice thereof and such breaching party fails to cure such breach in all material respects within such cure period).</li>
                <li>Insolvency. A Party to this Agreement may terminate this Agreement upon written notice specifying the termination date to the other Party, in the event a Party of the Agreement (a) ceases all operations, (b) files for bankruptcy, (c) becomes or is declared insolvent, or is the subject of any unchallenged proceedings related to its liquidation, insolvency, or the appointment of a receiver or similar officer for it (d) makes an assignment for the benefit of all or substantially all of its creditors, or (e) enters into an agreement for the consolidation, extension, or readjustment of substantially all of its obligations.</li>
                <li>Convenience. Upon sixty (60) days written notice, either Party may terminate this Agreement, in whole or in part, for convenience. Such termination notice shall be effective upon the date specified in the written notice.</li>
            </ul>
        </li>
        <li>Force Majeure. Neither party will be liable under, or deemed to be in breach of, this Agreement for any delay or failure in performance under this Agreement that is caused by any of the following events: acts of God, civil or military authority, the public enemy, or war; accidents; fires; explosions; power surges; earthquakes; floods; unusually severe weather; strikes or labor disputes; delays in transportation or delivery due to a Force Majeure Event; epidemics; terrorism or threats of terrorism; and any similar event that is beyond the reasonable control of the non-performing party (“Force Majeure Event”). The party affected by the Force Majeure Event must diligently attempt to perform (including through alternate means). During a Force Majeure Event, the parties will negotiate changes to this Agreement in good faith to address the Force Majeure Event in a fair and equitable manner. If a Force Majeure Event continues for ten (10) days or longer, and the non-performing party is delayed or unable to perform under this Agreement as a result of the Force Majeure Event, then the other party will have the right to terminate this Agreement upon written notice to the non-performing party.</li>
        <li>Obligations Upon Termination or Expiration. When the Agreement or any Schedule terminates or expires:
            <ul>
                <li>Customer will pay iRely the undisputed amounts for all Services performed and expenses incurred by iRely prior to the date of termination.</li>
                <li>iRely will: (i) deliver to Customer all Deliverables (completed and in progress), all Products for which Customer has paid, as well as all materials, including Customer Materials, which were furnished to iRely by Customer or its Affiliates or which were prepared or procured by iRely to perform its obligations under the Agreement; (ii) discontinue (and cause its contractors and personnel to immediately discontinue) all use of Customer Materials; and (iii) promptly close out all activities under the Agreement.</li>
            </ul>
        </li>
        <li>Recommence<span>. Customer may cancel maintenance services as described above during the term of this agreement.  In the event the Customer desires to recommence receiving maintenance services after a period in which Customer allowed such maintenance services to lapse, Customer may do so provided that Customer pays iRely the maintenance fees that would have been due hereunder during the period of lapse.</span></li>
    </ul>
    <p><em> </em></p>
    <p><em>By clicking the &quot;I agree&quot; box you acknowledge that you are entering into a legally binding contract with iRely, and that you have read, understood, and agreed to the terms set forth herein, including all applicable schedules.</em></p>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <h1 class="with-breadcrumbs"><a href="http://help.irelyserver.com/display/DOC/Schedule+5+-+irely+Invoicing+and+Payment" style="text-decoration: none;">Schedule 5 - iRely Invoicing and Payment</a></h1>
    <p>
        <br />
    </p>
    <p><strong>1. SERVICE OFFERINGS</strong></p>
    <ul>
        <li>Possible service offerings are listed below. For pricing and selection, please refer to<span> </span><u>Schedule 1 - Proposal</u>.</li>
        <li>License</li>
        <li>Professional Services
            <ul>
                <li>Implementation Services</li>
                <li>Development Services</li>
            </ul>
        </li>
        <li>Maintenance</li>
        <li>Software as a Service (SaaS)</li>
        <li>Hosting</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>2. LICENSE</strong></p>
    <ul>
        <li>Full License Fee will be invoiced at Master Agreement execution.</li>
        <li>Installation will begin once payment for license is received.</li>
        <li>Payment must be received within 10 days to avoid project delay.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>3. PROFESSIONAL SERVICES</strong></p>
    <ul>
        <li>Professional Services (both Implementation and Development) are invoiced as incurred.</li>
        <li>Invoicing for Professional Services are issued on a weekly basis.</li>
        <li>Payment for Professional Services must be received within 30 days. If payment is not received, iRely will cease all Professional Services until payment is resolved.</li>
        <li>If Development Services are requested, a Statement of Work will be created and issued to customer for approval prior to the work being completed.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>4. MAINTENANCE</strong></p>
    <ul>
        <li>Standard Maintenance services begin on day of Master Agreement execution.</li>
        <li>Maintenance minimum requirement is 3 years.</li>
        <li>First maintenance invoice will be issued at Master Agreement execution and will be pro-rated to the beginning of the next calendar year.</li>
        <li>After initial maintenance invoice, ongoing Maintenance is invoiced annually up to 30 days prior to the start of the maintenance period.</li>
        <li>Payment for annual invoice is due prior to the next maintenance period start date.</li>
        <li>Annual maintenance rates on same products may increase at a rate of no more than 5% annually.</li>
        <li>Maintenance will automatically renew annually after initial 3-year term.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>5. SOFTWARE AS A SERVICE</strong></p>
    <ul>
        <li>SaaS services begin on day of Master Agreement execution.</li>
        <li>SaaS minimum requirement is 3 years.</li>
        <li>SaaS will be invoiced annually up to 30 days prior to the start of the SaaS period.</li>
        <li>Payment for annual invoice is due prior to the SaaS period start date.</li>
        <li>Installation of SaaS solution will begin once initial payment is received.</li>
        <li>SaaS rates may increase at a rate of no more than 5% annually within the contract period.</li>
        <li>SaaS rates will be reassessed during contract renewal due to possible Hosting cost changes.</li>
        <li>SaaS agreement will automatically renew on a year to year basis.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>6. HOSTING</strong></p>
    <ul>
        <li>Hosting services begin on day of Master Agreement execution.</li>
        <li>First hosting invoice will be issued at contract execution.</li>
        <li>After initial Hosting invoice, ongoing Hosting is invoiced annually up to 30 days prior to the start of the next Hosting period.</li>
        <li>Payment for annual invoice is due prior to the Hosting period start date.</li>
        <li>Annual hosting rates will be reviewed annually and adjusted if warranted based on Hosting cost and requirements.</li>
        <li>Hosting will automatically renew annually.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong> 7. </strong><strong>TRAVEL AND EXPENSE</strong></p>
    <ul>
        <li>Any travel and related expenses will be invoiced during the weekly invoicing process.</li>
        <li>Travel and related expenses are reimbursed at actual cost.</li>
        <li>iRely will invoice a per diem of $75 for living expenses per person.</li>
        <li>Payment for travel and related expense must be received within 30 days. If payment is not received, iRely cease Professional Services until payment is resolved.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>8. CUSTOM MODIFICATION/ENHANCEMENTS</strong></p>
    <ul>
        <li>Customer’s annual maintenance will be adjusted to include maintenance rates for the custom modification/enhancement.</li>
        <li>Annual maintenance rate for custom modifications/enhancements will be calculated by taking 20% of the actual cost of development of the modification once completed.</li>
        <li>Customer will receive initial maintenance invoice for modification once modification is verified in a production release. Going forward, maintenance will be added to the annual maintenance invoice.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>9. iRely CURRENT SERVICE RATES</strong></p>
    <p>Hourly rates for iRely Professional Services are as follows:</p>
    <p>
        <br />
    </p>
    <p>$240 – Executive/Sr. Project Management</p>
    <p>$200 – Project Management</p>
    <p>$200 – Implementation/Functional Lead</p>
    <p>$200 – Development</p>
    <p>$200 – Data Conversion</p>
    <p>$200+ – Functional Consulting</p>
    <p>
        <br />
    </p>
    <p><strong>10. USER ACCEPTANCE PROGRAM (UAP)</strong></p>
    <ul>
        <li>UAP is required for customers with custom development</li>
        <li>UAP is priced based on level of license and level of development of customer</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>11. OTHER CONSIDERATIONS</strong></p>
    <ul>
        <li>All invoices will be in USD (unless agreed otherwise)</li>
        <li>All payments shall be made by check or by EFT.</li>
        <li>The fees and other amounts payable by Customer to iRely under this Agreement do not include any taxes of any jurisdiction that may be assessed or imposed in connection with the services provided hereunder and, as applicable, upon the copies of the Software and Documentation delivered to Customer, the license granted under this Agreement and the services provided hereunder, or any taxes otherwise assessed or imposed in connection with the transactions contemplated by this Agreement, including sales, use, excise, value added, personal property, export, import and withholding taxes, excluding only taxes based upon iRely''s net income. Customer will directly pay any such taxes assessed against it, and Customer will promptly reimburse iRely for any such taxes payable or collectable by iRely.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>12. REMEDIES FOR NONPAYMENT</strong></p>
    <p>If Customer fails to pay to iRely within 30 days of the date of invoice, any amount payable under this Agreement (including interest thereon) that is not the subject of a good faith dispute, in addition to all other rights and remedies which iRely may have at law or in equity, iRely may, in its sole discretion and without further notice to Customer, immediately suspend all applicable SaaS Services, Hosting Services, Professional Services and the performance of any or all of its other obligations under this Agreement, and iRely will have no liability with respect to Customer’s use of the applicable Software, SaaS Services, Hosting Services, Professional Services or other iRely services hereunder until all past due amounts are settled. Past due payments will be assessed a finance charge at a rate of 18% per annum (1.5% per month). iRely reserves the right to impose a reconnection fee in the event Customer’s access to the SaaS Services is suspended and thereafter Customer requests renewed access to the SaaS Services. For the purposes of this Agreement, a “good faith dispute” means a good faith dispute by Customer of certain amounts invoiced under this Agreement. A good faith dispute will be deemed to exist only if (a) Customer has given written notice of the dispute to iRely within 15 days of the date of an invoice and (b) the notice explains Customer''s position in reasonable detail. A good faith dispute will not exist as to an invoice in its entirety merely because certain amounts on the invoice have been disputed.</p>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <p><em>By clicking the &quot;I agree&quot; box you acknowledge that you are entering into a legally binding contract with iRely, and that you have read, understood, and agreed to the terms set forth herein, including all applicable schedules.</em></p>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <h1 class="with-breadcrumbs"><a style="text-decoration: none;" href="http://help.irelyserver.com/display/DOC/Schedule+6+-+irely+Change+Procedure">Schedule 6 - iRely Change Procedure</a></h1>
    <p>
        <br />
    </p>
    <p><strong>1. CHANGE IN SERVICE</strong></p>
    <p><strong> </strong>There may be instances where a change in the service provided is required. Schedule 3 – iRely SOW and Service Agreement provides a project plan. The scope of that project plan may change for many reasons. When a change in scope has been identified, the following change procedure must be followed. </p>
    <p><strong> </strong>Some instances when change may occur include:</p>
    <ul>
        <li>Additional training is requested or needed.</li>
        <li>Additional setup is required.</li>
        <li>Additional process flows are identified than were originally scoped.</li>
        <li>Additional testing is required due to nuances/complexities in customer’s process flows.</li>
        <li>Additional reporting is required to fulfill reporting needs.</li>
        <li>Additional re-work is needed due to changing customer staff.</li>
        <li>Additional reconciliation work is needed due to out of balance previous system data.</li>
        <li>Data conversion services</li>
        <li>Additional staff training beyond what was originally scoped.</li>
        <li>Additional request for on-site services beyond the original scope.</li>
        <li>Many other instances not identified and not in the original scope.</li>
    </ul>
    <p>If it is deemed necessary to make a change to the cost/scope of the implementation project due to additional Service, the following procedure will take place:</p>
    <ul>
        <li>iRely will initially present and make aware out of scope items to customer project manager.</li>
        <li>Approval must be provided by customer for any work that falls outside of scope.</li>
        <li>If the out of scope service is minimal and requires less than 8 hours of service, a help desk ticket describing the out of scope item will be created. Customer must provide approval for the item either within the ticket or via an email response.</li>
        <li>If the out of scope item will require more than 8 hours of service, an Estimate of Work (EOW) will be generated.</li>
        <li>EOW will be created and presented by the Project Manager. It will define the following:
            <ul>
                <li>Description of Work</li>
                <li>Estimated Cost</li>
                <li>Change in go live date or completion of implementation</li>
            </ul>
        </li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>2. CHANGE IN DEVELOPMENT</strong></p>
    <p><strong> </strong>There may be instances where a change (modification) to the product is requested. Development changes may impact scope of the project. When a change in scope has been identified, the change procedure must be followed. </p>
    <p><strong> </strong>Some instances when change may occur include:</p>
    <ul>
        <li>Requested change in process design due to current process flow</li>
        <li>New Feature</li>
        <li>Modified/New setting</li>
        <li>Report Creation/Modification</li>
        <li>Any other instances not identified and not in the original scope.</li>
    </ul>
    <p><strong> </strong>If it is deemed necessary to make a change to the cost/scope of the implementation project due to development requests, the following procedure will take place:</p>
    <ul>
        <li>iRely will initially present and make aware out of scope items to customer project manager.</li>
        <li>Approval must be provided by customer for any work that falls outside of scope.</li>
        <li>If the out of scope development is minimal and requires less than 8 hours, a help desk ticket describing the out of scope item will be created. Customer must provide approval for the item either within the ticket or via an email response.</li>
        <li>Due to development, spec writing, and testing, most development efforts require more than 8 hours. If the out of scope item will require more than 8 hours, an Estimate of Work (EOW) will be generated.</li>
        <li>EOW will be created and presented by the iRely Project Manager with the direct feedback from the Customer and the relevant iRely Product Manager. It will define the following:
            <ul>
                <li>Description of work</li>
                <li>Estimated Cost</li>
                <li>Release Version</li>
                <li>Change in go live date or completion of implementation.</li>
            </ul>
        </li>
    </ul>
    <p><strong> </strong></p>
    <p><strong>3. CHANGE IN LICENSE</strong></p>
    <p>There may be instances where Customer would like to add additional products during the implementation. Adding additional product will impact the scope of the implementation. When a change in scope has been identified, the change procedure must be followed. </p>
    <p>If it is deemed necessary to make a change to the cost/scope of the implementation project due to additional product, the following procedure will take place:</p>
    <ul>
        <li>iRely will initially present and make aware out of scope items to customer project manager.</li>
        <li>Approval must be provided by customer for any work that falls outside of scope.</li>
        <li>Customer will be provided a proposal for the additional product along with the additional service time required for implementation.</li>
        <li>A proposal will be created by the Sales Representative and will define the following:
            <ul>
                <li>Name of Product</li>
                <li>Cost of Product and Maintenance</li>
                <li>Release Version of installation</li>
                <li>Change in go live date or completion of implementation.</li>
            </ul>
        </li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>4. BUDGET ADJUSTMENT</strong></p>
    <p>Project Managers will periodically review budget vs actual based on the Project Plan presented in the SOW. During the implementation, actual hours may not fall in line with budget. Should actual hours start to fall out of line with budget, the iRely Project Manager will notify Customer. If actual hours/costs fall out of total budget by more than 20%, iRely will require an EOW to be created by the Project Manager and approved by the customer.</p>
    <p>
        <br />
    </p>
    <p><strong>5. APPROVAL</strong></p>
    <ul>
        <li>For projects requiring 8 hours or less, Customer may document approval through approving the Help Desk ticket.</li>
        <li>For projects over 8 hours, Customer must sign an EOW for approval.</li>
        <li>If the overall project is more than 20% over budget, Customer must sign an EOW for approval.</li>
        <li>For additional product/license, Customer must sign a proposal for approval.</li>
        <li>Approval must be received prior to iRely providing any additional service.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>6. NON-APPROVED</strong></p>
    <ul>
        <li>If a help desk ticket is not approved, iRely will not deliver additional service described in the ticket.</li>
        <li>If an EOW is not approved, iRely will not deliver the additional service described in the EOW.</li>
        <li>If the non-approval of an EOW puts the project at risk, iRely will escalate and will discuss and present during the Steering Committee meeting and other meetings if needed. iRely’s priority is to ensure success and maintain transparency throughout the implementation.</li>
        <li>Regardless of non-approved items, iRely will work with customer to deliver services efficiently and in a manner that is approved by the customer.</li>
    </ul>
    <p>
        <br />
    </p>
    <p>
        <br />
    </p>
    <p><em>By clicking the &quot;I agree&quot; box you acknowledge that you are entering into a legally binding contract with iRely, and that you have read, understood, and agreed to the terms set forth herein, including all applicable schedules.</em></p>
    <p>
        <br />
    </p>
    <h1 class="with-breadcrumbs"><a href="http://help.irelyserver.com/display/DOC/Schedule+7+-+irely+Hosting+Agreement" style="text-decoration: none;">Schedule 7 - iRely Hosting Agreement</a></h1>
    <p>
        <br />
    </p>
    <p>This Hosting Agreement (the<span> </span><strong>“Hosting Agreement”</strong>), a support Schedule to the Master Services Agreement (the “<strong>Master</strong><span> </span><strong>Agreement</strong>”), is effective as of acceptance of agreement between (“<strong>Customer</strong>”) and<span> </span><strong>iRely, LLC<span> </span></strong>(“<strong>iRely</strong>”). This Hosting Agreement shall be governed by and is incorporated by reference into the Master Agreement.</p>
    <p>
        <br />
    </p>
    <p>iRely is in the business of providing (i) access to its hosted software applications for managing extended enterprise data, and (ii) implementation services for such applications. The parties desire that the Customer shall obtain access to such applications on a hosting basis under the terms and conditions of this Agreement. In consideration of the mutual promises and covenants set forth herein and for other good and valuable consideration, the receipt and sufficiency of which are acknowledged, the Parties agree as follows:</p>
    <p><strong> </strong></p>
    <p><strong>1) DESCRIPTION OF APPLICATION AND SERVICES</strong></p>
    <ul>
        <li>Hosting the Application. iRely shall provide to Customer access and use of the Hosted Application described in Schedule 1 - Proposal, for the Hosting Period specified therein, in consideration of payment of the applicable Hosting Fees.</li>
        <li>Additional Proposals. Additional Proposals may be entered by the Parties to subscribe to additional or different features of the Application. Unless designated as replacing a specific outstanding Proposal, a new Proposal will be considered in addition to currently outstanding Proposals. Additional Proposals shall be executed manually by the Parties or submitted electronically through the iRely’s online ordering system.</li>
        <li>Accessing User Accounts. User IDs shall be required to access and use the Application. Customer will access and use the Application only through the User IDs and only in accordance with the Hosting terms and other restrictions in this Agreement. Customer shall be responsible for issuing User IDs to such employees and Affiliates as it determines in its sole discretion, in accordance with this Agreement.</li>
        <li>Standard Support Services. iRely shall provide support service as identified in Schedule 4 – iRely Maintenance Agreement. Customers using Hosting service are required to pay annual maintenance.</li>
        <li>Hosting and Subcontractors. iRely may in its sole discretion engage, or has engaged, third-parties (“Subcontractors”) to perform Hosting of the Application or other Support Services under this Agreement.</li>
    </ul>
    <p><strong> </strong></p>
    <p><strong>2) HOSTING RIGHTS AND RESTRICTIONS</strong></p>
    <ul>
        <li>Hosting Grant. For each Application feature referenced on a Proposal, and for which the applicable Hosting Fee is paid when due, iRely hereby grants to Customer: (i) access to the Hosted Application through the User IDs; (ii) ability to load Customer Data into the Application; (iii) ability to use the Application for Customer’s own internal business purposes; and (iv) operate the features of the Application during the Hosting Period according to the Documentation, all subject to the terms and conditions of the Proposals and this Agreement. All rights not expressly granted to Customer herein are reserved to iRely and its licensors.</li>
        <li>Type of Hosting. The Hosting Grant is limited to the number of Users specified on the applicable Proposal.</li>
        <li>Hosting Restrictions.
            <ul>
                <li>Customer shall not access, or allow access to, the Application if Customer is in direct competition with iRely, except with iRely’s prior written consent. Customer may not access the Application for purposes of monitoring its availability, performance, or functionality, or for any other benchmarking or competitive purposes. Customer shall not (i) license, sublicense, sell, resell, transfer, assign, distribute, or otherwise commercially exploit or make available to any third party the Application in any way; (ii) modify or make derivative works of the Application; (iii) create Internet “links” to the Application on any other server or wireless or Internet-based device; or (iv) reverse engineer or access the Application in order to (a) build a competitive product or service; (b) build a product using similar ideas, features, functions or graphics of the Application; or (c) copy any ideas, features, functions or graphics of the Application.</li>
                <li>Customer shall not: (i) send spam or otherwise duplicative or unsolicited messages in violation of applicable laws; (ii) send or store infringing, obscene, threatening, libelous, or otherwise unlawful or tortuous material, including material harmful to children or violative of third party privacy rights; (iii) send or store material containing software viruses, worms, Trojan horses, or other harmful computer code, files, scripts, agents, or programs; (iv) interfere with or disrupt the integrity or performance of the Application or the data contained therein; (v) attempt to gain unauthorized access to the Application or its related systems or networks; or (vi) input any data or information into the Application that is: credit card or debit card information, personal banking, financial account information, social security numbers, HIPAA-protected data, or personal confidential/identifying information concerning individuals.</li>
                <li>Customer shall not permit Users to share User IDs with each other or with third parties. Customer acknowledges that: (i) iRely shall rely on the validity of any User ID, instruction or information that meets the Application’s automated criteria or which is believed by iRely to be genuine; (ii) iRely may assume a person entering a User ID and password is, in fact, that User; and (iii) iRely may assume the latest email addresses and registration information for Users on file with iRely are accurate and current.</li>
            </ul>
        </li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>3) CUSTOMER RESPONSIBILITIES</strong></p>
    <ul>
        <li>User IDs. Customer shall select its Users in its sole discretion and shall issue to each individual User a User ID to access the Application subject to the limitations and obligations herein, and provided, that Customer shall be responsible for all activity occurring under Customer’s User accounts. Customer shall: (i) notify iRely immediately of any unauthorized use of any password or account or any other known or suspected breach of security; (ii) report to iRely immediately and use reasonable efforts to stop immediately any unauthorized copying or distribution of Customer Data that is known or suspected by Customer or Users; and (iii) not impersonate another iRely customer or provide false identity information to gain access to or use the Application. Customer shall be responsible for its Users’ compliance with the terms of this Agreement and shall ensure that Users shall be obligated in writing to protect User IDs and the Application at least to the extent as provided in this Agreement.</li>
        <li>Data Preparation and Configuration. Customer will ensure that: (i) it maintains Customer Data in prop</li>
        <li>Cer format as specified by the Documentation or the Statement of Work in a Professional Services Agreement and that its Customer Data does not include personal identifying information (“PII”); (ii) its Personnel are familiar with the use and operation of the Application; and (iii) it does not introduce other software, data, or equipment having an adverse impact on the Application. Following any initial implementation assistance by iRely, Customer shall load the Customer Data and configure the Application, any Updates, and its internal processes, as needed, to operate the Application and any Updates in Customer’s computing environment. Customer, not iRely, shall have sole responsibility for the accuracy, quality, integrity, legality, reliability, appropriateness and right to use of all Customer Data. iRely shall not be responsible or liable for any deletion, correction, destruction, damage, loss, or failure to store any Customer Data that is caused by Customer or User or the use or misuse of User IDs by a third party.</li>
    </ul>
    <p><strong> </strong></p>
    <p><strong>4) RESERVATION OF RIGHTS AND iRely OWNERHSIP</strong></p>
    <p>This Agreement is not a sale and does not convey to Customer any rights of ownership in or to the Application, or to the Intellectual Property Rights therein owned by iRely. iRely’s name, iRely’s logo, and the product names associated with the Application are trademarks of iRely or third parties, and no right or license is granted to use them. iRely (and its licensors) shall exclusively own all right, title, and interest in and to the Application, copies, modifications, and derivative works thereof. iRely shall own any suggestions, ideas, enhancement requests, feedback, recommendations, or other information provided by Customer or any other party relating to the Application, including all related Intellectual Property Rights thereto, excluding Customer Data.</p>
    <p>
        <br />
    </p>
    <p><strong>5) CUSTOMER DATA OWNERSHIP</strong></p>
    <p>Customer (and its licensors) shall exclusively own all right, title and interest in and to Customer Data and Intellectual Property Rights thereto.</p>
    <p>
        <br />
    </p>
    <p><strong>6) FEES AND PAYMENT</strong></p>
    <ul>
        <li>Hosting Fees and Payment. Customer shall pay the Hosting Fees, in advance, for the rights to access and use the Application during the applicable Hosting Period, as set forth in the Proposal(s), attached to the Master Agreement as Schedule - 1. Hosting Fees shall be invoiced annually before the corresponding Hosting Period, which dates may be specified in the Proposal. Invoices shall be due and payable within thirty (30) days of the invoice date, and in no event later than one day before the start of the applicable Hosting Period. Any future Proposals shall be at iRely’s then-published rates or as otherwise agreed by the Parties in the Proposal. All payment obligations for Hosting Fees are non-cancelable and all amounts paid are nonrefundable. Please refer to Schedule 5 – Invoicing and Payment for additional details.</li>
        <li>Data Storage and Backup Fees. The Hosting Fees include online data storage and weekly data backups as set forth in the Proposal. If the amount of disk storage required exceeds these limits, Customer will be charged the then-current storage fees at the time the Hosting Fee is due. iRely shall use reasonable efforts to notify Customer when its usage approaches ninety percent (90%) of the allotted storage space; however, any failure by iRely to so notify Customer shall not affect Customer’s responsibility for such additional storage charges. Any additional data storage shall be at iRely’s then applicable rates or as otherwise agreed in an Proposal.</li>
        <li>Professional Services Fees. iRely shall invoice Customer weekly in arrears for Professional Services performed pursuant to any Professional Services Agreement at the rates set forth therein. Please refer to Schedule 5 – Invoicing and Payment for additional details.</li>
        <li>Late Payment, Suspension. Customer may not withhold or “setoff” any amounts due hereunder. In addition to any other legal remedies, iRely reserves the right to suspend or terminate Customer’s access to the Application until all amounts due are paid in full after giving Customer advance written notice and an opportunity to cure as specified herein in the Section relating to Termination. Any late payment shall be subject to costs of collection, including reasonable attorneys’ fees, and shall bear interest at the rate of one percent (1.5%) per month, or the highest rate permitted by law, until paid.</li>
        <li>Prices quoted do not include, and Customer shall pay all applicable taxes, including without limitation, sales, use, gross receipts, value-added, GST, personal property, or other tax (including interest and penalties imposed thereon) on the transactions contemplated herein, other than taxes based on the net income or profits of iRely.</li>
        <li>Pricing Terms. All prices are stated and payable in U.S. Dollars. All pricing terms are confidential, and Customer shall not disclose them to any third party.</li>
        <li>iRely will issue an invoice to Customer each year at the end of a Term or as otherwise mutually agreed upon, unless either Party has given notice of non-renewal as set forth in the Section 18, “Term.”</li>
    </ul>
    <p><strong> </strong></p>
    <p><strong>7) DATA PROTECTION AND INFORMATION SECURITY</strong></p>
    <p>iRely shall maintain and enforce reasonable technical and organizational safeguards against accidental or unlawful destruction, loss, alteration or unauthorized disclosure or access of the Customer Data that are at least equal to industry standards for applications similar to the Application. However, because the success of this process depends on equipment, software, and services over which iRely has limited control, Customer agrees that iRely has no responsibility or liability for the deletion or failure to store any Customer Data or communications maintained or transmitted by the Application. Customer shall be responsible for backing up its own Customer Data. Customer has set no limit on the number of transmissions Customer may send or receive through the Application or the amount of storage space used, except as provided in the Proposal, and Customer’s volume of transmissions may affect its Hosting Fees.</p>
    <p>
        <br />
    </p>
    <p><em>By clicking the &quot;I agree&quot; box you acknowledge that you are entering into a legally binding contract with iRely, and that you have read, understood, and agreed to the terms set forth herein, including all applicable schedules.</em></p>
    <p>
        <br />
    </p>
    <h1 class="with-breadcrumbs"><a style="text-decoration: none;" href="http://help.irelyserver.com/display/DOC/Schedule+8+-+irely+Privacy+Policy">Schedule 8 - iRely Privacy Policy</a></h1>
    <p>
        <br />
    </p>
    <p><strong>Effective Date: July 1, 2018</strong></p>
    <p><strong>Last Revised: December 27, 2019</strong></p>
    <p>Here at iRely, LLC. (<strong>“iRely” “we”</strong><span> </span>and<strong><span> </span>“us”</strong>), we understand and respect your concerns about the use of your personal data. This Privacy Policy (the “Policy”) explains what personal date we collect, how we use that information, and your privacy rights.</p>
    <p>
        <br />
    </p>
    <p><strong>1. DEFINITIONS</strong></p>
    <p>For purposes of this Policy, the following definitions shall apply:</p>
    <ul>
        <li>“Data Subject” means an identified or identifiable natural person; an identifiable natural person is one who can be identified, directly or indirectly, in particular by reference to an identifier such as a name, an identification number, location data, an online identifier or to one or more factors specific to the physical, physiological, genetic, mental, economic, cultural or social identity of that natural person.</li>
        <li>“GDPR” refers to the European General Data Protection Regulation (Regulation (EU) 2016/679 of the European Parliament and of the Council of 27 April 2016).</li>
        <li>“EU” (European Union) refers to those countries that are members of the European Union.</li>
        <li>“EEA” (European Economic Area) refers to those countries that are members of the European Economic Area.</li>
        <li>“Personal Data” means any information relating to a Data Subject.</li>
        <li>“Privacy Shield Principles” mean the Privacy Shield Principles enumerated under the EU-U.S. Privacy Shield Framework and the Swiss-U.S. Privacy Shield Framework.</li>
        <li>“Third Party” means any person that is not an employee or agent of iRely.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>2. PRIVACY PRINCIPLES</strong></p>
    <p>The privacy principles expressed in this Policy are based on the Privacy Shield Principles enumerated under the EU-U.S. Privacy Shield Framework and the Swiss-U.S. Privacy Shield Framework.</p>
    <p>
        <br />
    </p>
    <p><strong>3. COLLECTION AND USE OF PERSONAL DATA</strong></p>
    <p>This Policy applies to all personal data received by iRely in any format including electronic, paper or verbal. iRely collects and processes personal data from current and former employees, as well as applicants for employment, clients, and prospective clients, through its Internet website, its Intranet site, carrier portals, electronic mail, and traditional mail. All personal data collected by iRely will be used for legitimate business purposes consistent with this Policy.</p>
    <ul>
        <li><strong><u>Personal Data Collected</u></strong>
            <ul>
                <li>We only collect personal data that you provide to us.</li>
                <li>If you register for certain Services on iRely’s website (the “Website”), you will be asked to provide certain personally identifiable information as part of the registration process, such as first and last name, e-mail address, telephone number.</li>
                <li>In addition, in using the services provided by iRely (the “Services”), you may be asked to provide additional information about the hedge funds that you represent or manage (if applicable), investment parameters, personal financial and account information, information relating to services performed for or transactions entered into on behalf of a hedge fund or another registered user, and data or analyses derived from such non-public personal information.</li>
                <li>You may visit our Website and choose not to provide some personal information, but that will limit our ability to communicate with you or fulfill your requests. By using our Website and providing personal information, you consent to our privacy policy.</li>
                <li>We also may use personally identifiable information to develop, offer, and deliver products and services; respond to inquiries from you or your representative; or to fulfill legal and regulatory requirements.</li>
                <li>iRely may collect non-public personal data about you from any of the following sources:
                    <ul>
                        <li>From you or your representative on applications, registrations, or other forms (for example, your name, address, assets and income);</li>
                        <li>From you or your representative regarding your preferences (for example, based on your activity on our Website);</li>
                        <li>From other sources with your consent or with the consent of your representative (for example, from other institutions such as credit reporting agencies);</li>
                        <li>From investment activity (for example, your investments in private placements);</li>
                        <li>From information you have listed on any public area of your company’s website.</li>
                        <li>From other interactions with iRely (for example, discussions with our customer service staff or your entry of information into our interactive tools); and</li>
                        <li>From email correspondence from you or phone conversations with you (we may gather the information in a file specific to you).</li>
                    </ul>
                </li>
            </ul>
        </li>
        <li><strong><u>Non-Personal Information Collected</u></strong>
            <ul>
                <li>We also may collect certain non-personally identifiable information when you visit the Website. This information includes the type of Internet browser and operating system you are using, the domain name of your Internet service provider, the URL that you visited before you came to our Website, the URL to which you next go, and your IP (Internet Protocol) address, pages visited, and average time spent on our Website. This information may be used, for example, to alert you to software compatibility issues, or it may be analyzed to improve our Website design and functionality. When you use the contact features of the Website, you consent to the review and internal use of your communication by iRely. We also may use non-personally identifiable information in the aggregate to analyze Website usage and to gather broad demographic information.</li>
            </ul>
        </li>
        <li><strong><u>Cookies</u></strong>
            <ul>
                <li>We also receive information through cookies, clear GIFs, pixel tags, and other similar technologies. This information often does not reveal your identity directly, but in some countries, including the EEA, it is considered personal data.</li>
                <li>We use cookies to improve and customize your browsing experience. For example, cookies permit the Website to remember that you have registered, which makes it possible for you to enter your log in ID and password less frequently and which allows us to speed up your activities on the Website.</li>
                <li>Most web browsers are initially set to accept cookies. However, you can block, disable, or delete cookies, if desired. This often can be done by changing your internet software browsing settings. It also may be possible to configure your browser settings to enable acceptance of specific cookies or to notify you each time a new cookie is about to be stored on your computer enabling you to decide whether to accept or reject the cookie. To manage your use of cookies there are various resources available to you, for example the “Help” section on your browser may assist you. You also can disable or delete the stored data used by technology like cookies, such as Local Shared Objects or Flash cookies, by managing your browser’s “add-on settings” or visiting the website of the browser’s manufacturer. To learn more about how cookies can be managed, blocked, disabled, or deleted, visit<span> </span><a href="http://www.allaboutcookies.org/" style="text-decoration: none;" rel="nofollow" class="external-link">allaboutcookies.org</a>. However, as our cookies allow you to access some of our Website’s features, we recommend that you leave cookies enabled, because, otherwise, if the cookies are disabled or deleted, it may mean that you experience reduced functionality or will be prevented from using the Website altogether. </li>
                <li>By accessing or using our Website or online services, you consent to iRely using cookies. If you refuse to accept cookies by adjusting your browser setting or taking any of the other kinds of actions discussed above, some or all areas of our Website or online services may not function properly or may not be accessible.</li>
            </ul>
        </li>
        <li><strong><u>Our Use of Personal Data</u></strong>
            <ul>
                <li>Generally, iRely will not share, rent, sell or otherwise disclose any of your personal information except with your permission. However, iRely may disclose personal information in the following ways:
                    <ul>
                        <li>If you are a qualified investor, as necessary to enable managers or representatives of private investment funds to make determinations with respect to the eligibility and suitability of you as a qualified investor, and to contact you for purposes of discussing investment opportunities in private investment funds;</li>
                        <li>If you are a manager or representative of a private investment fund, as necessary to enable qualified investors who are registered users to make determinations with respect to the eligibility and suitability of such investment fund, and to contact you for purposes of discussing such investment opportunities;</li>
                        <li>In using certain of the services, some of your personal information will be displayed either to other persons or entities whom you designate, or to the public;</li>
                        <li>Affiliates, including affiliated services providers;</li>
                        <li>We may disclose your personal information to our third-party contractors, service providers, and agents who perform services for iRely. These contractors and service providers are permitted to use the personal information only for the purposes of such services;</li>
                        <li>We may be legally obligated to disclose personally identifiable information to the government, law enforcement officials or third parties under certain circumstances, for example, in response to legal process, court order or a subpoena and tax reporting. We also may disclose such information where we believe it is necessary to investigate, prevent, or take action regarding illegal activities, suspected fraud, unauthorized access, situations involving potential threats to the physical safety of any person, violations of our Terms of Use, abuse of this Website, security breaches of this Website, or as necessary to protect our systems, business, users or others or as otherwise required by law;</li>
                        <li>We may disclose and transfer your information as part of a merger, acquisition or other sale or disposition of our assets or business;</li>
                        <li>Other organizations, with your consent or as directed by your representative; and</li>
                        <li>Other organizations, as permitted or required by the laws that protect your privacy (for example, for fraud prevention).</li>
                        <li>We require each of the above parties to adhere to our privacy standards or substantially similar standards for non-disclosure and protection of personal information and to use this information only for the limited purpose for which it was shared. Individuals interact with us in a variety of ways, and under some of these variations, we may exchange information with parties in addition to those described above.</li>
                        <li>We may also share all individual investor information, under joint marketing agreements with nonaffiliated financial services business partners, to offer discounts or other special access to products and services. In addition, we may disclose aggregated information to advertisers and for marketing or promotional purposes. In these situations, we do not disclose to these entities any information that could be used to personally identify you.</li>
                        <li>If you are a former customer, your personal data is treated in the same manner as the personal data of current customers.</li>
                    </ul>
                </li>
            </ul>
        </li>
    </ul>
    <ul>
        <li><strong><u>Our Retention of Personal Data</u></strong>
            <ul>
                <li>iRely will retain personal data while we have a justifiable business need to do so, unless a longer retention period is required or permitted by law (such as tax, legal, accounting, or other purposes). For example, if you are a customer, we will keep your personal data for the duration of the contractual relationship you or your company has with us and after the end of that relationship for as long as necessary to perform the functions set forth above or to comply with legal obligations. When we have no justifiable business need to process your personal data, we will either delete or anonymize it, or if this is not possible, we will securely store your personal data and isolate it from any further processing until deletion is possible.</li>
            </ul>
        </li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>4. SECURITY</strong></p>
    <p>iRely uses administrative, organizational, technical, and physical safeguards to protect your personal data. We will take reasonable precautions to protect personal data in our possession from loss, misuse and unauthorized access, disclosure, alteration and destruction. With respect to information given on the Internet, iRely uses a variety of proven protections to maintain the security of your online session. This may include the use of firewall barriers, encryption techniques and authentication procedures. We require our partners to use appropriate security measures.</p>
    <p>
        <br />
    </p>
    <p><strong>5. USER ACCESS AND CHOICE</strong></p>
    <ul>
        <li>You are entitled to ask us for a copy of your personal data, to correct it, erase or restrict its processing, or to ask us to transfer (parts of) this data to other organizations. You also have the right to object to certain processing activities, such as the profiling we may perform for the purposes of direct marketing as discussed above in this Policy. Where we have asked for your consent to process your personal data, you have the right to withdraw this consent, for example, by using the opt-out or unsubscribe functionalities in our communications with you. These rights can be limited where we can demonstrate that we have a legal requirement or legitimate basis to process your personal data, and under such circumstances, we are able to retain your data even if you withdraw your consent.</li>
        <li>If you wish to make use of any of these rights, please contact our Data Privacy Officer by e-mail or postal mail at the contact information provided below for the Data Privacy Officer or, as applicable, by using opt-out or unsubscribe functionalities in our communications with you. We will respond to your request within 30 days. If you are not satisfied with how we handle such requests or how we otherwise process your personal data, you can seek to have the matter addressed through the dispute resolution program administered by JAMS; for more information on how to initiate a matter with JAMS, please see<span> </span><a href="https://www.jamsadr.com/file-an-eu-us-privacy-shield-or-safe-harbor-claim" rel="nofollow" class="external-link" style="text-decoration: none;">https://www.jamsadr.com/file-an-eu-us-privacy-shield-or-safe-harbor-claim</a>.</li>
    </ul>
    <p>
        <br />
    </p>
    <p><strong>6. LINKED WEBSITES AND OTHER THIRD PARTIES</strong></p>
    <p>This Privacy Policy only addresses the use and disclosure of personal data that we collect from you. The Website, or services on the Website, may contain links to other websites whose information, security, and privacy practices may be different than ours. You should consult the other websites'' privacy policies and terms of use since we do not control information that is submitted to, or collected by, these third parties or the content of those linked websites. Once you access another website, you are subject to the privacy policy and terms of use of that website.</p>
    <p>
        <br />
    </p>
    <p><strong>7. CHILDREN’S PRIVACY</strong></p>
    <p>The Website and its services are not directed toward children under the age of 14. iRely will not knowingly request personally identifiable information from anyone under the age of 14, and if iRely becomes aware that any such information has been collected, iRely will delete it.</p>
    <p>
        <br />
    </p>
    <p><strong>8. CHANGES TO THIS POLICY</strong></p>
    <p>This Policy was last revised on December 27, 2019. iRely reserves the right to change, modify, or amend this Policy at any time. When the Policy is changed, modified, and/or amended, the revised Policy will be posted on our website. If required by applicable law, we will notify you of any material changes to the Policy, and we will provide such notification by means of posting a notice on our website prior to the changes becoming effective. Any revised privacy policy will only apply prospectively to personal data collected or modified after the effective date of the revised policy.</p>
    <p>
        <br />
    </p>
    <p><strong>9. CONTACT INFORMATION</strong></p>
    <p>If you have any questions regarding this Policy, you can write to iRely’s Data Privacy Officer, who may be contacted by telephone at 1-800-433-5724, by e-mail at<span> </span><a class="external-link" style="text-decoration: none;" rel="nofollow" href="mailto:billing@irely.com">billing@iRely.com</a>, or by postal mail at:</p>
    <p>iRely</p>
    <p>Attn: Data Privacy Officer</p>
    <p>iRely, LLC</p>
    <p>4242 Flagstaff Cv.</p>
    <p>Fort Wayne, IN 46815</p>
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