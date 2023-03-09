CREATE VIEW [dbo].[vyuTRImportAttachmentDetail]
AS
SELECT        
	  IAD.intImportAttachmentDetailId
	, IA.intImportAttachmentId
	, IAD.strInvoiceId
	, IAD.ysnDelete
	, IAD.intConcurrencyId
	, IAD.ysnValid
	, IAD.strMessage
	, CAST(IA.dtmImportDate AS DATETIME2) dtmImportDate
	, IAD.intLoadHeaderId
	, IAD.strFileName
	, IA.strSource
	, TM.strName AS strVendorName
	, EL.strLocationName AS strSupplyPoint
	, (CASE
		WHEN CHARINDEX(',',IAD.strInvoiceId) = 0 THEN (SELECT B.strName from tblARInvoice A INNER JOIN tblEMEntity B ON A.intEntityCustomerId = B. intEntityId WHERE A.intInvoiceId = CAST(IAD.strInvoiceId AS INT))
		WHEN CHARINDEX(',',IAD.strInvoiceId) > 0 THEN (SELECT B.strName from tblARInvoice A INNER JOIN tblEMEntity B ON A.intEntityCustomerId = B. intEntityId WHERE A.intInvoiceId = CAST(SUBSTRING(IAD.strInvoiceId, 1, CHARINDEX(',',IAD.strInvoiceId)-1) AS INT))
		ELSE IAD.strInvoiceId
	  END) COLLATE Latin1_General_CI_AS AS strCustomerName
	--,CASE WHEN IAD.strInvoiceId IS NULL THEN IAD.strMessage ELSE STUFF((SELECT ', ' + strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId IN (SELECT * FROM [dbo].[fnTRSplit] (IAD.strInvoiceId,','))
	--	FOR XML PATH('')),1,1,''
	--) END  AS strInvoiceNumber
	, STUFF((SELECT ', ' + strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId IN (SELECT * FROM [dbo].[fnTRSplit] (IAD.strInvoiceId,','))
		FOR XML PATH('')),1,1,''
	) COLLATE Latin1_General_CI_AS AS strInvoiceNumber
	, LH.strTransaction AS strTransportLoadNumber
FROM
		dbo.tblTRImportAttachmentDetail AS IAD 
		INNER JOIN dbo.tblTRImportAttachment AS IA ON IA.intImportAttachmentId = IAD.intImportAttachmentId 
		INNER JOIN dbo.tblEMEntity AS EM ON EM.intEntityId = IA.intUserId
		LEFT JOIN vyuTRTerminal TM on TM.intEntityVendorId = IAD.intVendorId
		LEFT JOIN tblTRSupplyPoint SP on IAD.intSupplyPointId = SP.intSupplyPointId
		LEFT JOIN tblEMEntityLocation EL on EL.intEntityLocationId = SP.intEntityLocationId
		LEFT JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = IAD.intLoadHeaderId