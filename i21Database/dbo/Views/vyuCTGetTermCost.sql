CREATE VIEW [dbo].[vyuCTGetTermCost]

AS

SELECT tc.intTermCostId
	, tc.intLoadingPortId 
	, strLoadingPort = LoadingPort.strCity
	, tc.intDestinationPortId 
	, strDestinationPort = DestinationPort.strCity
	, tc.intLoadingTermId 
	, strLoadingTerm = LoadingTerm.strFreightTerm
	, tc.intDestinationTermId 
	, strDestinationTerm = DestinationTerm.strFreightTerm
	, tc.intMarketZoneId
	, strMarketZone = mz.strMarketZoneCode
	, tc.intConcurrencyId
FROM tblCTTermCost tc
JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = tc.intLoadingPortId
JOIN tblSMCity DestinationPort ON DestinationPort.intCityId = tc.intDestinationPortId
JOIN tblSMFreightTerms LoadingTerm ON LoadingTerm.intFreightTermId = tc.intLoadingTermId
JOIN tblSMFreightTerms DestinationTerm ON DestinationTerm.intFreightTermId = tc.intDestinationTermId
JOIN tblARMarketZone mz ON mz.intMarketZoneId = tc.intMarketZoneId