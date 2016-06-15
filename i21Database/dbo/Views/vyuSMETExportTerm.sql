CREATE VIEW [dbo].[vyuSMETExportTerm]
AS 
SELECT [Location].[strLocationNumber] AS [trloc], 
[Term].[strTerm] AS [trdesc], 
[Term].[strTermCode] AS [trtrm], 
[Term].[intDiscountDay] AS [trdays],
'D' AS [trtype],
'0.000000' AS [trpct],
'N' AS [ovr_price]
FROM tblSMCompanyLocation Location
CROSS JOIN tblSMTerm Term
LEFT JOIN tblETExportFilterTerm ExportTerm
	on Term.intTermID = ExportTerm.intTermId
LEFT JOIN tblETExportFilterLocation ExportLocation
	on Location.intCompanyLocationId = ExportLocation.intCompanyLocationId
WHERE Term.intTermID = ExportTerm.intTermId OR Location.intCompanyLocationId = ExportLocation.intCompanyLocationId
--WHERE [Term].[ysnEnergyTrac] = 1