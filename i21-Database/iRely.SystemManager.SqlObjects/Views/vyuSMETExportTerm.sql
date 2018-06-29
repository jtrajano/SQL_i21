CREATE VIEW [dbo].[vyuSMETExportTerm]
AS 
SELECT  DISTINCT [Location].[strLocationNumber] AS [trloc], 
[Term].[strTerm] AS [trdesc], 
[Term].[strTermCode] AS [trtrm], 
[Term].[intDiscountDay] AS [trdays],
'D' AS [trtype],
'0.000000' AS [trpct],
'N' AS [ovr_price]
FROM tblSMCompanyLocation Location
	CROSS JOIN tblSMTerm Term
	INNER JOIN tblETExportFilterTerm ExportTerm
ON Term.intTermID = ExportTerm.intTermId
	INNER JOIN tblETExportFilterLocation ExportLocation
ON Location.intCompanyLocationId = ExportLocation.intCompanyLocationId
