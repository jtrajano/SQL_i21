CREATE VIEW [dbo].[vyuCTContractOptionView]

AS

SELECT
	intId = CAST(ROW_NUMBER() OVER (ORDER BY CD.intContractDetailId, CH.strContractNumber) AS INT)
	 ,CD.intContractDetailId 
	 ,CH.intContractHeaderId
	,CH.strContractNumber
	,CD.intContractSeq
	,CT.strContractType
	,PT.strPricingType 
	,ET.strName
	,dbo.fnCTGetContractStatuses(CH.intContractHeaderId) COLLATE Latin1_General_CI_AS AS	strStatuses
	,CH.intCommodityId
	,C.strDescription
	,CH.intCommodityUOMId
	,UM.strUnitMeasure
	,CH.dblQuantity
	,MA.strFutMarketName
	,MO.strFutureMonth
	,BS.strBuySell
	,PC.strPutCall
	,CO.dblStrike
	,dblPremium
	,dblServiceFee
	,dtmExpiration
	,ISNULL(dblTargetPrice,0) as dblTargetPrice
	,strPremFee
FROM tblCTContractDetail CD
INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
INNER JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
INNER JOIN tblEMEntity ET ON ET.intEntityId = CH.intEntityId
INNER JOIN tblICCommodityUnitMeasure CM	ON	CM.intCommodityUnitMeasureId = CH.intCommodityUOMId
INNER JOIN tblICUnitMeasure	UM	ON	UM.intUnitMeasureId	= CM.intUnitMeasureId
LEFT JOIN tblICCommodity C ON C.intCommodityId = CH.intCommodityId
LEFT JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = CD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
INNER JOIN tblCTContractOption CO ON CO.intContractDetailId = CD.intContractDetailId
INNER JOIN tblCTBuySell BS ON BS.intBuySellId = CO.intBuySellId
INNER JOIN tblCTPutCall PC ON PC.intPutCallId = CO.intPutCallId
INNER JOIN tblCTPremFee PF ON PF.intPremFeeId = CO.intPremFeeId
INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CH.intPricingTypeId