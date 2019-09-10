﻿CREATE PROCEDURE [dbo].uspRKM2MValidateInquiryTransaction
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
	DECLARE @intMarkExpiredMonthPositionId INT

	SET @dtmTransactionDateUpTo = left(convert(VARCHAR, @dtmTransactionDateUpTo, 101), 10)

	SELECT TOP 1 @intMarkExpiredMonthPositionId  = intMarkExpiredMonthPositionId FROM tblRKCompanyPreference

	IF (@intMarkExpiredMonthPositionId = 1)
	BEGIN
		SELECT CD.intContractDetailId
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
			AND dtmContractDate <= @dtmTransactionDateUpTo
			AND MO.intFutureMonthId IN (SELECT intFutureMonthId
										FROM tblRKFuturesMonth
										WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, GETDATE()) < GETDATE())
	
		UNION ALL SELECT CT.intFutOptTransactionId intContractDetailId
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
			AND LEFT(CONVERT(VARCHAR, CT.dtmFilledDate, 101), 10) <= @dtmTransactionDateUpTo
			AND MO.intFutureMonthId IN (SELECT intFutureMonthId
										FROM tblRKFuturesMonth
										WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, GETDATE()) < GETDATE())
	END
	ELSE IF (@intMarkExpiredMonthPositionId = 3)
	BEGIN
		SELECT CD.intContractDetailId
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
			AND dtmContractDate <= @dtmTransactionDateUpTo
			AND MO.intFutureMonthId IN (SELECT intFutureMonthId
										FROM tblRKFuturesMonth
										WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, GETDATE()) < GETDATE())
			AND rk.intContractDetailId = CD.intContractDetailId
			AND rk.intFutureMonthId = CD.intFutureMonthId
			AND ISNULL(rk.intNearByFutureMonthId, 0) = 0

		UNION ALL SELECT CD.intContractDetailId
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
			AND dtmContractDate <= @dtmTransactionDateUpTo
			AND MO.intFutureMonthId IN (SELECT intFutureMonthId
										FROM tblRKFuturesMonth
										WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, GETDATE()) < GETDATE())
			AND rk.intContractDetailId = CD.intContractDetailId
			AND rk.intFutureMonthId = CD.intFutureMonthId
			AND CD.intPricingTypeId IN (1, 3)
			AND ISNULL(rk.intNearByFutureMonthId, 0) <> 0
			AND ISNULL(rk.dblNearByFuturePrice, 0) = 0
	END
	ELSE
	BEGIN
		-- Display columns but with no records to validate everything
		SELECT intContractDetailId = NULL
			, intContractHeaderId = NULL
			, intFutOptTransactionHeaderId = NULL
			, strLocationName = NULL
			, strCommodityCode = NULL 
			, strContractType  = NULL
			, strContractNumber = NULL
			, strEntityName = NULL
			, strItemNo = NULL
			, strPricingType = NULL
			, strFutureMonth = NULL
			, strFutMarketName = NULL
			, dtmLastTradingDate = NULL
			, strPhysicalOrFuture = NULL
			, strErrorMsg = NULL
		FROM tblRKCompanyPreference
		WHERE 1 = 0
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