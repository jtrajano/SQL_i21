CREATE VIEW vyuRKGetAssignPhysicalTransaction

AS
 SELECT  convert(int,row_number() OVER(ORDER BY intContractDetailId)) intRowNum, * FROM (
 SELECT *,intNoOfLots-intHedgedLots as intToBeHedgedLots FROM
 (SELECT intContractDetailId,CH.intContractHeaderId,
 CH.dtmContractDate,CT.strContractType,CH.strContractNumber ,CD.intContractSeq,
 E.strName as strCustomer,
 CD.dblQuantity as dblQuantity,
 UC.strUnitMeasure,
 ISNULL(CD.dblNetWeight,0.0) as dblWeights,
 M.strFutMarketName,
 MO.strFutureMonth,
 ISNULL(convert(int,CD.dblNoOfLots),0) intNoOfLots,
 ISNULL((SELECT SUM(AD.intHedgedLots) FROM tblRKAssignFuturesToContractSummary AD Group By AD.intContractDetailId 
		HAVING CD.intContractDetailId = AD.intContractDetailId), 0) as intHedgedLots,
 ISNULL((SELECT SUM(AD.dblAssignedLots) FROM tblRKAssignFuturesToContractSummary AD Group By AD.intContractDetailId 
		HAVING CD.intContractDetailId = AD.intContractDetailId), 0) as dblAssignedLots,
 COM.strCommodityCode,
 CL.strLocationName,MO.ysnExpired,
 B.strBook,
 SB.strSubBook
 FROM tblCTContractDetail CD  
 JOIN tblCTContractHeader CH ON CH.intContractHeaderId  = CD.intContractHeaderId  and CD.intContractStatusId <> 3 
 JOIN tblCTContractType CT on CT.intContractTypeId=CH.intContractTypeId 
 JOIN tblEMEntity E on E.intEntityId=CH.intEntityId 
 JOIN tblICCommodity COM on COM.intCommodityId=CH.intCommodityId
 JOIN tblRKFutureMarket M on CD.intFutureMarketId=M.intFutureMarketId
 JOIN tblRKFuturesMonth MO on CD.intFutureMonthId=MO.intFutureMonthId
 JOIN tblSMCompanyLocation   CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId  
 JOIN tblICUnitMeasure UC on CD.intUnitMeasureId=UC.intUnitMeasureId
 LEFT JOIN tblCTBook B on CD.intBookId=B.intBookId
 LEFT JOIN tblCTSubBook SB on CD.intSubBookId=SB.intSubBookId where  isnull(CH.ysnMultiplePriceFixation, 0) = 0)t  

 UNION 

 SELECT *,intNoOfLots-intHedgedLots as intToBeHedgedLots FROM
 (
 SELECT NULL AS intContractDetailId,CH.intContractHeaderId,
		 CH.dtmContractDate,CT.strContractType,CH.strContractNumber ,null as intContractSeq,
		 E.strName as strCustomer,
		 CH.dblQuantity as dblQuantity,
		 UC.strUnitMeasure,
		 0.0 as dblWeights,
		 M.strFutMarketName,
		 MO.strFutureMonth,
		 ISNULL(convert(int,CH.dblNoOfLots),0) intNoOfLots,
		 ISNULL((SELECT SUM(AD.intHedgedLots) FROM tblRKAssignFuturesToContractSummary AD Group By AD.intContractHeaderId 
				HAVING CH.intContractHeaderId = AD.intContractHeaderId), 0) as intHedgedLots,
		 ISNULL((SELECT SUM(AD.dblAssignedLots) FROM tblRKAssignFuturesToContractSummary AD Group By AD.intContractHeaderId 
				HAVING CH.intContractHeaderId = AD.intContractHeaderId), 0) as dblAssignedLots,
		 COM.strCommodityCode,
		 CL.strLocationName,MO.ysnExpired,
		 B.strBook,
		 SB.strSubBook
 FROM tblCTContractHeader CH
 JOIN tblCTContractType CT on CT.intContractTypeId=CH.intContractTypeId 
 JOIN tblEMEntity E on E.intEntityId=CH.intEntityId 
 JOIN tblICCommodity COM on COM.intCommodityId=CH.intCommodityId
 JOIN tblRKFutureMarket M on CH.intFutureMarketId=M.intFutureMarketId
 JOIN tblRKFuturesMonth MO on CH.intFutureMonthId=MO.intFutureMonthId
 JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = (SELECT TOP 1 intCompanyLocationId from tblCTContractDetail CD WHERE CD.intContractHeaderId=CH.intContractHeaderId)  
 JOIN tblICUnitMeasure UC on UC.intUnitMeasureId = (SELECT TOP 1 intUnitMeasureId from tblCTContractDetail CD where CD.intContractHeaderId=CH.intContractHeaderId)
 LEFT JOIN tblCTBook B on B.intBookId = (SELECT TOP 1 intBookId from tblCTContractDetail CD where CD.intContractHeaderId=CH.intContractHeaderId)
 LEFT JOIN tblCTSubBook SB on SB.intSubBookId = (SELECT TOP 1 intSubBookId from tblCTContractDetail CD where CD.intContractHeaderId=CH.intContractHeaderId)
 WHERE  isnull(CH.ysnMultiplePriceFixation, 0) = 1 
 AND intContractHeaderId <> (SELECT top 1 intContractHeaderId FROM tblCTContractDetail CCD where  CCD.intContractStatusId <> 3 ))t  )t1