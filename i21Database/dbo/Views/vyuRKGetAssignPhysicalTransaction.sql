CREATE VIEW vyuRKGetAssignPhysicalTransaction

AS
  SELECT *,intNoOfLots-intHedgedLots as intToBeHedgedLots FROM
 (SELECT intContractDetailId,CH.intContractHeaderId,
 CH.dtmContractDate,CH.strContractType,CD.intContractSeq,
 strEntityName as strCustomer,
 dblQuantity as dblQuantity,
 uc.strUnitMeasure,
 0.0 as dblWeights,
 m.strFutMarketName,
 mo.strFutureMonth,
 isnull(CD.intNoOfLots,0) intNoOfLots,
 IsNull((SELECT SUM(AD.intHedgedLots) FROM tblRKAssignFuturesToContractSummary AD Group By AD.intContractDetailId 
		Having CD.intContractDetailId = AD.intContractDetailId), 0) as intHedgedLots,
  IsNull((SELECT SUM(AD.intAssignedLots) FROM tblRKAssignFuturesToContractSummary AD Group By AD.intContractDetailId 
		Having CD.intContractDetailId = AD.intContractDetailId), 0) as intAssignedLots,
 CH.strCommodityCode,
 CL.strLocationName,mo.ysnExpired,
 b.strBook,
 sb.strSubBook
 FROM tblCTContractDetail    CD  
 JOIN vyuCTContractHeaderView   CH ON CH.intContractHeaderId  = CD.intContractHeaderId        
 join tblRKFutureMarket m on CD.intFutureMarketId=m.intFutureMarketId
 join tblRKFuturesMonth mo on CD.intFutureMonthId=mo.intFutureMonthId
 JOIN tblSMCompanyLocation   CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId  
 JOIN tblICUnitMeasure uc on CD.intUnitMeasureId=uc.intUnitMeasureId
 LEFT JOIN tblCTBook b on CD.intBookId=b.intBookId
 LEFT JOIN tblCTSubBook sb on CD.intSubBookId=sb.intSubBookId)t  
