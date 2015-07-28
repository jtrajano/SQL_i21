CREATE VIEW vyuRKGetAssignPhysicalTransaction

AS
  
 SELECT intContractDetailId,
 CH.dtmContractDate,CH.strContractType,CD.intContractSeq,
 '' as strCustomer,
 dblQuantity as dblQuantity,
 uc.strUnitMeasure,
 0.0 as dblWeights,
 m.strFutMarketName,
 mo.strFutureMonth,
 isnull(CD.intNoOfLots,0) intNoOfLots,
 0 as intHedgedLots,
 0 as intToBeHedgedLots,
 0 as intAssignedLots,
 CH.strCommodityCode,
 CL.strLocationName,
 b.strBook,
 sb.strSubBook
 FROM tblCTContractDetail    CD  
 JOIN vyuCTContractHeaderView   CH ON CH.intContractHeaderId  = CD.intContractHeaderId        
 join tblRKFutureMarket m on CD.intFutureMarketId=m.intFutureMarketId
 join tblRKFuturesMonth mo on CD.intFutureMonthId=mo.intFutureMonthId
 JOIN tblSMCompanyLocation   CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId  
 JOIN tblICUnitMeasure uc on CD.intUnitMeasureId=uc.intUnitMeasureId
 LEFT JOIN tblCTBook b on CD.intBookId=b.intBookId
 LEFT JOIN tblCTSubBook sb on CD.intSubBookId=sb.intSubBookId 
 
