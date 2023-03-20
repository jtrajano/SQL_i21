CREATE VIEW [dbo].[vyuARDocumentMaintenanceMessageDetails]
AS 
SELECT intDocumentMaintenanceId
	 , strCode
	 , strTitle
	 , strHeader	= ISNULL(strMessage,'') COLLATE Latin1_General_CI_AS
	 , strFooter	= ISNULL(strMessageFooter,'') COLLATE Latin1_General_CI_AS
	 , strMessageHtml
	 , strMessageHtmlFooter
FROM (
	SELECT intDocumentMaintenanceId
		 , strCode
		 , strTitle
		 , strHeaderFooter
		 , strMessage
		 , strMessageHtml
		 , strMessageFooter
		 , strMessageHtmlFooter
	FROM vyuARDocumentMaintenanceMessage
) tblARMessages