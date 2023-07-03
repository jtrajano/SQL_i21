Create PROCEDURE [dbo].[uspCTGetItemPriceByLevel]  
 @intEntityId int = null,  
 @intItemId int = null,  
 @dtmContractDate Date = null,  
 @dblQuantity decimal(18,6) = 0,  
 @intLocationId int = null,  
 @intItemUOMId int = null  
AS  
BEGIN TRY  
  
 DECLARE @ErrMsg NVARCHAR(MAX)  
 DECLARE @intCompanyLocationPricingLevelId int   
   
 SELECT @intCompanyLocationPricingLevelId = intCompanyLocationPricingLevelId  
 FROM tblARCustomer  
 WHERE intEntityId = @intEntityId  
  
 IF ISNULL(@intCompanyLocationPricingLevelId,0) = 0  
 BEGIN  
  return;  
 END  
 
  SET @dblQuantity = ISNULL(@dblQuantity,0)
  
 SELECT TOP 1 dblUnitPrice   
 FROM tblICItemPricingLevel   
 WHERE intCompanyLocationPricingLevelId = @intCompanyLocationPricingLevelId   
 AND intItemId = @intItemId  
 And ISNULL(dtmEffectiveDate, '1990-01-01') <= @dtmContractDate  
 AND CASE WHEN @dblQuantity = 0 THEN 0 ELSE @dblQuantity END Between CASE WHEN dblMin = 0 THEN @dblQuantity ELSE dblMin END AND CASE WHEN dblMax = 0 THEN @dblQuantity ELSE dblMax END  
 AND intItemUnitMeasureId = @intItemUOMId  
 ORDER BY ISNULL(dtmEffectiveDate, '1990-01-01') DESC  
  
END TRY        
BEGIN CATCH         
 SET @ErrMsg = ERROR_MESSAGE()        
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')        
END CATCH

