CREATE PROCEDURE dbo.uspCTGetSalesContractLeadTime (@intLoadingPortId INT, @intDestinationPortId INT)
AS
SElECT TOP 1
	  dc.strCity strDestinationPort
	, dc.intLeadTime intDestinationPortLeadTime
	, oc.strCity strLoadingPort
	, oc.intLeadTime intLoadingPortLeadTime
	, m.intLeadTime intFreightMatrixLeadTime
	, ISNULL(m.intLeadTime, 0) + dc.intLeadTime intSalesContractLeadTime
FROM tblSMCity dc
CROSS APPLY (
	SELECT TOP 1 intCityId, intLeadTime, strCity
	FROM tblSMCity
	WHERE intCityId = @intLoadingPortId
) oc
LEFT JOIN tblLGFreightRateMatrix m ON m.strOriginPort = oc.strCity
	AND m.strDestinationCity = dc.strCity
	AND m.intType = 2 -- General type
WHERE dc.intCityId = @intDestinationPortId