CREATE VIEW vyuLGGetSaleContractForStockSale
AS
SELECT DISTINCT CH.intContractHeaderId
	,CH.strContractNumber
	,CH.intEntityId
	,E.strName AS strCustomerName
	,CH.intSalespersonId
	,SP.strName AS strSalespersonId
	,CH.intPositionId
	,PO.strPosition
	,CH.intContractBasisId
	,CB.strContractBasis
	,CH.intINCOLocationTypeId
	,CT.strCity AS strINCOLocationTypeId
	,CH.intCountryId
	,CO.strCountry
	,CH.intPricingTypeId
	,PT.strPricingType
	,CH.intInsuranceById
	,IB.strInsuranceBy
	,CH.intTermId
	,TE.strTerm
	,CH.intWeightId
	,WG.strWeightGradeDesc AS strWeightGrade
	,CH.intGradeId
	,G.strWeightGradeDesc AS strGrade
	,CD.dtmStartDate
	,CD.dtmEndDate
	,CD.intFutureMarketId
	,FMA.strFutMarketName
	,CD.intFutureMonthId
	,FMO.strFutureMonth
	,CH.ysnMultiplePriceFixation
	,CH.strInternalComment
	,CD.strFixationBy
	,CD.dblFutures
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
JOIN tblEMEntity SP ON SP.intEntityId = CH.intSalespersonId
JOIN tblCTPosition PO ON PO.intPositionId = CH.intPositionId
JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
JOIN tblCTPricingType PT ON PT.intPricingTypeId = CH.intPricingTypeId
LEFT JOIN tblSMCity CT ON CT.intCityId = CH.intINCOLocationTypeId
LEFT JOIN tblSMCountry CO ON CO.intCountryID = CH.intCountryId
LEFT JOIN tblCTInsuranceBy IB ON IB.intInsuranceById = CH.intInsuranceById
LEFT JOIN tblSMTerm TE ON TE.intTermID = CH.intTermId
LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
LEFT JOIN tblCTWeightGrade G ON G.intWeightGradeId = CH.intGradeId
LEFT JOIN tblRKFuturesMonth FMO ON FMO.intFutureMonthId = CD.intFutureMonthId
LEFT JOIN tblRKFutureMarket FMA ON FMA.intFutureMarketId = CD.intFutureMarketId
WHERE CH.intContractTypeId = 2