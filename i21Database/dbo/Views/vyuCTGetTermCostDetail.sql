﻿CREATE VIEW [dbo].[vyuCTGetTermCostDetail]

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
	, tcd.intTermCostDetailId
	, tcd.intCostId
	, strCostItem = it.strItemNo
	, tcd.strCostMethod  COLLATE Latin1_General_CI_AS AS strCostMethod
	, tcd.intCurrencyId
	, cur.strCurrency
	, tcd.dblValue
	, tcd.intItemUOMId
	, uom.strUnitMeasure
	, ysnFreight = ISNULL(tcd.ysnFreight, 0)
	, ysnInsurance = ISNULL(tcd.ysnInsurance, 0)
	, tcd.intConcurrencyId
FROM tblCTTermCostDetail tcd
JOIN tblCTTermCost tc ON tc.intTermCostId = tcd.intTermCostId
JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = tc.intLoadingPortId
JOIN tblSMCity DestinationPort ON DestinationPort.intCityId = tc.intDestinationPortId
JOIN tblSMFreightTerms LoadingTerm ON LoadingTerm.intFreightTermId = tc.intLoadingTermId
JOIN tblSMFreightTerms DestinationTerm ON DestinationTerm.intFreightTermId = tc.intDestinationTermId
JOIN tblARMarketZone mz ON mz.intMarketZoneId = tc.intMarketZoneId
LEFT JOIN tblICItem it ON it.intItemId = tcd.intCostId
LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = tcd.intCurrencyId
LEFT JOIN tblICItemUOM iUOM ON iUOM.intItemUOMId = tcd.intItemUOMId
LEFT JOIN tblICUnitMeasure uom ON uom.intUnitMeasureId = iUOM.intUnitMeasureId