CREATE VIEW [dbo].[vyuGRSettleContractNotMapped]
AS
SELECT    
 S.intSettleStorageId
,T.intSettleContractId
,T.intContractDetailId
,V.strContractNumber
,V.intEntityId
,V.strEntityName
,V.dblAvailableQty
,V.strContractType
,CASE WHEN V.dblAvailableQty < T.dblUnits THEN V.dblAvailableQty ELSE T.dblUnits END AS dblUnits
,V.dblCashPrice
,V.dblFutures   
,V.dtmStartDate  
,V.intContractSeq   
,V.dblBasis       
,V.strContractStatus   
,V.ysnUnlimitedQuantity   
,V.strPricingType   
,V.intDetailConcurrencyId   
,V.intContractHeaderId   
,V.intCompanyLocationId   
,V.strLocationName   
,V.intItemId   
,V.strItemNo   
,V.intUnitMeasureId   
,V.intPricingTypeId   
,V.intDiscountId   
,V.dblOriginalQty   
,V.dblBalance    
,V.intContractTypeId   
,V.intCommodityId   
,V.ysnEarlyDayPassed   
,V.ysnAllowedToShow   
,V.intContractStatusId
,V.dblScheduleQty
,V.intItemUOMId
FROM tblGRSettleStorage S
JOIN tblGRSettleContract T ON T.intSettleStorageId=S.intSettleStorageId
JOIN vyuCTContractDetailView V ON V.intContractDetailId=T.intContractDetailId  

