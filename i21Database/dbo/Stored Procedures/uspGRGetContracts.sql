CREATE PROCEDURE [dbo].[uspGRGetContracts]
	@strSearchCriteria NVARCHAR(MAX)
AS
BEGIN TRY  
 DECLARE @ErrMsg NVARCHAR(MAX)  
 DECLARE @sql NVARCHAR(MAX)   
 DECLARE @ItemIdIndex INT  
 DECLARE @ItemId INT  
 DECLARE @intUnitMeasureId INT  
  
 SET @ItemIdIndex =  CHARINDEX('intItemId=',@strSearchCriteria)  
 SET @ItemId= SUBSTRING(@strSearchCriteria,@ItemIdIndex+10,14)  
   
 SELECT @intUnitMeasureId=a.intUnitMeasureId   
 FROM tblICCommodityUnitMeasure a   
 JOIN tblICItem b ON b.intCommodityId=a.intCommodityId  
 WHERE b.intItemId=@ItemId AND a.ysnStockUnit=1   
    
 IF @strSearchCriteria <> ''  
   SET @sql='SELECT intContractDetailId   
    ,strContractNumber  
    ,intEntityId  
    ,strEntityName       
    ,dbo.fnCTConvertQuantityToTargetItemUOM(intItemId,intUnitMeasureId,'+LTRIM(@intUnitMeasureId)+',dblAvailableQty)dblAvailableQty
	,dblAvailableQtyInItemStockUOM
	,dblBalanceInItemStockUOM  
    ,strContractType  
    ,dblCashPrice
	,dblFutures   
    ,dtmStartDate  
    ,intContractSeq   
    ,dblBasis       
    ,strContractStatus   
    ,ysnUnlimitedQuantity   
    ,strPricingType   
    ,intDetailConcurrencyId   
    ,intContractHeaderId   
    ,intCompanyLocationId   
    ,strLocationName   
    ,intItemId   
    ,strItemNo   
    ,intUnitMeasureId   
    ,intPricingTypeId   
    ,intDiscountId   
    ,dblOriginalQty   
    ,dblBalance   
    ,dblAvailableQty   
    ,intContractTypeId   
    ,intCommodityId   
    ,ysnEarlyDayPassed   
    ,ysnAllowedToShow   
    ,intContractStatusId
	,dblScheduleQty
	,intItemUOMId
	,intStorageScheduleRuleId
    ,intFarmFieldId
    ,intGradeId
    ,intWeightId FROM vyuCTContractDetailView WHERE '+@strSearchCriteria+' Order By intContractDetailId'    
 ELSE  
  SET @sql='SELECT * FROM vyuCTContractDetailView Order By intContractDetailId'  
    
 EXEC sp_executesql @sql  
     
END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')    
END CATCH