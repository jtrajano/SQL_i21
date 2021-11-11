CREATE PROCEDURE [dbo].[uspRKGetM2MCounterPartyExposureReport]
	  @strRecordName NVARCHAR(50) = NULL
	, @strCommodity NVARCHAR(100)
	, @strBasisEntryAsOf NVARCHAR(50)
	, @strSettlemntPriceDate NVARCHAR(50)
	, @strQuantityUOM NVARCHAR(100)
	, @strPriceUOM NVARCHAR(100)
	, @strCurrency NVARCHAR(50)
	, @strEndDate NVARCHAR(50)
	, @strRateType NVARCHAR(200)	
	, @strLocation NVARCHAR(100)	
	, @strMarketZone NVARCHAR(40)	
	, @ysnByProducer BIT = NULL
	, @strDateFormat NVARCHAR(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	IF OBJECT_ID('tempdb..#tblContractCost') IS NOT NULL
		DROP TABLE #tblContractCost
	IF OBJECT_ID('tempdb..#tblSettlementPrice') IS NOT NULL
		DROP TABLE #tblSettlementPrice
	IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
		DROP TABLE #Temp
	IF OBJECT_ID('tempdb..#tmpM2MBasisDetail') IS NOT NULL
		DROP TABLE #tmpM2MBasisDetail
	IF OBJECT_ID('tempdb..#RollNearbyMonth') IS NOT NULL
		DROP TABLE #RollNearbyMonth
	IF OBJECT_ID('tempdb..#tmpCPE') IS NOT NULL
		DROP TABLE #tmpCPE
	IF OBJECT_ID('tempdb..#tmpM2MTransaction') IS NOT NULL
		DROP TABLE #tmpM2MTransaction
	IF OBJECT_ID('tempdb..#tblContractFuture') IS NOT NULL
		DROP TABLE #tblContractFuture
	IF OBJECT_ID('tempdb..#tmpPricingStatus') IS NOT NULL
		DROP TABLE #tmpPricingStatus
	IF OBJECT_ID('tempdb..#CBBucket') IS NOT NULL
		DROP TABLE #CBBucket
	IF OBJECT_ID('tempdb..#ContractStatus') IS NOT NULL
		DROP TABLE #ContractStatus
	IF OBJECT_ID('tempdb..#tempLatestContractDetails') IS NOT NULL
		DROP TABLE #tempLatestContractDetails
	
	-- START Setting up id values for Parameters
	DECLARE @intCommodityId INT
		, @intM2MTypeId INT
		, @intM2MBasisId INT
		, @intFutureSettlementPriceId INT
		, @intQuantityUOMId INT
		, @intPriceUOMId INT
		, @intCurrencyId INT
		, @intLocationId INT
		, @intMarketZoneId INT 
		, @intM2MHeaderId INT 
		, @dtmBasisEntryAsOf DATETIME
		, @dtmSettlemntPriceDate DATETIME
		, @dtmEndDate DATETIME

	IF @strDateFormat = 'dd/MM/yyyy'
	BEGIN
		--REFORMAT DATE
		DECLARE @dummyDate NVARCHAR(50)

		SELECT  @dummyDate = SUBSTRING(@strBasisEntryAsOf, 4, 2) + '/' -- Month
						+ LEFT(@strBasisEntryAsOf, 2) + '/' -- Day
						+ SUBSTRING(@strBasisEntryAsOf, 7, 13)
						
		SELECT @dtmBasisEntryAsOf = CAST(@dummyDate AS DATETIME)
		
		IF ISNULL(@strSettlemntPriceDate, '') <> ''
		BEGIN
			SELECT  @dummyDate = SUBSTRING(@strSettlemntPriceDate, 4, 2) + '/' -- Month
							+ LEFT(@strSettlemntPriceDate, 2) + '/' -- Day
							+ SUBSTRING(@strSettlemntPriceDate, 7, 13)
			SELECT @dtmSettlemntPriceDate = CAST(@dummyDate AS DATETIME)
		END
		
		SELECT  @dummyDate = SUBSTRING(@strEndDate, 4, 2) + '/' -- Month
						+ LEFT(@strEndDate, 2) + '/' -- Day
						+ SUBSTRING(@strEndDate, 7, 4)
		SELECT @dtmEndDate = CAST(@dummyDate AS DATETIME)
	END
	ELSE
	BEGIN
		SELECT @dtmBasisEntryAsOf = @strBasisEntryAsOf
		SELECT @dtmSettlemntPriceDate = @strSettlemntPriceDate
		SELECT @dtmEndDate = @strEndDate
	END
	
	SELECT	@intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = @strCommodity
	SELECT	@intM2MTypeId = intM2MTypeId FROM tblRKM2MType WHERE strType = 'Mark to Market' 

	SELECT	@intM2MBasisId = intM2MBasisId FROM tblRKM2MBasis 
	WHERE	strPricingType = 'Mark to Market' 
			AND CONVERT(varchar, dtmM2MBasisDate, 0) =  CONVERT(varchar, @dtmBasisEntryAsOf, 0)
			
	IF ISNULL(@strSettlemntPriceDate, '') <> ''
	BEGIN
		SELECT	@intFutureSettlementPriceId = intFutureSettlementPriceId FROM tblRKFuturesSettlementPrice 
		WHERE	CONVERT(varchar, dtmPriceDate, 0) = CONVERT(varchar, @dtmSettlemntPriceDate, 0)
	END

	SELECT @intQuantityUOMId = intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = @strQuantityUOM
	SELECT @intPriceUOMId = intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = @strPriceUOM
	SELECT @intCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency = @strCurrency
	SELECT @intLocationId = intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationName = @strLocation 
	SELECT @intMarketZoneId = intMarketZoneId FROM tblARMarketZone WHERE strMarketZoneCode = @strMarketZone
	
	-- END Setting up id values for Parameters

	IF (ISNULL(@intM2MHeaderId, 0) = 0) SET @intM2MHeaderId = NULL
	IF (ISNULL(@intCommodityId, 0) = 0) SET @intCommodityId = NULL
	IF (ISNULL(@intM2MTypeId, 0) = 0) SET @intM2MTypeId = NULL
	IF (ISNULL(@intM2MBasisId, 0) = 0) SET @intM2MBasisId = NULL
	IF (ISNULL(@intFutureSettlementPriceId, 0) = 0) SET @intFutureSettlementPriceId = NULL
	IF (ISNULL(@intQuantityUOMId, 0) = 0) SET @intQuantityUOMId = NULL
	IF (ISNULL(@intPriceUOMId, 0) = 0) SET @intPriceUOMId = NULL
	IF (ISNULL(@intCurrencyId, 0) = 0) SET @intCurrencyId = NULL
	IF (ISNULL(@intLocationId, 0) = 0) SET @intLocationId = NULL
	IF (ISNULL(@intMarketZoneId, 0) = 0) SET @intMarketZoneId = NULL
	--IF (ISNULL(@dtmPostDate, '') = '') SET @dtmPostDate = GETDATE()

	DECLARE @ErrMsg NVARCHAR(MAX)

	DECLARE @strM2MView NVARCHAR(50)
		, @intMarkExpiredMonthPositionId INT
		, @ysnIncludeBasisDifferentialsInResults BIT
		--, @dtmSettlemntPriceDate DATETIME
		, @ysnIncludeInventoryM2M BIT
		, @ysnEnterForwardCurveForMarketBasisDifferential BIT
		, @ysnCanadianCustomer BIT
		, @intDefaultCurrencyId int
		, @ysnIncludeDerivatives BIT
		, @ysnIncludeCrushDerivatives BIT
		, @strEvaluationBy NVARCHAR(50)
		, @strEvaluationByZone NVARCHAR(50)
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell BIT
		, @dtmCurrentDate DATETIME = GETDATE()
		, @dtmCurrentDay DATETIME = DATEADD(DD, DATEDIFF(DD, 0, GETDATE()), 0)

	--GET Company Preference Values
	SELECT TOP 1 @strM2MView = strM2MView
		, @intMarkExpiredMonthPositionId = intMarkExpiredMonthPositionId
		, @ysnIncludeBasisDifferentialsInResults = ysnIncludeBasisDifferentialsInResults
		, @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential
		, @ysnIncludeInventoryM2M = ysnIncludeInventoryM2M
		, @ysnCanadianCustomer = ISNULL(ysnCanadianCustomer, 0)
		, @intMarkExpiredMonthPositionId = intMarkExpiredMonthPositionId
		, @ysnIncludeDerivatives = ysnIncludeDerivatives
		, @ysnIncludeCrushDerivatives = ysnIncludeCrushDerivatives
		, @strEvaluationBy = strEvaluationBy
		, @strEvaluationByZone = strEvaluationByZone
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell
	FROM tblRKCompanyPreference

	SELECT TOP 1 @dtmSettlemntPriceDate = dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId = @intFutureSettlementPriceId

	SET @dtmEndDate = LEFT(CONVERT(VARCHAR, @dtmEndDate, 101), 10)
	
	SELECT TOP 1 @intM2MHeaderId = intM2MHeaderId FROM tblRKM2MHeader WHERE strRecordName = @strRecordName
	
		-- LOAD TRANSACTION
		DECLARE @ListTransaction TABLE (intContractHeaderId int
			, intContractDetailId int
			, strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intEntityId INT
			, strFutureMarket NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intFutureMarketId INT
			, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intFutureMonthId INT
			, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intCommodityId INT
			, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intItemId INT
			, intItemLocationId INT
			, strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intOriginId INT
			, strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intPricingTypeId INT
			, strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, dblFutures NUMERIC(24, 10)
			, dblCash NUMERIC(24, 10)
			, dblCosts NUMERIC(24, 10)
			, dblMarketBasis1 NUMERIC(24, 10)
			, intMarketBasisUOMId INT
			, intMarketBasisCurrencyId INT
			, dblContractRatio NUMERIC(24, 10)
			, dblContractBasis NUMERIC(24, 10)
			, dblDummyContractBasis NUMERIC(24, 10)
			, dblFuturePrice1 NUMERIC(24, 10)
			, intFuturePriceCurrencyId INT
			, dblFuturesClosingPrice1 NUMERIC(24, 10)
			, intContractTypeId INT
			, dblOpenQty NUMERIC(24, 10)
			, dblRate NUMERIC(24, 10)
			, intCommodityUnitMeasureId INT
			, intQuantityUOMId INT
			, intPriceUOMId INT
			, intCurrencyId INT
			, PriceSourceUOMId INT
			, dblltemPrice NUMERIC(24, 10)
			, dblMarketBasis NUMERIC(24, 10)
			, dblMarketRatio NUMERIC(24, 10)
			, dblCashPrice NUMERIC(24, 10)
			, dblAdjustedContractPrice NUMERIC(24, 10)
			, dblFuturesClosingPrice NUMERIC(24, 10)
			, dblFuturePrice NUMERIC(24, 10)
			, dblMarketPrice NUMERIC(24, 10)
			, dblResult NUMERIC(24, 10)
			, dblResultBasis1 NUMERIC(24, 10)
			, dblMarketFuturesResult NUMERIC(24, 10)
			, dblResultCash1 NUMERIC(24, 10)
			, dblContractPrice NUMERIC(24, 10)
			, dblResultCash NUMERIC(24, 10)
			, dblResultBasis NUMERIC(24, 10)
			, dblShipQty NUMERIC(24, 10)
			, ysnSubCurrency BIT
			, intMainCurrencyId INT
			, intCent INT
			, dtmPlannedAvailabilityDate DATETIME
			, dblPricedQty NUMERIC(24, 10)
			, dblUnPricedQty NUMERIC(24, 10)
			, dblPricedAmount NUMERIC(24, 10)
			, intMarketZoneId INT
			, intLocationId INT
			, strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, dblNotLotTrackedPrice NUMERIC(24, 10)
			, dblInvFuturePrice NUMERIC(24, 10)
			, dblInvMarketBasis NUMERIC(24, 10)
			, dblNoOfLots NUMERIC(24, 10)
			, dblLotsFixed NUMERIC(24, 10)
			, dblPriceWORollArb NUMERIC(24, 10)
			, intSpreadMonthId INT
			, strSpreadMonth NVARCHAR(50)
			, dblSpreadMonthPrice NUMERIC(24, 20)
			, dblSpread NUMERIC(24, 10)
			, ysnExpired BIT)

		DECLARE @GetContractDetailView TABLE (intCommodityUnitMeasureId INT
			, strLocationName NVARCHAR(100)
			, strCommodityDescription NVARCHAR(100)
			, intMainCurrencyId INT
			, intCent INT
			, dblDetailQuantity NUMERIC(24, 10)
			, intContractTypeId INT
			, intContractHeaderId INT
			, strContractType NVARCHAR(100)
			, strContractNumber NVARCHAR(100)
			, strEntityName NVARCHAR(100)
			, intEntityId INT
			, strCommodityCode NVARCHAR(100)
			, intCommodityId INT
			, strPosition NVARCHAR(100)
			, dtmContractDate DATETIME
			, intContractBasisId INT
			, intContractSeq INT
			, dtmStartDate DATETIME
			, dtmEndDate DATETIME
			, intPricingTypeId INT
			, dblRatio NUMERIC(24, 10)
			, dblBasis NUMERIC(24, 10)
			, dblFutures NUMERIC(24, 10)
			, intContractStatusId INT
			, dblCashPrice NUMERIC(24, 10)
			, intContractDetailId INT
			, intFutureMarketId INT
			, intFutureMonthId INT
			, intItemId INT
			, dblBalance NUMERIC(24, 10)
			, intCurrencyId INT
			, dblRate NUMERIC(24, 10)
			, intMarketZoneId INT
			, dtmPlannedAvailabilityDate DATETIME
			, strItemNo NVARCHAR(100)
			, strPricingType NVARCHAR(100)
			, intPriceUnitMeasureId INT
			, intUnitMeasureId INT
			, strFutureMonth NVARCHAR(100)
			, strFutureMarket NVARCHAR(100)
			, intOriginId INT
			, strLotTracking NVARCHAR(100)
			, dblNoOfLots NUMERIC(24, 10)
			, dblLotsFixed NUMERIC(24, 10)
			, dblPriceWORollArb NUMERIC(24, 10)
			, dblHeaderNoOfLots NUMERIC(24, 10)
			, ysnSubCurrency BIT
			, intCompanyLocationId INT
			, ysnExpired BIT
			, strPricingStatus NVARCHAR(100)
			, strOrgin NVARCHAR(100)
			, ysnMultiplePriceFixation BIT
			, intMarketUOMId INT
			, intMarketCurrencyId INT
			, dblInvoicedQuantity NUMERIC(24, 10)
			, dblPricedQty NUMERIC(24, 10)
			, dblUnPricedQty NUMERIC(24, 10)
			, dblPricedAmount NUMERIC(24, 10)
			, strMarketZoneCode NVARCHAR(200))

		--There is an error "An INSERT EXEC statement cannot be nested." that is why we cannot directly call the uspRKDPRContractDetail AND insert
		DECLARE @ContractBalance TABLE (intRowNum INT
			, strCommodityCode NVARCHAR(100)
			, intCommodityId INT
			, intContractHeaderId INT
			, strContractNumber NVARCHAR(100)
			, strLocationName NVARCHAR(100)
			, dtmEndDate DATETIME
			, dblBalance NUMERIC(24, 10)
			, dblFutures NUMERIC(24, 10)
			, dblBasis NUMERIC(24, 10)
			, dblCash NUMERIC(24, 10)
			, dblAmount NUMERIC(24, 10)
			, intUnitMeasureId INT
			, intPricingTypeId INT
			, intContractTypeId INT
			, intCompanyLocationId INT
			, strContractType NVARCHAR(100)
			, strPricingType NVARCHAR(100)
			, intCommodityUnitMeasureId INT
			, intContractDetailId INT
			, intContractStatusId INT
			, intEntityId INT
			, intCurrencyId INT
			, strType NVARCHAR(100)
			, intItemId INT
			, strItemNo NVARCHAR(100)
			, dtmContractDate DATETIME
			, strEntityName NVARCHAR(100)
			, strCustomerContract NVARCHAR(100)
			, intFutureMarketId INT
			, intFutureMonthId INT
			, strPricingStatus NVARCHAR(50))

		SELECT *
		INTO #CBBucket
		FROM dbo.fnRKGetBucketContractBalance(@dtmEndDate, @intCommodityId, NULL)

		SELECT intContractDetailId, intContractStatusId
		INTO #ContractStatus
		FROM (
			SELECT intRowNumber = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmCreateDate DESC)
				, intContractDetailId
				, intContractStatusId
			FROM #CBBucket
		) tbl
		WHERE intRowNumber = 1
		
		SELECT DISTINCT a.intContractDetailId, a.strContractNumber
			, CASE WHEN b.intCounter > 1 THEN 'Partially Priced'
				WHEN b.intCounter = 1 AND strPricingType IN ('Basis', 'HTA') THEN 'Unpriced'
				WHEN b.intCounter = 1 AND strPricingType = 'Priced' THEN 'Fully Priced'
				END as strPricingStatus
		INTO #tmpPricingStatus
		FROM #CBBucket a
		CROSS APPLY (
			SELECT *, COUNT(*) as intCounter
			FROM (
				SELECT strContractType, strContractNumber, intContractDetailId
				FROM #CBBucket
				GROUP BY strContractNumber, strPricingType, intContractDetailId, strContractType
				HAVING SUM(dblQty) > 0
			) t
			WHERE t.intContractDetailId = a.intContractDetailId
			GROUP BY strContractNumber, intContractDetailId, strContractType
		) b
		GROUP BY a.intContractDetailId, a.strContractNumber, strPricingType, a.strContractType, b.intCounter
		HAVING SUM(dblQty) > 0

		SELECT z.intContractHeaderId
			, z.intContractDetailId
			, z.dtmEndDate 
			, z.dblBasis
			, dblFutures = CASE WHEN ctd.intPricingTypeId = 1 AND pricingLatestDate.pricedCount = pricingByEndDate.pricedCount THEN ctd.dblFutures
					ELSE z.dblFutures END
			, z.intQtyUOMId
			, ysnFullyPriced = CAST(CASE WHEN ctd.intPricingTypeId = 1 AND pricingLatestDate.pricedCount = pricingByEndDate.pricedCount THEN 1
						ELSE 0 END AS bit)
		INTO #tempLatestContractDetails
		FROM
		(
			SELECT 
				intContractHeaderId
				,intContractDetailId
				,dtmEndDate 
				,dblBasis
				,dblFutures
				,intQtyUOMId
			FROM (
				SELECT 
					intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dbo.fnRemoveTimeOnDate(CASE WHEN CBL.strAction = 'Created Price' THEN CBL.dtmTransactionDate ELSE dbo.[fnCTConvertDateTime](CBL.dtmCreatedDate,'ToServerDate',0) END) DESC)
					,*
				FROM tblCTContractBalanceLog CBL
				WHERE dbo.fnRemoveTimeOnDate(CASE WHEN CBL.strAction = 'Created Price' THEN CBL.dtmTransactionDate ELSE dbo.[fnCTConvertDateTime](CBL.dtmCreatedDate,'ToServerDate',0) END) <= @dtmEndDate
				AND CBL.intCommodityId = ISNULL(@intCommodityId, CBL.intCommodityId)
				AND CBL.strTransactionType = 'Contract Balance'
				AND CBL.dblBasis IS NOT NULL
			) t
			WHERE intRowNum = 1
		) z

		LEFT JOIN tblCTContractDetail ctd
			ON ctd.intContractDetailId = z.intContractDetailId
		OUTER APPLY (SELECT pricedCount = COUNT('') 
					FROM tblCTPriceFixation pfh
					JOIN tblCTPriceFixationDetail pfd 
					ON pfh.intPriceFixationId = pfd.intPriceFixationId
					WHERE pfh.intContractDetailId = z.intContractDetailId
			) pricingLatestDate
		OUTER APPLY (SELECT pricedCount = COUNT('') 
					FROM tblCTPriceFixation pfh
					JOIN tblCTPriceFixationDetail pfd 
					ON pfh.intPriceFixationId = pfd.intPriceFixationId
					WHERE pfh.intContractDetailId = z.intContractDetailId
					AND pfd.dtmFixationDate <= @dtmEndDate
			) pricingByEndDate

		INSERT INTO @ContractBalance (intRowNum
			, strCommodityCode
			, intCommodityId
			, intContractHeaderId
			, strContractNumber
			, strLocationName
			, dtmEndDate
			, dblBalance
			, dblFutures
			, dblBasis
			, dblCash
			, dblAmount
			, intUnitMeasureId
			, intPricingTypeId
			, intContractTypeId
			, intCompanyLocationId
			, strContractType
			, strPricingType
			, intCommodityUnitMeasureId
			, intContractDetailId
			, intContractStatusId
			, intEntityId
			, intCurrencyId
			, strType
			, intItemId
			, strItemNo
			, dtmContractDate
			, strEntityName
			, strCustomerContract
			--, intFutureMarketId
			--, intFutureMonthId
			, strPricingStatus)
		SELECT ROW_NUMBER() OVER (PARTITION BY tbl.intContractDetailId ORDER BY dtmTransactionDate DESC) intRowNum
			, strCommodityCode
			, intCommodityId
			, intContractHeaderId
			, strContractNumber
			, strLocationName
			, dtmEndDate
			, dblQty
			, dblFutures
			, dblBasis
			, dblCashPrice
			, dblAmount
			, intQtyUOMId
			, intPricingTypeId
			, intContractTypeId
			, intLocationId
			, strContractType
			, strPricingType
			, intCommodityUnitMeasureId
			, tbl.intContractDetailId
			, intContractStatusId
			, intEntityId
			, intQtyCurrencyId
			, strType
			, intItemId
			, strItemNo
			, dtmTransactionDate
			, strEntityName
			, strCustomerContract
			--, intFutureMarketId
			--, intFutureMonthId
			, strPricingStatus
		FROM (
			SELECT dtmTransactionDate = MAX(dtmTransactionDate)
				, strCommodityCode
				, intCommodityId
				, tbl.intContractHeaderId
				, strContractNumber
				, strLocationName
				, lcd.dtmEndDate
				, dblQty = CAST(SUM(dblQuantity) AS NUMERIC(20, 6))
				, dblFutures = CAST(lcd.dblFutures AS NUMERIC(20, 6))
				, dblBasis = CAST(lcd.dblBasis AS NUMERIC(20, 6))	
				, dblCashPrice = CAST (MAX(dblCashPrice) AS NUMERIC(20, 6))
				, dblAmount = CAST ((SUM(dblQuantity) * (lcd.dblBasis + lcd.dblFutures)) AS NUMERIC(20, 6))
				, lcd.intQtyUOMId
				, intPricingTypeId
				, intContractTypeId
				, intLocationId
				, strContractType
				, strPricingType
				, intCommodityUnitMeasureId = NULL
				, tbl.intContractDetailId
				, intEntityId
				, intQtyCurrencyId
				, strType = strContractType + ' ' + strPricingType
				, intItemId
				, strItemNo
				, strEntityName
				, strCustomerContract = ''
				--, intFutureMarketId
				--, intFutureMonthId
				, strPricingStatus = CASE WHEN lcd.ysnFullyPriced = 1 THEN 'Fully Priced' ELSE strPricingStatus END
			FROM
			(
				SELECT dtmTransactionDate = CASE WHEN CBL.strAction = 'Created Price' THEN CBL.dtmTransactionDate ELSE dbo.[fnCTConvertDateTime](CBL.dtmCreatedDate,'ToServerDate',0) END
					, CBL.intContractDetailId
					, CBL.intCommodityId
					, strCommodityCode = CY.strCommodityCode
					, CBL.intContractHeaderId
					, intCompanyLocationId = CBL.intLocationId
					, strLocationName = L.strLocationName
					, CBL.strContractNumber
					, CBL.dtmStartDate
					--, CBL.dtmEndDate
					, dblQuantity = CBL.dblQty
					--, dblFutures = CASE WHEN CBL.intPricingTypeId = 1 OR CBL.intPricingTypeId = 3 THEN CBL.dblFutures ELSE NULL END 
					--, dblBasis = CAST(CBL.dblBasis AS NUMERIC(20,6))
					, dblCashPrice = CASE WHEN CBL.intPricingTypeId = 1 THEN ISNULL(CBL.dblFutures,0) + ISNULL(CBL.dblBasis,0) ELSE NULL END
					, dblAmount = CASE WHEN CBL.intPricingTypeId = 1 THEN [dbo].[fnCTConvertQtyToStockItemUOM](CD.intItemUOMId, CBL.dblQty) * [dbo].[fnCTConvertPriceToStockItemUOM](CD.intPriceItemUOMId,ISNULL(CBL.dblFutures, 0) + ISNULL(CBL.dblBasis, 0))
										ELSE NULL END
					--, CBL.intQtyUOMId
					, CBL.intPricingTypeId
					, CBL.intContractTypeId
					, CBL.intLocationId
					, strContractType = CASE WHEN CBL.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sale' END
					, PT.strPricingType
					, CBL.intEntityId
					, CBL.intQtyCurrencyId
					, CBL.intItemId
					, strItemNo
					, strEntityName = EM.strName
					--, CBL.intFutureMarketId
					--, CBL.intFutureMonthId
					, stat.strPricingStatus
				FROM tblCTContractBalanceLog CBL
				INNER JOIN tblICCommodity CY ON CBL.intCommodityId = CY.intCommodityId
				INNER JOIN tblICCommodityUnitMeasure C1 ON C1.intCommodityId = CBL.intCommodityId AND C1.intCommodityId = CBL.intCommodityId AND C1.ysnStockUnit = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CBL.intPricingTypeId
				INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId
				INNER JOIN tblICItem IM ON IM.intItemId = CBL.intItemId
				INNER JOIN tblEMEntity EM ON EM.intEntityId = CBL.intEntityId
				INNER JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = CBL.intLocationId
				INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CBL.intContractDetailId
				LEFT JOIN #tmpPricingStatus stat ON stat.intContractDetailId = CBL.intContractDetailId
				WHERE CBL.strTransactionType = 'Contract Balance'
			) tbl
			LEFT JOIN #tempLatestContractDetails lcd
				ON lcd.intContractHeaderId = tbl.intContractHeaderId
				AND lcd.intContractDetailId = tbl.intContractDetailId
			WHERE intCommodityId = ISNULL(@intCommodityId, intCommodityId)
				AND dbo.fnRemoveTimeOnDate(dtmTransactionDate) <= @dtmEndDate
				AND ((lcd.ysnFullyPriced = 0 AND tbl.intPricingTypeId = 2) OR tbl.intPricingTypeId <> 2 )
			GROUP BY strCommodityCode
				, intCommodityId
				, tbl.intContractHeaderId
				, strContractNumber
				, strLocationName
				, dtmEndDate
				, intQtyUOMId
				, intPricingTypeId
				, intContractTypeId
				, intLocationId
				, strContractType
				, strPricingType
				, tbl.intContractDetailId
				, intEntityId
				, intQtyCurrencyId
				, strContractType
				, strPricingType
				, intItemId
				, strItemNo
				, strEntityName
				--, intFutureMarketId
				--, intFutureMonthId
				, strPricingStatus
				, lcd.dblBasis
				, lcd.dblFutures
				, lcd.ysnFullyPriced
			HAVING SUM(dblQuantity) > 0
			
		) tbl
		JOIN #ContractStatus cs ON cs.intContractDetailId = tbl.intContractDetailId
		WHERE cs.intContractStatusId NOT IN (2, 3, 6, 5) 

		INSERT INTO @GetContractDetailView (intCommodityUnitMeasureId
			, strLocationName
			, strCommodityDescription
			, intMainCurrencyId
			, intCent
			, dblDetailQuantity
			, intContractTypeId
			, intContractHeaderId
			, strContractType
			, strContractNumber
			, strEntityName
			, intEntityId
			, strCommodityCode
			, intCommodityId
			, strPosition
			, dtmContractDate
			, intContractBasisId
			, intContractSeq
			, dtmStartDate
			, dtmEndDate
			, intPricingTypeId
			, dblRatio
			, dblBasis
			, dblFutures
			, intContractStatusId
			, dblCashPrice
			, intContractDetailId
			, intFutureMarketId
			, intFutureMonthId
			, intItemId
			, dblBalance
			, intCurrencyId
			, dblRate
			, intMarketZoneId
			, dtmPlannedAvailabilityDate
			, strItemNo
			, strPricingType
			, intPriceUnitMeasureId
			, intUnitMeasureId
			, strFutureMonth
			, strFutureMarket
			, intOriginId
			, strLotTracking
			, dblNoOfLots
			, dblLotsFixed
			, dblPriceWORollArb
			, dblHeaderNoOfLots
			, ysnSubCurrency
			, intCompanyLocationId
			, ysnExpired
			, strPricingStatus
			, strOrgin
			, ysnMultiplePriceFixation
			, intMarketUOMId
			, intMarketCurrencyId 
			, dblInvoicedQuantity
			, dblPricedQty
			, dblUnPricedQty
			, dblPricedAmount
			, strMarketZoneCode)
		SELECT DISTINCT intCommodityUnitMeasureId = CH.intCommodityUOMId
			, CL.strLocationName
			, strCommodityDescription = CY.strDescription
			, CU.intMainCurrencyId
			, CU.intCent
			, dblDetailQuantity = CD.dblQuantity
			, CH.intContractTypeId
			, CH.intContractHeaderId
			, TP.strContractType
			, CH.strContractNumber
			, strEntityName = EY.strName
			, CH.intEntityId
			, CY.strCommodityCode
			, CH.intCommodityId
			, PO.strPosition
			, dtmContractDate = CONVERT(DATETIME, CONVERT(VARCHAR, CB.dtmContractDate, 101), 101)
			, CH.intContractBasisId
			, CD.intContractSeq
			, CD.dtmStartDate
			, CD.dtmEndDate
			, CD.intPricingTypeId
			, CD.dblRatio
			, CB.dblBasis
			, CB.dblFutures
			, CD.intContractStatusId
			, CD.dblCashPrice
			, CD.intContractDetailId
			, CD.intFutureMarketId
			, CD.intFutureMonthId
			, CD.intItemId
			, dblBalance = ISNULL(CB.dblBalance, CD.dblBalance)
			, CD.intCurrencyId
			, CD.dblRate
			, CD.intMarketZoneId
			, CD.dtmPlannedAvailabilityDate
			, IM.strItemNo
			, CB.strPricingType
			, intPriceUnitMeasureId = PU.intUnitMeasureId
			, IU.intUnitMeasureId
			, MO.strFutureMonth
			, strFutureMarket = FM.strFutMarketName
			, IM.intOriginId
			, IM.strLotTracking
			, dblNoOfLots = CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN CH.dblNoOfLots ELSE CD.dblNoOfLots END
			, dblLotsFixed = NULL
			, dblPriceWORollArb = NULL
			, CH.dblNoOfLots dblHeaderNoOfLots
			, ysnSubCurrency = CAST(ISNULL(CU.intMainCurrencyId, 0) AS BIT)
			, CD.intCompanyLocationId
			, MO.ysnExpired
			, CB.strPricingStatus
			, strOrgin = CA.strDescription
			, ysnMultiplePriceFixation = ISNULL(ysnMultiplePriceFixation, 0)
			, intMarketUOMId = FM.intUnitMeasureId
			, intMarketCurrencyId = FM.intCurrencyId
			, dblInvoicedQuantity = dblInvoicedQty
			, dblPricedQty = NULL
			, dblUnPricedQty = NULL
			, dblPricedAmount = CB.dblAmount
			, MZ.strMarketZoneCode
		FROM tblCTContractHeader CH
		INNER JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
		INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
		INNER JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
		INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
		INNER JOIN tblICItem IM ON IM.intItemId = CD.intItemId
		INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		INNER JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId
		LEFT JOIN @ContractBalance CB ON CD.intContractDetailId = CB.intContractDetailId
		LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
		LEFT JOIN tblCTPosition PO ON PO.intPositionId = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
		LEFT JOIN tblARMarketZone MZ ON MZ.intMarketZoneId = CD.intMarketZoneId
		WHERE CH.intCommodityId = @intCommodityId
			AND CL.intCompanyLocationId = ISNULL(@intLocationId, CL.intCompanyLocationId)
			AND ISNULL(CD.intMarketZoneId, 0) = ISNULL(@intMarketZoneId, ISNULL(CD.intMarketZoneId, 0))
			AND CONVERT(DATETIME,CONVERT(VARCHAR, CB.dtmContractDate, 101),101) <= @dtmEndDate

		SELECT intContractDetailId
			, dblCosts = SUM(dblCosts)
		INTO #tblContractCost
		FROM ( 
			SELECT dblCosts = dbo.fnRKGetCurrencyConvertion(CASE WHEN ISNULL(CU.ysnSubCurrency, 0) = 1 THEN CU.intMainCurrencyId ELSE dc.intCurrencyId END, @intCurrencyId)
								* (CASE WHEN (M2M.strContractType = 'Both') OR (M2M.strContractType = 'Purchase' AND cd.strContractType = 'Purchase') OR (M2M.strContractType = 'Sale' AND cd.strContractType = 'Sale')
											THEN (CASE WHEN strAdjustmentType = 'Add' THEN ABS(CASE WHEN dc.strCostMethod = 'Amount' THEN SUM(dc.dblRate)
																									ELSE SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cu1.intCommodityUnitMeasureId, ISNULL(dc.dblRate, 0))) END)
														WHEN strAdjustmentType = 'Reduce' THEN CASE WHEN dc.strCostMethod = 'Amount' THEN SUM(dc.dblRate)
																									ELSE - SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cu1.intCommodityUnitMeasureId, ISNULL(dc.dblRate, 0))) END
														ELSE 0 END)
										ELSE 0 END)
				, strAdjustmentType
				, dc.intContractDetailId
				, a = cu.intCommodityUnitMeasureId
				, b = cu1.intCommodityUnitMeasureId
				, strCostMethod
			FROM @GetContractDetailView cd
			INNER JOIN vyuRKM2MContractCost dc ON dc.intContractDetailId = cd.intContractDetailId
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
			INNER JOIN tblRKM2MConfiguration M2M ON dc.intItemId = M2M.intItemId AND ch.intFreightTermId = M2M.intFreightTermId
			INNER JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = @intCommodityId AND cu.intUnitMeasureId = @intPriceUOMId
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = dc.intCurrencyId
			LEFT JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = @intCommodityId AND cu1.intUnitMeasureId = dc.intUnitMeasureId
			WHERE NOT (cd.intPricingTypeId = 2 AND cd.strPricingType = 'Priced')
			GROUP BY cu.intCommodityUnitMeasureId
				, cu1.intCommodityUnitMeasureId
				, strAdjustmentType
				, dc.intContractDetailId
				, dc.strCostMethod
				, CU.ysnSubCurrency
				, CU.intMainCurrencyId
				, dc.intCurrencyId
				, M2M.strContractType
				, cd.strContractType
		) t 
		GROUP BY intContractDetailId

		DECLARE @tblGetSettlementPrice TABLE (dblLastSettle NUMERIC(24, 10)
			, intFutureMonthId INT
			, intFutureMarketId INT)

		IF (@intMarkExpiredMonthPositionId = 2 OR @intMarkExpiredMonthPositionId = 3)
		BEGIN
			INSERT INTO @tblGetSettlementPrice
			SELECT dblLastSettle
				, intFutureMonthId
				, intFutureMarketId
			FROM (
				SELECT ROW_NUMBER() OVER (PARTITION BY pm.intFutureMonthId ORDER BY dtmPriceDate DESC) intRowNum
					, dblLastSettle
					, fm.intFutureMonthId
					, p.intFutureMarketId
					, fm.ysnExpired ysnExpired
					, strFutureMonth
				FROM tblRKFuturesSettlementPrice p
				INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
				JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = pm.intFutureMonthId
				WHERE p.intFutureMarketId = fm.intFutureMarketId
					AND CONVERT(NVARCHAR, dtmPriceDate, 111) < = CONVERT(NVARCHAR, @dtmSettlemntPriceDate, 111)
			) t WHERE t.intRowNum = 1
		END
		ELSE
		BEGIN
			INSERT INTO @tblGetSettlementPrice
			SELECT dblLastSettle
				, fm.intFutureMonthId
				, fm.intFutureMarketId
			FROM tblRKFuturesSettlementPrice p
			INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
			JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = CASE WHEN ISNULL(fm.ysnExpired, 0) = 0 THEN pm.intFutureMonthId
																	ELSE (SELECT TOP 1 intFutureMonthId
																			FROM tblRKFuturesMonth fm
																			WHERE ysnExpired = 0 AND fm.intFutureMarketId = p.intFutureMarketId
																				AND CONVERT(DATETIME, '01 ' + strFutureMonth) > GETDATE()
																			ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth) ASC) END
			WHERE p.intFutureMarketId = fm.intFutureMarketId
				AND CONVERT(NVARCHAR, dtmPriceDate, 111) = CONVERT(NVARCHAR, @dtmSettlemntPriceDate, 111)
			ORDER BY dtmPriceDate DESC
		END

		SELECT DISTINCT intContractDetailId
			, dblFuturePrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cuc.intCommodityUnitMeasureId, dblLastSettle / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
			, dblFutures = dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, PUOM.intCommodityUnitMeasureId, cd.dblFutures / CASE WHEN c1.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
			, intFuturePriceCurrencyId = fm.intCurrencyId
		INTO #tblSettlementPrice
		FROM @GetContractDetailView cd
		JOIN tblRKFuturesMonth ffm ON ffm.intFutureMonthId = cd.intFutureMonthId AND ffm.intFutureMarketId = cd.intFutureMarketId
		JOIN tblRKFutureMarket fm ON cd.intFutureMarketId = fm.intFutureMarketId
		JOIN tblSMCurrency c ON cd.intMarketCurrencyId = c.intCurrencyID AND cd.intCommodityId = @intCommodityId
		JOIN tblSMCurrency c1 ON cd.intCurrencyId = c1.intCurrencyID
		JOIN tblICCommodityUnitMeasure cuc ON cd.intCommodityId = cuc.intCommodityId AND cuc.intUnitMeasureId = cd.intMarketUOMId
		JOIN tblICCommodityUnitMeasure PUOM ON cd.intCommodityId = PUOM.intCommodityId AND PUOM.intUnitMeasureId = cd.intPriceUnitMeasureId
		JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = @intCommodityId AND cu.intUnitMeasureId = @intPriceUOMId
		JOIN @tblGetSettlementPrice sm ON sm.intFutureMonthId = ffm.intFutureMonthId
		WHERE cd.intCommodityId = @intCommodityId

		SELECT intContractDetailId
			, dblFuture = (avgLot / intTotLot)
		INTO #tblContractFuture
		FROM (
			SELECT avgLot = SUM(ISNULL(pfd.[dblNoOfLots], 0)
							* dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, PUOM.intCommodityUnitMeasureId, ISNULL(dblFixationPrice, 0)))
							/ MAX(CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
							 + ((MAX(ISNULL(CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots
												ELSE cdv.dblNoOfLots END, 0)) - SUM(ISNULL(pfd.[dblNoOfLots], 0)))
							* MAX(dblFuturePrice))
				, intTotLot = MAX(CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots ELSE cdv.dblNoOfLots END)
				, cdv.intContractDetailId
			FROM tblCTContractDetail cdv
			JOIN #tblSettlementPrice p ON cdv.intContractDetailId = p.intContractDetailId
			JOIN tblSMCurrency c ON cdv.intCurrencyId = c.intCurrencyID
			JOIN tblCTContractHeader ch ON cdv.intContractHeaderId = ch.intContractHeaderId AND ch.intCommodityId = @intCommodityId AND cdv.dblBalance > 0
			JOIN tblCTPriceFixation pf ON CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN pf.intContractHeaderId ELSE pf.intContractDetailId END = CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN cdv.intContractHeaderId ELSE cdv.intContractDetailId END
			JOIN tblCTPriceFixationDetail pfd ON pf.intPriceFixationId = pfd.intPriceFixationId AND cdv.intPricingTypeId <> 1 AND cdv.intFutureMarketId = pfd.intFutureMarketId AND cdv.intFutureMonthId = pfd.intFutureMonthId AND cdv.intContractStatusId NOT IN (2, 3, 6)
			JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = @intCommodityId AND cu.intUnitMeasureId = @intPriceUOMId
			JOIN tblICItemUOM PU ON PU.intItemUOMId = cdv.intPriceItemUOMId
			JOIN tblICCommodityUnitMeasure PUOM ON ch.intCommodityId = PUOM.intCommodityId AND PUOM.intUnitMeasureId = PU.intUnitMeasureId
			GROUP BY cdv.intContractDetailId
		) t

		DECLARE @tblOpenContractList TABLE (intContractHeaderId int
			, intContractDetailId int
			, strContractOrInventoryType NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strContractSeq NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intEntityId int
			, strFutureMarket NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intFutureMarketId int
			, strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intFutureMonthId int
			, strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intCommodityId int
			, strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intItemId int
			, strOrgin NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intOriginId int
			, strPosition NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strPeriod NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strPeriodTo NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strStartDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strEndDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strPriOrNotPriOrParPriced NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intPricingTypeId int
			, strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dblContractRatio NUMERIC(24, 10)
			, dblContractBasis NUMERIC(24, 10)
			, dblDummyContractBasis NUMERIC(24, 10)
			, dblCash NUMERIC(24, 10)
			, dblFuturesClosingPrice1 NUMERIC(24, 10)
			, dblFutures NUMERIC(24, 10)
			, dblMarketRatio NUMERIC(24, 10)
			, dblMarketBasis1 NUMERIC(24, 10)
			, intMarketBasisUOM NUMERIC(24, 10)
			, intMarketBasisCurrencyId INT
			, dblFuturePrice1 NUMERIC(24, 10)
			, intFuturePriceCurrencyId INT
			, intContractTypeId INT
			, dblRate NUMERIC(24, 10)
			, intCommodityUnitMeasureId int
			, intQuantityUOMId int
			, intPriceUOMId int
			, intCurrencyId int
			, PriceSourceUOMId int
			, dblCosts NUMERIC(24, 10)
			, dblContractOriginalQty NUMERIC(24, 10)
			, ysnSubCurrency BIT
			, intMainCurrencyId int
			, intCent int
			, dtmPlannedAvailabilityDate datetime
			, intCompanyLocationId int
			, intMarketZoneId int
			, intContractStatusId int
			, dtmContractDate datetime
			, ysnExpired BIT
			, dblInvoicedQuantity NUMERIC(24, 10)
			, dblPricedQty NUMERIC(24, 10)
			, dblUnPricedQty NUMERIC(24, 10)
			, dblPricedAmount NUMERIC(24, 10)
			, strMarketZoneCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dblNoOfLots NUMERIC(24, 10)
			, dblLotsFixed NUMERIC(24, 10)
			, dblPriceWORollArb NUMERIC(24, 10)
			, dblCashPrice NUMERIC(24, 10)
			, intSpreadMonthId INT
			, strSpreadMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, dblSpreadMonthPrice NUMERIC(24, 10)
			, dblSpread NUMERIC(24, 10)
			, ysnSpreadExpired BIT)

		SELECT dblRatio
			, dblMarketBasis = (ISNULL(dblBasisOrDiscount, 0) + ISNULL(dblCashOrFuture, 0)) / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END
			, intMarketBasisUOM = intCommodityUnitMeasureId
			, intMarketBasisCurrencyId = intCurrencyId
			, intFutureMarketId = temp.intFutureMarketId
			, intItemId = temp.intItemId
			, intContractTypeId = temp.intContractTypeId
			, intCompanyLocationId = temp.intCompanyLocationId
			, strPeriodTo = ISNULL(temp.strPeriodTo, '')
			, temp.strContractInventory
			, temp.intUnitMeasureId
			, dblCashOrFuture = ISNULL(dblCashOrFuture, 0)
			, temp.intCurrencyId
			, temp.intCommodityId
		INTO #tmpM2MBasisDetail
		FROM tblRKM2MBasisDetail temp
		LEFT JOIN tblSMCurrency c ON temp.intCurrencyId=c.intCurrencyID
		JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = temp.intCommodityId AND temp.intUnitMeasureId = cum.intUnitMeasureId
		WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId

		SELECT intContractDetailId
			, intFutureMarketId
			, intFutureMonthId
			, strFutureMonth
			, intNearByFutureMonthId
			, intNearByFutureMarketId
			, strNearByFutureMonth
			, ysnExpired
			, dblNearbySettlementPrice
			, intFutureSettlementPriceId
		INTO #RollNearbyMonth
		FROM (
			SELECT intRowNumber = ROW_NUMBER() OVER (PARTITION BY cd.intContractDetailId ORDER BY nearby.dtmFutureMonthsDate)
				, cd.intContractDetailId
				, cd.intFutureMarketId
				, cd.intFutureMonthId
				, fMon.strFutureMonth
				, intNearByFutureMonthId = nearby.intFutureMonthId
				, intNearByFutureMarketId = nearby.intFutureMarketId
				, strNearByFutureMonth = nearby.strFutureMonth
				, ysnExpired
				, dblNearbySettlementPrice = SP.dblLastSettle
				, SP.intFutureSettlementPriceId
			FROM tblCTContractBalance cd
			LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = cd.intFutureMonthId
			CROSS APPLY (
				SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY intFutureMarketId, intFutureMonthId ORDER BY dtmFutureMonthsDate)
					, intFutureMonthId
					, intFutureMarketId
					, strFutureMonth
					, dtmFutureMonthsDate
				FROM tblRKFuturesMonth
				WHERE intFutureMonthId <> cd.intFutureMonthId
					AND intFutureMarketId = cd.intFutureMarketId
					AND dtmFutureMonthsDate > fMon.dtmFutureMonthsDate
					AND ysnExpired <> 1
			) nearby
			LEFT JOIN (
				SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY SP.intFutureMarketId, MP.intFutureMonthId ORDER BY SP.dtmPriceDate DESC)
					, SP.intFutureMarketId
					, MP.intFutureMonthId
					, SP.intFutureSettlementPriceId
					, MP.dblLastSettle
					, SP.dtmPriceDate
				FROM tblRKFutSettlementPriceMarketMap MP
				JOIN tblRKFuturesSettlementPrice SP ON MP.intFutureSettlementPriceId = SP.intFutureSettlementPriceId
					AND CONVERT(DATETIME, CONVERT(VARCHAR, SP.dtmPriceDate, 101), 101) < = CONVERT(DATETIME, CONVERT(VARCHAR, @dtmEndDate, 101), 101)
			) SP ON SP.intFutureMarketId = nearby.intFutureMarketId AND SP.intFutureMonthId = nearby.intFutureMonthId
			WHERE ysnExpired = 1
				AND cd.intCommodityId = ISNULL(@intCommodityId, cd.intCommodityId)
				AND CONVERT(DATETIME, CONVERT(VARCHAR, dtmEndDate, 101), 101) = @dtmEndDate
				AND SP.intRowId = 1
				AND nearby.intRowId = 1
		) tbl WHERE intRowNumber = 1
		
		INSERT INTO @tblOpenContractList (intContractHeaderId
			, intContractDetailId
			, strContractOrInventoryType
			, strContractSeq
			, strEntityName
			, intEntityId
			, strFutureMarket
			, intFutureMarketId
			, strFutureMonth
			, intFutureMonthId
			, strCommodityCode
			, intCommodityId
			, strItemNo
			, intItemId
			, strOrgin
			, intOriginId
			, strPosition
			, strPeriod
			, strPeriodTo
			, strStartDate
			, strEndDate
			, strPriOrNotPriOrParPriced
			, intPricingTypeId
			, strPricingType
			, dblContractRatio
			, dblContractBasis
			, dblDummyContractBasis
			, dblCash
			, dblFuturesClosingPrice1
			, dblFutures
			, dblMarketRatio
			, dblMarketBasis1
			, intMarketBasisUOM
			, intMarketBasisCurrencyId
			, dblFuturePrice1
			, intFuturePriceCurrencyId
			, intContractTypeId
			, dblRate
			, intCommodityUnitMeasureId
			, intQuantityUOMId
			, intPriceUOMId
			, intCurrencyId
			, PriceSourceUOMId
			, dblCosts
			, dblContractOriginalQty
			, ysnSubCurrency
			, intMainCurrencyId
			, intCent
			, dtmPlannedAvailabilityDate
			, intCompanyLocationId
			, intMarketZoneId
			, intContractStatusId
			, dtmContractDate
			, ysnExpired
			, dblInvoicedQuantity
			, dblPricedQty
			, dblUnPricedQty
			, dblPricedAmount
			, strMarketZoneCode
			, strLocationName
			, dblNoOfLots
			, dblLotsFixed
			, dblPriceWORollArb
			, dblCashPrice
			, intSpreadMonthId
			, strSpreadMonth
			, dblSpreadMonthPrice
			, dblSpread
			, ysnSpreadExpired)
		SELECT intContractHeaderId
			, intContractDetailId
			, strContractOrInventoryType
			, strContractSeq
			, strEntityName
			, intEntityId
			, strFutureMarket
			, intFutureMarketId
			, strFutureMonth
			, intFutureMonthId
			, strCommodityCode
			, intCommodityId
			, strItemNo
			, intItemId
			, strOrgin
			, intOriginId
			, strPosition
			, strPeriod
			, strPeriodTo
			, strStartDate
			, strEndDate
			, strPriOrNotPriOrParPriced
			, intPricingTypeId
			, strPricingType
			, dblRatio
			, dblContractBasis = CASE WHEN ISNULL(intPricingTypeId, 0) = 3 THEN dblMarketBasis1 ELSE dblContractBasis END
			, dblDummyContractBasis
			, dblCash
			, dblFuturesClosingPrice1
			, dblFutures = dblFutures / CASE WHEN ysnSubCurrency = 1 THEN 100 ELSE 1 END
			, dblMarketRatio
			, dblMarketBasis1 = CASE WHEN intPricingTypeId = 6 THEN 0 ELSE dblMarketBasis1 END
			, intMarketBasisUOM
			, intMarketBasisCurrencyId
			, dblFuturePrice1
			, intFuturePriceCurrencyId
			, intContractTypeId 
			, dblRate
			, intCommodityUnitMeasureId
			, intQuantityUOMId
			, intPriceUOMId
			, intCurrencyId
			, PriceSourceUOMId
			, dblCosts
			, dblContractOriginalQty
			, ysnSubCurrency
			, intMainCurrencyId
			, intCent
			, dtmPlannedAvailabilityDate
			, intCompanyLocationId
			, intMarketZoneId
			, intContractStatusId
			, dtmContractDate
			, ysnExpired
			, dblInvoicedQuantity
			, dblPricedQty
			, dblUnPricedQty
			, dblPricedAmount
			, strMarketZoneCode
			, strLocationName 
			, dblNoOfLots
			, dblLotsFixed
			, dblPriceWORollArb
			, dblCashPrice = CASE WHEN intPricingTypeId = 6 THEN dblMarketCashPrice ELSE 0 END
			, intSpreadMonthId
			, strSpreadMonth
			, dblSpreadMonthPrice
			, dblSpread
			, ysnSpreadExpired
		FROM (
			SELECT DISTINCT cd.intContractHeaderId
				, cd.intContractDetailId
				, strContractOrInventoryType = 'Contract' + '(' + LEFT(cd.strContractType, 1) + ')'
				, strContractSeq = cd.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq)
				, cd.strEntityName
				, cd.intEntityId
				, cd.strFutureMarket
				, cd.intFutureMarketId
				, cd.strFutureMonth
				, cd.intFutureMonthId
				, cd.strCommodityCode
				, cd.intCommodityId
				, cd.strItemNo
				, cd.intItemId
				, cd.strOrgin
				, cd.intOriginId
				, cd.strPosition
				, strPeriod = RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5) + '-' + RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5)
				, strPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20), cd.dtmEndDate, 106), 4, 8)
				, strPriOrNotPriOrParPriced = cd.strPricingStatus
				, cd.intPricingTypeId
				, cd.strPricingType
				, cd.dblRatio
				, dblContractBasis = ISNULL(CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN ISNULL(cd.dblBasis, 0)
												ELSE 0 END, 0) / CASE WHEN ysnSubCurrency = 1 THEN 100 ELSE 1 END
				, dblDummyContractBasis = ISNULL(cd.dblBasis, 0)
				, dblCash = CASE WHEN cd.intPricingTypeId = 6 THEN dblCashPrice ELSE NULL END
				, dblFuturesClosingPrice1 = dblFuturePrice
				, dblFutures = CASE WHEN strPricingType = 'Basis' AND  strPricingStatus IN ('Unpriced', 'Partially Priced') THEN 0
									--Basis (Partially Priced) Priced Record
									WHEN cd.intPricingTypeId = 2 AND strPricingType = 'Priced' AND strPricingStatus = 'Partially Priced' THEN ISNULL(priceFixationDetail.dblFutures, 0)
									-- Fully Priced but when backdated, not yet fully priced 
									WHEN cd.intPricingTypeId = 1 AND strPricingType = 'Priced' AND strPricingStatus = 'Partially Priced' AND priceFixationDetail.dblFutures IS NOT NULL THEN ISNULL(priceFixationDetail.dblFutures, 0)
									ELSE 
										CASE WHEN cd.intPricingTypeId IN (1, 3) 
											THEN ISNULL(cd.dblFutures, 0) 
											ELSE ISNULL(cd.dblFutures, 0) END 
									END
				, dblMarketRatio = ISNULL(basisDetail.dblRatio, 0)
				, dblMarketBasis1 = ISNULL(CASE WHEN cd.strPricingType <> 'HTA' THEN basisDetail.dblMarketBasis ELSE 0 END, 0)
				, dblMarketCashPrice = ISNULL(CASE WHEN cd.strPricingType = 'Cash' THEN	basisDetail.dblMarketBasis ELSE 0 END, 0)
				, intMarketBasisUOM = ISNULL(basisDetail.intMarketBasisUOM, 0)
				, intMarketBasisCurrencyId = ISNULL(basisDetail.intMarketBasisCurrencyId, 0)
				, dblFuturePrice1 = CASE WHEN cd.strPricingType IN ('Basis', 'Ratio') THEN 0 ELSE p.dblFuturePrice END
				, intFuturePriceCurrencyId
				, intContractTypeId = CONVERT(INT, cd.intContractTypeId)
				, cd.dblRate
				, cuc.intCommodityUnitMeasureId
				, intQuantityUOMId = cuc1.intCommodityUnitMeasureId
				, intPriceUOMId = cuc2.intCommodityUnitMeasureId
				, cd.intCurrencyId
				, PriceSourceUOMId = CONVERT(INT, cuc3.intCommodityUnitMeasureId)
				, dblCosts = ISNULL(dblCosts, 0)
				, dblContractOriginalQty = cd.dblBalance
				, cd.ysnSubCurrency
				, cd.intMainCurrencyId
				, cd.intCent
				, cd.dtmPlannedAvailabilityDate
				, cd.intCompanyLocationId
				, cd.intMarketZoneId
				, cd.intContractStatusId
				, cd.dtmContractDate
				, ffm.ysnExpired
				, cd.dblInvoicedQuantity
				, dblPricedQty
				, dblUnPricedQty
				, cd.dblPricedAmount
				, strMarketZoneCode
				, strLocationName
				, cd.dblNoOfLots
				, cd.dblLotsFixed
				, cd.dblPriceWORollArb
				, strStartDate = CONVERT(NVARCHAR(20), cd.dtmStartDate, 106)
				, strEndDate = CONVERT(NVARCHAR(20), cd.dtmEndDate, 106)
				, intSpreadMonthId = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
				, strSpreadMonth = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
				, dblSpreadMonthPrice = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice ELSE NULL END ELSE NULL END
				, dblSpread = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice - (CASE WHEN cd.strPricingType IN ('Basis', 'Ratio') THEN 0 ELSE p.dblFuturePrice END) ELSE NULL END ELSE NULL END
				, ysnSpreadExpired = CASE WHEN strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
			FROM @GetContractDetailView cd
			JOIN tblICCommodityUnitMeasure cuc ON cd.intCommodityId = cuc.intCommodityId AND cuc.intUnitMeasureId = cd.intUnitMeasureId AND cd.intCommodityId = @intCommodityId
			JOIN tblICCommodityUnitMeasure cuc1 ON cd.intCommodityId = cuc1.intCommodityId AND cuc1.intUnitMeasureId = @intQuantityUOMId
			JOIN tblICCommodityUnitMeasure cuc2 ON cd.intCommodityId = cuc2.intCommodityId AND cuc2.intUnitMeasureId = @intPriceUOMId
			LEFT JOIN #tblSettlementPrice p ON cd.intContractDetailId = p.intContractDetailId
			LEFT JOIN #tblContractCost cc ON cd.intContractDetailId = cc.intContractDetailId
			LEFT JOIN #tblContractFuture cf ON cf.intContractDetailId = cd.intContractDetailId
			LEFT JOIN tblICCommodityUnitMeasure cuc3 ON cd.intCommodityId = cuc3.intCommodityId AND cuc3.intUnitMeasureId = cd.intPriceUnitMeasureId
			LEFT JOIN tblRKFuturesMonth ffm ON ffm.intFutureMonthId = cd.intFutureMonthId
			LEFT JOIN #RollNearbyMonth rk ON rk.intContractDetailId = cd.intContractDetailId AND rk.intFutureMonthId = cd.intFutureMonthId
			OUTER APPLY (
				SELECT TOP 1 dblRatio, dblMarketBasis, intMarketBasisUOM, intMarketBasisCurrencyId FROM #tmpM2MBasisDetail tmp
				WHERE ISNULL(tmp.intFutureMarketId,0) = ISNULL(cd.intFutureMarketId, ISNULL(tmp.intFutureMarketId,0))
					AND ISNULL(tmp.intItemId,0) = ISNULL(cd.intItemId, ISNULL(tmp.intItemId,0))
					AND ISNULL(tmp.intContractTypeId, cd.intContractTypeId) = CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1
														THEN CASE WHEN ISNULL(tmp.intContractTypeId, 0) = 0 THEN ISNULL(tmp.intContractTypeId, cd.intContractTypeId) ELSE cd.intContractTypeId END
														ELSE ISNULL(tmp.intContractTypeId, cd.intContractTypeId) END 
					AND ISNULL(tmp.intCompanyLocationId, cd.intCompanyLocationId) = CASE WHEN @strEvaluationByZone <> 'Company'
																				THEN cd.intCompanyLocationId
																			ELSE ISNULL(tmp.intCompanyLocationId, cd.intCompanyLocationId) END
					AND tmp.strPeriodTo = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
													THEN CASE WHEN tmp.strPeriodTo = '' THEN tmp.strPeriodTo ELSE dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy') END
												ELSE tmp.strPeriodTo END
					AND tmp.strContractInventory = 'Contract') basisDetail
			LEFT JOIN tblCTContractHeader cth
				ON cd.intContractHeaderId = cth.intContractHeaderId
			OUTER APPLY (
				-- Weighted Average Futures Price for Basis (Priced Qty) in Multiple Price Fixations
				SELECT dblFutures = SUM(dblFutures) 
				FROM
				(
					SELECT dblFutures = (pfd.dblFutures) * (pfd.dblQuantity / pricedTotal.dblTotalPricedQuantity)
					FROM tblCTPriceFixation pfh
					INNER JOIN tblCTPriceFixationDetail pfd
						ON pfh.intPriceFixationId = pfd.intPriceFixationId
						AND pfd.dtmFixationDate <= @dtmEndDate
					OUTER APPLY 
						(
							SELECT dblTotalPricedQuantity = SUM(pfdi.dblQuantity)
							FROM tblCTPriceFixationDetail pfdi
							WHERE pfh.intPriceFixationId = pfdi.intPriceFixationId
							AND pfdi.dtmFixationDate <= @dtmEndDate
						) pricedTotal
					WHERE intContractDetailId = cd.intContractDetailId
						AND (   
								-- Basis (Partially Priced) Priced Record
								(cd.intPricingTypeId = 2 AND strPricingType = 'Priced' AND strPricingStatus = 'Partially Priced')
								-- Backdated and not yet fully priced in that specific date
								OR ((cd.intPricingTypeId = 1 AND strPricingType = 'Priced' AND strPricingStatus = 'Partially Priced') 
									 AND EXISTS (SELECT TOP 1 '' FROM @ContractBalance cb
												WHERE cb.intContractDetailId = cd.intContractDetailId
												AND cb.strPricingType = 'Basis'
												)
									)
							)
				) t
			) priceFixationDetail
			WHERE cd.intCommodityId = @intCommodityId 
		)t

		INSERT INTO @ListTransaction (intContractHeaderId
			, intContractDetailId
			, strContractOrInventoryType
			, strContractSeq
			, strEntityName
			, intEntityId
			, strFutureMarket
			, intFutureMarketId
			, strFutureMonth
			, intFutureMonthId 
			, strCommodityCode
			, intCommodityId
			, strItemNo 
			, intItemId 
			, strOrgin 
			, intOriginId 
			, strPosition 
			, strPeriod 
			, strPeriodTo
			, strStartDate
			, strEndDate
			, strPriOrNotPriOrParPriced 
			, intPricingTypeId 
			, strPricingType 
			, dblFutures
			, dblCash
			, dblCosts
			, dblMarketBasis1
			, intMarketBasisUOMId
			, intMarketBasisCurrencyId
			, dblContractRatio
			, dblContractBasis
			, dblDummyContractBasis
			, dblFuturePrice1 
			, intFuturePriceCurrencyId
			, dblFuturesClosingPrice1 
			, intContractTypeId
			, dblOpenQty 
			, dblRate 
			, intCommodityUnitMeasureId
			, intQuantityUOMId 
			, intPriceUOMId 
			, intCurrencyId 
			, PriceSourceUOMId 
			, dblMarketRatio
			, dblMarketBasis 
			, dblCashPrice 
			, dblAdjustedContractPrice 
			, dblFuturesClosingPrice 
			, dblFuturePrice 
			, dblResult 
			, dblMarketFuturesResult 
			, dblResultCash1 
			, dblContractPrice 
			, dblResultCash 
			, dblResultBasis
			, dblShipQty
			, ysnSubCurrency
			, intMainCurrencyId
			, intCent
			, dtmPlannedAvailabilityDate
			, intMarketZoneId 
			, intLocationId
			, strMarketZoneCode
			, strLocationName 
			, dblNoOfLots
			, dblLotsFixed
			, dblPriceWORollArb
			, intSpreadMonthId
			, strSpreadMonth
			, dblSpreadMonthPrice
			, dblSpread
			, ysnExpired) 
		SELECT DISTINCT intContractHeaderId
			, intContractDetailId 
			, strContractOrInventoryType 
			, strContractSeq 
			, strEntityName 
			, intEntityId 
			, strFutureMarket 
			, intFutureMarketId 
			, strFutureMonth 
			, intFutureMonthId 
			, strCommodityCode 
			, intCommodityId 
			, strItemNo 
			, intItemId 
			, strOrgin 
			, intOriginId 
			, strPosition 
			, strPeriod 
			, strPeriodTo
			, strStartDate
			, strEndDate
			, strPriOrNotPriOrParPriced 
			, intPricingTypeId 
			, strPricingType 
			, dblFutures
			, dblCash
			, dblCosts
			, dblMarketBasis1
			, intMarketBasisUOM
			, intMarketBasisCurrencyId
			, dblContractRatio
			, dblContractBasis 
			, dblDummyContractBasis
			, dblFuturePrice1 
			, intFuturePriceCurrencyId
			, dblFuturesClosingPrice1
			, intContractTypeId
			, dblOpenQty 
			, dblRate 
			, intCommodityUnitMeasureId 
			, intQuantityUOMId 
			, intPriceUOMId 
			, intCurrencyId 
			, PriceSourceUOMId 
			, dblMarketRatio
			, dblMarketBasis 
			, dblCashPrice 
			, dblAdjustedContractPrice 
			, dblFuturePrice 
			, dblFuturePrice 
			, dblResult 
			, dblMarketFuturesResult 
			, dblResultCash1 
			, dblContractPrice 
			, dblResultCash = CASE WHEN intPricingTypeId = 6 THEN dblResult ELSE 0 END
			, dblResultBasis
			, dblShipQty = 0
			, ysnSubCurrency
			, intMainCurrencyId
			, intCent
			, dtmPlannedAvailabilityDate
			, intMarketZoneId
			, intCompanyLocationId
			, strMarketZoneCode
			, strLocationName
			, dblNoOfLots
			, dblLotsFixed
			, dblPriceWORollArb 
			, intSpreadMonthId
			, strSpreadMonth
			, dblSpreadMonthPrice
			, dblSpread
			, ysnExpired
		FROM (
			SELECT *
				, dblResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblResultBasis = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblMarketFuturesResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblResultCash1 = (ISNULL(dblMarketBasis, 0)-ISNULL(dblCash, 0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblContractPrice = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)), 0) + (ISNULL(dblFutures, 0)*ISNULL(dblContractRatio, 1))
			FROM (
				SELECT *
					, dblMarketBasis = CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, CASE WHEN ISNULL(intMarketBasisUOM, 0) = 0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END, ISNULL(dblMarketBasis1, 0)) ELSE 0 END
					, dblAdjustedContractPrice = CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0) + (ISNULL(dblCash, 0))
													ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
																ELSE CASE WHEN (case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))*ISNULL(dblRate, 0) 
																		ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) END END)
						 + CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId) * dblFutures
													ELSE CASE WHEN CASE WHEN ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId THEN dblFutures * ISNULL(dblRate, 0)
															ELSE dblFutures END END)
						 + ISNULL(dblCosts, 0) END
					, dblFuturePrice = dblFuturePrice1
					, dblOpenQty = ISNULL(CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN InTransQty
														ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, InTransQty) END), 0)
				FROM (
					SELECT DISTINCT cd.intContractHeaderId
						, cd.intContractDetailId
						, strContractOrInventoryType = 'In-transit' + '(P)'
						, cd.strContractSeq
						, cd.strEntityName
						, cd.intEntityId
						, cd.strFutureMarket
						, cd.intFutureMarketId
						, cd.strFutureMonth
						, cd.intFutureMonthId
						, cd.strCommodityCode
						, cd.intCommodityId
						, cd.strItemNo
						, cd.intItemId
						, cd.strOrgin
						, cd.intOriginId
						, cd.strPosition
						, cd.strPeriod
						, cd.strPeriodTo
						, cd.strStartDate
						, cd.strEndDate
						, cd.strPriOrNotPriOrParPriced
						, cd.intPricingTypeId
						, cd.strPricingType
						, cd.dblContractRatio
						, cd.dblContractBasis
						, dblDummyContractBasis
						, cd.dblFutures
						, cd.dblCash
						, cd.dblMarketRatio
						, cd.dblMarketBasis1
						, cd.intMarketBasisUOM
						, cd.intMarketBasisCurrencyId
						, cd.dblFuturePrice1
						, cd.intFuturePriceCurrencyId
						, cd.dblFuturesClosingPrice1
						, cd.intContractTypeId
						, cd.dblContractOriginalQty
						, InTransQty = LG.dblQuantity
						, cd.dblRate
						, cd.intCommodityUnitMeasureId
						, cd.intQuantityUOMId
						, cd.intPriceUOMId
						, cd.intCurrencyId
						, cd.PriceSourceUOMId
						, cd.dblCosts
						, cd.ysnSubCurrency
						, cd.intMainCurrencyId
						, cd.intCent
						, cd.dtmPlannedAvailabilityDate
						, cd.dblInvoicedQuantity
						, cd.intMarketZoneId
						, cd.intCompanyLocationId
						, cd.strMarketZoneCode
						, cd.strLocationName
						, cd.dblNoOfLots
						, cd.dblLotsFixed
						, cd.dblPriceWORollArb
						, dblCashPrice
						, intSpreadMonthId
						, strSpreadMonth
						, dblSpreadMonthPrice
						, dblSpread
						, ysnExpired = ysnSpreadExpired
					FROM @tblOpenContractList cd
					LEFT JOIN (
						SELECT dblQuantity = SUM(LD.dblQuantity)
							, PCT.intContractDetailId
						FROM tblLGLoad L
						JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6, 3)
						JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId AND PCT.dblQuantity > ISNULL(PCT.dblInvoicedQty, 0)
						GROUP BY PCT.intContractDetailId
					
						UNION ALL SELECT dblQuantity = SUM(LD.dblQuantity)
							, PCT.intContractDetailId
						FROM tblLGLoad L
						JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6, 3)
						JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intSContractDetailId AND PCT.dblQuantity > PCT.dblInvoicedQty
						GROUP BY PCT.intContractDetailId
					) AS LG ON LG.intContractDetailId = cd.intContractDetailId
					WHERE cd.intPricingTypeId = 2
				) t
			) t
		) t2
	
		IF ISNULL(@ysnIncludeInventoryM2M, 0) = 1
		BEGIN
			INSERT INTO @ListTransaction (intContractHeaderId
				, intContractDetailId
				, strContractOrInventoryType
				, strContractSeq
				, strEntityName
				, intEntityId
				, strFutureMarket
				, intFutureMarketId
				, strFutureMonth
				, intFutureMonthId 
				, strCommodityCode
				, intCommodityId 
				, strItemNo 
				, intItemId 
				, strOrgin 
				, intOriginId 
				, strPosition 
				, strPeriod 
				, strPeriodTo
				, strStartDate
				, strEndDate
				, strPriOrNotPriOrParPriced 
				, intPricingTypeId 
				, strPricingType 
				, dblFutures
				, dblCash
				, dblCosts
				, dblMarketBasis1
				, intMarketBasisUOMId
				, intMarketBasisCurrencyId
				, dblContractRatio
				, dblContractBasis 
				, dblDummyContractBasis
				, dblFuturePrice1 
				, intFuturePriceCurrencyId
				, dblFuturesClosingPrice1 
				, intContractTypeId
				, dblOpenQty 
				, dblRate 
				, intCommodityUnitMeasureId 
				, intQuantityUOMId 
				, intPriceUOMId 
				, intCurrencyId 
				, PriceSourceUOMId 
				, dblMarketRatio
				, dblMarketBasis 
				, dblCashPrice 
				, dblAdjustedContractPrice 
				, dblFuturesClosingPrice 
				, dblFuturePrice 
				, dblResult 
				, dblMarketFuturesResult 
				, dblResultCash1 
				, dblContractPrice 
				, dblResultCash 
				, dblResultBasis
				, dblShipQty
				, ysnSubCurrency
				, intMainCurrencyId
				, intCent
				, dtmPlannedAvailabilityDate
				, intMarketZoneId 
				, intLocationId
				, strMarketZoneCode
				, strLocationName 
				, dblNoOfLots
				, dblLotsFixed
				, dblPriceWORollArb
				, intSpreadMonthId
				, strSpreadMonth
				, dblSpreadMonthPrice
				, dblSpread
				, ysnExpired)
			SELECT DISTINCT intContractHeaderId
				, intContractDetailId 
				, strContractOrInventoryType 
				, strContractSeq 
				, strEntityName 
				, intEntityId 
				, strFutureMarket 
				, intFutureMarketId 
				, strFutureMonth 
				, intFutureMonthId 
				, strCommodityCode 
				, intCommodityId 
				, strItemNo 
				, intItemId 
				, strOrgin 
				, intOriginId 
				, strPosition 
				, strPeriod 
				, strPeriodTo
				, strStartDate
				, strEndDate
				, strPriOrNotPriOrParPriced 
				, intPricingTypeId 
				, strPricingType 
				, dblFutures
				, dblCash
				, dblCosts
				, dblMarketBasis1
				, intMarketBasisUOM
				, intMarketBasisCurrencyId
				, dblContractRatio
				, dblContractBasis 
				, dblDummyContractBasis
				, dblFuturePrice1 
				, intFuturePriceCurrencyId
				, dblFuturesClosingPrice1 
				, intContractTypeId
				, dblOpenQty 
				, dblRate 
				, intCommodityUnitMeasureId 
				, intQuantityUOMId 
				, intPriceUOMId 
				, intCurrencyId 
				, PriceSourceUOMId 
				, dblMarketRatio
				, dblMarketBasis 
				, dblCashPrice 
				, dblAdjustedContractPrice 
				, dblFuturesClosingPrice 
				, dblFuturePrice 
				, dblResult 
				, dblMarketFuturesResult 
				, dblResultCash1 
				, dblContractPrice 
				, case when intPricingTypeId = 6 THEN dblResult ELSE 0 END dblResultCash
				, dblResultBasis
				, 0 as dblShipQty
				, ysnSubCurrency
				, intMainCurrencyId
				, intCent
				, dtmPlannedAvailabilityDate
				, intMarketZoneId 
				, intCompanyLocationId 
				, strMarketZoneCode
				, strLocationName 
				, dblNoOfLots
				, dblLotsFixed
				, dblPriceWORollArb
				, intSpreadMonthId
				, strSpreadMonth
				, dblSpreadMonthPrice
				, dblSpread
				, ysnExpired
			FROM (
				SELECT *
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblResult
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblResultBasis
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblMarketFuturesResult
					, (ISNULL(dblMarketBasis, 0)-ISNULL(dblCash, 0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty1, 0))) dblResultCash1
					, ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)), 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1)) dblContractPrice
				FROM (
					SELECT *
						, CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, CASE WHEN ISNULL(intMarketBasisUOM, 0) = 0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END, ISNULL(dblMarketBasis1, 0)) ELSE 0 END dblMarketBasis
						, CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0) + (ISNULL(dblCash, 0))
							ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0
																THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
															ELSE CASE WHEN (CASE WHEN ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId
																			THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) * dblRate
																	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) END END)
								 + convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId)* dblFutures
																else case when (case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId THEN dblFutures * dblRate
																		else dblFutures END END)
								 + ISNULL(dblCosts, 0) END dblAdjustedContractPrice
						, dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, CASE WHEN ISNULL(intMarketBasisUOM, 0) = 0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END, dblFuturesClosingPrice1) as dblFuturesClosingPrice
						, dblFuturePrice1 as dblFuturePrice
						, ISNULL(CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN dblOpenQty1
															ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, dblOpenQty1) END), 0) as dblOpenQty
					FROM (
						SELECT DISTINCT cd.intContractHeaderId
							, cd.intContractDetailId
							, 'Inventory (P)' as strContractOrInventoryType
							, cd.strContractSeq
							, cd.strEntityName
							, cd.intEntityId
							, cd.strFutureMarket
							, cd.intFutureMarketId
							, cd.strFutureMonth
							, cd.intFutureMonthId
							, cd.strCommodityCode
							, cd.intCommodityId
							, cd.strItemNo
							, cd.intItemId
							, cd.strOrgin
							, cd.intOriginId
							, cd.strPosition
							, cd.strPeriod
							, cd.strPeriodTo
							, cd.strStartDate
							, cd.strEndDate
							, cd.strPriOrNotPriOrParPriced
							, cd.intPricingTypeId
							, cd.strPricingType
							, cd.dblContractRatio
							, cd.dblContractBasis
							, cd.dblDummyContractBasis
							, cd.dblFutures
							, cd.dblCash
							, cd.dblMarketRatio
							, cd.dblMarketBasis1
							, cd.intMarketBasisUOM
							, cd.intMarketBasisCurrencyId
							, cd.dblFuturePrice1
							, cd.intFuturePriceCurrencyId
							, cd.dblFuturesClosingPrice1
							, cd.intContractTypeId
							, dblLotQty dblOpenQty1
							, cd.dblRate
							, cd.intCommodityUnitMeasureId
							, cd.intQuantityUOMId
							, cd.intPriceUOMId
							, cd.intCurrencyId
							, cd.PriceSourceUOMId
							, cd.dblCosts
							, cd.dblInvoicedQuantity dblInvoiceQty
							, cd.ysnSubCurrency
							, cd.intMainCurrencyId
							, cd.intCent
							, cd.dtmPlannedAvailabilityDate
							, cd.intMarketZoneId
							, cd.intCompanyLocationId 
							, cd.strMarketZoneCode
							, cd.strLocationName
							, cd.dblNoOfLots
							, cd.dblLotsFixed
							, cd.dblPriceWORollArb
							, dblCashPrice
							, intSpreadMonthId
							, strSpreadMonth
							, dblSpreadMonthPrice
							, dblSpread
							, ysnExpired = ysnSpreadExpired
						FROM @tblOpenContractList cd
						JOIN vyuRKGetPurchaseInventory l ON cd.intContractDetailId = l.intContractDetailId
						JOIN tblICItem i ON cd.intItemId = i.intItemId AND i.strLotTracking <> 'No'						
						WHERE cd.intCommodityId = @intCommodityId
					)t
				)t1
			)t2
			WHERE strContractOrInventoryType = case when @ysnIncludeInventoryM2M = 1 THEN 'Inventory (P)' ELSE '' END
		END
		
		---- contract
		INSERT INTO @ListTransaction (intContractHeaderId
			, intContractDetailId
			, strContractOrInventoryType
			, strContractSeq
			, strEntityName
			, intEntityId
			, strFutureMarket
			, intFutureMarketId
			, strFutureMonth
			, intFutureMonthId
			, strCommodityCode
			, intCommodityId
			, strItemNo
			, intItemId
			, strOrgin
			, intOriginId
			, strPosition
			, strPeriod
			, strPeriodTo
			, strStartDate
			, strEndDate
			, strPriOrNotPriOrParPriced
			, intPricingTypeId
			, strPricingType
			, dblFutures
			, dblCash
			, dblCosts
			, dblMarketBasis1
			, intMarketBasisUOMId
			, intMarketBasisCurrencyId
			, dblContractRatio
			, dblContractBasis
			, dblDummyContractBasis
			, dblFuturePrice1
			, intFuturePriceCurrencyId
			, dblFuturesClosingPrice1
			, intContractTypeId
			, dblOpenQty
			, dblRate
			, intCommodityUnitMeasureId 
			, intQuantityUOMId 
			, intPriceUOMId 
			, intCurrencyId 
			, PriceSourceUOMId 
			, dblMarketRatio
			, dblMarketBasis 
			, dblCashPrice 
			, dblAdjustedContractPrice 
			, dblFuturesClosingPrice 
			, dblFuturePrice 
			, dblResult 
			, dblMarketFuturesResult 
			, dblResultCash1 
			, dblContractPrice 
			, dblResultCash 
			, dblResultBasis
			, ysnSubCurrency
			, intMainCurrencyId
			, intCent
			, dtmPlannedAvailabilityDate
			, dblPricedQty
			, dblUnPricedQty
			, dblPricedAmount
			, intMarketZoneId 
			, intLocationId
			, strMarketZoneCode
			, strLocationName 
			, dblNoOfLots
			, dblLotsFixed
			, dblPriceWORollArb
			, intSpreadMonthId
			, strSpreadMonth
			, dblSpreadMonthPrice
			, dblSpread
			, ysnExpired)
		SELECT DISTINCT intContractHeaderId
			, intContractDetailId 
			, strContractOrInventoryType 
			, strContractSeq 
			, strEntityName 
			, intEntityId 
			, strFutureMarket 
			, intFutureMarketId 
			, strFutureMonth 
			, intFutureMonthId 
			, strCommodityCode 
			, intCommodityId 
			, strItemNo 
			, intItemId 
			, strOrgin 
			, intOriginId 
			, strPosition 
			, strPeriod 
			, strPeriodTo
			, strStartDate
			, strEndDate
			, strPriOrNotPriOrParPriced 
			, intPricingTypeId 
			, strPricingType 
			, dblFutures
			, dblCash
			, dblCosts
			, dblMarketBasis1
			, intMarketBasisUOM
			, intMarketBasisCurrencyId
			, dblContractRatio
			, dblContractBasis 
			, dblDummyContractBasis
			, dblFuturePrice1 
			, intFuturePriceCurrencyId
			, dblFuturesClosingPrice1 
			, intContractTypeId
			, dblOpenQty 
			, dblRate 
			, intCommodityUnitMeasureId 
			, intQuantityUOMId 
			, intPriceUOMId 
			, intCurrencyId 
			, PriceSourceUOMId 
			, dblMarketRatio
			, dblMarketBasis 
			, dblCashPrice 
			, dblAdjustedContractPrice
			, dblFuturePrice 
			, dblFuturePrice 
			, dblResult 
			, dblMarketFuturesResult 
			, dblResultCash1 
			, dblContractPrice 
			, case when intPricingTypeId = 6 THEN dblResult ELSE 0 END dblResultCash
			, dblResultBasis
			, ysnSubCurrency
			, intMainCurrencyId
			, intCent
			, dtmPlannedAvailabilityDate
			, dblPricedQty
			, dblUnPricedQty
			, dblPricedAmount
			, intMarketZoneId
			, intCompanyLocationId
			, strMarketZoneCode
			, strLocationName 
			, dblNoOfLots
			, dblLotsFixed
			, dblPriceWORollArb
			, intSpreadMonthId
			, strSpreadMonth
			, dblSpreadMonthPrice
			, dblSpread
			, ysnExpired
		FROM (
			SELECT *
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblResult
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblResultBasis
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblMarketFuturesResult
				, (ISNULL(dblMarketBasis, 0)-ISNULL(dblCash, 0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) dblResultCash1
				, 0 dblContractPrice
			FROM (
				SELECT *
					, CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, CASE WHEN ISNULL(intMarketBasisUOM, 0) = 0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END, ISNULL(dblMarketBasis1, 0)) ELSE 0 END dblMarketBasis
					, CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0) + (ISNULL(dblCash, 0))
							ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
															ELSE CASE WHEN (case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId
																		THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))*ISNULL(dblRate, 0) 
																	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) END END) 
								 + CONVERT(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId)* dblFutures
															else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId THEN dblFutures*ISNULL(dblRate, 0)
																	else dblFutures END END)
								 + ISNULL(dblCosts, 0) END AS dblAdjustedContractPrice
					, dblFuturePrice1 as dblFuturePrice
					, convert(decimal(24, 6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN dblContractOriginalQty
												else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, dblContractOriginalQty) END)
						 as dblOpenQty
				FROM (
					SELECT cd.intContractHeaderId
						, cd.intContractDetailId
						, cd.strContractOrInventoryType
						, cd.strContractSeq
						, cd.strEntityName
						, cd.intEntityId
						, cd.strFutureMarket
						, cd.intFutureMarketId
						, cd.strFutureMonth
						, cd.intFutureMonthId
						, cd.strCommodityCode
						, cd.intCommodityId
						, cd.strItemNo
						, cd.intItemId
						, cd.strOrgin
						, cd.intOriginId
						, cd.strPosition
						, cd.strPeriod
						, cd.strPeriodTo
						, strStartDate
						, strEndDate
						, cd.strPriOrNotPriOrParPriced
						, cd.intPricingTypeId
						, cd.strPricingType
						, cd.dblContractRatio
						, cd.dblContractBasis
						, cd.dblDummyContractBasis
						, cd.dblCash
						, cd.dblFuturesClosingPrice1
						, cd.dblFutures
						, cd.dblMarketRatio
						, cd.dblMarketBasis1
						, cd.intMarketBasisUOM
						, cd.intMarketBasisCurrencyId
						, cd.dblFuturePrice1
						, cd.intFuturePriceCurrencyId
						, cd.intContractTypeId
						, cd.dblRate
						, cd.intCommodityUnitMeasureId
						, cd.intQuantityUOMId
						, cd.intPriceUOMId
						, cd.intCurrencyId
						, convert(int, cd.PriceSourceUOMId) PriceSourceUOMId
						, cd.dblCosts
						, cd.dblContractOriginalQty
						, LG.dblQuantity as InTransQty
						, cd.dblInvoicedQuantity
						, cd.ysnSubCurrency
						, cd.intMainCurrencyId
						, cd.intCent
						, cd.dtmPlannedAvailabilityDate
						, cd.intCompanyLocationId
						, cd.intMarketZoneId
						, cd.intContractStatusId
						, cd.dtmContractDate
						, dblPricedQty
						, dblUnPricedQty
						, dblPricedAmount
						, strMarketZoneCode
						, strLocationName
						, cd.dblNoOfLots
						, cd.dblLotsFixed
						, cd.dblPriceWORollArb
						, dblCashPrice
						, intSpreadMonthId
						, strSpreadMonth
						, dblSpreadMonthPrice
						, dblSpread
						, ysnExpired = ysnSpreadExpired
					FROM @tblOpenContractList cd
					LEFT JOIN (SELECT SUM(LD.dblQuantity)dblQuantity
									, PCT.intContractDetailId
								FROM tblLGLoad L
								JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus in(6, 3) -- 1.purchase 2.outbound
								JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId AND PCT.dblQuantity > ISNULL(PCT.dblInvoicedQty, 0)
								GROUP BY PCT.intContractDetailId
						
								UNION ALL SELECT SUM(LD.dblQuantity)dblQuantity
									, PCT.intContractDetailId
								from tblLGLoad L
								JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus in(6, 3) -- 1.purchase 2.outbound
								JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intSContractDetailId AND PCT.dblQuantity > PCT.dblInvoicedQty
								group by PCT.intContractDetailId
					) AS LG ON LG.intContractDetailId = cd.intContractDetailId
				) t
			) t where ISNULL(dblOpenQty, 0) > 0
		) t1

		SELECT *
			, dblContractPrice = ISNULL(dblContractBasis, 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1))
			, dblResult = CONVERT(DECIMAL(24, 6), ((ISNULL(dblMarketBasis, 0) - ISNULL(dblContractBasis, 0) + ISNULL(dblCosts, 0))) * ISNULL(dblResultBasis1, 0)) + CONVERT(DECIMAL(24, 6), ((ISNULL(dblFutures, 0) - ISNULL(dblFuturePrice, 0)) * ISNULL(dblMarketFuturesResult1, 0)))
			, dblResultBasis = CONVERT(DECIMAL(24, 6), ((ISNULL(dblMarketBasis, 0) - (ISNULL(dblContractBasis, 0) + ISNULL(dblCosts, 0)) - (CASE WHEN ysnExpired = 1 THEN ISNULL(dblSpread, 0) ELSE 0 END))) * ISNULL(dblOpenQty, 0)) 
			, dblMarketFuturesResult = CASE WHEN intContractTypeId = 1 THEN CONVERT(DECIMAL(24, 6), ((ISNULL(dblFuturePrice, 0) - ISNULL(dblFutures, 0)) * ISNULL(dblOpenQty, 0)))
											ELSE 0 END
			, dblResultCash = CASE WHEN strPricingType = 'Cash' THEN CONVERT(DECIMAL(24, 6), (ISNULL(dblCash, 0) - ISNULL(dblCashPrice, 0)) * ISNULL(dblResult1, 0))
									ELSE 0 END
		INTO #Temp
		FROM (
			SELECT intContractHeaderId
				, intContractDetailId
				, intTransactionId = intContractHeaderId
				, strContractOrInventoryType
				, strContractSeq
				, strEntityName
				, intEntityId
				, strFutureMarket
				, intFutureMarketId
				, intFutureMonthId
				, strFutureMonth
				, dblContractRatio
				, strCommodityCode
				, intCommodityId
				, strItemNo
				, intItemId
				, intOriginId
				, strOrgin
				, strPosition
				, strPeriod
				, strPeriodTo
				, strStartDate
				, strEndDate
				, strPriOrNotPriOrParPriced
				, case when intContractTypeId = 2 THEN - dblOpenQty
						else dblOpenQty END dblOpenQty
				, intPricingTypeId
				, strPricingType
				, convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblDummyContractBasis, 0))
											else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																	then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblDummyContractBasis, 0)) * dblRate
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblDummyContractBasis, 0)) END END) as dblDummyContractBasis
				, case when @ysnCanadianCustomer = 1 THEN dblContractBasis
					else convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
													else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))*dblRate
															else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) END END) END as dblContractBasis
				, convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
											else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																	then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))*dblRate 
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) END END) as dblCanadianContractBasis
				, case when @ysnCanadianCustomer = 1 THEN dblFutures
						else convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblFutures, 0))
					else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblFutures, 0)) * dblRate
							else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblFutures, 0)) END END) END as dblFutures
				, convert(decimal(24, 6), dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, dblCash)) as dblCash
				, dblCosts as dblCosts
				, dblMarketRatio
				, case when @ysnCanadianCustomer = 1 THEN dblMarketBasis
					else convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblMarketBasis, 0))
													else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblMarketBasis, 0)) * dblRate
															else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblMarketBasis, 0)) END END) END as dblMarketBasis
				, intMarketBasisCurrencyId
				, dblFuturePrice = CASE WHEN strPricingType = 'Basis' THEN 0 ELSE dblFuturePrice1 END
				, intFuturePriceCurrencyId
				, convert(decimal(24, 6), dblFuturesClosingPrice) dblFuturesClosingPrice
				, CONVERT(int, intContractTypeId) as intContractTypeId
				, dblAdjustedContractPrice
				, dblCashPrice as dblCashPrice
				, case when ysnSubCurrency = 1 THEN (convert(decimal(24, 6), dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, dblResultCash))) / ISNULL(intCent, 0)
						else convert(decimal(24, 6), dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, dblResultCash)) END as dblResultCash1
				, dblResult as dblResult1
				, CASE WHEN ISNULL(@ysnIncludeBasisDifferentialsInResults, 0) = 0 THEN 0 ELSE dblResultBasis END as dblResultBasis1
				, dblMarketFuturesResult as dblMarketFuturesResult1
				, intQuantityUOMId
				, intCommodityUnitMeasureId
				, intPriceUOMId
				, intCent
				, dtmPlannedAvailabilityDate
				, CONVERT(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId) * dblFutures
											else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId THEN dblFutures * dblRate
													else dblFutures END END) dblCanadianFutures
				, dblPricedQty
				, dblUnPricedQty
				, dblPricedAmount
				, intLocationId
				, intMarketZoneId
				, strMarketZoneCode
				, strLocationName
				, dblNotLotTrackedPrice
				, dblInvFuturePrice
				, dblInvMarketBasis
				, dblNoOfLots
				, dblLotsFixed
				, dblPriceWORollArb
				, intCurrencyId
				, intSpreadMonthId
				, strSpreadMonth
				, dblSpreadMonthPrice
				, dblSpread
				, ysnExpired
			FROM @ListTransaction
		) t
		ORDER BY intCommodityId, strContractSeq DESC
		
		--Derivative Entries
		IF @ysnIncludeDerivatives = 1
		BEGIN		
			INSERT INTO #Temp (strContractOrInventoryType
				, intTransactionId
				, strContractSeq
				, strEntityName
				, intEntityId
				, strCommodityCode
				, intCommodityId
				, strLocationName
				, intLocationId
				, strFutureMonth
				, intFutureMonthId
				, strFutureMarket
				, intFutureMarketId
				, dblFutures
				, dblOpenQty
				, dblInvFuturePrice
				, intCurrencyId)
			SELECT strContractOrInventoryType = CASE WHEN strNewBuySell = 'Buy' THEN 'Futures(B)' ELSE 'Futures(S)' END
				, intFutOptTransactionHeaderId
				, strInternalTradeNo
				, strBroker
				, intEntityId
				, strCommodityCode
				, intCommodityId
				, strLocationName
				, intLocationId
				, strFutureMonth
				, DER.intFutureMonthId
				, strFutureMarket
				, DER.intFutureMarketId
				, dblPrice
				, dblOpenQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(fm.intUnitMeasureId, @intQuantityUOMId,dblOpenContract * DER.dblContractSize)
				, dblInvFuturePrice = SP.dblLastSettle
				, DER.intCurrencyId
			FROM fnRKGetOpenFutureByDate (@intCommodityId, '1/1/1900', @dtmEndDate, 1) DER
			LEFT JOIN @tblGetSettlementPrice SP ON SP.intFutureMarketId = DER.intFutureMarketId AND SP.intFutureMonthId = DER.intFutureMonthId
			LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = DER.intFutureMarketId
			WHERE intCommodityId = @intCommodityId 
				AND ysnExpired = 0
				AND intInstrumentTypeId = 1
				AND dblOpenContract <> 0
				AND ISNULL(ysnPreCrush, 0) = CASE WHEN ISNULL(@ysnIncludeCrushDerivatives, 0) = 1 THEN ISNULL(ysnPreCrush, 0) ELSE 0 END
		END


		DECLARE @strM2MCurrency NVARCHAR(20)
			, @dblRateConfiguration NUMERIC(18, 6)

		SELECT TOP 1 @strM2MCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId

		SELECT TOP 1 @dblRateConfiguration = dblRate
		FROM vyuSMForex
		WHERE intFromCurrencyId = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'CAD')
			AND intToCurrencyId = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD')
			AND dbo.fnDateLessThanEquals(dtmValidFromDate, GETDATE()) = 1
		ORDER BY dtmValidFromDate DESC

		DECLARE @intCurrencyExchangeRateId INT
		SELECT TOP 1 @intCurrencyExchangeRateId = intCurrencyExchangeRateId
		FROM tblSMCurrencyExchangeRate CER
		INNER JOIN tblSMCurrency Cur1 ON CER.intFromCurrencyId = Cur1.intCurrencyID
		INNER JOIN tblSMCurrency Cur2 ON CER.intToCurrencyId = Cur2.intCurrencyID
		WHERE Cur1.strCurrency = 'CAD' AND Cur2.strCurrency = 'USD'

		---------------------------------
		SELECT intM2MHeaderId = @intM2MHeaderId
			, intContractHeaderId
			, intContractDetailId
			, strContractOrInventoryType
			, strContractSeq
			, strEntityName
			, intEntityId
			, intFutureMarketId
			, strFutureMarket
			, intFutureMonthId
			, strFutureMonth
			, dblOpenQty dblOpenQty
			, strCommodityCode
			, intCommodityId
			, intItemId
			, strItemNo
			, strOrgin
			, strPosition
			, strPeriod
			, strPeriodTo
			, strStartDate
			, strEndDate
			, strPriOrNotPriOrParPriced
			, intPricingTypeId
			, strPricingType
			, dblContractRatio
			, dblContractBasis
			, dblFutures
			, dblCash
			, dblCosts
			, dblMarketBasis
			, dblMarketRatio
			, dblFuturePrice
			, intContractTypeId
			, dblAdjustedContractPrice
			, dblCashPrice
			, dblMarketPrice
			, dblResultBasis
			, dblResultCash
			, dblContractPrice
			, intQuantityUOMId
			, intCommodityUnitMeasureId
			, intPriceUOMId
			, intCent
			, dtmPlannedAvailabilityDate
			, dblPricedQty
			, dblUnPricedQty
			, dblPricedAmount
			, intLocationId
			, intMarketZoneId
			, strMarketZoneCode
			, strLocationName 
			, dblResult = case when strPricingType = 'Cash' THEN 
									ROUND(dblResultCash, 2) 
								else 
									ROUND((dblMarketPrice - dblAdjustedContractPrice) * dblOpenQty, 2)
						 END
			, dblMarketFuturesResult = CASE WHEN strContractOrInventoryType = 'Inventory' THEN 0
											WHEN strPricingType = 'Basis' THEN 0
											ELSE ((ISNULL(dblFuturePrice, 0) - ISNULL(dblActualFutures, 0) + (CASE WHEN ysnExpired = 1 THEN ISNULL(dblSpread, 0) ELSE 0 END)) * dblOpenQty)
											END
			, dblResultRatio = (CASE WHEN dblContractRatio <> 0 AND dblMarketRatio <> 0 THEN ((dblMarketPrice - dblAdjustedContractPrice) * dblOpenQty)
										- (CASE WHEN strContractOrInventoryType = 'Inventory' THEN 0
												WHEN strPricingType = 'Basis' THEN 0
												ELSE ((ISNULL(dblFuturePrice, 0) - ISNULL(dblActualFutures, 0) + (CASE WHEN ysnExpired = 1 THEN ISNULL(dblSpread, 0) ELSE 0 END)) * dblOpenQty) END)
										- dblResultBasis
									WHEN strContractOrInventoryType = 'Inventory' THEN
										0
									ELSE 0 END)
			, intSpreadMonthId
			, strSpreadMonth
			, dblSpreadMonthPrice
			, dblSpread
		INTO #tmpM2MTransaction
		FROM (
			SELECT intContractHeaderId
				, intContractDetailId
				, strContractOrInventoryType
				, strContractSeq
				, strEntityName
				, intEntityId
				, intFutureMarketId
				, strFutureMarket
				, intFutureMonthId
				, strFutureMonth
				, dblOpenQty
				, strCommodityCode
				, intCommodityId
				, intItemId
				, strItemNo
				, strOrgin
				, strPosition
				, strPeriod
				, strPeriodTo
				, strStartDate
				, strEndDate
				, strPriOrNotPriOrParPriced
				, intPricingTypeId
				, strPricingType
				, dblContractRatio = ISNULL(dblContractRatio, 0)
				--Contract Basis
				, dblContractBasis = (CASE WHEN strPricingType ! = 'HTA'
											THEN (CASE WHEN @ysnCanadianCustomer = 1
														THEN (CASE WHEN intCurrencyId = @intCurrencyId 
																-- CONTRACT CURRENCY = M2M CURRENCY
																THEN dblContractBasis
																ELSE ISNULL(dblContractBasis, 0) * dblRateCT
																END
															  )
														ELSE dblContractBasis END)
										ELSE 0 END)
				--Contract Futures
				, dblActualFutures = dblCalculatedFutures
				, dblFutures = (CASE WHEN strPricingType = 'Basis' AND strPriOrNotPriOrParPriced = 'Partially Priced' THEN dblFutures --((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * dblConvertedFuturePrice)) / dblNoOfLots
								WHEN strPricingType = 'Basis' THEN ISNULL(dblFutures, 0)
								WHEN strPricingType = 'Priced' THEN dblCalculatedFutures
								ELSE dblCalculatedFutures END)
				, dblCash --Contract Cash
				, dblCosts = ABS(dblCosts)
				--Market Basis
				, dblMarketBasis = (CASE WHEN strPricingType ! = 'HTA' THEN
										CASE WHEN @ysnCanadianCustomer = 1 
											THEN ISNULL(dblMarketBasis, 0) * dblRateMB
										ELSE ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0) END
									ELSE 0 END)
				, dblMarketRatio
				, dblFuturePrice = dblConvertedFuturePrice --Market Futures
				, intContractTypeId
				, dblAdjustedContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 
													THEN (CASE WHEN intCurrencyId = @intCurrencyId
															-- CONTRACT CURRENCY = M2M CURRENCY
															THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts, 0)
															ELSE  (ISNULL(dblContractBasis, 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts, 0))
																			* dblRateCT
															END
														)
												ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts, 0) END)
				, dblCashPrice
				--Market Price
				, dblMarketPrice = CASE WHEN @ysnCanadianCustomer = 1 
											THEN (CASE WHEN strMBCurrency = strFPCurrency
													THEN  (ISNULL(dblMarketBasis, 0) + (dblFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0))
																	* dblRateMB
													ELSE 
														(ISNULL(dblMarketBasis, 0) * dblRateMB) + 
														((dblFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0) * dblRateFP)
													END
												  )
											ELSE ISNULL(dblMarketBasis, 0) + (ISNULL(dblConvertedFuturePrice, 0) * CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE ISNULL(dblMarketRatio, 0) END) + ISNULL(dblCashPrice, 0) END
				, dblResultBasis = dblResultBasis
				, dblResultCash
				--Contract Price
				, dblContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 
											THEN (CASE WHEN intCurrencyId = @intCurrencyId
													-- CONTRACT CURRENCY = M2M CURRENCY
													THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0)
													ELSE  (ISNULL(dblContractBasis, 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0))
																	* dblRateCT
													END
												)
										ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) END)
				, intQuantityUOMId
				, intCommodityUnitMeasureId
				, intPriceUOMId
				, t.intCent
				, dtmPlannedAvailabilityDate
				, dblPricedQty
				, dblUnPricedQty
				, dblPricedAmount
				, intLocationId
				, intMarketZoneId
				, strMarketZoneCode
				, strLocationName
				, intSpreadMonthId
				, strSpreadMonth
				, dblSpreadMonthPrice
				, dblSpread
				, t.ysnExpired
			FROM (
				SELECT t.*
					, dblCalculatedFutures = ISNULL((CASE WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Unpriced' THEN dblConvertedFuturePrice
															WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Partially Priced'
															THEN ((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * dblConvertedFuturePrice)) / dblNoOfLots
															ELSE 
																CASE WHEN @ysnCanadianCustomer = 1 
																	THEN 
																		CASE WHEN intCurrencyId = @intCurrencyId	
																			THEN ISNULL(dblFutures, 0)
																			ELSE ISNULL(dblFutures, 0) * dblRateCT END 
																	ELSE ISNULL(dblFutures, 0) END
															END), 0)
				FROM (
					SELECT #Temp.*
						-- IF RATE TYPE IS CONTRACT = CHECK CONTRACT FOREX. IF NO VALUE, USE SYSTEM WIDE FOREX INSTEAD

						-- RATE FOR FUTURE PRICE (SETTLEMENT PRICE) CURRENCY TO M2M CURRENCY 
						, dblRateFP = CASE WHEN FPCurrency.intCurrencyID = @intCurrencyId
									  THEN 1
									  ELSE
										  CASE WHEN @strRateType = 'Contract' 
										  THEN
											ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
													WHERE dtmFXValidFrom <= @dtmCurrentDay AND dtmFXValidTo >= @dtmCurrentDay
														AND ISNULL(dblRate, 0) <> 0
														AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId FROM tblSMCurrencyExchangeRate forex
																						WHERE forex.intFromCurrencyId = FPCurrency.intCurrencyID AND forex.intToCurrencyId = @intCurrencyId)
														AND intContractDetailId = #Temp.intContractDetailId), dbo.fnRKGetCurrencyConvertion(FPCurrency.intCurrencyID, @intCurrencyId))
											ELSE dbo.fnRKGetCurrencyConvertion(FPCurrency.intCurrencyID, @intCurrencyId) END
									  END

						-- RATE FOR MARKET BASIS (BASIS ENTRY) CURRENCY TO M2M CURRENCY
						, dblRateMB = CASE WHEN MBCurrency.intCurrencyID = @intCurrencyId
									  THEN 1
									  ELSE
										  CASE WHEN @strRateType = 'Contract' 
										  THEN
											ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
													WHERE dtmFXValidFrom <= @dtmCurrentDay AND dtmFXValidTo >= @dtmCurrentDay
														AND ISNULL(dblRate, 0) <> 0
														AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId FROM tblSMCurrencyExchangeRate forex
																						WHERE forex.intFromCurrencyId = MBCurrency.intCurrencyID AND forex.intToCurrencyId = @intCurrencyId)
														AND intContractDetailId = #Temp.intContractDetailId), dbo.fnRKGetCurrencyConvertion(MBCurrency.intCurrencyID, @intCurrencyId))
											ELSE dbo.fnRKGetCurrencyConvertion(MBCurrency.intCurrencyID, @intCurrencyId) END
									  END

						-- RATE FOR CONTRACT CURRENCY TO M2M CURRENCY
						, dblRateCT = CASE WHEN intCurrencyId = @intCurrencyId
									  THEN 1
									  ELSE
										  CASE WHEN @strRateType = 'Contract' 
										  THEN
											ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
													WHERE dtmFXValidFrom <= @dtmCurrentDay AND dtmFXValidTo >= @dtmCurrentDay
														AND ISNULL(dblRate, 0) <> 0
														AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId FROM tblSMCurrencyExchangeRate forex
																						WHERE forex.intFromCurrencyId = Currency.intCurrencyID AND forex.intToCurrencyId = @intCurrencyId)
														AND intContractDetailId = #Temp.intContractDetailId), dbo.fnRKGetCurrencyConvertion(Currency.intCurrencyID, @intCurrencyId))
											ELSE dbo.fnRKGetCurrencyConvertion(Currency.intCurrencyID, @intCurrencyId) END
									  END

						, dblConvertedFuturePrice = (CASE WHEN @ysnCanadianCustomer = 1
															-- SAME CURRENCY (NO CONVERSION)
															THEN (CASE WHEN FPCurrency.intCurrencyID = @intCurrencyId THEN ISNULL(dblFuturePrice, 0)
																	-- DIFFERENT CURRENCY (WITH CONVERSION)
																	-- IF RATE TYPE IS CONTRACT = CHECK CONTRACT FOREX. IF NO VALUE, USE SYSTEM WIDE FOREX INSTEAD
																	ELSE (CASE WHEN @strRateType = 'Contract' THEN ISNULL(dblFuturePrice, 0) *
																			ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
																					WHERE dtmFXValidFrom <= @dtmCurrentDay AND dtmFXValidTo >= @dtmCurrentDay
																						AND ISNULL(dblRate, 0) <> 0
																						AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId FROM tblSMCurrencyExchangeRate forex
																														WHERE forex.intFromCurrencyId = FPCurrency.intCurrencyID AND forex.intToCurrencyId = @intCurrencyId)
																						AND intContractDetailId = #Temp.intContractDetailId), dbo.fnRKGetCurrencyConvertion(FPCurrency.intCurrencyID, @intCurrencyId))
																			ELSE ISNULL(dblFuturePrice, 0) * dbo.fnRKGetCurrencyConvertion(FPCurrency.intCurrencyID, @intCurrencyId) END)
																	END
																)
															ELSE ISNULL(dblFuturePrice, 0) END)
												
						, strMainCurrency = Currency.strCurrency
						, strMBCurrency = MBCurrency.strCurrency
						, strFPCurrency = FPCurrency.strCurrency
					FROM #Temp
					LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = #Temp.intCurrencyId
					LEFT JOIN tblSMCurrency MBCurrency ON MBCurrency.intCurrencyID = #Temp.intMarketBasisCurrencyId
					LEFT JOIN tblSMCurrency FPCurrency ON FPCurrency.intCurrencyID = #Temp.intFuturePriceCurrencyId
				) t
			) t
			WHERE dblOpenQty <> 0 AND intContractHeaderId is not NULL 
	
			UNION ALL SELECT intContractHeaderId = intTransactionId
				, intContractDetailId
				, strContractOrInventoryType
				, strContractSeq
				, strEntityName
				, intEntityId
				, intFutureMarketId
				, strFutureMarket
				, intFutureMonthId
				, strFutureMonth
				, dblOpenQty
				, strCommodityCode
				, intCommodityId
				, intItemId
				, strItemNo
				, strOrgin
				, strPosition
				, strPeriod
				, strPeriodTo
				, strStartDate
				, strEndDate
				, strPriOrNotPriOrParPriced
				, intPricingTypeId
				, strPricingType
				, dblContractRatio
				, dblContractBasis = (CASE WHEN strPricingType ! = 'HTA'
											THEN (CASE WHEN ISNULL(@ysnIncludeBasisDifferentialsInResults, 0) = 0 THEN 0
													ELSE (CASE WHEN @ysnCanadianCustomer = 1 THEN dblCanadianFutures + dblCanadianContractBasis - ISNULL(dblFutures, 0)
															ELSE dblContractBasis END) END)
										ELSE 0 END)
				, dblActualFutures = dblFutures
				, dblFutures = (CASE WHEN strPricingType = 'Basis' THEN 0
									ELSE dblFutures END)
				, dblCash = ISNULL(dblCash, 0)
				, dblCosts = ABS(ISNULL(dblCosts, 0))
				, dblMarketBasis = ISNULL(dblInvMarketBasis, 0)
				, dblMarketRatio = ISNULL(dblMarketRatio, 0)
				, dblFuturePrice = ISNULL(dblInvFuturePrice, 0)
				, intContractTypeId
				, dblAdjustedContractPrice = CASE WHEN strContractOrInventoryType like 'Futures%' THEN dblFutures ELSE ISNULL(dblCash, 0) END
				, dblCashPrice = ISNULL(dblCashPrice, 0)
				, dblMarketPrice = ISNULL(dblInvMarketBasis, 0) + ISNULL(dblInvFuturePrice, 0) + ISNULL(dblCashPrice, 0)
				, dblResultBasis = 0
				, dblResultCash = ROUND((ISNULL(dblCashPrice, 0) - ISNULL(dblCash, 0)) * Round(dblOpenQty, 2), 2)
				, dblContractPrice = CASE WHEN strContractOrInventoryType like 'Futures%' THEN dblFutures ELSE ISNULL(dblCash, 0) END
				, intQuantityUOMId
				, intCommodityUnitMeasureId
				, intPriceUOMId
				, intCent
				, dtmPlannedAvailabilityDate
				, dblPricedQty
				, dblUnPricedQty
				, dblPricedAmount
				, intLocationId
				, intMarketZoneId
				, strMarketZoneCode
				, strLocationName 
				, intSpreadMonthId
				, strSpreadMonth
				, dblSpreadMonthPrice
				, dblSpread
				, ysnExpired
			FROM #Temp 
			WHERE dblOpenQty <> 0 AND intContractHeaderId IS NULL
		)t 
		ORDER BY intContractHeaderId DESC

		-- Counter Party Exposure
		SELECT DISTINCT trans.*
			, strProducer = (CASE WHEN ISNULL(ysnClaimsToProducer, 0) = 1 THEN e.strName ELSE NULL END)
			, intProducerId = (CASE WHEN ISNULL(ysnClaimsToProducer, 0) = 1 THEN ch.intProducerId ELSE NULL END)
		INTO #tmpCPE
		FROM #tmpM2MTransaction trans
		JOIN tblCTContractDetail ch ON ch.intContractHeaderId = trans.intContractHeaderId
		LEFT JOIN tblEMEntity e ON e.intEntityId = ch.intProducerId
	
		DECLARE @tmpCPEDetail TABLE(intM2MHeaderId INT
			, intContractHeaderId INT
			, strContractSeq NVARCHAR(100)
			, strEntityName NVARCHAR(100)
			, intEntityId INT
			, dblM2M NUMERIC(24, 10)
			, dblFixedPurchaseVolume NUMERIC(24, 10)
			, dblUnfixedPurchaseVolume NUMERIC(24, 10)
			, dblTotalCommittedVolume NUMERIC(24, 10)
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
			, dblTotalCommittedValue NUMERIC(24, 10))

		IF (ISNULL(@ysnByProducer, 0) = 0)
		BEGIN
			INSERT INTO @tmpCPEDetail (intM2MHeaderId
				, intContractHeaderId
				, strContractSeq
				, strEntityName
				, intEntityId
				, dblM2M
				, dblFixedPurchaseVolume
				, dblUnfixedPurchaseVolume
				, dblTotalCommittedVolume
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
				, dblTotalCommittedValue)
			SELECT intM2MHeaderId = @intM2MHeaderId
				, intContractHeaderId
				, strContractSeq
				, strEntityName
				, intEntityId
				, dblM2M
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
				, dblTotalCommittedValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
			FROM (
				SELECT fd.intContractHeaderId
					, fd.strContractSeq
					, fd.strEntityName
					, e.intEntityId
					, fd.dblOpenQty
					, dblM2M = ISNULL(dblResult, 0)
					, strPriOrNotPriOrParPriced = (CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced'
														WHEN ISNULL(strPriOrNotPriOrParPriced, '') = '' THEN 'Priced'
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
																											, fd.dblOpenQty * ((ISNULL(fd.dblContractBasis, 0)) + (ISNULL(fd.dblFuturePrice, 0)))))
				FROM #tmpCPE fd
				JOIN tblAPVendor e ON e.intEntityId = fd.intEntityId
				WHERE strContractOrInventoryType IN ('Contract(P)', 'In-transit(P)', 'Inventory (P)')
			) t
		END
		ELSE
		BEGIN
			INSERT INTO @tmpCPEDetail (intM2MHeaderId
				, intContractHeaderId
				, strContractSeq
				, strEntityName
				, intEntityId
				, dblM2M
				, dblFixedPurchaseVolume
				, dblUnfixedPurchaseVolume
				, dblTotalCommittedVolume
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
				, dblTotalCommittedValue)
			SELECT intM2MHeaderId = @intM2MHeaderId
				, intContractHeaderId
				, strContractSeq
				, strEntityName
				, intEntityId
				, dblM2M
				, dblFixedPurchaseVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END)
				, dblUnfixedPurchaseVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
				, dblTotalCommittedVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
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
				, dblTotalCommittedValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
			FROM(
				SELECT fd.intContractHeaderId
					, fd.strContractSeq
					, strEntityName = ISNULL(fd.strProducer, fd.strEntityName)
					, intEntityId = ISNULL(fd.intProducerId, fd.intEntityId)
					, fd.dblOpenQty
					, dblM2M = ISNULL(dblResult, 0)
					, strPriOrNotPriOrParPriced = (CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced'
							WHEN ISNULL(strPriOrNotPriOrParPriced, '') = '' THEN 'Priced'
							WHEN strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced'
							ELSE strPriOrNotPriOrParPriced END)
					, dblPValueQty = 0.0
					, dblPContractBasis = ISNULL(fd.dblContractBasis, 0)
					, dblPFutures = ISNULL(fd.dblFutures, 0)
					, dblQtyPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
															, fd.intCommodityUnitMeasureId
															, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																										, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																										, fd.dblOpenQty * (ISNULL(fd.dblContractBasis, 0) + (select top 1 isnull(dblFuturePrice,0) from #tblSettlementPrice where intContractDetailId = fd.intContractDetailId))))
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
																										, fd.dblOpenQty * (ISNULL(fd.dblContractBasis, 0) + (select top 1 isnull(dblFuturePrice,0) from #tblSettlementPrice where intContractDetailId = fd.intContractDetailId))))
				FROM #tmpCPE fd
				WHERE strContractOrInventoryType IN ('Contract(P)', 'In-transit(P)', 'Inventory (P)')
			) t
		END

		;
		WITH
		generated_data
		AS
		(
			SELECT intM2MHeaderId
				, intContractHeaderId
				, strContractSeq
				, strEntityName
				, intEntityId AS intVendorId
				, dblM2M AS dblMToM
				, dblFixedPurchaseVolume
				, dblUnfixedPurchaseVolume
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
				, dblTotalCommittedVolume
				, dblTotalCommittedValue
			FROM @tmpCPEDetail
		)

		-- COMPUTE GENERATED DATA

		SELECT 
			strEntityName VendorName
			, strRiskIndicator Rating
			, FixedTransactionVolume  = CONVERT(NUMERIC(16, 2), dblFixedPurchaseVolume) 
			, UnfixedTransactionVolume = CONVERT(NUMERIC(16,2),dblUnfixedPurchaseVolume)
			, TotalCommittedVolume = CONVERT(NUMERIC(16, 2), dblTotalCommittedVolume) 
			, FixedTransactionValue = CONVERT(NUMERIC(16, 2), dblFixedPurchaseValue) 
			, UnfixedTransactionValue = CONVERT(NUMERIC(16, 2), dblUnfixedPurchaseValue) 
			, TotalCommittedValue = CONVERT(NUMERIC(16, 2), dblTotalCommittedValue) 
			, [% of Koninklijke Douwe Egberts B.V. Spend] = CONVERT(NUMERIC(16, 2), dblTotalSpend) 
			, dblShareWithSupplier [% of Koninklijke Douwe Egberts B.V. Share With Supplier]
			, dblMToM M2M
			, PotentialAdditionalVolume = CASE WHEN (ISNULL(dblPotentialAdditionalVolume, 0) - ISNULL(dblTotalCommittedVolume, 0)) < 0 THEN 0
												ELSE (ISNULL(dblPotentialAdditionalVolume, 0) - ISNULL(dblTotalCommittedVolume, 0)) END 
		FROM (
			SELECT strEntityName
				, intEntityId
				, intM2MHeaderId
				, strRiskIndicator
				, dblFixedPurchaseVolume
				, dblUnfixedPurchaseVolume
				, dblTotalCommittedVolume
				, dblFixedPurchaseValue
				, dblUnfixedPurchaseValue
				, dblTotalCommittedValue
				, dblTotalSpend = CONVERT(NUMERIC(16, 2), dblTotalSpend)
				, dblShareWithSupplier = CONVERT(NUMERIC(16, 2), dblShareWithSupplier)
				, dblMToM
				, dblCompanyExposurePercentage
				, a = (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
				, b = (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage
				, dblPotentialAdditionalVolume = CASE WHEN CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END > dblCompanyExposurePercentage THEN 0
													WHEN CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END > dblSupplierSalesPercentage THEN 0
													WHEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
														<= (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage
														THEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
													ELSE (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage END
			FROM (
				SELECT strEntityName
					, intEntityId
					, intM2MHeaderId
					, strRiskIndicator
					, dblFixedPurchaseVolume
					, dblUnfixedPurchaseVolume
					, dblTotalCommittedVolume
					, dblFixedPurchaseValue
					, dblUnfixedPurchaseValue
					, dblTotalCommittedValue
					, dblTotalSpend = (ISNULL(dblTotalCommittedValue, 0)/ SUM(CASE WHEN ISNULL(dblTotalCommittedValue, 0) = 0 THEN 1 ELSE dblTotalCommittedValue END) OVER (PARTITION BY intM2MHeaderId)) * 100
					, dblShareWithSupplier = (CASE WHEN ISNULL(dblRiskTotalBusinessVolume, 0) = 0 THEN 0 ELSE ISNULL(dblTotalCommittedVolume, 0) / dblRiskTotalBusinessVolume END) * 100
					, dblMToM
					, dblCompanyExposurePercentage
					, dblSupplierSalesPercentage
				FROM (
					SELECT strEntityName
						, intEntityId
						, intM2MHeaderId
						, dblFixedPurchaseVolume
						, dblUnfixedPurchaseVolume
						, dblTotalCommittedVolume = dblFixedPurchaseVolume + dblUnfixedPurchaseVolume
						, dblFixedPurchaseValue
						, dblUnfixedPurchaseValue
						, dblTotalCommittedValue = dblFixedPurchaseValue + dblUnfixedPurchaseValue
						, dblMToM
						, strRiskIndicator
						, intRiskUnitOfMeasureId
						, dblRiskTotalBusinessVolume
						, dblCompanyExposurePercentage
						, dblSupplierSalesPercentage
					FROM (
						SELECT strEntityName
							, intEntityId
							, intM2MHeaderId
							, dblFixedPurchaseVolume = SUM(dblFixedPurchaseVolume)
							, dblUnfixedPurchaseVolume = SUM(dblUnfixedPurchaseVolume)
							, dblFixedPurchaseValue = SUM(dblFixedPurchaseValue)
							, dblUnfixedPurchaseValue = SUM(dblUnfixedPurchaseValue)
							, dblMToM = SUM(dblMToM)
							, strRiskIndicator
							, dblRiskTotalBusinessVolume
							, intRiskUnitOfMeasureId
							, dblCompanyExposurePercentage
							, dblSupplierSalesPercentage
						FROM (
							SELECT CPE.*
								, strRiskIndicator
								, dblRiskTotalBusinessVolume = dbo.fnCTConvertQuantityToTargetCommodityUOM(toUOM.intCommodityUnitMeasureId
																				, CASE WHEN ISNULL(fromUOM.intCommodityUnitMeasureId, 0) = 0 THEN toUOM.intCommodityUnitMeasureId ELSE fromUOM.intCommodityUnitMeasureId END
																				, ISNULL(dblRiskTotalBusinessVolume, 0.00))
								, intRiskUnitOfMeasureId
								, dblCompanyExposurePercentage = ROUND(ISNULL(dblCompanyExposurePercentage, 0.00), 2)
								, dblSupplierSalesPercentage = ROUND(ISNULL(dblSupplierSalesPercentage, 0.00), 2)
								, intEntityId
							FROM generated_data CPE
							JOIN tblRKM2MHeader M2M ON M2M.intM2MHeaderId = CPE.intM2MHeaderId
							JOIN tblAPVendor e ON e.intEntityId = CPE.intVendorId
							LEFT JOIN tblICCommodityUnitMeasure fromUOM ON M2M.intCommodityId = fromUOM.intCommodityId AND fromUOM.intUnitMeasureId = M2M.intQtyUOMId
							LEFT JOIN tblICCommodityUnitMeasure toUOM ON M2M.intCommodityId = toUOM.intCommodityId AND toUOM.intUnitMeasureId = e.intRiskUnitOfMeasureId
							LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
						) t1
						GROUP BY strEntityName
							, strRiskIndicator
							, dblRiskTotalBusinessVolume
							, intRiskUnitOfMeasureId
							, dblCompanyExposurePercentage
							, dblSupplierSalesPercentage
							, intEntityId
							, intM2MHeaderId
					)t2
				)t2
			)t3
		)t4

END TRY
	
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH