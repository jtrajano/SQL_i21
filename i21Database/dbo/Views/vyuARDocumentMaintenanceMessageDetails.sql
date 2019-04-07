CREATE VIEW [dbo].[vyuARDocumentMaintenanceMessageDetails]
AS 
SELECT intDocumentMaintenanceId
	 , strCode
	 , strTitle
	 , strHeader	= ISNULL(Header,'') COLLATE Latin1_General_CI_AS
	 , strFooter	= ISNULL(Footer,'') COLLATE Latin1_General_CI_AS
	 , strMessageHtml
FROM (
	SELECT intDocumentMaintenanceId
		 , strCode
		 , strTitle
		 , strHeaderFooter
		 , strMessage
		 , strMessageHtml
	FROM vyuARDocumentMaintenanceMessage
) tblARMessages
PIVOT (
	MAX(strMessage)
	FOR strHeaderFooter
	IN (Header, Footer)--, strHeaderFooter)
) AS U

