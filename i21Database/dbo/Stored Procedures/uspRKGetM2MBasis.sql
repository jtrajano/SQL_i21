CREATE PROCEDURE uspRKGetM2MBasis
	@intCopyBasisId INT = NULL

AS

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY	
	DECLARE @ysnIncludeInventoryM2M BIT
		, @ysnIncludeBasisDifferentialsInResults BIT
		, @ysnValueBasisAndDPDeliveries BIT
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell BIT
		, @ysnEnterForwardCurveForMarketBasisDifferential BIT
		, @strEvaluationBy NVARCHAR(50)
		, @strEvaluationByZone NVARCHAR(50)
		, @ysnEvaluationByLocation BIT
        , @ysnEvaluationByMarketZone BIT
        , @ysnEvaluationByOriginPort BIT
        , @ysnEvaluationByDestinationPort BIT
        , @ysnEvaluationByCropYear BIT
        , @ysnEvaluationByStorageLocation BIT
        , @ysnEvaluationByStorageUnit BIT
	
	SELECT TOP 1 @ysnIncludeInventoryM2M = ISNULL(ysnIncludeInventoryM2M, 0)
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = ISNULL(ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell, 0)
		, @ysnEnterForwardCurveForMarketBasisDifferential = ISNULL(ysnEnterForwardCurveForMarketBasisDifferential, 0)
		, @strEvaluationBy = strEvaluationBy
		, @strEvaluationByZone = strEvaluationByZone
		-- NEW CONFIGS FOR EVALUATION OF GETTING BASIS ENTRY
		, @ysnEvaluationByLocation = ysnEvaluationByLocation 
        , @ysnEvaluationByMarketZone = ysnEvaluationByMarketZone 
        , @ysnEvaluationByOriginPort = ysnEvaluationByOriginPort 
        , @ysnEvaluationByDestinationPort = ysnEvaluationByDestinationPort 
        , @ysnEvaluationByCropYear = ysnEvaluationByCropYear 
        , @ysnEvaluationByStorageLocation = ysnEvaluationByStorageLocation 
        , @ysnEvaluationByStorageUnit = ysnEvaluationByStorageUnit 
	FROM tblRKCompanyPreference
	
	DECLARE @tempBasis TABLE (strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strOriginDest NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strFutMarketName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strPeriodTo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strMarketZoneCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strContractInventory NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strContractType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblCashOrFuture NUMERIC(16, 10)
		, dblBasisOrDiscount NUMERIC(16, 10)
		, dblRatio NUMERIC(16, 10)
		, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
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
		, strMarketValuation NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, ysnLicensed BIT
		, intBoardMonthId INT
		, strBoardMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strOriginPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intOriginPortId INT
		, strDestinationPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intDestinationPortId INT
		, strCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCropYearId INT
		, strStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intStorageLocationId INT
		, strStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intStorageUnitId INT
	)
	
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
				, strLocationName = (CASE WHEN @ysnEvaluationByLocation = 1 THEN strLocationName ELSE NULL END)
				, strMarketZoneCode = (CASE WHEN @ysnEvaluationByMarketZone = 1 THEN strMarketZoneCode ELSE NULL END)
				, strCurrency
				, strPricingType = ''
				, strContractInventory
				, strContractType = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN strContractType ELSE NULL END)
				, dblCashOrFuture = ISNULL(dblCashOrFuture, 0)
				, dblBasisOrDiscount = ISNULL(dblBasisOrDiscount, 0)
				, dblRatio = 0
				, strUnitMeasure
				, intCommodityId
				, intItemId = NULL
				, intOriginId = NULL
				, intFutureMarketId
				, intFutureMonthId = NULL
				, intCompanyLocationId = (CASE WHEN @ysnEvaluationByLocation = 1 THEN intCompanyLocationId ELSE NULL END)
				, intMarketZoneId = (CASE WHEN @ysnEvaluationByMarketZone = 1 THEN intMarketZoneId ELSE NULL END)
				, intCurrencyId
				, intPricingTypeId  = NULL
				, intContractTypeId = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN intContractTypeId ELSE NULL END)
				, intUnitMeasureId
				, intConcurrencyId
				, strMarketValuation = ISNULL(strMarketValuation, '')
				, ysnLicensed
				, intBoardMonthId
				, strBoardMonth
				, strOriginPort = (CASE WHEN @ysnEvaluationByOriginPort = 1 THEN strOriginPort ELSE NULL END)
				, intOriginPortId = (CASE WHEN @ysnEvaluationByOriginPort = 1 THEN intOriginPortId ELSE NULL END)
				, strDestinationPort = (CASE WHEN @ysnEvaluationByDestinationPort = 1 THEN strDestinationPort ELSE NULL END)
				, intDestinationPortId = (CASE WHEN @ysnEvaluationByDestinationPort = 1 THEN intDestinationPortId ELSE NULL END)
				, strCropYear = (CASE WHEN @ysnEvaluationByCropYear = 1 THEN strCropYear ELSE NULL END)
				, intCropYearId = (CASE WHEN @ysnEvaluationByCropYear = 1 THEN intCropYearId ELSE NULL END)
				, strStorageLocation = (CASE WHEN @ysnEvaluationByStorageLocation = 1 THEN strStorageLocation ELSE NULL END)
				, intStorageLocationId = (CASE WHEN @ysnEvaluationByStorageLocation = 1 THEN intStorageLocationId ELSE NULL END)
				, strStorageUnit = (CASE WHEN @ysnEvaluationByStorageUnit = 1 THEN strStorageUnit ELSE NULL END)
				, intStorageUnitId = (CASE WHEN @ysnEvaluationByStorageUnit = 1 THEN intStorageUnitId ELSE NULL END)
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
				, strLocationName = (CASE WHEN @ysnEvaluationByLocation = 1 THEN strLocationName ELSE NULL END)
				, strMarketZoneCode = (CASE WHEN @ysnEvaluationByMarketZone = 1 THEN strMarketZoneCode ELSE NULL END)
				, strCurrency
				, strPricingType = ''
				, strContractInventory
				, strContractType = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN strContractType ELSE NULL END)
				, dblCashOrFuture = ISNULL(dblCashOrFuture, 0)
				, dblBasisOrDiscount = ISNULL(dblBasisOrDiscount, 0)
				, dblRatio = 0
				, strUnitMeasure
				, intCommodityId
				, intItemId = NULL
				, intOriginId = NULL
				, intFutureMarketId
				, intFutureMonthId = NULL
				, intCompanyLocationId = (CASE WHEN @ysnEvaluationByLocation = 1 THEN intCompanyLocationId ELSE NULL END)
				, intMarketZoneId = (CASE WHEN @ysnEvaluationByMarketZone = 1 THEN intMarketZoneId ELSE NULL END)
				, intCurrencyId
				, intPricingTypeId = NULL
				, intContractTypeId = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN intContractTypeId ELSE NULL END)
				, intUnitMeasureId
				, intConcurrencyId
				, strMarketValuation = ISNULL(strMarketValuation, '') 
				, ysnLicensed
				, intBoardMonthId
				, strBoardMonth
				, strOriginPort = (CASE WHEN @ysnEvaluationByOriginPort = 1 THEN strOriginPort ELSE NULL END)
				, intOriginPortId = (CASE WHEN @ysnEvaluationByOriginPort = 1 THEN intOriginPortId ELSE NULL END)
				, strDestinationPort = (CASE WHEN @ysnEvaluationByDestinationPort = 1 THEN strDestinationPort ELSE NULL END)
				, intDestinationPortId = (CASE WHEN @ysnEvaluationByDestinationPort = 1 THEN intDestinationPortId ELSE NULL END)
				, strCropYear = (CASE WHEN @ysnEvaluationByCropYear = 1 THEN strCropYear ELSE NULL END)
				, intCropYearId = (CASE WHEN @ysnEvaluationByCropYear = 1 THEN intCropYearId ELSE NULL END)
				, strStorageLocation = (CASE WHEN @ysnEvaluationByStorageLocation = 1 THEN strStorageLocation ELSE NULL END)
				, intStorageLocationId = (CASE WHEN @ysnEvaluationByStorageLocation = 1 THEN intStorageLocationId ELSE NULL END)
				, strStorageUnit = (CASE WHEN @ysnEvaluationByStorageUnit = 1 THEN strStorageUnit ELSE NULL END)
				, intStorageUnitId = (CASE WHEN @ysnEvaluationByStorageUnit = 1 THEN intStorageUnitId ELSE NULL END)
			FROM vyuRKGetM2MBasis
		END
		
		IF (ISNULL(@intCopyBasisId, 0) <> 0)
		BEGIN
			UPDATE a
			SET  a.dblCashOrFuture = b.dblCashOrFuture
				, a.dblBasisOrDiscount = b.dblBasisOrDiscount
				, a.intUnitMeasureId = b.intUnitMeasureId
				, a.strUnitMeasure = UOM.strUnitMeasure
				, a.dblRatio = b.dblRatio
			FROM @tempBasis a
			JOIN tblRKM2MBasisDetail b ON a.intCommodityId = b.intCommodityId
				AND ISNULL(a.intFutureMarketId, 0) = ISNULL(b.intFutureMarketId, 0)				
				AND ISNULL(a.intCurrencyId, 0) = ISNULL(b.intCurrencyId, 0)
				AND ISNULL(a.strPeriodTo, 0) = ISNULL(b.strPeriodTo, 0)
				AND ISNULL(a.intContractTypeId, 0) = ISNULL(b.intContractTypeId, 0)
				AND ISNULL(a.intCompanyLocationId, 0) = (CASE WHEN @ysnEvaluationByLocation = 1 THEN ISNULL(b.intCompanyLocationId, 0) ELSE ISNULL(a.intCompanyLocationId, 0) END)
				AND ISNULL(a.intMarketZoneId, 0) = (CASE WHEN @ysnEvaluationByMarketZone = 1 THEN ISNULL(b.intMarketZoneId, 0) ELSE ISNULL(a.intMarketZoneId, 0) END)
				AND ISNULL(a.intOriginPortId, 0) = (CASE WHEN @ysnEvaluationByOriginPort = 1 THEN ISNULL(b.intOriginPortId, 0) ELSE ISNULL(a.intOriginPortId, 0) END)
				AND ISNULL(a.intDestinationPortId, 0) = (CASE WHEN @ysnEvaluationByDestinationPort = 1 THEN ISNULL(b.intDestinationPortId, 0) ELSE ISNULL(a.intDestinationPortId, 0) END)
				AND ISNULL(a.intCropYearId, 0) = (CASE WHEN @ysnEvaluationByCropYear = 1 THEN ISNULL(b.intCropYearId, 0) ELSE ISNULL(a.intCropYearId, 0) END)
				AND ISNULL(a.intStorageLocationId, 0) = (CASE WHEN @ysnEvaluationByStorageLocation = 1 THEN ISNULL(b.intStorageLocationId, 0) ELSE ISNULL(a.intStorageLocationId, 0) END)
				AND ISNULL(a.intStorageUnitId, 0) = (CASE WHEN @ysnEvaluationByStorageUnit = 1 THEN ISNULL(b.intStorageUnitId, 0) ELSE ISNULL(a.intStorageUnitId, 0) END)
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = b.intUnitMeasureId
			WHERE b.intM2MBasisId = @intCopyBasisId
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
				, strLocationName = (CASE WHEN @ysnEvaluationByLocation = 1 THEN strLocationName ELSE NULL END)
				, strMarketZoneCode = (CASE WHEN @ysnEvaluationByMarketZone = 1 THEN strMarketZoneCode ELSE NULL END)
				, strCurrency
				, strPricingType = ''
				, strContractInventory
				, strContractType = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN strContractType ELSE NULL END)
				, dblCashOrFuture = ISNULL(dblCashOrFuture, 0)
				, dblBasisOrDiscount = ISNULL(dblBasisOrDiscount, 0)
				, dblRatio = 0
				, strUnitMeasure
				, intCommodityId
				, intItemId
				, intOriginId
				, intFutureMarketId
				, intFutureMonthId = NULL
				, intCompanyLocationId = (CASE WHEN @ysnEvaluationByLocation = 1 THEN intCompanyLocationId ELSE NULL END)
				, intMarketZoneId = (CASE WHEN @ysnEvaluationByMarketZone = 1 THEN intMarketZoneId ELSE NULL END)
				, intCurrencyId
				, intPricingTypeId = NULL
				, intContractTypeId = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN intContractTypeId ELSE NULL END)
				, intUnitMeasureId
				, intConcurrencyId
				, strMarketValuation = ISNULL(strMarketValuation, '')
				, ysnLicensed
				, intBoardMonthId
				, strBoardMonth
				, strOriginPort = (CASE WHEN @ysnEvaluationByOriginPort = 1 THEN strOriginPort ELSE NULL END)
				, intOriginPortId = (CASE WHEN @ysnEvaluationByOriginPort = 1 THEN intOriginPortId ELSE NULL END)
				, strDestinationPort = (CASE WHEN @ysnEvaluationByDestinationPort = 1 THEN strDestinationPort ELSE NULL END)
				, intDestinationPortId = (CASE WHEN @ysnEvaluationByDestinationPort = 1 THEN intDestinationPortId ELSE NULL END)
				, strCropYear = (CASE WHEN @ysnEvaluationByCropYear = 1 THEN strCropYear ELSE NULL END)
				, intCropYearId = (CASE WHEN @ysnEvaluationByCropYear = 1 THEN intCropYearId ELSE NULL END)
				, strStorageLocation = (CASE WHEN @ysnEvaluationByStorageLocation = 1 THEN strStorageLocation ELSE NULL END)
				, intStorageLocationId = (CASE WHEN @ysnEvaluationByStorageLocation = 1 THEN intStorageLocationId ELSE NULL END)
				, strStorageUnit = (CASE WHEN @ysnEvaluationByStorageUnit = 1 THEN strStorageUnit ELSE NULL END)
				, intStorageUnitId = (CASE WHEN @ysnEvaluationByStorageUnit = 1 THEN intStorageUnitId ELSE NULL END)
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
				, strLocationName = (CASE WHEN @ysnEvaluationByLocation = 1 THEN strLocationName ELSE NULL END)
				, strMarketZoneCode = (CASE WHEN @ysnEvaluationByMarketZone = 1 THEN strMarketZoneCode ELSE NULL END)
				, strCurrency
				, strPricingType = ''
				, strContractInventory
				, strContractType = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN strContractType ELSE NULL END)
				, dblCashOrFuture = ISNULL(dblCashOrFuture, 0)
				, dblBasisOrDiscount = ISNULL(dblBasisOrDiscount, 0)
				, dblRatio = 0
				, strUnitMeasure
				, intCommodityId
				, intItemId
				, intOriginId
				, intFutureMarketId
				, intFutureMonthId = NULL
				, intCompanyLocationId = (CASE WHEN @ysnEvaluationByLocation = 1 THEN intCompanyLocationId ELSE NULL END)
				, intMarketZoneId = (CASE WHEN @ysnEvaluationByMarketZone = 1 THEN intMarketZoneId ELSE NULL END)
				, intCurrencyId
				, intPricingTypeId = NULL
				, intContractTypeId = (CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1 THEN intContractTypeId ELSE NULL END)
				, intUnitMeasureId
				, intConcurrencyId
				, strMarketValuation = ISNULL(strMarketValuation, '')
				, ysnLicensed
				, intBoardMonthId
				, strBoardMonth
				, strOriginPort = (CASE WHEN @ysnEvaluationByOriginPort = 1 THEN strOriginPort ELSE NULL END)
				, intOriginPortId = (CASE WHEN @ysnEvaluationByOriginPort = 1 THEN intOriginPortId ELSE NULL END)
				, strDestinationPort = (CASE WHEN @ysnEvaluationByDestinationPort = 1 THEN strDestinationPort ELSE NULL END)
				, intDestinationPortId = (CASE WHEN @ysnEvaluationByDestinationPort = 1 THEN intDestinationPortId ELSE NULL END)
				, strCropYear = (CASE WHEN @ysnEvaluationByCropYear = 1 THEN strCropYear ELSE NULL END)
				, intCropYearId = (CASE WHEN @ysnEvaluationByCropYear = 1 THEN intCropYearId ELSE NULL END)
				, strStorageLocation = (CASE WHEN @ysnEvaluationByStorageLocation = 1 THEN strStorageLocation ELSE NULL END)
				, intStorageLocationId = (CASE WHEN @ysnEvaluationByStorageLocation = 1 THEN intStorageLocationId ELSE NULL END)
				, strStorageUnit = (CASE WHEN @ysnEvaluationByStorageUnit = 1 THEN strStorageUnit ELSE NULL END)
				, intStorageUnitId = (CASE WHEN @ysnEvaluationByStorageUnit = 1 THEN intStorageUnitId ELSE NULL END)
			FROM vyuRKGetM2MBasis
		END
		
		IF (ISNULL(@intCopyBasisId, 0) <> 0)
		BEGIN
			UPDATE a
			SET  a.dblCashOrFuture = b.dblCashOrFuture
				, a.dblBasisOrDiscount = b.dblBasisOrDiscount
				, a.intUnitMeasureId = b.intUnitMeasureId
				, a.strUnitMeasure = UOM.strUnitMeasure
				, a.dblRatio = b.dblRatio
			FROM @tempBasis a
			JOIN tblRKM2MBasisDetail b ON a.intCommodityId = b.intCommodityId
				AND ISNULL(a.intItemId, 0) = ISNULL(b.intItemId, 0)
				AND ISNULL(a.intFutureMarketId, 0) = ISNULL(b.intFutureMarketId, 0)
				AND ISNULL(a.intCurrencyId, 0) = ISNULL(b.intCurrencyId, 0)
				AND ISNULL(a.strPeriodTo, 0) = ISNULL(b.strPeriodTo, 0)
				AND ISNULL(a.intContractTypeId, 0) = ISNULL(b.intContractTypeId, 0)
				AND ISNULL(a.intCompanyLocationId, 0) = (CASE WHEN @ysnEvaluationByLocation = 1 THEN ISNULL(b.intCompanyLocationId, 0) ELSE ISNULL(a.intCompanyLocationId, 0) END)
				AND ISNULL(a.intMarketZoneId, 0) = (CASE WHEN @ysnEvaluationByMarketZone = 1 THEN ISNULL(b.intMarketZoneId, 0) ELSE ISNULL(a.intMarketZoneId, 0) END)
				AND ISNULL(a.intOriginPortId, 0) = (CASE WHEN @ysnEvaluationByOriginPort = 1 THEN ISNULL(b.intOriginPortId, 0) ELSE ISNULL(a.intOriginPortId, 0) END)
				AND ISNULL(a.intDestinationPortId, 0) = (CASE WHEN @ysnEvaluationByDestinationPort = 1 THEN ISNULL(b.intDestinationPortId, 0) ELSE ISNULL(a.intDestinationPortId, 0) END)
				AND ISNULL(a.intCropYearId, 0) = (CASE WHEN @ysnEvaluationByCropYear = 1 THEN ISNULL(b.intCropYearId, 0) ELSE ISNULL(a.intCropYearId, 0) END)
				AND ISNULL(a.intStorageLocationId, 0) = (CASE WHEN @ysnEvaluationByStorageLocation = 1 THEN ISNULL(b.intStorageLocationId, 0) ELSE ISNULL(a.intStorageLocationId, 0) END)
				AND ISNULL(a.intStorageUnitId, 0) = (CASE WHEN @ysnEvaluationByStorageUnit = 1 THEN ISNULL(b.intStorageUnitId, 0) ELSE ISNULL(a.intStorageUnitId, 0) END)
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = b.intUnitMeasureId
			WHERE b.intM2MBasisId = @intCopyBasisId
		END
	END
	
	SELECT CONVERT(INT, ROW_NUMBER() OVER (ORDER BY strItemNo)) AS intRowNumber
		, *
		, ysnEvaluationByLocation = @ysnEvaluationByLocation 
		, ysnEvaluationByMarketZone = @ysnEvaluationByMarketZone 
		, ysnEvaluationByOriginPort = @ysnEvaluationByOriginPort 
		, ysnEvaluationByDestinationPort = @ysnEvaluationByDestinationPort 
		, ysnEvaluationByCropYear = @ysnEvaluationByCropYear 
		, ysnEvaluationByStorageLocation = @ysnEvaluationByStorageLocation 
		, ysnEvaluationByStorageUnit = @ysnEvaluationByStorageUnit 
	FROM @tempBasis
	WHERE intCommodityId IS NOT NULL
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