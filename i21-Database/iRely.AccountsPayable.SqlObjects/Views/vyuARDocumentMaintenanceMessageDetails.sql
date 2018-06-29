CREATE VIEW [dbo].[vyuARDocumentMaintenanceMessageDetails]
	AS 
	SELECT 
		intDocumentMaintenanceId, 
		strCode, 
		strTitle,
		ISNULL(Header,'') AS strHeader, 
		ISNULL(Footer,'') AS strFooter FROM
(
	SELECT 
			intDocumentMaintenanceId,
			strCode,
			strTitle,
			strHeaderFooter,
			strMessage
	FROM vyuARDocumentMaintenanceMessage
)
AS tblARMessages
PIVOT
(
	MAX(strMessage)
	FOR strHeaderFooter
	IN (Header, Footer)--, strHeaderFooter)
) AS U

