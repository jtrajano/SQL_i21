CREATE PROC [dbo].[uspRKM2MVendorExposureDetail]
	@intM2MBasisId INT = NULL
	, @intFutureSettlementPriceId INT = NULL
	, @intQuantityUOMId INT = NULL
	, @intPriceUOMId INT = NULL
	, @intCurrencyUOMId INT = NULL
	, @dtmTransactionDateUpTo DATETIME = NULL
	, @strRateType NVARCHAR(200) = NULL
	, @intCommodityId INT = NULL
	, @intLocationId INT = NULL
	, @intMarketZoneId INT = NULL
	, @ysnVendorProducer BIT = NULL
	, @strDrillDownColumn NVARCHAR(100) = NULL
	, @strVendorName NVARCHAR(250) = NULL

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

	DECLARE @tblFinalDetail TABLE (
		intRowNum INT
       ,intConcurrencyId INT
       ,intContractHeaderId INT
       ,intContractDetailId INT
       ,strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intEntityId INT
       ,intFutureMarketId INT
       ,strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intFutureMonthId INT
       ,strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,dblOpenQty NUMERIC(24, 10)
       ,strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intCommodityId INT
       ,intItemId INT
       ,strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
	   ,strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
       ,strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,intPricingTypeId INT
       ,strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
	   ,dblContractRatio NUMERIC(24, 10)
       ,dblContractBasis NUMERIC(24, 10)
       ,dblFutures NUMERIC(24, 10)
       ,dblCash NUMERIC(24, 10)
       ,dblCosts NUMERIC(24, 10)
       ,dblMarketBasis NUMERIC(24, 10)
	   ,dblMarketRatio NUMERIC(24, 10)
       ,dblFuturePrice NUMERIC(24, 10)
       ,intContractTypeId INT
       ,dblAdjustedContractPrice NUMERIC(24, 10)
       ,dblCashPrice NUMERIC(24, 10)
       ,dblMarketPrice NUMERIC(24, 10)
       ,dblResultBasis NUMERIC(24, 10)
       ,dblResultCash NUMERIC(24, 10)
       ,dblContractPrice NUMERIC(24, 10)
       ,intQuantityUOMId INT
       ,intCommodityUnitMeasureId INT
       ,intPriceUOMId INT
       ,intCent int
	   ,dtmPlannedAvailabilityDate datetime
	   ,dblPricedQty numeric(24,10),dblUnPricedQty numeric(24,10),dblPricedAmount numeric(24,10)
	   	,intMarketZoneId int  ,intCompanyLocationId int
	,strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblResult NUMERIC(24, 10)
	,dblMarketFuturesResult NUMERIC(24, 10)
	,dblResultRatio NUMERIC(24, 10))

	INSERT INTO @tblFinalDetail
	EXEC [uspRKM2MInquiryTransaction] @intM2MBasisId  = @intM2MBasisId
		, @intFutureSettlementPriceId  = @intFutureSettlementPriceId
		, @intQuantityUOMId  = @intQuantityUOMId
		, @intPriceUOMId  = @intPriceUOMId
		, @intCurrencyUOMId = @intCurrencyUOMId
		, @dtmTransactionDateUpTo = @dtmTransactionDateUpTo
		, @strRateType = @strRateType
		, @intCommodityId =@intCommodityId
		, @intLocationId = @intLocationId
		, @intMarketZoneId = @intMarketZoneId

	SELECT DISTINCT cd.*
		, strProducer = (CASE WHEN ISNULL(ysnClaimsToProducer, 0) = 1 THEN e.strName ELSE NULL END)
		, intProducerId = (CASE WHEN ISNULL(ysnClaimsToProducer, 0) = 1 THEN ch.intProducerId ELSE NULL END)
	INTO #temp
	FROM @tblFinalDetail cd
	JOIN tblCTContractDetail ch ON ch.intContractHeaderId=cd.intContractHeaderId
	LEFT JOIN tblEMEntity e ON e.intEntityId=ch.intProducerId

	DECLARE @tblDerivative TABLE(intRowNum INT
		, intContractHeaderId int
		, strContractSeq nvarchar(100)
		, strEntityName nvarchar(100)
		, dblFixedPurchaseVolume NUMERIC(24, 10)
		, dblUnfixedPurchaseVolume NUMERIC(24, 10)
		, dblTotalValume NUMERIC(24, 10)
		, dblPurchaseOpenQty NUMERIC(24, 10)
		, dblPurchaseContractBasisPrice NUMERIC(24, 10)
		, dblPurchaseFuturesPrice NUMERIC(24, 10)
		, dblPurchaseCashPrice NUMERIC(24, 10)
		, dblFixedPurchaseValue NUMERIC(24, 10)
		, dblUnPurchaseOpenQty NUMERIC(24, 10)
		, dblUnPurchaseContractBasisPrice NUMERIC(24, 10)
		, dblUnPurchaseFuturesPrice NUMERIC(24, 10)
		, dblUnPurchaseCashPrice NUMERIC(24, 10)
		, dblUnfixedPurchaseValue NUMERIC(24, 10)
		, dblTotalCommitedValue NUMERIC(24, 10))

	IF (ISNULL(@ysnVendorProducer, 0) = 0)
	BEGIN	
		INSERT INTO @tblDerivative (intRowNum
			, intContractHeaderId
			, strContractSeq
			, strEntityName
			, dblFixedPurchaseVolume
			, dblUnfixedPurchaseVolume
			, dblTotalValume
			, dblPurchaseOpenQty
			, dblPurchaseContractBasisPrice
			, dblPurchaseFuturesPrice
			, dblPurchaseCashPrice
			, dblFixedPurchaseValue
			, dblUnPurchaseOpenQty
			, dblUnPurchaseContractBasisPrice
			, dblUnPurchaseFuturesPrice
			, dblUnPurchaseCashPrice
			, dblUnfixedPurchaseValue
			, dblTotalCommitedValue)
		SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strEntityName)) intRowNum
			, intContractHeaderId
			, strContractSeq
			, strEntityName
			, dblFixedPurchaseVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END)
			, dblUnfixedPurchaseVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
			, dblTotalValume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
			, dblPurchaseOpenQty = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPValueQty ELSE 0 END)
			, dblPurchaseContractBasisPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPContractBasis ELSE 0 END)
			, dblPurchaseFuturesPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPFutures ELSE 0 END)
			, dblPurchaseCashPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPContractBasis ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPFutures ELSE 0 END)
			, dblFixedPurchaseValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END)
			, dblUnPurchaseOpenQty = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPValueQty ELSE 0 END)
			, dblUnPurchaseContractBasisPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPContractBasis ELSE 0 END)
			, dblUnPurchaseFuturesPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPFutures ELSE 0 END)
			, dblUnPurchaseCashPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPContractBasis ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPFutures ELSE 0 END)
			, dblUnfixedPurchaseValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
			, dblTotalCommitedValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
		FROM(                                  
			SELECT ch.intContractHeaderId
				, fd.strContractSeq
				, fd.strEntityName
				, fd.dblOpenQty
				, strPriOrNotPriOrParPriced = (CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced'
													WHEN ISNULL(strPriOrNotPriOrParPriced,'') = '' THEN 'Priced'
													WHEN strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced'
													ELSE strPriOrNotPriOrParPriced END)
				, dblPValueQty = 0.0
				, dblPContractBasis = ISNULL(fd.dblContractBasis, 0)
				, dblPFutures = ISNULL(fd.dblFutures, 0)
				, dblQtyPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
															, fd.intCommodityUnitMeasureId
															, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																										, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																										, fd.dblOpenQty * (ISNULL(fd.dblContractBasis, 0) + ISNULL(fd.dblFutures, 0))))
				, dblUPValueQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
															, fd.intCommodityUnitMeasureId
															, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																										, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																										, fd.dblOpenQty))
				, dblUPContractBasis = ISNULL(fd.dblContractBasis, 0)
				, dblUPFutures = ISNULL(fd.dblFuturePrice, 0)
				, dblQtyUnFixedPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
															, fd.intCommodityUnitMeasureId
															, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																										, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																										, fd.dblOpenQty * ((ISNULL(fd.dblContractBasis,0))+(isnull(fd.dblFuturePrice,0)))))
			FROM #temp  fd
			JOIN tblCTContractDetail det ON fd.intContractDetailId=det.intContractDetailId
			join tblCTContractHeader ch ON ch.intContractHeaderId=det.intContractHeaderId
			JOIN tblICItemUOM ic ON det.intPriceItemUOMId=ic.intItemUOMId                                   
			JOIN tblSMCurrency c ON det.intCurrencyId=c.intCurrencyID
			JOIN tblAPVendor e ON e.intEntityId=fd.intEntityId
			LEFT JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId=@intCommodityId and cum.intUnitMeasureId=  e.intRiskUnitOfMeasureId
			LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId=e.intRiskVendorPriceFixationLimitId
			WHERE strContractOrInventoryType in ('Contract(P)', 'In-transit(P)', 'Inventory (P)')) t
		WHERE strEntityName = @strVendorName 
	END
	ELSE
	BEGIN
		INSERT INTO @tblDerivative (intRowNum
			, intContractHeaderId
			, strContractSeq
			, strEntityName
			, dblFixedPurchaseVolume
			, dblUnfixedPurchaseVolume
			, dblTotalValume
			, dblPurchaseOpenQty
			, dblPurchaseContractBasisPrice
			, dblPurchaseFuturesPrice
			, dblPurchaseCashPrice
			, dblFixedPurchaseValue
			, dblUnPurchaseOpenQty
			, dblUnPurchaseContractBasisPrice
			, dblUnPurchaseFuturesPrice
			, dblUnPurchaseCashPrice
			, dblUnfixedPurchaseValue
			, dblTotalCommitedValue)
		SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strEntityName))
			, intContractHeaderId
			, strContractSeq
			, strEntityName
			, dblFixedPurchaseVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END)
			, dblUnfixedPurchaseVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
			, dblTotalValume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
			, dblPurchaseOpenQty = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPValueQty ELSE 0 END)
			, dblPurchaseContractBasisPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPContractBasis ELSE 0 END)
			, dblPurchaseFuturesPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPFutures ELSE 0 END)
			, dblPurchaseCashPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPContractBasis ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPFutures ELSE 0 END)
			, dblFixedPurchaseValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END)
			, dblUnPurchaseOpenQty = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPValueQty ELSE 0 END)
			, dblUnPurchaseContractBasisPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPContractBasis ELSE 0 END)
			, dblUnPurchaseFuturesPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPFutures ELSE 0 END)
			, dblUnPurchaseCashPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPContractBasis ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPFutures ELSE 0 END)
			, dblUnfixedPurchaseValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
			, dblTotalCommitedValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
		FROM(
			SELECT ch.intContractHeaderId
				, fd.strContractSeq
				, strEntityName = ISNULL(strProducer, strEntityName)
				, fd.dblOpenQty
				, strPriOrNotPriOrParPriced = (CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced'
						WHEN ISNULL(strPriOrNotPriOrParPriced,'') = '' THEN 'Priced'
						WHEN strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced'
						ELSE strPriOrNotPriOrParPriced END)
				, dblPValueQty = 0.0
				, dblPContractBasis = ISNULL(fd.dblContractBasis, 0)
				, dblPFutures = ISNULL(fd.dblFutures, 0)
				, dblQtyPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
														, fd.intCommodityUnitMeasureId
														, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																									, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																									, fd.dblOpenQty * (ISNULL(fd.dblContractBasis, 0) + ISNULL(fd.dblFutures, 0))))
				, dblUPValueQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
														, fd.intCommodityUnitMeasureId
														, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																									, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																									, fd.dblOpenQty))
				, dblUPContractBasis = ISNULL(fd.dblContractBasis, 0)
				, dblUPFutures = ISNULL(fd.dblFuturePrice, 0)
				, dblQtyUnFixedPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
														, fd.intCommodityUnitMeasureId
														, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																									, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																									, fd.dblOpenQty * (ISNULL(fd.dblContractBasis, 0) + ISNULL(fd.dblFuturePrice, 0))))
			FROM #temp  fd
			JOIN tblCTContractDetail det ON fd.intContractDetailId = det.intContractDetailId
			join tblCTContractHeader ch ON ch.intContractHeaderId = det.intContractHeaderId
			JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId
			JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
			LEFT JOIN tblAPVendor e ON e.intEntityId = fd.intProducerId
			LEFT JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = @intCommodityId AND cum.intUnitMeasureId = e.intRiskUnitOfMeasureId
			LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
			LEFT JOIN tblAPVendor e1 ON e1.intEntityId = fd.intEntityId
			LEFT JOIN tblICCommodityUnitMeasure cum1 ON cum1.intCommodityId = @intCommodityId AND cum1.intUnitMeasureId = e1.intRiskUnitOfMeasureId
			LEFT JOIN tblRKVendorPriceFixationLimit pf1 ON pf1.intVendorPriceFixationLimitId = e1.intRiskVendorPriceFixationLimitId
			WHERE strContractOrInventoryType IN ('Contract(P)', 'In-transit(P)', 'Inventory (P)')) t
		WHERE strEntityName = @strVendorName 
	END

	IF (@strDrillDownColumn	= 'colFixedPurchaseVolume')
	BEGIN
		SELECT * FROM @tblDerivative WHERE dblFixedPurchaseVolume > 0
	END
	ELSE IF (@strDrillDownColumn = 'colUnfixedPurchaseVolume')
	BEGIN
		SELECT * FROM @tblDerivative WHERE dblUnfixedPurchaseVolume > 0
	END
	ELSE IF (@strDrillDownColumn = 'colFixedPurchaseValue')
	BEGIN
		SELECT * FROM @tblDerivative WHERE dblFixedPurchaseValue > 0
	END
	ELSE IF (@strDrillDownColumn = 'colUnfixedPurchaseValue')
	BEGIN
		SELECT * FROM @tblDerivative WHERE dblUnfixedPurchaseValue > 0
	END	 
	ELSE 
	BEGIN
		SELECT * FROM @tblDerivative
	END
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