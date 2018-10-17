﻿CREATE PROCEDURE uspRKGetM2MBasis
	@strCopyData NVARCHAR(50) = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY
	
	IF (ISNULL(@strCopyData, '') <> '')
	BEGIN
		DECLARE @dtmCopyData DATETIME
			, @intM2MBasisId INT
		
		SET @dtmCopyData = CONVERT(DATETIME, @strCopyData)
		SELECT @intM2MBasisId = intM2MBasisId FROM tblRKM2MBasis WHERE CAST(FLOOR(CAST(dtmM2MBasisDate AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(@dtmCopyData AS FLOAT)) AS DATETIME)
	END
	
	DECLARE @ysnIncludeInventoryM2M BIT
		, @ysnIncludeBasisDifferentialsInResults BIT
		, @ysnValueBasisAndDPDeliveries BIT
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell BIT
		, @ysnEnterForwardCurveForMarketBasisDifferential BIT
		, @strEvaluationBy NVARCHAR(50)
		, @strEvaluationByZone NVARCHAR(50)
	
	SELECT TOP 1 @ysnIncludeInventoryM2M = ISNULL(ysnIncludeInventoryM2M, 0)
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = ISNULL(ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell, 0)
		, @ysnEnterForwardCurveForMarketBasisDifferential = ISNULL(ysnEnterForwardCurveForMarketBasisDifferential, 0)
		, @strEvaluationBy = strEvaluationBy
		, @strEvaluationByZone = strEvaluationByZone
	FROM tblRKCompanyPreference
	
	DECLARE @tempBasis TABLE(
		strCommodityCode NVARCHAR(50)
		, strItemNo NVARCHAR(50)
		, strOriginDest NVARCHAR(50)
		, strFutMarketName NVARCHAR(50)
		, strFutureMonth NVARCHAR(50)
		, strPeriodTo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(50)
		, strMarketZoneCode NVARCHAR(50)
		, strCurrency NVARCHAR(50)
		, strPricingType NVARCHAR(50)
		, strContractInventory NVARCHAR(50)
		, strContractType NVARCHAR(50)
		, dblCashOrFuture NUMERIC(16, 10)
		, dblBasisOrDiscount NUMERIC(16, 10)
		, strUnitMeasure NVARCHAR(50)
		, intCommodityId INT
		, intItemId INT
		, intOriginId INT
		, intFutureMarketId INT
		, intFutureMonthId INT
		, intCompanyLocationId INT
		, intMarketZoneId INT
		, intCurrencyId INT
		, intPricingTypeId INT
		, intContractTypeId INT
		, intUnitMeasureId  INT
		, intConcurrencyId INT
		, strMarketValuation NVARCHAR(250))
	
	IF (@strEvaluationBy = 'Commodity')
	BEGIN
		IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
			DELETE FROM @tempBasis
			INSERT INTO @tempBasis
			SELECT DISTINCT strCommodityCode
				, strItemNo = ''
				, strOriginDest = ''
				, strFutMarketName
				, strFutureMonth = ''
				, strPeriodTo = (CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN strPeriodTo ELSE NULL END)
				, strLocationName = (CASE WHEN @strEvaluationByZone = 'Location' THEN strLocationName ELSE NULL END)
				, strMarketZoneCode = (CASE WHEN @strEvaluationByZone = 'Market Zone' THEN strMarketZoneCode ELSE NULL END)
				, strCurrency
				, strPricingType
				, strContractInventory
				, strContractType = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN strContractType ELSE NULL END)
				, dblCashOrFuture
				, dblBasisOrDiscount
				, strUnitMeasure
				, intCommodityId
				, intItemId = NULL
				, intOriginId = NULL
				, intFutureMarketId
				, intFutureMonthId = NULL
				, intCompanyLocationId = (CASE WHEN @strEvaluationByZone = 'Location' THEN intCompanyLocationId ELSE NULL END)
				, intMarketZoneId = (CASE WHEN @strEvaluationByZone = 'Market Zone' THEN intMarketZoneId ELSE NULL END)
				, intCurrencyId
				, intPricingTypeId
				, intContractTypeId = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN intContractTypeId ELSE NULL END)
				, intUnitMeasureId
				, intConcurrencyId
				, strMarketValuation = ISNULL(strMarketValuation, '')
			FROM vyuRKGetM2MBasis WHERE strContractInventory <> 'Inventory'
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
			DELETE FROM @tempBasis
			INSERT INTO @tempBasis
			SELECT DISTINCT strCommodityCode
				, strItemNo = ''
				, strOriginDest = ''
				, strFutMarketName
				, strFutureMonth = ''
				, strPeriodTo = (CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN strPeriodTo ELSE NULL END)
				, strLocationName = (CASE WHEN @strEvaluationByZone = 'Location' THEN strLocationName ELSE NULL END)
				, strMarketZoneCode = (CASE WHEN @strEvaluationByZone = 'Market Zone' THEN strMarketZoneCode ELSE NULL END)
				, strCurrency
				, strPricingType
				, strContractInventory
				, strContractType = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN strContractType ELSE NULL END)
				, dblCashOrFuture
				, dblBasisOrDiscount
				, strUnitMeasure
				, intCommodityId
				, intItemId = NULL
				, intOriginId = NULL
				, intFutureMarketId
				, intFutureMonthId = NULL
				, intCompanyLocationId = (CASE WHEN @strEvaluationByZone = 'Location' THEN intCompanyLocationId ELSE NULL END)
				, intMarketZoneId = (CASE WHEN @strEvaluationByZone = 'Market Zone' THEN intMarketZoneId ELSE NULL END)
				, intCurrencyId
				, intPricingTypeId
				, intContractTypeId = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN intContractTypeId ELSE NULL END)
				, intUnitMeasureId
				, intConcurrencyId
				, strMarketValuation = ISNULL(strMarketValuation, '') 
			FROM vyuRKGetM2MBasis
		END
		
		IF ISNULL(@strCopyData, '') <> '' AND @intM2MBasisId IS NOT NULL
		BEGIN
			UPDATE a
			SET  a.dblCashOrFuture = b.dblCashOrFuture
				, a.dblBasisOrDiscount = b.dblBasisOrDiscount
				, a.intUnitMeasureId = b.intUnitMeasureId
				, a.strUnitMeasure = UOM.strUnitMeasure
			FROM @tempBasis a
			JOIN tblRKM2MBasisDetail b ON a.intCommodityId = b.intCommodityId
				AND ISNULL(a.intFutureMarketId, 0) = ISNULL(b.intFutureMarketId, 0)
				AND ISNULL(a.intMarketZoneId, 0) = ISNULL(b.intMarketZoneId, 0)
				AND ISNULL(a.intCurrencyId, 0) = ISNULL(b.intCurrencyId, 0)
				AND ISNULL(a.strPeriodTo, 0) = ISNULL(b.strPeriodTo, 0)
				AND ISNULL(a.intContractTypeId, 0) = ISNULL(b.intContractTypeId, 0)
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = b.intUnitMeasureId
			WHERE b.intM2MBasisId = @intM2MBasisId
		END
	END
	ELSE IF(@strEvaluationBy = 'Item')
	BEGIN
		IF (@ysnIncludeInventoryM2M = 0)
		BEGIN
			DELETE FROM @tempBasis
			INSERT INTO @tempBasis
			SELECT DISTINCT strCommodityCode
				, strItemNo
				, strOriginDest
				, strFutMarketName
				, strFutureMonth = ''
				, strPeriodTo = (CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN strPeriodTo ELSE NULL END)
				, strLocationName = (CASE WHEN @strEvaluationByZone = 'Location' THEN strLocationName ELSE NULL END)
				, strMarketZoneCode = (CASE WHEN @strEvaluationByZone = 'Market Zone' THEN strMarketZoneCode ELSE NULL END)
				, strCurrency
				, strPricingType
				, strContractInventory
				, strContractType = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN strContractType ELSE NULL END)
				, dblCashOrFuture
				, dblBasisOrDiscount
				, strUnitMeasure
				, intCommodityId
				, intItemId
				, intOriginId
				, intFutureMarketId
				, intFutureMonthId = NULL
				, intCompanyLocationId = (CASE WHEN @strEvaluationByZone = 'Location' THEN intCompanyLocationId ELSE NULL END)
				, intMarketZoneId = (CASE WHEN @strEvaluationByZone = 'Market Zone' THEN intMarketZoneId ELSE NULL END)
				, intCurrencyId
				, intPricingTypeId
				, intContractTypeId = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN intContractTypeId ELSE NULL END)
				, intUnitMeasureId
				, intConcurrencyId
				, strMarketValuation = ISNULL(strMarketValuation, '')
			FROM vyuRKGetM2MBasis WHERE strContractInventory <> 'Inventory'
		END
		ELSE IF (@ysnIncludeInventoryM2M = 1)
		BEGIN
			DELETE FROM @tempBasis
			INSERT INTO @tempBasis
			SELECT DISTINCT strCommodityCode
				, strItemNo
				, strOriginDest
				, strFutMarketName
				, strFutureMonth = ''
				, strPeriodTo = (CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1 THEN strPeriodTo ELSE NULL END)
				, strLocationName = (CASE WHEN @strEvaluationByZone = 'Location' THEN strLocationName ELSE NULL END)
				, strMarketZoneCode = (CASE WHEN @strEvaluationByZone = 'Market Zone' THEN strMarketZoneCode ELSE NULL END)
				, strCurrency
				, strPricingType
				, strContractInventory
				, strContractType = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN strContractType ELSE NULL END)
				, dblCashOrFuture
				, dblBasisOrDiscount
				, strUnitMeasure
				, intCommodityId
				, intItemId
				, intOriginId
				, intFutureMarketId
				, intFutureMonthId = NULL
				, intCompanyLocationId = (CASE WHEN @strEvaluationByZone = 'Location' THEN intCompanyLocationId ELSE NULL END)
				, intMarketZoneId = (CASE WHEN @strEvaluationByZone = 'Market Zone' THEN intMarketZoneId ELSE NULL END)
				, intCurrencyId
				, intPricingTypeId
				, intContractTypeId = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN intContractTypeId ELSE NULL END)
				, intUnitMeasureId
				, intConcurrencyId
				, strMarketValuation = ISNULL(strMarketValuation, '')
			FROM vyuRKGetM2MBasis
		END
		
		IF (ISNULL(@strCopyData, '') <> '' AND @intM2MBasisId IS NOT NULL)
		BEGIN
			UPDATE a
			SET  a.dblCashOrFuture = b.dblCashOrFuture
				, a.dblBasisOrDiscount = b.dblBasisOrDiscount
				, a.intUnitMeasureId = b.intUnitMeasureId
				, a.strUnitMeasure = UOM.strUnitMeasure
			FROM @tempBasis a
			JOIN tblRKM2MBasisDetail b ON a.intCommodityId = b.intCommodityId
				AND ISNULL(a.intFutureMarketId, 0) = ISNULL(b.intFutureMarketId, 0)
				AND ISNULL(a.intMarketZoneId, 0) = ISNULL(b.intMarketZoneId, 0)
				AND ISNULL(a.intCurrencyId, 0) = ISNULL(b.intCurrencyId, 0)
				AND ISNULL(a.strPeriodTo, 0) = ISNULL(b.strPeriodTo, 0)
				AND ISNULL(a.intContractTypeId, 0) = ISNULL(b.intContractTypeId, 0)
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = b.intUnitMeasureId
			WHERE b.intM2MBasisId = @intM2MBasisId
		END
	END
	
	SELECT CONVERT(INT, ROW_NUMBER() OVER (ORDER BY strItemNo)) AS intRowNumber
		, *
	FROM @tempBasis
	WHERE intFutureMarketId IS NOT NULL
	ORDER BY strMarketValuation
		, strFutMarketName
		, strCommodityCode
		, strItemNo
		, strLocationName
		, CONVERT(DATETIME, '01 ' + strPeriodTo)

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH