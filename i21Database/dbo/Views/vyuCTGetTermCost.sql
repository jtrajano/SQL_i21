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
	, tc.intCommodityId
	, strCommodity = com.strCommodityCode
	, tc.intProductTypeId
	, strProductType = pt.strDescription
	, tc.intProductLineId
	, strProductLine = pl.strDescription
	, tc.intConcurrencyId
FROM tblCTTermCost tc
JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = tc.intLoadingPortId
JOIN tblSMCity DestinationPort ON DestinationPort.intCityId = tc.intDestinationPortId
JOIN tblSMFreightTerms LoadingTerm ON LoadingTerm.intFreightTermId = tc.intLoadingTermId
JOIN tblSMFreightTerms DestinationTerm ON DestinationTerm.intFreightTermId = tc.intDestinationTermId
JOIN tblARMarketZone mz ON mz.intMarketZoneId = tc.intMarketZoneId
LEFT JOIN tblICCommodity com ON com.intCommodityId = tc.intCommodityId
LEFT JOIN tblICCommodityAttribute pt ON pt.intCommodityAttributeId = tc.intProductTypeId AND pt.strType = 'ProductType'
LEFT JOIN tblICCommodityProductLine pl ON pl.intCommodityProductLineId = tc.intProductLineId