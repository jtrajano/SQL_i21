CREATE PROC [dbo].[uspRKInsertM2MBasisDetails]
  @intM2MBasisId int
    ,@intRowNumbers nvarchar(max)
AS
 
  DECLARE @tempBasis TABLE(  
  intRowNumber int
 ,strCommodityCode nvarchar(50)  
 ,strItemNo nvarchar(50)  
 ,strOriginDest nvarchar(50)  
 ,strFutMarketName nvarchar(50)  
 ,strFutureMonth nvarchar(50)  
 ,strPeriodTo nvarchar(50) COLLATE Latin1_General_CI_AS  
 ,strLocationName nvarchar(50)  
 ,strMarketZoneCode nvarchar(50)  
 ,strCurrency nvarchar(50)  
 ,strPricingType nvarchar(50)  
 ,strContractInventory nvarchar(50)  
 ,strContractType nvarchar(50)  
 ,dblCashOrFuture numeric(16,10)  
 ,dblBasisOrDiscount numeric(16,10)  
 ,strUnitMeasure nvarchar(50)  
 ,intCommodityId int  
 ,intItemId int  
 ,intOriginId int  
 ,intFutureMarketId int  
 ,intFutureMonthId int  
 ,intCompanyLocationId int  
 ,intMarketZoneId int  
 ,intCurrencyId int  
 ,intPricingTypeId int  
 ,intContractTypeId int  
 ,intUnitMeasureId  int  
 ,intConcurrencyId int
 ,strMarketValuation nvarchar(250)  
  )  
 
 INSERT INTO @tempBasis
 EXEC uspRKGetM2MBasis
 
 INSERT INTO [dbo].[tblRKM2MBasisDetail]
           ([intM2MBasisId]
           ,[intConcurrencyId]
           ,[intCommodityId]
           ,[intItemId]
           ,[strOriginDest]
           ,[intFutureMarketId]
           ,[intFutureMonthId]
           ,[strPeriodTo]
           ,[intCompanyLocationId]
           ,[intMarketZoneId]
           ,[intCurrencyId]
           ,[intPricingTypeId]
           ,[strContractInventory]
           ,[intContractTypeId]
           ,[dblCashOrFuture]
           ,[dblBasisOrDiscount]
           ,[intUnitMeasureId])
     SELECT
           @intM2MBasisId
     ,1
     ,intCommodityId
     ,intItemId
     ,strOriginDest
           ,intFutureMarketId
           ,intFutureMonthId
           ,strPeriodTo
           ,intCompanyLocationId
           ,intMarketZoneId
           ,intCurrencyId
           ,intPricingTypeId
           ,strContractInventory
           ,intContractTypeId
           ,dblCashOrFuture
           ,dblBasisOrDiscount
           ,intUnitMeasureId
 FROM @tempBasis
 WHERE intRowNumber NOT IN (SELECT * FROM dbo.[fnCommaSeparatedValueToTable](@intRowNumbers))