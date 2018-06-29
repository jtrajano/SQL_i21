CREATE VIEW [dbo].[vyuGRSettleContractNotMapped]
AS
SELECT    
 intSettleStorageId    = S.intSettleStorageId
,intSettleContractId   = T.intSettleContractId
,intContractDetailId   = T.intContractDetailId
,strContractNumber     = V.strContractNumber
,intEntityId		   = V.intEntityId
,strEntityName		   = V.strEntityName
,dblAvailableQty	   = V.dblAvailableQtyInCommodityStockUOM
,strContractType	   = V.strContractType
,dblUnits			   = T.dblUnits 
,dblCashPrice		   = V.dblCashPriceInCommodityStockUOM
,dblFutures			   = V.dblFutures   
,dtmStartDate		   = V.dtmStartDate  
,intContractSeq		   = V.intContractSeq   
,dblBasis			   = V.dblBasis       
,strContractStatus	   = V.strContractStatus   
,ysnUnlimitedQuantity  = V.ysnUnlimitedQuantity   
,strPricingType		   = V.strPricingType   
,intContractHeaderId   = V.intContractHeaderId   
,intCompanyLocationId  = V.intCompanyLocationId   
,strLocationName       = V.strLocationName   
,intItemId             = V.intItemId   
,strItemNo             = V.strItemNo     
,intPricingTypeId      = V.intPricingTypeId   
,intContractTypeId     = V.intContractTypeId   
,intContractStatusId   = V.intContractStatusId
FROM tblGRSettleStorage S
JOIN tblGRSettleContract T ON T.intSettleStorageId=S.intSettleStorageId
JOIN vyuGRGetSettleContracts V ON V.intContractDetailId=T.intContractDetailId  

