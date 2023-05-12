CREATE PROCEDURE [dbo].[uspRKGenerateAllocatedContractsGainOrLoss]
	  @intAllocatedContractsGainOrLossHeaderId INT OUTPUT
	, @strRecordName NVARCHAR(50) = NULL
	, @intCommodityId INT = NULL
	, @intBasisEntryId INT
	, @intFutureSettlementPriceId INT
	, @intQuantityUOMId INT
	, @intPriceUOMId INT
	, @intCurrencyId INT
	, @strRateType NVARCHAR(50) = NULL
	, @dtmTransactionUpTo DATETIME
	, @intLocationId INT = NULL
	, @intMarketZoneId INT = NULL
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

--DECLARE
--	@intAllocatedContractsGainOrLossHeaderId INT
--	, @strRecordName NVARCHAR(50) = 'AC-3'
--	, @intCommodityId INT = 2
--	, @intBasisEntryId INT = 4
--	, @intFutureSettlementPriceId INT = NULL
--	, @intQuantityUOMId INT = 2-- 2=KG, 3=MT
--	, @intPriceUOMId INT = 2
--	, @intCurrencyId INT = 3
--	, @dtmTransactionUpTo DATETIME = GETDATE()
--	, @intLocationId INT = 2
--	, @intMarketZoneId INT = NULL
--	, @intCompanyId INT = NULL
--	, @dtmPostDate DATETIME = GETDATE()
--	, @dtmReverseDate DATETIME = NULL
--	, @dtmLastReversalDate DATETIME = NULL
--	, @intUserId INT = NULL


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
		, @strM2MType NVARCHAR(50)
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell BIT
		, @strTransactionShouldBeRelieved NVARCHAR(50)
		, @ysnDropUninvoicedPurchaseAndInvoicedSales INT
		, @dtmCurrentDate DATETIME = GETDATE()
		, @dtmCurrentDay DATETIME = DATEADD(DD, DATEDIFF(DD, 0, GETDATE()), 0)
		, @intMarkToMarketRateTypeId INT
		, @ysnEnableMTMPoint BIT
		, @ysnIncludeProductInformation BIT

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
		, @strTransactionShouldBeRelieved = strTransactionShouldBeRelieved
		, @ysnDropUninvoicedPurchaseAndInvoicedSales = ysnDropUninvoicedPurchaseAndInvoicedSales
		, @ysnIncludeProductInformation = ysnIncludeProductInformation
	FROM tblRKCompanyPreference
	
	SELECT TOP 1 @intMarkToMarketRateTypeId = intMarkToMarketRateTypeId FROM tblSMMultiCurrency 
	SELECT TOP 1 @ysnEnableMTMPoint = ysnEnableMTMPoint FROM tblCTCompanyPreference

DECLARE @tmpAllocatedContracts TABLE (
	  intAllocatedContractsGainOrLossHeaderId INT
	, strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strTransactionReferenceNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionReferennceId INT 
	--Buy =================================================================================
	, strPurchaseContract  NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strPurchaseCounterparty NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intPurchaseFutureMarketId INT
	, strPurchaseFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intPurchaseFutureMonthId INT
	, strPurchaseLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseMarketZoneCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strPurchaseOriginPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseDestinationPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblPurchaseAllocatedQty NUMERIC(24,6)
	, strPurchaseCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseClass NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseSeason NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseRegion NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchasePosition NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchasePeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmPurchasePlannedAvailabilityDate DATETIME
	, strPurchasePriOrNotPriOrParPriced NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strPurchasePricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblPurchaseContractBasis NUMERIC(24,6)
	, strPurchaseInvoiceStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblPurchaseContractRatio NUMERIC(24,6)
	, dblPurchaseContractFutures NUMERIC(24,6)
	, dblPurchaseContractCash NUMERIC(24,6)
	, dblPurchaseContractCosts NUMERIC(24,6)
	, dblPurchaseValue NUMERIC(24,6)
	, intPurchaseQuantityUnitMeasureId INT
	, intPurchaseContractDetailId INT
	, intPurchaseContractHeaderId INT
	, intPurchaseContractTypeId INT
	, intPurchaseFreightTermId INT
	, intPurchaseCommodityId INT
	, intPurchaseItemId INT
	, intPurchaseCompanyLocationId INT
	, intPurchaseMarketZoneId INT
	, intPurchaseOriginPortId INT
	, intPurchaseDestinationPortId INT
	, intPurchaseCropYearId INT
	, intPurchaseStorageLocationId INT
	, intPurchaseStorageUnitId INT
	, intPurchaseMTMPointId INT
	, strPurchaseMTMPoint NVARCHAR(300) COLLATE Latin1_General_CI_AS
	, strPurchaseCertification NVARCHAR(MAX) COLLATE Latin1_General_CI_AS

	--Sell Contract =================================================================================
	, strSalesContract  NVARCHAR(50)
	, strSalesCounterparty NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intSalesFutureMarketId INT
	, strSalesFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intSalesFutureMonthId INT
	, strSalesLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesMarketZoneCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strSalesOriginPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesDestinationPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblSalesAllocatedQty NUMERIC(24,6)
	, strSalesCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesClass NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesSeason NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesRegion NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesPosition NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmSalesPlannedAvailabilityDate DATETIME
	, strSalesPriOrNotPriOrParPriced NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strSalesPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblSalesContractBasis NUMERIC(24,6)
	, strSalesInvoiceStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblSalesContractRatio NUMERIC(24,6)
	, dblSalesContractFutures NUMERIC(24,6)
	, dblSalesContractCash NUMERIC(24,6)
	, dblSalesContractCosts NUMERIC(24,6)
	, dblSalesValue NUMERIC(24,6)
	, intSalesQuantityUnitMeasureId INT
	, intSalesContractDetailId INT
	, intSalesContractHeaderId INT
	, intSalesContractTypeId INT
	, intSalesFreightTermId INT
	, intSalesCommodityId INT
	, intSalesItemId INT
	, intSalesCompanyLocationId INT
	, intSalesMarketZoneId INT
	, intSalesOriginPortId INT
	, intSalesDestinationPortId INT
	, intSalesCropYearId INT
	, intSalesStorageLocationId INT
	, intSalesStorageUnitId INT
	, intSalesMTMPointId INT
	, strSalesMTMPoint NVARCHAR(300) COLLATE Latin1_General_CI_AS
	, strSalesCertification NVARCHAR(MAX) COLLATE Latin1_General_CI_AS

	, dblMatchedPnL NUMERIC(24,6)
)


IF (ISNULL(@strRecordName, '') = '')
BEGIN		
	EXEC uspSMGetStartingNumber 174, @strRecordName OUTPUT

	INSERT INTO tblRKAllocatedContractsGainOrLossHeader(strRecordName
		, intCommodityId
		, intBasisEntryId
		, intFutureSettlementPriceId
		, intPriceUOMId
		, intQtyUOMId
		, intCurrencyId
		, dtmTransactionUpTo
		, intLocationId
		, intMarketZoneId
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
		, intBasisEntryId = @intBasisEntryId
		, intFutureSettlementPriceId = @intFutureSettlementPriceId
		, intPriceUOMId = @intPriceUOMId
		, intQtyUOMId = @intQuantityUOMId
		, intCurrencyId = @intCurrencyId
		, dtmTransactionUpTo = @dtmTransactionUpTo
		, intLocationId = @intLocationId
		, intMarketZoneId = @intMarketZoneId
		, dtmPostDate = @dtmPostDate
		, dtmReverseDate = @dtmReverseDate
		, dtmLastReversalDate = @dtmLastReversalDate
		, ysnPosted = CAST(0 AS BIT)
		, dtmCreatedDate = GETDATE()
		, dtmUnpostDate = NULL
		, strBatchId = NULL
		, intCompanyId = NULL

	SET @intAllocatedContractsGainOrLossHeaderId = SCOPE_IDENTITY()
END
ELSE
BEGIN
	SELECT TOP 1 @intAllocatedContractsGainOrLossHeaderId = intAllocatedContractsGainOrLossHeaderId FROM tblRKAllocatedContractsGainOrLossHeader WHERE strRecordName = @strRecordName
END



INSERT INTO @tmpAllocatedContracts
SELECT
	@intAllocatedContractsGainOrLossHeaderId
	, strTransactionType = 'Physical'
	, strTransactionReferenceNo = ALH.strAllocationNumber
	, intTransactionReferenceId = ALD.intAllocationHeaderId
	--Purchase Contract =================================================================================
	, strPurchaseContract  = PCH.strContractNumber + '-' + CAST(PCD.intContractSeq AS NVARCHAR(50))
	, strPurchaseCounterparty = P_E.strName
	, strPurchaseFutureMarket = P_FM.strFutMarketName
	, intPurchaseFutureMarketId = P_FM.intFutureMarketId
	, strPurchaseFutureMonth = P_FMo.strFutureMonth
	, intPurchaseFutureMonthId = P_FMo.intFutureMonthId
	, strPurchaseLocationName = CASE WHEN @ysnEvaluationByLocation = 0 THEN NULL ELSE P_CL.strLocationName END
	, strPurchaseMarketZoneCode = CASE WHEN @ysnEvaluationByMarketZone = 0 THEN NULL ELSE P_MZ.strMarketZoneCode END 
	, strPurchaseOriginPort =  CASE WHEN @ysnEvaluationByOriginPort = 0 THEN NULL ELSE P_originPort.strCity END
	, strPurchaseDestinationPort = CASE WHEN @ysnEvaluationByDestinationPort = 0 THEN NULL ELSE P_destinationPort.strCity END 
	, strPurchaseCropYear = CASE WHEN @ysnEvaluationByCropYear = 0 THEN NULL ELSE P_cropYear.strCropYear END
	, strPurchaseStorageLocation = CASE WHEN @ysnEvaluationByStorageLocation = 0 THEN NULL ELSE P_storageLocation.strSubLocationName END
	, strPurchaseStorageUnit = CASE WHEN @ysnEvaluationByStorageUnit = 0 THEN NULL ELSE P_storageUnit.strName END
	, dblPurchaseAllocatedQty = dbo.fnCalculateQtyBetweenUOM(P_ItemUOM.intItemUOMId,P_HeaderQtyUOM.intItemUOMId, ALD.dblPAllocatedQty)
	, strPurchaseCommodityCode = P_COM.strCommodityCode
	, strPurchaseItemNo = P_I.strItemNo
	, strPurchaseOrigin = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE P_CA.strDescription END
	, strPurchaseProductLine = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE P_PL.strDescription END
	, strPurchaseClass = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE P_CLASS.strDescription END
	, strPurchaseSeason = P_SEASON.strDescription
	, strPurchaseRegion = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE P_REGION.strDescription END
	, strPurchaseGrade = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE P_GRADE.strDescription END
	, strPurchaseProductType = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE P_PTC.strDescription END 
	, strPurchasePosition = P_PO.strPosition
	, strPurchasePeriodTo = SUBSTRING(CONVERT(NVARCHAR(20), PCD.dtmEndDate, 106), 4, 8)
	, strPurchaseStartDate =  CONVERT(NVARCHAR(20), PCD.dtmStartDate, 106) 
	, strPurchaseEndDate = CONVERT(NVARCHAR(20), PCD.dtmEndDate, 106)
	, dtmPurchasePlannedAvailabilityDate = PCD.dtmPlannedAvailabilityDate
	, strPurchasePriOrNotPriOrParPriced = CASE WHEN PCD.intPricingTypeId = 2 THEN 
	 											CASE WHEN ISNULL(P_PF.dblTotalLots,0) = 0 THEN 
	 													'Unpriced'
	 												ELSE
	 													CASE WHEN ISNULL(P_PF.dblTotalLots,0)-ISNULL(P_PF.dblLotsFixed,0) = 0 THEN 'Fully Priced' 
	 														WHEN ISNULL(P_PF.dblLotsFixed,0) = 0 THEN 'Unpriced'
	 														ELSE 'Partially Priced' 
	 													END
	 											END
	 										WHEN PCD.intPricingTypeId = 1 THEN	
	 											'Fully Priced'
	 										WHEN PCD.intPricingTypeId = 3 THEN
	 											'Unpriced'
	 										ELSE ''
	 									END	
	, strPurchasePricingType = P_PT.strPricingType
	, dblPurchaseContractBasis = (dbo.fnCalculateQtyBetweenUOM(P_HeaderPriceUOM.intItemUOMId, PCD.intBasisUOMId, PCD.dblBasis) / CASE WHEN P_BasisCur.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
	 							* PRate.dblRateCT
	, strPurchaseInvoiceStatus = PCD.strFinancialStatus
	, dblPurchaseContractRatio = PCD.dblRatio
	, dblPurchaseContractFutures = (dbo.fnCalculateQtyBetweenUOM(P_HeaderPriceUOM.intItemUOMId, PCD.intBasisUOMId, PCD.dblFutures) / CASE WHEN P_PriceCur.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
	 							* PRate.dblRateCT
	, dblPurchaseContractCash = (dbo.fnCalculateQtyBetweenUOM(P_HeaderPriceUOM.intItemUOMId, PCD.intBasisUOMId, PCD.dblCashPrice) / CASE WHEN P_PriceCur.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
	 							* PRate.dblRateCT
	, dblPurchaseContractCosts = NULL
	, dblPurchaseValue = NULL
	, intPurchaseQuantityUnitMeasureId = ALD.intPUnitMeasureId
	, intPurchaseContractDetailId  = PCD.intContractDetailId
	, intPurchaseContractHeaderId  = PCH.intContractHeaderId
	, intPurchaseContractTypeId = PCH.intContractTypeId
	, intPurchaseFreightTermId = PCH.intFreightTermId
	, intPurchaseCommodityId = P_COM.intCommodityId
	, intPurchaseItemId = P_I.intItemId
	, intPurchaseCompanyLocationId = CASE WHEN @ysnEvaluationByLocation = 0 THEN NULL ELSE P_CL.intCompanyLocationId END
	, intPurchaseMarketZoneId = CASE WHEN @ysnEvaluationByMarketZone = 0 THEN NULL ELSE P_MZ.intMarketZoneId END 
	, intPurchaseOriginPortId =  CASE WHEN @ysnEvaluationByOriginPort = 0 THEN NULL ELSE P_originPort.intCityId END
	, intPurchaseDestinationPortId = CASE WHEN @ysnEvaluationByDestinationPort = 0 THEN NULL ELSE P_destinationPort.intCityId END 
	, intPurchaseCropYearId = CASE WHEN @ysnEvaluationByCropYear = 0 THEN NULL ELSE P_cropYear.intCropYearId END
	, intPurchaseStorageLocationId = CASE WHEN @ysnEvaluationByStorageLocation = 0 THEN NULL ELSE P_storageLocation.intCompanyLocationSubLocationId END
	, intPurchaseStorageUnitId = CASE WHEN @ysnEvaluationByStorageUnit = 0 THEN NULL ELSE P_storageUnit.intStorageLocationId END
	, intPurchaseMTMPointId = CASE WHEN @ysnEnableMTMPoint = 0 THEN NULL ELSE PCD.intMTMPointId END
	, strPurchaseMTMPoint = CASE WHEN @ysnEnableMTMPoint = 0 THEN NULL ELSE PMTMPoint.strMTMPoint END
	, strPurchaseCertification = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE PCC.strContractCertifications END



	--Sales Contract =================================================================================
	, strSalesContract  = SCH.strContractNumber + '-' + CAST(SCD.intContractSeq AS NVARCHAR(50))
	, strSalesCounterparty = S_E.strName
	, strSalesFutureMarket = S_FM.strFutMarketName
	, intSalesFutureMarketId = S_FM.intFutureMarketId
	, strSalesFutureMonth = S_FMo.strFutureMonth
	, intSalesFutureMonthId = S_FMo.intFutureMonthId
	, strSalesLocationName = CASE WHEN @ysnEvaluationByLocation = 0 THEN NULL ELSE S_CL.strLocationName END
	, strSalesMarketZoneCode = CASE WHEN @ysnEvaluationByMarketZone = 0 THEN NULL ELSE S_MZ.strMarketZoneCode END 
	, strSalesOriginPort =  CASE WHEN @ysnEvaluationByOriginPort = 0 THEN NULL ELSE S_originPort.strCity END
	, strSalesDestinationPort = CASE WHEN @ysnEvaluationByDestinationPort = 0 THEN NULL ELSE S_destinationPort.strCity END 
	, strSalesCropYear = CASE WHEN @ysnEvaluationByCropYear = 0 THEN NULL ELSE S_cropYear.strCropYear END
	, strSalesStorageLocation = CASE WHEN @ysnEvaluationByStorageLocation = 0 THEN NULL ELSE S_storageLocation.strSubLocationName END
	, strSalesStorageUnit = CASE WHEN @ysnEvaluationByStorageUnit = 0 THEN NULL ELSE S_storageUnit.strName END
	, dblSalesAllocatedQty = dbo.fnCalculateQtyBetweenUOM(S_ItemUOM.intItemUOMId,S_HeaderQtyUOM.intItemUOMId, ALD.dblSAllocatedQty)
	, strSalesCommodityCode = S_COM.strCommodityCode
	, strSalesItemNo = S_I.strItemNo
	, strSalesOrigin = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE S_CA.strDescription END
	, strSalesProductLine = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE S_PL.strDescription END 
	, strSalesClass = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE S_CLASS.strDescription END 
	, strSalesSeason = S_SEASON.strDescription
	, strSalesRegion = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE S_REGION.strDescription END 
	, strSalesGrade = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE S_GRADE.strDescription END 
	, strSalesProductType = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE S_PTC.strDescription END
	, strSalesPosition = S_PO.strPosition
	, strSalesPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20), SCD.dtmEndDate, 106), 4, 8)
	, strSalesStartDate = CONVERT(NVARCHAR(20), SCD.dtmStartDate, 106)
	, strSalesEndDate = CONVERT(NVARCHAR(20), SCD.dtmEndDate, 106)
	, dtmSalesPlannedAvailabilityDate = PCD.dtmPlannedAvailabilityDate
	, strSalesPriOrNotPriOrParPriced =CASE WHEN SCD.intPricingTypeId = 2 THEN 
	 											CASE WHEN ISNULL(S_PF.dblTotalLots,0) = 0 THEN 
	 													'Unpriced'
	 												ELSE
	 													CASE WHEN ISNULL(S_PF.dblTotalLots,0)-ISNULL(S_PF.dblLotsFixed,0) = 0 THEN 'Fully Priced' 
	 														WHEN ISNULL(S_PF.dblLotsFixed,0) = 0 THEN 'Unpriced'
	 														ELSE 'Partially Priced' 
	 													END
	 											END
	 										WHEN SCD.intPricingTypeId = 1 THEN	
	 											'Fully Priced'
	 										WHEN SCD.intPricingTypeId = 3 THEN 
	 											'Unpriced'
	 										ELSE ''
	 									END	
	, strSalesPricingType = S_PT.strPricingType
	, dblSalesContractBasis = (dbo.fnCalculateQtyBetweenUOM(S_HeaderPriceUOM.intItemUOMId, SCD.intBasisUOMId, SCD.dblBasis) / CASE WHEN S_BasisCur.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
	 							* SRate.dblRateCT
	, strSalesInvoiceStatus = SCD.strFinancialStatus
	, dblSalesContractRatio = SCD.dblRatio
	, dblSalesContractFutures = (dbo.fnCalculateQtyBetweenUOM(S_HeaderPriceUOM.intItemUOMId, SCD.intBasisUOMId, SCD.dblFutures) / CASE WHEN S_PriceCur.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
	 							* SRate.dblRateCT
	, dblSalesContractCash = (dbo.fnCalculateQtyBetweenUOM(S_HeaderPriceUOM.intItemUOMId, SCD.intBasisUOMId, SCD.dblCashPrice) / CASE WHEN S_PriceCur.ysnSubCurrency = 1 THEN 100 ELSE 1 END)
	 							* SRate.dblRateCT
	, dblSalesContractCosts = NULL
	, dblSalesValue = NULL
	, intSalesQuantityUnitMeasureId = ALD.intSUnitMeasureId
	, intSalesContractDetailId  = SCD.intContractDetailId
	, intSalesContractHeaderId  = SCH.intContractHeaderId
	, intSalesContractTypeId = SCH.intContractTypeId
	, intSalesFreightTermId = SCH.intFreightTermId
	, intSalesCommodityId = S_COM.intCommodityId
	, intSalesItemId = P_I.intItemId
	, intSalesCompanyLocationId = CASE WHEN @ysnEvaluationByLocation = 0 THEN NULL ELSE S_CL.intCompanyLocationId END
	, intSalesMarketZoneId = CASE WHEN @ysnEvaluationByMarketZone = 0 THEN NULL ELSE S_MZ.intMarketZoneId END 
	, intSalesOriginPortId =  CASE WHEN @ysnEvaluationByOriginPort = 0 THEN NULL ELSE S_originPort.intCityId END
	, intSalesDestinationPortId = CASE WHEN @ysnEvaluationByDestinationPort = 0 THEN NULL ELSE S_destinationPort.intCityId END 
	, intSalesCropYearId = CASE WHEN @ysnEvaluationByCropYear = 0 THEN NULL ELSE S_cropYear.intCropYearId END
	, intSalesStorageLocationId = CASE WHEN @ysnEvaluationByStorageLocation = 0 THEN NULL ELSE S_storageLocation.intCompanyLocationSubLocationId END
	, intSalesStorageUnitId = CASE WHEN @ysnEvaluationByStorageUnit = 0 THEN NULL ELSE S_storageUnit.intStorageLocationId END
	, intSalesMTMPointId = CASE WHEN @ysnEnableMTMPoint = 0 THEN NULL ELSE SCD.intMTMPointId END
	, strSalesMTMPoint = CASE WHEN @ysnEnableMTMPoint = 0 THEN NULL ELSE SMTMPoint.strMTMPoint END
	, strSalesCertification = CASE WHEN @ysnIncludeProductInformation = 0 THEN NULL ELSE SCC.strContractCertifications END

	, dblMatchedPnL = NULL
FROM tblLGAllocationDetail ALD
		INNER JOIN tblLGAllocationHeader ALH ON ALH.intAllocationHeaderId = ALD.intAllocationHeaderId
		--Purchase Contract
		LEFT JOIN tblCTContractDetail PCD ON  PCD.intContractDetailId = ALD.intPContractDetailId
		LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
		LEFT JOIN tblICItem P_I ON P_I.intItemId = PCD.intItemId
		LEFT JOIN tblICItemUOM P_ItemUOM ON P_ItemUOM.intItemId = P_I.intItemId AND P_ItemUOM.intUnitMeasureId = ALD.intPUnitMeasureId
		LEFT JOIN tblICItemUOM P_HeaderQtyUOM ON P_HeaderQtyUOM.intItemId = P_I.intItemId AND P_HeaderQtyUOM.intUnitMeasureId = @intQuantityUOMId
		LEFT JOIN tblICItemUOM P_HeaderPriceUOM ON P_HeaderPriceUOM.intItemId = P_I.intItemId AND P_HeaderPriceUOM.intUnitMeasureId = @intPriceUOMId
		LEFT JOIN tblSMCurrency P_PriceCur ON P_PriceCur.intCurrencyID = PCD.intCurrencyId
		LEFT JOIN tblSMCurrency P_BasisCur ON P_BasisCur.intCurrencyID = PCD.intBasisCurrencyId
		LEFT JOIN tblICCommodity P_COM ON P_COM.intCommodityId = PCH.intCommodityId
		LEFT JOIN tblEMEntity P_E ON P_E.intEntityId = PCH.intEntityId
		LEFT JOIN tblRKFutureMarket P_FM ON P_FM.intFutureMarketId = PCD.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth P_FMo ON P_FMo.intFutureMonthId = PCD.intFutureMonthId
		LEFT JOIN tblSMCompanyLocation P_CL ON P_CL.intCompanyLocationId = PCD.intCompanyLocationId
		LEFT JOIN tblARMarketZone P_MZ ON P_MZ.intMarketZoneId = PCD.intMarketZoneId
		LEFT JOIN tblSMCity P_originPort ON P_originPort.intCityId = PCD.intLoadingPortId
		LEFT JOIN tblSMCity P_destinationPort ON P_destinationPort.intCityId = PCD.intDestinationPortId
		LEFT JOIN tblCTCropYear P_cropYear ON P_cropYear.intCropYearId = PCH.intCropYearId
		LEFT JOIN tblSMCompanyLocationSubLocation P_storageLocation ON P_storageLocation.intCompanyLocationSubLocationId = PCD.intSubLocationId
		LEFT JOIN tblICStorageLocation P_storageUnit ON P_storageUnit.intStorageLocationId = PCD.intStorageLocationId
		LEFT JOIN tblICCommodityAttribute P_CA ON P_CA.intCommodityAttributeId = P_I.intOriginId
		LEFT JOIN tblICCommodityProductLine P_PL ON P_PL.intCommodityProductLineId = P_I.intProductLineId
		LEFT JOIN tblICCommodityAttribute P_PTC ON P_PTC.intCommodityAttributeId = P_I.intProductTypeId
		LEFT JOIN tblICCommodityAttribute P_GRADE ON P_GRADE.intCommodityAttributeId = P_I.intGradeId
		LEFT JOIN tblICCommodityAttribute P_REGION ON P_REGION.intCommodityAttributeId = P_I.intRegionId
		LEFT JOIN tblICCommodityAttribute P_SEASON ON P_SEASON.intCommodityAttributeId = P_I.intSeasonId
		LEFT JOIN tblICCommodityAttribute P_CLASS ON P_CLASS.intCommodityAttributeId = P_I.intClassVarietyId
		LEFT JOIN tblCTPosition P_PO ON P_PO.intPositionId = PCH.intPositionId
		LEFT JOIN tblCTPriceFixation P_PF ON P_PF.intContractDetailId = PCD.intContractDetailId	
		LEFT JOIN tblCTPricingType P_PT ON P_PT.intPricingTypeId = PCD.intPricingTypeId
		OUTER APPLY (
			SELECT strContractCertifications = (LTRIM(STUFF((
				SELECT ', ' + ICC.strCertificationName
				FROM tblCTContractCertification CTC
				JOIN tblICCertification ICC
					ON ICC.intCertificationId = CTC.intCertificationId
				WHERE CTC.intContractDetailId = PCD.intContractDetailId
				ORDER BY ICC.strCertificationName
				FOR XML PATH('')), 1, 1, ''))
			) COLLATE Latin1_General_CI_AS
		) PCC
		--LEFT JOIN tblICItemUOM P_FuturesUOM ON P_FuturesUOM.intItemId = P_I.intItemId AND P_FuturesUOM.intUnitMeasureId = P_FM.intUnitMeasureId

		--Sales Contract
		LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = ALD.intSContractDetailId 
		LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
		LEFT JOIN tblICItem S_I ON S_I.intItemId = SCD.intItemId
		LEFT JOIN tblICItemUOM S_ItemUOM ON S_ItemUOM.intItemId = S_I.intItemId AND S_ItemUOM.intUnitMeasureId = ALD.intSUnitMeasureId
		LEFT JOIN tblICItemUOM S_HeaderQtyUOM ON S_HeaderQtyUOM.intItemId = S_I.intItemId AND S_HeaderQtyUOM.intUnitMeasureId = @intQuantityUOMId
		LEFT JOIN tblICItemUOM S_HeaderPriceUOM ON S_HeaderPriceUOM.intItemId = S_I.intItemId AND S_HeaderPriceUOM.intUnitMeasureId = @intPriceUOMId
		LEFT JOIN tblSMCurrency S_PriceCur ON S_PriceCur.intCurrencyID = PCD.intCurrencyId
		LEFT JOIN tblSMCurrency S_BasisCur ON S_BasisCur.intCurrencyID = PCD.intBasisCurrencyId
		LEFT JOIN tblICCommodity S_COM ON S_COM.intCommodityId = SCH.intCommodityId
		LEFT JOIN tblEMEntity S_E ON S_E.intEntityId = SCH.intEntityId
		LEFT JOIN tblRKFutureMarket S_FM ON S_FM.intFutureMarketId = SCD.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth S_FMo ON S_FMo.intFutureMonthId = SCD.intFutureMonthId
		LEFT JOIN tblSMCompanyLocation S_CL ON S_CL.intCompanyLocationId = SCD.intCompanyLocationId
		LEFT JOIN tblARMarketZone S_MZ ON S_MZ.intMarketZoneId = SCD.intMarketZoneId
		LEFT JOIN tblSMCity S_originPort ON S_originPort.intCityId = SCD.intLoadingPortId
		LEFT JOIN tblSMCity S_destinationPort ON S_destinationPort.intCityId = SCD.intDestinationPortId
		LEFT JOIN tblCTCropYear S_cropYear ON S_cropYear.intCropYearId = SCH.intCropYearId
		LEFT JOIN tblSMCompanyLocationSubLocation S_storageLocation ON S_storageLocation.intCompanyLocationSubLocationId = SCD.intSubLocationId
		LEFT JOIN tblICStorageLocation S_storageUnit ON S_storageUnit.intStorageLocationId = SCD.intStorageLocationId
		LEFT JOIN tblICCommodityAttribute S_CA ON S_CA.intCommodityAttributeId = S_I.intOriginId
		LEFT JOIN tblICCommodityProductLine S_PL ON S_PL.intCommodityProductLineId = S_I.intProductLineId
		LEFT JOIN tblICCommodityAttribute S_PTC ON S_PTC.intCommodityAttributeId = S_I.intProductTypeId
		LEFT JOIN tblICCommodityAttribute S_GRADE ON S_GRADE.intCommodityAttributeId = S_I.intGradeId
		LEFT JOIN tblICCommodityAttribute S_REGION ON S_REGION.intCommodityAttributeId = S_I.intRegionId
		LEFT JOIN tblICCommodityAttribute S_SEASON ON S_SEASON.intCommodityAttributeId = S_I.intSeasonId
		LEFT JOIN tblICCommodityAttribute S_CLASS ON S_CLASS.intCommodityAttributeId = S_I.intClassVarietyId
		LEFT JOIN tblCTPosition S_PO ON S_PO.intPositionId = SCH.intPositionId
		LEFT JOIN tblCTPriceFixation S_PF ON S_PF.intContractDetailId = SCD.intContractDetailId	
		LEFT JOIN tblCTPricingType S_PT ON S_PT.intPricingTypeId = SCD.intPricingTypeId
		OUTER APPLY (
			SELECT strContractCertifications = (LTRIM(STUFF((
				SELECT ', ' + ICC.strCertificationName
				FROM tblCTContractCertification CTC
				JOIN tblICCertification ICC
					ON ICC.intCertificationId = CTC.intCertificationId
				WHERE CTC.intContractDetailId = SCD.intContractDetailId
				ORDER BY ICC.strCertificationName
				FOR XML PATH('')), 1, 1, ''))
			) COLLATE Latin1_General_CI_AS
		) SCC
		OUTER APPLY (
			SELECT dblRateCT = CASE WHEN PCD.intCurrencyId = @intCurrencyId
									THEN 1
									ELSE
										CASE WHEN @strRateType = 'Contract' 
										THEN
											ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
													WHERE ISNULL(dtmFXValidFrom, @dtmCurrentDay) <= @dtmCurrentDay AND ISNULL(dtmFXValidTo, @dtmCurrentDay) >= @dtmCurrentDay
														AND ISNULL(dblRate, 0) <> 0
														AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId 
																						FROM tblSMCurrencyExchangeRate forex
																						WHERE forex.intFromCurrencyId = PCD.intCurrencyId
																						AND forex.intToCurrencyId = @intCurrencyId)
														AND intContractDetailId = PCD.intContractDetailId)
												, dbo.fnRKGetCurrencyConvertion(PCD.intCurrencyId, @intCurrencyId, DEFAULT))
										ELSE dbo.fnRKGetCurrencyConvertion(PCD.intCurrencyId, @intCurrencyId, DEFAULT) END
									END
		) PRate
		OUTER APPLY (
			SELECT dblRateCT = CASE WHEN SCD.intCurrencyId = @intCurrencyId
									THEN 1
									ELSE
										CASE WHEN @strRateType = 'Contract' 
										THEN
											ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
													WHERE ISNULL(dtmFXValidFrom, @dtmCurrentDay) <= @dtmCurrentDay AND ISNULL(dtmFXValidTo, @dtmCurrentDay) >= @dtmCurrentDay
														AND ISNULL(dblRate, 0) <> 0
														AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId 
																						FROM tblSMCurrencyExchangeRate forex
																						WHERE forex.intFromCurrencyId = SCD.intCurrencyId
																						AND forex.intToCurrencyId = @intCurrencyId)
														AND intContractDetailId = SCD.intContractDetailId)
												, dbo.fnRKGetCurrencyConvertion(SCD.intCurrencyId, @intCurrencyId, DEFAULT))
										ELSE dbo.fnRKGetCurrencyConvertion(SCD.intCurrencyId, @intCurrencyId, DEFAULT) END
									END
		) SRate
		LEFT JOIN tblCTMTMPoint PMTMPoint
			ON PMTMPoint.intMTMPointId = PCD.intMTMPointId
		LEFT JOIN tblCTMTMPoint SMTMPoint
			ON SMTMPoint.intMTMPointId = SCD.intMTMPointId
		--LEFT JOIN tblICItemUOM S_FuturesUOM ON S_FuturesUOM.intItemId = S_I.intItemId AND S_FuturesUOM.intUnitMeasureId = S_FM.intUnitMeasureId
	
		
WHERE P_COM.intCommodityId = @intCommodityId 
AND S_COM.intCommodityId = @intCommodityId
AND ALH.dtmTransDate <= @dtmTransactionUpTo
AND ALH.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN ALH.intCompanyLocationId ELSE @intLocationId END

--Filtering out transactions based on company configuration
IF @ysnDropUninvoicedPurchaseAndInvoicedSales = 1
BEGIN

	IF @strTransactionShouldBeRelieved = 'Final Invoiced'
	BEGIN

		DELETE FROM @tmpAllocatedContracts 
		WHERE intSalesContractDetailId IN (
			select distinct intContractDetailId 
			from tblARInvoiceDetail ID
			inner join tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			where intContractDetailId in (select intSalesContractDetailId from @tmpAllocatedContracts)
			and I.strType IN ('Standard') and I.strTransactionType = 'Invoice'
		)
	END

	IF @strTransactionShouldBeRelieved = 'Provisional Invoiced'
	BEGIN
		DELETE FROM @tmpAllocatedContracts 
		WHERE intSalesContractDetailId IN (
			select distinct intContractDetailId 
			from tblARInvoiceDetail ID
			inner join tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			where intContractDetailId in (select intSalesContractDetailId from @tmpAllocatedContracts)
			and I.strType IN ('Provisional')  and I.strTransactionType = 'Invoice'
		)
	END

	UPDATE @tmpAllocatedContracts SET strSalesInvoiceStatus = 'Provisional Invoiced'
	WHERE  intSalesContractDetailId IN (
			select distinct intContractDetailId 
			from tblARInvoiceDetail ID
			inner join tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			where intContractDetailId in (select intSalesContractDetailId from @tmpAllocatedContracts)
			and I.strType IN ('Provisional')  and I.strTransactionType = 'Invoice'
		)

END
ELSE
BEGIN
	
select distinct BD.intContractDetailId 
,CASE B.intTransactionType
		 WHEN 1 THEN 'Voucher'
		 WHEN 2 THEN 'Vendor Prepayment'
		 WHEN 3 THEN 'Debit Memo'
		 WHEN 7 THEN 'Invalid Type'
		 WHEN 9 THEN '1099 Adjustment'
		 WHEN 11 THEN 'Claim'
		 WHEN 12 THEN 'Prepayment Reversal'
		 WHEN 13 THEN 'Basis Advance'
		 WHEN 14 THEN 'Deferred Interest'
		 WHEN 15 THEN 'Tax Adjustment'
		 WHEN 16 THEN 'Provisional Voucher' 
		 ELSE 'Invalid Type'
	END COLLATE Latin1_General_CI_AS AS strTransactionType
into #tmpPurchaseWithVoucher 
from tblAPBillDetail BD
inner join tblAPBill B on B.intBillId = BD.intBillId
where BD.intContractDetailId in (select intPurchaseContractDetailId from @tmpAllocatedContracts)

	IF @strTransactionShouldBeRelieved = 'Final Invoiced'
	BEGIN
		DELETE FROM @tmpAllocatedContracts 
		WHERE intSalesContractDetailId IN (
			select distinct intContractDetailId 
			from tblARInvoiceDetail ID
			inner join tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			where intContractDetailId in (select intSalesContractDetailId from @tmpAllocatedContracts)
			and I.strType IN ('Standard') and I.strTransactionType = 'Invoice'
		)
		AND intPurchaseContractDetailId IN (select intContractDetailId from #tmpPurchaseWithVoucher)
	END

	IF @strTransactionShouldBeRelieved = 'Provisional Invoiced'
	BEGIN
		DELETE FROM @tmpAllocatedContracts 
		WHERE intSalesContractDetailId IN (
			select distinct intContractDetailId 
			from tblARInvoiceDetail ID
			inner join tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			where intContractDetailId in (select intSalesContractDetailId from @tmpAllocatedContracts)
			and I.strType IN ('Provisional')  and I.strTransactionType = 'Invoice'
		)
		AND intPurchaseContractDetailId IN (select intContractDetailId from #tmpPurchaseWithVoucher)
	END


	UPDATE @tmpAllocatedContracts SET strSalesInvoiceStatus = 'Provisional Invoiced'
	WHERE  intSalesContractDetailId IN (
			select distinct intContractDetailId 
			from tblARInvoiceDetail ID
			inner join tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			where intContractDetailId in (select intSalesContractDetailId from @tmpAllocatedContracts)
			and I.strType IN ('Provisional')  and I.strTransactionType = 'Invoice'
		)

	UPDATE @tmpAllocatedContracts SET strSalesInvoiceStatus = 'Final Invoiced'
	WHERE  intSalesContractDetailId IN (
			select distinct intContractDetailId 
			from tblARInvoiceDetail ID
			inner join tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			where intContractDetailId in (select intSalesContractDetailId from @tmpAllocatedContracts)
			and I.strType IN ('Standard')  and I.strTransactionType = 'Invoice'
		)
	
	UPDATE AC 
	SET AC.strPurchaseInvoiceStatus =  PWV.strTransactionType
	FROM @tmpAllocatedContracts AC
	INNER JOIN #tmpPurchaseWithVoucher PWV ON PWV.intContractDetailId = AC.intPurchaseContractDetailId
	

DROP TABLE #tmpPurchaseWithVoucher
END


--=================================================
--Start - Update Allocated Contracts Futures
--=================================================
DECLARE @tblSettlementPrice TABLE (intFutureMarketId INT
		, intFutureMonthId INT
		, dblSettlementPrice NUMERIC(38, 20)
		, intUnitMeasureId INT
		, intCurrencyId INT
		, ysnSubCurrency INT)
	

IF ISNULL(@intFutureSettlementPriceId, 0) > 0
BEGIN
	INSERT INTO @tblSettlementPrice(intFutureMarketId
		, intFutureMonthId
		, dblSettlementPrice
		, intUnitMeasureId
		, intCurrencyId
		, ysnSubCurrency)
	SELECT intFutureMarketId = SettlementPrice.intFutureMarketId
		, intFutureMonthId = MarketMap.intFutureMonthId
		, dblSettlementPrice = ISNULL(MarketMap.dblLastSettle, 0)
		, FM.intUnitMeasureId
		, intCurrencyId = CASE WHEN C.ysnSubCurrency = 1 THEN C.intMainCurrencyId ELSE FM.intCurrencyId END
		, C.ysnSubCurrency
	FROM tblRKFutSettlementPriceMarketMap MarketMap
	JOIN tblRKFuturesSettlementPrice SettlementPrice ON SettlementPrice.intFutureSettlementPriceId = MarketMap.intFutureSettlementPriceId
	JOIN tblRKFuturesMonth Mo ON Mo.intFutureMonthId = MarketMap.intFutureMonthId AND ISNULL(Mo.ysnExpired, 0) = 0
	JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = SettlementPrice.intFutureMarketId
	JOIN tblSMCurrency C ON C.intCurrencyID = FM.intCurrencyId
	WHERE SettlementPrice.intFutureSettlementPriceId = @intFutureSettlementPriceId
			
	INSERT INTO @tblSettlementPrice(intFutureMarketId
		, intFutureMonthId
		, dblSettlementPrice
		, intUnitMeasureId
		, intCurrencyId
		, ysnSubCurrency)
	SELECT intFutureMarketId = SettlementPrice.intFutureMarketId
		, intFutureMonthId = MarketMap.intFutureMonthId
		, dblSettlementPrice = ISNULL(MarketMap.dblLastSettle, 0)
		, FM.intUnitMeasureId
		, intCurrencyId = CASE WHEN C.ysnSubCurrency = 1 THEN C.intMainCurrencyId ELSE FM.intCurrencyId END
		, C.ysnSubCurrency
	FROM tblRKFutSettlementPriceMarketMap MarketMap
	JOIN tblRKFuturesSettlementPrice SettlementPrice ON SettlementPrice.intFutureSettlementPriceId = MarketMap.intFutureSettlementPriceId
	JOIN tblRKFuturesMonth Mo ON Mo.intFutureMonthId = MarketMap.intFutureMonthId AND ISNULL(Mo.ysnExpired, 0) = 0
	JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = SettlementPrice.intFutureMarketId
	JOIN tblSMCurrency C ON C.intCurrencyID = FM.intCurrencyId
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
		, dblSettlementPrice
		, intUnitMeasureId)
	SELECT intFutureMarketId = SettlementPrice.intFutureMarketId
		, intFutureMonthId = MarketMap.intFutureMonthId
		, dblSettlementPrice = ISNULL(MarketMap.dblLastSettle, 0)
		, Market.intUnitMeasureId
	FROM tblRKFutureMarket Market
	JOIN tblRKFuturesSettlementPrice SettlementPrice ON SettlementPrice.intFutureMarketId = Market.intFutureMarketId
	JOIN tblRKFutSettlementPriceMarketMap MarketMap ON MarketMap.intFutureSettlementPriceId = SettlementPrice.intFutureSettlementPriceId 
	WHERE SettlementPrice.intFutureSettlementPriceId = (SELECT MAX(intFutureSettlementPriceId) FROM tblRKFuturesSettlementPrice WHERE intFutureMarketId = Market.intFutureMarketId)
END 

DELETE FROM tblRKAllocatedContractsSettlementPrice WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId

INSERT INTO tblRKAllocatedContractsSettlementPrice(
	intAllocatedContractsGainOrLossHeaderId
	,intFutureMarketId
	,intFutureMonthId
	,dblClosingPrice
)
SELECT DISTINCT 
	@intAllocatedContractsGainOrLossHeaderId
	,intFutureMarketId
	,intFutureMonthId
	,dblSettlementPrice
FROM @tblSettlementPrice SP
INNER JOIN @tmpAllocatedContracts AC ON SP.intFutureMarketId = AC.intPurchaseFutureMarketId AND SP.intFutureMonthId = AC.intPurchaseFutureMonthId
WHERE AC.dblPurchaseContractFutures IS NULL

UNION ALL

SELECT DISTINCT
	@intAllocatedContractsGainOrLossHeaderId
	,intFutureMarketId
	,intFutureMonthId
	,dblSettlementPrice
FROM @tblSettlementPrice SP
INNER JOIN @tmpAllocatedContracts AC ON SP.intFutureMarketId = AC.intSalesFutureMarketId AND SP.intFutureMonthId = AC.intSalesFutureMonthId
WHERE AC.dblSalesContractFutures IS NULL




UPDATE AC
SET AC.dblPurchaseContractFutures = (ISNULL(dbo.fnCalculateQtyBetweenUOM(P_FuturesUOM.intItemUOMId, P_HeaderPriceUOM.intItemUOMId, SP.dblSettlementPrice), 0) 
										/ CASE WHEN SP.ysnSubCurrency = 1 THEN 100 ELSE 1 END) * SettlementRate.dblRateFP
FROM @tmpAllocatedContracts AC
LEFT JOIN @tblSettlementPrice SP ON SP.intFutureMarketId = AC.intPurchaseFutureMarketId AND SP.intFutureMonthId = AC.intPurchaseFutureMonthId
LEFT JOIN tblICItemUOM P_HeaderPriceUOM ON P_HeaderPriceUOM.intItemId = AC.intPurchaseItemId AND P_HeaderPriceUOM.intUnitMeasureId = @intPriceUOMId
LEFT JOIN tblICItemUOM P_FuturesUOM ON P_FuturesUOM.intItemId = AC.intPurchaseItemId AND P_FuturesUOM.intUnitMeasureId = SP.intUnitMeasureId
OUTER APPLY (
	SELECT dblRateFP = CASE WHEN SP.intCurrencyId = @intCurrencyId
							THEN 1
							ELSE
								CASE WHEN @strRateType = 'Contract' 
								THEN
								ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
										WHERE ISNULL(dtmFXValidFrom, @dtmCurrentDay) <= @dtmCurrentDay AND ISNULL(dtmFXValidTo, @dtmCurrentDay) >= @dtmCurrentDay
											AND ISNULL(dblRate, 0) <> 0
											AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId 
																			FROM tblSMCurrencyExchangeRate forex
																			WHERE forex.intFromCurrencyId = SP.intCurrencyId
																			AND forex.intToCurrencyId = @intCurrencyId)
											AND intContractDetailId = AC.intPurchaseContractDetailId)
									, dbo.fnRKGetCurrencyConvertion(SP.intCurrencyId, @intCurrencyId, DEFAULT))
								ELSE dbo.fnRKGetCurrencyConvertion(SP.intCurrencyId, @intCurrencyId, DEFAULT) END
							END
) SettlementRate
WHERE AC.dblPurchaseContractFutures IS NULL

UPDATE AC
SET AC.dblSalesContractFutures = (ISNULL(dbo.fnCalculateQtyBetweenUOM(S_FuturesUOM.intItemUOMId, S_HeaderPriceUOM.intItemUOMId, SP.dblSettlementPrice), 0)
										/ CASE WHEN SP.ysnSubCurrency = 1 THEN 100 ELSE 1 END) * SettlementRate.dblRateFP
FROM @tmpAllocatedContracts AC
LEFT JOIN @tblSettlementPrice SP ON SP.intFutureMarketId = AC.intSalesFutureMarketId AND SP.intFutureMonthId = AC.intSalesFutureMonthId
LEFT JOIN tblICItemUOM S_HeaderPriceUOM ON S_HeaderPriceUOM.intItemId = AC.intSalesItemId AND S_HeaderPriceUOM.intUnitMeasureId = @intPriceUOMId
LEFT JOIN tblICItemUOM S_FuturesUOM ON S_FuturesUOM.intItemId = AC.intSalesItemId AND S_FuturesUOM.intUnitMeasureId = SP.intUnitMeasureId
OUTER APPLY (
	SELECT dblRateFP = CASE WHEN SP.intCurrencyId = @intCurrencyId
							THEN 1
							ELSE
								CASE WHEN @strRateType = 'Contract' 
								THEN
								ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
										WHERE ISNULL(dtmFXValidFrom, @dtmCurrentDay) <= @dtmCurrentDay AND ISNULL(dtmFXValidTo, @dtmCurrentDay) >= @dtmCurrentDay
											AND ISNULL(dblRate, 0) <> 0
											AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId 
																			FROM tblSMCurrencyExchangeRate forex
																			WHERE forex.intFromCurrencyId = SP.intCurrencyId
																			AND forex.intToCurrencyId = @intCurrencyId)
											AND intContractDetailId = AC.intSalesContractDetailId)
									, dbo.fnRKGetCurrencyConvertion(SP.intCurrencyId, @intCurrencyId, DEFAULT))
								ELSE dbo.fnRKGetCurrencyConvertion(SP.intCurrencyId, @intCurrencyId, DEFAULT) END
							END
) SettlementRate
WHERE AC.dblSalesContractFutures IS NULL


--=================================================
--End - Update Allocated Contracts Futures
--=================================================

--=================================================
--Start - Update Allocated Contracts Basis
--=================================================

SELECT dblRatio
	, dblMarketBasis = (ISNULL(dblBasisOrDiscount, 0) + ISNULL(dblCashOrFuture, 0)) / CASE WHEN ISNULL(c.ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END
	, intMarketBasisUOM = intCommodityUnitMeasureId
	, intMarketBasisCurrencyId = CASE WHEN ISNULL(c.ysnSubCurrency, 0) = 1 THEN c.intMainCurrencyId ELSE temp.intCurrencyId END
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
	, temp.intM2MBasisDetailId
	, temp.intPricingTypeId
	, temp.strOriginDest
	, temp.intFutureMonthId
	, temp.intMTMPointId
	, temp.strCertification
INTO #tmpBasisDetail
FROM tblRKM2MBasisDetail temp
LEFT JOIN tblSMCurrency c ON temp.intCurrencyId=c.intCurrencyID
JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = temp.intCommodityId AND temp.intUnitMeasureId = cum.intUnitMeasureId
WHERE temp.intM2MBasisId = @intBasisEntryId AND temp.intCommodityId = @intCommodityId


IF EXISTS (SELECT TOP 1 1 FROM @tmpAllocatedContracts WHERE dblPurchaseContractBasis IS NULL OR dblSalesContractBasis IS NULL)
BEGIN
	-- PURCHASE
	SELECT DISTINCT  basisDetail.intM2MBasisDetailId
		, basisDetail.dblRatio
		, basisDetail.dblMarketBasis
		, basisDetail.intMarketBasisUOM
		, basisDetail.intMarketBasisCurrencyId
		, intContractDetailId = AC.intPurchaseContractDetailId
	INTO #tmpUsedBasisDetail
	FROM @tmpAllocatedContracts AC
	OUTER APPLY (
		SELECT TOP 1 intM2MBasisDetailId
			, dblRatio
			, dblMarketBasis
			, intMarketBasisUOM
			, intMarketBasisCurrencyId
		FROM #tmpBasisDetail tmp
		WHERE ISNULL(tmp.intFutureMarketId,0) = ISNULL(AC.intPurchaseFutureMarketId, ISNULL(tmp.intFutureMarketId,0))
			AND ISNULL(tmp.intItemId,0) = CASE WHEN @strEvaluationBy = 'Item' 
												THEN ISNULL(AC.intPurchaseItemId, 0)
												ELSE ISNULL(tmp.intItemId, 0)
												END
			AND ISNULL(tmp.intContractTypeId, 0) = CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1
																			THEN ISNULL(AC.intPurchaseContractTypeId, 0)
																			ELSE ISNULL(tmp.intContractTypeId, 0) END
			AND ISNULL(tmp.intCompanyLocationId, 0) = CASE WHEN @ysnEvaluationByLocation = 1 
																			THEN ISNULL(AC.intPurchaseCompanyLocationId, 0)
																			ELSE ISNULL(tmp.intCompanyLocationId, 0) END
			AND ISNULL(tmp.intMarketZoneId, 0) = CASE WHEN @ysnEvaluationByMarketZone = 1 
																			THEN ISNULL(AC.intPurchaseMarketZoneId, 0)
																			ELSE ISNULL(tmp.intMarketZoneId, 0) END
			AND ISNULL(tmp.intOriginPortId, 0) = CASE WHEN @ysnEvaluationByOriginPort = 1 
																			THEN ISNULL(AC.intPurchaseOriginPortId, 0)
																			ELSE ISNULL(tmp.intOriginPortId, 0) END
			AND ISNULL(tmp.intDestinationPortId, 0) = CASE WHEN @ysnEvaluationByDestinationPort = 1 
																			THEN ISNULL(AC.intPurchaseDestinationPortId, 0)
																			ELSE ISNULL(tmp.intDestinationPortId, 0) END
			AND ISNULL(tmp.intCropYearId, 0) = CASE WHEN @ysnEvaluationByCropYear = 1 
																			THEN ISNULL(AC.intPurchaseCropYearId, 0)
																			ELSE ISNULL(tmp.intCropYearId, 0) END
			AND ISNULL(tmp.intStorageLocationId, 0) = CASE WHEN @ysnEvaluationByStorageLocation = 1 
																			THEN ISNULL(AC.intPurchaseStorageLocationId, 0)
																			ELSE ISNULL(tmp.intStorageLocationId, 0) END
			AND ISNULL(tmp.intStorageUnitId, 0) = CASE WHEN @ysnEvaluationByStorageUnit = 1 
																			THEN ISNULL(AC.intPurchaseStorageUnitId, 0)
																			ELSE ISNULL(tmp.intStorageUnitId, 0) END
			AND ISNULL(tmp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
												THEN dbo.fnRKFormatDate(AC.strPurchaseEndDate, 'MMM yyyy')
												ELSE ISNULL(tmp.strPeriodTo, '')
												END
			AND ISNULL(tmp.intMTMPointId, 0) = CASE WHEN @ysnEnableMTMPoint = 1 
																			THEN ISNULL(AC.intPurchaseMTMPointId, 0)
																			ELSE ISNULL(tmp.intMTMPointId, 0) END
			AND ISNULL(tmp.strCertification, '') = CASE WHEN @ysnIncludeProductInformation = 1 
																			THEN ISNULL(AC.strPurchaseCertification, '')
																			ELSE ISNULL(tmp.strCertification, '') END
			AND tmp.strContractInventory = 'Contract' 
	) basisDetail
	WHERE AC.dblPurchaseContractBasis IS NULL

	-- SALES
	UNION ALL
	SELECT DISTINCT basisDetail.intM2MBasisDetailId
		, basisDetail.dblRatio
		, basisDetail.dblMarketBasis
		, basisDetail.intMarketBasisUOM
		, basisDetail.intMarketBasisCurrencyId
		, intContractDetailId = AC.intSalesContractDetailId
	FROM @tmpAllocatedContracts AC
	OUTER APPLY (
		SELECT TOP 1 intM2MBasisDetailId
			, dblRatio
			, dblMarketBasis
			, intMarketBasisUOM
			, intMarketBasisCurrencyId
		FROM #tmpBasisDetail tmp
		LEFT JOIN tblSMCurrency MC
			ON MC.intCurrencyID = tmp.intMarketBasisCurrencyId
		WHERE ISNULL(tmp.intFutureMarketId,0) = ISNULL(AC.intSalesFutureMarketId, ISNULL(tmp.intFutureMarketId,0))
			AND ISNULL(tmp.intItemId,0) = CASE WHEN @strEvaluationBy = 'Item' 
												THEN ISNULL(AC.intSalesItemId, 0)
												ELSE ISNULL(tmp.intItemId, 0)
												END
			AND ISNULL(tmp.intContractTypeId, 0) = CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1
																			THEN ISNULL(AC.intSalesContractTypeId, 0)
																			ELSE ISNULL(tmp.intContractTypeId, 0) END
			AND ISNULL(tmp.intCompanyLocationId, 0) = CASE WHEN @ysnEvaluationByLocation = 1 
																			THEN ISNULL(AC.intSalesCompanyLocationId, 0)
																			ELSE ISNULL(tmp.intCompanyLocationId, 0) END
			AND ISNULL(tmp.intMarketZoneId, 0) = CASE WHEN @ysnEvaluationByMarketZone = 1 
																			THEN ISNULL(AC.intSalesMarketZoneId, 0)
																			ELSE ISNULL(tmp.intMarketZoneId, 0) END
			AND ISNULL(tmp.intOriginPortId, 0) = CASE WHEN @ysnEvaluationByOriginPort = 1 
																			THEN ISNULL(AC.intSalesOriginPortId, 0)
																			ELSE ISNULL(tmp.intOriginPortId, 0) END
			AND ISNULL(tmp.intDestinationPortId, 0) = CASE WHEN @ysnEvaluationByDestinationPort = 1 
																			THEN ISNULL(AC.intSalesDestinationPortId, 0)
																			ELSE ISNULL(tmp.intDestinationPortId, 0) END
			AND ISNULL(tmp.intCropYearId, 0) = CASE WHEN @ysnEvaluationByCropYear = 1 
																			THEN ISNULL(AC.intSalesCropYearId, 0)
																			ELSE ISNULL(tmp.intCropYearId, 0) END
			AND ISNULL(tmp.intStorageLocationId, 0) = CASE WHEN @ysnEvaluationByStorageLocation = 1 
																			THEN ISNULL(AC.intSalesStorageLocationId, 0)
																			ELSE ISNULL(tmp.intStorageLocationId, 0) END
			AND ISNULL(tmp.intStorageUnitId, 0) = CASE WHEN @ysnEvaluationByStorageUnit = 1 
																			THEN ISNULL(AC.intSalesStorageUnitId, 0)
																			ELSE ISNULL(tmp.intStorageUnitId, 0) END
			AND ISNULL(tmp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
												THEN dbo.fnRKFormatDate(AC.strSalesEndDate, 'MMM yyyy')
												ELSE ISNULL(tmp.strPeriodTo, '')
												END
			AND ISNULL(tmp.intMTMPointId, 0) = CASE WHEN @ysnEnableMTMPoint = 1 
																			THEN ISNULL(AC.intSalesMTMPointId, 0)
																			ELSE ISNULL(tmp.intMTMPointId, 0) END
			AND ISNULL(tmp.strCertification, '') = CASE WHEN @ysnIncludeProductInformation = 1 
																			THEN ISNULL(AC.strSalesCertification, '')
																			ELSE ISNULL(tmp.strCertification, '') END
			AND tmp.strContractInventory = 'Contract' 
	) basisDetail
	WHERE AC.dblSalesContractBasis IS NULL

	DELETE FROM tblRKAllocatedContractsBasisEntry WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId

	INSERT INTO tblRKAllocatedContractsBasisEntry(intAllocatedContractsGainOrLossHeaderId
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
	)
	SELECT
		@intAllocatedContractsGainOrLossHeaderId
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
		, dblBasisOrDiscount = dblMarketBasis
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
	FROM #tmpBasisDetail 
	WHERE intM2MBasisDetailId IN (SELECT DISTINCT intM2MBasisDetailId FROM #tmpUsedBasisDetail)

	

	--Purchase Contract
	UPDATE AC SET dblPurchaseContractBasis = basisDetail.dblMarketBasis * MBRate.dblRateMB
	FROM @tmpAllocatedContracts AC
	INNER JOIN #tmpUsedBasisDetail basisDetail
		ON basisDetail.intContractDetailId = AC.intPurchaseContractDetailId
	OUTER APPLY (
		SELECT dblRateMB = CASE WHEN basisDetail.intMarketBasisCurrencyId = @intCurrencyId
							THEN 1
							ELSE
								CASE WHEN @strRateType = 'Contract' 
								THEN
								ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
										WHERE ISNULL(dtmFXValidFrom, @dtmCurrentDay) <= @dtmCurrentDay AND ISNULL(dtmFXValidTo, @dtmCurrentDay) >= @dtmCurrentDay
											AND ISNULL(dblRate, 0) <> 0
											AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId 
																			FROM tblSMCurrencyExchangeRate forex
																			WHERE forex.intFromCurrencyId = basisDetail.intMarketBasisCurrencyId
																			AND forex.intToCurrencyId = @intCurrencyId)
											AND intContractDetailId = AC.intPurchaseContractDetailId)
									, dbo.fnRKGetCurrencyConvertion(basisDetail.intMarketBasisCurrencyId, @intCurrencyId, DEFAULT))
								ELSE dbo.fnRKGetCurrencyConvertion(basisDetail.intMarketBasisCurrencyId, @intCurrencyId, DEFAULT) END
							END
	) MBRate
	WHERE AC.dblPurchaseContractBasis IS NULL

	--Sales Contract
	UPDATE AC SET dblSalesContractBasis = basisDetail.dblMarketBasis * MBRate.dblRateMB
	FROM @tmpAllocatedContracts AC
	INNER JOIN #tmpUsedBasisDetail basisDetail
		ON basisDetail.intContractDetailId = AC.intSalesContractDetailId
	OUTER APPLY (
		SELECT dblRateMB = CASE WHEN basisDetail.intMarketBasisCurrencyId = @intCurrencyId
							THEN 1
							ELSE
								CASE WHEN @strRateType = 'Contract' 
								THEN
								ISNULL((SELECT TOP 1 dblRate FROM tblCTContractDetail
										WHERE ISNULL(dtmFXValidFrom, @dtmCurrentDay) <= @dtmCurrentDay AND ISNULL(dtmFXValidTo, @dtmCurrentDay) >= @dtmCurrentDay
											AND ISNULL(dblRate, 0) <> 0
											AND intCurrencyExchangeRateId = (SELECT TOP 1 intCurrencyExchangeRateId 
																			FROM tblSMCurrencyExchangeRate forex
																			WHERE forex.intFromCurrencyId = basisDetail.intMarketBasisCurrencyId
																			AND forex.intToCurrencyId = @intCurrencyId)
											AND intContractDetailId = AC.intSalesContractDetailId)
									, dbo.fnRKGetCurrencyConvertion(basisDetail.intMarketBasisCurrencyId, @intCurrencyId, DEFAULT))
								ELSE dbo.fnRKGetCurrencyConvertion(basisDetail.intMarketBasisCurrencyId, @intCurrencyId, DEFAULT) END
							END
	) MBRate
	WHERE AC.dblSalesContractBasis IS NULL
	
	DROP TABLE #tmpUsedBasisDetail
END



--=================================================
--End - Update Allocated Contracts Basis
--=================================================

--=================================================
--Start - Update Allocated Contracts Cash
--=================================================

UPDATE @tmpAllocatedContracts
SET dblPurchaseContractCash  = ISNULL(dblPurchaseContractBasis,0) + ISNULL(dblPurchaseContractFutures,0)
WHERE dblPurchaseContractCash IS NULL

UPDATE @tmpAllocatedContracts
SET dblSalesContractCash  = ISNULL(dblSalesContractBasis,0) + ISNULL(dblSalesContractFutures,0)
WHERE dblSalesContractCash IS NULL


--=================================================
--End - Update Allocated Contracts Cash
--=================================================


--=================================================
--Start - Update Allocated Contracts Costs
--=================================================
SELECT intContractDetailId = CC.intContractDetailId
	, dblRate = CC.dblRate 
				/ (CASE WHEN CC.strCostMethod = 'Amount' 
					THEN CASE WHEN CH.ysnLoad = 1 
							THEN (ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId, cu2.intCommodityUnitMeasureId, ISNULL(CD.dblQuantityPerLoad, 1)), 1) 
									* CAST(ISNULL(CD.intNoOfLoad, 1) AS NUMERIC(16, 8)))
							ELSE ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId, cu2.intCommodityUnitMeasureId, ISNULL(CD.dblQuantity, 1)), 1)
							END
					ELSE 1
					END)
	, ysnAccrue = CC.ysnAccrue	
	, dblTotalCost = (CASE WHEN CC.ysnAccrue = 1 THEN CASE WHEN CC.strCostStatus = 'Closed' THEN ISNULL(CC.dblActualAmount, 0)
														ELSE ISNULL(CC.dblActualAmount, 0) + ISNULL(CC.dblAccruedAmount, 0) END
													* (CASE WHEN intPurchaseContractTypeId = 1 THEN 1 ELSE -1 END) 
						WHEN CC.ysnAccrue = 0 AND CC.strCostMethod = 'Per Unit' THEN ISNULL(CC.dblRate, 0) * ISNULL(CC.dblFX , 1)
																* dbo.fnGRConvertQuantityToTargetItemUOM(CC.intItemId, AC.intPurchaseQuantityUnitMeasureId, ItemUOM.intUnitMeasureId, CD.dblQuantity)
																* CASE WHEN M2M.strAdjustmentType = 'Add' THEN 1
																	WHEN M2M.strAdjustmentType = 'Reduce' THEN -1 END
																/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END
						WHEN CC.ysnAccrue = 0 AND CC.strCostMethod <> 'Per Unit' THEN 0 END)
INTO #tmpPurchaseContractCost
FROM tblCTContractCost CC
JOIN @tmpAllocatedContracts AC ON AC.intPurchaseContractDetailId = CC.intContractDetailId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = AC.intPurchaseContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem Item ON Item.intItemId = CC.intItemId 
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CC.intItemUOMId
LEFT JOIN tblSMCurrency	FCY ON FCY.intCurrencyID = CC.intCurrencyId
LEFT JOIN tblRKM2MConfiguration M2M ON M2M.intItemId = CC.intItemId AND M2M.intFreightTermId = AC.intPurchaseFreightTermId
LEFT JOIN tblICItemUOM CIU ON CIU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = @intCommodityId AND cu1.intUnitMeasureId = CIU.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cu2 ON cu2.intCommodityId = @intCommodityId AND cu2.intUnitMeasureId = @intPriceUOMId
WHERE Item.strCostType <> 'Commission'


UPDATE AC
SET AC.dblPurchaseContractCosts = 
			(ISNULL(CC.dblTotalCost, 0) 
			/ CASE WHEN CH.ysnLoad = 1 
				THEN (ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId, cu2.intCommodityUnitMeasureId, ISNULL(CD.dblQuantityPerLoad, 1)), 1) 
						* CAST(ISNULL(CD.intNoOfLoad, 1) AS NUMERIC(16, 8)))
				ELSE ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId, cu2.intCommodityUnitMeasureId, ISNULL(CD.dblQuantity, 1)), 1)
				END) 
FROM @tmpAllocatedContracts AC
JOIN tblCTContractDetail CD ON CD.intContractDetailId = AC.intPurchaseContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblICItemUOM CIU ON CIU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = @intCommodityId AND cu1.intUnitMeasureId = CIU.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cu2 ON cu2.intCommodityId = @intCommodityId AND cu2.intUnitMeasureId = @intPriceUOMId
JOIN (SELECT intContractDetailId, SUM(ISNULL(dblTotalCost, 0)) dblTotalCost 
FROM #tmpPurchaseContractCost GROUP BY intContractDetailId) CC ON CC.intContractDetailId = AC.intPurchaseContractDetailId



SELECT intContractDetailId = CC.intContractDetailId
	, dblRate = CC.dblRate 
				/ (CASE WHEN CC.strCostMethod = 'Amount' 
					THEN CASE WHEN CH.ysnLoad = 1 
							THEN (ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId, cu2.intCommodityUnitMeasureId, ISNULL(CD.dblQuantityPerLoad, 1)), 1) 
									* CAST(ISNULL(CD.intNoOfLoad, 1) AS NUMERIC(16, 8)))
							ELSE ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId, cu2.intCommodityUnitMeasureId, ISNULL(CD.dblQuantity, 1)), 1)
							END
					ELSE 1
					END)
	, ysnAccrue = CC.ysnAccrue	
	, dblTotalCost = CASE WHEN CC.ysnAccrue = 1 THEN CASE WHEN CC.strCostStatus = 'Closed' THEN ISNULL(CC.dblActualAmount, 0)
														ELSE ISNULL(CC.dblActualAmount, 0) + ISNULL(CC.dblAccruedAmount, 0) END
													* (CASE WHEN intSalesContractTypeId = 1 THEN 1 ELSE -1 END)
						WHEN CC.ysnAccrue = 0 AND CC.strCostMethod = 'Per Unit' THEN ISNULL(CC.dblRate, 0) * ISNULL(CC.dblFX , 1)
																* dbo.fnGRConvertQuantityToTargetItemUOM(CC.intItemId, AC.intSalesQuantityUnitMeasureId, ItemUOM.intUnitMeasureId, CD.dblQuantity)
																* CASE WHEN M2M.strAdjustmentType = 'Add' THEN 1
																	WHEN M2M.strAdjustmentType = 'Reduce' THEN -1 END
																/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END
						WHEN CC.ysnAccrue = 0 AND CC.strCostMethod <> 'Per Unit' THEN 0 END
INTO #tmpSalesContractCost
FROM tblCTContractCost CC
JOIN @tmpAllocatedContracts AC ON AC.intSalesContractDetailId = CC.intContractDetailId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = AC.intSalesContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem Item ON Item.intItemId = CC.intItemId 
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CC.intItemUOMId
LEFT JOIN tblSMCurrency	FCY ON FCY.intCurrencyID = CC.intCurrencyId
LEFT JOIN tblRKM2MConfiguration M2M ON M2M.intItemId = CC.intItemId AND M2M.intFreightTermId = AC.intSalesFreightTermId
LEFT JOIN tblICItemUOM CIU ON CIU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = @intCommodityId AND cu1.intUnitMeasureId = CIU.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cu2 ON cu2.intCommodityId = @intCommodityId AND cu2.intUnitMeasureId = @intPriceUOMId
WHERE Item.strCostType <> 'Commission'



UPDATE AC
SET AC.dblSalesContractCosts = 
			(ISNULL(CC.dblTotalCost, 0) 
			/ CASE WHEN CH.ysnLoad = 1 
				THEN (ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId, cu2.intCommodityUnitMeasureId, ISNULL(CD.dblQuantityPerLoad, 1)), 1) 
						* CAST(ISNULL(CD.intNoOfLoad, 1) AS NUMERIC(16, 8)))
				ELSE ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cu1.intCommodityUnitMeasureId, cu2.intCommodityUnitMeasureId, ISNULL(CD.dblQuantity, 1)), 1)
				END)
FROM @tmpAllocatedContracts AC
JOIN tblCTContractDetail CD ON CD.intContractDetailId = AC.intSalesContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblICItemUOM CIU ON CIU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = @intCommodityId AND cu1.intUnitMeasureId = CIU.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure cu2 ON cu2.intCommodityId = @intCommodityId AND cu2.intUnitMeasureId = @intQuantityUOMId
JOIN (SELECT intContractDetailId, SUM(ISNULL(dblTotalCost, 0)) dblTotalCost FROM #tmpSalesContractCost GROUP BY intContractDetailId) CC ON CC.intContractDetailId = AC.intSalesContractDetailId

--================================================
--End - Update Allocated Contracts Costs
--=================================================


--=================================================
--Start - Update Allocated Value
--=================================================

UPDATE @tmpAllocatedContracts
SET dblPurchaseValue  = (ISNULL(dblPurchaseContractCash,0) + ISNULL(dblPurchaseContractCosts,0)) * dblPurchaseAllocatedQty
WHERE dblPurchaseValue IS NULL

UPDATE @tmpAllocatedContracts
SET dblSalesValue  = (ISNULL(dblSalesContractCash,0) + ISNULL(dblSalesContractCosts,0)) * dblSalesAllocatedQty
WHERE dblSalesValue IS NULL


--=================================================
--End - Update Allocated Contracts Value
--=================================================



--=========================================================
--Start - Update Allocated MatchPnL for Allocated Contract
--=========================================================

UPDATE @tmpAllocatedContracts
SET dblMatchedPnL  = ISNULL(dblSalesValue,0) - ISNULL(dblPurchaseValue,0)
WHERE dblMatchedPnL IS NULL


--=========================================================
--End - Update Allocated MatchPnL for Allocated Contract
--=========================================================



--Matched Derivatives
INSERT INTO @tmpAllocatedContracts
SELECT
	@intAllocatedContractsGainOrLossHeaderId
	, strTransactionType = 'Derivative'
	, strTransactionReferenceNo = psh.intMatchNo
	, intTransactionReferenceId = psd.intMatchFuturesPSHeaderId
	--Buy =================================================================================
	, strPurchaseContract  = buy.strInternalTradeNo
	, strPurchaseCounterparty = E.strName
	, strPurchaseFutureMarket = fm.strFutMarketName
	, intPurchaseFutureMarketId = fm.intFutureMarketId
	, strPurchaseFutureMonth = LFM.strFutureMonth
	, intPurchaseFutureMonthId = LFM.intFutureMonthId
	, strPurchaseLocationName = CASE WHEN @ysnEvaluationByLocation = 0 THEN NULL ELSE CL.strLocationName END
	, strPurchaseMarketZoneCode = NULL
	, strPurchaseOriginPort =  NULL
	, strPurchaseDestinationPort = NULL
	, strPurchaseCropYear = NULL
	, strPurchaseStorageLocation = NULL
	, strPurchaseStorageUnit = NULL
	, dblPurchaseAllocatedQty =  dbo.fnCTConvertQuantityToTargetCommodityUOM(qtyUOM.intCommodityUnitMeasureId,CUM.intCommodityUnitMeasureId, ISNULL(psd.dblMatchQty, 0.00)) * fm.dblContractSize
	, strPurchaseCommodityCode = COM.strCommodityCode
	, strPurchaseItemNo = NULL
	, strPurchaseOrigin = NULL
	, strPurchaseProductLine = NULL
	, strPurchaseClass = NULL
	, strPurchaseSeason = NULL
	, strPurchaseRegion = NULL
	, strPurchaseGrade = NULL
	, strPurchaseProductType = NULL
	, strPurchasePosition = NULL
	, strPurchasePeriodTo = NULL
	, strPurchaseStartDate = NULL
	, strPurchaseEndDate = NULL
	, dtmPurchasePlannedAvailabilityDate =NULL
	, strPurchasePriOrNotPriOrParPriced = NULL
	, strPurchasePricingType = NULL
	, dblPurchaseContractBasis = NULL
	, strPurchaseInvoiceStatus = NULL
	, dblPurchaseContractRatio = NULL
	, dblPurchaseContractFutures = dbo.fnCTConvertQuantityToTargetCommodityUOM(priceUOM.intCommodityUnitMeasureId,CUM.intCommodityUnitMeasureId, ISNULL(buy.dblPrice, 0.00))
	, dblPurchaseContractCash = NULL
	, dblPurchaseContractCosts = NULL
	, dblPurchaseValue =  (dbo.fnCTConvertQuantityToTargetCommodityUOM(priceUOM.intCommodityUnitMeasureId,CUM.intCommodityUnitMeasureId, ISNULL(psd.dblMatchQty, 0.00)) * fm.dblContractSize) * ISNULL(buy.dblPrice, 0.00)
	, intPurchaseQuantityUnitMeasureId = NULL
	, intPurchaseContractDetailId  = NULL
	, intPurchaseContractHeaderId = NULL
	, intPurchaseContractTypeId = NULL
	, intPurchaseFreightTermId = NULL
	, intPurchaseCommodityId = buy.intCommodityId
	, intPurchaseItemId = NULL
	, intPurchaseCompanyLocationId = NULL
	, intPurchaseMarketZoneId = NULL
	, intPurchaseOriginPortId =  NULL
	, intPurchaseDestinationPortId = NULL
	, intPurchaseCropYearId = NULL
	, intPurchaseStorageLocationId = NULL
	, intPurchaseStorageUnitId = NULL
	, intPurchaseMTMPointId = NULL
	, strPurchaseMTMPoint = NULL
	, strPurchaseCertification = NULL

	--Sell Contract =================================================================================
	, strSalesContract  = sell.strInternalTradeNo
	, strSalesCounterparty = E.strName
	, strSalesFutureMarket = fm.strFutMarketName
	, intSalesFutureMarketId = fm.intFutureMarketId
	, strSalesFutureMonth = LFM.strFutureMonth
	, intSalesFutureMonthId = LFM.intFutureMonthId
	, strSalesLocationName = CASE WHEN @ysnEvaluationByLocation = 0 THEN NULL ELSE CL.strLocationName END
	, strSalesMarketZoneCode = NULL
	, strSalesOriginPort =  NULL
	, strSalesDestinationPort = NULL
	, strSalesCropYear = NULL
	, strSalesStorageLocation = NULL
	, strSalesStorageUnit = NULL
	, dblSalesAllocatedQty =  dbo.fnCTConvertQuantityToTargetCommodityUOM(qtyUOM.intCommodityUnitMeasureId,CUM.intCommodityUnitMeasureId, ISNULL(psd.dblMatchQty, 0.00)) * fm.dblContractSize
	, strSalesCommodityCode = COM.strCommodityCode
	, strSalesItemNo = NULL
	, strSalesOrigin = NULL
	, strSalesProductLine = NULL
	, strSalesClass = NULL
	, strSalesSeason = NULL
	, strSalesRegion = NULL
	, strSalesGrade = NULL
	, strSalesProductType = NULL
	, strSalesPosition = NULL
	, strSalesPeriodTo = NULL
	, strSalesStartDate = NULL
	, strSalesEndDate = NULL
	, dtmSalesPlannedAvailabilityDate =NULL
	, strSalesPriOrNotPriOrParPriced = NULL
	, strSalesPricingType = NULL
	, dblSalesContractBasis = NULL
	, strSalesInvoiceStatus = NULL
	, dblSalesContractRatio = NULL
	, dblSalesContractFutures = dbo.fnCTConvertQuantityToTargetCommodityUOM(priceUOM.intCommodityUnitMeasureId,CUM.intCommodityUnitMeasureId, ISNULL(sell.dblPrice, 0.00))
	, dblSalesContractCash = NULL
	, dblSalesContractCosts = NULL
	, dblSalesValue =  (dbo.fnCTConvertQuantityToTargetCommodityUOM(priceUOM.intCommodityUnitMeasureId,CUM.intCommodityUnitMeasureId, ISNULL(psd.dblMatchQty, 0.00)) * fm.dblContractSize) * ISNULL(sell.dblPrice, 0.00)
	, intSalesQuantityUnitMeasureId = NULL
	, intSalesContractDetailId  = NULL
	, intSalesContractHeaderId = NULL
	, intSalesContractTypeId = NULL
	, intSalesFreightTermId = NULL
	, intSalesCommodityId = sell.intCommodityId
	, intSalesItemId = NULL
	, intSalesCompanyLocationId = NULL
	, intSalesMarketZoneId = NULL
	, intSalesOriginPortId =  NULL
	, intSalesDestinationPortId = NULL
	, intSalesCropYearId = NULL
	, intSalesStorageLocationId = NULL
	, intSalesStorageUnitId = NULL
	, intSalesMTMPointId = NULL
	, strSalesMTMPoint = NULL
	, strSalesCertification = NULL

	, dblMatchedPnL = NULL
FROM tblRKMatchFuturesPSHeader psh
JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId
JOIN tblRKFutOptTransaction buy ON psd.intLFutOptTransactionId = buy.intFutOptTransactionId
JOIN tblRKFutOptTransaction sell ON psd.intSFutOptTransactionId = sell.intFutOptTransactionId
JOIN tblICCommodity COM ON COM.intCommodityId = psh.intCommodityId
LEFT JOIN tblRKFutureMarket fm ON buy.intFutureMarketId = fm.intFutureMarketId
LEFT JOIN tblSMCurrency c ON c.intCurrencyID = fm.intCurrencyId
LEFT JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = c.intMainCurrencyId
LEFT JOIN tblRKFuturesMonth LFM ON LFM.intFutureMonthId = buy.intFutureMonthId
LEFT JOIN tblRKFuturesMonth SFM ON SFM.intFutureMonthId = sell.intFutureMonthId
LEFT JOIN tblRKBrokerageAccount ba ON buy.intBrokerageAccountId = ba.intBrokerageAccountId AND buy.intInstrumentTypeId IN (1)
LEFT JOIN tblEMEntity E ON E.intEntityId = ba.intEntityId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = psh.intCompanyLocationId
JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityId = COM.intCommodityId AND CUM.intUnitMeasureId = fm.intUnitMeasureId
JOIN tblICCommodityUnitMeasure qtyUOM ON qtyUOM.intCommodityId = COM.intCommodityId AND qtyUOM.intUnitMeasureId = @intQuantityUOMId
JOIN tblICCommodityUnitMeasure priceUOM ON priceUOM.intCommodityId = COM.intCommodityId AND priceUOM.intUnitMeasureId = @intPriceUOMId
WHERE ISNULL(psh.ysnPosted,0) = 0
AND COM.intCommodityId = @intCommodityId
AND psh.dtmMatchDate <= @dtmTransactionUpTo
AND psh.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN psh.intCompanyLocationId ELSE @intLocationId END



--=========================================================
--Start - Update Allocated MatchPnL for Matched Derivatives
--=========================================================

UPDATE @tmpAllocatedContracts
SET dblMatchedPnL  = ISNULL(dblSalesValue,0) - ISNULL(dblPurchaseValue,0)
WHERE dblMatchedPnL IS NULL
AND strTransactionType = 'Derivative'


--=========================================================
--End - Update Allocated MatchPnL for Matched Derivatives
--=========================================================


--=========================================================
--Start - Inserting Transaction Data
--=========================================================

DELETE FROM tblRKAllocatedContractsTransaction WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId

INSERT INTO tblRKAllocatedContractsTransaction
SELECT *,intConcurrencyId = 1 FROM @tmpAllocatedContracts

--=========================================================
--End - Inserting Transaction Data
--=========================================================




--=========================================================
--Start - Get the Summary Data
--=========================================================

DELETE FROM tblRKAllocatedContractsSummary WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId

INSERT INTO tblRKAllocatedContractsSummary(
	intAllocatedContractsGainOrLossHeaderId
	,strSummary
	,intCommodityId
	,dblPurchaseAllocatedQty
	,dblSalesAllocatedQty
	,dblTotal
	,dblFutures
	,dblBasis
	,dblCash
)
SELECT intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId
	, strSummary = strTransactionType
	, intCommodityId = @intCommodityId
	, dblPurchaseAllocatedQty = SUM(ISNULL(dblPurchaseAllocatedQty, 0))
	, dblSalesAllocatedQty = SUM(ISNULL(dblSalesAllocatedQty, 0))
	, dblTotal = SUM(ISNULL(dblMatchedPnL, 0))
	, dblFutures = SUM(ISNULL(dblSalesContractFutures, 0) - ISNULL(dblPurchaseContractFutures, 0) )
	, dblBasis = SUM(ISNULL(dblSalesContractBasis, 0) - ISNULL(dblPurchaseContractBasis, 0) )
	, dblCash = SUM(ISNULL(dblSalesContractCash, 0) - ISNULL(dblPurchaseContractCash, 0) )
FROM @tmpAllocatedContracts
GROUP BY  strTransactionType
	,strPurchaseCommodityCode
ORDER BY strTransactionType DESC
--=========================================================
--End - Get the Summary Data
--=========================================================



--=========================================================
--Start - Get the Post Preview
--=========================================================


DELETE FROM tblRKAllocatedContractsPostRecap WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId

DECLARE @intAllocatedContractGainOrLossId INT
		,@strAllocatedContractGainOrLossId NVARCHAR(40)
		,@strAllocatedContractGainOrLossIdDescription NVARCHAR(255)
		,@intAllocatedContractGainOrLossOffsetId INT
		,@strAllocatedContractGainOrLossOffsetId NVARCHAR(40)
		,@strAllocatedContractGainOrLossOffsetIdDescription NVARCHAR(255)

SELECT 
	@intAllocatedContractGainOrLossId = intAllocatedContractGainOrLossId 
	,@intAllocatedContractGainOrLossOffsetId = intAllocatedContractGainOrLossOffsetId
FROM tblRKCompanyPreference


SELECT
	@intAllocatedContractGainOrLossId = fn.intAccountId
	, @strAllocatedContractGainOrLossId = fn.strAccountNo
	, @strAllocatedContractGainOrLossIdDescription = CASE WHEN fn.ysnHasError = 1 THEN fn.strErrorMessage ELSE gl.strDescription END
FROM dbo.fnRKGetAccountIdForLocationLOB('Allocated Contracts Gain or Loss', @intAllocatedContractGainOrLossId, @intCommodityId, @intLocationId) fn
LEFT JOIN tblGLAccount gl ON gl.intAccountId = fn.intAccountId

SELECT
	@intAllocatedContractGainOrLossOffsetId = fn.intAccountId
	, @strAllocatedContractGainOrLossOffsetId = fn.strAccountNo
	, @strAllocatedContractGainOrLossOffsetIdDescription = CASE WHEN fn.ysnHasError = 1 THEN fn.strErrorMessage ELSE gl.strDescription END
FROM dbo.fnRKGetAccountIdForLocationLOB('Allocated Contracts Gain or Loss Offset', @intAllocatedContractGainOrLossOffsetId, @intCommodityId, @intLocationId) fn
LEFT JOIN tblGLAccount gl ON gl.intAccountId = fn.intAccountId



INSERT INTO tblRKAllocatedContractsPostRecap(
	intAllocatedContractsGainOrLossHeaderId
	,dtmPostDate
	,intAccountId
	,strAccountId
	,dblDebit
	,dblCredit
	,dblDebitUnit
	,dblCreditUnit
	,strAccountDescription
	,intCurrencyId
	,dtmTransactionDate
	,strTransactionId
	,intTransactionId
	,strTransactionType
	,strTransactionForm
	,strModuleName
	,strCode
	,intConcurrencyId
	,dblExchangeRate
	,dtmDateEntered
	,ysnIsUnposted
	,intEntityId
	,strReference
	,intUserId
	,intSourceLocationId
	,intSourceUOMId
	,intCommodityId
)
SELECT 
	intAllocatedContractsGainOrLossHeaderId
	,dtmPostDate
	,intAccountId
	,strAccountId
	,dblDebit
	,dblCredit
	,dblDebitUnit
	,dblCreditUnit
	,strAccountDescription
	,intCurrencyId
	,dtmTransactionDate
	,strTransactionId
	,intTransactionId
	,strTransactionType
	,strTransactionForm
	,strModuleName
	,strCode
	,intConcurrencyId
	,dblExchangeRate
	,dtmDateEntered
	,ysnIsUnposted
	,intEntityId
	,strReference
	,intUserId
	,intSourceLocationId
	,intSourceUOMId
	,intCommodityId
FROM (

	SELECT intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId
		, @dtmPostDate AS dtmPostDate
		, intAccountId = @intAllocatedContractGainOrLossId
		, strAccountId = @strAllocatedContractGainOrLossId
		, dblDebit = CASE WHEN ISNULL(dblMatchedPnL, 0) >= 0 THEN 0.00 ELSE ABS(dblMatchedPnL) END
		, dblCredit = CASE WHEN ISNULL(dblMatchedPnL, 0) >= 0 THEN ABS(dblMatchedPnL) ELSE 0.00 END
		, dblDebitUnit = CASE WHEN ISNULL(dblMatchedPnL, 0) >= 0 THEN 0.00 ELSE ABS(dblPurchaseAllocatedQty) END
		, dblCreditUnit = CASE WHEN ISNULL(dblMatchedPnL, 0) >= 0 THEN ABS(dblPurchaseAllocatedQty) ELSE 0.00 END
		, strAccountDescription = @strAllocatedContractGainOrLossIdDescription
		, intCurrencyId = @intCurrencyId
		, dtmTransactionDate = @dtmPostDate
		, strTransactionId = strTransactionReferenceNo
		, intTransactionId = intTransactionReferenceId
		, strTransactionType = 'Allocated Contracts Gain or Loss'
		, strTransactionForm = 'Allocated Contracts Gain or Loss'
		, strModuleName = 'Risk Management'
		, strCode = 'RK'
		, intConcurrencyId = 1
		, dblExchangeRate = 1
		, dtmDateEntered = @dtmCurrentDate
		, ysnIsUnposted = 0
		, intEntityId = @intUserId
		, strReference =  @strRecordName
		, intUserId = @intUserId 
		, intSourceLocationId = @intLocationId
		, intSourceUOMId = @intQuantityUOMId
		, intCommodityId = @intCommodityId
		, intAllocatedContractsTransactionId
		, intSortId = 2
	FROM tblRKAllocatedContractsTransaction
	WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId
		AND strTransactionType IN ('Physical')
		AND ISNULL(dblMatchedPnL, 0) <> 0

	UNION ALL

	SELECT intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId
		, @dtmPostDate AS dtmPostDate
		, intAccountId = @intAllocatedContractGainOrLossOffsetId
		, strAccountId = @strAllocatedContractGainOrLossOffsetId
		, dblDebit = CASE WHEN ISNULL(dblMatchedPnL, 0) <= 0 THEN 0.00 ELSE ABS(dblMatchedPnL) END
		, dblCredit = CASE WHEN ISNULL(dblMatchedPnL, 0) <= 0 THEN ABS(dblMatchedPnL) ELSE 0.00 END
		, dblDebitUnit = CASE WHEN ISNULL(dblMatchedPnL, 0) <= 0 THEN 0.00 ELSE ABS(dblPurchaseAllocatedQty) END
		, dblCreditUnit = CASE WHEN ISNULL(dblMatchedPnL, 0) <= 0 THEN ABS(dblPurchaseAllocatedQty) ELSE 0.00 END
		, strAccountDescription = @strAllocatedContractGainOrLossOffsetIdDescription
		, intCurrencyId = @intCurrencyId
		, dtmTransactionDate = @dtmPostDate
		, strTransactionId = strTransactionReferenceNo
		, intTransactionId = intTransactionReferenceId
		, strTransactionType = 'Allocated Contracts Gain or Loss Offset'
		, strTransactionForm = 'Allocated Contracts Gain or Loss'
		, strModuleName = 'Risk Management'
		, strCode = 'RK'
		, intConcurrencyId = 1
		, dblExchangeRate = 1
		, dtmDateEntered = @dtmCurrentDate
		, ysnIsUnposted = 0
		, intEntityId = @intUserId
		, strReference =  @strRecordName
		, intUserId = @intUserId 
		, intSourceLocationId = @intLocationId
		, intSourceUOMId = @intQuantityUOMId
		, intCommodityId = @intCommodityId
		, intAllocatedContractsTransactionId
		, intSortId = 2
	FROM tblRKAllocatedContractsTransaction
	WHERE intAllocatedContractsGainOrLossHeaderId = @intAllocatedContractsGainOrLossHeaderId
		AND strTransactionType IN ('Physical')
		AND ISNULL(dblMatchedPnL, 0) <> 0
) t
ORDER BY intAllocatedContractsTransactionId, intSortId

--=========================================================
--End - Get the Post Preview
--=========================================================

DROP TABLE #tmpPurchaseContractCost
DROP TABLE #tmpSalesContractCost
DROP TABLE #tmpBasisDetail


END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH