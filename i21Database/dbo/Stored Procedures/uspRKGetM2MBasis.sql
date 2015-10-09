﻿CREATE PROC uspRKGetM2MBasis 
		@strCopyData nvarchar(50)= null 
AS
IF ISNULL(@strCopyData,'')<>''
BEGIN
	DECLARE @dtmCopyData datetime
	DECLARE @intM2MBasisId int	
	SET @dtmCopyData = convert(datetime,@strCopyData)
	SELECT @intM2MBasisId = intM2MBasisId FROM tblRKM2MBasis where dtmM2MBasisDate= @dtmCopyData
	
END

DECLARE @ysnIncludeInventoryM2M bit,
		@ysnIncludeBasisDifferentialsInResults bit,
		@ysnValueBasisAndDPDeliveries bit,
		@ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell bit,
		@ysnEnterForwardCurveForMarketBasisDifferential bit,		
		@strEvaluationBy nvarchar(50),
		@strEvaluationByZone nvarchar(50)
		
SELECT TOP 1 @ysnIncludeInventoryM2M = ysnIncludeInventoryM2M,
			 @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell,
			 @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential,			 
			 @strEvaluationBy =  strEvaluationBy,
			 @strEvaluationByZone =  strEvaluationByZone 
FROM tblRKCompanyPreference         

 DECLARE @tempBasis TABLE(
     strCommodityCode nvarchar(50)
	,strItemNo nvarchar(50)
	,strOriginDest nvarchar(50)
	,strFutMarketName nvarchar(50)
	,strFutureMonth nvarchar(50)
	,strPeriodTo nvarchar(50)
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
	 )

IF (@strEvaluationBy='Commodity' AND @strEvaluationByZone='Zone')
BEGIN
	IF @ysnEnterForwardCurveForMarketBasisDifferential= 0
	BEGIN
			IF (@ysnIncludeInventoryM2M = 0)
			BEGIN
					DELETE FROM @tempBasis
					INSERT INTO @tempBasis
						SELECT DISTINCT strCommodityCode
										,'' strItemNo
										,'' strOriginDest
										,strFutMarketName
										,'' strFutureMonth
										,NULL strPeriodTo
										,'' strLocationName
										,strMarketZoneCode
										,strCurrency
										,'' strPricingType
										,strContractInventory
										,'' strContractType
										,dblCashOrFuture
										,dblBasisOrDiscount
										,strUnitMeasure
										,intCommodityId  
										,NULL intItemId
										,NULL intOriginId
										,intFutureMarketId
										,NULL intFutureMonthId
										,NULL intCompanyLocationId
										,intMarketZoneId
										,intCurrencyId
										,NULL intPricingTypeId
										,NULL intContractTypeId
										,intUnitMeasureId
										,intConcurrencyId										
						FROM vyuRKGetM2MBasis 
			END
			ELSE IF (@ysnIncludeInventoryM2M = 1)
			BEGIN
					DELETE FROM @tempBasis
					INSERT INTO @tempBasis
						SELECT DISTINCT strCommodityCode
										,'' strItemNo
										,'' strOriginDest
										,strFutMarketName
										,'' strFutureMonth
										,NULL strPeriodTo
										,'' strLocationName
										,strMarketZoneCode
										,strCurrency
										,'' strPricingType
										,strContractInventory
										,'' strContractType
										,dblCashOrFuture
										,dblBasisOrDiscount
										,strUnitMeasure
										,intCommodityId  
										,NULL intItemId
										,NULL intOriginId
										,intFutureMarketId
										,NULL intFutureMonthId
										,NULL intCompanyLocationId
										,intMarketZoneId
										,intCurrencyId
										,NULL intPricingTypeId
										,NULL intContractTypeId
										,intUnitMeasureId
										,intConcurrencyId										
						FROM vyuRKGetM2MBasis 
						UNION
						SELECT DISTINCT strCommodityCode
										,'' strItemNo
										,'' strOriginDest
										,strFutMarketName
										,'' strFutureMonth
										,NULL strPeriodTo
										,'' strLocationName
										,strMarketZoneCode
										,strCurrency
										,'' strPricingType
										,'Inventory' as strContractInventory
										,'' strContractType
										,dblCashOrFuture
										,dblBasisOrDiscount
										,strUnitMeasure
										,intCommodityId  
										,NULL intItemId
										,NULL intOriginId
										,intFutureMarketId
										,NULL intFutureMonthId
										,NULL intCompanyLocationId
										,intMarketZoneId
										,intCurrencyId
										,NULL intPricingTypeId
										,NULL intContractTypeId
										,intUnitMeasureId
										,intConcurrencyId
										
						FROM vyuRKGetM2MBasis 
			END
			
			
	END
	ELSE IF @ysnEnterForwardCurveForMarketBasisDifferential= 1
	BEGIN
		IF (@ysnIncludeInventoryM2M = 0)
			BEGIN
					DELETE FROM @tempBasis
					INSERT INTO @tempBasis
						SELECT DISTINCT strCommodityCode
										,'' strItemNo
										,'' strOriginDest
										,strFutMarketName
										,'' strFutureMonth
										,NULL strPeriodTo
										,'' strLocationName
										,strMarketZoneCode
										,strCurrency
										,'' strPricingType
										,strContractInventory
										,'' strContractType
										,dblCashOrFuture
										,dblBasisOrDiscount
										,strUnitMeasure
										,intCommodityId  
										,NULL intItemId
										,NULL intOriginId
										,intFutureMarketId
										,NULL intFutureMonthId
										,NULL intCompanyLocationId
										,intMarketZoneId
										,intCurrencyId
										,NULL intPricingTypeId
										,NULL intContractTypeId
										,intUnitMeasureId
										,intConcurrencyId
										
						FROM vyuRKGetM2MBasis 
			END
			ELSE IF (@ysnIncludeInventoryM2M = 1)
			BEGIN
					DELETE FROM @tempBasis
					INSERT INTO @tempBasis
						SELECT DISTINCT strCommodityCode
										,'' strItemNo
										,'' strOriginDest
										,strFutMarketName
										,'' strFutureMonth
										,NULL strPeriodTo
										,'' strLocationName
										,strMarketZoneCode
										,strCurrency
										,'' strPricingType
										,strContractInventory
										,'' strContractType
										,dblCashOrFuture
										,dblBasisOrDiscount
										,strUnitMeasure
										,intCommodityId  
										,NULL intItemId
										,NULL intOriginId
										,intFutureMarketId
										,NULL intFutureMonthId
										,NULL intCompanyLocationId
										,intMarketZoneId
										,intCurrencyId
										,NULL intPricingTypeId
										,NULL intContractTypeId
										,intUnitMeasureId
										,intConcurrencyId
										
						FROM vyuRKGetM2MBasis 
						UNION
						SELECT DISTINCT strCommodityCode
										,'' strItemNo
										,'' strOriginDest
										,strFutMarketName
										,'' strFutureMonth
										,NULL strPeriodTo
										,'' strLocationName
										,strMarketZoneCode
										,strCurrency
										,'' strPricingType
										,'Inventory' as strContractInventory
										,'' strContractType
										,dblCashOrFuture
										,dblBasisOrDiscount
										,strUnitMeasure
										,intCommodityId  
										,NULL intItemId
										,NULL intOriginId
										,intFutureMarketId
										,NULL intFutureMonthId
										,NULL intCompanyLocationId
										,intMarketZoneId
										,intCurrencyId
										,NULL intPricingTypeId
										,NULL intContractTypeId
										,intUnitMeasureId
										,intConcurrencyId
										
						FROM vyuRKGetM2MBasis 
			END
	END
	
	IF ISNULL(@strCopyData,'')<>'' and @intM2MBasisId is not null
		BEGIN
			UPDATE a 
			SET  a.dblCashOrFuture =b.dblCashOrFuture,a.dblBasisOrDiscount =b.dblBasisOrDiscount
			FROM @tempBasis a 
			JOIN tblRKM2MBasisDetail b ON a.intCommodityId=b.intCommodityId
			 AND isnull(a.intFutureMarketId,0)=isnull(b.intFutureMarketId,0) and isnull(a.intMarketZoneId,0)=isnull(b.intMarketZoneId,0)
			AND isnull(a.intCurrencyId,0)=isnull(b.intCurrencyId,0) and isnull(a.intUnitMeasureId,0)=isnull(b.intUnitMeasureId,0)
			WHERE b.intM2MBasisId=@intM2MBasisId			 
		END
END

ELSE IF (@strEvaluationBy='Commodity' AND @strEvaluationByZone='Location')
BEGIN
	IF @ysnEnterForwardCurveForMarketBasisDifferential= 0
	BEGIN
		IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
			FROM vyuRKGetM2MBasis 
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
			FROM vyuRKGetM2MBasis 
			UNION
			SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,'Inventory' strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
			FROM vyuRKGetM2MBasis 
		END
	END
	ELSE IF	@ysnEnterForwardCurveForMarketBasisDifferential= 1
	BEGIN
		IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
			FROM vyuRKGetM2MBasis 
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
			FROM vyuRKGetM2MBasis 
			UNION
			SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,'Inventory' strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
			FROM vyuRKGetM2MBasis 
		END
	END
	
	IF ISNULL(@strCopyData,'')<>'' and @intM2MBasisId is not null
		BEGIN
			UPDATE a 
			SET  a.dblCashOrFuture =b.dblCashOrFuture,a.dblBasisOrDiscount =b.dblBasisOrDiscount
			FROM @tempBasis a 
			JOIN tblRKM2MBasisDetail b ON a.intCommodityId=b.intCommodityId and isnull(a.intCompanyLocationId,0)=isnull(b.intCompanyLocationId,0)
			 AND isnull(a.intFutureMarketId,0)=isnull(b.intFutureMarketId,0)
			AND isnull(a.intCurrencyId,0)=isnull(b.intCurrencyId,0) and isnull(a.intUnitMeasureId,0)=isnull(b.intUnitMeasureId,0)
			WHERE b.intM2MBasisId=@intM2MBasisId			 
		END
	
END

ELSE IF (@strEvaluationBy='Commodity' AND @strEvaluationByZone='Company')
BEGIN	
	IF	@ysnEnterForwardCurveForMarketBasisDifferential= 0
	BEGIN
		IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
		FROM vyuRKGetM2MBasis 
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
		FROM vyuRKGetM2MBasis 
		UNION
		SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,'Inventory' strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
		FROM vyuRKGetM2MBasis 
		END
	END
	ELSE IF	@ysnEnterForwardCurveForMarketBasisDifferential= 1
	BEGIN
		IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
		FROM vyuRKGetM2MBasis 
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
		FROM vyuRKGetM2MBasis 
		UNION
		SELECT DISTINCT strCommodityCode   
				,'' strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,'Inventory' strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,NULL intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
		FROM vyuRKGetM2MBasis 
		END
	END
	
	IF ISNULL(@strCopyData,'')<>'' and @intM2MBasisId is not null
		BEGIN
			UPDATE a 
			SET  a.dblCashOrFuture =b.dblCashOrFuture,a.dblBasisOrDiscount =b.dblBasisOrDiscount
			FROM @tempBasis a 
			JOIN tblRKM2MBasisDetail b ON a.intCommodityId=b.intCommodityId 
			 AND isnull(a.intFutureMarketId,0)=isnull(b.intFutureMarketId,0)
			AND isnull(a.intCurrencyId,0)=isnull(b.intCurrencyId,0) and isnull(a.intUnitMeasureId,0)=isnull(b.intUnitMeasureId,0)
			WHERE b.intM2MBasisId=@intM2MBasisId			 
		END
	
END

ELSE IF (@strEvaluationBy='Item' AND @strEvaluationByZone='Zone')
BEGIN

	IF	@ysnEnterForwardCurveForMarketBasisDifferential= 0
	BEGIN
		IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode
						,strItemNo
						,'' strOriginDest
						,strFutMarketName
						,'' strFutureMonth
						,NULL strPeriodTo
						,'' strLocationName
						,strMarketZoneCode
						,strCurrency
						,'' strPricingType
						,strContractInventory
						,'' strContractType
						,dblCashOrFuture
						,dblBasisOrDiscount
						,strUnitMeasure
						,intCommodityId  
						,intItemId
						,NULL intOriginId
						,intFutureMarketId
						,NULL intFutureMonthId
						,NULL intCompanyLocationId
						,intMarketZoneId
						,intCurrencyId
						,NULL intPricingTypeId
						,NULL intContractTypeId
						,intUnitMeasureId
						,intConcurrencyId
						
		FROM vyuRKGetM2MBasis 
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode
						,strItemNo
						,'' strOriginDest
						,strFutMarketName
						,'' strFutureMonth
						,NULL strPeriodTo
						,'' strLocationName
						,strMarketZoneCode
						,strCurrency
						,'' strPricingType
						,strContractInventory
						,'' strContractType
						,dblCashOrFuture
						,dblBasisOrDiscount
						,strUnitMeasure
						,intCommodityId  
						,intItemId
						,NULL intOriginId
						,intFutureMarketId
						,NULL intFutureMonthId
						,NULL intCompanyLocationId
						,intMarketZoneId
						,intCurrencyId
						,NULL intPricingTypeId
						,NULL intContractTypeId
						,intUnitMeasureId
						,intConcurrencyId
						
		FROM vyuRKGetM2MBasis 
		UNION
		SELECT DISTINCT strCommodityCode
						,strItemNo
						,'' strOriginDest
						,strFutMarketName
						,'' strFutureMonth
						,NULL strPeriodTo
						,'' strLocationName
						,strMarketZoneCode
						,strCurrency
						,'' strPricingType
						,'Inventory' strContractInventory
						,'' strContractType
						,dblCashOrFuture
						,dblBasisOrDiscount
						,strUnitMeasure
						,intCommodityId  
						,intItemId
						,NULL intOriginId
						,intFutureMarketId
						,NULL intFutureMonthId
						,NULL intCompanyLocationId
						,intMarketZoneId
						,intCurrencyId
						,NULL intPricingTypeId
						,NULL intContractTypeId
						,intUnitMeasureId
						,intConcurrencyId
						
		FROM vyuRKGetM2MBasis 
		END
	END
	ELSE IF	@ysnEnterForwardCurveForMarketBasisDifferential= 1
	BEGIN
	IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode
						,strItemNo
						,'' strOriginDest
						,strFutMarketName
						,'' strFutureMonth
						,NULL strPeriodTo
						,'' strLocationName
						,strMarketZoneCode
						,strCurrency
						,'' strPricingType
						,strContractInventory
						,'' strContractType
						,dblCashOrFuture
						,dblBasisOrDiscount
						,strUnitMeasure
						,intCommodityId  
						,intItemId
						,NULL intOriginId
						,intFutureMarketId
						,NULL intFutureMonthId
						,NULL intCompanyLocationId
						,intMarketZoneId
						,intCurrencyId
						,NULL intPricingTypeId
						,NULL intContractTypeId
						,intUnitMeasureId
						,intConcurrencyId
						
		FROM vyuRKGetM2MBasis 
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode
						,strItemNo
						,'' strOriginDest
						,strFutMarketName
						,'' strFutureMonth
						,NULL strPeriodTo
						,'' strLocationName
						,strMarketZoneCode
						,strCurrency
						,'' strPricingType
						,strContractInventory
						,'' strContractType
						,dblCashOrFuture
						,dblBasisOrDiscount
						,strUnitMeasure
						,intCommodityId  
						,intItemId
						,NULL intOriginId
						,intFutureMarketId
						,NULL intFutureMonthId
						,NULL intCompanyLocationId
						,intMarketZoneId
						,intCurrencyId
						,NULL intPricingTypeId
						,NULL intContractTypeId
						,intUnitMeasureId
						,intConcurrencyId
					
		FROM vyuRKGetM2MBasis 
		UNION
		SELECT DISTINCT strCommodityCode
						,strItemNo
						,'' strOriginDest
						,strFutMarketName
						,'' strFutureMonth
						,NULL strPeriodTo
						,'' strLocationName
						,strMarketZoneCode
						,strCurrency
						,'' strPricingType
						,'Inventory' strContractInventory
						,'' strContractType
						,dblCashOrFuture
						,dblBasisOrDiscount
						,strUnitMeasure
						,intCommodityId  
						,intItemId
						,NULL intOriginId
						,intFutureMarketId
						,NULL intFutureMonthId
						,NULL intCompanyLocationId
						,intMarketZoneId
						,intCurrencyId
						,NULL intPricingTypeId
						,NULL intContractTypeId
						,intUnitMeasureId
						,intConcurrencyId
						
		FROM vyuRKGetM2MBasis 
		END
	END
	IF ISNULL(@strCopyData,'')<>'' and @intM2MBasisId is not null
		BEGIN
			UPDATE a 
			SET  a.dblCashOrFuture =b.dblCashOrFuture,a.dblBasisOrDiscount =b.dblBasisOrDiscount
			FROM @tempBasis a 
			JOIN tblRKM2MBasisDetail b ON a.intCommodityId=b.intCommodityId and isnull(a.intItemId,0)=isnull(b.intItemId,0)
			 AND isnull(a.intFutureMarketId,0)=isnull(b.intFutureMarketId,0) and isnull(a.intMarketZoneId,0)=isnull(b.intMarketZoneId,0)
			AND isnull(a.intCurrencyId,0)=isnull(b.intCurrencyId,0) and isnull(a.intUnitMeasureId,0)=isnull(b.intUnitMeasureId,0)
			WHERE b.intM2MBasisId=@intM2MBasisId			 
		END
	
END

ELSE IF (@strEvaluationBy='Item' AND @strEvaluationByZone='Location')
BEGIN
	
	IF	@ysnEnterForwardCurveForMarketBasisDifferential= 0
	BEGIN

		IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
			FROM vyuRKGetM2MBasis 
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
			FROM vyuRKGetM2MBasis 
			UNION
			SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,'Inventory' strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
			FROM vyuRKGetM2MBasis 
		END
	END
	ELSE IF	@ysnEnterForwardCurveForMarketBasisDifferential= 1
	BEGIN

	IF (@ysnIncludeInventoryM2M = 0)
	
		BEGIN 
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
			FROM vyuRKGetM2MBasis 
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
		
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
			FROM vyuRKGetM2MBasis 
			UNION
			SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,'Inventory' strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
			FROM vyuRKGetM2MBasis 
		END
	END

		IF ISNULL(@strCopyData,'')<>'' and @intM2MBasisId is not null
		BEGIN
		UPDATE a 
			SET  a.dblCashOrFuture =b.dblCashOrFuture,a.dblBasisOrDiscount =b.dblBasisOrDiscount
			FROM @tempBasis a 
			JOIN tblRKM2MBasisDetail b ON a.intCommodityId=b.intCommodityId AND isnull(a.intItemId,0)=isnull(b.intItemId,0) 
			and isnull(a.intCompanyLocationId,0)=isnull(b.intCompanyLocationId,0)
			 AND isnull(a.intFutureMarketId,0)=isnull(b.intFutureMarketId,0)
			AND isnull(a.intCurrencyId,0)=isnull(b.intCurrencyId,0) and isnull(a.intUnitMeasureId,0)=isnull(b.intUnitMeasureId,0)
			WHERE b.intM2MBasisId=@intM2MBasisId			 
		END
END

ELSE IF (@strEvaluationBy='Item' AND @strEvaluationByZone='Company')
BEGIN
IF	@ysnEnterForwardCurveForMarketBasisDifferential= 0
	BEGIN
		IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
		FROM vyuRKGetM2MBasis 
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
		FROM vyuRKGetM2MBasis 
		UNION
		SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,'Inventory' strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
		FROM vyuRKGetM2MBasis 
		END
	END
	ELSE IF @ysnEnterForwardCurveForMarketBasisDifferential= 1
	BEGIN
	IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
		FROM vyuRKGetM2MBasis 
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
		DELETE FROM @tempBasis
		INSERT INTO @tempBasis
		SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
				
		FROM vyuRKGetM2MBasis 
		UNION
		SELECT DISTINCT strCommodityCode   
				,strItemNo
				,'' strOriginDest
				,strFutMarketName
				,'' strFutureMonth
				,NULL strPeriodTo
				,'' strLocationName
				,'' strMarketZoneCode
				,strCurrency
				,'' strPricingType
				,'Inventory' strContractInventory
				,'' strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,NULL intOriginId
				,intFutureMarketId
				,NULL intFutureMonthId
				,NULL intCompanyLocationId
				,NULL intMarketZoneId
				,intCurrencyId
				,NULL intPricingTypeId
				,NULL intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId
			
		FROM vyuRKGetM2MBasis 
		END
	END
		IF ISNULL(@strCopyData,'')<>'' and @intM2MBasisId is not null
		BEGIN
			UPDATE a 
			SET  a.dblCashOrFuture =b.dblCashOrFuture,a.dblBasisOrDiscount =b.dblBasisOrDiscount
			FROM @tempBasis a 
			JOIN tblRKM2MBasisDetail b ON a.intCommodityId=b.intCommodityId AND isnull(a.intItemId,0)=isnull(b.intItemId,0)
			 AND isnull(a.intFutureMarketId,0)=isnull(b.intFutureMarketId,0)
			AND isnull(a.intCurrencyId,0)=isnull(b.intCurrencyId,0) and isnull(a.intUnitMeasureId,0)=isnull(b.intUnitMeasureId,0)
			WHERE b.intM2MBasisId=@intM2MBasisId			 
		END		
END

IF @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 
BEGIN
--select * from @tempBasis where strItemNo='Q-Corn'
	UPDATE @tempBasis set intContractTypeId=1,strContractType='Purchase' WHERE strContractInventory='Contract'
	INSERT INTO @tempBasis
	SELECT DISTINCT strCommodityCode   
				,strItemNo
				,strOriginDest
				,strFutMarketName
				,strFutureMonth
				,NULL strPeriodTo
				,strLocationName
				,strMarketZoneCode
				,strCurrency
				,strPricingType
				,strContractInventory
				,'Sale' as strContractType
				,dblCashOrFuture
				,dblBasisOrDiscount
				,strUnitMeasure
				,intCommodityId  
				,intItemId
				,intOriginId
				,intFutureMarketId
				,intFutureMonthId
				,intCompanyLocationId
				,intMarketZoneId
				,intCurrencyId
				,intPricingTypeId
				,2 intContractTypeId
				,intUnitMeasureId
				,intConcurrencyId FROM @tempBasis WHERE strContractInventory='Contract'
END


SELECT convert(int,ROW_NUMBER() over (ORDER BY strItemNo)) AS intRowNumber,* from @tempBasis order by 
				intCommodityId  
				,intItemId
				,intOriginId
				,intFutureMarketId,
				intFutureMonthId,
				intCompanyLocationId			
				,intMarketZoneId
				,intCurrencyId
				,intPricingTypeId
				,intContractTypeId				
				,intUnitMeasureId
				

