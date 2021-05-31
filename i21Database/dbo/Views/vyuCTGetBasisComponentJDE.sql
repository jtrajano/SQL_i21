CREATE VIEW [dbo].[vyuCTGetBasisComponentJDE]

AS

SELECT DISTINCT strContractNumber = CH.strContractNumber + ' - ' + CAST(CD.intContractSeq AS NVARCHAR)
	, strPONumber = CD.strERPPONumber
	, CH.dtmContractDate
	, dtmStartDate = CONVERT(DATE, CD.dtmStartDate)
	, dtmEndDate = CONVERT(DATE, CD.dtmEndDate)
	, CD.dtmPlannedAvailabilityDate
	, strEntity =  EN.strName
	, CH.strInternalComment
	, strItem = IT.strItemNo
	, CD.dblQuantity
	, strQtyUOM = IUOM.strUnitMeasure
	, CD.dblNetWeight
	, strWeightUOM = WUOM.strUnitMeasure
	, strContractItem = IC.strContractItemName
	, strMarket = FMarket.strFutMarketName
	, strMonth = FMonth.strFutureMonth
	, CU.strCurrency
	, strPriceUOM = PUOM.strUnitMeasure
	, CD.dblFutures
	, strProductType = PT.strDescription
	, strINCOShipTerms = ST.strFreightTerm
	, CS.strContractStatus
	, CCTotal.dblFinancingCost
	, CCTotal.dblFOB
	, CCTotal.dblSustainabilityPremium
	, CCTotal.dblFOBCAD
	, CCTotal.dblOtherCost
	, CD.dblBasis
	, CD.dblCashPrice
FROM tblCTContractDetail CD
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblEMEntity EN ON EN.intEntityId = CH.intEntityId
JOIN tblICItem IT ON IT.intItemId = CD.intItemId
JOIN tblICUnitMeasure IUOM ON IUOM.intUnitMeasureId = CD.intUnitMeasureId
JOIN tblICItemUOM WIUOM ON WIUOM.intItemUOMId = CD.intNetWeightUOMId
JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = WIUOM.intUnitMeasureId
JOIN tblICItemUOM PIUOM ON PIUOM.intItemUOMId = CD.intPriceItemUOMId
JOIN tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId = PIUOM.intUnitMeasureId
JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
LEFT JOIN (
	SELECT intContractDetailId
		, dblFinancingCost = [Financing cost]
		, dblFOB = [FOB +]
		, dblSustainabilityPremium = [Sustainability Premium]
		, dblFOBCAD = [FOB CAD]
		, dblOtherCost = [Other costs]
	FROM (
		SELECT intContractDetailId
			, strItemNo
			, dblRate
		FROM vyuCTContractCostView
		WHERE ysnBasis = 1
	) t 
	PIVOT(
		SUM(dblRate)
		FOR strItemNo IN ([Financing cost]
			, [FOB +]
			, [Sustainability Premium]
			, [FOB CAD]
			, [Other costs])
	) AS pivot_table
) CCTotal ON CCTotal.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblICItemUOM IIUOM ON IIUOM.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
LEFT JOIN tblRKFutureMarket FMarket ON FMarket.intFutureMarketId = CD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth FMonth ON FMonth.intFutureMonthId = CD.intFutureMonthId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
LEFT JOIN tblSMFreightTerms ST ON ST.intFreightTermId = ISNULL(CH.intFreightTermId, CD.intFreightTermId)
LEFT JOIN tblICCommodityAttribute PT ON	PT.intCommodityAttributeId = IT.intProductTypeId AND PT.strType = 'ProductType'
WHERE CD.intContractStatusId <> 3