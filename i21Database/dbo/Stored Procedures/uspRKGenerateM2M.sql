CREATE PROCEDURE [dbo].[uspRKGenerateM2M]
	@intM2MHeaderId INT OUTPUT
	, @strRecordName NVARCHAR(50) = NULL
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
	, @intUserId INT = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

--SELECT * FROM tblRKM2MHeader

--DECLARE
--@intM2MHeaderId INT = 4
--  , @strRecordName NVARCHAR(50) = 'M2M-5'
--	, @intCommodityId INT = 70
--	, @intM2MTypeId INT = 1
--	, @intM2MBasisId INT = 9
--	, @intFutureSettlementPriceId INT = 6
--	, @intQuantityUOMId INT = 4
--	, @intPriceUOMId INT = 4
--	, @intCurrencyId INT = 2
--	, @dtmEndDate DATETIME = '2020-10-07 00:00:00.000'
--	, @strRateType NVARCHAR(200) = 'Contract'
--	, @intLocationId INT = NULL
--	, @intMarketZoneId INT = NULL
--	, @ysnByProducer BIT = 0
--	, @intCompanyId INT = NULL
--	, @dtmPostDate DATETIME = '2020-10-07 00:00:00.000'
--	, @dtmReverseDate DATETIME = NULL
--	, @dtmLastReversalDate DATETIME = NULL
--	, @intUserId INT = 1

	IF OBJECT_ID('tempdb..#tblContractCost') IS NOT NULL
		DROP TABLE #tblContractCost
	IF OBJECT_ID('tempdb..#tmpAllocatedContracts') IS NOT NULL
		DROP TABLE #tmpAllocatedContracts
	IF OBJECT_ID('tempdb..#tmpPartialPricedContracts') IS NOT NULL
		DROP TABLE #tmpPartialPricedContracts
	IF OBJECT_ID('tempdb..#tblSettlementPrice') IS NOT NULL
		DROP TABLE #tblSettlementPrice
	IF OBJECT_ID('tempdb..#tblPIntransitView') IS NOT NULL
		DROP TABLE #tblPIntransitView
	IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
		DROP TABLE #Temp
	IF OBJECT_ID('tempdb..#tmpM2MBasisDetail') IS NOT NULL
		DROP TABLE #tmpM2MBasisDetail
	IF OBJECT_ID('tempdb..#RollNearbyMonth') IS NOT NULL
		DROP TABLE #RollNearbyMonth
	IF OBJECT_ID('tempdb..#tmpCPE') IS NOT NULL
		DROP TABLE #tmpCPE
	IF OBJECT_ID('tempdb..#tmpM2MDifferentialBasis') IS NOT NULL
		DROP TABLE #tmpM2MDifferentialBasis
	IF OBJECT_ID('tempdb..#tmpM2MTransaction') IS NOT NULL
		DROP TABLE #tmpM2MTransaction
	IF OBJECT_ID('tempdb..#tempIntransit') IS NOT NULL
		DROP TABLE #tempIntransit
	IF OBJECT_ID('tempdb..#tempCollateral') IS NOT NULL
		DROP TABLE #tempCollateral
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
	IF (ISNULL(@intCompanyId, 0) = 0) SET @intCompanyId = NULL
	IF (ISNULL(@intUserId, 0) = 0) SET @intUserId = NULL
	IF (ISNULL(@dtmPostDate, '') = '') SET @dtmPostDate = GETDATE()

	DECLARE @ErrMsg NVARCHAR(MAX)

	DECLARE @strM2MView NVARCHAR(50)
		, @intMarkExpiredMonthPositionId INT
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
		, @ysnEvaluationByLocation BIT
        , @ysnEvaluationByMarketZone BIT
        , @ysnEvaluationByOriginPort BIT
        , @ysnEvaluationByDestinationPort BIT
        , @ysnEvaluationByCropYear BIT
        , @ysnEvaluationByStorageLocation BIT
        , @ysnEvaluationByStorageUnit BIT
		, @ysnEnableAllocatedContractsGainOrLoss BIT
		, @strM2MType NVARCHAR(50)
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell BIT
		, @dtmCurrentDate DATETIME = GETDATE()
		, @dtmCurrentDay DATETIME = DATEADD(DD, DATEDIFF(DD, 0, GETDATE()), 0)
		, @intMarkToMarketRateTypeId INT
		, @ysnEnableMTMPoint BIT
		, @ysnIncludeProductInformation BIT
		, @intFunctionalCurrencyId INT

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
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell
		, @ysnEvaluationByLocation = ysnEvaluationByLocation 
        , @ysnEvaluationByMarketZone = ysnEvaluationByMarketZone 
        , @ysnEvaluationByOriginPort = ysnEvaluationByOriginPort 
        , @ysnEvaluationByDestinationPort = ysnEvaluationByDestinationPort 
        , @ysnEvaluationByCropYear = ysnEvaluationByCropYear 
        , @ysnEvaluationByStorageLocation = ysnEvaluationByStorageLocation 
        , @ysnEvaluationByStorageUnit = ysnEvaluationByStorageUnit 
		, @ysnEnableAllocatedContractsGainOrLoss = ysnEnableAllocatedContractsGainOrLoss
		, @ysnIncludeProductInformation = ysnIncludeProductInformation
	FROM tblRKCompanyPreference

	SELECT @intFunctionalCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

	SELECT TOP 1 @dtmPriceDate = dtmM2MBasisDate FROM tblRKM2MBasis WHERE intM2MBasisId = @intM2MBasisId
	SELECT TOP 1 @dtmSettlemntPriceDate = dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId = @intFutureSettlementPriceId
	SELECT TOP 1 @strLocationName = strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intLocationId
	SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
	SELECT TOP 1 @strM2MType = strType FROM tblRKM2MType WHERE intM2MTypeId = @intM2MTypeId
	SELECT TOP 1 @intMarkToMarketRateTypeId = intMarkToMarketRateTypeId FROM tblSMMultiCurrency 
	SELECT TOP 1 @ysnEnableMTMPoint = ysnEnableMTMPoint FROM tblCTCompanyPreference


	SET @dtmEndDate = LEFT(CONVERT(VARCHAR, @dtmEndDate, 101), 10)

	IF (ISNULL(@strRecordName, '') = '')
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
	ELSE
	BEGIN
		SELECT TOP 1 @intM2MHeaderId = intM2MHeaderId FROM tblRKM2MHeader WHERE strRecordName = @strRecordName
	END

	DELETE FROM tblRKM2MValidateError WHERE intM2MHeaderId = @intM2MHeaderId

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
												WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, @dtmCurrentDate) < @dtmCurrentDate)
	
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
												WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, @dtmCurrentDate) < @dtmCurrentDate)
				
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
												WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, @dtmCurrentDate) < @dtmCurrentDate)
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
												WHERE ISNULL(ysnExpired, 0) = 1 OR ISNULL(dtmLastTradingDate, @dtmCurrentDate) < @dtmCurrentDate)
					AND rk.intContractDetailId = CD.intContractDetailId
					AND rk.intFutureMonthId = CD.intFutureMonthId
					AND CD.intPricingTypeId IN (1, 3)
					AND ISNULL(rk.intNearByFutureMonthId, 0) <> 0
					AND ISNULL(rk.dblNearByFuturePrice, 0) = 0
					AND MO.ysnExpired = 1

				SET @ErrMsg = 'Nearby Month not found for delinquent contracts.'
			END
		END

		IF @intMarkToMarketRateTypeId IS NULL AND @strRateType = 'Configuration'
		BEGIN
			SET @ErrMsg = 'Missing Mark to Market Rate Type setup in Company Configuration > Multi Currency > Mark to Market.'
			RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
			--RETURN
		END

		IF @strRateType = 'Contract'
		BEGIN
			SET @intMarkToMarketRateTypeId = NULL
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
			, ysnExpired BIT
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
			, intProductTypeId INT
			, intGradeId INT
			, intRegionId INT
			, intSeasonId INT	
			, intClassVarietyId INT	
			, intProductLineId INT	
			, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strCertification NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
			, strGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strRegion NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strSeason NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strClass NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strBook NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intBookId INT
			, strSubBook NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intSubBookId INT
			, intFMMainCurrencyId INT
			, ysnFMSubCurrency BIT
			, strMTMPoint NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, intMTMPointId INT
		)

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
			, strMarketZoneCode NVARCHAR(200)
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
			, intProductTypeId INT
			, intGradeId INT
			, intRegionId INT
			, intSeasonId INT	
			, intClassVarietyId INT	
			, intProductLineId INT	
			, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strCertification NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
			, strGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strRegion NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strSeason NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strClass NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strBook NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intBookId INT
			, strSubBook NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intSubBookId INT
			, intMTMPointId INT
			, strMTMPoint NVARCHAR(100) COLLATE Latin1_General_CI_AS
		)
			
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
			, strPricingStatus NVARCHAR(50)
			, intBookId INT
			, intSubBookId INT)

		SELECT *
		INTO #CBBucket
		FROM dbo.fnRKGetBucketContractBalance(@dtmEndDate, @intCommodityId, NULL)

		SELECT intContractDetailId, intContractStatusId
		INTO #ContractStatus
		FROM (
			SELECT intRowNumber = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmCreateDate DESC, intContractBalanceLogId DESC)
				, intContractDetailId
				, intContractStatusId
			FROM #CBBucket
		) tbl
		WHERE intRowNumber = 1
		
		SELECT DISTINCT a.intContractDetailId, a.strContractNumber
			, CASE WHEN b.intCounter > 1 THEN 'Partially Priced'
				WHEN b.intCounter = 1 AND strPricingType IN ('Basis', 'HTA', 'Ratio') THEN 'Unpriced'
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
			, intEntityId
			, strEntityName
			, intQtyCurrencyId
			, intBookId
			, intSubBookId
		INTO #tempLatestContractDetails
		FROM
		(
			SELECT 
				intContractHeaderId
				, intContractDetailId
				, dtmEndDate 
				, dblBasis
				, dblFutures
				, intQtyUOMId
				, t.intEntityId
				, strEntityName = EM.strName
				, intQtyCurrencyId
			FROM (
				SELECT 
					intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId 
													ORDER BY CASE WHEN CBL.strAction = 'Created Price' 
																THEN CBL.dtmTransactionDate 
																ELSE dbo.[fnCTConvertDateTime](CBL.dtmCreatedDate,'ToServerDate',0) 
																END DESC
															, CBL.intContractBalanceLogId DESC )
					,*
				FROM tblCTContractBalanceLog CBL
				WHERE dbo.fnRemoveTimeOnDate(CASE WHEN CBL.strAction = 'Created Price' THEN CBL.dtmTransactionDate ELSE dbo.[fnCTConvertDateTime](CBL.dtmCreatedDate,'ToServerDate',0) END) <= @dtmEndDate
				AND CBL.intCommodityId = ISNULL(@intCommodityId, CBL.intCommodityId)
				AND CBL.strTransactionType = 'Contract Balance'
				AND (CBL.dblBasis IS NOT NULL OR CBL.intPricingTypeId = 3)
			) t
			LEFT JOIN tblEMEntity EM ON EM.intEntityId = t.intEntityId
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
			, strPricingStatus
			, intBookId
			, intSubBookId
		)
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
			, intBookId
			, intSubBookId
		FROM (
			SELECT dtmTransactionDate = MAX(dtmTransactionDate)
				, strCommodityCode
				, intCommodityId
				, tbl.intContractHeaderId
				, strContractNumber
				, strLocationName
				, lcd.dtmEndDate
				, dblQty = CAST(SUM(dblQuantity) AS NUMERIC(20, 6))
				, dblFutures = CAST((CASE WHEN intPricingTypeId = 1 OR intPricingTypeId = 3 THEN lcd.dblFutures ELSE 0 END) AS NUMERIC(20, 6))
				, dblBasis = CAST(lcd.dblBasis AS NUMERIC(20, 6))	
				, dblCashPrice = CAST (MAX(dblCashPrice) AS NUMERIC(20, 6))
				, dblAmount = CAST ((SUM(dblQuantity) * (lcd.dblBasis + (CASE WHEN intPricingTypeId = 1 OR intPricingTypeId = 3 THEN lcd.dblFutures ELSE 0 END))) AS NUMERIC(20, 6))
				, lcd.intQtyUOMId
				, intPricingTypeId
				, intContractTypeId
				, intLocationId
				, strContractType
				, strPricingType
				, intCommodityUnitMeasureId = NULL
				, tbl.intContractDetailId
				, lcd.intEntityId
				, lcd.intQtyCurrencyId
				, strType = strContractType + ' ' + strPricingType
				, intItemId
				, strItemNo
				, lcd.strEntityName
				, strCustomerContract = ''
				--, intFutureMarketId
				--, intFutureMonthId
				, strPricingStatus = CASE WHEN lcd.ysnFullyPriced = 1 THEN 'Fully Priced' ELSE strPricingStatus END
				, lcd.intBookId
				, lcd.intSubBookId
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
					--, CBL.intEntityId
					--, CBL.intQtyCurrencyId
					, CBL.intItemId
					, strItemNo
					--, strEntityName = EM.strName
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
				, lcd.intBookId
				, lcd.intSubBookId
			HAVING SUM(dblQuantity) > 0
			
		) tbl
		JOIN #ContractStatus cs ON cs.intContractDetailId = tbl.intContractDetailId
		WHERE cs.intContractStatusId NOT IN (2, 3, 6, 5) 

		-- GET ALLOCATED CONTRACTS
		SELECT *
		INTO #tmpAllocatedContracts
		FROM 
		(
			SELECT intContractDetailId = allocD.intPContractDetailId -- Purchase
				, intAllocatedUnitMeasureId = allocH.intWeightUnitMeasureId
				, dblAllocatedQty = SUM(allocD.dblPAllocatedQty)
			FROM tblLGAllocationDetail allocD
			LEFT JOIN tblLGAllocationHeader allocH
				ON allocH.intAllocationHeaderId = allocD.intAllocationHeaderId
			WHERE @ysnEnableAllocatedContractsGainOrLoss = 1
			AND dbo.fnRemoveTimeOnDate(allocD.dtmAllocatedDate) <= @dtmEndDate
			GROUP BY allocD.intPContractDetailId, allocH.intWeightUnitMeasureId

			UNION
			
			SELECT intContractDetailId = allocD.intSContractDetailId -- Sale
				, intAllocatedUnitMeasureId = allocH.intWeightUnitMeasureId
				, dblAllocatedQty = SUM(allocD.dblSAllocatedQty)
			FROM tblLGAllocationDetail allocD
			LEFT JOIN tblLGAllocationHeader allocH
				ON allocH.intAllocationHeaderId = allocD.intAllocationHeaderId
			WHERE @ysnEnableAllocatedContractsGainOrLoss = 1
			AND dbo.fnRemoveTimeOnDate(allocD.dtmAllocatedDate) <= @dtmEndDate
			GROUP BY allocD.intSContractDetailId, allocH.intWeightUnitMeasureId
		) t

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
			, strMarketZoneCode
			, strOriginPort 
			, intOriginPortId 
			, strDestinationPort 
			, intDestinationPortId 
			, strCropYear 
			, intCropYearId 
			, strStorageLocation 
			, intStorageLocationId 
			, strStorageUnit 
			, intStorageUnitId 
			, intProductTypeId 
			, intGradeId 
			, intRegionId 
			, intSeasonId 	
			, intClassVarietyId 
			, intProductLineId 
			, strProductType 
			, strCertification 
			, strGrade 
			, strRegion 
			, strSeason 
			, strClass 
			, strProductLine 
			, strBook
			, intBookId
			, strSubBook
			, intSubBookId
			, intMTMPointId
			, strMTMPoint
		)
		SELECT DISTINCT intCommodityUnitMeasureId = CH.intCommodityUOMId
			, strLocationName = CASE WHEN @ysnEvaluationByLocation = 0
									THEN NULL
									ELSE CL.strLocationName
									END
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
			, dblFutures = CASE WHEN CH.intPricingTypeId = 2 AND CD.intPricingTypeId = 1 THEN CD.dblFutures ELSE CB.dblFutures END
			, CD.intContractStatusId
			, CD.dblCashPrice
			, CD.intContractDetailId
			, CD.intFutureMarketId
			, CD.intFutureMonthId
			, CD.intItemId
			, dblBalance = ISNULL(CB.dblBalance, CD.dblBalance)
			, CD.intCurrencyId
			, CD.dblRate
			, intMarketZoneId = CASE WHEN @ysnEvaluationByMarketZone = 0
									THEN NULL
									ELSE CD.intMarketZoneId
									END
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
			, intCompanyLocationId = CASE WHEN @ysnEvaluationByLocation = 0
									THEN NULL
									ELSE CD.intCompanyLocationId
									END
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
			, strMarketZoneCode = CASE WHEN @ysnEvaluationByMarketZone = 0
									THEN NULL
									ELSE MZ.strMarketZoneCode
									END
			, strOriginPort = CASE WHEN @ysnEvaluationByOriginPort = 0
								THEN NULL
								ELSE CASE WHEN ISNULL(loadShipmentWarehouse.intLoadId, 0) <> 0
									THEN loadShipmentWarehouse.strOriginPort
									ELSE originPort.strCity
									END
								END
			, intOriginPortId = CASE WHEN @ysnEvaluationByOriginPort = 0
								THEN NULL
								ELSE CASE WHEN ISNULL(loadShipmentWarehouse.intLoadId, 0) <> 0
									THEN loadShipmentWarehouse.intOriginPortId
									ELSE originPort.intCityId
									END
								END
			, strDestinationPort = CASE WHEN @ysnEvaluationByDestinationPort = 0
									THEN NULL
									ELSE CASE WHEN ISNULL(loadShipmentWarehouse.intLoadId, 0) <> 0
										THEN loadShipmentWarehouse.strDestinationPort
										ELSE destinationPort.strCity
										END
									END
			, intDestinationPortId =  CASE WHEN @ysnEvaluationByDestinationPort = 0
										THEN NULL
										ELSE CASE WHEN ISNULL(loadShipmentWarehouse.intLoadId, 0) <> 0
											THEN loadShipmentWarehouse.intDestinationPortId
											ELSE destinationPort.intCityId
											END
										END
			, strCropYear = CASE WHEN @ysnEvaluationByCropYear = 0 THEN NULL ELSE cropYear.strCropYear END
			, intCropYearId = CASE WHEN @ysnEvaluationByCropYear = 0 THEN NULL ELSE cropYear.intCropYearId END
			, strStorageLocation = CASE WHEN @ysnEvaluationByStorageLocation = 0
										THEN NULL
										ELSE CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.strStorageLocation
											WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.strStorageLocation
											ELSE 
												CASE WHEN ISNULL(loadShipmentWarehouse.intLoadId, 0) <> 0 AND loadShipmentWarehouse.intTransUsedBy = 1
												THEN loadShipmentWarehouse.strStorageLocation
												ELSE storageLocation.strSubLocationName
												END
											END 
										END
			, intStorageLocationId = CASE WHEN @ysnEvaluationByStorageLocation = 0
										THEN NULL
										ELSE CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.intStorageLocationId
											WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.intStorageLocationId
											ELSE 
												CASE WHEN ISNULL(loadShipmentWarehouse.intLoadId, 0) <> 0 AND loadShipmentWarehouse.intTransUsedBy = 1
												THEN loadShipmentWarehouse.intStorageLocationId
												ELSE storageLocation.intCompanyLocationSubLocationId
												END
											END
										END
			, strStorageUnit =  CASE WHEN @ysnEvaluationByStorageUnit = 0
									THEN NULL
									ELSE CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.strStorageUnit
										WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.strStorageUnit
										ELSE 
											CASE WHEN ISNULL(loadShipmentWarehouse.intLoadId, 0) <> 0 AND loadShipmentWarehouse.intTransUsedBy = 1
												THEN loadShipmentWarehouse.strStorageUnit
												ELSE storageUnit.strName
												END
										END
									END
			, intStorageUnitId = CASE WHEN @ysnEvaluationByStorageUnit = 0
									THEN NULL
									ELSE CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.intStorageUnitId
										WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.intStorageUnitId
										ELSE
											CASE WHEN ISNULL(loadShipmentWarehouse.intLoadId, 0) <> 0 AND loadShipmentWarehouse.intTransUsedBy = 1
											THEN loadShipmentWarehouse.intStorageUnitId
											ELSE storageUnit.intStorageLocationId
											END
										END
									END
			, IM.intProductTypeId
			, IM.intGradeId
			, IM.intRegionId
			, IM.intSeasonId	
			, IM.intClassVarietyId		
			, IM.intProductLineId			
			, strProductType = PTC.strDescription
			--, strCertification = CERTI.strCertificationName
			, strCertification = CASE WHEN @ysnIncludeProductInformation = 0
									THEN NULL
									ELSE CC.strContractCertifications
									END
			, strGrade = GRADE.strDescription
			, strRegion = REGION.strDescription
			, strSeason = SEASON.strDescription
			, strClass = CLASS.strDescription
			, strProductLine = PL.strDescription
			, strBook = book.strBook
			, intBookId = book.intBookId
			, strSubBook = subBook.strSubBook
			, intSubBookId = subBook.intSubBookId
			, intMTMPointId = CASE WHEN @ysnEnableMTMPoint = 0
									THEN NULL
									ELSE CD.intMTMPointId
									END 
			, strMTMPoint  = CASE WHEN @ysnEnableMTMPoint = 0
									THEN NULL
									ELSE mtm.strMTMPoint
									END 
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
		LEFT JOIN tblCTBook book
			ON book.intBookId = CH.intBookId
		LEFT JOIN tblCTSubBook subBook
			ON subBook.intSubBookId = CH.intSubBookId 
		LEFT JOIN tblSMCity originPort
			ON originPort.intCityId = CD.intLoadingPortId
		LEFT JOIN tblSMCity destinationPort
			ON destinationPort.intCityId = CD.intDestinationPortId
		LEFT JOIN tblCTCropYear cropYear
			ON cropYear.intCropYearId = CH.intCropYearId
		LEFT JOIN tblSMCompanyLocationSubLocation storageLocation
			ON storageLocation.intCompanyLocationSubLocationId = CD.intSubLocationId
		LEFT JOIN tblICStorageLocation storageUnit
			ON storageUnit.intStorageLocationId = CD.intStorageLocationId
		LEFT JOIN tblICCommodityProductLine PL ON PL.intCommodityProductLineId = IM.intProductLineId
		LEFT JOIN tblICCommodityAttribute PTC ON PTC.intCommodityAttributeId = IM.intProductTypeId
		LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.intCommodityAttributeId = IM.intGradeId
		LEFT JOIN tblICCommodityAttribute REGION ON REGION.intCommodityAttributeId = IM.intRegionId
		LEFT JOIN tblICCommodityAttribute SEASON ON SEASON.intCommodityAttributeId = IM.intSeasonId
		LEFT JOIN tblICCommodityAttribute CLASS ON CLASS.intCommodityAttributeId = IM.intClassVarietyId
		LEFT JOIN tblICCommodityAttribute C ON GRADE.intCommodityAttributeId = IM.intGradeId
		--LEFT JOIN tblICCertification CERTI ON CERTI.intCertificationId = IM.intCertificationId
		OUTER APPLY (
				SELECT strShipmentStatus = ISNULL(NULLIF(ctShipStatus.strShipmentStatus, ''), 'Open')  
				FROM  dbo.fnCTGetShipmentStatus(CD.intContractDetailId) ctShipStatus 
			) ctShipmentStatus
		OUTER APPLY (
			SELECT TOP 1 
				  LD.intLoadId
				, intStorageLocationId = loadStorageLoc.intCompanyLocationSubLocationId
				, strStorageLocation = loadStorageLoc.strSubLocationName
				, intStorageUnitId = loadStorageUnit.intStorageLocationId
				, strStorageUnit = loadStorageUnit.strName
				, intOriginPortId = LGLoadOrigin.intCityId
				, strOriginPort = LGLoadOrigin.strCity
				, intDestinationPortId = LGLoadDestination.intCityId
				, strDestinationPort = LGLoadDestination.strCity
				, LGLoad.intTransUsedBy
			FROM tblLGLoadDetail LD
			LEFT JOIN tblLGLoad LGLoad
				ON LGLoad.intLoadId = LD.intLoadId 
			LEFT JOIN tblLGLoadWarehouse warehouse
				ON warehouse.intLoadId = LD.intLoadId
			LEFT JOIN tblSMCompanyLocationSubLocation loadStorageLoc
				ON loadStorageLoc.intCompanyLocationSubLocationId = warehouse.intSubLocationId
			LEFT JOIN tblICStorageLocation loadStorageUnit
				ON loadStorageUnit.intStorageLocationId = warehouse.intStorageLocationId
			LEFT JOIN tblSMCity LGLoadOrigin
				ON LGLoadOrigin.strCity = LGLoad.strOriginPort
			LEFT JOIN tblSMCity LGLoadDestination
				ON LGLoadDestination.strCity = LGLoad.strDestinationPort
			WHERE	LGLoad.intTransportationMode = 2 -- TRANSPORT MODE = OCEAN VESSEL (2)
			AND		LGLoad.intShipmentType = 1 -- SHIPMENT ONLY
			AND		ISNULL(LD.intSContractDetailId, LD.intPContractDetailId) = CD.intContractDetailId 
			AND		(LGLoad.dtmDispatchedDate IS NOT NULL OR LGLoad.dtmPostedDate IS NOT NULL) -- LOAD SHIPMENT AFLOAT
			AND		LEFT(CONVERT(VARCHAR, ISNULL(LGLoad.dtmDispatchedDate, LGLoad.dtmPostedDate), 101), 10) <= @dtmEndDate
		) loadShipmentWarehouse
		OUTER APPLY (
			SELECT TOP 1 
				  receiptItem.intInventoryReceiptId
				, intStorageLocationId = receiptStorageLoc.intCompanyLocationSubLocationId
				, strStorageLocation = receiptStorageLoc.strSubLocationName
				, intStorageUnitId = receiptStorageUnit.intStorageLocationId
				, strStorageUnit = receiptStorageUnit.strName
			FROM tblICInventoryReceiptItem receiptItem
			LEFT JOIN tblICInventoryReceipt receipt
				ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
			LEFT JOIN tblICInventoryReceipt invReceipt
				ON invReceipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
			LEFT JOIN tblSMCompanyLocationSubLocation receiptStorageLoc
				ON receiptStorageLoc.intCompanyLocationSubLocationId = receiptItem.intSubLocationId
			LEFT JOIN tblICStorageLocation receiptStorageUnit
				ON receiptStorageUnit.intStorageLocationId = receiptItem.intStorageLocationId
			WHERE CH.intContractTypeId = 1 -- PURCHASE CONTRACTS ONLY
			AND receiptItem.intContractDetailId = CD.intContractDetailId
			AND invReceipt.dtmReceiptDate IS NOT NULL
			AND LEFT(CONVERT(VARCHAR, invReceipt.dtmReceiptDate, 101), 10) <= @dtmEndDate
			AND receipt.ysnPosted = 1
		) receiptWarehouse
		OUTER APPLY (
			SELECT TOP 1
				  invShipment.intInventoryShipmentId
				, intStorageLocationId = invShipStorageLoc.intCompanyLocationSubLocationId
				, strStorageLocation = invShipStorageLoc.strSubLocationName
				, intStorageUnitId = invShipStorageUnit.intStorageLocationId
				, strStorageUnit = invShipStorageUnit.strName
			FROM tblICInventoryShipmentItem invShipment
			LEFT JOIN tblICInventoryShipment shipment
				ON shipment.intInventoryShipmentId = invShipment.intInventoryShipmentId
			LEFT JOIN tblICInventoryShipment invShip
				ON invShip.intInventoryShipmentId = invShipment.intInventoryShipmentId
			LEFT JOIN tblSMCompanyLocationSubLocation invShipStorageLoc
				ON invShipStorageLoc.intCompanyLocationSubLocationId = invShipment.intSubLocationId
			LEFT JOIN tblICStorageLocation invShipStorageUnit
				ON invShipStorageUnit.intStorageLocationId = invShipment.intStorageLocationId
			WHERE CH.intContractTypeId = 2 -- SALE CONTRACTS ONLY
			AND invShipment.intLineNo = CD.intContractDetailId
			AND invShip.dtmShipDate IS NOT NULL
			AND LEFT(CONVERT(VARCHAR, invShip.dtmShipDate, 101), 10) <= @dtmEndDate
			AND shipment.ysnPosted = 1
		) invShipWarehouse
		LEFT JOIN tblCTMTMPoint mtm on mtm.intMTMPointId = CD.intMTMPointId
		OUTER APPLY (
			SELECT strContractCertifications = (LTRIM(STUFF((
				SELECT ', ' + ICC.strCertificationName
				FROM tblCTContractCertification CTC
				JOIN tblICCertification ICC
					ON ICC.intCertificationId = CTC.intCertificationId
				WHERE CTC.intContractDetailId = CD.intContractDetailId
				ORDER BY ICC.strCertificationName
				FOR XML PATH('')), 1, 1, ''))
			) COLLATE Latin1_General_CI_AS
		) CC
		WHERE CH.intCommodityId = @intCommodityId
			AND CL.intCompanyLocationId = ISNULL(@intLocationId, CL.intCompanyLocationId)
			AND ISNULL(CD.intMarketZoneId, 0) = ISNULL(@intMarketZoneId, ISNULL(CD.intMarketZoneId, 0))
			AND CONVERT(DATETIME,CONVERT(VARCHAR, CB.dtmContractDate, 101),101) <= @dtmEndDate

		SELECT intContractDetailId
			, dblCosts = SUM(dblCosts)
		INTO #tblContractCost
		FROM ( 
			SELECT dblCosts = dbo.fnRKGetCurrencyConvertion(CASE WHEN ISNULL(CU.ysnSubCurrency, 0) = 1 THEN CU.intMainCurrencyId ELSE dc.intCurrencyId END, @intCurrencyId, @intMarkToMarketRateTypeId)
								* (CASE WHEN (M2M.strContractType = 'Both') 
											OR (M2M.strContractType = 'Purchase' AND cd.strContractType = 'Purchase') 
											OR (M2M.strContractType = 'Sale' AND cd.strContractType = 'Sale')
												THEN ABS(CASE WHEN dc.strCostMethod = 'Amount' 
														THEN (SUM(dc.dblRate) 
															/ CASE WHEN ISNULL(ch.ysnLoad, 0) = 1 
																THEN (ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu2.intCommodityUnitMeasureId, cu3.intCommodityUnitMeasureId, ISNULL(cd2.dblQuantityPerLoad, 1)), 1) 
																		* CAST(ISNULL(cd2.intNoOfLoad, 1) AS NUMERIC(16, 8)))
																ELSE ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu2.intCommodityUnitMeasureId, cu3.intCommodityUnitMeasureId, ISNULL(cd.dblDetailQuantity, 1)), 1)
																END)
														ELSE SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cu1.intCommodityUnitMeasureId, ISNULL(dc.dblRate, 0)))
														END) * CASE WHEN strAdjustmentType = 'Add' THEN 1  
																	WHEN strAdjustmentType = 'Reduce' THEN -1
																	ELSE 0
																	END
												ELSE 0 END)
				, strAdjustmentType
				, dc.intContractDetailId
				, a = cu.intCommodityUnitMeasureId
				, b = cu1.intCommodityUnitMeasureId
				, strCostMethod
			FROM @GetContractDetailView cd
			INNER JOIN vyuRKM2MContractCost dc ON dc.intContractDetailId = cd.intContractDetailId
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
			INNER JOIN tblCTContractDetail cd2 ON cd2.intContractHeaderId = ch.intContractHeaderId
			INNER JOIN tblRKM2MConfiguration M2M 
				ON dc.intItemId = M2M.intItemId 
				AND ch.intFreightTermId = M2M.intFreightTermId
				AND (	 @ysnEnableMTMPoint = 0 
						 OR
						(@ysnEnableMTMPoint = 1 AND ISNULL(M2M.intMTMPointId , 0) = ISNULL(cd2.intMTMPointId, 0))
					)
			INNER JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = @intCommodityId AND cu.intUnitMeasureId = @intPriceUOMId
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = dc.intCurrencyId
			LEFT JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = @intCommodityId AND cu1.intUnitMeasureId = dc.intUnitMeasureId
			LEFT JOIN tblICItemUOM CIU ON CIU.intItemUOMId = cd2.intItemUOMId
			LEFT JOIN tblICCommodityUnitMeasure cu2 ON cu2.intCommodityId = @intCommodityId AND cu2.intUnitMeasureId = CIU.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure cu3 ON cu3.intCommodityId = @intCommodityId AND cu3.intUnitMeasureId = @intQuantityUOMId
			WHERE NOT (cd.intPricingTypeId = 2 AND cd.strPricingType = 'Priced')
			GROUP BY cu.intCommodityUnitMeasureId
				, cu1.intCommodityUnitMeasureId
				, cu2.intCommodityUnitMeasureId
				, cu3.intCommodityUnitMeasureId
				, strAdjustmentType
				, dc.intContractDetailId
				, dc.strCostMethod
				, CU.ysnSubCurrency
				, CU.intMainCurrencyId
				, dc.intCurrencyId
				, M2M.strContractType
				, cd.strContractType
				, cd.dblDetailQuantity
				, ch.ysnLoad
				, cd2.intNoOfLoad
				, cd2.dblQuantityPerLoad
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
																				AND CONVERT(DATETIME, '01 ' + strFutureMonth) > @dtmCurrentDate
																			ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth) ASC) END
			WHERE p.intFutureMarketId = fm.intFutureMarketId
				AND CONVERT(NVARCHAR, dtmPriceDate, 111) = CONVERT(NVARCHAR, @dtmSettlemntPriceDate, 111)
			ORDER BY dtmPriceDate DESC
		END

		SELECT DISTINCT intContractDetailId
			, dblFuturePrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, cuc.intCommodityUnitMeasureId, dblLastSettle / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
			, dblFutures = dbo.fnCTConvertQuantityToTargetCommodityUOM(cu.intCommodityUnitMeasureId, PUOM.intCommodityUnitMeasureId, cd.dblFutures / CASE WHEN c1.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
			, intFuturePriceCurrencyId = CASE WHEN CFM.ysnSubCurrency = 1 THEN CFM.intMainCurrencyId ELSE fm.intCurrencyId END
			, intFMMainCurrencyId = CFM.intMainCurrencyId
			, ysnFMSubCurrency = CFM.ysnSubCurrency
		INTO #tblSettlementPrice
		FROM @GetContractDetailView cd
		JOIN tblRKFuturesMonth ffm ON ffm.intFutureMonthId = cd.intFutureMonthId AND ffm.intFutureMarketId = cd.intFutureMarketId
		JOIN tblRKFutureMarket fm ON cd.intFutureMarketId = fm.intFutureMarketId
		JOIN tblSMCurrency c ON cd.intMarketCurrencyId = c.intCurrencyID AND cd.intCommodityId = @intCommodityId
		JOIN tblSMCurrency c1 ON cd.intCurrencyId = c1.intCurrencyID
		JOIN tblSMCurrency CFM ON CFM.intCurrencyID = fm.intCurrencyId
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
			, ysnSpreadExpired BIT
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
			, intProductTypeId INT
			, intGradeId INT
			, intRegionId INT
			, intSeasonId INT	
			, intClassVarietyId INT	
			, intProductLineId INT	
			, strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strCertification NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
			, strGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strRegion NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strSeason NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strClass NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, dblDetailQuantity NUMERIC(24, 10)
			, strBook NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intBookId INT
			, strSubBook NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, intSubBookId INT
			, intFMMainCurrencyId INT
			, ysnFMSubCurrency BIT
			, intMTMPointId INT	
			, strMTMPoint NVARCHAR(100) COLLATE Latin1_General_CI_AS
		)

		SELECT dblRatio
			, dblMarketBasis = (ISNULL(dblBasisOrDiscount, 0) + ISNULL(dblCashOrFuture, 0)) / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END
			, intMarketBasisUOM = intCommodityUnitMeasureId
			, intMarketBasisCurrencyId = CASE WHEN c.ysnSubCurrency = 1 THEN c.intMainCurrencyId ELSE temp.intCurrencyId END
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
			, temp.intMarketZoneId
			, temp.intOriginPortId
			, temp.intDestinationPortId
			, temp.intCropYearId
			, temp.intStorageLocationId
			, temp.intStorageUnitId
			, temp.intMTMPointId
			, temp.strCertification
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
			, ysnSpreadExpired
			, strOriginPort
			, intOriginPortId
			, strDestinationPort
			, intDestinationPortId
			, strCropYear
			, intCropYearId 
			, strStorageLocation 
			, intStorageLocationId 
			, strStorageUnit 
			, intStorageUnitId 
			, intProductTypeId 
			, intGradeId 
			, intRegionId 
			, intSeasonId 	
			, intClassVarietyId
			, intProductLineId 	
			, strProductType 
			, strCertification 
			, strGrade 
			, strRegion 
			, strSeason 
			, strClass 
			, strProductLine 
			, dblDetailQuantity
			, strBook
			, intBookId
			, strSubBook
			, intSubBookId
			, intFMMainCurrencyId
			, ysnFMSubCurrency
			, intMTMPointId
			, strMTMPoint
		)
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
			, dblContractBasis 
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
			, strOriginPort
			, intOriginPortId
			, strDestinationPort
			, intDestinationPortId
			, strCropYear
			, intCropYearId 
			, strStorageLocation 
			, intStorageLocationId 
			, strStorageUnit 
			, intStorageUnitId 
			, intProductTypeId 
			, intGradeId 
			, intRegionId 
			, intSeasonId 
			, intClassVarietyId 
			, intProductLineId 
			, strProductType 
			, strCertification 
			, strGrade 
			, strRegion 
			, strSeason 
			, strClass 
			, strProductLine 
			, dblDetailQuantity
			, strBook
			, intBookId
			, strSubBook
			, intSubBookId
			, intFMMainCurrencyId
			, ysnFMSubCurrency
			, intMTMPointId
			, strMTMPoint
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
				, dblContractBasis = ISNULL(CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 THEN
													CASE WHEN strPricingType = 'HTA' AND  strPricingStatus IN ('Unpriced', 'Partially Priced') THEN 0
													--HTA (Partially Priced) Priced Record
													WHEN cd.intPricingTypeId = 3 AND strPricingType = 'Priced' AND strPricingStatus = 'Partially Priced' THEN ISNULL(priceFixationDetailForHTA.dblBasis, 0)
													-- Fully Priced but when backdated, not yet fully priced 
													WHEN cd.intPricingTypeId = 1 AND strPricingType = 'Priced' AND strPricingStatus = 'Partially Priced' AND priceFixationDetailForHTA.dblBasis IS NOT NULL THEN ISNULL(priceFixationDetailForHTA.dblBasis, 0)
													ELSE 
														CASE WHEN cd.intPricingTypeId IN (1, 2) 
															THEN ISNULL(cd.dblBasis, 0) 
															ELSE ISNULL(cd.dblBasis, 0) END 
													END
												ELSE 0 END, 0) 
												/ CASE WHEN ysnSubCurrency = 1 THEN 100 ELSE 1 END
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
				, cd.strOriginPort
				, cd.intOriginPortId
				, cd.strDestinationPort
				, cd.intDestinationPortId
				, cd.strCropYear
				, cd.intCropYearId 
				, cd.strStorageLocation 
				, cd.intStorageLocationId 
				, cd.strStorageUnit 
				, cd.intStorageUnitId 
				, cd.intProductTypeId 
				, cd.intGradeId
				, cd.intRegionId 
				, cd.intSeasonId 
				, cd.intClassVarietyId 
				, cd.intProductLineId 	
				, cd.strProductType
				, cd.strCertification 
				, cd.strGrade
				, cd.strRegion
				, cd.strSeason
				, cd.strClass
				, cd.strProductLine
				, cd.dblDetailQuantity
				, cd.strBook
				, cd.intBookId
				, cd.strSubBook
				, cd.intSubBookId
				, p.intFMMainCurrencyId
				, p.ysnFMSubCurrency
				, cd.intMTMPointId
				, cd.strMTMPoint
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
				SELECT TOP 1 dblRatio, dblMarketBasis, intMarketBasisUOM, intMarketBasisCurrencyId 
				FROM #tmpM2MBasisDetail tmp
				WHERE ISNULL(tmp.intFutureMarketId,0) = ISNULL(cd.intFutureMarketId, ISNULL(tmp.intFutureMarketId,0))
					AND ISNULL(tmp.intItemId,0) = CASE WHEN @strEvaluationBy = 'Item' 
														THEN ISNULL(cd.intItemId, 0)
														ELSE ISNULL(tmp.intItemId, 0)
														END
					AND ISNULL(tmp.intContractTypeId, 0) = CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1
																					THEN ISNULL(cd.intContractTypeId, 0)
																					ELSE ISNULL(tmp.intContractTypeId, 0) END
					AND ISNULL(tmp.intCompanyLocationId, 0) = CASE WHEN @ysnEvaluationByLocation = 1 
																					THEN ISNULL(cd.intCompanyLocationId, 0)
																					ELSE ISNULL(tmp.intCompanyLocationId, 0) END
					AND ISNULL(tmp.intMarketZoneId, 0) = CASE WHEN @ysnEvaluationByMarketZone = 1 
																					THEN ISNULL(cd.intMarketZoneId, 0)
																					ELSE ISNULL(tmp.intMarketZoneId, 0) END
					AND ISNULL(tmp.intOriginPortId, 0) = CASE WHEN @ysnEvaluationByOriginPort = 1 
																					THEN ISNULL(cd.intOriginPortId, 0)
																					ELSE ISNULL(tmp.intOriginPortId, 0) END
					AND ISNULL(tmp.intDestinationPortId, 0) = CASE WHEN @ysnEvaluationByDestinationPort = 1 
																					THEN ISNULL(cd.intDestinationPortId, 0)
																					ELSE ISNULL(tmp.intDestinationPortId, 0) END
					AND ISNULL(tmp.intCropYearId, 0) = CASE WHEN @ysnEvaluationByCropYear = 1 
																					THEN ISNULL(cd.intCropYearId, 0)
																					ELSE ISNULL(tmp.intCropYearId, 0) END
					AND ISNULL(tmp.intStorageLocationId, 0) = CASE WHEN @ysnEvaluationByStorageLocation = 1 
																					THEN ISNULL(cd.intStorageLocationId, 0)
																					ELSE ISNULL(tmp.intStorageLocationId, 0) END
					AND ISNULL(tmp.intStorageUnitId, 0) = CASE WHEN @ysnEvaluationByStorageUnit = 1 
																					THEN ISNULL(cd.intStorageUnitId, 0)
																					ELSE ISNULL(tmp.intStorageUnitId, 0) END
					AND ISNULL(tmp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
														THEN dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy')
														ELSE ISNULL(tmp.strPeriodTo, '')
														END
					AND ISNULL(tmp.intMTMPointId, 0) = CASE WHEN @ysnEnableMTMPoint = 1 
																					THEN ISNULL(cd.intMTMPointId, 0)
																					ELSE ISNULL(tmp.intMTMPointId, 0) END
					AND ISNULL(tmp.strCertification, '') = CASE WHEN @ysnIncludeProductInformation = 1 
																					THEN ISNULL(cd.strCertification, '')
																					ELSE ISNULL(tmp.strCertification, '') END
					AND tmp.strContractInventory = 'Contract' ) basisDetail
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
					WHERE (cd.ysnMultiplePriceFixation = 1 AND intContractHeaderId = cd.intContractHeaderId 
							OR intContractDetailId = cd.intContractDetailId
						   )
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
			OUTER APPLY (
				-- Weighted Average Futures Price for Basis (Priced Qty) in Multiple Price Fixations
				SELECT dblBasis = SUM(dblBasis) 
				FROM
				(
					SELECT dblBasis = (pfd.dblBasis) * (pfd.dblQuantity / pricedTotal.dblTotalPricedQuantity)
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
					WHERE (cd.ysnMultiplePriceFixation = 1 AND intContractHeaderId = cd.intContractHeaderId OR intContractDetailId = cd.intContractDetailId)
						AND (   
							-- Basis (Partially Priced) Priced Record
							(cd.intPricingTypeId = 3 AND strPricingType = 'Priced' AND strPricingStatus = 'Partially Priced')
							-- Backdated and not yet fully priced in that specific date
							OR ((cd.intPricingTypeId = 1 AND strPricingType = 'Priced' AND strPricingStatus = 'Partially Priced') 
									AND EXISTS (SELECT TOP 1 '' FROM @ContractBalance cb
											WHERE cb.intContractDetailId = cd.intContractDetailId
											AND cb.strPricingType = 'HTA'
											)
								)
							)
							
				) t
			) priceFixationDetailForHTA
			WHERE cd.intCommodityId = @intCommodityId 
		)t

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
			, ysnExpired
			, strOriginPort
			, intOriginPortId
			, strDestinationPort
			, intDestinationPortId
			, strCropYear
			, intCropYearId 
			, strStorageLocation 
			, intStorageLocationId 
			, strStorageUnit 
			, intStorageUnitId 
			, intProductTypeId 
			, intGradeId 
			, intRegionId 
			, intSeasonId 
			, intClassVarietyId 
			, intProductLineId 	
			, strProductType 
			, strCertification
			, strGrade 
			, strRegion 
			, strSeason 
			, strClass 
			, strProductLine 
			, strBook
			, intBookId
			, strSubBook
			, intSubBookId
			, intFMMainCurrencyId
			, ysnFMSubCurrency
			, strMTMPoint
			, intMTMPointId
		) 
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
			, strOriginPort
			, intOriginPortId
			, strDestinationPort
			, intDestinationPortId
			, strCropYear
			, intCropYearId 
			, strStorageLocation 
			, intStorageLocationId 
			, strStorageUnit 
			, intStorageUnitId
			, intProductTypeId 
			, intGradeId 
			, intRegionId
			, intSeasonId 
			, intClassVarietyId 
			, intProductLineId 
			, strProductType 
			, strCertification
			, strGrade 
			, strRegion 
			, strSeason 
			, strClass 
			, strProductLine 
			, strBook
			, intBookId
			, strSubBook
			, intSubBookId
			, intFMMainCurrencyId
			, ysnFMSubCurrency
			, strMTMPoint
			, intMTMPointId
		FROM (
			SELECT *	
				, dblResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblResultBasis = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblMarketFuturesResult = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblResultCash1 = (ISNULL(dblMarketBasis, 0)-ISNULL(dblCash, 0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0)))
				, dblContractPrice = ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)), 0) + (ISNULL(dblFutures, 0)*ISNULL(dblContractRatio, 1))
			FROM (
				SELECT *
					, dblMarketBasis = CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 
											THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(intMarketBasisUOM, 0) = 0 THEN intPriceUOMId ELSE intMarketBasisUOM END, ISNULL(dblMarketBasis1, 0)) 
											ELSE 0 
											END
					, dblAdjustedContractPrice = CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0) + (ISNULL(dblCash, 0))
													ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId, @intMarkToMarketRateTypeId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
																ELSE CASE WHEN (case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))*ISNULL(dblRate, 0) 
																		ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) END END)
						 + CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId, @intMarkToMarketRateTypeId) * dblFutures
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
						, cd.strOriginPort
						, cd.intOriginPortId
						, cd.strDestinationPort
						, cd.intDestinationPortId
						, cd.strCropYear
						, cd.intCropYearId 
						, cd.strStorageLocation 
						, cd.intStorageLocationId 
						, cd.strStorageUnit 
						, cd.intStorageUnitId 
						, cd.intProductTypeId 
						, cd.intGradeId 
						, cd.intRegionId 
						, cd.intSeasonId 	
						, cd.intClassVarietyId 
						, cd.intProductLineId 	
						, cd.strProductType
						, cd.strCertification
						, cd.strGrade
						, cd.strRegion
						, cd.strSeason
						, cd.strClass
						, cd.strProductLine
						, cd.strBook
						, cd.intBookId
						, cd.strSubBook
						, cd.intSubBookId
						, cd.intFMMainCurrencyId
						, cd.ysnFMSubCurrency
						, cd.intMTMPointId
						, cd.strMTMPoint
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
				, ysnExpired
				, strOriginPort
				, intOriginPortId
				, strDestinationPort
				, intDestinationPortId
				, strCropYear
				, intCropYearId 
				, strStorageLocation 
				, intStorageLocationId 
				, strStorageUnit 
				, intStorageUnitId 
				, intProductTypeId 
				, intGradeId 
				, intRegionId 
				, intSeasonId 
				, intClassVarietyId 	
				, intProductLineId 	
				, strProductType 
				, strCertification
				, strGrade 
				, strRegion 
				, strSeason 
				, strClass 
				, strProductLine 
				, strBook
				, intBookId
				, strSubBook
				, intSubBookId
				, intFMMainCurrencyId
				, ysnFMSubCurrency
			)
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
				, strOriginPort
				, intOriginPortId
				, strDestinationPort
				, intDestinationPortId
				, strCropYear
				, intCropYearId 
				, strStorageLocation 
				, intStorageLocationId 
				, strStorageUnit 
				, intStorageUnitId 
				, intProductTypeId 
				, intGradeId 
				, intRegionId 
				, intSeasonId 	
				, intClassVarietyId 
				, intProductLineId 	
				, strProductType 
				, strCertification
				, strGrade 
				, strRegion 
				, strSeason 
				, strClass 
				, strProductLine 
				, strBook
				, intBookId
				, strSubBook
				, intSubBookId
				, intFMMainCurrencyId
				, ysnFMSubCurrency
			FROM (
				SELECT *
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblResult
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblResultBasis
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblMarketFuturesResult
					, (ISNULL(dblMarketBasis, 0)-ISNULL(dblCash, 0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty1, 0))) dblResultCash1
					, ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)), 0) + (ISNULL(dblFutures, 0) * ISNULL(dblContractRatio, 1)) dblContractPrice
				FROM (
					SELECT *
						, dblMarketBasis = CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 
											THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(intMarketBasisUOM, 0) = 0 THEN intPriceUOMId ELSE intMarketBasisUOM END, ISNULL(dblMarketBasis1, 0)) 
											ELSE 0 
											END
						, CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0) + (ISNULL(dblCash, 0))
							ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0
																THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId, @intMarkToMarketRateTypeId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
															ELSE CASE WHEN (CASE WHEN ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId
																			THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) * dblRate
																	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) END END)
								 + convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId, @intMarkToMarketRateTypeId)* dblFutures
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
							, cd.strOriginPort
							, cd.intOriginPortId
							, cd.strDestinationPort
							, cd.intDestinationPortId
							, cd.strCropYear
							, cd.intCropYearId 
							, cd.strStorageLocation 
							, cd.intStorageLocationId 
							, cd.strStorageUnit 
							, cd.intStorageUnitId 
							, cd.intProductTypeId 
							, cd.intGradeId 
							, cd.intRegionId 
							, cd.intSeasonId 	
							, cd.intClassVarietyId 	
							, cd.intProductLineId 
							, cd.strProductType
							, cd.strCertification
							, cd.strGrade
							, cd.strRegion
							, cd.strSeason
							, cd.strClass
							, cd.strProductLine							
							, cd.strBook
							, cd.intBookId
							, cd.strSubBook
							, cd.intSubBookId
							, cd.intFMMainCurrencyId
							, cd.ysnFMSubCurrency
						FROM @tblOpenContractList cd
						JOIN vyuRKGetPurchaseInventory l ON cd.intContractDetailId = l.intContractDetailId
						JOIN tblICItem i ON cd.intItemId = i.intItemId AND i.strLotTracking <> 'No'						
						WHERE cd.intCommodityId = @intCommodityId
					)t
				)t1
			)t2
			WHERE strContractOrInventoryType = case when @ysnIncludeInventoryM2M = 1 THEN 'Inventory (P)' ELSE '' END
		END

		-- Partial Priced Contracts (Used in deduction of Allocated Qty.)
		SELECT 
			  cdBasis.intContractDetailId
			, dblPricedOpenQty = cdPriced.dblContractOriginalQty
			, dblBasisOpenQty = cdBasis.dblContractOriginalQty
			, dblCompletedQty = cdPriced.dblDetailQuantity - (cdPriced.dblContractOriginalQty + cdBasis.dblContractOriginalQty)
		INTO #tmpPartialPricedContracts
		FROM @tblOpenContractList cdPriced
		INNER JOIN @tblOpenContractList cdBasis
			ON cdBasis.intContractDetailId = cdPriced.intContractDetailId
			AND cdBasis.intPricingTypeId IN (2, 3, 8)
			AND cdBasis.strPricingType IN ('Basis', 'HTA', 'Ratio')
		WHERE cdPriced.intPricingTypeId IN (2, 3, 8) AND cdPriced.strPricingType = 'Priced'

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
			, ysnExpired
			, strOriginPort
			, intOriginPortId
			, strDestinationPort
			, intDestinationPortId
			, strCropYear
			, intCropYearId 
			, strStorageLocation 
			, intStorageLocationId 
			, strStorageUnit 
			, intStorageUnitId
			, intProductTypeId 
			, intGradeId 
			, intRegionId 
			, intSeasonId 	
			, intClassVarietyId 	
			, intProductLineId 
			, strProductType 
			, strCertification
			, strGrade 
			, strRegion 
			, strSeason 
			, strClass 
			, strProductLine 
			, strBook
			, intBookId
			, strSubBook
			, intSubBookId
			, intFMMainCurrencyId
			, ysnFMSubCurrency
			, intMTMPointId
			, strMTMPoint
		)
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
			, strOriginPort
			, intOriginPortId
			, strDestinationPort
			, intDestinationPortId
			, strCropYear
			, intCropYearId 
			, strStorageLocation 
			, intStorageLocationId 
			, strStorageUnit 
			, intStorageUnitId
			, intProductTypeId 
			, intGradeId 
			, intRegionId 
			, intSeasonId 	
			, intClassVarietyId 	
			, intProductLineId 
			, strProductType 
			, strCertification
			, strGrade 
			, strRegion 
			, strSeason 
			, strClass 
			, strProductLine 
			, strBook
			, intBookId
			, strSubBook
			, intSubBookId
			, intFMMainCurrencyId
			, ysnFMSubCurrency
			, intMTMPointId
			, strMTMPoint
		FROM (
			SELECT *
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblResult
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblResultBasis
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) as dblMarketFuturesResult
				, (ISNULL(dblMarketBasis, 0)-ISNULL(dblCash, 0))*dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN intCommodityUnitMeasureId ELSE intQuantityUOMId END, intCommodityUnitMeasureId, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, ISNULL(intPriceUOMId, intCommodityUnitMeasureId), ISNULL(dblOpenQty, 0))) dblResultCash1
				, 0 dblContractPrice
			FROM (
				SELECT *
					, dblMarketBasis = CASE WHEN @ysnIncludeBasisDifferentialsInResults = 1 
											THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId,CASE WHEN ISNULL(intMarketBasisUOM, 0) = 0 THEN intPriceUOMId ELSE intMarketBasisUOM END, ISNULL(dblMarketBasis1, 0)) 
											ELSE 0 
											END
					, CASE WHEN intPricingTypeId = 6 THEN ISNULL(dblCosts, 0) + (ISNULL(dblCash, 0))
							ELSE CONVERT(DECIMAL(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId, @intMarkToMarketRateTypeId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
															ELSE CASE WHEN (case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END) <> @intCurrencyId
																		THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))*ISNULL(dblRate, 0) 
																	ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) END END) 
								 + CONVERT(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId, @intMarkToMarketRateTypeId)* dblFutures
															else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId THEN dblFutures*ISNULL(dblRate, 0)
																	else dblFutures END END)
								 + ISNULL(dblCosts, 0) END AS dblAdjustedContractPrice
					, dblFuturePrice1 as dblFuturePrice
					, dblOpenQty = CONVERT(decimal(24, 6), CASE WHEN ISNULL(intCommodityUnitMeasureId, 0) = 0 
												THEN dblContractOriginalQty
												ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId
															, CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 
																	THEN intCommodityUnitMeasureId 
																	ELSE intQuantityUOMId END
															, dblContractOriginalQty) 
												END
											)
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
						, cd.strOriginPort
						, cd.intOriginPortId
						, cd.strDestinationPort
						, cd.intDestinationPortId
						, cd.strCropYear
						, cd.intCropYearId 
						, cd.strStorageLocation 
						, cd.intStorageLocationId 
						, cd.strStorageUnit 
						, cd.intStorageUnitId
						, cd.intProductTypeId 
						, cd.intGradeId 
						, cd.intRegionId 
						, cd.intSeasonId 	
						, cd.intClassVarietyId 	
						, cd.intProductLineId 
						, cd.strProductType
						, cd.strCertification
						, cd.strGrade
						, cd.strRegion
						, cd.strSeason
						, cd.strClass
						, cd.strProductLine
						, dblContractOriginalQty = 
							CASE WHEN ISNULL(allocatedContract.dblAllocatedQty, 0) = 0 THEN cd.dblContractOriginalQty
								ELSE
									-- COMPUTE OPEN QTY. (INCLUDE REDUCTION OF ALLOCATED QTY)
									-- IF NOT PARTIAL PRICED
									CASE WHEN ISNULL(partialPricedCT.intContractDetailId, 0) = 0 
										THEN CASE WHEN cd.dblDetailQuantity = cd.dblContractOriginalQty
											THEN cd.dblContractOriginalQty - ISNULL(allocatedContract.dblAllocatedQty, 0)
											-- COMPLETED QTY > ALLOCATED QTY = RETAIN OPEN QTY.
											ELSE CASE WHEN (cd.dblDetailQuantity - cd.dblContractOriginalQty) > ISNULL(allocatedContract.dblAllocatedQty, 0)
												THEN cd.dblContractOriginalQty
												ELSE cd.dblDetailQuantity - ISNULL(allocatedContract.dblAllocatedQty, 0)
												END
											END
									-- IF PARTIAL PRICED
											-- PRICED PART
										ELSE CASE WHEN cd.intPricingTypeId IN (2, 3, 8) AND cd.strPricingType = 'Priced'
											THEN CASE WHEN cd.dblDetailQuantity = (partialPricedCT.dblPricedOpenQty + partialPricedCT.dblBasisOpenQty)
													THEN CASE WHEN partialPricedCT.dblPricedOpenQty > ISNULL(allocatedContract.dblAllocatedQty, 0)
														THEN partialPricedCT.dblPricedOpenQty - ISNULL(allocatedContract.dblAllocatedQty, 0)
														ELSE 0
														END
													ELSE CASE WHEN (partialPricedCT.dblCompletedQty + partialPricedCT.dblPricedOpenQty) > ISNULL(allocatedContract.dblAllocatedQty, 0)
														THEN (partialPricedCT.dblCompletedQty + partialPricedCT.dblPricedOpenQty) - ISNULL(allocatedContract.dblAllocatedQty, 0)
														ELSE 0
														END													
													END
											-- UNPRICED PART
											WHEN cd.intPricingTypeId IN (2, 3, 8) AND cd.strPricingType IN ('Basis', 'HTA', 'Ratio')
											THEN CASE WHEN cd.dblDetailQuantity = (partialPricedCT.dblPricedOpenQty + partialPricedCT.dblBasisOpenQty)
													THEN CASE WHEN partialPricedCT.dblPricedOpenQty >= ISNULL(allocatedContract.dblAllocatedQty, 0)
														THEN cd.dblContractOriginalQty
														ELSE (partialPricedCT.dblPricedOpenQty + partialPricedCT.dblBasisOpenQty) - ISNULL(allocatedContract.dblAllocatedQty, 0)
														END
													ELSE CASE WHEN (partialPricedCT.dblCompletedQty + partialPricedCT.dblPricedOpenQty) >= ISNULL(allocatedContract.dblAllocatedQty, 0)
														THEN cd.dblContractOriginalQty
														ELSE (partialPricedCT.dblCompletedQty + partialPricedCT.dblPricedOpenQty + partialPricedCT.dblBasisOpenQty) - ISNULL(allocatedContract.dblAllocatedQty, 0)
														END
													END
											ELSE cd.dblContractOriginalQty
											END
										END
								END
						, strBook
						, intBookId
						, strSubBook
						, intSubBookId
						, cd.intFMMainCurrencyId
						, cd.ysnFMSubCurrency
						, cd.intMTMPointId
						, cd.strMTMPoint
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
					LEFT JOIN #tmpAllocatedContracts allocatedContract
						ON allocatedContract.intContractDetailId = cd.intContractDetailId
					LEFT JOIN #tmpPartialPricedContracts partialPricedCT
						ON partialPricedCT.intContractDetailId = cd.intContractDetailId
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
				, convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId, @intMarkToMarketRateTypeId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblDummyContractBasis, 0))
											else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																	then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblDummyContractBasis, 0)) * dblRate
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblDummyContractBasis, 0)) END END) as dblDummyContractBasis
				, case when @ysnCanadianCustomer = 1 THEN dblContractBasis
					else convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN  dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
													else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
															else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) END END) END as dblContractBasis
				, convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId, @intMarkToMarketRateTypeId)* dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))
											else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																	then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0))*dblRate 
													else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblContractBasis, 0)) END END) as dblCanadianContractBasis
				, case when @ysnCanadianCustomer = 1 THEN dblFutures
						else convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN  dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblFutures, 0))
					else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblFutures, 0))
							else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, ISNULL(dblFutures, 0)) END END) END as dblFutures
				, convert(decimal(24, 6), dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(PriceSourceUOMId, 0) = 0 THEN intPriceUOMId ELSE PriceSourceUOMId END, dblCash)) as dblCash
				, dblCosts as dblCosts
				, dblMarketRatio
				, dblMarketBasis = case when @ysnCanadianCustomer = 1 OR @strRateType = 'Configuration' THEN dblMarketBasis
					else convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN  dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(intMarketBasisUOMId, 0) = 0 THEN intPriceUOMId ELSE intMarketBasisUOMId END, ISNULL(dblMarketBasis, 0))
													else case when case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END <> @intCurrencyId
																then dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(intMarketBasisUOMId, 0) = 0 THEN intPriceUOMId ELSE intMarketBasisUOMId END, ISNULL(dblMarketBasis, 0))
															else dbo.fnCTConvertQuantityToTargetCommodityUOM(intPriceUOMId, CASE WHEN ISNULL(intMarketBasisUOMId, 0) = 0 THEN intPriceUOMId ELSE intMarketBasisUOMId END, ISNULL(dblMarketBasis, 0)) END END) END
				, intMarketBasisCurrencyId
				, dblFuturePrice = CASE WHEN strPricingType = 'Basis' 
										THEN 0 
										ELSE case when @ysnCanadianCustomer = 1 THEN ISNULL(dblFuturePrice1, 0)
												else convert(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN ISNULL(dblFuturePrice1, 0)
														else case when case when ysnFMSubCurrency = 1 THEN intFMMainCurrencyId ELSE intFuturePriceCurrencyId END <> @intCurrencyId
																	then ISNULL(dblFuturePrice1, 0)
																else ISNULL(dblFuturePrice1, 0) END END) END --dblFuturePrice1 
									END
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
				, CONVERT(decimal(24, 6), CASE WHEN ISNULL(dblRate, 0) = 0 THEN dbo.fnRKGetCurrencyConvertion(case when ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END, @intCurrencyId, @intMarkToMarketRateTypeId) * dblFutures
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
				, intCurrencyId = CASE WHEN ysnSubCurrency = 1 THEN intMainCurrencyId ELSE intCurrencyId END
				, intSpreadMonthId
				, strSpreadMonth
				, dblSpreadMonthPrice
				, dblSpread
				, ysnExpired
				, strOriginPort
				, intOriginPortId
				, strDestinationPort
				, intDestinationPortId
				, strCropYear
				, intCropYearId 
				, strStorageLocation 
				, intStorageLocationId 
				, strStorageUnit 
				, intStorageUnitId
				, intProductTypeId 
				, intGradeId 
				, intRegionId 
				, intSeasonId 	
				, intClassVarietyId 	
				, intProductLineId 
				, strProductType
				, strCertification
				, strGrade
				, strRegion
				, strSeason
				, strClass
				, strProductLine
				, strBook
				, intBookId
				, strSubBook
				, intSubBookId
				, strMTMPoint
				, intMTMPointId
				, dblRate
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
			WHERE ysnExpired = 0 AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmSpotDate, 110), 110) < = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmCurrentDate, 110), 110)
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
					, dblCosts
					, SUM(dblOpenQty) dblOpenQty
					, SUM(dblOpenQty) dblResult
					, dblCashOrFuture = dbo.fnCTConvertQuantityToTargetCommodityUOM(intToPriceUOM, intMarketBasisUOM, dblCashOrFuture)
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
						, PriceSourceUOMId = ISNULL(bdcu.intCommodityUnitMeasureId, 0)
						, dblInvMarketBasis = 0
						, dblCashOrFuture = ROUND(ISNULL(bd.dblCashOrFuture, 0), 4)
						, intMarketBasisUOM = ISNULL(bdcu.intCommodityUnitMeasureId, 0)
						, intCurrencyId = ISNULL(bd.intCurrencyId, 0)
						, (SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate < = @dtmCurrentDate AND intFutureMarketId = c.intFutureMarketId ORDER BY 1 DESC) strFutureMonth
						, (SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate < = @dtmCurrentDate AND intFutureMarketId = c.intFutureMarketId ORDER BY 1 DESC) intFutureMonthId
						, c.intFutureMarketId
						, dblNotLotTrackedPrice = dbo.fnCalculateQtyBetweenUOM(iuomTo.intItemUOMId, iuomStck.intItemUOMId, ISNULL(dbo.fnCalculateValuationAverageCost(i.intItemId, s.intItemLocationId, @dtmEndDate), 0))
						, cu2.intCommodityUnitMeasureId intToPriceUOM
						, dblCosts  = SUM(CASE WHEN s.strTransactionType = 'Inventory Receipt' THEN IRCost.dblTotalCost 
										WHEN s.strTransactionType = 'Inventory Shipment' THEN ISCost.dblTotalCost
										ELSE 0 END)
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
					OUTER APPLY (SELECT TOP 1 intUnitMeasureId
									, dblCashOrFuture = ISNULL(dblCashOrFuture, 0)
									, intCurrencyId = ISNULL(intCurrencyId, 0)
								FROM #tmpM2MBasisDetail temp
								WHERE ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE i.intItemId END
									AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(s.intLocationId, 0) END
									AND temp.strContractInventory = 'Inventory') bd
					LEFT JOIN tblICCommodityUnitMeasure bdcu ON bdcu.intCommodityId = c.intCommodityId AND bdcu.intUnitMeasureId = bd.intUnitMeasureId
					OUTER APPLY(
						SELECT
							 dblTotalCost = SUM(CASE WHEN CC.ysnAccrue = 1 THEN ISNULL(CC.dblAmount, 0) 
																			* (CASE WHEN M2M.strAdjustmentType = 'Add' THEN 1 ELSE -1 END) 
												WHEN CC.ysnAccrue = 0 AND CC.strCostMethod = 'Per Unit' THEN ISNULL(CC.dblRate, 0) * ISNULL(CC.dblForexRate , 1)
																						* CC.dblQuantity
																						* CASE WHEN M2M.strAdjustmentType = 'Add' THEN 1
																							WHEN M2M.strAdjustmentType = 'Reduce' THEN -1 END
																						/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END
												WHEN CC.ysnAccrue = 0 AND CC.strCostMethod <> 'Per Unit' THEN 0 
												ELSE 0 END)
						FROM tblICInventoryReceiptCharge CC
						JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = CC.intInventoryReceiptId
						JOIN tblICItem Item ON Item.intItemId = CC.intChargeId 
						LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CC.intCostUOMId
						LEFT JOIN tblSMCurrency	FCY ON FCY.intCurrencyID = CC.intCurrencyId
						LEFT JOIN tblRKM2MConfiguration M2M ON M2M.intItemId = CC.intChargeId AND M2M.intFreightTermId = IR.intFreightTermId
						WHERE Item.strCostType <> 'Commission'
						AND IR.intInventoryReceiptId = s.intTransactionId and s.strTransactionType = 'Inventory Receipt'
					
					) IRCost
					OUTER APPLY (
						SELECT
							 dblTotalCost = SUM(CASE WHEN CC.ysnAccrue = 1 THEN ISNULL(CC.dblAmount, 0) 
																			* (CASE WHEN M2M.strAdjustmentType = 'Add' THEN 1 ELSE -1 END) 
												WHEN CC.ysnAccrue = 0 AND CC.strCostMethod = 'Per Unit' THEN ISNULL(CC.dblRate, 0) * ISNULL(CC.dblForexRate , 1)
																						* CC.dblQuantity
																						* CASE WHEN M2M.strAdjustmentType = 'Add' THEN 1
																							WHEN M2M.strAdjustmentType = 'Reduce' THEN -1 END
																						/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END
												WHEN CC.ysnAccrue = 0 AND CC.strCostMethod <> 'Per Unit' THEN 0 
												ELSE 0 END)
						FROM tblICInventoryShipmentCharge CC
						JOIN tblICInventoryShipment InvS ON InvS.intInventoryShipmentId = CC.intInventoryShipmentId
						JOIN tblICItem Item ON Item.intItemId = CC.intChargeId 
						LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CC.intCostUOMId
						LEFT JOIN tblSMCurrency	FCY ON FCY.intCurrencyID = CC.intCurrencyId
						LEFT JOIN tblRKM2MConfiguration M2M ON M2M.intItemId = CC.intChargeId AND M2M.intFreightTermId = InvS.intFreightTermId
						WHERE Item.strCostType <> 'Commission'
						AND InvS.intInventoryShipmentId = s.intTransactionId and s.strTransactionType = 'Inventory Shipment'
					) ISCost
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
							, bdcu.intCommodityUnitMeasureId
					
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
					, intToPriceUOM
					, dblCosts
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
					, dblCashOrFuture = dbo.fnCTConvertQuantityToTargetCommodityUOM(intToPriceUOM, intMarketBasisUOM, dblCashOrFuture)
					, intCurrencyId
				FROM (
					SELECT strContractOrInventoryType = 'In-transit(I)'
						, strContractSeq
						, strLocationName
						, intLocationId
						, strCommodityCode
						, t.intCommodityId
						, strItemNo
						, intItemId
						, dblOpenQty = ABS(dblOpenQty)
						, PriceSourceUOMId = ISNULL(bdcu.intCommodityUnitMeasureId, 0)
						, dblInvMarketBasis = 0
						, dblCashOrFuture = ROUND(ISNULL(bd.dblCashOrFuture, 0), 4)
						, intMarketBasisUOM = ISNULL(bdcu.intCommodityUnitMeasureId, 0)
						, intCurrencyId = ISNULL(bd.intCurrencyId, 0)
						, strFutureMonth = (SELECT TOP 1 strFutureMonth strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate < = @dtmCurrentDate AND intFutureMarketId = intFutureMarketId ORDER BY 1 DESC)
						, intFutureMonthId = (SELECT TOP 1 intFutureMonthId strFutureMonth FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate < = @dtmCurrentDate AND intFutureMarketId = intFutureMarketId ORDER BY 1 DESC) 
						, intFutureMarketId
						, dblNotLotTrackedPrice = ISNULL(dbo.fnCalculateValuationAverageCost(intItemId, intItemLocationId, @dtmEndDate), 0)
						, cu2.intCommodityUnitMeasureId intToPriceUOM
					FROM @ListTransaction t
					OUTER APPLY (SELECT TOP 1 intUnitMeasureId
									, dblCashOrFuture = ISNULL(dblCashOrFuture, 0)
									, intCurrencyId = ISNULL(intCurrencyId, 0)
								FROM #tmpM2MBasisDetail temp
								WHERE ISNULL(temp.intItemId, 0) = CASE WHEN ISNULL(temp.intItemId, 0) = 0 THEN 0 ELSE t.intItemId END
									AND ISNULL(temp.intCompanyLocationId, 0) = CASE WHEN ISNULL(temp.intCompanyLocationId, 0) = 0 THEN 0 ELSE ISNULL(t.intLocationId, 0) END
									AND temp.strContractInventory = 'Inventory') bd
					LEFT JOIN tblICCommodityUnitMeasure bdcu ON bdcu.intCommodityId = t.intCommodityId AND bdcu.intUnitMeasureId = bd.intUnitMeasureId
					LEFT JOIN tblICCommodityUnitMeasure cu2 ON cu2.intCommodityId = t.intCommodityId AND cu2.intUnitMeasureId = @intPriceUOMId
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
				, DER.intCommodityId
				, strLocationName
				, intLocationId
				, strFutureMonth
				, DER.intFutureMonthId
				, strFutureMarket
				, DER.intFutureMarketId
				, dblPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(priceUOM.intCommodityUnitMeasureId, CUOM.intCommodityUnitMeasureId, ISNULL(dblPrice, 0) / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END )
								* 
								CASE WHEN ISNULL(c.ysnSubCurrency, 0) = 0 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> fm.intCurrencyId
									THEN ISNULL(dbo.fnRKGetCurrencyConvertion(fm.intCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
								WHEN ISNULL(c.ysnSubCurrency, 0) = 1 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> c.intMainCurrencyId
									THEN ISNULL(dbo.fnRKGetCurrencyConvertion(c.intMainCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
								ELSE 1
								END
				, dblOpenQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(CUOM.intCommodityUnitMeasureId, CUOM2.intCommodityUnitMeasureId, dblOpenContract * DER.dblContractSize)
				, dblInvFuturePrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(priceUOM.intCommodityUnitMeasureId, CUOM.intCommodityUnitMeasureId, SP.dblLastSettle / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END )
								* 
								CASE WHEN ISNULL(c.ysnSubCurrency, 0) = 0 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> fm.intCurrencyId
									THEN ISNULL(dbo.fnRKGetCurrencyConvertion(fm.intCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
								WHEN ISNULL(c.ysnSubCurrency, 0) = 1 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> c.intMainCurrencyId
									THEN ISNULL(dbo.fnRKGetCurrencyConvertion(c.intMainCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
								ELSE 1
								END
				, DER.intCurrencyId
			FROM fnRKGetOpenFutureByDate (@intCommodityId, '1/1/1900', @dtmEndDate, 1) DER
			LEFT JOIN @tblGetSettlementPrice SP ON SP.intFutureMarketId = DER.intFutureMarketId AND SP.intFutureMonthId = DER.intFutureMonthId
			LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = DER.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure CUOM
				ON CUOM.intCommodityId = DER.intCommodityId
				AND CUOM.intUnitMeasureId = fm.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure CUOM2
				ON CUOM2.intCommodityId = DER.intCommodityId
				AND CUOM2.intUnitMeasureId = @intQuantityUOMId
			LEFT JOIN tblSMCurrency c
				ON c.intCurrencyID = fm.intCurrencyId
			LEFT JOIN tblICCommodityUnitMeasure priceUOM 
				ON priceUOM.intCommodityId = @intCommodityId AND priceUOM.intUnitMeasureId = @intPriceUOMId
			WHERE DER.intCommodityId = @intCommodityId 
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
			AND dbo.fnDateLessThanEquals(dtmValidFromDate, @dtmCurrentDate) = 1
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
			, dblResultBasis = (dblMarketBasis - dblContractBasis) * dblOpenQty
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
			, dblResult = CASE WHEN strPricingType = 'Cash' 
							THEN ROUND(dblResultCash, 2) 
							ELSE ROUND((dblMarketPrice - dblAdjustedContractPrice) * dblOpenQty, 2)
							END
			, dblMarketFuturesResult = CASE WHEN strContractOrInventoryType = 'Inventory' THEN 0
											WHEN strPricingType = 'Basis' THEN 0
											ELSE ((ISNULL(dblFuturePrice, 0) - ISNULL(dblActualFutures, 0) 
												+ (CASE WHEN ysnExpired = 1 THEN ISNULL(dblSpread, 0) ELSE 0 END)) * dblOpenQty)
											END
			, dblResultRatio = (CASE WHEN dblContractRatio <> 0 AND dblMarketRatio <> 0 AND strContractOrInventoryType <> 'Inventory'
									THEN ((dblMarketPrice - dblAdjustedContractPrice) * dblOpenQty)
										- (CASE WHEN strPricingType = 'Basis' THEN 0
												ELSE ((ISNULL(dblFuturePrice, 0) - ISNULL(dblActualFutures, 0) 
													+ (CASE WHEN ysnExpired = 1 THEN ISNULL(dblSpread, 0) ELSE 0 END)) * dblOpenQty) END)
										- dblResultBasis
									ELSE 0 END)
			, intSpreadMonthId
			, strSpreadMonth
			, dblSpreadMonthPrice
			, dblSpread
			, t.strOriginPort
			, t.intOriginPortId
			, t.strDestinationPort
			, t.intDestinationPortId
			, t.strCropYear
			, t.intCropYearId 
			, t.strStorageLocation 
			, t.intStorageLocationId 
			, t.strStorageUnit 
			, t.intStorageUnitId
			, strProductType 
			, strCertification
			, strGrade 
			, strRegion 
			, strSeason 
			, strClass 
			, strProductLine 
			, strBook
			, intBookId
			, strSubBook
			, intSubBookId
			, strMTMPoint
			, intMTMPointId
			, t.dblRate
			, intTransactionCurrencyId = t.intCurrencyId
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
				, dblContractRatio = ISNULL(dblCalculatedContractRatio, 0)
				-- Contract Basis
				, dblContractBasis = dblCalculatedBasis
				-- Contract Futures
				, dblActualFutures = dblCalculatedFutures
				, dblFutures = CASE WHEN strPricingType = 'Basis' THEN ISNULL(dblFutures, 0)
									WHEN strPricingType = 'Priced' THEN dblCalculatedFutures
									ELSE dblCalculatedFutures END
				-- Contract Cash
				, dblCash
				-- Contract Costs
				, dblCosts = ABS(dblCosts) 
				-- Market Basis
				, dblMarketBasis = dblCalculatedMarketBasis
				, dblMarketRatio
				-- Market Futures 
				, dblFuturePrice = dblCalculatedMarketFutures
				, intContractTypeId
				, dblAdjustedContractPrice = dblCalculatedBasis + (dblCalculatedFutures * dblCalculatedContractRatio) + ISNULL(dblCash, 0) + ISNULL(dblCosts, 0)
				, dblCashPrice
				--Market Price
				, dblMarketPrice = dblCalculatedMarketBasis + (dblCalculatedMarketFutures * dblCalculatedMarketRatio) + ISNULL(dblCashPrice, 0)
				, dblResultBasis = dblResultBasis
				, dblResultCash
				--Contract Price
				, dblContractPrice = dblCalculatedBasis + (dblCalculatedFutures * dblCalculatedContractRatio) + ISNULL(dblCash, 0) 
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
				, t.strOriginPort
				, t.intOriginPortId
				, t.strDestinationPort
				, t.intDestinationPortId
				, t.strCropYear
				, t.intCropYearId 
				, t.strStorageLocation 
				, t.intStorageLocationId 
				, t.strStorageUnit 
				, t.intStorageUnitId
				, strProductType 
				, strCertification
				, strGrade 
				, strRegion 
				, strSeason 
				, strClass 
				, strProductLine 
				, t.strBook
				, t.intBookId
				, t.strSubBook
				, t.intSubBookId
				, t.strMTMPoint
				, t.intMTMPointId
				, dblRate = t.dblRateCT
				, t.intCurrencyId
			FROM (
				SELECT t.*
					, dblCalculatedBasis = CASE WHEN strPricingType != 'HTA' THEN ISNULL(dblContractBasis, 0) * dblRateCT ELSE 0 END
					, dblCalculatedFutures = ISNULL((CASE WHEN strPricingType = 'Ratio' AND strPriOrNotPriOrParPriced = 'Partially Priced'
														THEN ISNULL(((dblLotsFixed * dblPriceWORollArb) + ((dblNoOfLots - dblLotsFixed) * (ISNULL(dblFutures, 0) * dblRateCT))) 
																/ dblNoOfLots, 0)
														ELSE ISNULL(dblFutures, 0) * dblRateCT
														END), 0)
					, dblCalculatedContractRatio = CASE WHEN ISNULL(dblContractRatio, 0) = 0 THEN 1 ELSE dblContractRatio * dblRateCT END
					, dblCalculatedMarketBasis = CASE WHEN strPricingType != 'HTA' 
													THEN (	ISNULL(dblMarketBasis, 0) +
															CASE WHEN @ysnCanadianCustomer != 1 THEN ISNULL(dblInvMarketBasis, 0) ELSE 0 END
														  )
													ELSE 0 END * dblRateMB 
					, dblCalculatedMarketFutures = ISNULL(dblFuturePrice, 0) * dblRateFP
					, dblCalculatedMarketRatio = CASE WHEN ISNULL(dblMarketRatio, 0) = 0 THEN 1 ELSE dblMarketRatio END
				FROM (
					SELECT #Temp.*
						-- IF RATE TYPE IS CONTRACT = CHECK CONTRACT FOREX. IF NO VALUE, USE SYSTEM WIDE FOREX INSTEAD
						-- RATE FOR CONTRACT CURRENCY TO M2M CURRENCY
						, dblRateCT = CASE WHEN intCurrencyId = @intCurrencyId
									  THEN 1
									  ELSE
										  CASE WHEN @strRateType = 'Contract' 
										  THEN
											ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
													WHERE ISNULL(dtmFXValidFrom, @dtmCurrentDay) <= @dtmCurrentDay AND ISNULL(dtmFXValidTo, @dtmCurrentDay) >= @dtmCurrentDay
														AND ISNULL(dblRate, 0) <> 0
														AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId 
																						FROM tblSMCurrencyExchangeRate forex
																						WHERE forex.intFromCurrencyId = Currency.intCurrencyID 
																						AND forex.intToCurrencyId = @intCurrencyId)
														AND intContractDetailId = #Temp.intContractDetailId)
												, dbo.fnRKGetCurrencyConvertion(Currency.intCurrencyID, @intCurrencyId, @intMarkToMarketRateTypeId))
											ELSE dbo.fnRKGetCurrencyConvertion(Currency.intCurrencyID, @intCurrencyId, @intMarkToMarketRateTypeId) END
									  END
						-- RATE FOR MARKET BASIS (BASIS ENTRY) CURRENCY TO M2M CURRENCY 
						, dblRateMB = CASE WHEN MBCurrency.intCurrencyID = @intCurrencyId
									  THEN 1
									  ELSE
										  CASE WHEN @strRateType = 'Contract' 
										  THEN
											ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
													WHERE ISNULL(dtmFXValidFrom, @dtmCurrentDay) <= @dtmCurrentDay AND ISNULL(dtmFXValidTo, @dtmCurrentDay) >= @dtmCurrentDay
														AND ISNULL(dblRate, 0) <> 0
														AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId 
																						FROM tblSMCurrencyExchangeRate forex
																						WHERE forex.intFromCurrencyId = MBCurrency.intCurrencyID 
																						AND forex.intToCurrencyId = @intCurrencyId)
														AND intContractDetailId = #Temp.intContractDetailId)
												, dbo.fnRKGetCurrencyConvertion(MBCurrency.intCurrencyID, @intCurrencyId, @intMarkToMarketRateTypeId))
											ELSE dbo.fnRKGetCurrencyConvertion(MBCurrency.intCurrencyID, @intCurrencyId, @intMarkToMarketRateTypeId) END
									  END
						-- RATE FOR FUTURE PRICE (SETTLEMENT PRICE) CURRENCY TO M2M CURRENCY 
						, dblRateFP = CASE WHEN FPCurrency.intCurrencyID = @intCurrencyId
									  THEN 1
									  ELSE
										  CASE WHEN @strRateType = 'Contract' 
										  THEN
											ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
													WHERE ISNULL(dtmFXValidFrom, @dtmCurrentDay) <= @dtmCurrentDay AND ISNULL(dtmFXValidTo, @dtmCurrentDay) >= @dtmCurrentDay
														AND ISNULL(dblRate, 0) <> 0
														AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId 
																						FROM tblSMCurrencyExchangeRate forex
																						WHERE forex.intFromCurrencyId = FPCurrency.intCurrencyID 
																						AND forex.intToCurrencyId = @intCurrencyId)
														AND intContractDetailId = #Temp.intContractDetailId)
												, dbo.fnRKGetCurrencyConvertion(FPCurrency.intCurrencyID, @intCurrencyId, @intMarkToMarketRateTypeId))
											ELSE dbo.fnRKGetCurrencyConvertion(FPCurrency.intCurrencyID, @intCurrencyId, @intMarkToMarketRateTypeId) END
									  END
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
				, dblCosts = ISNULL(dblCosts, 0)
				, dblMarketBasis = ISNULL(dblInvMarketBasis, 0)
				, dblMarketRatio = ISNULL(dblMarketRatio, 0)
				, dblFuturePrice = ISNULL(dblInvFuturePrice, 0)
				, intContractTypeId
				, dblAdjustedContractPrice = CASE WHEN strContractOrInventoryType like 'Futures%' THEN dblFutures ELSE ISNULL(dblCash, 0) + ISNULL(dblCosts, 0) END
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
				, strOriginPort
				, intOriginPortId
				, strDestinationPort
				, intDestinationPortId
				, strCropYear
				, intCropYearId 
				, strStorageLocation 
				, intStorageLocationId 
				, strStorageUnit 
				, intStorageUnitId
				, strProductType 
				, strCertification
				, strGrade 
				, strRegion 
				, strSeason 
				, strClass 
				, strProductLine 
				, strBook
				, intBookId
				, strSubBook
				, intSubBookId
				, strMTMPoint
				, intMTMPointId
				, dblRate
				, intCurrencyId
			FROM #Temp 
			WHERE dblOpenQty <> 0 AND intContractHeaderId IS NULL
		)t 
		ORDER BY intContractHeaderId DESC

		DELETE FROM tblRKM2MTransaction WHERE intM2MHeaderId = @intM2MHeaderId
		
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
			, dblSpread
			, strOriginPort
			, intOriginPortId
			, strDestinationPort
			, intDestinationPortId
			, strCropYear
			, intCropYearId 
			, strStorageLocation 
			, intStorageLocationId 
			, strStorageUnit 
			, intStorageUnitId
			, strProductType 
			, strCertification
			, strGrade 
			, strRegion 
			, strSeason 
			, strClass 
			, strProductLine 
			, strBook
			, intBookId
			, strSubBook
			, intSubBookId
			, strMTMPoint
			, intMTMPointId
			, dblRate
			, intTransactionCurrencyId
		)
		SELECT * FROM #tmpM2MTransaction

		-- Differential Basis
		DECLARE @strItemIds NVARCHAR(MAX)
			, @strPeriodTos NVARCHAR(MAX)
			, @strLocationIds NVARCHAR(MAX)
			, @strZoneIds NVARCHAR(MAX)
			, @strOriginPortIds NVARCHAR(MAX)
			, @strDestinationPortIds NVARCHAR(MAX)
			, @strCropYearIds NVARCHAR(MAX)
			, @strStorageLocationIds NVARCHAR(MAX)
			, @strStorageUnitIds NVARCHAR(MAX)
	
		--Get the unique items from transactions
		SELECT @strItemIds = COALESCE(@strItemIds + ', ', '') + ISNULL(intItemId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intItemId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intItemId) END AS intItemId FROM #tmpM2MTransaction
		) tbl
	
		SELECT @strPeriodTos = COALESCE(@strPeriodTos + ', ', '') + CONVERT(NVARCHAR(50), strPeriodTo)
		FROM (
			SELECT DISTINCT strPeriodTo FROM #tmpM2MTransaction
			WHERE strPeriodTo IS NOT NULL
		) tbl
	
		-- LOCATION
		SELECT @strLocationIds = COALESCE(@strLocationIds + ', ', '') + ISNULL(intCompanyLocationId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intLocationId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intLocationId) END AS intCompanyLocationId FROM #tmpM2MTransaction
		) tbl
		
		-- MARKET ZONE
		SELECT @strZoneIds = COALESCE(@strZoneIds + ', ', '') + ISNULL(intMarketZoneId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intMarketZoneId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intMarketZoneId) END AS intMarketZoneId FROM #tmpM2MTransaction
		) tbl
		
		-- ORIGIN PORT
		SELECT @strOriginPortIds = COALESCE(@strOriginPortIds + ', ', '') + ISNULL(intOriginPortId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intOriginPortId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intOriginPortId) END AS intOriginPortId FROM #tmpM2MTransaction
		) tbl

		-- DESTINATION PORT
		SELECT @strDestinationPortIds = COALESCE(@strDestinationPortIds + ', ', '') + ISNULL(intDestinationPortId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intDestinationPortId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intDestinationPortId) END AS intDestinationPortId FROM #tmpM2MTransaction
		) tbl

		-- CROP YEAR
		SELECT @strCropYearIds = COALESCE(@strCropYearIds + ', ', '') + ISNULL(intCropYearId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intCropYearId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intCropYearId) END AS intCropYearId FROM #tmpM2MTransaction
		) tbl

		-- STORAGE LOCATION
		SELECT @strStorageLocationIds = COALESCE(@strStorageLocationIds + ', ', '') + ISNULL(intStorageLocationId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intStorageLocationId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intStorageLocationId) END AS intStorageLocationId FROM #tmpM2MTransaction
		) tbl
		
		-- STORAGE UNIT
		SELECT @strStorageUnitIds = COALESCE(@strStorageUnitIds + ', ', '') + ISNULL(intStorageUnitId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intStorageUnitId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intStorageUnitId) END AS intStorageUnitId FROM #tmpM2MTransaction
		) tbl

		IF @strEvaluationBy = 'Commodity'
		BEGIN
			SET @strItemIds = ''
		END
	
		IF ISNULL(@ysnEvaluationByMarketZone, 0) = 0
		BEGIN
			SET @strZoneIds = ''
		END

		IF ISNULL(@ysnEvaluationByLocation, 0) = 0 
		BEGIN
			SET @strLocationIds = ''
		END
		
		IF ISNULL(@ysnEvaluationByOriginPort, 0) = 0 
		BEGIN
			SET @strOriginPortIds = ''
		END
		
		IF ISNULL(@ysnEvaluationByDestinationPort, 0) = 0 
		BEGIN
			SET @strDestinationPortIds = ''
		END
		
		IF ISNULL(@ysnEvaluationByCropYear, 0) = 0 
		BEGIN
			SET @strCropYearIds = ''
		END

		IF ISNULL(@ysnEvaluationByStorageLocation, 0) = 0 
		BEGIN
			SET @strStorageLocationIds = ''
		END

		IF ISNULL(@ysnEvaluationByStorageUnit, 0) = 0 
		BEGIN
			SET @strStorageUnitIds = ''
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
			, bd.intOriginPortId
			, bd.intDestinationPortId
			, bd.intCropYearId 
			, bd.intStorageLocationId 
			, bd.intStorageUnitId
			, bd.intMTMPointId
			, bd.strCertification
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
		WHERE (b.intM2MBasisId = @intM2MBasisId
			AND c.intCommodityId = ISNULL(@intCommodityId, c.intCommodityId)
			AND b.strPricingType = @strM2MType
			AND ISNULL(bd.intItemId, 0) IN (SELECT CASE WHEN @strItemIds = '' THEN ISNULL(bd.intItemId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strItemIds, ', ')) --added this be able to filter by item (RM-739)
			AND ISNULL(bd.strPeriodTo, '') IN (SELECT CASE WHEN @strPeriodTos = '' THEN ISNULL(bd.strPeriodTo, '') ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END FROM [dbo].[fnSplitString](@strPeriodTos, ', ')) --added this be able to filter by period to (RM-739)
			AND ISNULL(bd.intCompanyLocationId, 0) IN (SELECT CASE WHEN @strLocationIds = '' THEN ISNULL(bd.intCompanyLocationId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strLocationIds, ', ')) --added this be able to filter by item (RM-739)
			AND ISNULL(bd.intMarketZoneId, 0) IN (SELECT CASE WHEN @strZoneIds = '' THEN ISNULL(bd.intMarketZoneId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strZoneIds, ', ')) --added this be able to filter by item (RM-739)
			AND ISNULL(bd.intOriginPortId, 0) IN (SELECT CASE WHEN @strOriginPortIds = '' THEN ISNULL(bd.intOriginPortId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strOriginPortIds, ', ')) 
			AND ISNULL(bd.intDestinationPortId, 0) IN (SELECT CASE WHEN @strDestinationPortIds = '' THEN ISNULL(bd.intDestinationPortId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strDestinationPortIds, ', ')) 
			AND ISNULL(bd.intCropYearId, 0) IN (SELECT CASE WHEN @strCropYearIds = '' THEN ISNULL(bd.intCropYearId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strCropYearIds, ', ')) 
			AND ISNULL(bd.intStorageLocationId, 0) IN (SELECT CASE WHEN @strStorageLocationIds = '' THEN ISNULL(bd.intStorageLocationId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strStorageLocationIds, ', ')) 
			AND ISNULL(bd.intStorageUnitId, 0) IN (SELECT CASE WHEN @strStorageUnitIds = '' THEN ISNULL(bd.intStorageUnitId, 0) ELSE CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END END AS Item FROM [dbo].[fnSplitString](@strStorageUnitIds, ', ')) 
			) OR (bd.strContractInventory = 'Inventory' and b.intM2MBasisId = @intM2MBasisId
				AND c.intCommodityId = ISNULL(@intCommodityId, c.intCommodityId)
				AND b.strPricingType = @strM2MType)
		ORDER BY i.strMarketValuation
			, fm.strFutMarketName
			, strCommodityCode
			, strItemNo
			, strLocationName
			, CONVERT(DATETIME, '01 ' + strPeriodTo)

		DELETE FROM tblRKM2MDifferentialBasis WHERE intM2MHeaderId = @intM2MHeaderId

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
			, intUnitMeasureId
			, intLocationId
			, intOriginPortId
			, intDestinationPortId
			, intCropYearId 
			, intStorageLocationId 
			, intStorageUnitId
			, intMTMPointId
			, strCertification
		)
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
			, intCompanyLocationId
			, intOriginPortId
			, intDestinationPortId
			, intCropYearId 
			, intStorageLocationId 
			, intStorageUnitId
			, intMTMPointId
			, strCertification
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
				JOIN tblRKFuturesMonth fm ON f.intFutureMarketId = fm.intFutureMarketId --AND fm.ysnExpired = 0
				JOIN tblRKCommodityMarketMapping mm ON fm.intFutureMarketId = mm.intFutureMarketId
				WHERE mm.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN mm.intCommodityId ELSE @intCommodityId END
			) t
			WHERE dblClosingPrice > 0
			ORDER BY strFutMarketName
				, CONVERT(DATETIME, '01 ' + strFutureMonth)
		END
		ELSE
		BEGIN		
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
																					AND CONVERT(DATETIME, '01 ' + strFutureMonth) > @dtmCurrentDate
																				ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth) ASC) END
					WHERE p.intFutureMarketId = fm.intFutureMarketId
						AND CONVERT(NVARCHAR, dtmPriceDate, 111) = CONVERT(NVARCHAR, @dtmSettlemntPriceDate, 111)
						AND ISNULL(p.strPricingType, @strM2MType) = @strM2MType
				) t ON t.intFutureMarketId = fm.intFutureMarketId AND t.intFutureMonthId = fm.intFutureMonthId
				WHERE mm.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN mm.intCommodityId ELSE @intCommodityId END
					AND ISNULL(fm.intFutureMonthId, 0) IN (SELECT DISTINCT intFutureMonthId
														FROM #tmpM2MTransaction
														WHERE ISNULL(intFutureMonthId, 0) <> 0)
			) t WHERE dblClosingPrice > 0
			ORDER BY strFutMarketName
				, CONVERT(DATETIME, '01 ' + strFutureMonth)
		END

		DELETE FROM tblRKM2MSettlementPrice WHERE intM2MHeaderId = @intM2MHeaderId

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

		DELETE FROM tblRKM2MSummary WHERE intM2MHeaderId = @intM2MHeaderId

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

		DECLARE @tmpCustomerExposureDetail TABLE(intM2MHeaderId INT
			, intContractHeaderId INT
			, strContractSeq NVARCHAR(100)
			, strEntityName NVARCHAR(100)
			, strCountry NVARCHAR(100)
			, intEntityId INT
			, dblM2M NUMERIC(24, 10)
			, dblFixedSalesVolume NUMERIC(24, 10)
			, dblUnfixedSalesVolume NUMERIC(24, 10)
			, dblTotalCommittedVolume NUMERIC(24, 10)
			, dblSalesOpenQty NUMERIC(24, 10)
			, dblSalesContractBasisPrice NUMERIC(24, 10)
			, dblSalesFuturesPrice NUMERIC(24, 10)
			, dblSalesCashPrice NUMERIC(24, 10)
			, dblFixedSalesValue NUMERIC(24, 10)
			, dblUnSalesOpenQty NUMERIC(24, 10)
			, dblUnSalesContractBasisPrice NUMERIC(24, 10)
			, dblUnSalesFuturesPrice NUMERIC(24, 10)
			, dblUnSalesCashPrice NUMERIC(24, 10)
			, dblUnfixedSalesValue NUMERIC(24, 10)
			, dblTotalCommittedValue NUMERIC(24, 10)
			, dblCreditLimit NUMERIC(24, 10)
			, dblOpenInvoicedValue NUMERIC(24, 10)
			, dblVariance NUMERIC(24, 10))

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
					, strPriOrNotPriOrParPriced = (CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN CASE WHEN strPricingType = 'Priced' THEN 'Priced' ELSE 'Unpriced' END
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


			INSERT INTO @tmpCustomerExposureDetail (intM2MHeaderId
				, intContractHeaderId
				, strContractSeq
				, strEntityName
				, strCountry
				, intEntityId
				, dblM2M
				, dblFixedSalesVolume
				, dblUnfixedSalesVolume
				, dblTotalCommittedVolume
				, dblSalesOpenQty
				, dblSalesContractBasisPrice
				, dblSalesFuturesPrice
				, dblSalesCashPrice
				, dblFixedSalesValue
				, dblUnSalesOpenQty
				, dblUnSalesContractBasisPrice
				, dblUnSalesFuturesPrice
				, dblUnSalesCashPrice
				, dblUnfixedSalesValue
				, dblTotalCommittedValue
				, dblCreditLimit
				, dblOpenInvoicedValue
				, dblVariance)
			SELECT intM2MHeaderId = @intM2MHeaderId
				, intContractHeaderId
				, strContractSeq
				, strEntityName
				, strCountry
				, intEntityId
				, dblM2M
				, dblFixedSalesVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END)
				, dblUnfixedSalesVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
				, dblTotalValume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
				, dblSalesOpenQty = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPValueQty ELSE 0 END)
				, dblSalesContractBasisPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPContractBasis ELSE 0 END)
				, dblSalesFuturesPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPFutures ELSE 0 END)
				, dblSalesCashPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPContractBasis ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPFutures ELSE 0 END)
				, dblFixedSalesValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END)
				, dblUnSalesOpenQty = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPValueQty ELSE 0 END)
				, dblUnSalesContractBasisPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPContractBasis ELSE 0 END)
				, dblUnSalesFuturesPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPFutures ELSE 0 END)
				, dblUnSalesCashPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPContractBasis ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPFutures ELSE 0 END)
				, dblUnfixedSalesValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
				, dblTotalCommittedValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
				, dblCreditLimit
				, dblOpenInvoicedValue
				, dblVariance = isnull(dblCreditLimit,0) - isnull(dblOpenInvoicedValue,0)
			FROM (
				SELECT fd.intContractHeaderId
					, fd.strContractSeq
					, fd.strEntityName
					, Loc.strCountry
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
					, dblCreditLimit
					, dblOpenInvoicedValue = e.dblARBalance--(select sum(dblAmountDue) from vyuARInvoiceSearch where intEntityCustomerId = fd.intEntityId)
				FROM #tmpCPE fd
				JOIN tblARCustomer e ON e.intEntityId = fd.intEntityId
				LEFT JOIN tblEMEntityLocation AS Loc ON e.intEntityId = Loc.intEntityId AND Loc.ysnDefaultLocation = 1
				WHERE strContractOrInventoryType IN ('Contract(S)', 'In-transit(S)', 'Inventory (S)')
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
					, strPriOrNotPriOrParPriced = (CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN CASE WHEN strPricingType = 'Priced' THEN 'Priced' ELSE 'Unpriced' END
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

		DELETE FROM tblRKM2MCounterPartyExposure WHERE intM2MHeaderId = @intM2MHeaderId

		INSERT INTO tblRKM2MCounterPartyExposure(intM2MHeaderId
			, intContractHeaderId
			, strContractSeq
			, strEntityName
			, intVendorId
			, dblMToM
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
			, dblTotalCommittedValue)
		SELECT intM2MHeaderId
			, intContractHeaderId
			, strContractSeq
			, strEntityName
			, intEntityId
			, dblM2M
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

		DELETE FROM tblRKM2MCustomerExposure WHERE intM2MHeaderId = @intM2MHeaderId

		INSERT INTO tblRKM2MCustomerExposure(intM2MHeaderId
			, intContractHeaderId
			, strContractSeq
			, strEntityName
			, strCountry
			, intCustomerId
			, dblMToM
			, dblFixedSalesVolume
			, dblUnfixedSalesVolume
			, dblSalesOpenQty
			, dblSalesContractBasisPrice
			, dblSalesFuturesPrice
			, dblSalesCashPrice
			, dblFixedSalesValue
			, dblUnSalesOpenQty
			, dblUnSalesContractBasisPrice
			, dblUnSalesFuturesPrice
			, dblUnSalesCashPrice
			, dblUnfixedSalesValue
			, dblTotalCommittedVolume
			, dblTotalCommittedValue
			, dblCreditLimit
			, dblOpenInvoicedValue
			, dblVariance)
		SELECT intM2MHeaderId
			, intContractHeaderId
			, strContractSeq
			, strEntityName
			, strCountry
			, intEntityId
			, dblM2M
			, dblFixedSalesVolume
			, dblUnfixedSalesVolume
			, dblSalesOpenQty
			, dblSalesContractBasisPrice
			, dblSalesFuturesPrice
			, dblSalesCashPrice
			, dblFixedSalesValue
			, dblUnSalesOpenQty
			, dblUnSalesContractBasisPrice
			, dblUnSalesFuturesPrice
			, dblUnSalesCashPrice
			, dblUnfixedSalesValue
			, dblTotalCommittedVolume
			, dblTotalCommittedValue
			, dblCreditLimit
			, dblOpenInvoicedValue
			, dblVariance
		FROM @tmpCustomerExposureDetail


		-- Post Preview
		IF EXISTS(SELECT TOP 1 1 FROM tblRKM2MPostPreview WHERE intM2MHeaderId = @intM2MHeaderId)
		BEGIN
			DELETE FROM tblRKM2MPostPreview WHERE intM2MHeaderId = @intM2MHeaderId
		END
		
		IF @strRateType != 'Stress Test'
		BEGIN
			DECLARE @GLAccounts TABLE(strCategory NVARCHAR(100)
				, intAccountId INT
				, strAccountNo NVARCHAR(20) COLLATE Latin1_General_CI_AS
				, ysnHasError BIT
				, strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS)

			DECLARE @intUnrealizedGainOnBasisId INT
				, @intUnrealizedGainOnFuturesId INT
				, @intUnrealizedGainOnCashId INT
				, @intUnrealizedLossOnBasisId INT
				, @intUnrealizedLossOnFuturesId INT
				, @intUnrealizedLossOnCashId INT
				, @intUnrealizedGainOnInventoryBasisIOSId INT
				, @intUnrealizedGainOnInventoryFuturesIOSId INT
				, @intUnrealizedGainOnInventoryCashIOSId INT
				, @intUnrealizedLossOnInventoryBasisIOSId INT
				, @intUnrealizedLossOnInventoryFuturesIOSId INT
				, @intUnrealizedLossOnInventoryCashIOSId INT
				, @intUnrealizedGainOnInventoryIntransitIOSId INT
				, @intUnrealizedLossOnInventoryIntransitIOSId INT
				, @intUnrealizedGainOnRatioId INT
				, @intUnrealizedLossOnRatioId INT
				, @intUnrealizedGainOnInventoryRatioIOSId INT
				, @intUnrealizedLossOnInventoryRatioIOSId INT
				, @intUnrealizedGainOnInventoryIOSId INT
				, @intUnrealizedLossOnInventoryIOSId INT
				, @strUnrealizedGainOnBasisId NVARCHAR(250)
				, @strUnrealizedGainOnFuturesId NVARCHAR(250)
				, @strUnrealizedGainOnCashId NVARCHAR(250)
				, @strUnrealizedLossOnBasisId NVARCHAR(250)
				, @strUnrealizedLossOnFuturesId NVARCHAR(250)
				, @strUnrealizedLossOnCashId NVARCHAR(250)
				, @strUnrealizedGainOnInventoryBasisIOSId NVARCHAR(250)
				, @strUnrealizedGainOnInventoryFuturesIOSId NVARCHAR(250)
				, @strUnrealizedGainOnInventoryCashIOSId NVARCHAR(250)
				, @strUnrealizedLossOnInventoryBasisIOSId NVARCHAR(250)
				, @strUnrealizedLossOnInventoryFuturesIOSId NVARCHAR(250)
				, @strUnrealizedLossOnInventoryCashIOSId NVARCHAR(250)
				, @strUnrealizedGainOnInventoryIntransitIOSId NVARCHAR(250)
				, @strUnrealizedLossOnInventoryIntransitIOSId NVARCHAR(250)
				, @strUnrealizedGainOnRatioId NVARCHAR(250)
				, @strUnrealizedLossOnRatioId NVARCHAR(250)
				, @strUnrealizedGainOnInventoryRatioIOSId NVARCHAR(250)
				, @strUnrealizedLossOnInventoryRatioIOSId NVARCHAR(250)
				, @strUnrealizedGainOnInventoryIOSId NVARCHAR(250)
				, @strUnrealizedLossOnInventoryIOSId NVARCHAR(250)

			INSERT INTO @GLAccounts
			EXEC uspRKGetGLAccountsForPosting @intCommodityId = @intCommodityId
				, @intLocationId = @intLocationId

			SELECT @intUnrealizedGainOnBasisId = intAccountId
				, @strUnrealizedGainOnBasisId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedGainOnBasisId'

			SELECT @intUnrealizedGainOnFuturesId = intAccountId
				, @strUnrealizedGainOnFuturesId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedGainOnFuturesId'

			SELECT @intUnrealizedGainOnCashId = intAccountId
				, @strUnrealizedGainOnCashId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedGainOnCashId'

			SELECT @intUnrealizedLossOnBasisId = intAccountId
				, @strUnrealizedLossOnBasisId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedLossOnBasisId'

			SELECT @intUnrealizedLossOnFuturesId = intAccountId
				, @strUnrealizedLossOnFuturesId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedLossOnFuturesId'

			SELECT @intUnrealizedLossOnCashId = intAccountId
				, @strUnrealizedLossOnCashId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedLossOnCashId'

			SELECT @intUnrealizedGainOnInventoryBasisIOSId = intAccountId
				, @strUnrealizedGainOnInventoryBasisIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedGainOnInventoryBasisIOSId'

			SELECT @intUnrealizedGainOnInventoryFuturesIOSId = intAccountId
				, @strUnrealizedGainOnInventoryFuturesIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedGainOnInventoryFuturesIOSId'

			SELECT @intUnrealizedGainOnInventoryCashIOSId = intAccountId
				, @strUnrealizedGainOnInventoryCashIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedGainOnInventoryCashIOSId'

			SELECT @intUnrealizedLossOnInventoryBasisIOSId = intAccountId
				, @strUnrealizedLossOnInventoryBasisIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedLossOnInventoryBasisIOSId'

			SELECT @intUnrealizedLossOnInventoryFuturesIOSId = intAccountId
				, @strUnrealizedLossOnInventoryFuturesIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedLossOnInventoryFuturesIOSId'

			SELECT @intUnrealizedLossOnInventoryCashIOSId = intAccountId
				, @strUnrealizedLossOnInventoryCashIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedLossOnInventoryCashIOSId'

			SELECT @intUnrealizedGainOnInventoryIntransitIOSId = intAccountId
				, @strUnrealizedGainOnInventoryIntransitIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedGainOnInventoryIntransitIOSId'

			SELECT @intUnrealizedLossOnInventoryIntransitIOSId = intAccountId
				, @strUnrealizedLossOnInventoryIntransitIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedLossOnInventoryIntransitIOSId'

			SELECT @intUnrealizedGainOnRatioId = intAccountId
				, @strUnrealizedGainOnRatioId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedGainOnRatioId'

			SELECT @intUnrealizedLossOnRatioId = intAccountId
				, @strUnrealizedLossOnRatioId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedLossOnRatioId'

			SELECT @intUnrealizedGainOnInventoryRatioIOSId = intAccountId
				, @strUnrealizedGainOnInventoryRatioIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedGainOnInventoryRatioIOSId'

			SELECT @intUnrealizedLossOnInventoryRatioIOSId = intAccountId
				, @strUnrealizedLossOnInventoryRatioIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedLossOnInventoryRatioIOSId'

			SELECT @intUnrealizedGainOnInventoryIOSId = intAccountId
				, @strUnrealizedGainOnInventoryIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedGainOnInventoryIOSId'

			SELECT @intUnrealizedLossOnInventoryIOSId = intAccountId
				, @strUnrealizedLossOnInventoryIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
			FROM @GLAccounts
			WHERE strCategory = 'intUnrealizedLossOnInventoryIOSId'

			----Derivative unrealized start

			DECLARE @Result AS TABLE (intFutOptTransactionId INT
				, dblGrossPnL NUMERIC(24, 10)
				, dblLong NUMERIC(24, 10)
				, dblShort NUMERIC(24, 10)
				, dblFutCommission NUMERIC(24, 10)
				, strFutMarketName NVARCHAR(100)
				, strFutureMonth NVARCHAR(100)
				, dtmTradeDate DATETIME
				, strInternalTradeNo NVARCHAR(100)
				, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strBook NVARCHAR(100)
				, strSubBook NVARCHAR(100)
				, strSalespersonId NVARCHAR(100)
				, strCommodityCode NVARCHAR(100)
				, strLocationName NVARCHAR(100)
				, dblLong1 INT
				, dblSell1 INT
				, dblNet INT
				, dblActual NUMERIC(24, 10)
				, dblClosing NUMERIC(24, 10)
				, dblPrice NUMERIC(24, 10)
				, dblContractSize NUMERIC(24, 10)
				, dblFutCommission1 NUMERIC(24, 10)
				, dblMatchLong NUMERIC(24, 10)
				, dblMatchShort NUMERIC(24, 10)
				, dblNetPnL NUMERIC(24, 10)
				, intFutureMarketId INT
				, intFutureMonthId INT
				, intOriginalQty INT
				, intFutOptTransactionHeaderId INT
				, strMonthOrder NVARCHAR(100)
				, RowNum INT
				, intCommodityId INT
				, ysnExpired BIT
				, dblVariationMargin NUMERIC(24, 10)
				, dblInitialMargin NUMERIC(24, 10)
				, LongWaitedPrice NUMERIC(24, 10)
				, ShortWaitedPrice NUMERIC(24, 10)
				, intSelectedInstrumentTypeId INT)
	
			INSERT INTO @Result (RowNum
				, strMonthOrder
				, intFutOptTransactionId
				, dblGrossPnL
				, dblLong
				, dblShort
				, dblFutCommission
				, strFutMarketName
				, strFutureMonth
				, dtmTradeDate
				, strInternalTradeNo
				, strName
				, strAccountNumber
				, strBook
				, strSubBook
				, strSalespersonId
				, strCommodityCode
				, strLocationName
				, dblLong1
				, dblSell1
				, dblNet
				, dblActual
				, dblClosing
				, dblPrice
				, dblContractSize
				, dblFutCommission1
				, dblMatchLong
				, dblMatchShort
				, dblNetPnL
				, intFutureMarketId
				, intFutureMonthId
				, intOriginalQty
				, intFutOptTransactionHeaderId
				, intCommodityId
				, ysnExpired
				, dblVariationMargin
				, dblInitialMargin
				, LongWaitedPrice
				, ShortWaitedPrice
				, intSelectedInstrumentTypeId)
			EXEC uspRKUnrealizedPnL @dtmFromDate = '01-01-1900'
				, @dtmToDate = @dtmEndDate
				, @intCommodityId  = @intCommodityId
				, @ysnExpired =0
				, @intFutureMarketId  = NULL
				, @intEntityId  = NULL
				, @intBrokerageAccountId  = NULL
				, @intFutureMonthId  = NULL
				, @strBuySell  = NULL
				, @intBookId  = NULL
				, @intSubBookId  = NULL
				, @intSelectedInstrumentTypeId = 1
	
			--------- end
	
			--Basis entry
			INSERT INTO tblRKM2MPostPreview(intM2MHeaderId
				, dtmDate
				, intAccountId
				, strAccountId
				, dblDebit
				, dblCredit
				, dblDebitForeign
				, dblCreditForeign
				, dblDebitUnit
				, dblCreditUnit
				, strDescription
				, intCurrencyId
				, dtmTransactionDate
				, strTransactionId
				, intTransactionId
				, strTransactionType
				, strTransactionForm
				, strModuleName
				, intConcurrencyId
				, dblExchangeRate
				, dtmDateEntered
				, ysnIsUnposted
				, intEntityId
				, strReference
				, intUserId
				, intSourceLocationId
				, intSourceUOMId)

			SELECT intM2MHeaderId
				, dtmDate
				, intAccountId
				, strAccountId
				, dblDebit 
				, dblCredit
				, dblDebitForeign = ISNULL(dblDebit, 0) / ISNULL(dblExchangeRate, 1)
				, dblCreditForeign = ISNULL(dblCredit, 0) / ISNULL(dblExchangeRate, 1)
				, dblDebitUnit
				, dblCreditUnit
				, strDescription
				, intCurrencyId
				, dtmTransactionDate
				, strTransactionId
				, intTransactionId
				, strTransactionType
				, strTransactionForm
				, strModuleName
				, intConcurrencyId
				, dblExchangeRate
				, dtmDateEntered
				, ysnIsUnposted
				, intEntityId
				, strReference
				, intUserId
				, intSourceLocationId
				, intSourceUOMId
			FROM (
				SELECT intM2MHeaderId = @intM2MHeaderId 
					, dtmDate = @dtmPostDate
					, intAccountId = CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @intUnrealizedGainOnBasisId ELSE @intUnrealizedLossOnBasisId END 
					, strAccountId = CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @strUnrealizedGainOnBasisId ELSE @strUnrealizedLossOnBasisId END
					, dblDebit = CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END
					, dblCredit = CASE WHEN ISNULL(dblResultBasis, 0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END 
					, dblDebitUnit = CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END
					, dblCreditUnit = CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END 
					, strDescription = 'Mark To Market-Basis'
					, intCurrencyId = @intCurrencyId
					, dtmTransactionDate = @dtmPostDate
					, strTransactionId = strContractSeq
					, intTransactionId = intContractDetailId
					, strTransactionType = 'Mark To Market-Basis'
					, strTransactionForm = 'Mark To Market'
					, strModuleName = 'Risk Management'
					, intConcurrencyId = 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, dtmDateEntered = @dtmCurrentDate
					, ysnIsUnposted = 0
					, intEntityId
					, strReference = @strRecordName
					, intUserId = @intUserId
					, intSourceLocationId = @intLocationId
					, intSourceUOMId = @intQuantityUOMId
				FROM tblRKM2MTransaction t
				LEFT JOIN tblSMCurrency c
					ON c.intCurrencyID = @intCurrencyId
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
					AND ISNULL(strPricingType, '') <> 'Cash'
					AND ISNULL(dblResultBasis, 0) <> 0
	
				--Basis entry Offset
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @intUnrealizedGainOnInventoryBasisIOSId ELSE @intUnrealizedLossOnInventoryBasisIOSId END intAccountId
					, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryBasisIOSId END strAccountId
					, CASE WHEN ISNULL(dblResultBasis, 0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
					, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Basis Offset'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Basis Offset'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
					AND ISNULL(strPricingType, '') <> 'Cash'
					AND ISNULL(dblResultBasis, 0) <> 0
		
				-- Futures
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Futures'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Futures'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
					AND ISNULL(strPricingType, '') <> 'Cash'
					AND ISNULL(dblMarketFuturesResult, 0) <> 0
	
				--Futures Offset
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @intUnrealizedGainOnInventoryFuturesIOSId ELSE @intUnrealizedLossOnInventoryFuturesIOSId END intAccountId
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @strUnrealizedGainOnInventoryFuturesIOSId ELSE @strUnrealizedLossOnInventoryFuturesIOSId END strAccountId
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Futures Offset'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Futures Offset'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
					AND ISNULL(strPricingType, '') <> 'Cash'
					AND ISNULL(dblMarketFuturesResult, 0) <> 0

				--Cash
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnCashId ELSE @intUnrealizedLossOnCashId END intAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnCashId ELSE @strUnrealizedLossOnCashId END strAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
					, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Cash'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Cash'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
					AND ISNULL(strPricingType, '') = 'Cash'
					AND ISNULL(dblResultCash, 0) <> 0
	
				--Cash Offset
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnInventoryCashIOSId ELSE @intUnrealizedLossOnInventoryCashIOSId END intAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnInventoryCashIOSId ELSE @strUnrealizedLossOnInventoryCashIOSId END strAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Cash Offset'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Cash Offset'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
					AND ISNULL(strPricingType, '') = 'Cash'
					AND ISNULL(dblResultCash, 0) <> 0

				--Ratio
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN @intUnrealizedGainOnRatioId ELSE @intUnrealizedLossOnRatioId END intAccountId
					, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN @strUnrealizedGainOnRatioId ELSE @strUnrealizedLossOnRatioId END strAccountId
					, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblDebit
					, CASE WHEN ISNULL(dblResultRatio, 0) <= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Ratio'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Ratio'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
					AND ISNULL(dblResultRatio, 0) <> 0
		
				--Ratio Offset
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN @intUnrealizedGainOnInventoryRatioIOSId ELSE @intUnrealizedLossOnInventoryRatioIOSId END intAccountId
					, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN @strUnrealizedGainOnInventoryRatioIOSId ELSE @strUnrealizedLossOnInventoryRatioIOSId END strAccountId
					, CASE WHEN ISNULL(dblResultRatio, 0) <= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblDebit
					, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) * CASE WHEN strContractOrInventoryType = 'Contract(S)' THEN -1 ELSE 1 END >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Ratio Offset'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Ratio Offset'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
					AND ISNULL(dblResultRatio, 0) <> 0
	
				-------- intransit Offset
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @intUnrealizedGainOnInventoryBasisIOSId ELSE @intUnrealizedLossOnInventoryBasisIOSId END intAccountId
					, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryBasisIOSId END strAccountId
					, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
					, CASE WHEN ISNULL(dblResultBasis, 0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Basis Intransit'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Basis Intransit'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
					AND ISNULL(strPricingType, '') <> 'Cash'
					AND ISNULL(dblResultBasis, 0) <> 0

				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @intUnrealizedGainOnInventoryIntransitIOSId ELSE @intUnrealizedLossOnInventoryIntransitIOSId END intAccountId
					, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryIntransitIOSId END strAccountId
					, CASE WHEN ISNULL(dblResultBasis, 0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
					, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Basis Intransit Offset'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Basis Intransit Offset'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
					AND ISNULL(strPricingType, '') <> 'Cash'
					AND ISNULL(dblResultBasis, 0) <> 0
	
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Futures Intransit'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Futures Intransit'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
					AND ISNULL(strPricingType, '') <> 'Cash'
					AND ISNULL(dblMarketFuturesResult, 0) <> 0

				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @intUnrealizedGainOnInventoryIntransitIOSId ELSE @intUnrealizedLossOnInventoryIntransitIOSId END intAccountId
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryIntransitIOSId END strAccountId
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
					, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Futures Intransit Offset'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Futures Intransit Offset'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
					AND ISNULL(strPricingType, '') <> 'Cash'
					AND ISNULL(dblMarketFuturesResult, 0) <> 0

				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnCashId ELSE @intUnrealizedLossOnCashId END intAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnCashId ELSE @strUnrealizedLossOnCashId END strAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
					, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Cash Intransit'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Cash Intransit'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
					AND ISNULL(strPricingType, '') = 'Cash'
					AND ISNULL(dblResultCash, 0) <> 0
		
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnInventoryIntransitIOSId ELSE @intUnrealizedLossOnInventoryIntransitIOSId END intAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnInventoryIntransitIOSId ELSE @strUnrealizedLossOnInventoryIntransitIOSId END strAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Cash Intransit Offset'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq
					, intContractDetailId
					, 'Mark To Market-Cash Intransit Offset'
					, 'Mark To Market'
					, 'Risk Management'
					, 1 
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
					AND ISNULL(strPricingType, '') = 'Cash'
					AND ISNULL(dblResultCash, 0) <> 0

				--Inventory Cash
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnCashId ELSE @intUnrealizedLossOnCashId END intAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnCashId ELSE @strUnrealizedLossOnCashId END strAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
					, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Cash Inventory'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq = @strRecordName
					, intContractDetailId = @intM2MHeaderId
					, 'Mark To Market-Cash Inventory'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('Inventory','In-transit(I)')
					AND ISNULL(dblResultCash, 0) <> 0
	
				--Inventory Cash Offset	
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnInventoryIOSId ELSE @intUnrealizedLossOnInventoryIOSId END intAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnInventoryIOSId ELSE @strUnrealizedLossOnInventoryIOSId END strAccountId
					, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
					, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
					, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
					, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
					, 'Mark To Market-Cash Inventory Offset'
					, @intCurrencyId
					, @dtmPostDate
					, strContractSeq = @strRecordName
					, intContractDetailId = @intM2MHeaderId
					, 'Mark To Market-Cash Inventory Offset'
					, 'Mark To Market'
					, 'Risk Management'
					, 1 
					, dblExchangeRate = CASE WHEN @strRateType = 'Contract' AND ISNULL(dblRate, 0) <> 0
												THEN ISNULL(dblRate, 1)
											WHEN @strRateType = 'Configuration' AND ISNULL(@intCurrencyId, 0) <> 0 
												THEN ISNULL(dbo.fnRKGetCurrencyConvertion(t.intTransactionCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
											ELSE 1
											END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
				FROM tblRKM2MTransaction t
				WHERE intM2MHeaderId = @intM2MHeaderId
					AND strContractOrInventoryType IN ('Inventory','In-transit(I)')
					AND ISNULL(dblResultCash, 0) <> 0
			) z

			-- CURRENCY CONVERSION
			UPDATE t
			SET dblGrossPnL = ISNULL(dblGrossPnL, 0) * 
									CASE WHEN ISNULL(c.ysnSubCurrency, 0) = 0 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> fm.intCurrencyId
										THEN ISNULL(dbo.fnRKGetCurrencyConvertion(fm.intCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
									WHEN ISNULL(c.ysnSubCurrency, 0) = 1 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> c.intMainCurrencyId
										THEN ISNULL(dbo.fnRKGetCurrencyConvertion(c.intMainCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
									ELSE 1
									END,
				dblNetPnL = ISNULL(dblNetPnL, 0) * 
								CASE WHEN ISNULL(c.ysnSubCurrency, 0) = 0 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> fm.intCurrencyId
									THEN ISNULL(dbo.fnRKGetCurrencyConvertion(fm.intCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
								WHEN ISNULL(c.ysnSubCurrency, 0) = 1 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> c.intMainCurrencyId
									THEN ISNULL(dbo.fnRKGetCurrencyConvertion(c.intMainCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
								ELSE 1
								END
			FROM @Result t
			LEFT JOIN tblRKFutureMarket fm
				ON fm.intFutureMarketId = t.intFutureMarketId
			LEFT JOIN tblSMCurrency c
				ON c.intCurrencyID = fm.intCurrencyId


			-- Derivative Transaction
			INSERT INTO tblRKM2MPostPreview (intM2MHeaderId
				, dtmDate
				, intAccountId
				, strAccountId
				, dblDebit
				, dblCredit
				, dblDebitForeign
				, dblCreditForeign
				, dblDebitUnit
				, dblCreditUnit
				, strDescription
				, intCurrencyId
				, dtmTransactionDate
				, strTransactionId
				, intTransactionId
				, strTransactionType
				, strTransactionForm
				, strModuleName
				, intConcurrencyId
				, dblExchangeRate
				, dtmDateEntered
				, ysnIsUnposted
				, intEntityId
				, strReference
				, intUserId
				, intSourceLocationId
				, intSourceUOMId
				, dblPrice)
			SELECT intM2MHeaderId
				, dtmDate
				, intAccountId
				, strAccountId
				, dblDebit
				, dblCredit
				, dblDebitForeign = ISNULL(dblDebit, 0) / ISNULL(dblExchangeRate, 1)
				, dblCreditForeign = ISNULL(dblCredit, 0) / ISNULL(dblExchangeRate, 1)
				, dblDebitUnit
				, dblCreditUnit
				, strDescription
				, intCurrencyId
				, dtmTransactionDate
				, strTransactionId
				, intTransactionId
				, strTransactionType
				, strTransactionForm
				, strModuleName
				, intConcurrencyId
				, dblExchangeRate
				, dtmDateEntered
				, ysnIsUnposted
				, intEntityId
				, strReference
				, intUserId
				, intSourceLocationId
				, intSourceUOMId
				, dblPrice
			FROM 
			(
				SELECT intM2MHeaderId = @intM2MHeaderId
					, dtmDate = @dtmPostDate
					, intAccountId = CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END
					, strAccountId = CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END
					, dblDebit = CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END
					, dblCredit = CASE WHEN ISNULL(dblGrossPnL, 0) <= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END 
					, dblDebitUnit = CASE WHEN ISNULL(dblNetPnL, 0) >= 0 THEN 0.0 ELSE ABS(dblNetPnL) END 
					, dblCreditUnit = CASE WHEN ISNULL(dblNetPnL, 0) <= 0 THEN 0.0 ELSE ABS(dblNetPnL) END 
					, strDescription = 'Mark To Market-Futures Derivative'
					, intCurrencyId = @intCurrencyId
					, dtmTransactionDate = @dtmPostDate
					, strTransactionId = t.strInternalTradeNo
					, intTransactionId = t.intFutOptTransactionId
					, strTransactionType = 'Mark To Market-Futures Derivative'
					, strTransactionForm = 'Mark To Market'
					, strModuleName = 'Risk Management'
					, intConcurrencyId = 1
					, dblExchangeRate = CASE WHEN ISNULL(c.ysnSubCurrency, 0) = 0 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> fm.intCurrencyId
													THEN ISNULL(dbo.fnRKGetCurrencyConvertion(fm.intCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
												WHEN ISNULL(c.ysnSubCurrency, 0) = 1 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> c.intMainCurrencyId
													THEN ISNULL(dbo.fnRKGetCurrencyConvertion(c.intMainCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
												ELSE 1
												END
					, dtmDateEntered = @dtmCurrentDate
					, ysnIsUnposted = 0
					, intEntityId
					, strReference = @strRecordName 
					, intUserId = @intUserId 
					, intSourceLocationId = @intLocationId 
					, intSourceUOMId = @intQuantityUOMId
					, dblPrice = t.dblPrice
				FROM @Result t
				JOIN tblEMEntity e ON t.strName = e.strName
				LEFT JOIN tblRKFutureMarket fm
					ON fm.intFutureMarketId = t.intFutureMarketId
				LEFT JOIN tblSMCurrency c
					ON c.intCurrencyID = fm.intCurrencyId
				WHERE ISNULL(dblGrossPnL, 0) <> 0
	
				UNION ALL SELECT @intM2MHeaderId intM2MHeaderId
					, @dtmPostDate AS dtmPostDate
					, CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
					, CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
					, CASE WHEN ISNULL(dblGrossPnL, 0) <= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END dblDebit
					, CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END dblCredit
					, CASE WHEN ISNULL(dblNetPnL, 0) <= 0 THEN 0.0 ELSE ABS(dblNetPnL) END dblDebitUnit
					, CASE WHEN ISNULL(dblNetPnL, 0) >= 0 THEN 0.0 ELSE ABS(dblNetPnL) END dblCreditUnit
					, 'Mark To Market-Futures Derivative Offset'
					, @intCurrencyId
					, @dtmPostDate
					, t.strInternalTradeNo
					, t.intFutOptTransactionId
					, 'Mark To Market-Futures Derivative Offset'
					, 'Mark To Market'
					, 'Risk Management'
					, 1
					, dblExchangeRate = CASE WHEN ISNULL(c.ysnSubCurrency, 0) = 0 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> fm.intCurrencyId
													THEN ISNULL(dbo.fnRKGetCurrencyConvertion(fm.intCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
												WHEN ISNULL(c.ysnSubCurrency, 0) = 1 AND ISNULL(@intCurrencyId, 0) <> 0 AND @intCurrencyId <> c.intMainCurrencyId
													THEN ISNULL(dbo.fnRKGetCurrencyConvertion(c.intMainCurrencyId, @intCurrencyId, @intMarkToMarketRateTypeId), 1)
												ELSE 1
												END
					, @dtmCurrentDate
					, 0
					, intEntityId
					, @strRecordName strRecordName
					, @intUserId intUserId
					, @intLocationId intLocationId
					, @intQuantityUOMId intQtyUOMId
					, t.dblPrice
				FROM @Result t
				JOIN tblEMEntity e on t.strName = e.strName
				LEFT JOIN tblRKFutureMarket fm
					ON fm.intFutureMarketId = t.intFutureMarketId
				LEFT JOIN tblSMCurrency c
					ON c.intCurrencyID = fm.intCurrencyId
				WHERE ISNULL(dblGrossPnL, 0) <> 0
			) z
		END		
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
			, strCertification NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
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
			WHERE ysnExpired = 0 AND dtmSpotDate < = @dtmCurrentDate
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
			WHERE ysnExpired = 0 AND CONVERT(DATETIME, '01 ' + strFutureMonth) > @dtmCurrentDate
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
																				, [dbo].[fnRKGetSequencePrice](CD.intContractDetailId, CD.dblSettlementPrice, @dtmCurrentDate))
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