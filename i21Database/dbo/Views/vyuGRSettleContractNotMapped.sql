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
,T.dblUnits dblUnits
,V.dblCashPrice
,V.dblFutures   
,V.dtmStartDate  
,V.intContractSeq   
,V.dblBasis       
,V.strContractStatus   
,V.ysnUnlimitedQuantity   
,V.strPricingType   
,V.intContractHeaderId   
,V.intCompanyLocationId   
,V.strLocationName   
,V.intItemId   
,V.strItemNo     
,V.intPricingTypeId   
,V.intContractTypeId   
,V.intContractStatusId
FROM tblGRSettleStorage S
JOIN tblGRSettleContract T ON T.intSettleStorageId=S.intSettleStorageId
JOIN vyuGRGetContracts V ON V.intContractDetailId=T.intContractDetailId  

