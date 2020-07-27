﻿CREATE PROCEDURE [dbo].[uspRKGenerateM2M]
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
		, @ysnIncludeInTransitM2M BIT

	SELECT TOP 1 @strM2MView = strM2MView
		, @intMarkExpiredMonthPositionId = intMarkExpiredMonthPositionId
		, @ysnIncludeBasisDifferentialsInResults = ysnIncludeBasisDifferentialsInResults
		, @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential
		, @ysnIncludeInventoryM2M = ysnIncludeInventoryM2M
		, @ysnCanadianCustomer = ISNULL(ysnCanadianCustomer, 0)
		, @intMarkExpiredMonthPositionId = intMarkExpiredMonthPositionId
		, @ysnIncludeDerivatives = ysnIncludeDerivatives
		, @ysnIncludeInTransitM2M = ysnIncludeInTransitM2M
	FROM tblRKCompanyPreference

	SELECT TOP 1 @dtmPriceDate = dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId = @intM2MBasisId
	SELECT TOP 1 @dtmSettlemntPriceDate = dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId = @intFutureSettlementPriceId
	SELECT TOP 1 @strLocationName = strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intLocationId
	SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

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

	IF (@strM2MView = '')
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
				JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CL.intCompanyLocationId = CASE WHEN isnull(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
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
					, FM.strFutMarketName
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
					, FM.strFutMarketName
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
				JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CL.intCompanyLocationId = CASE WHEN isnull(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
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
					, FM.strFutMarketName
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
				JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CL.intCompanyLocationId = CASE WHEN isnull(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId ELSE @intLocationId END
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
			, dblShipQty NUMERIC(24,10)
			, ysnSubCurrency BIT
			, intMainCurrencyId INT
			, intCent INT
			, dtmPlannedAvailabilityDate DATETIME
			, dblPricedQty NUMERIC(24, 10)
			, dblUnPricedQty NUMERIC(24, 10)
			, dblPricedAmount NUMERIC(24, 10)
			, intMarketZoneId INT
			, intCompanyLocationId INT
			, strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, dblNotLotTrackedPrice NUMERIC(24, 10)
			, dblInvFuturePrice NUMERIC(24, 10)
			, dblInvMarketBasis NUMERIC(24, 10)
			, dblNoOfLots NUMERIC(24,10)
			, dblLotsFixed NUMERIC(24,10)
			, dblPriceWORollArb NUMERIC(24,10)
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
			, dblDetailQuantity NUMERIC(24,10)
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
			, dblRatio NUMERIC(24,10)
			, dblBasis NUMERIC(24,10)
			, dblFutures NUMERIC(24,10)
			, intContractStatusId INT
			, dblCashPrice NUMERIC(24,10)
			, intContractDetailId INT
			, intFutureMarketId INT
			, intFutureMonthId INT
			, intItemId INT
			, dblBalance NUMERIC(24,10)
			, intCurrencyId INT
			, dblRate NUMERIC(24,10)
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
			, dblNoOfLots NUMERIC(24,10)
			, dblLotsFixed NUMERIC(24,10)
			, dblPriceWORollArb NUMERIC(24,10)
			, dblHeaderNoOfLots NUMERIC(24,10)
			, ysnSubCurrency BIT
			, intCompanyLocationId INT
			, ysnExpired BIT
			, strPricingStatus NVARCHAR(100)
			, strOrgin NVARCHAR(100)
			, ysnMultiplePriceFixation BIT
			, intMarketUOMId INT
			, intMarketCurrencyId INT
			, dblInvoicedQuantity NUMERIC(24,10)
			, dblPricedQty NUMERIC(24,10)
			, dblUnPricedQty NUMERIC(24,10)
			, dblPricedAmount NUMERIC(24,10)
			, strMarketZoneCode NVARCHAR(200))

		--There is an error "An INSERT EXEC statement cannot be nested." that is why we cannot directly call the uspRKDPRContractDetail AND insert
		DECLARE @ContractBalance TABLE (intRowNum INT
			, strCommodityCode NVARCHAR(100)
			, intCommodityId INT
			, intContractHeaderId INT
			, strContractNumber NVARCHAR(100)
			, strLocationName NVARCHAR(100)
			, dtmEndDate DATETIME
			, dblBalance NUMERIC(24,10)
			, dblFutures NUMERIC(24,10)
			, dblBasis NUMERIC(24,10)
			, dblCash NUMERIC(24,10)
			, dblAmount NUMERIC(24,10)
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
			, dtmContractDate = CONVERT(DATETIME, CONVERT(VARCHAR, CB.dtmContractDate, 101),101)
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
			, FM.strFutMarketName
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
											THEN (CASE WHEN strAdjustmentType = 'Add' THEN ABS(CASE WHEN dc.strCostMethod ='Amount' THEN SUM(dc.dblRate)
																									ELSE SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cu1.intCommodityUnitMeasureId, ISNULL(dc.dblRate, 0))) END)
														WHEN strAdjustmentType = 'Reduce' THEN CASE WHEN dc.strCostMethod ='Amount' THEN SUM(dc.dblRate)
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

		DECLARE @tblGetSettlementPrice TABLE (dblLastSettle NUMERIC(24,10)
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
				JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId= pm.intFutureMonthId
				WHERE p.intFutureMarketId =fm.intFutureMarketId
					AND CONVERT(NVARCHAR, dtmPriceDate, 111) <= CONVERT(NVARCHAR, @dtmSettlemntPriceDate, 111)
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
			WHERE p.intFutureMarketId =fm.intFutureMarketId
				AND CONVERT(NVARCHAR, dtmPriceDate, 111) = CONVERT(NVARCHAR, @dtmSettlemntPriceDate, 111)
			ORDER BY dtmPriceDate DESC
		END

		SELECT DISTINCT intContractDetailId
			, dblFuturePrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cuc.intCommodityUnitMeasureId, dblLastSettle / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
			, dblFutures = dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,PUOM.intCommodityUnitMeasureId,cd.dblFutures / CASE WHEN c1.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
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
							* dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId,PUOM.intCommodityUnitMeasureId,ISNULL(dblFixationPrice, 0)))
							/ MAX(CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
							+ ((MAX(ISNULL(CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots
												ELSE cdv.dblNoOfLots END, 0)) - SUM(ISNULL(pfd.[dblNoOfLots], 0)))
							* MAX(dblFuturePrice))
				, intTotLot = MAX(CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots ELSE cdv.dblNoOfLots END)
				, cdv.intContractDetailId
			FROM tblCTContractDetail cdv
			JOIN #tblSettlementPrice p ON cdv.intContractDetailId = p.intContractDetailId
			JOIN tblSMCurrency c ON cdv.intCurrencyId=c.intCurrencyID
			JOIN tblCTContractHeader ch ON cdv.intContractHeaderId = ch.intContractHeaderId AND ch.intCommodityId = @intCommodityId AND cdv.dblBalance > 0
			JOIN tblCTPriceFixation pf ON CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN pf.intContractHeaderId ELSE pf.intContractDetailId END = CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN cdv.intContractHeaderId ELSE cdv.intContractDetailId END
			JOIN tblCTPriceFixationDetail pfd ON pf.intPriceFixationId = pfd.intPriceFixationId AND cdv.intPricingTypeId <> 1 AND cdv.intFutureMarketId = pfd.intFutureMarketId AND cdv.intFutureMonthId = pfd.intFutureMonthId AND cdv.intContractStatusId NOT IN (2, 3, 6)
			JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId=@intCommodityId AND cu.intUnitMeasureId=@intPriceUOMId
			JOIN tblICItemUOM PU ON PU.intItemUOMId = cdv.intPriceItemUOMId
			JOIN tblICCommodityUnitMeasure PUOM ON ch.intCommodityId=PUOM.intCommodityId AND PUOM.intUnitMeasureId=PU.intUnitMeasureId
			GROUP BY cdv.intContractDetailId
		) t

		DECLARE @tblOpenContractList TABLE (intContractHeaderId int
			, intContractDetailId int
			, strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intEntityId int
			, strFutureMarket NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intFutureMarketId int
			, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intFutureMonthId int
			, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intCommodityId int
			, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intItemId int
			, strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intOriginId int
			, strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intPricingTypeId int
			, strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
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
			, dblInvoicedQuantity NUMERIC(24,10)
			, dblPricedQty NUMERIC(24,10)
			, dblUnPricedQty NUMERIC(24,10)
			, dblPricedAmount NUMERIC(24,10)
			, strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, dblNoOfLots NUMERIC(24,10)
			, dblLotsFixed NUMERIC(24,10)
			, dblPriceWORollArb NUMERIC(24,10)
			, dblCashPrice NUMERIC(24,10))

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
		INTO #tmpM2MBasisDetail
		FROM tblRKM2MBasisDetail temp
		LEFT JOIN tblSMCurrency c ON temp.intCurrencyId=c.intCurrencyID
		JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = temp.intCommodityId AND temp.intUnitMeasureId = cum.intUnitMeasureId
		WHERE temp.intM2MBasisId = @intM2MBasisId AND temp.intCommodityId = @intCommodityId

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
			, dblCashPrice)
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
				, dblMarketRatio = ISNULL((SELECT TOP 1 dblRatio FROM #tmpM2MBasisDetail tmp
											WHERE tmp.intFutureMarketId = ISNULL(cd.intFutureMarketId, tmp.intFutureMarketId)
												AND tmp.intItemId = ISNULL(cd.intItemId, tmp.intItemId)
												AND tmp.intContractTypeId = ISNULL(cd.intContractTypeId, tmp.intContractTypeId)
												AND tmp.intCompanyLocationId = ISNULL(cd.intCompanyLocationId, tmp.intCompanyLocationId)
												AND tmp.strPeriodTo = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
																				THEN CASE WHEN tmp.strPeriodTo = '' THEN tmp.strPeriodTo ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END
																			ELSE tmp.strPeriodTo END
												AND tmp.strContractInventory = 'Contract'), 0)
				, dblMarketBasis1 = ISNULL((SELECT TOP 1 dblMarketBasis FROM #tmpM2MBasisDetail tmp
											WHERE tmp.intFutureMarketId = ISNULL(cd.intFutureMarketId, tmp.intFutureMarketId)
												AND tmp.intItemId = ISNULL(cd.intItemId, tmp.intItemId)
												AND tmp.intContractTypeId = ISNULL(cd.intContractTypeId, tmp.intContractTypeId)
												AND tmp.intCompanyLocationId = ISNULL(cd.intCompanyLocationId, tmp.intCompanyLocationId)
												AND tmp.strPeriodTo = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
																				THEN CASE WHEN tmp.strPeriodTo = '' THEN tmp.strPeriodTo ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END
																			ELSE tmp.strPeriodTo END
												AND tmp.strContractInventory = 'Contract' AND cd.strPricingType <> 'HTA'), 0)
				, dblMarketCashPrice = ISNULL((SELECT TOP 1 dblMarketBasis FROM #tmpM2MBasisDetail tmp
											WHERE tmp.intFutureMarketId = ISNULL(cd.intFutureMarketId, tmp.intFutureMarketId)
												AND tmp.intItemId = ISNULL(cd.intItemId, tmp.intItemId)
												AND tmp.intContractTypeId = ISNULL(cd.intContractTypeId, tmp.intContractTypeId)
												AND tmp.intCompanyLocationId = ISNULL(cd.intCompanyLocationId, tmp.intCompanyLocationId)
												AND tmp.strPeriodTo = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
																				THEN CASE WHEN tmp.strPeriodTo = '' THEN tmp.strPeriodTo ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END
																			ELSE tmp.strPeriodTo END
												AND tmp.strContractInventory = 'Contract' AND cd.strPricingType <> 'HTA'), 0)
				, intMarketBasisUOM = ISNULL((SELECT TOP 1 intMarketBasisUOM FROM #tmpM2MBasisDetail tmp
											WHERE tmp.intFutureMarketId = ISNULL(cd.intFutureMarketId, tmp.intFutureMarketId)
												AND tmp.intItemId = ISNULL(cd.intItemId, tmp.intItemId)
												AND tmp.intContractTypeId = ISNULL(cd.intContractTypeId, tmp.intContractTypeId)
												AND tmp.intCompanyLocationId = ISNULL(cd.intCompanyLocationId, tmp.intCompanyLocationId)
												AND tmp.strPeriodTo = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
																				THEN CASE WHEN tmp.strPeriodTo = '' THEN tmp.strPeriodTo ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END
																			ELSE tmp.strPeriodTo END
												AND tmp.strContractInventory = 'Contract'), 0)
				, intMarketBasisCurrencyId = ISNULL((SELECT TOP 1 intMarketBasisCurrencyId FROM #tmpM2MBasisDetail tmp
											WHERE tmp.intFutureMarketId = ISNULL(cd.intFutureMarketId, tmp.intFutureMarketId)
												AND tmp.intItemId = ISNULL(cd.intItemId, tmp.intItemId)
												AND tmp.intContractTypeId = ISNULL(cd.intContractTypeId, tmp.intContractTypeId)
												AND tmp.intCompanyLocationId = ISNULL(cd.intCompanyLocationId, tmp.intCompanyLocationId)
												AND tmp.strPeriodTo = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
																				THEN CASE WHEN tmp.strPeriodTo = '' THEN tmp.strPeriodTo ELSE dbo.fnRKFormatDate(cd.dtmEndDate,'MMM yyyy') END
																			ELSE tmp.strPeriodTo END
												AND tmp.strContractInventory = 'Contract'), 0)
				, dblFuturePrice1 = CASE WHEN cd.strPricingType IN ('Basis', 'Ratio') THEN 0 ELSE p.dblFuturePrice END
				, intFuturePriceCurrencyId
				, intContractTypeId = CONVERT(INT,cd.intContractTypeId)
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
			FROM @GetContractDetailView cd
			JOIN tblICCommodityUnitMeasure cuc ON cd.intCommodityId = cuc.intCommodityId AND cuc.intUnitMeasureId = cd.intUnitMeasureId AND cd.intCommodityId = @intCommodityId
			JOIN tblICCommodityUnitMeasure cuc1 ON cd.intCommodityId = cuc1.intCommodityId AND cuc1.intUnitMeasureId = @intQuantityUOMId
			JOIN tblICCommodityUnitMeasure cuc2 ON cd.intCommodityId = cuc2.intCommodityId AND cuc2.intUnitMeasureId = @intPriceUOMId
			LEFT JOIN #tblSettlementPrice p ON cd.intContractDetailId = p.intContractDetailId
			LEFT JOIN #tblContractCost cc ON cd.intContractDetailId = cc.intContractDetailId
			LEFT JOIN #tblContractFuture cf ON cf.intContractDetailId = cd.intContractDetailId
			LEFT JOIN tblICCommodityUnitMeasure cuc3 ON cd.intCommodityId = cuc3.intCommodityId AND cuc3.intUnitMeasureId = cd.intPriceUnitMeasureId
			LEFT JOIN tblRKFuturesMonth ffm ON ffm.intFutureMonthId = cd.intFutureMonthId 
			WHERE cd.intCommodityId = @intCommodityId 
		)t

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
				SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY SP.intFutureMarketId,  MP.intFutureMonthId ORDER BY SP.dtmPriceDate DESC)
					, SP.intFutureMarketId
					, MP.intFutureMonthId
					, SP.intFutureSettlementPriceId
					, MP.dblLastSettle
					, SP.dtmPriceDate
				FROM tblRKFutSettlementPriceMarketMap MP
				JOIN tblRKFuturesSettlementPrice SP ON MP.intFutureSettlementPriceId = SP.intFutureSettlementPriceId
					AND CONVERT(DATETIME, CONVERT(VARCHAR, SP.dtmPriceDate, 101), 101) <= CONVERT(DATETIME, CONVERT(VARCHAR, @dtmEndDate, 101), 101)
			) SP ON SP.intFutureMarketId = nearby.intFutureMarketId AND SP.intFutureMonthId = nearby.intFutureMonthId
			WHERE ysnExpired = 1
				AND cd.intCommodityId = ISNULL(@intCommodityId, cd.intCommodityId)
				AND CONVERT(DATETIME, CONVERT(VARCHAR, dtmEndDate, 101), 101) = @dtmEndDate
				AND SP.intRowId = 1
				AND nearby.intRowId = 1
		) tbl WHERE intRowNumber = 1
	
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
					, dblResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0)))
					, dblResultBasis = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0)))
					, dblMarketFuturesResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0)))
					, dblResultCash1 = (ISNULL(dblMarketBasis, 0)-ISNULL(dblCash, 0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0)))
					, dblContractPrice = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0)), 0)+(ISNULL(dblFutures, 0)*ISNULL(dblContractRatio,1))
				FROM (
					SELECT *
						, dblMarketBasis = CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,CASE WHEN ISNULL(intMarketBasisUOM, 0)=0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END,ISNULL(dblMarketBasis1, 0)) ELSE 0 END
						, dblAdjustedContractPrice = CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0)+(ISNULL(dblCash, 0)) + CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dblFutures ELSE dblFutures END) + ISNULL(dblCosts, 0) END
						, dblFuturesClosingPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,CASE WHEN ISNULL(intMarketBasisUOM, 0)=0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END,dblFuturesClosingPrice1)
						, dblFuturePrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,CASE WHEN ISNULL(intMarketBasisUOM, 0)=0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END,dblFuturePrice1)
						, dblOpenQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END ,ISNULL(dblOpenQty1, 0))
					FROM (
						SELECT it.intContractHeaderId
							, it.intContractDetailId
							, strContractOrInventoryType = 'In-transit' + CASE WHEN ch.intContractTypeId = 1 THEN '(P)' ELSE '(S)' END
							, it.strContractSeq
							, it.strEntityName
							, it.intEntityId
							, it.strFutureMarket
							, it.intFutureMarketId
							, it.strFutureMonth
							, it.intFutureMonthId
							, it.strCommodityCode
							, it.intCommodityId
							, it.strItemNo
							, it.intItemId
							, it.intItemLocationId
							, strOrgin = NULL
							, i.intOriginId
							, strPosition = NULL
							, strPeriod = RIGHT(CONVERT(VARCHAR(8), cd.dtmStartDate, 3), 5) + '-' + RIGHT(CONVERT(VARCHAR(8), cd.dtmEndDate, 3), 5)
							, strPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20), cd.dtmEndDate, 106), 4, 8)
							, strStartDate = CONVERT(NVARCHAR(20), cd.dtmStartDate, 106)
							, strEndDate = CONVERT(NVARCHAR(20), cd.dtmEndDate, 106)
							, strPriOrNotPriOrParPriced = ISNULL(it.strPricingStatus, pt.strPricingType)
							, intPricingTypeId = ISNULL(it.intPricingTypeId, pt.intPricingTypeId)
							, strPricingType = ISNULL(it.strPricingType, pt.strPricingType)
							, dblContractRatio = cd.dblRatio
							, dblContractBasis = cd.dblBasis
							, dblDummyContractBasis = null
							, cd.dblFutures
							, dblCash = CASE WHEN cd.intPricingTypeId = 6 THEN dblCashPrice ELSE NULL END
							, dblMarketRatio = ISNULL(basisDetail.dblRatio, 0)
							, dblMarketBasis1 = ISNULL(basisDetail.dblMarketBasis, 0)
							, intMarketBasisUOM = ISNULL(basisDetail.intMarketBasisUOM, 0)
							, intMarketBasisCurrencyId = ISNULL(basisDetail.intMarketBasisCurrencyId, 0)
							, dblFuturePrice1 = it.dblLastSettle
							, intFuturePriceCurrencyId = null
							, dblFuturesClosingPrice1 = it.dblLastSettle
							, ch.intContractTypeId
							, dblOpenQty1 = it.dblTotal
							, cd.dblRate
							, intCommodityUnitMeasureId = intOrigUOMId
							, intQuantityUOMId = cuc1.intCommodityUnitMeasureId
							, intPriceUOMId = cuc2.intCommodityUnitMeasureId
							, cd.intCurrencyId
							, PriceSourceUOMId = CONVERT(int,cuc3.intCommodityUnitMeasureId)
							, dblCosts = ISNULL(it.dblCosts, 0)
							, it.ysnSubCurrency
							, it.intMainCurrencyId
							, it.intCent
							, cd.dtmPlannedAvailabilityDate
							, dblInvoicedQuantity = cd.dblInvoicedQty
							, cd.intMarketZoneId
							, it.intLocationId
							, mz.strMarketZoneCode
							, it.strLocationName
							, dblNoOfLots = CASE WHEN ISNULL(ch.ysnMultiplePriceFixation, 0) = 1 THEN ch.dblNoOfLots ELSE cd.dblNoOfLots END
							, dblLotsFixed = NULL --cd.dblLotsFixed
							, dblPriceWORollArb = NULL --cd.dblPriceWORollArb
							, dblCashPrice = 0.00
							, intSpreadMonthId
							, strSpreadMonth
							, dblSpreadMonthPrice
							, dblSpread
							, ysnExpired
						FROM #tempIntransit it
						JOIN tblCTContractDetail cd ON cd.intContractDetailId = it.intContractDetailId
						JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
						JOIN tblICItem i ON cd.intItemId=i.intItemId
						JOIN tblICItemUOM iuom ON it.intItemId = iuom.intItemId AND iuom.intItemUOMId = cd.intBasisUOMId
						JOIN tblCTPricingType pt ON cd.intPricingTypeId = pt.intPricingTypeId
						JOIN tblICCommodityUnitMeasure cuc1 ON ch.intCommodityId = cuc1.intCommodityId AND cuc1.intUnitMeasureId = @intQuantityUOMId
						JOIN tblICCommodityUnitMeasure cuc2 ON ch.intCommodityId = cuc2.intCommodityId AND cuc2.intUnitMeasureId = @intPriceUOMId
						JOIN tblICCommodityUnitMeasure cuc3 ON ch.intCommodityId = cuc3.intCommodityId AND cuc3.intUnitMeasureId= iuom.intUnitMeasureId
						LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = cd.intMarketZoneId
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
						
						UNION ALL
						SELECT 
							 intContractHeaderId = NULL
							, intContractDetailId = NULL
							, 'In-transit' + '(S)' as strContractOrInventoryType
							, strContractSeq = it.strTransactionNumber 
							, strEntityName
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
							, dblOpenQty1 = - it.dblTotal
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
							, dblCashPrice = ROUND(ISNULL((SELECT TOP 1 ISNULL(dblCashOrFuture, 0) FROM tblRKM2MBasisDetail temp
									WHERE temp.intM2MBasisId = @intM2MBasisId
										AND ISNULL(temp.intCommodityId, 0) = CASE WHEN ISNULL(temp.intCommodityId, 0)= 0 THEN 0 ELSE it.intCommodityId END
										AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0)= 0 THEN 0 ELSE it.intItemId END
										AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0)= 0 THEN 0 ELSE ISNULL(it.intLocationId, 0) END
										AND temp.strContractInventory = 'Inventory'), 0),4)
							, intSpreadMonthId = NULL
							, strSpreadMonth = NULL
							, dblSpreadMonthPrice = NULL
							, dblSpread = NULL
							, ysnExpired = NULL
						FROM #tempIntransit it
						WHERE it.intContractDetailId IS NULL
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
				, dblResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0)))
				, dblResultBasis = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0)))
				, dblMarketFuturesResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0)))
				, dblResultCash1 = (ISNULL(dblMarketBasis, 0)-ISNULL(dblCash, 0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0)))
				, dblContractPrice = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0)), 0)+(ISNULL(dblFutures, 0)*ISNULL(dblContractRatio,1))
			FROM (
				SELECT *
					, dblMarketBasis = CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,CASE WHEN ISNULL(intMarketBasisUOM, 0)=0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END,ISNULL(dblMarketBasis1, 0)) ELSE 0 END
					, dblAdjustedContractPrice = CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0) + (ISNULL(dblCash, 0))
													ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0))
																ELSE CASE WHEN (case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0))*ISNULL(dblRate, 0) 
																		ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0)) END END)
						+ CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId) * dblFutures
													ELSE CASE WHEN CASE WHEN ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId THEN dblFutures * ISNULL(dblRate, 0)
															ELSE dblFutures END END)
						+ ISNULL(dblCosts, 0) END
					, dblFuturePrice = dblFuturePrice1
					, dblOpenQty = ISNULL(CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN InTransQty
														ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,InTransQty) END), 0)
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
						, intSpreadMonthId = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
						, strSpreadMonth = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
						, dblSpreadMonthPrice = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice ELSE NULL END ELSE NULL END
						, dblSpread = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice - cd.dblFuturePrice1 ELSE NULL END ELSE NULL END
						, ysnExpired = CASE WHEN strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
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
					--CROSS APPLY dbo.fnRKRollToNearby(cd.intContractDetailId, cd.intFutureMarketId, cd.intFutureMonthId, cd.dblFuturePrice1) rk
					LEFT JOIN #RollNearbyMonth rk ON rk.intContractDetailId = cd.intContractDetailId AND rk.intFutureMonthId = cd.intFutureMonthId
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
				, case when intPricingTypeId=6 THEN dblResult ELSE 0 END dblResultCash
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
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0))) as dblResult
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0))) as dblResultBasis
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0))) as dblMarketFuturesResult
					, (ISNULL(dblMarketBasis, 0)-ISNULL(dblCash, 0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty1, 0))) dblResultCash1
					, ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0)), 0)+(ISNULL(dblFutures, 0) * ISNULL(dblContractRatio,1)) dblContractPrice
				FROM (
					SELECT *
						, CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,CASE WHEN ISNULL(intMarketBasisUOM, 0)=0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END,ISNULL(dblMarketBasis1, 0)) ELSE 0 END dblMarketBasis
						, CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0)+(ISNULL(dblCash, 0))
							ELSE CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(dblRate, 0)=0
																THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0))
															ELSE CASE WHEN (CASE WHEN ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId
																			THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0)) * dblRate
																	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0)) END END)
								+ convert(decimal(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId)* dblFutures
																else case when (case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId THEN dblFutures * dblRate
																		else dblFutures END END)
								+ ISNULL(dblCosts, 0) END dblAdjustedContractPrice
						, dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,CASE WHEN ISNULL(intMarketBasisUOM, 0)=0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END,dblFuturesClosingPrice1) as dblFuturesClosingPrice
						, dblFuturePrice1 as dblFuturePrice
						, ISNULL(CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN dblOpenQty1
															ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,dblOpenQty1) END), 0) as dblOpenQty
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
							, intSpreadMonthId = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
							, strSpreadMonth = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
							, dblSpreadMonthPrice = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice ELSE NULL END ELSE NULL END
							, dblSpread = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice - cd.dblFuturePrice1 ELSE NULL END ELSE NULL END
							, ysnExpired = CASE WHEN strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
						FROM @tblOpenContractList cd
						JOIN vyuRKGetPurchaseInventory l ON cd.intContractDetailId =l.intContractDetailId
						JOIN tblICItem i ON cd.intItemId= i.intItemId AND i.strLotTracking<>'No'
						--CROSS APPLY dbo.fnRKRollToNearby(cd.intContractDetailId, cd.intFutureMarketId, cd.intFutureMonthId, cd.dblFuturePrice1) rk
						LEFT JOIN #RollNearbyMonth rk ON rk.intContractDetailId = cd.intContractDetailId AND rk.intFutureMonthId = cd.intFutureMonthId
						WHERE rk.intContractDetailId = cd.intContractDetailId
							AND rk.intFutureMonthId = cd.intFutureMonthId
							AND cd.intCommodityId = @intCommodityId
					)t
				)t1
			)t2
			WHERE strContractOrInventoryType= case when @ysnIncludeInventoryM2M = 1 THEN 'Inventory (P)' ELSE '' END
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
			, case when intPricingTypeId=6 THEN dblResult ELSE 0 END dblResultCash
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
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0))) as dblResult
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0))) as dblResultBasis
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0))) as dblMarketFuturesResult
				, (ISNULL(dblMarketBasis, 0)-ISNULL(dblCash, 0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,intCommodityUnitMeasureId,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,ISNULL(intPriceUOMId,intCommodityUnitMeasureId),ISNULL(dblOpenQty, 0))) dblResultCash1
				, 0 dblContractPrice
			FROM (
				SELECT *
					, CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId,CASE WHEN ISNULL(intMarketBasisUOM, 0)=0 THEN PriceSourceUOMId ELSE intMarketBasisUOM END,ISNULL(dblMarketBasis1, 0)) ELSE 0 END dblMarketBasis
					, CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0)+(ISNULL(dblCash, 0))
							ELSE CONVERT(DECIMAL(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0))
															ELSE CASE WHEN (case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId
																		THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0))*ISNULL(dblRate, 0) 
																	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0)) END END) 
								+ CONVERT(decimal(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId)* dblFutures
															else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId THEN dblFutures*ISNULL(dblRate, 0)
																	else dblFutures END END)
								+ ISNULL(dblCosts, 0) END AS dblAdjustedContractPrice
					, dblFuturePrice1 as dblFuturePrice
					, convert(decimal(24,6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 THEN dblContractOriginalQty
												else dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,CASE WHEN ISNULL(intQuantityUOMId, 0)=0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END,dblContractOriginalQty) END)
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
						, convert(int,cd.PriceSourceUOMId) PriceSourceUOMId
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
						, intSpreadMonthId = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.intNearByFutureMonthId ELSE NULL END ELSE NULL END
						, strSpreadMonth = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.strNearByFutureMonth ELSE NULL END ELSE NULL END
						, dblSpreadMonthPrice = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice ELSE NULL END ELSE NULL END
						, dblSpread = CASE WHEN strPricingType = 'Priced' THEN CASE WHEN rk.ysnExpired = 1 THEN rk.dblNearbySettlementPrice - cd.dblFuturePrice1 ELSE NULL END ELSE NULL END
						, ysnExpired = CASE WHEN strPricingType = 'Priced' THEN ISNULL(rk.ysnExpired, 0) ELSE NULL END
					FROM @tblOpenContractList cd
					LEFT JOIN (SELECT SUM(LD.dblQuantity)dblQuantity
									, PCT.intContractDetailId
								FROM tblLGLoad L
								JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
								JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId AND PCT.dblQuantity > ISNULL(PCT.dblInvoicedQty, 0)
								GROUP BY PCT.intContractDetailId
						
								UNION ALL SELECT SUM(LD.dblQuantity)dblQuantity
									, PCT.intContractDetailId
								from tblLGLoad L
								JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
								JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intSContractDetailId AND PCT.dblQuantity > PCT.dblInvoicedQty
								group by PCT.intContractDetailId
					) AS LG ON LG.intContractDetailId = cd.intContractDetailId
					--CROSS APPLY dbo.fnRKRollToNearby(cd.intContractDetailId, cd.intFutureMarketId, cd.intFutureMonthId, cd.dblFuturePrice1) rk
					LEFT JOIN #RollNearbyMonth rk ON rk.intContractDetailId = cd.intContractDetailId AND rk.intFutureMonthId = cd.intFutureMonthId
					--WHERE rk.intContractDetailId = cd.intContractDetailId
					--	AND rk.intFutureMonthId = cd.intFutureMonthId
				) t
			) t where ISNULL(dblOpenQty, 0) > 0
		) t1

		SELECT *
			, dblContractPrice = ISNULL(dblContractBasis, 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1))
			, dblResult = CONVERT(DECIMAL(24, 6), ((ISNULL(dblMarketBasis, 0) - ISNULL(dblContractBasis, 0) + ISNULL(dblCosts, 0))) * ISNULL(dblResultBasis1, 0)) + CONVERT(DECIMAL(24, 6),((ISNULL(dblFutures, 0) - ISNULL(dblFuturePrice, 0)) * ISNULL(dblMarketFuturesResult1, 0)))
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
				, convert(decimal(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblDummyContractBasis, 0))
											else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																	then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblDummyContractBasis, 0)) * dblRate
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblDummyContractBasis, 0)) END END) as dblDummyContractBasis
				, case when @ysnCanadianCustomer= 1 THEN dblContractBasis
					else convert(decimal(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0))
													else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0))*dblRate
															else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0)) END END) END as dblContractBasis
				, convert(decimal(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0))
											else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																	then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0))*dblRate 
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblContractBasis, 0)) END END) as dblCanadianContractBasis
				, case when @ysnCanadianCustomer = 1 THEN dblFutures
						else convert(decimal(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId) * dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblFutures, 0))
					else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblFutures, 0)) * dblRate
							else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblFutures, 0)) END END) END as dblFutures
				, convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,dblCash)) as dblCash
				, dblCosts as dblCosts
				, dblMarketRatio
				, case when @ysnCanadianCustomer= 1 THEN dblMarketBasis
					else convert(decimal(24,6),CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblMarketBasis, 0))
													else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblMarketBasis, 0)) * dblRate
															else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,ISNULL(dblMarketBasis, 0)) END END) END as dblMarketBasis
				, intMarketBasisCurrencyId
				, dblFuturePrice = CASE WHEN strPricingType = 'Basis' THEN 0 ELSE dblFuturePrice1 END
				, intFuturePriceCurrencyId
				, convert(decimal(24,6),dblFuturesClosingPrice) dblFuturesClosingPrice
				, CONVERT(int,intContractTypeId) as intContractTypeId
				, dblAdjustedContractPrice
				, dblCashPrice as dblCashPrice
				, case when ysnSubCurrency = 1 THEN (convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,dblResultCash))) / ISNULL(intCent, 0)
						else convert(decimal(24,6),dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(PriceSourceUOMId, 0)=0 THEN intPriceUOMId ELSE PriceSourceUOMId END,dblResultCash)) END as dblResultCash1
				, dblResult as dblResult1
				, CASE WHEN ISNULL(@ysnIncludeBasisDifferentialsInResults, 0) = 0 THEN 0 ELSE dblResultBasis END as dblResultBasis1
				, dblMarketFuturesResult as dblMarketFuturesResult1
				, intQuantityUOMId
				, intCommodityUnitMeasureId
				, intPriceUOMId
				, intCent
				, dtmPlannedAvailabilityDate
				, CONVERT(decimal(24,6), CASE WHEN ISNULL(dblRate, 0)=0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END,@intCurrencyId) * dblFutures
											else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId THEN dblFutures * dblRate
													else dblFutures END END) dblCanadianFutures
				, dblPricedQty
				, dblUnPricedQty
				, dblPricedAmount
				, intCompanyLocationId
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
		ORDER BY intCommodityId,strContractSeq DESC

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
			WHERE ysnExpired = 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmSpotDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10),getdate(), 110), 110)
				AND intFutureMarketId = 1
			ORDER BY dtmSpotDate DESC
	
			INSERT INTO #Temp (strContractOrInventoryType
				, strCommodityCode
				, intCommodityId
				, strItemNo
				, intItemId
				, strLocationName
				, intCompanyLocationId
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
					,intCurrencyId
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
						, (SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate <= GETDATE() AND intFutureMarketId =c.intFutureMarketId ORDER BY 1 DESC) strFutureMonth
						, (SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate <= GETDATE() AND intFutureMarketId =c.intFutureMarketId ORDER BY 1 DESC) intFutureMonthId
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
						AND ISNULL(strTicketStatus,'') <> 'V'
						AND convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmEndDate)
						AND ysnInTransit = 0
					GROUP BY i.intItemId
							,i.strItemNo
							,s.intItemLocationId
							,s.intLocationId
							,strLocationName
							,strCommodityCode
							,c.intCommodityId
							,c.intFutureMarketId
							,cuom.intCommodityUnitMeasureId
							,iuomTo.intItemUOMId
							,iuomStck.intItemUOMId
							,cu2.intCommodityUnitMeasureId
							,bd.intUnitMeasureId
							,bd.dblCashOrFuture
							,bd.intCurrencyId
					
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
					,intCurrencyId
					,dblCashOrFuture
			)t2 WHERE ISNULL(dblOpenQty, 0) <> 0

			--Collateral
			SELECT 
					col.intCollateralId
				,strContractOrInventoryType = 'Inventory' 
				, loc.strLocationName
				, col.intLocationId
				, c.strCommodityCode
				, c.intCommodityId
				, i.strItemNo
				, i.intItemId
				, dblOpenQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(col.intUnitMeasureId,@intQuantityUOMId,col.dblOriginalQuantity - ISNULL(ca.dblAdjustmentAmount, 0))
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
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmAdjustmentDate, 110), 110) <= CONVERT(DATETIME, @dtmEndDate)
				GROUP BY intCollateralId

			) ca ON col.intCollateralId = ca.intCollateralId
			WHERE col.intCommodityId = @intCommodityId
			AND col.intLocationId = ISNULL(@intLocationId, col.intLocationId) 
			AND col.ysnIncludeInPriceRiskAndCompanyTitled = 1

			DECLARE @intCollateralId INT
					,@intCommodityIdCollateral INT
					,@intItemIdCollateral INT
					,@intLocationIdCollateral INT
					,@dblOpenQtyCollateral NUMERIC(18,6)
				
			WHILE (SELECT Count(*) FROM #tempCollateral) > 0
			BEGIN
				SELECT 
					@intCollateralId = intCollateralId 
					,@intCommodityIdCollateral = intCommodityId
					,@intItemIdCollateral = intItemId
					,@intLocationIdCollateral = intLocationId
					,@dblOpenQtyCollateral = dblOpenQty
				FROM #tempCollateral

				--Add Collateral Qty if Inventory exist ELSE insert a new entry
				IF EXISTS (SELECT TOP 1 * FROM #Temp
								WHERE intCommodityId = @intCommodityIdCollateral
								AND intItemId = @intItemIdCollateral
								AND intCompanyLocationId = @intLocationIdCollateral
								AND strContractOrInventoryType = 'Inventory'
				)
				BEGIN
					UPDATE #Temp SET dblOpenQty = dblOpenQty + @dblOpenQtyCollateral
					WHERE intCommodityId = @intCommodityIdCollateral
						AND intItemId = @intItemIdCollateral
						AND intCompanyLocationId = @intLocationIdCollateral

				END
				ELSE
				BEGIN
					INSERT INTO #Temp (strContractOrInventoryType
						, strCommodityCode
						, intCommodityId
						, strItemNo
						, intItemId
						, strLocationName
						, intCompanyLocationId
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
				, intCompanyLocationId
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
					, intCompanyLocationId
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
					, dblOpenQty
					, dblResult = dblOpenQty
					, dblCashOrFuture = dbo.fnCTConvertQuantityToTargetCommodityUOM(PriceSourceUOMId, intMarketBasisUOM, dblCashOrFuture)
					,intCurrencyId
				FROM (
					SELECT 
						'In-transit(I)' as strContractOrInventoryType
						, strContractSeq
						, strLocationName
						, intCompanyLocationId
						, strCommodityCode
						, intCommodityId
						, strItemNo
						, intItemId
						, dblOpenQty = ABS(dblOpenQty)
						, ISNULL((SELECT TOP 1 intUnitMeasureId FROM tblRKM2MBasisDetail temp
								WHERE temp.intM2MBasisId = @intM2MBasisId
									AND ISNULL(temp.intCommodityId, 0) = CASE WHEN ISNULL(temp.intCommodityId, 0)= 0 THEN 0 ELSE intCommodityId END
									AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0)= 0 THEN 0 ELSE intItemId END
									AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0)= 0 THEN 0 ELSE ISNULL(intCompanyLocationId, 0) END
									AND temp.strContractInventory = 'Inventory'), 0) as PriceSourceUOMId
						, dblInvMarketBasis = 0
						,ROUND(ISNULL((SELECT TOP 1 ISNULL(dblCashOrFuture, 0) FROM tblRKM2MBasisDetail temp
								WHERE temp.intM2MBasisId = @intM2MBasisId
									AND ISNULL(temp.intCommodityId, 0) = CASE WHEN ISNULL(temp.intCommodityId, 0)= 0 THEN 0 ELSE intCommodityId END
									AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0)= 0 THEN 0 ELSE intItemId END
									AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0)= 0 THEN 0 ELSE ISNULL(intCompanyLocationId, 0) END
									AND temp.strContractInventory = 'Inventory'), 0),4) as dblCashOrFuture
						,ISNULL((SELECT TOP 1 ISNULL(temp.intUnitMeasureId, 0) FROM tblRKM2MBasisDetail temp
								WHERE temp.intM2MBasisId = @intM2MBasisId
									AND ISNULL(temp.intCommodityId, 0) = CASE WHEN ISNULL(temp.intCommodityId, 0)= 0 THEN 0 ELSE intCommodityId END
									AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0)= 0 THEN 0 ELSE intItemId END
									AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0)= 0 THEN 0 ELSE ISNULL(intCompanyLocationId, 0) END
									AND temp.strContractInventory = 'Inventory'), 0) as intMarketBasisUOM
						,ISNULL((SELECT TOP 1 ISNULL(intCurrencyId, 0) FROM tblRKM2MBasisDetail temp
								WHERE temp.intM2MBasisId = @intM2MBasisId
									AND ISNULL(temp.intCommodityId, 0) = CASE WHEN ISNULL(temp.intCommodityId, 0)= 0 THEN 0 ELSE intCommodityId END
									AND ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0)= 0 THEN 0 ELSE intItemId END
									AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0)= 0 THEN 0 ELSE ISNULL(intCompanyLocationId, 0) END
									AND temp.strContractInventory = 'Inventory'), 0) as intCurrencyId
						, (SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate <= GETDATE() AND intFutureMarketId =intFutureMarketId ORDER BY 1 DESC) strFutureMonth
						, (SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate <= GETDATE() AND intFutureMarketId =intFutureMarketId ORDER BY 1 DESC) intFutureMonthId
						, intFutureMarketId
						, dblNotLotTrackedPrice = ISNULL(dbo.fnCalculateValuationAverageCost(intItemId, intItemLocationId, @dtmEndDate), 0)
					FROM @ListTransaction
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
				, intCompanyLocationId
				, strFutureMonth
				, intFutureMonthId
				, strFutureMarket
				, intFutureMarketId
				, dblFutures
				, dblOpenQty
				, dblInvFuturePrice
				, intCurrencyId)
			SELECT 
					strContractOrInventoryType = CASE WHEN strNewBuySell = 'Buy' THEN 'Futures(B)' ELSE 'Futures(S)' END
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
			FROM fnRKGetOpenFutureByDate (@intCommodityId, '1/1/1900',@dtmEndDate, 1) DER
			LEFT JOIN @tblGetSettlementPrice SP ON SP.intFutureMarketId = DER.intFutureMarketId AND SP.intFutureMonthId = DER.intFutureMonthId
			WHERE intCommodityId = @intCommodityId 
				AND ISNULL(ysnPreCrush, 0) = 0 
				AND ysnExpired = 0
				AND intInstrumentTypeId = 1
				AND dblOpenContract <> 0

		END


		DECLARE @strM2MCurrency NVARCHAR(20)
			, @dblRateConfiguration NUMERIC(18,6)

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
		SELECT intRowNum = CONVERT(INT,ROW_NUMBER() OVER(ORDER BY intFutureMarketId DESC))
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
			, intCompanyLocationId
			, intMarketZoneId
			, strMarketZoneCode
			, strLocationName 
			, dblResult = case when strPricingType='Cash' THEN 
									ROUND(dblResultCash,2) 
								else 
									ROUND((dblMarketPrice - dblAdjustedContractPrice) * dblOpenQty,2)
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
				, dblContractBasis = (CASE WHEN strPricingType != 'HTA'
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
				, dblMarketBasis = (CASE WHEN strPricingType != 'HTA' THEN
										CASE WHEN @ysnCanadianCustomer = 1 AND @strM2MCurrency = 'CAD'
											THEN (CASE WHEN strMBCurrency = 'USD' AND strFPCurrency = 'USD'
														--USD/CAD
														THEN (CASE WHEN @strRateType = 'Contract'
																	--Formula: Market Price - Market Futures
																	THEN ((ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0)=0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0))
																		/ dblRate)
																		- dblConvertedFuturePrice
																--Configuration
																--Formula: Market Price - Market Futures
																ELSE ((ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0)=0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0))
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
																	THEN (ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0)=0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0))
																		/ dblRate
																	--Configuration
																	ELSE (ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0)=0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0))
																		/ @dblRateConfiguration END)
													--When both currencies is not equal to M2M currency
													WHEN intMarketBasisCurrencyId <> @intCurrencyId OR intFuturePriceCurrencyId <> @intCurrencyId
														THEN ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0)=0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0)
													--Can be used other currency exchange
													ELSE ISNULL(dblMarketBasis, 0) + (dblConvertedFuturePrice * CASE WHEN ISNULL(dblMarketRatio, 0)=0 THEN 1 ELSE dblMarketRatio END) + ISNULL(dblCashPrice, 0) END)
										ELSE ISNULL(dblMarketBasis, 0) + (ISNULL(dblConvertedFuturePrice, 0) * CASE WHEN ISNULL(dblMarketRatio, 0)=0 THEN 1 ELSE ISNULL(dblMarketRatio, 0) END) + ISNULL(dblCashPrice, 0) END
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
				, intCompanyLocationId
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
				, dblContractBasis = (CASE WHEN strPricingType != 'HTA'
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
				, dblResultCash = ROUND((ISNULL(dblCashPrice, 0) - ISNULL(dblCash, 0)) * Round(dblOpenQty,2),2)
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

	END
	--ELSE
	--BEGIN
	--	 EXEC uspRKGetUnRealizedPNL
	--END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH