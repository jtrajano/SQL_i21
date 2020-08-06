CREATE PROCEDURE [dbo].[uspRKGenerateM2M]
	@intM2MHeaderId INT OUTPUT
	, @intCommodityId INT = NULL
	, @intM2MTypeId INT
	, @intM2MBasisId INT
	, @intFutureSettlementPriceId INT
	, @intQuantityUOMId INT
	, @intPriceUOMId INT
	, @intCurrencyId INT
	, @dtmEndDate DATETIME
	, @strRateType NVARCHAR(200)	
	, @intLocationId INT = NULL
	, @intMarketZoneId INT = NULL
	, @ysnByProducer BIT = NULL
	, @intCompanyId INT = NULL
	, @dtmPostDate DATETIME = NULL
	, @dtmReverseDate DATETIME = NULL
	, @dtmLastReversalDate DATETIME = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

--DECLARE
--@intM2MHeaderId INT = NULL
--	, @intCommodityId INT = 4
--	, @intM2MTypeId INT = 1
--	, @intM2MBasisId INT = 17
--	, @intFutureSettlementPriceId INT = 67
--	, @intQuantityUOMId INT = 3
--	, @intPriceUOMId INT = 3
--	, @intCurrencyId INT = 3
--	, @dtmEndDate DATETIME = '2019-12-31T00:00:00'
--	, @strRateType NVARCHAR(200) = 'Contract'
--	, @intLocationId INT = NULL
--	, @intMarketZoneId INT = NULL
--	, @ysnByProducer BIT = 0
--	, @intCompanyId INT = NULL
--	, @dtmPostDate DATETIME = NULL
--	, @dtmReverseDate DATETIME = NULL
--	, @dtmLastReversalDate DATETIME = NULL

	DECLARE @ErrMsg NVARCHAR(MAX)
		, @intDPRHeaderId INT

	DECLARE @strM2MView NVARCHAR(50)
		, @intMarkExpiredMonthPositionId INT
		, @strRecordName NVARCHAR(50)
		, @ysnIncludeBasisDifferentialsInResults BIT
		, @dtmPriceDate DATETIME
		, @dtmSettlemntPriceDate DATETIME
		, @strLocationName NVARCHAR(200)
		, @ysnIncludeInventoryM2M BIT
		, @ysnEnterForwardCurveForMarketBasisDifferential BIT
		, @ysnCanadianCustomer BIT
		, @intDefaultCurrencyId int
		, @ysnIncludeDerivatives BIT
		, @ysnIncludeCrushDerivatives BIT
		, @ysnIncludeInTransitM2M BIT
		, @strEvaluationBy NVARCHAR(50)
		, @strEvaluationByZone NVARCHAR(50)
		, @strM2MType NVARCHAR(50)

	SELECT TOP 1 @strM2MView = strM2MView
		, @intMarkExpiredMonthPositionId = intMarkExpiredMonthPositionId
		, @ysnIncludeBasisDifferentialsInResults = ysnIncludeBasisDifferentialsInResults
		, @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential
		, @ysnIncludeInventoryM2M = ysnIncludeInventoryM2M
		, @ysnCanadianCustomer = ISNULL(ysnCanadianCustomer, 0)
		, @intMarkExpiredMonthPositionId = intMarkExpiredMonthPositionId
		, @ysnIncludeDerivatives = ysnIncludeDerivatives
		, @ysnIncludeCrushDerivatives = ysnIncludeCrushDerivatives
		, @ysnIncludeInTransitM2M = ysnIncludeInTransitM2M
		, @strEvaluationBy = strEvaluationBy
		, @strEvaluationByZone = strEvaluationByZone
	FROM tblRKCompanyPreference

	SELECT TOP 1 @dtmPriceDate = dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId = @intM2MBasisId
	SELECT TOP 1 @dtmSettlemntPriceDate = dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId = @intFutureSettlementPriceId
	SELECT TOP 1 @strLocationName = strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intLocationId
	SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
	SELECT TOP 1 @strM2MType = strType FROM tblRKM2MType WHERE intM2MTypeId = @intM2MTypeId

	SET @dtmEndDate = LEFT(CONVERT(VARCHAR, @dtmEndDate, 101), 10)

	IF (@intCommodityId = 0) SET @intCommodityId = NULL
	IF (@intLocationId = 0) SET @intLocationId = NULL
	IF (@intMarketZoneId = 0) SET @intMarketZoneId = NULL
	IF (ISNULL(@intM2MHeaderId, 0) = 0) SET @intM2MHeaderId = NULL
	
	IF (ISNULL(@intM2MHeaderId, 0) = 0)
	BEGIN		
		EXEC uspSMGetStartingNumber 133, @strRecordName OUTPUT

		INSERT INTO tblRKM2MHeader(strRecordName
			, intCommodityId
			, intM2MTypeId
			, intM2MBasisId
			, intFutureSettlementPriceId
			, intPriceUOMId
			, intQtyUOMId
			, intCurrencyId
			, dtmEndDate
			, strRateType
			, intLocationId
			, intMarketZoneId
			, ysnByProducer
			, dtmPostDate
			, dtmReverseDate
			, dtmLastReversalDate
			, ysnPosted
			, dtmCreatedDate
			, dtmUnpostDate
			, strBatchId
			, intCompanyId)
		SELECT strRecordName = @strRecordName
			, intCommodityId = @intCommodityId
			, intM2MTypeId = @intM2MTypeId
			, intM2MBasisId = @intM2MBasisId
			, intFutureSettlementPriceId = @intFutureSettlementPriceId
			, intPriceUOMId = @intPriceUOMId
			, intQtyUOMId = @intQuantityUOMId
			, intCurrencyId = @intCurrencyId
			, dtmEndDate = @dtmEndDate
			, strRateType = @strRateType
			, intLocationId = @intLocationId
			, intMarketZoneId = @intMarketZoneId
			, ysnByProducer = @ysnByProducer
			, dtmPostDate = @dtmPostDate
			, dtmReverseDate = @dtmReverseDate
			, dtmLastReversalDate = @dtmLastReversalDate
			, ysnPosted = CAST(0 AS BIT)
			, dtmCreatedDate = GETDATE()
			, dtmUnpostDate = NULL
			, strBatchId = NULL
			, intCompanyId = NULL

		SET @intM2MHeaderId = SCOPE_IDENTITY()
	END

	IF (@strM2MView = 'View 1 - Standard')
	BEGIN
		-- VALIDATE IF REQUIRED
		IF (@intMarkExpiredMonthPositionId = 1 OR @intMarkExpiredMonthPositionId = 3)
		BEGIN
			IF (@intMarkExpiredMonthPositionId = 1)
			BEGIN
				INSERT INTO tblRKM2MValidateError(intM2MHeaderId
					, intContractDetailId
					, intContractHeaderId
					, intFutOptTransactionHeaderId
					, strLocationName
					, strCommodityCode
					, strContractType
					, strContractNumber
					, strEntityName
					, strItemNo
					, strPricingType
					, strFutureMonth
					, strFutureMarket
					, dtmLastTradingDate
					, strPhysicalOrFuture
					, strErrorMsg)
				SELECT @intM2MHeaderId
					, CD.intContractDetailId
					, CH.intContractHeaderId
					, intFutOptTransactionHeaderId = NULL
					, CL.strLocationName
					, CY.strCommodityCode
					, TP.strContractType strContractType
					, strContractNumber = CH.strContractNumber + '-' + convert(NVARCHAR(10), CD.intContractSeq)
					, EY.strName strEntityName
					, IM.strItemNo
					, PT.strPricingType
					, MO.strFutureMonth
					, strFutureMarket = FM.strFutMarketName
					, MO.dtmLastTradingDate
					, strPhysicalOrFuture = 'Physical'
					, strErrorMsg = 'Future Month is Expired'
				FROM tblCTContractHeader CH
				JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
				JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
				JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
				JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
				JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
				JOIN tblICItem IM ON IM.intItemId = CD.intItemId
				JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
				JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
				WHERE CH.intCommodityId = @intCommodityId
					AND CD.dblQuantity > ISNULL(CD.dblInvoicedQty, 0)
					AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
					AND ISNULL(CD.intMarketZoneId, 0) = CASE WHEN ISNULL(@intMarketZoneId, 0) = 0 THEN ISNULL(CD.intMarketZoneId, 0) ELSE @intMarketZoneId END
					AND intContractStatusId NOT IN (2, 3, 6, 5)
					AND dtmContractDate <= @dtmEndDate
					AND MO.intFutureMonthId IN (SELECT intFutureMonthId
												FROM tblRKFuturesMonth
												WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, GETDATE()) < GETDATE())
	
				UNION ALL SELECT @intM2MHeaderId
					, CT.intFutOptTransactionId intContractDetailId
					, intContractHeaderId = NULL
					, CT.intFutOptTransactionHeaderId
					, CL.strLocationName
					, C.strCommodityCode
					, strContractType = strBuySell
					, strContractNumber = CT.strInternalTradeNo
					, strEntityName = EY.strName
					, strItemNo = ''
					, strPricingType = ''
					, MO.strFutureMonth
					, strFutureMarket = FM.strFutMarketName
					, MO.dtmLastTradingDate
					, strPhysicalOrFuture = 'Derivative'
					, strErrorMsg = 'Future Month is expired'
				FROM vyuRKGetOpenContract OC
				JOIN tblRKFutOptTransaction CT ON CT.intFutOptTransactionId = OC.intFutOptTransactionId
				JOIN tblICCommodity C ON C.intCommodityId = CT.intCommodityId
				JOIN tblEMEntity EY ON EY.intEntityId = CT.intEntityId
				JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CT.intFutureMarketId
				JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CT.intFutureMonthId
				JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CT.intLocationId
				WHERE CT.intCommodityId = @intCommodityId
					AND OC.dblOpenContract > 0
					AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
					AND LEFT(CONVERT(VARCHAR, CT.dtmFilledDate, 101), 10) <= @dtmEndDate
					AND MO.intFutureMonthId IN (SELECT intFutureMonthId
												FROM tblRKFuturesMonth
												WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, GETDATE()) < GETDATE())
				
				SET @ErrMsg = 'Physical/derivative records exist for expired futures month/s. Please roll the transactions and then run M2M inquiry.'
			END
			ELSE IF (@intMarkExpiredMonthPositionId = 3)
			BEGIN
				INSERT INTO tblRKM2MValidateError(intM2MHeaderId
					, intContractDetailId
					, intContractHeaderId
					, intFutOptTransactionHeaderId
					, strLocationName
					, strCommodityCode
					, strContractType
					, strContractNumber
					, strEntityName
					, strItemNo
					, strPricingType
					, strFutureMonth
					, strFutureMarket
					, dtmLastTradingDate
					, strPhysicalOrFuture
					, strErrorMsg)
				SELECT @intM2MHeaderId
					, CD.intContractDetailId
					, CH.intContractHeaderId
					, intFutOptTransactionHeaderId = NULL
					, CL.strLocationName
					, CY.strCommodityCode
					, TP.strContractType strContractType
					, strContractNumber = CH.strContractNumber + '-' + convert(NVARCHAR(10), CD.intContractSeq)
					, EY.strName strEntityName
					, IM.strItemNo
					, PT.strPricingType
					, MO.strFutureMonth
					, strFutureMarket = FM.strFutMarketName
					, MO.dtmLastTradingDate
					, strPhysicalOrFuture = 'Physical'
					, strErrorMsg = 'No Nearby Month found'
				FROM tblCTContractHeader CH
				JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
				JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
				JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
				JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
				JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
				JOIN tblICItem IM ON IM.intItemId = CD.intItemId
				JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
				JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
				CROSS APPLY dbo.fnRKRollToNearby(CD.intContractDetailId, CD.intFutureMarketId, CD.intFutureMonthId, CD.dblFutures) rk
				WHERE CH.intCommodityId = @intCommodityId
					AND CD.dblQuantity > ISNULL(CD.dblInvoicedQty, 0)
					AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
					AND ISNULL(CD.intMarketZoneId, 0) = CASE WHEN ISNULL(@intMarketZoneId, 0) = 0 THEN ISNULL(CD.intMarketZoneId, 0) ELSE @intMarketZoneId END
					AND intContractStatusId NOT IN (2, 3, 6, 5)
					AND dtmContractDate <= @dtmEndDate
					AND MO.intFutureMonthId IN (SELECT intFutureMonthId
												FROM tblRKFuturesMonth
												WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, GETDATE()) < GETDATE())
					AND rk.intContractDetailId = CD.intContractDetailId
					AND rk.intFutureMonthId = CD.intFutureMonthId
					AND ISNULL(rk.intNearByFutureMonthId, 0) = 0
					AND MO.ysnExpired = 1

				UNION ALL SELECT @intM2MHeaderId
					, CD.intContractDetailId
					, CH.intContractHeaderId
					, intFutOptTransactionHeaderId = NULL
					, CL.strLocationName
					, CY.strCommodityCode
					, TP.strContractType strContractType
					, strContractNumber = CH.strContractNumber + '-' + convert(NVARCHAR(10), CD.intContractSeq)
					, EY.strName strEntityName
					, IM.strItemNo
					, PT.strPricingType
					, MO.strFutureMonth
					, strFutureMarket = FM.strFutMarketName
					, MO.dtmLastTradingDate
					, strPhysicalOrFuture = 'Physical'
					, strErrorMsg = 'No settlement price found'
				FROM tblCTContractHeader CH
				JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
				JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
				JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
				JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
				JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
				JOIN tblICItem IM ON IM.intItemId = CD.intItemId
				JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
				JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
				CROSS APPLY dbo.fnRKRollToNearby(CD.intContractDetailId, CD.intFutureMarketId, CD.intFutureMonthId, CD.dblFutures) rk
				WHERE CH.intCommodityId = @intCommodityId
					AND CD.dblQuantity > ISNULL(CD.dblInvoicedQty, 0)
					AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
					AND ISNULL(CD.intMarketZoneId, 0) = CASE WHEN ISNULL(@intMarketZoneId, 0) = 0 THEN ISNULL(CD.intMarketZoneId, 0) ELSE @intMarketZoneId END
					AND intContractStatusId NOT IN (2, 3, 6, 5)
					AND dtmContractDate <= @dtmEndDate
					AND MO.intFutureMonthId IN (SELECT intFutureMonthId
												FROM tblRKFuturesMonth
												WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, GETDATE()) < GETDATE())
					AND rk.intContractDetailId = CD.intContractDetailId
					AND rk.intFutureMonthId = CD.intFutureMonthId
					AND CD.intPricingTypeId IN (1, 3)
					AND ISNULL(rk.intNearByFutureMonthId, 0) <> 0
					AND ISNULL(rk.dblNearByFuturePrice, 0) = 0
					AND MO.ysnExpired = 1

				SET @ErrMsg = 'Nearby Month not found for delinquent contracts.'
			END
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblRKM2MValidateError WHERE intM2MHeaderId = @intM2MHeaderId)
		BEGIN
			RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
			RETURN
		END
		-- END VALIDATION

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
			, intFutureMarketId
			, intFutureMonthId
			, strPricingStatus)
		SELECT ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmTransactionDate DESC) intRowNum
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
			, intCommodityUnitMeasureId = NULL
			, intContractDetailId
			, intContractStatusId
			, intEntityId
			, intQtyCurrencyId
			, strType = strContractType + ' ' + strPricingType
			, intItemId
			, strItemNo
			, dtmTransactionDate
			, strEntityName
			, strCustomerContract = ''
			, intFutureMarketId
			, intFutureMonthId
			, strContractStatus
		FROM dbo.fnRKGetBucketContractBalance(@dtmEndDate, @intCommodityId, NULL)

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
			, intFutureMarketId = ISNULL(temp.intFutureMarketId, 0)
			, intItemId = ISNULL(temp.intItemId, 0)
			, intContractTypeId = ISNULL(temp.intContractTypeId, 0)
			, intCompanyLocationId = ISNULL(temp.intCompanyLocationId, 0)
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
				, dblFutures = CASE WHEN cd.intPricingTypeId = 2 AND strPricingStatus IN ('Unpriced', 'Partially Priced') THEN 0
									ELSE CASE WHEN cd.intPricingTypeId IN (1, 3) THEN ISNULL(cd.dblFutures, 0) ELSE ISNULL(cd.dblFutures, 0) END END
				, dblMarketRatio = ISNULL(basisDetail.dblRatio, 0)
				, dblMarketBasis1 = ISNULL(CASE WHEN cd.strPricingType <> 'HTA' THEN basisDetail.dblMarketBasis ELSE 0 END, 0)
				, dblMarketCashPrice = ISNULL(CASE WHEN cd.strPricingType <> 'HTA' THEN basisDetail.dblMarketBasis ELSE 0 END, 0)
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
				, dtmContractDate
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
			CROSS APPLY (
				SELECT TOP 1 dblRatio, dblMarketBasis, intMarketBasisUOM, intMarketBasisCurrencyId FROM #tmpM2MBasisDetail tmp
				WHERE tmp.intFutureMarketId = ISNULL(cd.intFutureMarketId, tmp.intFutureMarketId)
					AND tmp.intItemId = ISNULL(cd.intItemId, tmp.intItemId)
					AND tmp.intContractTypeId = ISNULL(cd.intContractTypeId, tmp.intContractTypeId)
					AND tmp.intCompanyLocationId = ISNULL(cd.intCompanyLocationId, tmp.intCompanyLocationId)
					AND tmp.strPeriodTo = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
													THEN CASE WHEN tmp.strPeriodTo = '' THEN tmp.strPeriodTo ELSE dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy') END
												ELSE tmp.strPeriodTo END
					AND tmp.strContractInventory = 'Contract') basisDetail
			WHERE cd.intCommodityId = @intCommodityId 
		)t

		
	
		-- intransit
		IF (@ysnIncludeInTransitM2M = 1)
		BEGIN
			SELECT *
			INTO #tempIntransit
			FROM (
				SELECT strTransactionNumber
					, intTransactionRecordId
					, t.strContractSeq
					, t.intContractHeaderId
					, t.intContractDetailId
					, t.intLocationId
					, t.strLocationName
					, itemLoc.intItemLocationId
					, dblTotal = ISNULL(dblTotal, 0.000000)
					, t.intEntityId
					, t.strEntityName
					, strCustomerReference = t.strEntityName
					, dtmTicketDateTime = dtmTransactionDate
					, intTicketId
					, strTicketNumber
					, t.intCommodityId
					, t.strCommodityCode
					, t.intItemId
					, t.strItemNo
					, intCategoryId
					, strCategory
					, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), t.dtmTransactionDate, 106), 8) COLLATE Latin1_General_CI_AS
					, t.intFutureMarketId
					, t.strFutureMarket
					, t.intFutureMonthId
					, t.strFutureMonth
					, strDeliveryDate
					, t.strType
					, intOrigUOMId
					, cur.ysnSubCurrency
					, cur.intMainCurrencyId
					, cur.intCent
					, cb.strPricingStatus
					, cb.strPricingType
					, cb.intPricingTypeId
					, dblLastSettle = ISNULL(p.dblLastSettle, 0.000000)
					, dblCosts = ISNULL(cc.dblCosts, 0.000000)
					, intSpreadMonthId = CASE WHEN cb.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
					, strSpreadMonth = CASE WHEN cb.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
					, dblSpreadMonthPrice = CASE WHEN cb.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice ELSE NULL END ELSE NULL END
					, dblSpread = CASE WHEN cb.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice - p.dblLastSettle ELSE NULL END ELSE NULL END
					, ysnExpired = CASE WHEN cb.strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
				FROM dbo.fnRKGetBucketInTransit(@dtmEndDate, @intCommodityId, NULL) t
				LEFT JOIN tblICItemLocation itemLoc ON itemLoc.intItemId = t.intItemId AND itemLoc.intLocationId = t.intLocationId
				LEFT JOIN @ContractBalance cb ON cb.intContractDetailId = t.intContractDetailId
				LEFT JOIN @tblGetSettlementPrice p ON t.intFutureMonthId = p.intFutureMonthId
				LEFT JOIN #RollNearbyMonth rk ON rk.intContractDetailId = t.intContractDetailId AND rk.intFutureMonthId = t.intFutureMonthId
				LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = t.intCurrencyId
				LEFT JOIN #tblContractCost cc ON t.intContractDetailId = cc.intContractDetailId
			) tbl

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
				, intItemLocationId
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
				, intItemLocationId
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
				, dblResultCash = CASE WHEN intPricingTypeId = 6 THEN dblResult ELSE 0 END
				, dblResultBasis
				, dblShipQty = 0
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
						, dblAdjustedContractPrice = CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0) + (ISNULL(dblCash, 0)) + CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dblFutures ELSE dblFutures END) + ISNULL(dblCosts, 0) END
						, dblFuturesClosingPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, CASE WHEN ISNULL(intMarketBasisUOM, 0) = 0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END, dblFuturesClosingPrice1)
						, dblFuturePrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, CASE WHEN ISNULL(intMarketBasisUOM, 0) = 0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END, dblFuturePrice1)
						, dblOpenQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END , ISNULL(dblOpenQty1, 0))
					FROM (
						SELECT ch.intContractHeaderId
							, cd.intContractDetailId
							, strContractOrInventoryType = 'In-transit' + '(S)'
							, strContractSeq = it.strTransactionId
							, strEntityName = e.strName
							, ch.intEntityId
							, strFutureMarket = fm.strFutMarketName
							, cd.intFutureMarketId
							, fmo.strFutureMonth
							, cd.intFutureMonthId
							, com.strCommodityCode
							, ch.intCommodityId
							, i.strItemNo
							, cd.intItemId
							, it.intItemLocationId
							, strOrgin = NULL
							, i.intOriginId
							, strPosition = NULL
							, strPeriod = RIGHT(CONVERT(VARCHAR(8), cd.dtmStartDate, 3), 5) + '-' + RIGHT(CONVERT(VARCHAR(8), cd.dtmEndDate, 3), 5)
							, strPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20), cd.dtmEndDate, 106), 4, 8)
							, strStartDate = CONVERT(NVARCHAR(20), cd.dtmStartDate, 106)
							, strEndDate = CONVERT(NVARCHAR(20), cd.dtmEndDate, 106)
							, strPriOrNotPriOrParPriced = ISNULL(CB.strPricingStatus, pt.strPricingType)
							, intPricingTypeId = ISNULL(CB.intPricingTypeId, pt.intPricingTypeId)
							, strPricingType = ISNULL(CB.strPricingType, pt.strPricingType)
							, dblContractRatio = cd.dblRatio
							, dblContractBasis = cd.dblBasis
							, dblDummyContractBasis = null
							, cd.dblFutures
							, dblCash = CASE WHEN cd.intPricingTypeId = 6 THEN dblCashPrice ELSE NULL END
							, dblMarketRatio = ISNULL(basisDetail.dblRatio, 0)
							, dblMarketBasis1 = ISNULL(basisDetail.dblMarketBasis, 0)
							, intMarketBasisUOM = ISNULL(basisDetail.intMarketBasisUOM, 0)
							, intMarketBasisCurrencyId = ISNULL(basisDetail.intMarketBasisCurrencyId, 0)
							, dblFuturePrice1 = p.dblLastSettle
							, intFuturePriceCurrencyId = null
							, dblFuturesClosingPrice1 = p.dblLastSettle
							, ch.intContractTypeId
							, dblOpenQty1 = it.dblBalanceToInvoice
							, cd.dblRate
							, intCommodityUnitMeasureId = cuc.intCommodityUnitMeasureId
							, intQuantityUOMId = cuc1.intCommodityUnitMeasureId
							, intPriceUOMId = cuc2.intCommodityUnitMeasureId
							, cd.intCurrencyId
							, PriceSourceUOMId = convert(int, cuc3.intCommodityUnitMeasureId)
							, dblCosts = ISNULL(cc.dblCosts, 0)
							, ysnSubCurrency = CAST(ISNULL(cu.intMainCurrencyId, 0) AS BIT)
							, cu.intMainCurrencyId
							, cu.intCent
							, cd.dtmPlannedAvailabilityDate
							, dblInvoicedQuantity = cd.dblInvoicedQty
							, cd.intMarketZoneId
							, cd.intCompanyLocationId
							, mz.strMarketZoneCode
							, cl.strLocationName
							, dblNoOfLots = CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots ELSE cd.dblNoOfLots END
							, dblLotsFixed = NULL --cd.dblLotsFixed
							, dblPriceWORollArb = NULL --cd.dblPriceWORollArb
							, dblCashPrice = 0.00
							, intSpreadMonthId = CASE WHEN CB.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
							, strSpreadMonth = CASE WHEN CB.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
							, dblSpreadMonthPrice = CASE WHEN CB.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice ELSE NULL END ELSE NULL END
							, dblSpread = CASE WHEN CB.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice - p.dblLastSettle ELSE NULL END ELSE NULL END
							, ysnExpired = CASE WHEN CB.strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
						FROM #tempIntransit it
						JOIN tblCTContractDetail cd ON cd.intContractDetailId = it.intContractDetailId
						JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
						JOIN tblICItem i ON cd.intItemId = i.intItemId
						JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND iuom.intItemUOMId = cd.intBasisUOMId
						JOIN tblEMEntity e ON ch.intEntityId = e.intEntityId
						JOIN tblICCommodity com ON ch.intCommodityId = com.intCommodityId
						JOIN tblRKFutureMarket fm ON cd.intFutureMarketId = fm.intFutureMarketId
						JOIN tblRKFuturesMonth fmo ON cd.intFutureMonthId = fmo.intFutureMonthId
						JOIN tblCTPricingType pt ON cd.intPricingTypeId = pt.intPricingTypeId
						JOIN tblICCommodityUnitMeasure cuc ON ch.intCommodityId = cuc.intCommodityId AND cuc.intUnitMeasureId = it.intUnitMeasureId AND ch.intCommodityId = @intCommodityId
						JOIN tblICCommodityUnitMeasure cuc1 ON ch.intCommodityId = cuc1.intCommodityId AND cuc1.intUnitMeasureId = @intQuantityUOMId
						JOIN tblICCommodityUnitMeasure cuc2 ON ch.intCommodityId = cuc2.intCommodityId AND cuc2.intUnitMeasureId = @intPriceUOMId
						JOIN tblICCommodityUnitMeasure cuc3 ON ch.intCommodityId = cuc3.intCommodityId AND cuc3.intUnitMeasureId = iuom.intUnitMeasureId
						LEFT JOIN @tblGetSettlementPrice p ON cd.intFutureMonthId = p.intFutureMonthId
						LEFT JOIN #tblContractCost cc ON cd.intContractDetailId = cc.intContractDetailId
						JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
						LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = cd.intMarketZoneId
						JOIN tblSMCurrency cu ON cu.intCurrencyID = cd.intCurrencyId
						LEFT JOIN #RollNearbyMonth rk ON rk.intContractDetailId = cd.intContractDetailId AND rk.intFutureMonthId = cd.intFutureMonthId
						LEFT JOIN @ContractBalance CB ON CB.intContractDetailId = cd.intContractDetailId
						CROSS APPLY (
							SELECT TOP 1 dblRatio, dblMarketBasis, intMarketBasisUOM, intMarketBasisCurrencyId FROM #tmpM2MBasisDetail tmp
							WHERE tmp.intFutureMarketId = ISNULL(cd.intFutureMarketId, tmp.intFutureMarketId)
								AND tmp.intItemId = ISNULL(cd.intItemId, tmp.intItemId)
								AND tmp.intContractTypeId = ISNULL(ch.intContractTypeId, tmp.intContractTypeId)
								AND tmp.intCompanyLocationId = ISNULL(cd.intCompanyLocationId, tmp.intCompanyLocationId)
								AND tmp.strPeriodTo = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
																THEN CASE WHEN tmp.strPeriodTo = '' THEN tmp.strPeriodTo ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END
															ELSE tmp.strPeriodTo END
								AND tmp.strContractInventory = 'Contract') basisDetail

						--Logistics Sale
						UNION ALL SELECT ch.intContractHeaderId
							, cd.intContractDetailId
							, strContractOrInventoryType = 'In-transit' + '(S)'
							, strContractSeq = it.strTransactionId 
							, strEntityName = e.strName
							, ch.intEntityId
							, strFutureMarket = fm.strFutMarketName
							, cd.intFutureMarketId
							, fmo.strFutureMonth
							, cd.intFutureMonthId
							, com.strCommodityCode
							, ch.intCommodityId
							, i.strItemNo
							, cd.intItemId
							, it.intItemLocationId
							, strOrgin = NULL
							, i.intOriginId
							, strPosition = NULL
							, strPeriod = RIGHT(CONVERT(VARCHAR(8), cd.dtmStartDate, 3), 5) + '-' + RIGHT(CONVERT(VARCHAR(8), cd.dtmEndDate, 3), 5)
							, strPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20), cd.dtmEndDate, 106), 4, 8)
							, strStartDate = CONVERT(NVARCHAR(20), cd.dtmStartDate, 106)
							, strEndDate = CONVERT(NVARCHAR(20), cd.dtmEndDate, 106)
							, strPriOrNotPriOrParPriced = ISNULL(CB.strPricingStatus, pt.strPricingType)
							, intPricingTypeId = ISNULL(CB.intPricingTypeId, pt.intPricingTypeId)
							, strPricingType = ISNULL(CB.strPricingType, pt.strPricingType)
							, dblContractRatio = cd.dblRatio
							, dblContractBasis = cd.dblBasis
							, dblDummyContractBasis = null
							, cd.dblFutures
							, dblCash = CASE WHEN cd.intPricingTypeId = 6 THEN dblCashPrice ELSE NULL END
							, dblMarketRatio = ISNULL(basisDetail.dblRatio, 0)
							, dblMarketBasis1 = ISNULL(basisDetail.dblMarketBasis, 0)
							, intMarketBasisUOM = ISNULL(basisDetail.intMarketBasisUOM, 0)
							, intMarketBasisCurrencyId = ISNULL(basisDetail.intMarketBasisCurrencyId, 0)
							, dblFuturePrice1 = p.dblLastSettle
							, intFuturePriceCurrencyId = null
							, dblFuturesClosingPrice1 = p.dblLastSettle
							, ch.intContractTypeId
							, dblOpenQty1 = it.dblBalanceToInvoice
							, cd.dblRate
							, intCommodityUnitMeasureId = cuc.intCommodityUnitMeasureId
							, intQuantityUOMId = cuc1.intCommodityUnitMeasureId
							, intPriceUOMId = cuc2.intCommodityUnitMeasureId
							, cd.intCurrencyId
							, PriceSourceUOMId = CONVERT(INT, cuc3.intCommodityUnitMeasureId)
							, dblCosts = ISNULL(cc.dblCosts, 0)
							, ysnSubCurrency = CAST(ISNULL(cu.intMainCurrencyId, 0) AS BIT)
							, cu.intMainCurrencyId
							, cu.intCent
							, cd.dtmPlannedAvailabilityDate
							, dblInvoicedQuantity = 0
							, cd.intMarketZoneId
							, cd.intCompanyLocationId
							, mz.strMarketZoneCode
							, cl.strLocationName
							, dblNoOfLots = CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots ELSE cd.dblNoOfLots END
							, dblLotsFixed = NULL
							, dblPriceWORollArb = NULL
							, dblCashPrice = 0.00
							, intSpreadMonthId = CASE WHEN pt.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
							, strSpreadMonth = CASE WHEN pt.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
							, dblSpreadMonthPrice = CASE WHEN pt.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice ELSE NULL END ELSE NULL END
							, dblSpread = CASE WHEN pt.strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice - p.dblLastSettle ELSE NULL END ELSE NULL END
							, ysnExpired = CASE WHEN pt.strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
						FROM #tempIntransit it
						JOIN tblLGLoadDetail ld ON ld.intLoadDetailId = it.intTransactionDetailId
						JOIN tblCTContractDetail cd ON cd.intContractDetailId = ld.intSContractDetailId
						JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
						JOIN tblICItem i ON cd.intItemId = i.intItemId
						JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND iuom.intItemUOMId = cd.intBasisUOMId
						JOIN tblEMEntity e ON ch.intEntityId = e.intEntityId
						JOIN tblICCommodity com ON ch.intCommodityId = com.intCommodityId
						JOIN tblRKFutureMarket fm ON cd.intFutureMarketId = fm.intFutureMarketId
						JOIN tblRKFuturesMonth fmo ON cd.intFutureMonthId = fmo.intFutureMonthId
						JOIN tblCTPricingType pt ON cd.intPricingTypeId = pt.intPricingTypeId
						JOIN tblICCommodityUnitMeasure cuc ON ch.intCommodityId = cuc.intCommodityId AND cuc.intUnitMeasureId = it.intUnitMeasureId AND ch.intCommodityId = @intCommodityId
						JOIN tblICCommodityUnitMeasure cuc1 ON ch.intCommodityId = cuc1.intCommodityId AND cuc1.intUnitMeasureId = @intQuantityUOMId
						JOIN tblICCommodityUnitMeasure cuc2 ON ch.intCommodityId = cuc2.intCommodityId AND cuc2.intUnitMeasureId = @intPriceUOMId
						JOIN tblICCommodityUnitMeasure cuc3 ON ch.intCommodityId = cuc3.intCommodityId AND cuc3.intUnitMeasureId = iuom.intUnitMeasureId
						LEFT JOIN @tblGetSettlementPrice p ON cd.intFutureMonthId = p.intFutureMonthId
						LEFT JOIN #tblContractCost cc ON cd.intContractDetailId = cc.intContractDetailId
						JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
						LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = cd.intMarketZoneId
						JOIN tblSMCurrency cu ON cu.intCurrencyID = cd.intCurrencyId
						LEFT JOIN #RollNearbyMonth rk ON rk.intContractDetailId = cd.intContractDetailId AND rk.intFutureMonthId = cd.intFutureMonthId
						LEFT JOIN @ContractBalance CB ON CB.intContractDetailId = cd.intContractDetailId
						CROSS APPLY (
							SELECT TOP 1 dblRatio, dblMarketBasis, intMarketBasisUOM, intMarketBasisCurrencyId FROM #tmpM2MBasisDetail tmp
							WHERE tmp.intFutureMarketId = ISNULL(cd.intFutureMarketId, tmp.intFutureMarketId)
								AND tmp.intItemId = ISNULL(cd.intItemId, tmp.intItemId)
								AND tmp.intContractTypeId = ISNULL(ch.intContractTypeId, tmp.intContractTypeId)
								AND tmp.intCompanyLocationId = ISNULL(cd.intCompanyLocationId, tmp.intCompanyLocationId)
								AND tmp.strPeriodTo = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
																THEN CASE WHEN tmp.strPeriodTo = '' THEN tmp.strPeriodTo ELSE dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy') END
															ELSE tmp.strPeriodTo END
								AND tmp.strContractInventory = 'Contract') basisDetail
						WHERE it.intLineNo IS NULL
							AND it.strTransactionId LIKE 'LS-%'

						UNION ALL
						SELECT 
							 intContractHeaderId = NULL
							, intContractDetailId = NULL
							, 'In-transit' + '(S)' as strContractOrInventoryType
							, strContractSeq = it.strTransactionId 
							, strEntityName = it.strEntity
							, it.intEntityId
							, strFutureMarket = NULL
							, intFutureMarketId = NULL
							, strFutureMonth = NULL
							, intFutureMonthId = NULL
							, it.strCommodityCode
							, it.intCommodityId
							, it.strItemNo
							, it.intItemId
							, it.intItemLocationId
							, strOrgin = NULL --cd.strOrgin
							, intOriginId = NULL
							, strPosition = NULL --cd.strPosition
							, strPeriod = NULL
							, strPeriodTo = NULL
							, strStartDate = NULL
							, strEndDate = NULL
							, strPriOrNotPriOrParPriced = NULL
							, intPricingTypeId = NULL
							, strPricingType = NULL
							, dblContractRatio = 0
							, dblContractBasis = 0
							, dblDummyContractBasis = 0
							, dblFutures = 0
							, dblCash = ISNULL(dbo.fnCalculateValuationAverageCost(intItemId, intItemLocationId, @dtmEndDate), 0) --it.dblPrice
							, dblMarketRatio = 0
							, dblMarketBasis1 = 0
							, dblMarketBasisUOM = 0
							, intMarketBasisCurrencyId = NULL
							, dblFuturePrice1 = 0
							, intFuturePriceCurrencyId = NULL
							, dblFuturesClosingPrice1 = 0
							, intContractTypeId = NULL
							, dblOpenQty1 = -it.dblBalanceToInvoice
							, dblRate = NULL
							, intCommodityUnitMeasureId = NULL
							, intQuantityUOMId = NULL
							, intPriceUOMId = NULL
							, intCurrencyId = NULL
							, PriceSourceUOMId = NULL
							, dblCosts = 0
							, ysnSubCurrency = NULL
							, intMainCurrencyId = NULL
							, intCent = NULL
							, dtmPlannedAvailabilityDate = NULL
							, dblInvoicedQuantity = NULL
							, intMarketZoneId = NULL
							, intCompanyLocationId = it.intLocationId
							, strMarketZoneCode = NULL
							, it.strLocationName
							, dblNoOfLots = NULL
							, dblLotsFixed = NULL --cd.dblLotsFixed
							, dblPriceWORollArb = NULL --cd.dblPriceWORollArb
							, dblCashPrice = ROUND(ISNULL((SELECT TOP 1 ISNULL(dblCashOrFuture, 0) FROM #tmpM2MBasisDetail temp
									WHERE ISNULL(temp.intCommodityId, 0) = CASE WHEN ISNULL(temp.intCommodityId, 0) = 0 THEN 0 ELSE it.intCommodityId END
										AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE it.intItemId END
										AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(it.intLocationId, 0) END
										AND temp.strContractInventory = 'Inventory'), 0), 4)
							, intSpreadMonthId = NULL
							, strSpreadMonth = NULL
							, dblSpreadMonthPrice = NULL
							, dblSpread = NULL
							, ysnExpired = NULL
						FROM #tempIntransit it
						WHERE it.intLineNo IS NULL
						AND it.strTransactionId NOT LIKE 'LS-%'

					)t
				)t
			)t2
			DROP TABLE #tempIntransit
		END
		---- intransit End(p)
 
		select SUM(dblPurchaseContractShippedQty) dblPurchaseContractShippedQty, intContractDetailId into #tblPIntransitView from vyuRKPurchaseIntransitView group by intContractDetailId
 
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

		------------- Calculation of Results ----------------------
		--UPDATE #Temp
		--SET dblResultBasis = CASE WHEN intContractTypeId = 1 AND (ISNULL(dblContractBasis, 0) <= dblMarketBasis) THEN abs(dblResultBasis)
		--						WHEN intContractTypeId = 1 AND (ISNULL(dblContractBasis, 0) > dblMarketBasis) THEN - abs(dblResultBasis)
		--						WHEN intContractTypeId = 2 AND (ISNULL(dblContractBasis, 0) >= dblMarketBasis) THEN abs(dblResultBasis)
		--						WHEN intContractTypeId = 2 AND (ISNULL(dblContractBasis, 0) < dblMarketBasis) THEN - abs(dblResultBasis) END
			--, dblMarketFuturesResult = CASE WHEN intContractTypeId = 1 AND (ISNULL(dblFutures, 0) <= ISNULL(dblFuturesClosingPrice, 0)) THEN abs(dblMarketFuturesResult)
			--								WHEN intContractTypeId = 1 AND (ISNULL(dblFutures, 0) > ISNULL(dblFuturesClosingPrice, 0)) THEN - abs(dblMarketFuturesResult)
			--								WHEN intContractTypeId = 2 AND (ISNULL(dblFutures, 0) >= ISNULL(dblFuturesClosingPrice, 0)) THEN abs(dblMarketFuturesResult)
			--								WHEN intContractTypeId = 2 AND (ISNULL(dblFutures, 0) < ISNULL(dblFuturesClosingPrice, 0)) THEN - abs(dblMarketFuturesResult) END
		--------------END ---------------

		IF ISNULL(@ysnIncludeInventoryM2M, 0) = 1
		BEGIN
			DECLARE @intSpotMonthId int
				, @strSpotMonth NVARCHAR(100)
	
			SELECT TOP 1 @intSpotMonthId = intFutureMonthId
				, @strSpotMonth = strFutureMonth
			FROM tblRKFuturesMonth
			WHERE ysnExpired = 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmSpotDate, 110), 110) < = CONVERT(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)
				AND intFutureMarketId = 1
			ORDER BY dtmSpotDate DESC
	
			INSERT INTO #Temp (strContractOrInventoryType
				, strCommodityCode
				, intCommodityId
				, strItemNo
				, intItemId
				, strLocationName
				, intLocationId
				, strFutureMonth
				, intFutureMonthId
				, intFutureMarketId
				, dblContractRatio
				, dblFutures
				, dblCash
				, dblNotLotTrackedPrice
				, dblInvFuturePrice
				, dblInvMarketBasis
				, dblMarketRatio
				, dblCosts
				, dblOpenQty
				, dblResult
				, dblCashPrice
				, intCurrencyId)
			SELECT * FROM (
				SELECT strContractOrInventoryType
					, strCommodityCode
					, intCommodityId
					, strItemNo
					, intItemId
					, strLocationName
					, intLocationId
					, @strSpotMonth strFutureMonth
					, @intSpotMonthId intFutureMonthId
					, intFutureMarketId
					, dblContractRatio = 0
					, dblFutures = 0
					, dblCash = dblNotLotTrackedPrice
					, dblNotLotTrackedPrice
					, dblInvFuturePrice = 0
					, dblInvMarketBasis = 0
					, dblMarketRatio = 0
					, dblCosts = 0
					, SUM(dblOpenQty) dblOpenQty
					, SUM(dblOpenQty) dblResult
					, dblCashOrFuture = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, intMarketBasisUOM, dblCashOrFuture)
					, intCurrencyId
				FROM (
					SELECT strContractOrInventoryType = 'Inventory'
						, s.strLocationName
						, s.intLocationId
						, c.strCommodityCode
						, c.intCommodityId
						, i.strItemNo
						, i.intItemId
						, dblOpenQty = SUM(dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity , 0)))) 
						, PriceSourceUOMId = ISNULL(bd.intUnitMeasureId, 0)
						, dblInvMarketBasis = 0
						, dblCashOrFuture = ROUND(ISNULL(bd.dblCashOrFuture, 0), 4)
						, intMarketBasisUOM = ISNULL(bd.intUnitMeasureId, 0)
						, intCurrencyId = ISNULL(bd.intCurrencyId, 0)
						, (SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate < = GETDATE() AND intFutureMarketId = c.intFutureMarketId ORDER BY 1 DESC) strFutureMonth
						, (SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate < = GETDATE() AND intFutureMarketId = c.intFutureMarketId ORDER BY 1 DESC) intFutureMonthId
						, c.intFutureMarketId
						, dblNotLotTrackedPrice = dbo.fnCalculateQtyBetweenUOM(iuomTo.intItemUOMId, iuomStck.intItemUOMId, ISNULL(dbo.fnCalculateValuationAverageCost(i.intItemId, s.intItemLocationId, @dtmEndDate), 0))
						, cu2.intCommodityUnitMeasureId intToPriceUOM
					FROM vyuRKGetInventoryValuation s
					JOIN tblICItem i ON i.intItemId = s.intItemId
					JOIN tblICCommodity c ON i.intCommodityId = c.intCommodityId
					JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
					JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
					JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = @intQuantityUOMId
					JOIN tblICCommodityUnitMeasure cu2 ON cu2.intCommodityId = c.intCommodityId AND cu2.intUnitMeasureId = @intPriceUOMId
					JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = c.intCommodityId AND cu1.ysnStockUnit = 1
					LEFT JOIN tblSCTicket t ON s.intSourceId = t.intTicketId
					LEFT JOIN tblICItemPricing p ON i.intItemId = p.intItemId AND s.intItemLocationId = p.intItemLocationId
					CROSS APPLY (SELECT TOP 1 intUnitMeasureId
									, dblCashOrFuture = ISNULL(dblCashOrFuture, 0)
									, intCurrencyId = ISNULL(intCurrencyId, 0)
								FROM #tmpM2MBasisDetail temp
								WHERE ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE i.intItemId END
									AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(s.intLocationId, 0) END
									AND temp.strContractInventory = 'Inventory') bd
					WHERE i.intCommodityId = @intCommodityId AND ISNULL(s.dblQuantity, 0) <>0 
						AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId) 
						AND ISNULL(strTicketStatus, '') <> 'V'
						AND convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)< = convert(datetime, @dtmEndDate)
						AND ysnInTransit = 0
					GROUP BY i.intItemId
							, i.strItemNo
							, s.intItemLocationId
							, s.intLocationId
							, strLocationName
							, strCommodityCode
							, c.intCommodityId
							, c.intFutureMarketId
							, cuom.intCommodityUnitMeasureId
							, iuomTo.intItemUOMId
							, iuomStck.intItemUOMId
							, cu2.intCommodityUnitMeasureId
							, bd.intUnitMeasureId
							, bd.dblCashOrFuture
							, bd.intCurrencyId
					
				) t1
				GROUP BY strContractOrInventoryType
					, strCommodityCode
					, intCommodityId
					, strItemNo
					, intItemId
					, PriceSourceUOMId
					, strLocationName
					, intLocationId
					, strFutureMonth
					, intFutureMonthId
					, intFutureMarketId
					, dblNotLotTrackedPrice
					, dblInvMarketBasis
					, intMarketBasisUOM
					, PriceSourceUOMId
					, intCurrencyId
					, dblCashOrFuture
			)t2 WHERE ISNULL(dblOpenQty, 0) <> 0

			--Collateral
			SELECT 
					col.intCollateralId
				, strContractOrInventoryType = 'Inventory' 
				, loc.strLocationName
				, col.intLocationId
				, c.strCommodityCode
				, c.intCommodityId
				, i.strItemNo
				, i.intItemId
				, dblOpenQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(col.intUnitMeasureId, @intQuantityUOMId, col.dblOriginalQuantity - ISNULL(ca.dblAdjustmentAmount, 0))
									* CASE WHEN col.strType = 'Sale' THEN -1 ELSE 1 END
				, PriceSourceUOMId = NULL
				, dblInvMarketBasis = 0
				, dblCashOrFuture = 0
				, intMarketBasisUOM = 0
				, intCurrencyId = 0
				, strFutureMonth = ''
				, intFutureMonthId = NULL
				, c.intFutureMarketId
				, dblNotLotTrackedPrice = 0
				, intToPriceUOM = NULL
			INTO #tempCollateral
			FROM tblRKCollateral col
			INNER JOIN tblICItem i ON i.intItemId = col.intItemId
			INNER JOIN tblICCommodity c ON c.intCommodityId = col.intCommodityId
			JOIN tblICItemUOM iuomStck ON i.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
			JOIN tblICItemUOM iuomTo ON i.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = @intQuantityUOMId
			JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = col.intLocationId
			LEFT JOIN (
				SELECT intCollateralId, SUM(ISNULL(dblAdjustmentAmount, 0)) as dblAdjustmentAmount FROM tblRKCollateralAdjustment 
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmAdjustmentDate, 110), 110) < = CONVERT(DATETIME, @dtmEndDate)
				GROUP BY intCollateralId

			) ca ON col.intCollateralId = ca.intCollateralId
			WHERE col.intCommodityId = @intCommodityId
			AND col.intLocationId = ISNULL(@intLocationId, col.intLocationId) 
			AND col.ysnIncludeInPriceRiskAndCompanyTitled = 1

			DECLARE @intCollateralId INT
					, @intCommodityIdCollateral INT
					, @intItemIdCollateral INT
					, @intLocationIdCollateral INT
					, @dblOpenQtyCollateral NUMERIC(18, 6)
				
			WHILE (SELECT Count(*) FROM #tempCollateral) > 0
			BEGIN
				SELECT 
					@intCollateralId = intCollateralId 
					, @intCommodityIdCollateral = intCommodityId
					, @intItemIdCollateral = intItemId
					, @intLocationIdCollateral = intLocationId
					, @dblOpenQtyCollateral = dblOpenQty
				FROM #tempCollateral

				--Add Collateral Qty if Inventory exist ELSE insert a new entry
				IF EXISTS (SELECT TOP 1 * FROM #Temp
								WHERE intCommodityId = @intCommodityIdCollateral
								AND intItemId = @intItemIdCollateral
								AND intLocationId = @intLocationIdCollateral
								AND strContractOrInventoryType = 'Inventory'
				)
				BEGIN
					UPDATE #Temp SET dblOpenQty = dblOpenQty + @dblOpenQtyCollateral
					WHERE intCommodityId = @intCommodityIdCollateral
						AND intItemId = @intItemIdCollateral
						AND intLocationId = @intLocationIdCollateral

				END
				ELSE
				BEGIN
					INSERT INTO #Temp (strContractOrInventoryType
						, strCommodityCode
						, intCommodityId
						, strItemNo
						, intItemId
						, strLocationName
						, intLocationId
						, strFutureMonth
						, intFutureMonthId
						, intFutureMarketId
						, dblContractRatio
						, dblFutures
						, dblCash
						, dblNotLotTrackedPrice
						, dblInvFuturePrice
						, dblInvMarketBasis
						, dblMarketRatio
						, dblCosts
						, dblOpenQty
						, dblResult
						, dblCashPrice
						, intCurrencyId)
					SELECT strContractOrInventoryType
						, strCommodityCode
						, intCommodityId
						, strItemNo
						, intItemId
						, strLocationName
						, intLocationId
						, strFutureMonth
						, intFutureMonthId
						, intFutureMarketId
						, dblContractRatio = 0
						, dblFutures = 0
						, dblCash = 0
						, dblNotLotTrackedPrice
						, dblInvFuturePrice = 0
						, dblInvMarketBasis
						, dblMarketRatio = 0
						, dblCosts = 0
						, dblOpenQty
						, dblResult = 0
						, dblCashPrice = 0
						, intCurrencyId
					FROM #tempCollateral
					WHERE intCollateralId = @intCollateralId
				
				END
			
				DELETE FROM #tempCollateral WHERE intCollateralId = @intCollateralId
			END

			DROP TABLE #tempCollateral
		END


		IF @ysnIncludeInTransitM2M = 1
		BEGIN
			INSERT INTO #Temp (strContractOrInventoryType
				, strContractSeq
				, strCommodityCode
				, intCommodityId
				, strItemNo
				, intItemId
				, strLocationName
				, intLocationId
				, strFutureMonth
				, intFutureMonthId
				, intFutureMarketId
				, dblContractRatio
				, dblFutures
				, dblCash
				, dblNotLotTrackedPrice
				, dblInvFuturePrice
				, dblInvMarketBasis
				, dblMarketRatio
				, dblCosts
				, dblOpenQty
				, dblResult
				, dblCashPrice
				, intCurrencyId)
			SELECT * FROM (
				SELECT strContractOrInventoryType
					, strContractSeq
					, strCommodityCode
					, intCommodityId
					, strItemNo
					, intItemId
					, strLocationName
					, intLocationId
					, strFutureMonth = @strSpotMonth
					, intFutureMonthId = @intSpotMonthId
					, intFutureMarketId
					, dblContractRatio = 0
					, dblFutures = 0
					, dblCash = dblNotLotTrackedPrice
					, dblNotLotTrackedPrice
					, dblInvFuturePrice = 0
					, dblInvMarketBasis = 0
					, dblMarketRatio = 0
					, dblCosts = 0
					, dblOpenQty
					, dblResult = dblOpenQty
					, dblCashOrFuture = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, intMarketBasisUOM, dblCashOrFuture)
					, intCurrencyId
				FROM (
					SELECT strContractOrInventoryType = 'In-transit(I)'
						, strContractSeq
						, strLocationName
						, intLocationId
						, strCommodityCode
						, intCommodityId
						, strItemNo
						, intItemId
						, dblOpenQty = ABS(dblOpenQty)
						, PriceSourceUOMId = ISNULL(bd.intUnitMeasureId, 0)
						, dblInvMarketBasis = 0
						, dblCashOrFuture = ROUND(ISNULL(bd.dblCashOrFuture, 0), 4)
						, intMarketBasisUOM = ISNULL(bd.intUnitMeasureId, 0)
						, intCurrencyId = ISNULL(bd.intCurrencyId, 0)
						, strFutureMonth = (SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate < = GETDATE() AND intFutureMarketId = intFutureMarketId ORDER BY 1 DESC)
						, intFutureMonthId = (SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate < = GETDATE() AND intFutureMarketId = intFutureMarketId ORDER BY 1 DESC) 
						, intFutureMarketId
						, dblNotLotTrackedPrice = ISNULL(dbo.fnCalculateValuationAverageCost(intItemId, intItemLocationId, @dtmEndDate), 0)
					FROM @ListTransaction t
					CROSS APPLY (SELECT TOP 1 intUnitMeasureId
									, dblCashOrFuture = ISNULL(dblCashOrFuture, 0)
									, intCurrencyId = ISNULL(intCurrencyId, 0)
								FROM #tmpM2MBasisDetail temp
								WHERE ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE t.intItemId END
									AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(t.intLocationId, 0) END
									AND temp.strContractInventory = 'Inventory') bd
					WHERE strContractOrInventoryType = 'In-transit(S)'
					
					
				) t1
			)t2 WHERE ISNULL(dblOpenQty, 0) <> 0
		END

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
				, dblOpenQty = dblOpenContract * dblContractSize
				, dblInvFuturePrice = SP.dblLastSettle
				, intCurrencyId
			FROM fnRKGetOpenFutureByDate (@intCommodityId, '1/1/1900', @dtmEndDate, 1) DER
			LEFT JOIN @tblGetSettlementPrice SP ON SP.intFutureMarketId = DER.intFutureMarketId AND SP.intFutureMonthId = DER.intFutureMonthId
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
				--Contract Basisc
				, dblContractBasis = (CASE WHEN strPricingType ! = 'HTA'
											THEN (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
														--CAD/CAD
														THEN (CASE WHEN intCurrencyId = @intCurrencyId THEN dblContractBasis
																--USD/CAD
																WHEN strMainCurrency = 'USD'
																	THEN (CASE WHEN @strRateType = 'Contract'
																				--Formula: Contract Price - Contract Futures
																				THEN ((ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0))
																					/ dblRate)
																					- (dblCalculatedFutures)
																			--Configuration
																			--Formula: Contract Price - Contract Futures
																			ELSE ((ISNULL(dblContractBasis, 0)
																					+ (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1))
																					+ ISNULL(dblCash, 0)) / @dblRateConfiguration)
																				- dblCalculatedFutures END)
																--Can be used other currency exchange
																ELSE dblContractBasis END)
														ELSE dblContractBasis END)
										ELSE 0 END)
				--Contract Futures
				, dblActualFutures = dblCalculatedFutures
				, dblFutures = (CASE WHEN strPricingType = 'Basis' AND strPriOrNotPriOrParPriced = 'Partially Priced' THEN dblFutures --((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * dblConvertedFuturePrice)) / dblNoOfLots
						WHEN strPricingType = 'Basis' THEN ISNULL(dblFutures, 0)
						WHEN strPricingType = 'Priced' THEN ISNULL(dblFutures, 0)
						ELSE dblCalculatedFutures END)
				, dblCash --Contract Cash
				, dblCosts = ABS(dblCosts)
				--Market Basis
				, dblMarketBasis = (CASE WHEN strPricingType ! = 'HTA' THEN
										CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
											THEN (CASE WHEN strMBCurrency = 'USD' AND strFPCurrency = 'USD'
														--USD/CAD
														THEN (CASE WHEN @strRateType = 'Contract'
																	--Formula: Market Price - Market Futures
																	THEN ((ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0))
																		/ dblRate)
																		- dblConvertedFuturePrice
																--Configuration
																--Formula: Market Price - Market Futures
																ELSE ((ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0))
																	/ @dblRateConfiguration) - dblConvertedFuturePrice END)
													--When both currencies is not equal to M2M currency
													WHEN intMarketBasisCurrencyId <> @intCurrencyId OR intFuturePriceCurrencyId <> @intCurrencyId
														THEN ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0)
													--Can be used other currency exchange
													ELSE ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0) END)
										ELSE ISNULL(dblMarketBasis, 0) + ISNULL(dblInvMarketBasis, 0) END

									ELSE 0 END)
				, dblMarketRatio
				, dblFuturePrice = dblConvertedFuturePrice --Market Futures
				, intContractTypeId
				, dblAdjustedContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
													THEN (CASE WHEN intCurrencyId = @intCurrencyId
																--CAD/CAD
																THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts, 0)
															WHEN strMainCurrency = 'USD'
																--USD/CAD
																THEN (CASE WHEN @strRateType = 'Contract'
																			THEN (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts, 0))
																				/ dblRate
																		--Configuration
																		ELSE (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts, 0))
																			/ @dblRateConfiguration END)
															--Can be used other currency exchange
															ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts, 0) END)
												ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) + ISNULL(dblCosts, 0) END)
				, dblCashPrice
				--Market Price
				, dblMarketPrice = CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
											THEN (CASE WHEN strMBCurrency = 'USD' AND strFPCurrency = 'USD'
														--USD/CAD
														THEN (CASE WHEN @strRateType = 'Contract'
																	THEN (ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0))
																		/ dblRate
																	--Configuration
																	ELSE (ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0))
																		/ @dblRateConfiguration END)
													--When both currencies is not equal to M2M currency
													WHEN intMarketBasisCurrencyId <> @intCurrencyId OR intFuturePriceCurrencyId <> @intCurrencyId
														THEN ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0)
													--Can be used other currency exchange
													ELSE ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0) END)
										ELSE ISNULL(dblMarketBasis, 0) + (ISNULL(dblConvertedFuturePrice, 0) * CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE ISNULL(dblMarketRatio, 0) END) + ISNULL(dblCashPrice, 0) END
				, dblResultBasis = dblResultBasis
				, dblResultCash
				--Contract Price
				, dblContractPrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
											THEN (CASE WHEN intCurrencyId = @intCurrencyId
														--CAD/CAD
														THEN ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0)
													WHEN strMainCurrency = 'USD'
														--USD/CAD
														THEN (CASE WHEN @strRateType = 'Contract'
																	THEN (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0))
																		/ dblRate
																--Configuration
																ELSE (ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0))
																	/ @dblRateConfiguration END)
													--Can be used other currency exchange
													ELSE ISNULL(dblContractBasis, 0) + (ISNULL(dblCalculatedFutures, 0) * ISNULL(dblContractRatio, 1)) + ISNULL(dblCash, 0) END)
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
												ELSE dblFutures END), 0)
				FROM (
					SELECT #Temp.*
						, dblRate = ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
											WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
												AND ISNULL(dblRate, 0) <> 0
												AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId
												AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration)
						, dblConvertedFuturePrice = (CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
															--CAD/CAD
															THEN (CASE WHEN intCurrencyId = @intCurrencyId THEN ISNULL(dblFuturePrice, 0)
																	--USD/CAD
																	WHEN Currency.strCurrency = 'USD'
																		THEN (CASE WHEN @strRateType = 'Contract' THEN ISNULL(dblFuturePrice, 0) / 
																				ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
																						WHERE dtmFXValidFrom < GETDATE() AND dtmFXValidTo > GETDATE()
																							AND ISNULL(dblRate, 0) <> 0
																							AND intCurrencyExchangeRateId = @intCurrencyExchangeRateId
																							AND intContractDetailId = #Temp.intContractDetailId), @dblRateConfiguration)
																				ELSE ISNULL(dblFuturePrice, 0) / @dblRateConfiguration END)
																	--Can be used other currency exchange
																	ELSE ISNULL(dblFuturePrice, 0) END)
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
				, intCompanyLocationId
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

		DROP TABLE #tblContractCost
		DROP TABLE #tblSettlementPrice
		DROP TABLE #tblContractFuture
		DROP TABLE #tblPIntransitView
		DROP TABLE #Temp
		DROP TABLE #tmpM2MBasisDetail
		DROP TABLE #RollNearbyMonth

		INSERT INTO tblRKM2MTransaction(intM2MHeaderId
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
			, dblResult
			, dblMarketFuturesResult
			, dblResultRatio
			, intSpreadMonthId
			, strSpreadMonth
			, dblSpreadMonthPrice
			, dblSpread)
		SELECT * FROM #tmpM2MTransaction

		-- Differential Basis
		DECLARE @strItemIds NVARCHAR(MAX)
			, @strPeriodTos NVARCHAR(MAX)
			, @strLocationIds NVARCHAR(MAX)
			, @strZoneIds NVARCHAR(MAX)
	
		--Get the unique items from transactions
		SELECT @strItemIds = COALESCE(@strItemIds + ', ', '') + ISNULL(intItemId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intItemId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intItemId) END AS intItemId FROM #tmpM2MTransaction
		) tbl
	
		SELECT @strPeriodTos = COALESCE(@strPeriodTos + ', ', '') + CONVERT(NVARCHAR(50), strPeriodTo)
		FROM (
			SELECT DISTINCT strPeriodTo FROM #tmpM2MTransaction
		) tbl
	
		SELECT @strLocationIds = COALESCE(@strLocationIds + ', ', '') + ISNULL(intCompanyLocationId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intLocationId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intLocationId) END AS intCompanyLocationId FROM #tmpM2MTransaction
		) tbl
	
		SELECT @strZoneIds = COALESCE(@strZoneIds + ', ', '') + ISNULL(intMarketZoneId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intMarketZoneId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intMarketZoneId) END AS intMarketZoneId FROM #tmpM2MTransaction
		) tbl

		IF @strEvaluationBy = 'Commodity'
		BEGIN
			SET @strItemIds = ''
		END
	
		IF @strEvaluationByZone = 'Location'
		BEGIN
			SET @strZoneIds = ''
		END
		ELSE IF @strEvaluationByZone = 'Company'
		BEGIN
			SET @strZoneIds = ''
			SET @strLocationIds = ''
		END

		IF @ysnEnterForwardCurveForMarketBasisDifferential = 0
		BEGIN
			SET @strPeriodTos = ''
		END
	
		SELECT intM2MHeaderId = @intM2MHeaderId
			, bd.intM2MBasisDetailId
			, c.strCommodityCode
			, i.strItemNo
			, strOriginDest = ca.strDescription
			, fm.strFutMarketName
			, strFutureMonth = ''
			, bd.strPeriodTo
			, strLocationName
			, strMarketZoneCode
			, strCurrency
			, strPricingType = CASE WHEN ISNULL(bd.intPricingTypeId, 0) <> 0 THEN pt.strPricingType ELSE b.strPricingType END
			, strContractInventory
			, strContractType
			, strUnitMeasure
			, bd.intCommodityId
			, bd.intItemId
			, bd.intFutureMarketId
			, bd.intFutureMonthId
			, bd.intCompanyLocationId
			, bd.intMarketZoneId
			, bd.intCurrencyId
			, bd.intPricingTypeId
			, bd.intContractTypeId
			, bd.dblCashOrFuture
			, bd.dblBasisOrDiscount
			, bd.dblRatio
			, bd.intUnitMeasureId
			, i.strMarketValuation
		INTO #tmpM2MDifferentialBasis
		FROM tblRKM2MBasis b
		JOIN tblRKM2MBasisDetail bd ON b.intM2MBasisId = bd.intM2MBasisId
		LEFT JOIN tblICCommodity c ON c.intCommodityId = bd.intCommodityId
		LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
		LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = i.intOriginId
		LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = bd.intFutureMarketId
		LEFT JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = bd.intCompanyLocationId
		LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = bd.intCurrencyId
		LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = bd.intPricingTypeId
		LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = bd.intContractTypeId
		LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = bd.intMarketZoneId
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = bd.intUnitMeasureId
		WHERE b.intM2MBasisId = @intM2MBasisId
			AND c.intCommodityId = ISNULL(@intCommodityId, c.intCommodityId)
			AND b.strPricingType = @strM2MType
			AND ISNULL(bd.intItemId, 0) IN (SELECT CASE WHEN @strItemIds = '' THEN ISNULL(bd.intItemId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strItemIds, ', ')) --added this be able to filter by item (RM-739)
			AND ISNULL(bd.strPeriodTo, '') IN (SELECT CASE WHEN @strPeriodTos = '' THEN ISNULL(bd.strPeriodTo, '') ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END FROM [dbo].[fnSplitString](@strPeriodTos, ', ')) --added this be able to filter by period to (RM-739)
			AND ISNULL(bd.intCompanyLocationId, 0) IN (SELECT CASE WHEN @strLocationIds = '' THEN ISNULL(bd.intCompanyLocationId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strLocationIds, ', ')) --added this be able to filter by item (RM-739)
			AND ISNULL(bd.intMarketZoneId, 0) IN (SELECT CASE WHEN @strZoneIds = '' THEN ISNULL(bd.intMarketZoneId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strZoneIds, ', ')) --added this be able to filter by item (RM-739)
			OR (bd.strContractInventory = 'Inventory' and b.intM2MBasisId = @intM2MBasisId
				AND c.intCommodityId = ISNULL(@intCommodityId, c.intCommodityId)
				AND b.strPricingType = @strM2MType)
		ORDER BY i.strMarketValuation
			, fm.strFutMarketName
			, strCommodityCode
			, strItemNo
			, strLocationName
			, CONVERT(DATETIME, '01 ' + strPeriodTo)

		INSERT INTO tblRKM2MDifferentialBasis(intM2MHeaderId
			, intM2MBasisDetailId
			, strOriginDest
			, strPeriodTo
			, strContractInventory
			, intCommodityId
			, intItemId
			, intFutureMarketId
			, intFutureMonthId
			, intMarketZoneId
			, intCurrencyId
			, intPricingTypeId
			, intContractTypeId
			, dblCashOrFuture
			, dblBasisOrDiscount
			, dblRatio
			, intUnitMeasureId)
		SELECT intM2MHeaderId
			, intM2MBasisDetailId
			, strOriginDest
			, strPeriodTo
			, strContractInventory
			, intCommodityId
			, intItemId
			, intFutureMarketId
			, intFutureMonthId
			, intMarketZoneId
			, intCurrencyId
			, intPricingTypeId
			, intContractTypeId
			, dblCashOrFuture
			, dblBasisOrDiscount
			, dblRatio
			, intUnitMeasureId
		FROM #tmpM2MDifferentialBasis

		-- Settlement Price
		DECLARE @tmpM2MSettlementPrice AS TABLE(intM2MHeaderId INT NULL
			, intFutureMarketId INT NULL
			, intFutureMonthId INT NULL
			, intFutSettlementPriceMonthId INT NULL
			, dblClosingPrice NUMERIC(18, 6) NULL)

		IF (@intMarkExpiredMonthPositionId = 2 OR @intMarkExpiredMonthPositionId = 3)
		BEGIN
			INSERT INTO @tmpM2MSettlementPrice
			SELECT intM2MHeaderId = @intM2MHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutSettlementPriceMonthId = NULL
				, dblClosingPrice
			FROM (
				SELECT f.intFutureMarketId
					, fm.intFutureMonthId
					, f.strFutMarketName
					, fm.strFutureMonth
					, dblClosingPrice = dbo.fnRKGetLatestClosingPrice(f.intFutureMarketId, fm.intFutureMonthId, @dtmSettlemntPriceDate)
				FROM tblRKFutureMarket f
				JOIN tblRKFuturesMonth fm ON f.intFutureMarketId = fm.intFutureMarketId AND fm.ysnExpired = 0
				JOIN tblRKCommodityMarketMapping mm ON fm.intFutureMarketId = mm.intFutureMarketId
				WHERE mm.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN mm.intCommodityId ELSE @intCommodityId END
			) t
			WHERE dblClosingPrice > 0
			ORDER BY strFutMarketName
				, CONVERT(DATETIME, '01 ' + strFutureMonth)
		END
		ELSE
		BEGIN		
			DECLARE @strFutureMonthIds NVARCHAR(MAX)
		
			SELECT @strFutureMonthIds = COALESCE(@strFutureMonthIds + ', ', '') + ISNULL(intFutureMonthId, '')
			FROM (
				SELECT DISTINCT CASE WHEN intFutureMonthId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intFutureMonthId) END AS intFutureMonthId
				FROM #tmpM2MTransaction
			) tbl

			INSERT INTO @tmpM2MSettlementPrice
			SELECT intM2MHeaderId = @intM2MHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutSettlementPriceMonthId
				, dblClosingPrice
			FROM (
				SELECT f.intFutureMarketId
					, fm.intFutureMonthId
					, f.strFutMarketName
					, fm.strFutureMonth
					, dblClosingPrice = t.dblLastSettle
					, intFutSettlementPriceMonthId = t.intFutureMonthId
				FROM tblRKFutureMarket f
				JOIN tblRKFuturesMonth fm ON f.intFutureMarketId = fm.intFutureMarketId
				JOIN tblRKCommodityMarketMapping mm ON fm.intFutureMarketId = mm.intFutureMarketId
				JOIN (
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
						AND ISNULL(p.strPricingType, @strM2MType) = @strM2MType
				) t ON t.intFutureMarketId = fm.intFutureMarketId AND t.intFutureMonthId = fm.intFutureMonthId
				WHERE mm.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN mm.intCommodityId ELSE @intCommodityId END
					AND ISNULL(fm.intFutureMonthId, 0) IN (SELECT CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END
															FROM [dbo].[fnSplitString](@strFutureMonthIds, ', '))
			) t WHERE dblClosingPrice > 0
			ORDER BY strFutMarketName
				, CONVERT(DATETIME, '01 ' + strFutureMonth)
		END

		INSERT INTO tblRKM2MSettlementPrice(intM2MHeaderId
			, intFutureMarketId
			, intFutureMonthId
			, intFutSettlementPriceMonthId
			, dblClosingPrice)
		SELECT intM2MHeaderId
			, intFutureMarketId
			, intFutureMonthId
			, intFutSettlementPriceMonthId
			, dblClosingPrice
		FROM @tmpM2MSettlementPrice

		-- Summary
		DECLARE @tmpM2MSummary TABLE (intM2MHeaderId INT NULL
			, strSummary NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intCommodityId INT
			, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, dblQty NUMERIC(24, 10)
			, dblTotal NUMERIC(24, 10)
			, dblFutures NUMERIC(24, 10)
			, dblBasis NUMERIC(24, 10)
			, dblCash NUMERIC(24, 10))

		INSERT INTO @tmpM2MSummary (intM2MHeaderId
			, strSummary
			, intCommodityId
			, strCommodityCode
			, strContractOrInventoryType
			, dblQty
			, dblTotal
			, dblFutures
			, dblBasis
			, dblCash)
		SELECT intM2MHeaderId = @intM2MHeaderId
			, strSummary = ''
			, intCommodityId = NULL
			, strCommodityCode = ''
			, strContractOrInventoryType = ''
			, dblQty = NULL
			, dblTotal = NULL
			, dblFutures = NULL
			, dblBasis = NULL
			, dblCash = NULL
		
		INSERT INTO @tmpM2MSummary (intM2MHeaderId
			, strSummary
			, intCommodityId
			, strCommodityCode
			, strContractOrInventoryType
			, dblQty
			, dblTotal
			, dblFutures
			, dblBasis
			, dblCash)
		SELECT intM2MHeaderId = @intM2MHeaderId
			, strSummary = CASE WHEN strContractOrInventoryType like 'Futures%' THEN 'Derivatives' ELSE 'Physical' END
			, intCommodityId
			, strCommodityCode
			, strContractOrInventoryType
			, dblQty = SUM(ISNULL(dblOpenQty, 0))
			, dblTotal = SUM(ISNULL(dblResult, 0))
			, dblFutures = SUM(ISNULL(dblMarketFuturesResult, 0))
			, dblBasis = SUM(ISNULL(dblResultBasis, 0))
			, dblCash = SUM(ISNULL(dblResultCash, 0))
		FROM #tmpM2MTransaction s
		GROUP BY intCommodityId
			, strCommodityCode
			, strContractOrInventoryType
		ORDER BY intCommodityId
			, strCommodityCode
			, strContractOrInventoryType		
		
		INSERT INTO @tmpM2MSummary (intM2MHeaderId
			, strSummary
			, dblQty
			, dblTotal
			, dblFutures
			, dblBasis
			, dblCash)
		SELECT intM2MHeaderId = @intM2MHeaderId
			, 'Total'
			, SUM(ISNULL(dblQty, 0))
			, SUM(ISNULL(dblTotal, 0))
			, SUM(ISNULL(dblFutures, 0))
			, SUM(ISNULL(dblBasis, 0))
			, SUM(ISNULL(dblCash, 0))
		FROM @tmpM2MSummary
	
		INSERT INTO @tmpM2MSummary(intM2MHeaderId
			, strSummary
			, dblQty
			, dblTotal
			, dblFutures
			, dblBasis
			, dblCash)
		SELECT intM2MHeaderId = @intM2MHeaderId
			, 'Total Summary'
			, SUM(ISNULL(dblQty, 0))
			, SUM(ISNULL(dblTotal, 0))
			, SUM(ISNULL(dblFutures, 0))
			, SUM(ISNULL(dblBasis, 0))
			, SUM(ISNULL(dblCash, 0))
		FROM @tmpM2MSummary
		WHERE strSummary = 'Total'

		INSERT INTO tblRKM2MSummary(intM2MHeaderId
			, strSummary
			, intCommodityId
			, strContractOrInventoryType
			, dblQty
			, dblTotal
			, dblFutures
			, dblBasis
			, dblCash)
		SELECT intM2MHeaderId
			, strSummary
			, intCommodityId
			, strContractOrInventoryType
			, dblQty
			, dblTotal
			, dblFutures
			, dblBasis
			, dblCash
		FROM @tmpM2MSummary

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

		IF (ISNULL(@ysnByProducer, 0) = 0)
		BEGIN
			INSERT INTO @tmpCPEDetail (intM2MHeaderId
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
			SELECT intM2MHeaderId = @intM2MHeaderId
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
			FROM (
				SELECT ch.intContractHeaderId
					, fd.strContractSeq
					, fd.strEntityName
					, fd.dblOpenQty
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
				JOIN tblCTContractDetail det ON fd.intContractDetailId = det.intContractDetailId
				JOIN tblCTContractHeader ch ON ch.intContractHeaderId = det.intContractHeaderId
				JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId
				JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
				JOIN tblAPVendor e ON e.intEntityId = fd.intEntityId
				LEFT JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = @intCommodityId AND cum.intUnitMeasureId = e.intRiskUnitOfMeasureId
				LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
				WHERE strContractOrInventoryType IN ('Contract(P)', 'In-transit(P)', 'Inventory (P)')
			) t
		END
		ELSE
		BEGIN
			INSERT INTO @tmpCPEDetail (intM2MHeaderId
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
			SELECT intM2MHeaderId = @intM2MHeaderId
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
																										, fd.dblOpenQty * (ISNULL(fd.dblContractBasis, 0) + ISNULL(fd.dblFuturePrice, 0))))
				FROM #tmpCPE fd
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
				WHERE strContractOrInventoryType IN ('Contract(P)', 'In-transit(P)', 'Inventory (P)')
			) t
		END

		INSERT INTO tblRKM2MCounterPartyExposure(intM2MHeaderId
			, intContractHeaderId
			, strContractSeq
			, strEntityName
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
			, dblUnfixedPurchaseValue)
		SELECT intM2MHeaderId
			, intContractHeaderId
			, strContractSeq
			, strEntityName
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
		FROM @tmpCPEDetail

		DROP TABLE #tmpCPE
		DROP TABLE #tmpM2MDifferentialBasis
		DROP TABLE #tmpM2MTransaction
	END
	ELSE
	BEGIN
		-- EXEC uspRKGetUnRealizedPNL
		DECLARE @DefaultCompanyId INT
			, @DefaultCompanyName NVARCHAR(200)
			, @intWeightUOMId INT
			, @strWeightUOM NVARCHAR(200)

		SELECT @intWeightUOMId = ISNULL(intWeightUOMId, 0) FROM tblLGCompanyPreference
		SELECT @strWeightUOM = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = @intWeightUOMId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMultiCompany WHERE ISNULL(intMultiCompanyParentId, 0) <> 0)
		BEGIN
			SELECT @DefaultCompanyId = intMultiCompanyId
				, @DefaultCompanyName = strCompanyName
			FROM tblSMMultiCompany
			SET @intCompanyId = 0
		END
	
		/*
				intTransactionType	ShipmentStatus(intShipmentStatus) ShipmentType(intShipmentType)		LoadType(intPurchaseSale) 
				1 - Contract		1 - Scheduled						1 - Shipment					 1 - Inbound
				2 - InTransit		2 - Dispatched						2 - Shipping Instructions			2 - Outbound
				3 - Inventory		3 - Inbound transit												 3 - Drop Ship
				4 - FG Lots			4 - Received
									5 - Outbound transit
									6 - Delivered
									7 - Instruction created
									8 - Partial Shipment Created
									9 - Full Shipment Created
									10 - Cancelled 
									11 - Invoiced
		*/
	
		DECLARE @tblSettlementPrice TABLE (intFutureMarketId INT
			, intFutureMonthId INT
			, dblSettlementPrice NUMERIC(38, 20))
	
		DECLARE @tblRKM2MBasisDetail AS TABLE (intM2MBasisDetailId INT
			, intM2MBasisId INT
			, intItemId INT
			, intFutureMarketId INT
			, intFutureMonthId INT
			, strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, intCompanyLocationId INT
			, intPricingTypeId INT
			, intContractTypeId INT
			, dblBasisOrDiscount NUMERIC(38, 20))
	
		DECLARE @tblContractCost TABLE (intContractDetailId INT
			, dblRate NUMERIC(18, 6)
			, ysnAccrue BIT
			, dblTotalCost NUMERIC(38, 20))
	
		DECLARE @tblFutureMonthByMarket TABLE (Row_Num INT
			, intFutureMarketId INT
			, intFutureMonthId NUMERIC(38, 20))
	
		DECLARE @tblFutureSettlementMonth TABLE (Row_Num INT
			, intFutureMarketId INT
			, intFutureMonthId NUMERIC(38, 20))
	
		DECLARE @tblPostedLoad TABLE (intContractTypeId INT
			, intContractDetailId INT
			, dblPostedQuantity NUMERIC(38, 20))
	
		DECLARE @tblCurrencyExchange TABLE (RowNum INT
			, intFromCurrencyId INT
			, dblRate NUMERIC(38, 20))
	
		DECLARE @tblUnRealizedPNL AS TABLE (intM2MHeaderId INT
			, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intContractTypeId INT
			, intContractHeaderId INT
			, strContractType NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intFreightTermId INT
			, intTransactionType INT
			, strTransaction NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, intContractDetailId INT
			, intCurrencyId INT
			, intFutureMarketId INT
			, strFutureMarket NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intFutureMarketUOMId INT
			, intFutureMarketUnitMeasureId INT
			, strFutureMarketUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intMarketCurrencyId INT
			, intFutureMonthId INT
			, strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intItemId INT
			, intBookId INT
			, strBook NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strSubBook NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intCommodityId INT
			, strCommodity NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dtmReceiptDate DATETIME		
			, dtmContractDate DATETIME
			, strContract NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intContractSeq INT
			, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strInternalCompany NVARCHAR(20) COLLATE Latin1_General_CI_AS
			, dblQuantity NUMERIC(38, 20)
			, intQuantityUOMId INT
			, intQuantityUnitMeasureId INT
			, strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dblWeight NUMERIC(38, 20)
			, intWeightUOMId INT
			, intWeightUnitMeasureId INT
			, strWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dblBasis NUMERIC(38, 20)
			, intBasisUOMId INT
			, intBasisUnitMeasureId INT
			, strBasisUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dblFutures NUMERIC(38, 20)
			, dblCashPrice NUMERIC(38, 20)
			, intPriceUOMId INT
			, intPriceUnitMeasureId INT
			, strContractPriceUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intOriginId INT
			, strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strItemDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strCropYear NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strProductionLine NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strCertification NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strTerms NVARCHAR(50) COLLATE Latin1_General_CI_AS	
			, strPosition NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dtmStartDate DATETIME
			, dtmEndDate DATETIME
			, strBLNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dtmBLDate DATETIME
			, strAllocationRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strAllocationStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strPriceTerms NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dblContractDifferential NUMERIC(38, 20)
			, strContractDifferentialUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dblFuturesPrice NUMERIC(38, 20)
			, strFuturesPriceUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strFixationDetails NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, dblFixedLots NUMERIC(38, 20)
			, dblUnFixedLots NUMERIC(38, 20)
			, dblContractInvoiceValue NUMERIC(38, 20)
			, dblSecondaryCosts NUMERIC(38, 20)
			, dblCOGSOrNetSaleValue NUMERIC(38, 20)
			, dblInvoicePrice NUMERIC(38, 20)
			, dblInvoicePaymentPrice NUMERIC(38, 20)
			, strInvoicePriceUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, dblInvoiceValue NUMERIC(38, 20)
			, strInvoiceCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, dblNetMarketValue NUMERIC(38, 20)
			, dtmRealizedDate DATETIME
			, dblRealizedQty NUMERIC(38, 20)
			, dblProfitOrLossValue NUMERIC(38, 20)
			, dblPAndLinMarketUOM NUMERIC(38, 20)
			, dblPAndLChangeinMarketUOM NUMERIC(38, 20)
			, strMarketCurrencyUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strTrader NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strFixedBy NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strInvoiceStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strWarehouse NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strCPAddress NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strCPCountry NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strCPRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, intContractStatusId INT
			, intPricingTypeId INT
			, strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, strPricingStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
			, dblMarketDifferential NUMERIC(38, 20)
			, dblNetM2MPrice NUMERIC(38, 20)
			, dblSettlementPrice NUMERIC(38, 20)
			, intCompanyId INT
			, strCompanyName NVARCHAR(100) COLLATE Latin1_General_CI_AS)
	
		INSERT INTO @tblFutureMonthByMarket (Row_Num
			, intFutureMarketId
			, intFutureMonthId)
		SELECT Row_Num
			, intFutureMarketId
			, intFutureMonthId
		FROM (
			SELECT Row_Number() OVER (PARTITION BY intFutureMarketId ORDER BY intFutureMonthId DESC) AS Row_Num
				, intFutureMarketId
				, intFutureMonthId
			FROM tblRKFuturesMonth 
			WHERE ysnExpired = 0 AND dtmSpotDate < = GETDATE()	
		) t1 WHERE Row_Num = 1

		INSERT INTO @tblFutureSettlementMonth (Row_Num
			, intFutureMarketId
			, intFutureMonthId)
		SELECT Row_Num
			, intFutureMarketId
			, intFutureMonthId
		FROM (
			SELECT ROW_NUMBER() OVER (PARTITION BY intFutureMarketId ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth) ASC) AS Row_Num
				, intFutureMarketId
				, intFutureMonthId
			FROM tblRKFuturesMonth 
			WHERE ysnExpired = 0 AND CONVERT(DATETIME, '01 ' + strFutureMonth) > GETDATE()
		) t2 WHERE Row_Num = 1;
	
		INSERT INTO @tblCurrencyExchange (RowNum
			, intFromCurrencyId
			, dblRate)
		SELECT RowNum
			, intFromCurrencyId
			, dblRate
		FROM (
			SELECT ROW_NUMBER() OVER(PARTITION BY CERD.intCurrencyExchangeRateId ORDER BY dtmValidFromDate DESC) AS RowNum
				, CER.intFromCurrencyId
				, CERD.dblRate
			FROM tblSMCurrencyExchangeRateDetail CERD 
			JOIN tblSMCurrencyExchangeRate CER ON CER.intCurrencyExchangeRateId = CERD.intCurrencyExchangeRateId
			WHERE CER.intToCurrencyId = @intCurrencyId
		) t3 WHERE RowNum = 1
	
		INSERT INTO @tblPostedLoad(intContractTypeId
			, intContractDetailId
			, dblPostedQuantity)
		SELECT intContractTypeId = 1
			, intContractDetailId = LD.intPContractDetailId
			, dblPostedQuantity = SUM(LD.dblQuantity)
		FROM tblLGLoadDetail LD
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6, 3) AND L.intShipmentType = 1
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		GROUP BY LD.intPContractDetailId
	
		UNION ALL SELECT intContractTypeId = 2
			, intContractDetailId = LD.intSContractDetailId
			, dblPostedQuantity = SUM(LD.dblQuantity)
		FROM tblLGLoadDetail LD
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6, 3) AND L.intShipmentType = 1 AND L.intPurchaseSale = 3
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
		GROUP BY LD.intSContractDetailId
	
		UNION ALL SELECT intContractTypeId = 3
			, intContractDetailId = LD.intSContractDetailId
			, dblPostedQuantity = SUM(LD.dblQuantity)
		FROM tblLGLoadDetail LD
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6) AND L.intShipmentType = 1 AND L.intPurchaseSale = 2
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
		GROUP BY LD.intSContractDetailId
	
		INSERT INTO @tblUnRealizedPNL (intM2MHeaderId
			, strType
			, intContractTypeId
			, intContractHeaderId
			, strContractType
			, strContractNumber
			, intFreightTermId
			, intTransactionType
			, strTransaction
			, strTransactionType
			, intContractDetailId
			, intCurrencyId
			, intFutureMarketId
			, strFutureMarket
			, intFutureMarketUOMId
			, intFutureMarketUnitMeasureId
			, strFutureMarketUOM
			, intMarketCurrencyId
			, intFutureMonthId
			, strFutureMonth
			, intItemId
			, intBookId
			, strBook
			, strSubBook
			, intCommodityId
			, strCommodity
			, dtmReceiptDate
			, dtmContractDate
			, strContract
			, intContractSeq
			, strEntityName
			, strInternalCompany
			, dblQuantity
			, intQuantityUOMId
			, intQuantityUnitMeasureId
			, strQuantityUOM
			, dblWeight
			, intWeightUOMId
			, intWeightUnitMeasureId
			, strWeightUOM
			, dblBasis
			, intBasisUOMId
			, intBasisUnitMeasureId
			, strBasisUOM
			, dblFutures
			, dblCashPrice
			, intPriceUOMId
			, intPriceUnitMeasureId
			, strContractPriceUOM
			, intOriginId
			, strOrigin
			, strItemDescription
			, strCropYear
			, strProductionLine
			, strCertification
			, strTerms
			, strPosition
			, dtmStartDate
			, dtmEndDate
			, strBLNumber
			, dtmBLDate
			, strAllocationRefNo
			, strAllocationStatus
			, strPriceTerms
			, dblContractDifferential
			, strContractDifferentialUOM
			, dblFuturesPrice
			, strFuturesPriceUOM
			, strFixationDetails
			, dblFixedLots
			, dblUnFixedLots
			, dblContractInvoiceValue
			, dblSecondaryCosts
			, dblCOGSOrNetSaleValue
			, dblInvoicePrice
			, dblInvoicePaymentPrice
			, strInvoicePriceUOM
			, dblInvoiceValue
			, strInvoiceCurrency
			, dblNetMarketValue
			, dtmRealizedDate
			, dblRealizedQty
			, dblProfitOrLossValue
			, dblPAndLinMarketUOM
			, dblPAndLChangeinMarketUOM
			, strMarketCurrencyUOM
			, strTrader
			, strFixedBy
			, strInvoiceStatus
			, strWarehouse
			, strCPAddress
			, strCPCountry
			, strCPRefNo
			, intContractStatusId
			, intPricingTypeId
			, strPricingType
			, strPricingStatus
			, intCompanyId
			, strCompanyName)
		---Contract---
		SELECT @intM2MHeaderId
			, strType = 'Unrealized' COLLATE Latin1_General_CI_AS
			, intContractTypeId = CH.intContractTypeId
			, intContractHeaderId = CH.intContractHeaderId
			, strContractType = TP.strContractType
			, strContractNumber = CH.strContractNumber
			, intFreightTermId = CH.intFreightTermId
			, intTransactionType = 1
			, strTransaction = '1.Contract' COLLATE Latin1_General_CI_AS
			, strTransactionType = ('Contract(' + CASE WHEN CH.intContractTypeId = 1 THEN 'P'
													WHEN CH.intContractTypeId = 2 THEN 'S' END + ')') COLLATE Latin1_General_CI_AS
			, intContractDetailId = CD.intContractDetailId
			, intCurrencyId = CD.intCurrencyId
			, intFutureMarketId = CD.intFutureMarketId
			, strFutureMarket = Market.strFutMarketName
			, intFutureMarketUOMId = NULL
			, intFutureMarketUnitMeasureId = Market.intUnitMeasureId
			, strFutureMarketUOM = MarketUOM.strUnitMeasure
			, intMarketCurrencyId = Market.intCurrencyId
			, intFutureMonthId = FMonth.intFutureMonthId
			, strFutureMonth = FMonth.strFutureMonth
			, intItemId = CD.intItemId
			, intBookId = Book.intBookId
			, strBook = Book.strBook
			, strSubBook = SubBook.strSubBook
			, intCommodityId = Commodity.intCommodityId
			, strCommodity = Commodity.strDescription
			, dtmReceiptDate = NULL
			, dtmContractDate = CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
			, strContract = (CH.strContractNumber + '-' + LTRIM(CD.intContractSeq)) COLLATE Latin1_General_CI_AS
			, intContractSeq = CD.intContractSeq
			, strEntityName = Entity.strEntityName
			, strInternalCompany = CASE WHEN ISNULL(BVE.intEntityId, 0) >0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
			, dblQuantity = ISNULL(CD.dblBalance, 0) + (ISNULL(L.dblPostedQuantity, 0) * CASE WHEN L.intContractTypeId = 3 THEN 1 ELSE -1 END)
			, intQuantityUOMId = CD.intItemUOMId
			, intQuantityUnitMeasureId = IUM.intUnitMeasureId
			, strQuantityUOM = IUM.strUnitMeasure
			, dblWeight = NULL ---CD.dblNetWeightr
			, intWeightUOMId = NULL ---CD.intNetWeightUOMId
			, intWeightUnitMeasureId = NULL ---WUM.intUnitMeasureId
			, strWeightUOM = NULL ---WUM.strUnitMeasure
			, dblBasis = CD.dblBasis
			, intBasisUOMId = CD.intBasisUOMId
			, intBasisUnitMeasureId = BASISUOM.intUnitMeasureId
			, strBasisUOM = BUOM.strUnitMeasure
			, dblFutures = ISNULL(CD.dblFutures, 0)
			, dblCashPrice = ISNULL(CD.dblCashPrice, 0)
			, intPriceUOMId = CD.intPriceItemUOMId
			, intPriceUnitMeasureId = PriceUOM.intUnitMeasureId
			, strContractPriceUOM = PUOM.strUnitMeasure
			, intOriginId = Item.intOriginId
			, strOrigin = ISNULL(RY.strCountry, OG.strCountry)
			, strItemDescription = Item.strDescription
			, strCropYear = CropYear.strCropYear
			, strProductionLine = CPL.strDescription
			, strCertification = NULL
			, strTerms = ISNULL(CB.strContractBasis, '') + ', ' + ISNULL(Term.strTerm, '') + ', ' + ISNULL(WG.strWeightGradeDesc, '') COLLATE Latin1_General_CI_AS
			, strPosition = PO.strPosition
			, dtmStartDate = CD.dtmStartDate
			, dtmEndDate = CD.dtmEndDate
			, strBLNumber = NULL
			, dtmBLDate = NULL
			, strAllocationRefNo = NULL
			, strAllocationStatus = CASE WHEN CH.intContractTypeId = 1 THEN 'L'
										WHEN CH.intContractTypeId = 2 THEN 'S' END COLLATE Latin1_General_CI_AS
			, strPriceTerms = CASE WHEN CD.intPricingTypeId = 2 THEN 'Unfixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblBasis) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure
								ELSE 'Fixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure + ' '
									 + [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure END COLLATE Latin1_General_CI_AS
			, dblContractDifferential = CD.dblBasis
			, strContractDifferentialUOM = (BCY.strCurrency + '/' + BUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, dblFuturesPrice = ISNULL(CD.dblFutures, 0)
			, strFuturesPriceUOM = (CY.strCurrency + '/' + PUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strFixationDetails = NULL
			, dblFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL(PF.dblLotsFixed, 0) ELSE 0 END
			, dblUnFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL((ISNULL(CD.[dblNoOfLots], 0) -ISNULL(PF.dblLotsFixed, 0)), 0) ELSE 0 END
			, dblContractInvoiceValue = NULL
			, dblSecondaryCosts = 0
			, dblCOGSOrNetSaleValue = NULL
			, dblInvoicePrice = NULL
			, dblInvoicePaymentPrice = NULL
			, strInvoicePriceUOM = NULL
			, dblInvoiceValue = NULL
			, strInvoiceCurrency = NULL
			, dblNetMarketValue = NULL
			, dtmRealizedDate = NULL
			, dblRealizedQty = NULL
			, dblProfitOrLossValue = NULL
			, dblPAndLinMarketUOM = NULL
			, dblPAndLChangeinMarketUOM = NULL
			, strMarketCurrencyUOM = (MarketCY.strCurrency + '/' + MarketUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strTrader = SP.strName 
			, strFixedBy = CD.strFixationBy
			, strInvoiceStatus = NULL
			, strWarehouse = NULL
			, strCPAddress = Entity.strEntityAddress 
			, strCPCountry = Entity.strEntityCountry	
			, strCPRefNo = CH.strCustomerContract
			, intContractStatusId = CD.intContractStatusId
			, intPricingTypeId = CD.intPricingTypeId
			, strPricingType = PT.strPricingType
			, strPricingStatus = CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced' ELSE '' END COLLATE Latin1_General_CI_AS
			, intCompanyId = Company.intMultiCompanyId
			, strCompanyName = Company.strCompanyName
		FROM tblCTContractHeader				CH
		JOIN tblCTContractDetail				CD				 ON CH.intContractHeaderId			 = CD.intContractHeaderId
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId		 = CH.intCommodityId
		JOIN tblCTContractType					TP				 ON TP.intContractTypeId			 = CH.intContractTypeId
		JOIN vyuCTEntity						Entity			 ON Entity.intEntityId				 = CH.intEntityId
			AND Entity.strEntityType = CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor'
											WHEN CH.intContractTypeId = 2 THEN 'Customer' END
		JOIN tblRKFutureMarket					Market			 ON Market.intFutureMarketId		 = CD.intFutureMarketId
		JOIN tblRKFuturesMonth					FMonth			 ON FMonth.intFutureMonthId		 = CD.intFutureMonthId
		JOIN tblICUnitMeasure					MarketUOM		 ON	MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId
		JOIN tblSMCurrency						MarketCY		 ON	MarketCY.intCurrencyID			 = Market.intCurrencyId
		JOIN tblICItem							Item			 ON Item.intItemId					 = CD.intItemId
		JOIN tblSMCompanyLocation				CL				 ON CL.intCompanyLocationId			 = CD.intCompanyLocationId
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		LEFT JOIN @tblPostedLoad L				 ON L.intContractTypeId			 = CH.intContractTypeId AND L.intContractDetailId = CD.intContractDetailId
		LEFT JOIN tblSMCurrency					CY				 ON	CY.intCurrencyID				 = CD.intCurrencyId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId AND	CA.strType = 'Origin'
		LEFT JOIN tblSMCountry					OG				 ON	OG.intCountryID					 = 	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblSMFreightTerms				CB				 ON CB.intFreightTermId			 = CH.intFreightTermId
		LEFT JOIN tblSMTerm						Term			 ON Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		 = CD.intItemUOMId
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		 = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN tblICItemContract				IC				 ON	IC.intItemContractId			 = CD.intItemContractId
		LEFT JOIN tblSMCountry					RY				 ON	RY.intCountryID					 = IC.intCountryId
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = CH.intCompanyId
		WHERE CH.intCommodityId = ISNULL(@intCommodityId, CH.intCommodityId)
			AND CD.dblQuantity > ISNULL(CD.dblInvoicedQty, 0)
			AND CL.intCompanyLocationId = ISNULL(@intLocationId, CL.intCompanyLocationId)
			AND intContractStatusId NOT IN (2, 3, 6)
			AND ISNULL(CD.dblBalance, 0)-ISNULL(L.dblPostedQuantity, 0)>0
			AND ISNULL(CH.intCompanyId, 0) = ISNULL(@intCompanyId, ISNULL(CH.intCompanyId, 0))
	
		---InTransit-----
		UNION ALL SELECT @intM2MHeaderId
			, strType = CASE WHEN ISNULL(Invoice.strType, '') = 'Provisional' THEN 'Realized Not Fixed' ELSE 'Unrealized' END COLLATE Latin1_General_CI_AS
			, intContractTypeId = CH.intContractTypeId
			, intContractHeaderId = CH.intContractHeaderId
			, strContractType = TP.strContractType
			, strContractNumber = CH.strContractNumber
			, intFreightTermId = CH.intFreightTermId
			, intTransactionType = 2
			, strTransaction = '2.In-transit' COLLATE Latin1_General_CI_AS
			, strTransactionType = 'In-transit(P)' COLLATE Latin1_General_CI_AS
			, intContractDetailId = CD.intContractDetailId
			, intCurrencyId = CD.intCurrencyId	
			, intFutureMarketId = CD.intFutureMarketId
			, strFutureMarket = Market.strFutMarketName
			, intFutureMarketUOMId = NULL
			, intFutureMarketUnitMeasureId = Market.intUnitMeasureId
			, strFutureMarketUOM = MarketUOM.strUnitMeasure
			, intMarketCurrencyId = Market.intCurrencyId
			, intFutureMonthId = FMonth.intFutureMonthId
			, strFutureMonth = FMonth.strFutureMonth
			, intItemId = CD.intItemId
			, intBookId = Book.intBookId
			, strBook = Book.strBook
			, strSubBook = SubBook.strSubBook
			, intCommodityId = Commodity.intCommodityId
			, strCommodity = Commodity.strDescription
			, dtmReceiptDate = NULL		
			, dtmContractDate = CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
			, strContract = (CH.strContractNumber + '-' + LTRIM(CD.intContractSeq)) COLLATE Latin1_General_CI_AS
			, intContractSeq = CD.intContractSeq
			, strEntityName = Entity.strEntityName
			, strInternalCompany = CASE WHEN ISNULL(BVE.intEntityId, 0) >0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
			, dblQuantity = LD.dblQuantity --SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId)
			, intQuantityUOMId = CD.intItemUOMId
			, intQuantityUnitMeasureId = IUM.intUnitMeasureId
			, strQuantityUOM = IUM.strUnitMeasure
			, dblWeight = NULL ---CD.dblNetWeight
			, intWeightUOMId = NULL ---CD.intNetWeightUOMId
			, intWeightUnitMeasureId = NULL ---WUM.intUnitMeasureId
			, strWeightUOM = NULL ---WUM.strUnitMeasure
			, dblBasis = CD.dblBasis
			, intBasisUOMId = CD.intBasisUOMId
			, intBasisUnitMeasureId = BUOM.intUnitMeasureId
			, strBasisUOM = BUOM.strUnitMeasure
			, dblFutures = ISNULL(CD.dblFutures, 0)
			, dblCashPrice = ISNULL(CD.dblCashPrice, 0)
			, intPriceUOMId = CD.intPriceItemUOMId
			, intPriceUnitMeasureId = PriceUOM.intUnitMeasureId
			, strContractPriceUOM = PUOM.strUnitMeasure
			, intOriginId = Item.intOriginId
			, strOrigin = ISNULL(RY.strCountry, OG.strCountry)
			, strItemDescription = Item.strDescription
			, strCropYear = CropYear.strCropYear
			, strProductionLine = CPL.strDescription
			, strCertification = NULL
			, strTerms = (ISNULL(CB.strContractBasis, '') + ', ' + ISNULL(Term.strTerm, '') + ', ' + ISNULL(WG.strWeightGradeDesc, '')) COLLATE Latin1_General_CI_AS
			, strPosition = PO.strPosition
			, dtmStartDate = CD.dtmStartDate
			, dtmEndDate = CD.dtmEndDate
			, strBLNumber = L.strBLNumber
			, dtmBLDate = L.dtmBLDate
			, strAllocationRefNo = NULL
			, strAllocationStatus = CASE WHEN CH.intContractTypeId = 1 THEN 'L'
										WHEN CH.intContractTypeId = 2 THEN 'S' END COLLATE Latin1_General_CI_AS
			, strPriceTerms = CASE WHEN CD.intPricingTypeId = 2 THEN 'Unfixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblBasis) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure
								ELSE 'Fixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure + ' '
									 + [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure END COLLATE Latin1_General_CI_AS
			, dblContractDifferential = CD.dblBasis
			, strContractDifferentialUOM = (BCY.strCurrency + '/' + BUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, dblFuturesPrice = ISNULL(CD.dblFutures, 0)
			, strFuturesPriceUOM = (CY.strCurrency + '/' + PUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strFixationDetails = NULL
			, dblFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL(PF.dblLotsFixed, 0) ELSE 0 END
			, dblUnFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL((ISNULL(CD.[dblNoOfLots], 0) -ISNULL(PF.dblLotsFixed, 0)), 0) ELSE 0 END
			, dblContractInvoiceValue = NULL
			, dblSecondaryCosts = 0
			, dblCOGSOrNetSaleValue = NULL
			, dblInvoicePrice = NULL
			, dblInvoicePaymentPrice = NULL
			, strInvoicePriceUOM = NULL
			, dblInvoiceValue = NULL
			, strInvoiceCurrency = NULL
			, dblNetMarketValue = NULL
			, dtmRealizedDate = CONVERT(DATETIME, CONVERT(VARCHAR, Invoice.dtmPostDate, 101), 101)
			, dblRealizedQty = NULL
			, dblProfitOrLossValue = NULL
			, dblPAndLinMarketUOM = NULL
			, dblPAndLChangeinMarketUOM = NULL
			, strMarketCurrencyUOM = (MarketCY.strCurrency + '/' + MarketUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strTrader = SP.strName 
			, strFixedBy = CD.strFixationBy
			, strInvoiceStatus = Invoice.strType
			, strWarehouse = NULL
			, strCPAddress = Entity.strEntityAddress 
			, strCPCountry = Entity.strEntityCountry	
			, strCPRefNo = CH.strCustomerContract
			, intContractStatusId = CD.intContractStatusId
			, intPricingTypeId = CD.intPricingTypeId
			, strPricingType = PT.strPricingType
			, strPricingStatus = CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced'ELSE '' END COLLATE Latin1_General_CI_AS
			, intCompanyId = Company.intMultiCompanyId
			, strCompanyName = Company.strCompanyName
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId 
									AND ysnPosted = 1 
									AND L.intShipmentStatus IN (6, 3) -- 1.purchase 2.outbound
									AND L.intPurchaseSale = 1
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader				CH				 ON CH.intContractHeaderId			 = CD.intContractHeaderId	
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId		 = CH.intCommodityId
		JOIN tblCTContractType					TP				 ON TP.intContractTypeId			 = CH.intContractTypeId		
		JOIN vyuCTEntity						Entity			 ON Entity.intEntityId				 = CH.intEntityId
																		AND Entity.strEntityType = CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor'
																									WHEN CH.intContractTypeId = 2 THEN 'Customer' END
		JOIN tblRKFutureMarket					Market			 ON Market.intFutureMarketId		 = CD.intFutureMarketId
		JOIN tblRKFuturesMonth					FMonth			 ON FMonth.intFutureMonthId		 = CD.intFutureMonthId
		JOIN tblSMCurrency						MarketCY		 ON	 MarketCY.intCurrencyID			 = Market.intCurrencyId
		JOIN tblICUnitMeasure					MarketUOM		 ON	 MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId		
		JOIN tblICItem							Item			 ON Item.intItemId					 = CD.intItemId
		JOIN tblSMCompanyLocation				CL				 ON CL.intCompanyLocationId			 = CD.intCompanyLocationId
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		LEFT JOIN tblSMCurrency					CY				 ON	CY.intCurrencyID				 = CD.intCurrencyId
		LEFT JOIN tblARInvoiceDetail			InvoiceDetail ON InvoiceDetail.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN tblARInvoice				 Invoice			 ON Invoice.intInvoiceId			 = InvoiceDetail.intInvoiceId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType					 = 'Origin'
		LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID					 = 	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId	
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblSMFreightTerms				CB				 ON CB.intFreightTermId			 = CH.intFreightTermId
		LEFT JOIN tblSMTerm						Term			 ON Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		 = CD.intItemUOMId
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		 = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC	ON	IC.intItemContractId						 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY	ON	RY.intCountryID								 = IC.intCountryId
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = L.intCompanyId
		WHERE CH.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN CH.intCommodityId
									ELSE @intCommodityId END
			AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId
											ELSE @intLocationId END
			AND ISNULL(L.intCompanyId, 0) = CASE WHEN ISNULL(@intCompanyId, 0) = 0 THEN ISNULL(L.intCompanyId, 0)
											ELSE @intCompanyId END

		---Delivered Not Invoiced (S)-----
		UNION ALL SELECT @intM2MHeaderId
			, strType = CASE WHEN ISNULL(Invoice.strType, '') = 'Provisional' THEN 'Realized Not Fixed' ELSE 'Unrealized' END COLLATE Latin1_General_CI_AS
			, intContractTypeId = CH.intContractTypeId
			, intContractHeaderId = CH.intContractHeaderId
			, strContractType = TP.strContractType
			, strContractNumber = CH.strContractNumber
			, intFreightTermId = CH.intFreightTermId
			, intTransactionType = 5
			, strTransaction = '5.Delivered Not Invoiced' COLLATE Latin1_General_CI_AS
			, strTransactionType = 'Delivered Not Invoiced (S)' COLLATE Latin1_General_CI_AS
			, intContractDetailId = CD.intContractDetailId
			, intCurrencyId = CD.intCurrencyId	
			, intFutureMarketId = CD.intFutureMarketId
			, strFutureMarket = Market.strFutMarketName
			, intFutureMarketUOMId = NULL
			, intFutureMarketUnitMeasureId = Market.intUnitMeasureId
			, strFutureMarketUOM = MarketUOM.strUnitMeasure
			, intMarketCurrencyId = Market.intCurrencyId
			, intFutureMonthId = FMonth.intFutureMonthId
			, strFutureMonth = FMonth.strFutureMonth
			, intItemId = CD.intItemId
			, intBookId = Book.intBookId
			, strBook = Book.strBook
			, strSubBook = SubBook.strSubBook
			, intCommodityId = Commodity.intCommodityId
			, strCommodity = Commodity.strDescription
			, dtmReceiptDate = NULL		
			, dtmContractDate = CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
			, strContract = (CH.strContractNumber + '-' + LTRIM(CD.intContractSeq)) COLLATE Latin1_General_CI_AS
			, intContractSeq = CD.intContractSeq
			, strEntityName = Entity.strEntityName
			, strInternalCompany = CASE WHEN ISNULL(BVE.intEntityId, 0) >0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
			, dblQuantity = LD.dblQuantity 
			, intQuantityUOMId = CD.intItemUOMId
			, intQuantityUnitMeasureId = IUM.intUnitMeasureId
			, strQuantityUOM = IUM.strUnitMeasure
			, dblWeight = NULL
			, intWeightUOMId = NULL
			, intWeightUnitMeasureId = NULL
			, strWeightUOM = NULL
			, dblBasis = CD.dblBasis
			, intBasisUOMId = CD.intBasisUOMId
			, intBasisUnitMeasureId = BUOM.intUnitMeasureId
			, strBasisUOM = BUOM.strUnitMeasure
			, dblFutures = ISNULL(CD.dblFutures, 0)
			, dblCashPrice = ISNULL(CD.dblCashPrice, 0)
			, intPriceUOMId = CD.intPriceItemUOMId
			, intPriceUnitMeasureId = PriceUOM.intUnitMeasureId
			, strContractPriceUOM = PUOM.strUnitMeasure
			, intOriginId = Item.intOriginId
			, strOrigin = ISNULL(RY.strCountry, OG.strCountry)
			, strItemDescription = Item.strDescription
			, strCropYear = CropYear.strCropYear
			, strProductionLine = CPL.strDescription
			, strCertification = NULL
			, strTerms = (ISNULL(CB.strContractBasis, '') + ', ' + ISNULL(Term.strTerm, '') + ', ' + ISNULL(WG.strWeightGradeDesc, '')) COLLATE Latin1_General_CI_AS
			, strPosition = PO.strPosition
			, dtmStartDate = CD.dtmStartDate
			, dtmEndDate = CD.dtmEndDate
			, strBLNumber = L.strBLNumber
			, dtmBLDate = L.dtmBLDate
			, strAllocationRefNo = NULL
			, strAllocationStatus = CASE WHEN CH.intContractTypeId = 1 THEN 'L'
										WHEN CH.intContractTypeId = 2 THEN 'S' END COLLATE Latin1_General_CI_AS
			, strPriceTerms = CASE WHEN CD.intPricingTypeId = 2 THEN 'Unfixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblBasis) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure
								ELSE 'Fixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure + ' '
									+ [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure END COLLATE Latin1_General_CI_AS
			, dblContractDifferential = CD.dblBasis
			, strContractDifferentialUOM = (BCY.strCurrency + '/' + BUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, dblFuturesPrice = ISNULL(CD.dblFutures, 0)
			, strFuturesPriceUOM = (CY.strCurrency + '/' + PUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strFixationDetails = NULL
			, dblFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL(PF.dblLotsFixed, 0) ELSE 0 END
			, dblUnFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL((ISNULL(CD.[dblNoOfLots], 0) -ISNULL(PF.dblLotsFixed, 0)), 0) ELSE 0 END
			, dblContractInvoiceValue = NULL
			, dblSecondaryCosts = 0
			, dblCOGSOrNetSaleValue = NULL
			, dblInvoicePrice = NULL
			, dblInvoicePaymentPrice = NULL
			, strInvoicePriceUOM = NULL
			, dblInvoiceValue = NULL
			, strInvoiceCurrency = NULL
			, dblNetMarketValue = NULL
			, dtmRealizedDate = CONVERT(DATETIME, CONVERT(VARCHAR, Invoice.dtmPostDate, 101), 101)
			, dblRealizedQty = NULL
			, dblProfitOrLossValue = NULL
			, dblPAndLinMarketUOM = NULL
			, dblPAndLChangeinMarketUOM = NULL
			, strMarketCurrencyUOM = (MarketCY.strCurrency + '/' + MarketUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strTrader = SP.strName 
			, strFixedBy = CD.strFixationBy
			, strInvoiceStatus = Invoice.strType
			, strWarehouse = NULL
			, strCPAddress = Entity.strEntityAddress 
			, strCPCountry = Entity.strEntityCountry	
			, strCPRefNo = CH.strCustomerContract
			, intContractStatusId = CD.intContractStatusId
			, intPricingTypeId = CD.intPricingTypeId
			, strPricingType = PT.strPricingType
			, strPricingStatus = CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced'ELSE '' END COLLATE Latin1_General_CI_AS
			, intCompanyId = Company.intMultiCompanyId
			, strCompanyName = Company.strCompanyName

		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6) -- 1.purchase 2.outbound
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
		JOIN tblCTContractHeader				CH				 ON CH.intContractHeaderId			 = CD.intContractHeaderId	
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId		 = CH.intCommodityId
		JOIN tblCTContractType					TP				 ON TP.intContractTypeId			 = CH.intContractTypeId		
		JOIN vyuCTEntity						Entity			 ON Entity.intEntityId				 = CH.intEntityId
																		AND Entity.strEntityType = CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor'
																									WHEN CH.intContractTypeId = 2 THEN 'Customer' END
		JOIN tblRKFutureMarket					Market			 ON Market.intFutureMarketId		 = CD.intFutureMarketId
		JOIN tblRKFuturesMonth					FMonth			 ON FMonth.intFutureMonthId		 = CD.intFutureMonthId
		JOIN tblSMCurrency						MarketCY		 ON	 MarketCY.intCurrencyID			 = Market.intCurrencyId
		JOIN tblICUnitMeasure					MarketUOM		 ON	 MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId		
		JOIN tblICItem							Item			 ON Item.intItemId					 = CD.intItemId
		JOIN tblSMCompanyLocation				CL				 ON CL.intCompanyLocationId			 = CD.intCompanyLocationId
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		LEFT JOIN tblSMCurrency					CY				 ON	CY.intCurrencyID				 = CD.intCurrencyId
		LEFT JOIN tblARInvoiceDetail			InvoiceDetail ON InvoiceDetail.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN tblARInvoice				 Invoice			 ON Invoice.intInvoiceId			 = InvoiceDetail.intInvoiceId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType					 = 'Origin'
		LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID					 = 	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId	
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblSMFreightTerms				CB				 ON CB.intFreightTermId			 = CH.intFreightTermId
		LEFT JOIN tblSMTerm						Term			 ON Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		 = CD.intItemUOMId
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemUOM.intUnitMeasureId		
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		 = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC				 ON	IC.intItemContractId			 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY				 ON	RY.intCountryID					 = IC.intCountryId
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = L.intCompanyId
		WHERE LD.intLoadDetailId NOT IN (SELECT ISNULL(tblARInvoiceDetail.intLoadDetailId, 0) FROM tblARInvoiceDetail)
			AND CH.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN CH.intCommodityId
										ELSE @intCommodityId END
			AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId
											ELSE @intLocationId END
			AND ISNULL(L.intCompanyId, 0) = CASE WHEN ISNULL(@intCompanyId, 0) = 0 THEN ISNULL(L.intCompanyId, 0)
												ELSE @intCompanyId END
			AND L.intPurchaseSale IN (2)
			AND L.intShipmentType = 1
			AND L.ysnPosted = 1
		
		---Delivered Not Invoiced (P)-----
		UNION ALL SELECT @intM2MHeaderId
			, strType = CASE WHEN ISNULL(Invoice.strType, '') = 'Provisional' THEN 'Realized Not Fixed' ELSE 'Unrealized' END COLLATE Latin1_General_CI_AS
			, intContractTypeId = CH.intContractTypeId
			, intContractHeaderId = CH.intContractHeaderId
			, strContractType = TP.strContractType
			, strContractNumber = CH.strContractNumber
			, intFreightTermId = CH.intFreightTermId
			, intTransactionTyp = 5
			, strTransaction = '5.Delivered Not Invoiced' COLLATE Latin1_General_CI_AS
			, strTransactionType = 'Delivered Not Invoiced (P)' COLLATE Latin1_General_CI_AS
			, intContractDetailId = CD.intContractDetailId
			, intCurrencyId = CD.intCurrencyId	
			, intFutureMarketId = CD.intFutureMarketId
			, strFutureMarket = Market.strFutMarketName
			, intFutureMarketUOMId = NULL
			, intFutureMarketUnitMeasureId = Market.intUnitMeasureId
			, strFutureMarketUOM = MarketUOM.strUnitMeasure
			, intMarketCurrencyId = Market.intCurrencyId
			, intFutureMonthId = FMonth.intFutureMonthId
			, strFutureMonth = FMonth.strFutureMonth
			, intItemId = CD.intItemId
			, intBookId = Book.intBookId
			, strBook = Book.strBook
			, strSubBook = SubBook.strSubBook
			, intCommodityId = Commodity.intCommodityId
			, strCommodity = Commodity.strDescription
			, dtmReceiptDate = NULL		
			, dtmContractDate = CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
			, strContract = (CH.strContractNumber + '-' + LTRIM(CD.intContractSeq)) COLLATE Latin1_General_CI_AS
			, intContractSeq = CD.intContractSeq
			, strEntityName = Entity.strEntityName
			, strInternalCompany = CASE WHEN ISNULL(BVE.intEntityId, 0) >0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
			, dblQuantity = LDL.dblLotQuantity 
			, intQuantityUOMId = CD.intItemUOMId
			, intQuantityUnitMeasureId = IUM.intUnitMeasureId
			, strQuantityUOM = IUM.strUnitMeasure
			, dblWeight = NULL
			, intWeightUOMId = NULL
			, intWeightUnitMeasureId = NULL
			, strWeightUOM = NULL
			, dblBasis = CD.dblBasis
			, intBasisUOMId = CD.intBasisUOMId
			, intBasisUnitMeasureId = BUOM.intUnitMeasureId
			, strBasisUOM = BUOM.strUnitMeasure
			, dblFutures = ISNULL(CD.dblFutures, 0)
			, dblCashPrice = ISNULL(CD.dblCashPrice, 0)
			, intPriceUOMId = CD.intPriceItemUOMId
			, intPriceUnitMeasureId = PriceUOM.intUnitMeasureId
			, strContractPriceUOM = PUOM.strUnitMeasure
			, intOriginId = Item.intOriginId
			, strOrigin = ISNULL(RY.strCountry, OG.strCountry)
			, strItemDescription = Item.strDescription
			, strCropYear = CropYear.strCropYear
			, strProductionLine = CPL.strDescription
			, strCertification = NULL
			, strTerms = (ISNULL(CB.strContractBasis, '') + ', ' + ISNULL(Term.strTerm, '') + ', ' + ISNULL(WG.strWeightGradeDesc, '')) COLLATE Latin1_General_CI_AS
			, strPosition = PO.strPosition
			, dtmStartDate = CD.dtmStartDate
			, dtmEndDate = CD.dtmEndDate
			, strBLNumber = L.strBLNumber
			, dtmBLDate = L.dtmBLDate
			, strAllocationRefNo = NULL
			, strAllocationStatus = CASE WHEN CH.intContractTypeId = 1 THEN 'L'
										WHEN CH.intContractTypeId = 2 THEN 'S' END COLLATE Latin1_General_CI_AS
			, strPriceTerms = CASE WHEN CD.intPricingTypeId = 2 THEN 'Unfixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblBasis) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure
								ELSE 'Fixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure + ' '
									+ [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure END COLLATE Latin1_General_CI_AS
			, dblContractDifferential = CD.dblBasis
			, strContractDifferentialUOM = (BCY.strCurrency + '/' + BUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, dblFuturesPrice = ISNULL(CD.dblFutures, 0)
			, strFuturesPriceUOM = (CY.strCurrency + '/' + PUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strFixationDetails = NULL
			, dblFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL(PF.dblLotsFixed, 0) ELSE 0 END
			, dblUnFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL((ISNULL(CD.[dblNoOfLots], 0) -ISNULL(PF.dblLotsFixed, 0)), 0) ELSE 0 END
			, dblContractInvoiceValue = NULL
			, dblSecondaryCosts = 0
			, dblCOGSOrNetSaleValue = NULL
			, dblInvoicePrice = NULL
			, dblInvoicePaymentPrice = NULL
			, strInvoicePriceUOM = NULL
			, dblInvoiceValue = NULL
			, strInvoiceCurrency = NULL
			, dblNetMarketValue = NULL
			, dtmRealizedDate = CONVERT(DATETIME, CONVERT(VARCHAR, Invoice.dtmPostDate, 101), 101)
			, dblRealizedQty = NULL
			, dblProfitOrLossValue = NULL
			, dblPAndLinMarketUOM = NULL
			, dblPAndLChangeinMarketUOM = NULL
			, strMarketCurrencyUOM = (MarketCY.strCurrency + '/' + MarketUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strTrader = SP.strName 
			, strFixedBy = CD.strFixationBy
			, strInvoiceStatus = Invoice.strType
			, strWarehouse = NULL
			, strCPAddress = Entity.strEntityAddress 
			, strCPCountry = Entity.strEntityCountry	
			, strCPRefNo = CH.strCustomerContract
			, intContractStatusId = CD.intContractStatusId
			, intPricingTypeId = CD.intPricingTypeId
			, strPricingType = PT.strPricingType
			, strPricingStatus = CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced'ELSE '' END COLLATE Latin1_General_CI_AS
			, intCompanyId = Company.intMultiCompanyId
			, strCompanyName = Company.strCompanyName
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6) -- 1.purchase 2.outbound
		JOIN tblLGLoadDetailLot					LDL				 ON LDL.intLoadDetailId				 = LD.intLoadDetailId
		JOIN tblICLot							LOT				 ON LOT.intLotId					 = LDL.intLotId
		JOIN tblICInventoryReceiptItemLot		ReceiptLot		 ON ReceiptLot.intParentLotId		 = LOT.intParentLotId
		JOIN tblICInventoryReceiptItem			ReceiptItem		 ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
		JOIN tblICInventoryReceipt				Receipt			 ON Receipt.intInventoryReceiptId		 = ReceiptItem.intInventoryReceiptId
		JOIN tblCTContractDetail				CD				 ON CD.intContractDetailId				 = ReceiptItem.intLineNo
		JOIN tblCTContractHeader				CH				 ON CH.intContractHeaderId				 = CD.intContractHeaderId	
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId			 = CH.intCommodityId
		JOIN tblCTContractType					TP				 ON TP.intContractTypeId				 = CH.intContractTypeId		
		JOIN vyuCTEntity						Entity			 ON Entity.intEntityId					 = CH.intEntityId
																		AND Entity.strEntityType = CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor'
																									WHEN CH.intContractTypeId = 2 THEN 'Customer' END
		JOIN tblRKFutureMarket					Market			 ON Market.intFutureMarketId		 = CD.intFutureMarketId
		JOIN tblRKFuturesMonth					FMonth			 ON FMonth.intFutureMonthId		 = CD.intFutureMonthId
		JOIN tblSMCurrency						MarketCY		 ON	 MarketCY.intCurrencyID			 = Market.intCurrencyId
		JOIN tblICUnitMeasure					MarketUOM		 ON	 MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId		
		JOIN tblICItem							Item			 ON Item.intItemId					 = CD.intItemId
		JOIN tblSMCompanyLocation				CL				 ON CL.intCompanyLocationId			 = CD.intCompanyLocationId
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		LEFT JOIN tblSMCurrency					CY				 ON	CY.intCurrencyID				 = CD.intCurrencyId
		LEFT JOIN tblARInvoiceDetail			InvoiceDetail ON InvoiceDetail.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN tblARInvoice				 Invoice			 ON Invoice.intInvoiceId			 = InvoiceDetail.intInvoiceId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType					 = 'Origin'
		LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID					 = 	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId	
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblSMFreightTerms				CB				 ON CB.intFreightTermId			 = CH.intFreightTermId
		LEFT JOIN tblSMTerm						Term			 ON Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		 = CD.intItemUOMId
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemUOM.intUnitMeasureId		
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		 = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC				 ON	IC.intItemContractId			 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY				 ON	RY.intCountryID					 = IC.intCountryId
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = L.intCompanyId
		WHERE LD.intLoadDetailId NOT IN (SELECT ISNULL(tblARInvoiceDetail.intLoadDetailId, 0) FROM tblARInvoiceDetail)
			AND CH.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN CH.intCommodityId
										ELSE @intCommodityId END
			AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId
											ELSE @intLocationId END
			AND ISNULL(L.intCompanyId, 0) = CASE WHEN ISNULL(@intCompanyId, 0) = 0 THEN ISNULL(L.intCompanyId, 0)
												ELSE @intCompanyId END
			AND L.intPurchaseSale IN (2, 3)
			AND L.intShipmentType = 1
			AND L.ysnPosted = 1
		
		---Drop Ship Purchase-----
		UNION ALL SELECT @intM2MHeaderId
			, strType = CASE WHEN ISNULL(Invoice.strType, '') = 'Provisional' THEN 'Realized Not Fixed' ELSE 'Unrealized' END COLLATE Latin1_General_CI_AS
			, intContractTypeId = CH.intContractTypeId
			, intContractHeaderId = CH.intContractHeaderId
			, strContractType = TP.strContractType
			, strContractNumber = CH.strContractNumber
			, intFreightTermId = CH.intFreightTermId
			, intTransactionType = 2
			, strTransaction = '2.In-transit' COLLATE Latin1_General_CI_AS
			, strTransactionType = ('In-transit(' + CASE WHEN TP.strContractType = 'Sale' THEN 'S' ELSE 'P' END + ')') COLLATE Latin1_General_CI_AS
			, intContractDetailId = CD.intContractDetailId
			, intCurrencyId = CD.intCurrencyId	
			, intFutureMarketId = CD.intFutureMarketId
			, strFutureMarket = Market.strFutMarketName
			, intFutureMarketUOMId = NULL
			, intFutureMarketUnitMeasureId = Market.intUnitMeasureId
			, strFutureMarketUOM = MarketUOM.strUnitMeasure
			, intMarketCurrencyId = Market.intCurrencyId
			, intFutureMonthId = FMonth.intFutureMonthId
			, strFutureMonth = FMonth.strFutureMonth
			, intItemId = CD.intItemId
			, intBookId = Book.intBookId
			, strBook = Book.strBook
			, strSubBook = SubBook.strSubBook
			, intCommodityId = Commodity.intCommodityId
			, strCommodity = Commodity.strDescription
			, dtmReceiptDate = NULL		
			, dtmContractDate = CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
			, strContract = (CH.strContractNumber + '-' + LTRIM(CD.intContractSeq)) COLLATE Latin1_General_CI_AS
			, intContractSeq = CD.intContractSeq
			, strEntityName = Entity.strEntityName
			, strInternalCompany = CASE WHEN ISNULL(BVE.intEntityId, 0) >0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
			, dblQuantity = SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId)
			, intQuantityUOMId = CD.intItemUOMId
			, intQuantityUnitMeasureId = IUM.intUnitMeasureId
			, strQuantityUOM = IUM.strUnitMeasure
			, dblWeight = NULL ---CD.dblNetWeight
			, intWeightUOMId = NULL ---CD.intNetWeightUOMId
			, intWeightUnitMeasureId = NULL ---WUM.intUnitMeasureId
			, strWeightUOM = NULL ---WUM.strUnitMeasure
			, dblBasis = CD.dblBasis
			, intBasisUOMId = CD.intBasisUOMId
			, intBasisUnitMeasureId = BUOM.intUnitMeasureId
			, strBasisUOM = BUOM.strUnitMeasure
			, dblFutures = ISNULL(CD.dblFutures, 0)
			, dblCashPrice = ISNULL(CD.dblCashPrice, 0)
			, intPriceUOMId = CD.intPriceItemUOMId
			, intPriceUnitMeasureId = PriceUOM.intUnitMeasureId
			, strContractPriceUOM = PUOM.strUnitMeasure
			, intOriginId = Item.intOriginId
			, strOrigin = ISNULL(RY.strCountry, OG.strCountry)
			, strItemDescription = Item.strDescription
			, strCropYear = CropYear.strCropYear
			, strProductionLine = CPL.strDescription
			, strCertification = NULL
			, strTerms = (ISNULL(CB.strContractBasis, '') + ', ' + ISNULL(Term.strTerm, '') + ', ' + ISNULL(WG.strWeightGradeDesc, '')) COLLATE Latin1_General_CI_AS
			, strPosition = PO.strPosition
			, dtmStartDate = CD.dtmStartDate
			, dtmEndDate = CD.dtmEndDate
			, strBLNumber = L.strBLNumber
			, dtmBLDate = L.dtmBLDate
			, strAllocationRefNo = NULL
			, strAllocationStatus = CASE WHEN CH.intContractTypeId = 1 THEN 'L'
										WHEN CH.intContractTypeId = 2 THEN 'S' END COLLATE Latin1_General_CI_AS
			, strPriceTerms = CASE WHEN CD.intPricingTypeId = 2 THEN 'Unfixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblBasis) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure
								ELSE 'Fixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure + ' '
									+ [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure END COLLATE Latin1_General_CI_AS
			, dblContractDifferential = CD.dblBasis
			, strContractDifferentialUOM = (BCY.strCurrency + '/' + BUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, dblFuturesPrice = ISNULL(CD.dblFutures, 0)
			, strFuturesPriceUOM = (CY.strCurrency + '/' + PUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strFixationDetails = NULL
			, dblFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL(PF.dblLotsFixed, 0) ELSE 0 END
			, dblUnFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL((ISNULL(CD.[dblNoOfLots], 0) -ISNULL(PF.dblLotsFixed, 0)), 0) ELSE 0 END
			, dblContractInvoiceValue = NULL
			, dblSecondaryCosts = 0
			, dblCOGSOrNetSaleValue = NULL
			, dblInvoicePrice = NULL
			, dblInvoicePaymentPrice = NULL
			, strInvoicePriceUOM = NULL
			, dblInvoiceValue = NULL
			, strInvoiceCurrency = NULL
			, dblNetMarketValue = NULL
			, dtmRealizedDate = CONVERT(DATETIME, CONVERT(VARCHAR, Invoice.dtmPostDate, 101), 101)
			, dblRealizedQty = NULL
			, dblProfitOrLossValue = NULL
			, dblPAndLinMarketUOM = NULL
			, dblPAndLChangeinMarketUOM = NULL
			, strMarketCurrencyUOM = (MarketCY.strCurrency + '/' + MarketUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strTrader = SP.strName 
			, strFixedBy = CD.strFixationBy
			, strInvoiceStatus = Invoice.strType
			, strWarehouse = NULL
			, strCPAddress = Entity.strEntityAddress 
			, strCPCountry = Entity.strEntityCountry	
			, strCPRefNo = CH.strCustomerContract
			, intContractStatusId = CD.intContractStatusId
			, intPricingTypeId = CD.intPricingTypeId
			, strPricingType = PT.strPricingType
			, strPricingStatus = CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced'ELSE '' END COLLATE Latin1_General_CI_AS
			, intCompanyId = Company.intMultiCompanyId
			, strCompanyName = Company.strCompanyName
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6, 3)
																AND L.intPurchaseSale = 3 AND L.intShipmentType = 1 
		JOIN tblCTContractDetail CD ON CD.intContractDetailId	 = LD.intPContractDetailId
		JOIN tblCTContractHeader				CH				 ON CH.intContractHeaderId			 = CD.intContractHeaderId	
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId		 = CH.intCommodityId
		JOIN tblCTContractType					TP				 ON TP.intContractTypeId			 = CH.intContractTypeId		
		JOIN vyuCTEntity						Entity			 ON Entity.intEntityId				 = CH.intEntityId
																		AND Entity.strEntityType = CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor'
																									WHEN CH.intContractTypeId = 2 THEN 'Customer' END
		JOIN tblRKFutureMarket					Market			 ON Market.intFutureMarketId		 = CD.intFutureMarketId
		JOIN tblRKFuturesMonth					FMonth			 ON FMonth.intFutureMonthId		 = CD.intFutureMonthId
		JOIN tblSMCurrency						MarketCY		 ON	 MarketCY.intCurrencyID			 = Market.intCurrencyId
		JOIN tblICUnitMeasure					MarketUOM		 ON	 MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId		
		JOIN tblICItem							Item			 ON Item.intItemId					 = CD.intItemId
		JOIN tblSMCompanyLocation				CL				 ON CL.intCompanyLocationId			 = CD.intCompanyLocationId
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		LEFT JOIN tblSMCurrency					CY				 ON	CY.intCurrencyID				 = CD.intCurrencyId
		LEFT JOIN tblARInvoiceDetail			InvoiceDetail ON InvoiceDetail.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN tblARInvoice				 Invoice			 ON Invoice.intInvoiceId			 = InvoiceDetail.intInvoiceId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType					 = 'Origin'
		LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID					 = 	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId	
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblSMFreightTerms				CB				 ON CB.intFreightTermId			 = CH.intFreightTermId
		LEFT JOIN tblSMTerm						Term			 ON Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		 = CD.intItemUOMId
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		 = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC				 ON	IC.intItemContractId			 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY				 ON	RY.intCountryID					 = IC.intCountryId
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = L.intCompanyId
		WHERE CH.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN CH.intCommodityId
									ELSE @intCommodityId END
			AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId
											ELSE @intLocationId END
			AND ISNULL(L.intCompanyId, 0) = CASE WHEN ISNULL(@intCompanyId, 0) = 0 THEN ISNULL(L.intCompanyId, 0)
												ELSE @intCompanyId END
		
		---DROP SHIP SALE-----
		UNION ALL SELECT @intM2MHeaderId
			, strType = CASE WHEN ISNULL(Invoice.strType, '') = 'Provisional' THEN 'Realized Not Fixed' ELSE 'Unrealized' END COLLATE Latin1_General_CI_AS
			, intContractTypeId = CH.intContractTypeId
			, intContractHeaderId = CH.intContractHeaderId
			, strContractType = TP.strContractType
			, strContractNumber = CH.strContractNumber
			, intFreightTermId = CH.intFreightTermId
			, intTransactionType = 2
			, strTransaction = '2.In-transit' COLLATE Latin1_General_CI_AS
			, strTransactionType = ('In-transit(' + CASE WHEN TP.strContractType = 'Sale' THEN 'S' ELSE 'P' END + ')') COLLATE Latin1_General_CI_AS
			, intContractDetailId = CD.intContractDetailId
			, intCurrencyId = CD.intCurrencyId	
			, intFutureMarketId = CD.intFutureMarketId
			, strFutureMarket = Market.strFutMarketName
			, intFutureMarketUOMId = NULL
			, intFutureMarketUnitMeasureId = Market.intUnitMeasureId
			, strFutureMarketUOM = MarketUOM.strUnitMeasure
			, intMarketCurrencyId = Market.intCurrencyId
			, intFutureMonthId = FMonth.intFutureMonthId
			, strFutureMonth = FMonth.strFutureMonth
			, intItemId = CD.intItemId
			, intBookId = Book.intBookId
			, strBook = Book.strBook
			, strSubBook = SubBook.strSubBook
			, intCommodityId = Commodity.intCommodityId
			, strCommodity = Commodity.strDescription
			, dtmReceiptDate = NULL		
			, dtmContractDate = CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
			, strContract = (CH.strContractNumber + '-' + LTRIM(CD.intContractSeq)) COLLATE Latin1_General_CI_AS
			, intContractSeq = CD.intContractSeq
			, strEntityName = Entity.strEntityName
			, strInternalCompany = CASE WHEN ISNULL(BVE.intEntityId, 0) >0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
			, dblQuantity = SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId)
			, intQuantityUOMId = CD.intItemUOMId
			, intQuantityUnitMeasureId = IUM.intUnitMeasureId
			, strQuantityUOM = IUM.strUnitMeasure
			, dblWeight = NULL ---CD.dblNetWeight
			, intWeightUOMId = NULL ---CD.intNetWeightUOMId
			, intWeightUnitMeasureId = NULL ---WUM.intUnitMeasureId
			, strWeightUOM = NULL ---WUM.strUnitMeasure
			, dblBasis = CD.dblBasis
			, intBasisUOMId = CD.intBasisUOMId
			, intBasisUnitMeasureId = BUOM.intUnitMeasureId
			, strBasisUOM = BUOM.strUnitMeasure
			, dblFutures = ISNULL(CD.dblFutures, 0)
			, dblCashPrice = ISNULL(CD.dblCashPrice, 0)
			, intPriceUOMId = CD.intPriceItemUOMId
			, intPriceUnitMeasureId = PriceUOM.intUnitMeasureId
			, strContractPriceUOM = PUOM.strUnitMeasure
			, intOriginId = Item.intOriginId
			, strOrigin = ISNULL(RY.strCountry, OG.strCountry)
			, strItemDescription = Item.strDescription
			, strCropYear = CropYear.strCropYear
			, strProductionLine = CPL.strDescription
			, strCertification = NULL
			, strTerms = (ISNULL(CB.strContractBasis, '') + ', ' + ISNULL(Term.strTerm, '') + ', ' + ISNULL(WG.strWeightGradeDesc, '')) COLLATE Latin1_General_CI_AS
			, strPosition = PO.strPosition
			, dtmStartDate = CD.dtmStartDate
			, dtmEndDate = CD.dtmEndDate
			, strBLNumber = L.strBLNumber
			, dtmBLDate = L.dtmBLDate
			, strAllocationRefNo = NULL
			, strAllocationStatus = CASE WHEN CH.intContractTypeId = 1 THEN 'L'
										WHEN CH.intContractTypeId = 2 THEN 'S' END COLLATE Latin1_General_CI_AS
			, strPriceTerms = CASE WHEN CD.intPricingTypeId = 2 THEN 'Unfixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblBasis) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure
								ELSE 'Fixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure + ' '
									+ [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure END COLLATE Latin1_General_CI_AS
			, dblContractDifferential = CD.dblBasis
			, strContractDifferentialUOM = (BCY.strCurrency + '/' + BUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, dblFuturesPrice = ISNULL(CD.dblFutures, 0)
			, strFuturesPriceUOM = (CY.strCurrency + '/' + PUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strFixationDetails = NULL
			, dblFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL(PF.dblLotsFixed, 0) ELSE 0 END
			, dblUnFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL((ISNULL(CD.[dblNoOfLots], 0) -ISNULL(PF.dblLotsFixed, 0)), 0) ELSE 0 END
			, dblContractInvoiceValue = NULL
			, dblSecondaryCosts = 0
			, dblCOGSOrNetSaleValue = NULL
			, dblInvoicePrice = NULL
			, dblInvoicePaymentPrice = NULL
			, strInvoicePriceUOM = NULL
			, dblInvoiceValue = NULL
			, strInvoiceCurrency = NULL
			, dblNetMarketValue = NULL
			, dtmRealizedDate = CONVERT(DATETIME, CONVERT(VARCHAR, Invoice.dtmPostDate, 101), 101)
			, dblRealizedQty = NULL
			, dblProfitOrLossValue = NULL
			, dblPAndLinMarketUOM = NULL
			, dblPAndLChangeinMarketUOM = NULL
			, strMarketCurrencyUOM = (MarketCY.strCurrency + '/' + MarketUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strTrader = SP.strName 
			, strFixedBy = CD.strFixationBy
			, strInvoiceStatus = Invoice.strType
			, strWarehouse = NULL
			, strCPAddress = Entity.strEntityAddress 
			, strCPCountry = Entity.strEntityCountry	
			, strCPRefNo = CH.strCustomerContract
			, intContractStatusId = CD.intContractStatusId
			, intPricingTypeId = CD.intPricingTypeId
			, strPricingType = PT.strPricingType
			, strPricingStatus = CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced'ELSE '' END COLLATE Latin1_General_CI_AS
			, intCompanyId = Company.intMultiCompanyId
			, strCompanyName = Company.strCompanyName
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6, 3) 
																AND L.intPurchaseSale = 3 AND L.intShipmentType = 1
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
		JOIN tblCTContractHeader				CH				 ON CH.intContractHeaderId			 = CD.intContractHeaderId	
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId		 = CH.intCommodityId
		JOIN tblCTContractType					TP				 ON TP.intContractTypeId			 = CH.intContractTypeId		
		JOIN vyuCTEntity						Entity			 ON Entity.intEntityId				 = CH.intEntityId
																		AND Entity.strEntityType = CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor'
																									WHEN CH.intContractTypeId = 2 THEN 'Customer' END
		JOIN tblRKFutureMarket					Market			 ON Market.intFutureMarketId		 = CD.intFutureMarketId
		JOIN tblRKFuturesMonth					FMonth			 ON FMonth.intFutureMonthId		 = CD.intFutureMonthId
		JOIN tblSMCurrency						MarketCY		 ON	 MarketCY.intCurrencyID			 = Market.intCurrencyId
		JOIN tblICUnitMeasure					MarketUOM		 ON	 MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId		
		JOIN tblICItem							Item			 ON Item.intItemId					 = CD.intItemId
		JOIN tblSMCompanyLocation				CL				 ON CL.intCompanyLocationId			 = CD.intCompanyLocationId
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		LEFT JOIN tblSMCurrency					CY				 ON	CY.intCurrencyID				 = CD.intCurrencyId
		LEFT JOIN tblARInvoiceDetail			InvoiceDetail ON InvoiceDetail.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN tblARInvoice				 Invoice			 ON Invoice.intInvoiceId			 = InvoiceDetail.intInvoiceId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType					 = 'Origin'
		LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID					 = 	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId	
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblSMFreightTerms				CB				 ON CB.intFreightTermId			 = CH.intFreightTermId
		LEFT JOIN tblSMTerm						Term			 ON Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		 = CD.intItemUOMId
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		 = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC	ON	IC.intItemContractId						 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY	ON	RY.intCountryID								 = IC.intCountryId
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = L.intCompanyId
		WHERE CH.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN CH.intCommodityId
									ELSE @intCommodityId END
			AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId
											ELSE @intLocationId END
			AND ISNULL(L.intCompanyId, 0) = CASE WHEN ISNULL(@intCompanyId, 0) = 0 THEN ISNULL(L.intCompanyId, 0)
												ELSE @intCompanyId END
												
		--Inventory
		UNION ALL SELECT @intM2MHeaderId
			, strType = 'Unrealized' COLLATE Latin1_General_CI_AS
			, intContractTypeId = CH.intContractTypeId
			, intContractHeaderId = CH.intContractHeaderId
			, strContractType = TP.strContractType
			, strContractNumber = CH.strContractNumber
			, intFreightTermId = CH.intFreightTermId
			, intTransactionType = 3
			, strTransaction = '3.Inventory' COLLATE Latin1_General_CI_AS
			, strTransactionType = 'Inventory (P)' COLLATE Latin1_General_CI_AS
			, intContractDetailId = CD.intContractDetailId
			, intCurrencyId = CD.intCurrencyId	
			, intFutureMarketId = CD.intFutureMarketId
			, strFutureMarket = Market.strFutMarketName
			, intFutureMarketUOMId = NULL
			, intFutureMarketUnitMeasureId = Market.intUnitMeasureId
			, strFutureMarketUOM = MarketUOM.strUnitMeasure
			, intMarketCurrencyId = Market.intCurrencyId
			, intFutureMonthId = FMonth.intFutureMonthId
			, strFutureMonth = FMonth.strFutureMonth
			, intItemId = CD.intItemId
			, intBookId = Book.intBookId
			, strBook = Book.strBook
			, strSubBook = SubBook.strSubBook
			, intCommodityId = Commodity.intCommodityId
			, strCommodity = Commodity.strDescription
			, dtmReceiptDate = NULL		
			, dtmContractDate = CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
			, strContract = (CH.strContractNumber + '-' + LTRIM(CD.intContractSeq)) COLLATE Latin1_General_CI_AS
			, intContractSeq = CD.intContractSeq
			, strEntityName = Entity.strEntityName
			, strInternalCompany = CASE WHEN ISNULL(BVE.intEntityId, 0) >0 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
			, dblQuantity = l.dblLotQty
			, intQuantityUOMId = CD.intItemUOMId
			, intQuantityUnitMeasureId = IUM.intUnitMeasureId
			, strQuantityUOM = IUM.strUnitMeasure
			, dblWeight = l.dblWeight
			, intWeightUOMId = CD.intNetWeightUOMId
			, intWeightUnitMeasureId = WUM.intUnitMeasureId
			, strWeightUOM = WUM.strUnitMeasure
			, dblBasis = CD.dblBasis
			, intBasisUOMId = CD.intBasisUOMId
			, intBasisUnitMeasureId = BUOM.intUnitMeasureId
			, strBasisUOM = BUOM.strUnitMeasure
			, dblFutures = ISNULL(CD.dblFutures, 0)
			, dblCashPrice = ISNULL(CD.dblCashPrice, 0)
			, intPriceUOMId = CD.intPriceItemUOMId
			, intPriceUnitMeasureId = PriceUOM.intUnitMeasureId
			, strContractPriceUOM = PUOM.strUnitMeasure
			, intOriginId = Item.intOriginId
			, strOrigin = ISNULL(RY.strCountry, OG.strCountry)
			, strItemDescription = Item.strDescription
			, strCropYear = CropYear.strCropYear
			, strProductionLine = CPL.strDescription
			, strCertification = NULL
			, strTerms = (ISNULL(CB.strContractBasis, '') + ', ' + ISNULL(Term.strTerm, '') + ', ' + ISNULL(WG.strWeightGradeDesc, '')) COLLATE Latin1_General_CI_AS
			, strPosition = PO.strPosition
			, dtmStartDate = CD.dtmStartDate
			, dtmEndDate = CD.dtmEndDate
			, strBLNumber = NULL
			, dtmBLDate = NULL
			, strAllocationRefNo = NULL
			, strAllocationStatus = CASE WHEN CH.intContractTypeId = 1 THEN 'L'
										WHEN CH.intContractTypeId = 2 THEN 'S' END COLLATE Latin1_General_CI_AS
			, strPriceTerms = CASE WHEN CD.intPricingTypeId = 2 THEN 'Unfixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblBasis) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure
								ELSE 'Fixed: ' + Market.strFutMarketName + ' ' + FMonth.strFutureMonth + ' ' + [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure + ' '
									+ [dbo].[fnRemoveTrailingZeroes](CD.dblFutures) + ' ' + BCY.strCurrency + ' / ' + BUOM.strUnitMeasure END COLLATE Latin1_General_CI_AS
			, dblContractDifferential = CD.dblBasis
			, strContractDifferentialUOM = (BCY.strCurrency + '/' + BUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, dblFuturesPrice = ISNULL(CD.dblFutures, 0)
			, strFuturesPriceUOM = (CY.strCurrency + '/' + PUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strFixationDetails = NULL
			, dblFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL(PF.dblLotsFixed, 0) ELSE 0 END
			, dblUnFixedLots = CASE WHEN CH.intPricingTypeId = 2 THEN ISNULL((ISNULL(CD.[dblNoOfLots], 0) -ISNULL(PF.dblLotsFixed, 0)), 0) ELSE 0 END
			, dblContractInvoiceValue = NULL
			, dblSecondaryCosts = NULL
			, dblCOGSOrNetSaleValue = NULL
			, dblInvoicePrice = NULL
			, dblInvoicePaymentPrice = NULL
			, strInvoicePriceUOM = NULL
			, dblInvoiceValue = NULL
			, strInvoiceCurrency = NULL
			, dblNetMarketValue = NULL
			, dtmRealizedDate = NULL
			, dblRealizedQty = NULL
			, dblProfitOrLossValue = NULL
			, dblPAndLinMarketUOM = NULL
			, dblPAndLChangeinMarketUOM = NULL
			, strMarketCurrencyUOM = (MarketCY.strCurrency + '/' + MarketUOM.strUnitMeasure) COLLATE Latin1_General_CI_AS
			, strTrader = SP.strName 
			, strFixedBy = CD.strFixationBy
			, strInvoiceStatus = NULL
			, strWarehouse = SubLocation.strSubLocationName
			, strCPAddress = Entity.strEntityAddress 
			, strCPCountry = Entity.strEntityCountry	
			, strCPRefNo = CH.strCustomerContract
			, intContractStatusId = CD.intContractStatusId
			, intPricingTypeId = CD.intPricingTypeId
			, strPricingType = PT.strPricingType
			, strPricingStatus = CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced'ELSE '' END COLLATE Latin1_General_CI_AS
			, intCompanyId = Company.intMultiCompanyId
			, strCompanyName = Company.strCompanyName
		FROM (
			SELECT CTDetail.intContractDetailId
				, Lot.intSubLocationId
				, dblLotQty = SUM(Lot.dblQty)
				, dblWeight = SUM(Lot.dblQty * Lot.dblWeightPerQty)
			FROM tblICLot Lot
			LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
			LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
			LEFT JOIN tblCTContractDetail CTDetail ON CTDetail.intContractDetailId = ReceiptItem.intLineNo 
			LEFT JOIN tblCTContractHeader CTHeader ON CTHeader.intContractHeaderId = ReceiptItem.intOrderId
			WHERE Lot.dblQty > 0.0 AND ISNULL(Lot.ysnProduced, 0) <> 1
			GROUP BY CTDetail.intContractDetailId, Lot.intSubLocationId
		) l -- 1.purchase 2.outbound
		JOIN tblCTContractDetail CD ON CD.intContractDetailId	 = l.intContractDetailId
		JOIN tblCTContractHeader				CH				 ON CH.intContractHeaderId			 = CD.intContractHeaderId	
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId		 = CH.intCommodityId
		JOIN tblCTContractType					TP				 ON TP.intContractTypeId			 = CH.intContractTypeId		
		JOIN vyuCTEntity						Entity			 ON Entity.intEntityId				 = CH.intEntityId
																		AND Entity.strEntityType = CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor'
																									WHEN CH.intContractTypeId = 2 THEN 'Customer' END
		JOIN tblRKFutureMarket					Market			 ON Market.intFutureMarketId		 = CD.intFutureMarketId
		JOIN tblRKFuturesMonth					FMonth			 ON FMonth.intFutureMonthId		 = CD.intFutureMonthId
		JOIN tblSMCurrency						MarketCY		 ON	 MarketCY.intCurrencyID			 = Market.intCurrencyId
		JOIN tblICUnitMeasure					MarketUOM		 ON	 MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId		
		JOIN tblICItem							Item			 ON Item.intItemId					 = CD.intItemId		
		JOIN tblSMCompanyLocation				CL				 ON CL.intCompanyLocationId			 = CD.intCompanyLocationId
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		JOIN tblSMCompanyLocationSubLocation	SubLocation		 ON	 SubLocation.intCompanyLocationSubLocationId = l.intSubLocationId
		LEFT JOIN tblSMCurrency					CY				 ON	CY.intCurrencyID				 = CD.intCurrencyId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType					 = 'Origin'
		LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID					 = 	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId		
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblSMFreightTerms				CB				 ON CB.intFreightTermId			 = CH.intFreightTermId
		LEFT JOIN tblSMTerm						Term			 ON Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		 = CD.intItemUOMId
		JOIN tblICItemUOM						WeightUOM		 ON WeightUOM.intItemUOMId		 = CD.intNetWeightUOMId		
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure				WUM				 ON	WUM.intUnitMeasureId			 = WeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		 = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC			 ON	IC.intItemContractId			 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY			 ON	RY.intCountryID					 = IC.intCountryId	
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = CH.intCompanyId
		WHERE CH.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN CH.intCommodityId
									ELSE @intCommodityId END		
			AND Item.strLotTracking <> 'No'
			AND CL.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId
											ELSE @intLocationId END
			AND ISNULL(CH.intCompanyId, 0) = CASE WHEN ISNULL(@intCompanyId, 0) = 0 THEN ISNULL(CH.intCompanyId, 0)
												ELSE @intCompanyId END
		
		-------------------Inventory (FG)---------------------
		UNION ALL SELECT @intM2MHeaderId
			, strType = 'Unrealized' COLLATE Latin1_General_CI_AS
			, intContractTypeId = 1
			, intContractHeaderId = NULL
			, strContractType = 'Purchase' COLLATE Latin1_General_CI_AS
			, strContractNumber = NULL
			, intFreightTermId = NULL
			, intTransactionType = 4
			, strTransaction = '4.Inventory(FG)' COLLATE Latin1_General_CI_AS
			, strTransactionType = 'Inventory (FG)' COLLATE Latin1_General_CI_AS								 
			, intContractDetailId = NULL
			, intCurrencyId = Market.intCurrencyId	
			, intFutureMarketId = Market.intFutureMarketId
			, strFutureMarket = Market.strFutMarketName
			, intFutureMarketUOMId = NULL
			, intFutureMarketUnitMeasureId = Market.intUnitMeasureId
			, strFutureMarketUOM = MarketUOM.strUnitMeasure
			, intMarketCurrencyId = Market.intCurrencyId
			, intFutureMonthId = FMonth.intFutureMonthId
			, strFutureMonth = FMonth.strFutureMonth
			, intItemId = Lot.intItemId
			, intBookId = NULL
			, strBook = NULL
			, strSubBook = NULL
			, intCommodityId = Commodity.intCommodityId
			, strCommodity = Commodity.strDescription
			, dtmReceiptDate = NULL		
			, dtmContractDate = NULL
			, strContract = NULL
			, intContractSeq = NULL
			, strEntityName = NULL
			, strInternalCompany = NULL
			, dblQuantity = Lot.dblQty
			, intQuantityUOMId = ItemStockUOM.intItemUOMId
			, intQuantityUnitMeasureId = IUM.intUnitMeasureId
			, strQuantityUOM = IUM.strUnitMeasure
			, dblWeight = Lot.dblQty
			, intWeightUOMId = ItemStockUOM.intItemUOMId
			, intWeightUnitMeasureId = IUM.intUnitMeasureId
			, strWeightUOM = IUM.strUnitMeasure
			, dblBasis = 0
			, intBasisUOMId = NULL
			, intBasisUnitMeasureId = NULL
			, strBasisUOM = NULL
			, dblFutures = 0
			, dblCashPrice = dbo.fnGRConvertQuantityToTargetItemUOM(Item.intItemId, Market.intUnitMeasureId, ItemStockUOM.intUnitMeasureId, (Lot.dblLastCost / Lot.dblQty)) * (CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END)
			, intPriceUOMId = NULL
			, intPriceUnitMeasureId = Market.intUnitMeasureId
			, strContractPriceUOM = MarketUOM.strUnitMeasure
			, intOriginId = Item.intOriginId
			, strOrigin = OG.strCountry
			, strItemDescription = Item.strDescription
			, strCropYear = NULL --Lot table Crop year
			, strProductionLine = CPL.strDescription
			, strCertification = NULL
			, strTerms = NULL
			, strPosition = 'Spot' COLLATE Latin1_General_CI_AS
			, dtmStartDate = NULL
			, dtmEndDate = NULL
			, strBLNumber = NULL
			, dtmBLDate = NULL
			, strAllocationRefNo = NULL
			, strAllocationStatus = NULL
			, strPriceTerms = NULL
			, dblContractDifferential = NULL
			, strContractDifferentialUOM = NULL
			, dblFuturesPrice = NULL
			, strFuturesPriceUOM = NULL
			, strFixationDetails = NULL
			, dblFixedLots = NULL
			, dblUnFixedLots = NULL
			, dblContractInvoiceValue = NULL
			, dblSecondaryCosts = NULL
			, dblCOGSOrNetSaleValue = NULL
			, dblInvoicePrice = NULL
			, dblInvoicePaymentPrice = NULL
			, strInvoicePriceUOM = NULL
			, dblInvoiceValue = NULL
			, strInvoiceCurrency = NULL
			, dblNetMarketValue = NULL
			, dtmRealizedDate = NULL
			, dblRealizedQty = NULL
			, dblProfitOrLossValue = NULL
			, dblPAndLinMarketUOM = NULL
			, dblPAndLChangeinMarketUOM = NULL
			, strMarketCurrencyUOM = NULL
			, strTrader = NULL 
			, strFixedBy = NULL
			, strInvoiceStatus = NULL
			, strWarehouse = SubLocation.strSubLocationName
			, strCPAddress = NULL
			, strCPCountry = NULL
			, strCPRefNo = NULL
			, intContractStatusId = NULL
			, intPricingTypeId = NULL
			, strPricingType = NULL
			, strPricingStatus = NULL
			, intCompanyId = Lot.intCompanyId
			, strCompanyName = Company.strCompanyName
		FROM tblICItem Item
		JOIN (
			SELECT L.intItemId
				, L.intCompanyId
				, L.intSubLocationId
				, dblQty = SUM(dbo.fnGRConvertQuantityToTargetItemUOM(L.intItemId, LotUOM.intUnitMeasureId, ItemStockUOM.intUnitMeasureId, L.dblQty)) 
				, dblLastCost = SUM(dbo.fnGRConvertQuantityToTargetItemUOM(L.intItemId, LotUOM.intUnitMeasureId, ItemStockUOM.intUnitMeasureId, L.dblQty) * ISNULL(L.dblLastCost, 0)) 
			FROM tblICLot L
			JOIN tblICItemUOM ItemStockUOM ON ItemStockUOM.intItemId = L.intItemId AND ItemStockUOM.ysnStockUnit = 1 
			JOIN tblICItemUOM LotUOM ON LotUOM.intItemUOMId = L.intItemUOMId
			WHERE L.dblQty >0 AND L.ysnProduced = 1
			GROUP BY L.intItemId, L.intCompanyId, L.intSubLocationId
		) Lot ON Item.intItemId = Lot.intItemId
		JOIN tblICItemUOM ItemStockUOM ON ItemStockUOM.intItemId = Item.intItemId AND ItemStockUOM.ysnStockUnit = 1
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemStockUOM.intUnitMeasureId
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId		 = Item.intCommodityId
		JOIN tblICCommodityAttribute			CA1				 ON CA1.intCommodityAttributeId		 = Item.intProductTypeId
		AND	CA1.strType						 = 'ProductType'
		JOIN tblRKCommodityMarketMapping		MarketMapping	 ON MarketMapping.intCommodityId = CA1.intCommodityId
		JOIN tblRKFutureMarket					Market			 ON Market.intFutureMarketId		 = MarketMapping.intFutureMarketId
		JOIN tblSMCurrency						FCY				 ON	FCY.intCurrencyID				 = Market.intCurrencyId
		JOIN tblICUnitMeasure					MarketUOM		 ON	 MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId
		JOIN @tblFutureMonthByMarket			CTE				 ON CTE.intFutureMarketId			 = Market.intFutureMarketId 
		JOIN tblRKFuturesMonth					FMonth			 ON FMonth.intFutureMonthId		 = CTE.intFutureMonthId 
																	AND Market.intFutureMarketId		 = FMonth.intFutureMarketId 
																	AND CTE.intFutureMarketId			 = FMonth.intFutureMarketId
		JOIN tblSMCompanyLocationSubLocation	SubLocation		 ON	 SubLocation.intCompanyLocationSubLocationId		 = Lot.intSubLocationId		
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType					 = 'Origin'
		LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID					 = 	CA.intCountryID	
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = Lot.intCompanyId
		WHERE ISNULL(Lot.intCompanyId, 0) = CASE WHEN ISNULL(@intCompanyId, 0) = 0 THEN ISNULL(Lot.intCompanyId, 0)
												ELSE @intCompanyId END
			AND CA1.intCommodityAttributeId IN (select * from dbo.fnCommaSeparatedValueToTable(MarketMapping.strCommodityAttributeId))
		
		INSERT INTO @tblContractCost (intContractDetailId
			, dblRate
			, ysnAccrue
			, dblTotalCost)
		SELECT intContractDetailId = CC.intContractDetailId
			, dblRate = CC.dblRate
			, ysnAccrue = CC.ysnAccrue	
			, dblTotalCost = CASE WHEN CC.ysnAccrue = 1 THEN CASE WHEN CC.strCostStatus = 'Closed' THEN ISNULL(CC.dblActualAmount, 0)
																ELSE ISNULL(CC.dblActualAmount, 0) + ISNULL(CC.dblAccruedAmount, 0) END
															* (CASE WHEN intContractTypeId = 1 THEN 1 ELSE -1 END)
								WHEN CC.ysnAccrue = 0 AND CC.strCostMethod = 'Per Unit' THEN ISNULL(CC.dblRate, 0) * ISNULL(CC.dblFX , 1)
																		* dbo.fnGRConvertQuantityToTargetItemUOM(CC.intItemId, RealizedPNL.intQuantityUnitMeasureId, ItemUOM.intUnitMeasureId, CD.dblQuantity)
																		* CASE WHEN M2M.strAdjustmentType = 'Add' THEN 1
																			WHEN M2M.strAdjustmentType = 'Reduce' THEN -1 END
																		/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END
								WHEN CC.ysnAccrue = 0 AND CC.strCostMethod <> 'Per Unit' THEN 0 END
		FROM tblCTContractCost CC
		JOIN @tblUnRealizedPNL RealizedPNL ON RealizedPNL.intContractDetailId = CC.intContractDetailId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = RealizedPNL.intContractDetailId
		JOIN tblICItem Item ON Item.intItemId = CC.intItemId 
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CC.intItemUOMId
		LEFT JOIN tblSMCurrency	FCY ON FCY.intCurrencyID = CC.intCurrencyId
		LEFT JOIN tblRKM2MConfiguration M2M ON M2M.intItemId = CC.intItemId AND M2M.intFreightTermId = RealizedPNL.intFreightTermId
		WHERE Item.strCostType <> 'Commission'
		
		IF ISNULL(@intFutureSettlementPriceId, 0) > 0
		BEGIN
			INSERT INTO @tblSettlementPrice(intFutureMarketId
				, intFutureMonthId
				, dblSettlementPrice)
			SELECT intFutureMarketId = SettlementPrice.intFutureMarketId
				, intFutureMonthId = MarketMap.intFutureMonthId
				, dblSettlementPrice = ISNULL(MarketMap.dblLastSettle, 0)
			FROM tblRKFutSettlementPriceMarketMap MarketMap
			JOIN tblRKFuturesSettlementPrice SettlementPrice ON SettlementPrice.intFutureSettlementPriceId = MarketMap.intFutureSettlementPriceId
			JOIN tblRKFuturesMonth Mo ON Mo.intFutureMonthId = MarketMap.intFutureMonthId AND ISNULL(Mo.ysnExpired, 0) = 0
			WHERE SettlementPrice.intFutureSettlementPriceId = @intFutureSettlementPriceId
			
			INSERT INTO @tblSettlementPrice(intFutureMarketId
				, intFutureMonthId
				, dblSettlementPrice)
			SELECT intFutureMarketId = SettlementPrice.intFutureMarketId
				, intFutureMonthId = MarketMap.intFutureMonthId
				, dblSettlementPrice = ISNULL(MarketMap.dblLastSettle, 0)
			FROM tblRKFutSettlementPriceMarketMap MarketMap
			JOIN tblRKFuturesSettlementPrice SettlementPrice ON SettlementPrice.intFutureSettlementPriceId = MarketMap.intFutureSettlementPriceId
			JOIN tblRKFuturesMonth Mo ON Mo.intFutureMonthId = MarketMap.intFutureMonthId AND ISNULL(Mo.ysnExpired, 0) = 0
			WHERE SettlementPrice.intFutureSettlementPriceId = (SELECT TOP 1 intFutureSettlementPriceId
																FROM tblRKFuturesSettlementPrice 
																WHERE intFutureSettlementPriceId <> @intFutureSettlementPriceId
																ORDER BY dtmPriceDate DESC)					
				AND MarketMap.intFutureMonthId NOT IN(SELECT intFutureMonthId FROM @tblSettlementPrice)
		END
		ELSE
		BEGIN
			INSERT INTO @tblSettlementPrice(intFutureMarketId
				, intFutureMonthId
				, dblSettlementPrice)
			SELECT intFutureMarketId = SettlementPrice.intFutureMarketId
				, intFutureMonthId = MarketMap.intFutureMonthId
				, dblSettlementPrice = ISNULL(MarketMap.dblLastSettle, 0)
			FROM tblRKFutureMarket Market
			JOIN tblRKFuturesSettlementPrice SettlementPrice ON SettlementPrice.intFutureMarketId = Market.intFutureMarketId
			JOIN tblRKFutSettlementPriceMarketMap MarketMap ON MarketMap.intFutureSettlementPriceId = SettlementPrice.intFutureSettlementPriceId 
			WHERE SettlementPrice.intFutureSettlementPriceId = (SELECT MAX(intFutureSettlementPriceId) FROM tblRKFuturesSettlementPrice WHERE intFutureMarketId = Market.intFutureMarketId)
		END 

		IF @intM2MBasisId > 0
		BEGIN
			INSERT INTO @tblRKM2MBasisDetail(intM2MBasisDetailId
				, intM2MBasisId
				, intItemId
				, intFutureMarketId
				, intFutureMonthId
				, strPeriodTo
				, intCompanyLocationId
				, intPricingTypeId
				, intContractTypeId
				, dblBasisOrDiscount)
			SELECT intM2MBasisDetailId
				, intM2MBasisId
				, intItemId
				, intFutureMarketId
				, intFutureMonthId
				, strPeriodTo
				, intCompanyLocationId
				, intPricingTypeId
				, intContractTypeId
				, dblBasisOrDiscount
			FROM tblRKM2MBasisDetail WHERE intM2MBasisId = @intM2MBasisId
		END
		ELSE
		BEGIN
			INSERT INTO @tblRKM2MBasisDetail(intM2MBasisDetailId
				, intM2MBasisId
				, intItemId
				, intFutureMarketId
				, intFutureMonthId
				, strPeriodTo
				, intCompanyLocationId
				, intPricingTypeId
				, intContractTypeId
				, dblBasisOrDiscount)
			SELECT intM2MBasisDetailId
				, intM2MBasisId
				, intItemId
				, intFutureMarketId
				, intFutureMonthId
				, strPeriodTo
				, intCompanyLocationId
				, intPricingTypeId
				, intContractTypeId
				, dblBasisOrDiscount
			FROM tblRKM2MBasisDetail WHERE intM2MBasisId = (SELECT MAX(intM2MBasisId) FROM tblRKM2MBasis)
		END
		
		-----------------------------------------------------Weight and Weight UOM Updation--------------------------------------------	
		UPDATE RealizedPNL
		SET RealizedPNL.dblWeight = dbo.fnGRConvertQuantityToTargetItemUOM(RealizedPNL.intItemId, RealizedPNL.intQuantityUnitMeasureId, @intWeightUOMId, RealizedPNL.dblQuantity)
			, RealizedPNL.intWeightUnitMeasureId = @intWeightUOMId
			, RealizedPNL.strWeightUOM = @strWeightUOM
		FROM @tblUnRealizedPNL RealizedPNL
		WHERE RealizedPNL.intTransactionType IN (1, 2, 3, 5) AND @intWeightUOMId > 0
		
		-----------------------------------------------------SecondaryCosts Updation--------------------------------------------
		UPDATE RealizedPNL
		SET RealizedPNL.dblSecondaryCosts = ((ISNULL(CC.dblTotalCost, 0) / CD.dblQuantity) * RealizedPNL.dblQuantity)
		FROM @tblUnRealizedPNL RealizedPNL
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = RealizedPNL.intContractDetailId
		JOIN (SELECT intContractDetailId, SUM(ISNULL(dblTotalCost, 0)) dblTotalCost FROM @tblContractCost GROUP BY intContractDetailId) CC ON CC.intContractDetailId = RealizedPNL.intContractDetailId
		
		-----------------------------------------------------Settlement Price Updation--------------------------------------------
		UPDATE CD
		SET CD.dblSettlementPrice = ISNULL(SP.dblSettlementPrice, dbo.fnRKGetLastSettlementPrice(CD.intFutureMarketId, SM.intFutureMonthId))
		FROM @tblUnRealizedPNL CD
		LEFT JOIN @tblSettlementPrice SP ON SP.intFutureMarketId = CD.intFutureMarketId AND SP.intFutureMonthId = CD.intFutureMonthId
		LEFT JOIN @tblFutureSettlementMonth SM ON SM.intFutureMarketId = CD.intFutureMarketId
		WHERE CD.intTransactionType <> 4
		
		-----------------------------------------------------ContractInvoiceValue Updation--------------------------------------------
		UPDATE CD
		SET CD.dblContractInvoiceValue = dbo.fnGRConvertQuantityToTargetItemUOM(CD.intItemId, CD.intQuantityUnitMeasureId, CD.intFutureMarketUnitMeasureId, CD.dblQuantity)
										* dbo.fnGRConvertQuantityToTargetItemUOM(CD.intItemId, CD.intFutureMarketUnitMeasureId, CD.intPriceUnitMeasureId
																				, [dbo].[fnRKGetSequencePrice](CD.intContractDetailId, CD.dblSettlementPrice, GETDATE()))
										/ CASE WHEN ISNULL(Detail.dblFXPrice, 0) = 0 THEN ISNULL(EX.dblRate, 1) ELSE ISNULL(Detail.dblRate, 1) END
										/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END
		FROM @tblUnRealizedPNL CD
		JOIN tblCTContractDetail Detail ON Detail.intContractDetailId = CD.intContractDetailId
		JOIN tblSMCurrency FCY ON FCY.intCurrencyID = CD.intCurrencyId
		LEFT JOIN @tblCurrencyExchange EX ON EX.intFromCurrencyId = CD.intCurrencyId
		WHERE CD.intTransactionType <> 4
		
		UPDATE CD
		SET CD.dblContractInvoiceValue = CASE WHEN ISNULL(CD.dblCashPrice, 0.0) <> 0.0 THEN dbo.fnGRConvertQuantityToTargetItemUOM(CD.intItemId, CD.intQuantityUnitMeasureId, CD.intFutureMarketUnitMeasureId, CD.dblQuantity)
																							* dbo.fnGRConvertQuantityToTargetItemUOM(CD.intItemId, CD.intFutureMarketUnitMeasureId, CD.intPriceUnitMeasureId, CD.dblCashPrice)
																							/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END
											WHEN ISNULL(CD.dblCashPrice, 0.0) = 0.0 THEN dbo.fnGRConvertQuantityToTargetItemUOM(CD.intItemId, CD.intFutureMarketUnitMeasureId, CD.intQuantityUnitMeasureId, CD.dblQuantity)
																						 * ISNULL(CD.dblSettlementPrice, 0)
																						/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END END
		FROM @tblUnRealizedPNL CD
		JOIN tblSMCurrency FCY ON	FCY.intCurrencyID = CD.intMarketCurrencyId
		WHERE CD.intTransactionType = 4
		
		-----------------------------------------------------Net Market Updation--------------------------------------------
		UPDATE @tblUnRealizedPNL
		SET dblMarketDifferential = ISNULL(dblMarketDifferential, 0)
			, dblNetMarketValue = ISNULL(dblNetMarketValue, 0)
			, dblNetM2MPrice = ISNULL(dblNetM2MPrice, 0)

		IF @ysnEnterForwardCurveForMarketBasisDifferential = 1
		BEGIN
			UPDATE CD
			SET CD.dblMarketDifferential = ISNULL(BasisDetail.dblBasisOrDiscount, 0)
			FROM @tblUnRealizedPNL CD
			JOIN @tblRKM2MBasisDetail BasisDetail ON BasisDetail.intFutureMarketId = CD.intFutureMarketId AND BasisDetail.intItemId = CD.intItemId
			AND BasisDetail.strPeriodTo = RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
			AND CD.intTransactionType <> 4 -- Update dblMarketDifferential Other than Inventory (FG)
		END
		ELSE
		BEGIN
			UPDATE CD
			SET CD.dblMarketDifferential = ISNULL(BasisDetail.dblBasisOrDiscount, 0)
			FROM @tblUnRealizedPNL CD
			JOIN @tblRKM2MBasisDetail BasisDetail ON BasisDetail.intFutureMarketId = CD.intFutureMarketId AND BasisDetail.intItemId = CD.intItemId
			AND CD.intTransactionType <> 4 -- Update dblMarketDifferential Other than Inventory (FG)
		END

		UPDATE CD
		SET CD.dblMarketDifferential = ISNULL(BasisDetail.dblBasisOrDiscount, 0)
		FROM @tblUnRealizedPNL CD
		JOIN @tblRKM2MBasisDetail BasisDetail ON BasisDetail.intFutureMarketId = CD.intFutureMarketId AND BasisDetail.intItemId = CD.intItemId
		AND CD.intTransactionType = 4 -- Update dblMarketDifferential Other than Inventory (FG)

		UPDATE CD
		SET CD.dblNetMarketValue = dbo.fnGRConvertQuantityToTargetItemUOM(CD.intItemId, CD.intQuantityUnitMeasureId, CD.intFutureMarketUnitMeasureId, CD.dblQuantity)
									* ( ISNULL(CD.dblSettlementPrice, 0) + ISNULL(CD.dblMarketDifferential, 0))
									/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END
			, CD.dblNetM2MPrice = ISNULL(CD.dblSettlementPrice, 0) + ISNULL(CD.dblMarketDifferential, 0)
		FROM @tblUnRealizedPNL CD
		JOIN tblSMCurrency FCY ON FCY.intCurrencyID = CD.intMarketCurrencyId

		----------------------------------------------------------------------------------------------------------------------------		
		UPDATE @tblUnRealizedPNL
		SET dblCOGSOrNetSaleValue = (ISNULL(dblContractInvoiceValue, 0) + ISNULL(dblSecondaryCosts, 0)) * CASE WHEN intContractTypeId = 1 THEN 1 ELSE -1 END

		UPDATE @tblUnRealizedPNL 
		SET dblProfitOrLossValue = CASE WHEN intContractTypeId = 1 THEN (ISNULL(dblNetMarketValue, 0) - ISNULL(dblCOGSOrNetSaleValue, 0))
										ELSE (ABS(ISNULL(dblCOGSOrNetSaleValue, 0)) - ISNULL(dblNetMarketValue, 0)) END
	
		UPDATE 	UnRealizedPNL
		SET UnRealizedPNL.dblPAndLinMarketUOM = ABS(UnRealizedPNL.dblProfitOrLossValue) / CASE WHEN ABS(UnRealizedPNL.dblProfitOrLossValue) = 0 THEN 1
																							ELSE dbo.fnGRConvertQuantityToTargetItemUOM(UnRealizedPNL.intItemId, UnRealizedPNL.intQuantityUnitMeasureId, UnRealizedPNL.intFutureMarketUnitMeasureId, ISNULL(UnRealizedPNL.dblQuantity, 0)) END
												* (CASE WHEN Currency.ysnSubCurrency = 1 THEN Currency.intCent ELSE 1 END)
		FROM @tblUnRealizedPNL UnRealizedPNL
		JOIN tblSMCurrency Currency ON Currency.intCurrencyID = UnRealizedPNL.intMarketCurrencyId
		
		INSERT INTO tblRKM2MUnrealized(intM2MHeaderId
			, strType
			, intContractTypeId
			, intContractHeaderId
			, strContractType
			, strContractNumber
			, intFreightTermId
			, intTransactionType
			, strTransaction
			, strTransactionType
			, intContractDetailId
			, intCurrencyId
			, intFutureMarketId
			, strFutureMarket
			, intFutureMarketUOMId
			, intFutureMarketUnitMeasureId
			, strFutureMarketUOM
			, intMarketCurrencyId
			, intFutureMonthId
			, strFutureMonth
			, intItemId
			, intBookId
			, strBook
			, strSubBook
			, intCommodityId
			, strCommodity
			, dtmReceiptDate
			, dtmContractDate
			, strContract
			, intContractSeq
			, strEntityName
			, strInternalCompany
			, dblQuantity
			, intQuantityUOMId
			, intQuantityUnitMeasureId
			, strQuantityUOM
			, dblWeight
			, intWeightUOMId
			, intWeightUnitMeasureId
			, strWeightUOM
			, dblBasis
			, intBasisUOMId
			, intBasisUnitMeasureId
			, strBasisUOM
			, dblFutures
			, dblCashPrice
			, intPriceUOMId
			, intPriceUnitMeasureId
			, strContractPriceUOM
			, intOriginId
			, strOrigin
			, strItemDescription
			, strCropYear
			, strProductionLine
			, strCertification
			, strTerms
			, strPosition
			, dtmStartDate
			, dtmEndDate
			, strBLNumber
			, dtmBLDate
			, strAllocationRefNo
			, strAllocationStatus
			, strPriceTerms
			, dblContractDifferential
			, strContractDifferentialUOM
			, dblFuturesPrice
			, strFuturesPriceUOM
			, strFixationDetails
			, dblFixedLots
			, dblUnFixedLots
			, dblContractInvoiceValue
			, dblSecondaryCosts
			, dblCOGSOrNetSaleValue
			, dblInvoicePrice
			, dblInvoicePaymentPrice
			, strInvoicePriceUOM
			, dblInvoiceValue
			, strInvoiceCurrency
			, dblNetMarketValue
			, dtmRealizedDate
			, dblRealizedQty
			, dblProfitOrLossValue
			, dblPAndLinMarketUOM
			, dblPAndLChangeinMarketUOM
			, strMarketCurrencyUOM
			, strTrader
			, strFixedBy
			, strInvoiceStatus
			, strWarehouse
			, strCPAddress
			, strCPCountry
			, strCPRefNo
			, intContractStatusId
			, intPricingTypeId
			, strPricingType
			, strPricingStatus
			, dblMarketDifferential
			, dblNetM2MPrice
			, dblSettlementPrice
			, intCompanyId
			, strCompanyName)
		SELECT intM2MHeaderId
			, strType
			, intContractTypeId
			, intContractHeaderId
			, strContractType
			, strContractNumber
			, intFreightTermId
			, intTransactionType
			, strTransaction
			, strTransactionType
			, intContractDetailId
			, intCurrencyId
			, intFutureMarketId
			, strFutureMarket
			, intFutureMarketUOMId
			, intFutureMarketUnitMeasureId
			, strFutureMarketUOM
			, intMarketCurrencyId
			, intFutureMonthId
			, strFutureMonth
			, intItemId
			, intBookId
			, strBook
			, strSubBook
			, intCommodityId
			, strCommodity
			, dtmReceiptDate
			, dtmContractDate
			, strContract
			, intContractSeq
			, strEntityName
			, strInternalCompany
			, dblQuantity = CAST(dblQuantity AS NUMERIC(38, 20))
			, intQuantityUOMId
			, intQuantityUnitMeasureId
			, strQuantityUOM
			, dblWeight = CAST(dblWeight AS NUMERIC(38, 20))
			, intWeightUOMId
			, intWeightUnitMeasureId
			, strWeightUOM
			, dblBasis
			, intBasisUOMId
			, intBasisUnitMeasureId
			, strBasisUOM
			, dblFutures
			, dblCashPrice
			, intPriceUOMId
			, intPriceUnitMeasureId
			, strContractPriceUOM
			, intOriginId
			, strOrigin
			, strItemDescription
			, strCropYear
			, strProductionLine
			, strCertification
			, strTerms
			, strPosition
			, dtmStartDate
			, dtmEndDate
			, strBLNumber
			, dtmBLDate
			, strAllocationRefNo
			, strAllocationStatus
			, strPriceTerms
			, dblContractDifferential = CAST(dblContractDifferential AS NUMERIC(38, 20))
			, strContractDifferentialUOM
			, dblFuturesPrice = CAST(dblFuturesPrice AS NUMERIC(38, 20))
			, strFuturesPriceUOM
			, strFixationDetails
			, dblFixedLots
			, dblUnFixedLots
			, dblContractInvoiceValue = CAST(dblContractInvoiceValue AS NUMERIC(38, 20))
			, dblSecondaryCosts = CAST(dblSecondaryCosts AS NUMERIC(38, 20))
			, dblCOGSOrNetSaleValue = CAST(dblCOGSOrNetSaleValue AS NUMERIC(38, 20))
			, dblInvoicePrice = CAST(dblInvoicePrice AS NUMERIC(38, 20))
			, dblInvoicePaymentPrice = CAST(dblInvoicePaymentPrice AS NUMERIC(38, 20))
			, strInvoicePriceUOM
			, dblInvoiceValue = CAST(dblInvoiceValue AS NUMERIC(38, 20))
			, strInvoiceCurrency
			, dblNetMarketValue
			, dtmRealizedDate
			, dblRealizedQty = CAST(dblRealizedQty AS NUMERIC(38, 20))
			, dblProfitOrLossValue = CAST(dblProfitOrLossValue AS NUMERIC(38, 20))
			, dblPAndLinMarketUOM = CAST(dblPAndLinMarketUOM AS NUMERIC(38, 20))
			, dblPAndLChangeinMarketUOM = CAST(dblPAndLChangeinMarketUOM AS NUMERIC(38, 20))
			, strMarketCurrencyUOM
			, strTrader
			, strFixedBy
			, strInvoiceStatus
			, strWarehouse
			, strCPAddress
			, strCPCountry
			, strCPRefNo
			, intContractStatusId
			, intPricingTypeId
			, strPricingType
			, strPricingStatus
			, dblMarketDifferential
			, dblNetM2MPrice
			, dblSettlementPrice
			, intCompanyId = ISNULL(intCompanyId, @DefaultCompanyId)
			, strCompanyName = ISNULL(strCompanyName, @DefaultCompanyName)
		FROM @tblUnRealizedPNL
		ORDER BY strTransaction
	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
