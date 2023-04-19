CREATE PROCEDURE [dbo].[uspTRFFacilityLimitsReport]
	  @intBankId INT
	, @intFacilityId INT = NULL
	, @dtmStartDate DATE
	, @dtmEndDate DATE
	, @intCurrencyId INT = NULL

AS
 
 SET QUOTED_IDENTIFIER OFF
 SET ANSI_NULLS ON
 SET NOCOUNT ON
 SET XACT_ABORT ON
 SET ANSI_WARNINGS OFF

 BEGIN TRY
 	DECLARE @ErrMsg NVARCHAR(MAX)

 	IF ISNULL(@intFacilityId, 0) = 0
 	BEGIN
 		SET @intFacilityId = NULL
 	END
	
 	IF ISNULL(@intCurrencyId, 0) = 0
 	BEGIN
 		SET @intCurrencyId = NULL
 	END

 	-- Get KG UOM
 	DECLARE @intKilogramUnitMeasureId INT = NULL
 		, @dblZero DECIMAL(16, 8) = 0

 	SELECT @intKilogramUnitMeasureId = intUnitMeasureId FROM tblICUnitMeasure
 	WHERE strUnitMeasure = 'Kilogram'

 	-- Company Preference values
 	DECLARE @ysnEnterForwardCurveForMarketBasisDifferential BIT
			, @strEvaluationBy NVARCHAR(50)
 			, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell BIT
			, @ysnEvaluationByLocation BIT
			, @ysnEvaluationByMarketZone BIT
			, @ysnEvaluationByOriginPort BIT
			, @ysnEvaluationByDestinationPort BIT
			, @ysnEvaluationByCropYear BIT
			, @ysnEvaluationByStorageLocation BIT
			, @ysnEvaluationByStorageUnit BIT
		
 	SELECT TOP 1
 		  @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential
 		, @strEvaluationBy = strEvaluationBy
 		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell
		, @ysnEvaluationByLocation = ysnEvaluationByLocation 
        , @ysnEvaluationByMarketZone = ysnEvaluationByMarketZone 
        , @ysnEvaluationByOriginPort = ysnEvaluationByOriginPort 
        , @ysnEvaluationByDestinationPort = ysnEvaluationByDestinationPort 
        , @ysnEvaluationByCropYear = ysnEvaluationByCropYear 
        , @ysnEvaluationByStorageLocation = ysnEvaluationByStorageLocation 
        , @ysnEvaluationByStorageUnit = ysnEvaluationByStorageUnit 
 	FROM tblRKCompanyPreference

 	-- Clear temp tables
 	IF OBJECT_ID('tempdb..#tempFacilityInfo') IS NOT NULL
 		DROP TABLE #tempFacilityInfo
 	IF OBJECT_ID('tempdb..#tempTradeLogContracts') IS NOT NULL
 		DROP TABLE #tempTradeLogContracts
 	IF OBJECT_ID('tempdb..#tempPurchaseContracts') IS NOT NULL
 		DROP TABLE #tempPurchaseContracts
 	IF OBJECT_ID('tempdb..#tempPurchaseContractInfo') IS NOT NULL
 		DROP TABLE #tempPurchaseContractInfo
 	IF OBJECT_ID('tempdb..#tempContractCommodity') IS NOT NULL
 		DROP TABLE #tempContractCommodity
 	IF OBJECT_ID('tempdb..#tempCommodity') IS NOT NULL
 		DROP TABLE #tempCommodity
 	IF OBJECT_ID('tempdb..#tempTradeFinanceLog') IS NOT NULL
 		DROP TABLE #tempTradeFinanceLog
 	IF OBJECT_ID('tempdb..#tempLatestLogValues') IS NOT NULL
 		DROP TABLE #tempLatestLogValues
 	IF OBJECT_ID('tempdb..#tempContractBalance') IS NOT NULL
 		DROP TABLE #tempContractBalance
 	IF OBJECT_ID('tempdb..#tempLogisticsLog') IS NOT NULL
 		DROP TABLE #tempLogisticsLog
 	IF OBJECT_ID('tempdb..#tempShipmentDetails') IS NOT NULL
 		DROP TABLE #tempShipmentDetails
 	IF OBJECT_ID('tempdb..#tempTicketInfo') IS NOT NULL
 		DROP TABLE #tempTicketInfo
 	IF OBJECT_ID('tempdb..#tempHedgeInfo') IS NOT NULL
 		DROP TABLE #tempHedgeInfo
 	IF OBJECT_ID('tempdb..#tempReceiptInfo') IS NOT NULL
 		DROP TABLE #tempReceiptInfo
 	IF OBJECT_ID('tempdb..#tempVoucherInfo') IS NOT NULL
 		DROP TABLE #tempVoucherInfo
 	IF OBJECT_ID('tempdb..#tempVoucherInfo2') IS NOT NULL
 		DROP TABLE #tempVoucherInfo2
		
 	--IF OBJECT_ID('tempdb..#tempVoucher') IS NOT NULL
 	--	DROP TABLE #tempVoucher
 	--IF OBJECT_ID('tempdb..#tempVoucherPayment') IS NOT NULL
 	--	DROP TABLE #tempVoucherPayment

 	IF OBJECT_ID('tempdb..#tempContractPair') IS NOT NULL
 		DROP TABLE #tempContractPair
 	IF OBJECT_ID('tempdb..#tempSaleHedgeInfo') IS NOT NULL
 		DROP TABLE #tempSaleHedgeInfo
 	IF OBJECT_ID('tempdb..#tempSaleContractInfo') IS NOT NULL
 		DROP TABLE #tempSaleContractInfo
 	IF OBJECT_ID('tempdb..#tempSaleTicketInfo') IS NOT NULL
 		DROP TABLE #tempSaleTicketInfo
 	IF OBJECT_ID('tempdb..#tempSaleShipmentDetails') IS NOT NULL
 		DROP TABLE #tempSaleShipmentDetails
 	IF OBJECT_ID('tempdb..#tempInvShipmentInfo') IS NOT NULL
 		DROP TABLE #tempInvShipmentInfo
 	IF OBJECT_ID('tempdb..#tempInvoiceInfo') IS NOT NULL
 		DROP TABLE #tempInvoiceInfo
		
	
 	IF OBJECT_ID('tempdb..#tempSettlePrice') IS NOT NULL
 		DROP TABLE #tempSettlePrice
 	IF OBJECT_ID('tempdb..#tempM2MBasisDetail') IS NOT NULL
 		DROP TABLE #tempM2MBasisDetail
 	IF OBJECT_ID('tempdb..#tempContractCost') IS NOT NULL
 		DROP TABLE #tempContractCost
 	IF OBJECT_ID('tempdb..#tempContractSeqHistory') IS NOT NULL
 		DROP TABLE #tempContractSeqHistory

 	-- Start
 	-- Filter by Loan/Limit of selected bank and facility.
 	SELECT DISTINCT 
 		  facility.intBorrowingFacilityId
		, facility.strBorrowingFacilityId
 		, facility.intBankId
 		, bank.strBankName
 		, intFacilityCurrencyId = facility.intPositionCurrencyId
		, dtmExpiration = facility.dtmExpiration
 	INTO #tempFacilityInfo
 	FROM tblCMBorrowingFacility facility
 	LEFT JOIN tblCMBank bank
 		ON	facility.intBankId = bank.intBankId
 	WHERE facility.intBankId = ISNULL(@intBankId, facility.intBankId)
 	AND facility.intBorrowingFacilityId = ISNULL(@intFacilityId, facility.intBorrowingFacilityId)
 	AND facility.intPositionCurrencyId = ISNULL(@intCurrencyId, facility.intPositionCurrencyId)


 	-- Get All Contracts and filter by facility and transaction date
 	SELECT  DISTINCT
 		  intContractHeaderId = tlog.intContractHeaderId
 		, intContractDetailId
		, intContractTypeId = CD.intContractTypeId
 	INTO #tempTradeLogContracts
 	FROM tblTRFTradeFinanceLog tlog
	JOIN tblCTContractHeader CD
		ON CD.intContractHeaderId = tlog.intContractHeaderId
 	JOIN #tempFacilityInfo facility
 		ON tlog.intBorrowingFacilityId = facility.intBorrowingFacilityId
	OUTER APPLY (
		SELECT TOP 1 ysnDeleted = CAST(1 AS BIT)
		FROM tblTRFTradeFinanceLog delTLog
		WHERE tlog.ysnDeleted = 1
		AND CAST(delTLog.dtmCreatedDate AS DATE) >= CAST(ISNULL(@dtmStartDate, delTLog.dtmCreatedDate) AS DATE)
		AND CAST(delTLog.dtmCreatedDate AS DATE) <= CAST(ISNULL(@dtmEndDate, delTLog.dtmCreatedDate) AS DATE)
		AND UPPER(LEFT(strAction, 6)) = 'DELETE'
		AND tlog.strTransactionNumber = delTLog.strTransactionNumber
		AND tlog.intTransactionHeaderId = delTLog.intTransactionHeaderId
		AND tlog.intTransactionDetailId = delTLog.intTransactionDetailId
		AND tlog.strTradeFinanceTransaction = delTLog.strTradeFinanceTransaction
	) deletedRecord
 	WHERE tlog.intContractHeaderId IS NOT NULL 
 	AND tlog.intContractDetailId IS NOT NULL
 	AND CAST(tlog.dtmCreatedDate AS DATE) >= @dtmStartDate
 	AND CAST(tlog.dtmCreatedDate AS DATE) <= @dtmEndDate
	AND ISNULL(deletedRecord.ysnDeleted, 0) = 0

 	-- Get Purchase Contract's Allocated Sale Contract
 	SELECT DISTINCT intPContractDetailId
 		, intSContractDetailId
 	INTO #tempContractPair
 	FROM tblLGAllocationDetail allocation
 	WHERE intPContractDetailId IN (SELECT intContractDetailId FROM #tempTradeLogContracts WHERE intContractTypeId = 1)

 	SELECT  
 		  tlog.intContractHeaderId
 		, tlog.intContractDetailId
 		, dtmCreatedDate
 		, dtmTransactionDate
 		, strAction
 		, strTransactionType
 		, intTransactionHeaderId
 		, intTransactionDetailId
 		, strTransactionNumber
 		, intBankTransactionId
 		, dblTransactionAmountAllocated
 		, dblTransactionAmountActual
 		, intLoanLimitId
 		, strLoanLimitNumber
 		, strLoanLimitType
 		, dtmAppliedToTransactionDate
 		, intWarrantId
		, intLimitId
		, dblLimit
		, strLimit
		, intSublimitId
		, dblSublimit
		, strSublimit
		, strTradeFinanceTransaction
		, intBorrowingFacilityId
		, tlog.intOverrideBankValuationId
		, tlog.strOverrideBankValuation
		, tlog.strBankTradeReference
		, tlog.dblFinanceQty
		, tContract.intContractTypeId
		, intPContractDetailId = CASE WHEN tContract.intContractTypeId = 1 
									THEN tlog.intContractDetailId 
									ELSE saleCTPair.intPContractDetailId END
		, intSContractDetailId = CASE WHEN tContract.intContractTypeId = 2 
									THEN tlog.intContractDetailId 
									ELSE purchaseCTPair.intSContractDetailId END
 	INTO #tempTradeFinanceLog
 	FROM tblTRFTradeFinanceLog tlog
 	JOIN #tempTradeLogContracts tContract
 		ON	tContract.intContractDetailId = tlog.intContractDetailId
 		AND CAST(tlog.dtmCreatedDate AS DATE) >= @dtmStartDate
 		AND CAST(tlog.dtmCreatedDate AS DATE) <= @dtmEndDate
	LEFT JOIN #tempContractPair purchaseCTPair
		ON purchaseCTPair.intPContractDetailId = tlog.intContractDetailId
		AND tContract.intContractTypeId = 1
	LEFT JOIN #tempContractPair saleCTPair
		ON saleCTPair.intSContractDetailId = tlog.intContractDetailId
		AND tContract.intContractTypeId = 2
	OUTER APPLY (
		SELECT TOP 1 ysnDeleted = CAST(1 AS BIT)
		FROM tblTRFTradeFinanceLog delTLog
		WHERE tlog.ysnDeleted = 1
		AND CAST(delTLog.dtmCreatedDate AS DATE) >= CAST(ISNULL(@dtmStartDate, delTLog.dtmCreatedDate) AS DATE)
		AND CAST(delTLog.dtmCreatedDate AS DATE) <= CAST(ISNULL(@dtmEndDate, delTLog.dtmCreatedDate) AS DATE)
		AND UPPER(LEFT(strAction, 6)) = 'DELETE'
		AND tlog.strTransactionNumber = delTLog.strTransactionNumber
		AND tlog.intTransactionHeaderId = delTLog.intTransactionHeaderId
		AND tlog.intTransactionDetailId = delTLog.intTransactionDetailId
		AND tlog.strTradeFinanceTransaction = delTLog.strTradeFinanceTransaction
	) deletedRecord
	WHERE ISNULL(deletedRecord.ysnDeleted, 0) = 0


 	SELECT dtmTransactionDate
 		, intBankTransactionId
 		, dblTransactionAmountAllocated
 		, dblTransactionAmountActual
 		, dtmAppliedToTransactionDate
 		, intWarrantId
 		--, bankLoan.intBankLoanId
 		--, bankLoan.strBankLoanId
 		--, bankLoan.dblLimit
 		--, bankLoan.dblLoanAmount
 		--, bankLoan.strLimitDescription
 		--, bankLoan.strLimitComments
 		--, bankLoan.dblHaircut
 		--, intLoanTypeId = bankLoan.intLimitTypeId
 		--, bankLoan.dtmOpened
 		--, bankLoan.dtmMaturity
 		--, bankLoan.dtmEntered
		, intLimitId
		, strLimit
		, dblLimit
		, intSublimitId
		, strSublimit
		, dblSublimit
		, strTradeFinanceTransaction
		, intBorrowingFacilityId
		, intOverrideBankValuationId
		, strOverrideBankValuation
		, strBankTradeReference
		, dblFinanceQty
		, dtmCreatedDate
		, intPContractDetailId
		, intSContractDetailId
 	INTO #tempLatestLogValues
 	FROM 
 	(
 		SELECT 
 			intRowNum = ROW_NUMBER() OVER (PARTITION BY intPContractDetailId, intSContractDetailId ORDER BY dtmCreatedDate DESC)
 			, *
 		FROM #tempTradeFinanceLog
 	) t
 	--LEFT JOIN tblCMBankLoan bankLoan
 	--	ON bankLoan.intBankLoanId = t.intLoanLimitId
 	WHERE intRowNum = 1


 	-- Get All Contracts filtered by loan/limit, Facility and contract date
 	SELECT intContractHeaderId = ctd.intContractHeaderId
 		, intContractDetailId = ctd.intContractDetailId
 		, intBankId = facility.intBankId
 		, strBankName = facility.strBankName
		, strFacility = facility.strBorrowingFacilityId
 		, dtmOpened = latestLog.dtmAppliedToTransactionDate -- CAST(latestLog.dtmOpened AS datetime)
 		, dtmMaturity = facility.dtmExpiration -- CAST(latestLog.dtmMaturity AS datetime)
 		, dtmEntered = NULL -- CAST(latestLog.dtmEntered AS datetime)
 		, intCommodityId = cth.intCommodityId
 		, intContractTypeId = cth.intContractTypeId
 		, intPurchasePriceCurrencyId = ctd.intCurrencyId 
 		, intPContractItemId = ctd.intItemId
 		--, facility.intBankValuationRuleId
 		--, facility.strBankValuationRule
 		, facility.intFacilityCurrencyId
		, strTradeFinanceTransaction = latestLog.strTradeFinanceTransaction
		, intLimitId = latestLog.intLimitId
		, strLimit = latestLog.strLimit
		, dblLimit = latestLog.dblLimit
		, intSublimitId = latestLog.intSublimitId
		, strSublimit = latestLog.strSublimit
		, dblSublimit = latestLog.dblSublimit 
		, strBankValuationRule = CASE WHEN ISNULL(latestLog.intOverrideBankValuationId, 0) = 0 
										THEN valRule.strBankValuationRule
										ELSE latestLog.strOverrideBankValuation
										END
		, intBankValuationRuleId = CASE WHEN ISNULL(latestLog.intOverrideBankValuationId, 0) = 0 
										THEN valRule.intBankValuationRuleId
										ELSE latestLog.intOverrideBankValuationId
										END 
		, latestLog.strBankTradeReference
		, intUnitMeasureId = ctd.intPriceItemUOMId
		, latestLog.dblFinanceQty
		, dtmTFLogCreateDate = latestLog.dtmCreatedDate
 	INTO #tempPurchaseContracts
 	FROM tblCTContractDetail ctd
 	JOIN tblCTContractHeader cth
 		ON cth.intContractHeaderId = ctd.intContractHeaderId
 	JOIN #tempLatestLogValues latestLog
 		ON latestLog.intPContractDetailId = ctd.intContractDetailId
	LEFT JOIN tblCMBorrowingFacilityLimitDetail sublimit
		ON sublimit.intBorrowingFacilityLimitDetailId = latestLog.intSublimitId
	LEFT JOIN tblCMBankValuationRule valRule
		ON valRule.intBankValuationRuleId = sublimit.intBankValuationRuleId
 	OUTER APPLY (
 		SELECT TOP 1 * 
 		FROM #tempFacilityInfo facInfo
 		WHERE facInfo.intBorrowingFacilityId = latestLog.intBorrowingFacilityId
 	) facility
 	WHERE ctd.intContractDetailId IN (SELECT intContractDetailId FROM #tempTradeLogContracts)
	AND cth.intContractTypeId = 1


 	-- Get Contract Hedge Info
 	SELECT hedgeInfo.intContractDetailId
 		, dblHedgedLots
 		, hedgeInfo.intFutOptTransactionId
 		, fmonth.strFutureMonth
 	INTO #tempHedgeInfo
 	FROM tblRKAssignFuturesToContractSummary hedgeInfo
 	JOIN tblRKFutOptTransaction derivative
 		ON derivative.intFutOptTransactionId = hedgeInfo.intFutOptTransactionId
 	LEFT JOIN tblRKFuturesMonth fmonth
 		ON fmonth.intFutureMonthId = derivative.intFutureMonthId 
 	WHERE hedgeInfo.intContractDetailId IN (SELECT intContractDetailId FROM #tempPurchaseContracts)
 	AND hedgeInfo.ysnIsHedged = 1


 	---- Get only Hedged contracts
 	--DELETE FROM #tempPurchaseContracts
 	--WHERE intContractDetailId NOT IN (SELECT intContractDetailId FROM #tempHedgeInfo)

 	-- Get Purchase Contract Info
 	SELECT 
 		  ctd.intContractHeaderId
 		, ctd.intContractDetailId
 		, tempLogCT.intBankId
		, tempLogCT.strFacility
 		, tempLogCT.strBankName
 		--, tempLogCT.intBankLoanId
 		, strLimit = tempLogCT.strLimit
 		, dblLimitAmount = tempLogCT.dblLimit
 		, strReference = tempLogCT.strTradeFinanceTransaction
 		, strPContractBankRef = tempLogCT.strBankTradeReference
 		, dtmTransactionDate = tempLogCT.dtmOpened
 		, dtmMaturityDate = tempLogCT.dtmMaturity
 		, cth.intCommodityId
 		, commodity.strCommodityCode
 		, ctd.intItemId
 		, strArticle = item.strItemNo
 		, country.strCountry
 		, strBuyFreightTerm = freight.strFreightTerm
 		, strPContractNumber = cth.strContractNumber + '-' + CAST(ctd.intContractSeq AS nvarchar(10))
 		, strSupplier = supplier.strName
 		, strPurchaseTerm = term.strTerm
 		, dblPurchaseBasis = ctd.dblBasis
 		, dblPurchaseDifferential = @dblZero
 		, dblPurchaseFixed = ctd.dblBasis -- Basis + Differential
 		, strPurchaseMarket = fmarket.strFutMarketName
 		, strPurchaseMonth = fmonth.strFutureMonth
 		, dblPurchaseUnitPrice = ISNULL(ctd.dblBasis, 0) + ISNULL(ctd.dblFutures, 0)
 		, intPurchaseCurrencyId = ctd.intCurrencyId
 		, strPurchaseCurrency = currency.strCurrency
 		, dblPurchaseLots = ctd.dblNoOfLots
 		, cth.dtmContractDate
 		, intPFutureMarketId = ctd.intFutureMarketId
 		, intPFutureMonthId = ctd.intFutureMonthId
 		, cth.intContractTypeId
 		, ctd.dtmEndDate
 		, tempLogCT.intBankValuationRuleId
 		, tempLogCT.strBankValuationRule
 		, intFacilityCurrencyId = tempLogCT.intFacilityCurrencyId
		
		, intCompanyLocationId = CASE WHEN @ysnEvaluationByLocation = 0
								THEN NULL
								ELSE ctd.intCompanyLocationId
								END
		, strLocationName = CASE WHEN @ysnEvaluationByLocation = 0
								THEN NULL
								ELSE CL.strLocationName
								END
		, intMarketZoneId = CASE WHEN @ysnEvaluationByMarketZone = 0
									THEN NULL
									ELSE ctd.intMarketZoneId
									END
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
		, dblFinanceQty = tempLogCT.dblFinanceQty
		, dtmTFLogCreateDate = tempLogCT.dtmTFLogCreateDate
 	INTO #tempPurchaseContractInfo 
 	FROM tblCTContractHeader cth
 	JOIN #tempPurchaseContracts tempLogCT
 		ON	cth.intContractHeaderId = tempLogCT.intContractHeaderId
 	JOIN tblCTContractDetail ctd
 		ON	ctd.intContractHeaderId = tempLogCT.intContractHeaderId
 		AND ctd.intContractDetailId = tempLogCT.intContractDetailId
 	LEFT JOIN tblICCommodity commodity
 		ON commodity.intCommodityId = cth.intCommodityId
 	LEFT JOIN tblICItem item
 		ON item.intItemId = ctd.intItemId
 	LEFT JOIN tblSMCurrency currency
 		ON	currency.intCurrencyID = ctd.intCurrencyId 
 	LEFT JOIN tblRKFutureMarket fmarket
 		ON fmarket.intFutureMarketId = ctd.intFutureMarketId
 	LEFT JOIN tblRKFuturesMonth fmonth
 		ON fmonth.intFutureMonthId = ctd.intFutureMonthId
 	LEFT JOIN tblSMCountry country
 		ON country.intCountryID = cth.intCountryId
 	LEFT JOIN tblSMFreightTerms freight
 		ON freight.intFreightTermId = cth.intFreightTermId
 	LEFT JOIN tblEMEntity supplier
 		ON supplier.intEntityId = cth.intEntityId
 	LEFT JOIN tblSMTerm term
 		ON term.intTermID = cth.intTermId
	LEFT JOIN tblSMCompanyLocation CL 
		ON CL.intCompanyLocationId = ctd.intCompanyLocationId
	LEFT JOIN tblARMarketZone MZ 
		ON MZ.intMarketZoneId = ctd.intMarketZoneId
	LEFT JOIN tblSMCity originPort
		ON originPort.intCityId = ctd.intLoadingPortId
	LEFT JOIN tblSMCity destinationPort
		ON destinationPort.intCityId = ctd.intDestinationPortId
	LEFT JOIN tblCTCropYear cropYear
		ON cropYear.intCropYearId = cth.intCropYearId
	LEFT JOIN tblSMCompanyLocationSubLocation storageLocation
		ON storageLocation.intCompanyLocationSubLocationId = ctd.intSubLocationId
	LEFT JOIN tblICStorageLocation storageUnit
		ON storageUnit.intStorageLocationId = ctd.intStorageLocationId
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
			ON LGLoadOrigin.strCity = LGLoad.strDestinationPort
		WHERE	LGLoad.intTransportationMode = 2 -- TRANSPORT MODE = OCEAN VESSEL (2)
		AND		LGLoad.intShipmentType = 1 -- SHIPMENT ONLY
		AND		ISNULL(LD.intSContractDetailId, LD.intPContractDetailId) = ctd.intContractDetailId 
		AND		(LGLoad.dtmDispatchedDate IS NOT NULL OR LGLoad.dtmPostedDate IS NOT NULL) -- LOAD SHIPMENT AFLOAT
		AND		CAST(ISNULL(LGLoad.dtmDispatchedDate, LGLoad.dtmPostedDate) AS DATE) <= @dtmEndDate
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
		WHERE cth.intContractTypeId = 1 -- PURCHASE CONTRACTS ONLY
		AND receiptItem.intContractDetailId = ctd.intContractDetailId
		AND invReceipt.dtmReceiptDate IS NOT NULL
		AND CAST(invReceipt.dtmReceiptDate AS DATE) <= @dtmEndDate
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
		WHERE cth.intContractTypeId = 2 -- SALE CONTRACTS ONLY
		AND invShipment.intLineNo = ctd.intContractDetailId
		AND invShip.dtmShipDate IS NOT NULL
		AND CAST(invShip.dtmShipDate AS DATE) <= @dtmEndDate
		AND shipment.ysnPosted = 1
	) invShipWarehouse

 	WHERE cth.intContractTypeId = 1 -- Purchase
 	AND ctd.intPricingTypeId IN (1, 2, 3) -- Basis, Priced and HTA


 	SELECT * 
 	INTO #tempLogisticsLog
 	FROM
 	(
 		SELECT 
 			intRowNum = ROW_NUMBER() OVER (PARTITION BY tlog.intContractDetailId ORDER BY dtmCreatedDate DESC)
 			, tlog.intContractHeaderId
 			, tlog.intContractDetailId
 			, tlog.intTransactionHeaderId
 			, tlog.intTransactionDetailId
 		FROM #tempTradeFinanceLog tlog 
 		WHERE tlog.strTransactionType = 'Logistics'
 	) t
 	WHERE intRowNum = 1


 	SELECT 
 		  intPContractDetailId
 		, intShipmentStatus
 		, loadView.strShipmentStatus
 		, strFVessel
 		, shipment.strLoadNumber
 		, shipment.dtmDispatchedDate
 		, shipment.dtmDeliveredDate
 		, dblPackingVolume = shipmentDetail.dblQuantity
 		, strPackingType = itemUnitMeasure.strUnitMeasure	
 		, dblQuantityInKg = 
 			CASE WHEN ISNULL(@intKilogramUnitMeasureId, 0) = 0 THEN 0
 			WHEN itemUOM.intUnitMeasureId <> ISNULL(@intKilogramUnitMeasureId, 0) 
 			THEN dbo.fnCTConvertQuantityToTargetItemUOM(shipmentDetail.intItemId, itemUOM.intUnitMeasureId, ISNULL(@intKilogramUnitMeasureId, 0), ISNULL(shipmentDetail.dblQuantity, 0))
 			ELSE shipmentDetail.dblQuantity END 
 	INTO #tempShipmentDetails
 	FROM tblLGLoadDetail shipmentDetail
 	JOIN tblLGLoad shipment
 		ON shipment.intLoadId = shipmentDetail.intLoadId
 	JOIN #tempLogisticsLog logisticsLog
 		ON logisticsLog.intTransactionHeaderId = shipment.intLoadId
 		AND logisticsLog.intTransactionDetailId = shipmentDetail.intLoadDetailId
 	LEFT JOIN tblICItemUOM itemUOM
 		ON itemUOM.intItemUOMId = shipmentDetail.intItemUOMId
 	LEFT JOIN tblICUnitMeasure itemUnitMeasure
 		ON	itemUnitMeasure.intUnitMeasureId = itemUOM.intUnitMeasureId
 	LEFT JOIN vyuLGLoadViewSearch loadView
 		ON loadView.intLoadId = shipmentDetail.intLoadId
 	WHERE shipmentDetail.intPContractDetailId IN (SELECT intContractDetailId FROM #tempPurchaseContracts)
	AND shipment.intShipmentType = 1 -- SHIPMENT
	
 	--SELECT * 
 	--INTO #tempVoucher
 	--FROM
 	--(
 	--	SELECT 
 	--		intRowNum = ROW_NUMBER() OVER (PARTITION BY tlog.intContractDetailId ORDER BY dtmCreatedDate DESC)
 	--		, tlog.intContractHeaderId
 	--		, tlog.intContractDetailId
 	--		, tlog.intTransactionHeaderId
 	--		, tlog.intTransactionDetailId
 	--	FROM #tempTradeFinanceLog tlog 
 	--	WHERE tlog.strTransactionType = 'AP'
 	--	AND tlog.strAction = 'Created Voucher'
 	--) t
 	--WHERE intRowNum = 1
	

 	--SELECT * 
 	--INTO #tempVoucherPayment
 	--FROM
 	--(
 	--	SELECT 
 	--		intRowNum = ROW_NUMBER() OVER (PARTITION BY tlog.intContractDetailId ORDER BY dtmCreatedDate DESC)
 	--		, tlog.intContractHeaderId
 	--		, tlog.intContractDetailId
 	--		, tlog.intTransactionHeaderId
 	--		, tlog.intTransactionDetailId
 	--	FROM #tempTradeFinanceLog tlog 
 	--	WHERE tlog.strTransactionType = 'AP'
 	--	AND tlog.strAction = 'Created AP Payment'
 	--) t
 	--WHERE intRowNum = 1


 	-- Get Purchase Contract Ticket
 	SELECT intContractDetailId = intContractId
 		, strWarehouse = sublocation.strSubLocationName
 		, strLocation = compLocation.strLocationName
 	INTO #tempTicketInfo
 	FROM tblSCTicket ticket
 	LEFT JOIN tblSMCompanyLocationSubLocation sublocation
 		ON	sublocation.intCompanyLocationSubLocationId = ticket.intSubLocationId
 	LEFT JOIN tblSMCompanyLocation compLocation
 		ON compLocation.intCompanyLocationId = ticket.intProcessingLocationId
 	WHERE intContractId IN (SELECT intContractDetailId FROM #tempPurchaseContracts)


 	-- Get Purchase Contract Inventory Receipt
 	SELECT  intContractDetailId
 		, intTicketId = intSourceId
 		, receiptItem.intInventoryReceiptItemId
 		, receipt.intInventoryReceiptId
 	INTO #tempReceiptInfo
 	FROM tblICInventoryReceiptItem receiptItem
 	JOIN tblICInventoryReceipt receipt
 		ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
 	WHERE receiptItem.intContractDetailId IN (SELECT intContractDetailId FROM #tempPurchaseContracts)

	
 	-- Get Purchase Contract Voucher (Via Inventory Receipt)
 	SELECT 
 		  voucher.intInventoryReceiptId
 		, voucher.intInventoryReceiptItemId
 		, voucher.intBillId
 		, strInvoiceNumber = CASE WHEN ISNULL(bill.strVendorOrderNumber, '') = '' THEN NULL ELSE bill.strVendorOrderNumber END
 		, strSupplierVoucherReference = CASE WHEN ISNULL(voucher.strBillId, '') = '' THEN NULL ELSE voucher.strBillId END
 		, dblPurchaseInvoiceAmount = bill.dblTotal --bill.dblTotalController
 		, dtmVoucherDate = bill.dtmDate
 		, dtmVoucherDueDate = bill.dtmDueDate
 		, dblVoucherPaidAmount = bill.dblPayment
 		, dblVoucherBalance = bill.dblAmountDue
 		, bill.intCurrencyId
 	INTO #tempVoucherInfo
 	FROM vyuICGetInventoryReceiptVoucher voucher
 	JOIN tblAPBill bill
 	ON bill.intBillId = voucher.intBillId
	WHERE voucher.intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM #tempReceiptInfo)
	AND voucher.intInventoryReceiptItemId IN (SELECT intInventoryReceiptItemId FROM #tempReceiptInfo)
	
 	-- Get Purchase Contract Voucher (Via Load Shipment)
	SELECT 
		  BD.intContractDetailId
		, bill.intBillId
		, strInvoiceNumber = bill.strVendorOrderNumber
		, strSupplierVoucherReference = bill.strBillId
		, dblPurchaseInvoiceAmount = bill.dblTotal
		, dtmVoucherDate = bill.dtmDate
 		, dtmVoucherDueDate = bill.dtmDueDate
 		, dblVoucherPaidAmount = bill.dblPayment
 		, dblVoucherBalance = bill.dblAmountDue
 		, bill.intCurrencyId
		, bill.strFinanceTradeNo
	INTO #tempVoucherInfo2
	FROM tblAPBillDetail BD
	INNER JOIN tblAPBill bill
		ON bill.intBillId = BD.intBillId
		AND ISNULL(bill.strFinanceTradeNo, '') <> ''
		AND BD.intContractDetailId IN (SELECT intContractDetailId FROM #tempPurchaseContracts)

 	-- Allocated Sale Contract Hedge Info
 	SELECT 
 		  HedgeSummary.intContractDetailId
 		, HedgeSummary.intFutOptTransactionId
 		, HedgeSummary.dblHedgedLots
 		, fmonth.strFutureMonth
 	INTO #tempSaleHedgeInfo
 	FROM tblRKAssignFuturesToContractSummary HedgeSummary
 	LEFT JOIN tblRKFutOptTransaction derivative
 		ON	derivative.intFutOptTransactionId = HedgeSummary.intFutOptTransactionId
 	LEFT JOIN tblRKFuturesMonth fmonth
 		ON fmonth.intFutureMonthId = derivative.intFutureMonthId
 	WHERE HedgeSummary.intContractDetailId IN (SELECT intSContractDetailId FROM #tempContractPair)
 	AND HedgeSummary.ysnIsHedged = 1


 	-- Allocated Sale Contract Info
 	SELECT ctd.intContractHeaderId
 		, ctd.intContractDetailId
 		, cth.intCommodityId
 		, commodity.strCommodityCode
 		, ctd.intItemId
 		, strArticle = item.strItemNo
 		, country.strCountry
 		, strSellFreightTerm = freight.strFreightTerm
 		, strSContractNumber = cth.strContractNumber + '-' + CAST(ctd.intContractSeq AS nvarchar(10))
 		, strCustomer = supplier.strName
 		, strSaleTerm = term.strTerm
 		, dblSaleBasis = ctd.dblBasis
 		, dblSaleDifferential = @dblZero
 		, dblSaleFixed = ctd.dblBasis -- Basis + Differential
 		, strSaleMarket = fmarket.strFutMarketName
 		, strSaleMonth = fmonth.strFutureMonth
 		, dblSaleUnitPrice = ISNULL(ctd.dblBasis, 0) + ISNULL(ctd.dblFutures, 0)
 		, intSaleCurrencyId = ctd.intCurrencyId
 		, strSaleCurrency = currency.strCurrency
 		, dblSaleLots = ctd.dblNoOfLots 
 		, intFutOptTransactionId = saleHedgeInfo.intFutOptTransactionId
 		, cth.intContractTypeId
		, latestLog.dblFinanceQty
		, dtmTFLogCreateDate = latestLog.dtmCreatedDate
 	INTO #tempSaleContractInfo
 	FROM tblCTContractDetail ctd
 	JOIN tblCTContractHeader cth
 		ON cth.intContractHeaderId = ctd.intContractHeaderId
	OUTER APPLY (
		SELECT TOP 1 * 
		FROM #tempSaleHedgeInfo sHedgeInfo
		WHERE sHedgeInfo.intContractDetailId = ctd.intContractDetailId
	) saleHedgeInfo
 	LEFT JOIN tblICCommodity commodity
 		ON commodity.intCommodityId = cth.intCommodityId
 	LEFT JOIN tblICItem item
 		ON item.intItemId = ctd.intItemId
 	LEFT JOIN tblSMCurrency currency
 		ON	currency.intCurrencyID = ctd.intCurrencyId 
 	LEFT JOIN tblRKFutureMarket fmarket
 		ON fmarket.intFutureMarketId = ctd.intFutureMarketId
 	LEFT JOIN tblRKFuturesMonth fmonth
 		ON fmonth.intFutureMonthId = ctd.intFutureMonthId
 	LEFT JOIN tblSMCountry country
 		ON country.intCountryID = cth.intCountryId
 	LEFT JOIN tblSMFreightTerms freight
 		ON freight.intFreightTermId = cth.intFreightTermId
 	LEFT JOIN tblEMEntity supplier
 		ON supplier.intEntityId = cth.intEntityId
 	LEFT JOIN tblSMTerm term
 		ON term.intTermID = cth.intTermId
	LEFT JOIN #tempLatestLogValues latestLog
		ON latestLog.intSContractDetailId = ctd.intContractDetailId
	WHERE ctd.intContractDetailId IN (SELECT intSContractDetailId FROM #tempContractPair)
	AND cth.intContractTypeId = 2 -- SALE CONTRACTS ONLY


 	-- Allocated Sale Contract Ticket Info
 	SELECT 
 		  intTicketId
 		, intContractDetailId = intContractId
 		, strWarehouse = sublocation.strSubLocationName
 		, strLocation = compLocation.strLocationName
 	INTO #tempSaleTicketInfo
 	FROM tblSCTicket ticket
 	LEFT JOIN tblSMCompanyLocationSubLocation sublocation
 		ON	sublocation.intCompanyLocationSubLocationId = ticket.intSubLocationId
 	LEFT JOIN tblSMCompanyLocation compLocation
 		ON compLocation.intCompanyLocationId = ticket.intProcessingLocationId
 	WHERE intContractId IN (SELECT intSContractDetailId FROM #tempContractPair)


 	-- Allocated Sale Contract Load Shipment Info
 	SELECT 
 		  intSContractDetailId
 		, intSaleShipmentStatus = intShipmentStatus
 		, strSaleShipmentStatus = loadView.strShipmentStatus
 		, strSaleFVessel = strFVessel
 		, strSaleLoadNumber = shipment.strLoadNumber
 		, dtmSaleScheduledDate = shipment.dtmScheduledDate
 		, dtmSaleDeliveredDate = shipment.dtmDeliveredDate
 		, dblSalePackingVolume = shipmentDetail.dblQuantity
 		, strSalePackingType = itemUnitMeasure.strUnitMeasure	
 		, dblSaleQuantityInKg = 
 			CASE WHEN ISNULL(@intKilogramUnitMeasureId, 0) = 0 THEN 0
 			WHEN itemUOM.intUnitMeasureId <> ISNULL(@intKilogramUnitMeasureId, 0) 
 			THEN dbo.fnCTConvertQuantityToTargetItemUOM(shipmentDetail.intItemId, itemUOM.intUnitMeasureId, 
 						ISNULL(@intKilogramUnitMeasureId, 0), ISNULL(shipmentDetail.dblQuantity, 0))
 			ELSE shipmentDetail.dblQuantity END 
 	INTO #tempSaleShipmentDetails
 	FROM tblLGLoadDetail shipmentDetail
 	JOIN tblLGLoad shipment
 		ON shipment.intLoadId = shipmentDetail.intLoadId
 	LEFT JOIN tblICItemUOM itemUOM
 		ON itemUOM.intItemUOMId = shipmentDetail.intItemUOMId
 	LEFT JOIN tblICUnitMeasure itemUnitMeasure
 		ON	itemUnitMeasure.intUnitMeasureId = itemUOM.intUnitMeasureId
 	LEFT JOIN vyuLGLoadViewSearch loadView
 		ON loadView.intLoadId = shipmentDetail.intLoadId
 	WHERE shipmentDetail.intSContractDetailId IN (SELECT intSContractDetailId FROM #tempContractPair)
	AND shipment.intShipmentType = 1 -- SHIPMENT

	
 	-- Allocated Sale Contract Inventory Shipment Info
 	SELECT  intContractDetailId
 		, intTicketId = intSourceId
 		, shipmentItem.intInventoryShipmentId
 		, shipmentItem.intInventoryShipmentItemId
 	INTO #tempInvShipmentInfo
 	FROM tblICInventoryShipmentItem shipmentItem
 	JOIN tblICInventoryShipment shipment
 		ON shipment.intInventoryShipmentId = shipmentItem.intInventoryShipmentId
	CROSS APPLY (
		SELECT TOP 1 *
		FROM #tempSaleTicketInfo sTicketInfo
		WHERE sTicketInfo.intTicketId = shipmentItem.intSourceId
	) saleTicketInfo
		
 	-- Allocated Sale Contract Invoice Info
 	SELECT shipmentDetail.intContractDetailId
 		, invoice.strInvoiceNumber
 		, invoice.intCurrencyId
 		, currency.strCurrency
 		, invoice.dblInvoiceTotal
 		, dtmInvoiceDate = invoice.dtmDate
 		, dtmInvoiceDueDate = invoice.dtmDueDate
 	INTO #tempInvoiceInfo
 	FROM tblARInvoiceDetail invoiceDetail
 	JOIN tblARInvoice invoice 
 		ON invoiceDetail.intInvoiceId = invoice.intInvoiceId
 	JOIN #tempInvShipmentInfo shipmentDetail 
 		ON invoiceDetail.intInventoryShipmentItemId = shipmentDetail.intInventoryShipmentItemId
 	JOIN tblSMCurrency currency
 		ON currency.intCurrencyID = invoice.intCurrencyId


 	SELECT DISTINCT intCommodityId
 		, intContractHeaderId
 		, intContractDetailId
 		, intContractTypeId
 	INTO #tempContractCommodity
 	FROM
 	(
 		SELECT intCommodityId
 			, intContractHeaderId
 			, intContractDetailId
 			, intContractTypeId
 		FROM #tempPurchaseContracts

 		UNION ALL
		
 		SELECT intCommodityId
 			, intContractHeaderId
 			, intContractDetailId
 			, intContractTypeId
 		FROM #tempSaleContractInfo
 	) t

 	DECLARE @intCommodityId INT = NULL
 	DECLARE @ContractBalance AS TABLE (
 		  intCommodityId INT
 		, dtmTransactionDate DATETIME
 		, intContractHeaderId INT
 		, intContractDetailId INT
 		, dblBasis DECIMAL(24, 10)
 		, dblFutures DECIMAL(24, 10)
 		, strAction NVARCHAR(100)
 	) 

 	SELECT DISTINCT intCommodityId
 	INTO #tempCommodity
 	FROM #tempContractCommodity


 	-- Get Contract Balance Logs Per Commodity of Contracts.
 	WHILE (SELECT COUNT('') FROM #tempCommodity) > 0
 	BEGIN
 		SELECT TOP 1 @intCommodityId = intCommodityId FROM #tempCommodity
		
 		INSERT INTO @ContractBalance (
 			  intCommodityId
 			, dtmTransactionDate
 			, intContractHeaderId
 			, intContractDetailId
 			, dblBasis
 			, dblFutures
 			, strAction
 		)
 		SELECT intCommodityId
 			, dtmTransactionDate
 			, intContractHeaderId
 			, intContractDetailId
 			, dblBasis
 			, dblFutures
 			, strAction
 		FROM dbo.fnRKGetBucketContractBalance(@dtmEndDate, @intCommodityId, NULL) 
 		WHERE intContractDetailId IN (SELECT intContractDetailId FROM #tempContractCommodity WHERE intCommodityId = @intCommodityId)

 		DELETE FROM #tempCommodity WHERE intCommodityId = @intCommodityId
 	END


 	-- Get Latest Basis and Futures of Purchase and Sale Contract by End Date
 	SELECT 
 	  pContract.intContractHeaderId
 	, pContract.intContractDetailId
 	, ctBalance.dblBasis
 	, ctBalance.dblFutures
 	, pContract.intContractTypeId
 	INTO #tempContractBalance
 	FROM #tempPurchaseContracts pContract
 	OUTER APPLY (
 		SELECT TOP 1 
 			  cb.dblBasis
 			, cb.dblFutures
 		FROM @ContractBalance cb
 		WHERE cb.intContractDetailId = pContract.intContractDetailId
 		ORDER BY cb.dtmTransactionDate DESC
 	) ctBalance

 	INSERT INTO #tempContractBalance (
 		  intContractHeaderId
 		, intContractDetailId
 		, dblBasis
 		, dblFutures
 		, intContractTypeId
 	) 
 	SELECT 
 	  sContract.intContractHeaderId
 	, sContract.intContractDetailId
 	, ctBalance.dblBasis
 	, ctBalance.dblFutures
 	, sContract.intContractTypeId
 	FROM #tempSaleContractInfo sContract
 	OUTER APPLY (
 		SELECT TOP 1 
 			  cb.dblBasis
 			, cb.dblFutures
 		FROM @ContractBalance cb
 		WHERE cb.intContractDetailId = sContract.intContractDetailId
 		ORDER BY cb.dtmTransactionDate DESC
 	) ctBalance
			
 	-- Get Latest Pricing Status
 	SELECT 
 			  pContract.intContractHeaderId
 			, pContract.intContractDetailId
 			, ctSeqHist.ysnPriced
			, pContract.intContractTypeId
			, dblFutures = ISNULL(CASE WHEN ctSeqHist.ysnPartialPrice = 1 
									AND ctSeqHist.intPricingTypeId = 2
								THEN priceFixationDetail.dblFutures
								ELSE ctSeqHist.dblFutures
								END, @dblZero)
			, dblBasis = ISNULL(CASE WHEN ctSeqHist.ysnPartialPrice = 1 
									AND ctSeqHist.intPricingTypeId = 3
								THEN priceFixationDetailForHTA.dblBasis
								ELSE ctSeqHist.dblBasis
								END, @dblZero)
 	INTO #tempContractSeqHistory
 	FROM #tempPurchaseContracts pContract
 	OUTER APPLY (
 		SELECT TOP 1 
 			    ysnPriced = CASE WHEN cb.strPricingStatus = 'Fully Priced' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
			  , ysnPartialPrice = CASE WHEN cb.strPricingStatus = 'Partially Priced' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
			  , cb.dblFutures
			  , cb.dblBasis
			  , cb.intContractDetailId
			  , cb.intPricingTypeId
			  , cb.dblQuantity
 		FROM tblCTSequenceHistory cb
 		WHERE cb.intContractDetailId = pContract.intContractDetailId
		AND CAST(cb.dtmHistoryCreated AS DATE) <= @dtmEndDate
 		ORDER BY cb.dtmHistoryCreated DESC
 	) ctSeqHist
	OUTER APPLY (
		-- Weighted Average Futures Price for Basis (Priced Qty) in Multiple Price Fixations
		SELECT dblFutures = SUM(dblFutures) 
		FROM
		(
			SELECT dblFutures = (pfd.dblFutures) * (pfd.dblQuantity / ctSeqHist.dblQuantity)
			FROM tblCTPriceFixation pfh
			INNER JOIN tblCTPriceFixationDetail pfd
				ON pfh.intPriceFixationId = pfd.intPriceFixationId
				AND pfd.dtmFixationDate <= @dtmEndDate
			WHERE pfh.intContractDetailId = ctSeqHist.intContractDetailId
				AND ctSeqHist.ysnPartialPrice = 1
				AND ctSeqHist.intPricingTypeId = 2 
		) t
	) priceFixationDetail
	OUTER APPLY (
		-- Weighted Average Futures Price for HTA (Priced Qty) in Multiple Price Fixations
		SELECT dblBasis = SUM(dblBasis) 
		FROM
		(
			SELECT dblBasis = (pfd.dblBasis) * (pfd.dblQuantity / ctSeqHist.dblQuantity)
			FROM tblCTPriceFixation pfh
			INNER JOIN tblCTPriceFixationDetail pfd
				ON pfh.intPriceFixationId = pfd.intPriceFixationId
				AND pfd.dtmFixationDate <= @dtmEndDate
			WHERE pfh.intContractDetailId = ctSeqHist.intContractDetailId
				AND ctSeqHist.ysnPartialPrice = 1
				AND ctSeqHist.intPricingTypeId = 3 
		) t
	) priceFixationDetailForHTA

	
 	INSERT INTO #tempContractSeqHistory (
 		  intContractHeaderId
 		, intContractDetailId
 		, ysnPriced
		, intContractTypeId
		, dblFutures
		, dblBasis
 	) 
 	SELECT 
 			  sContract.intContractHeaderId
 			, sContract.intContractDetailId
 			, ctSeqHist.ysnPriced
			, sContract.intContractTypeId
			, dblFutures = ISNULL(CASE WHEN ctSeqHist.ysnPartialPrice = 1 
									AND ctSeqHist.intPricingTypeId = 2
								THEN priceFixationDetail.dblFutures
								ELSE ctSeqHist.dblFutures
								END, @dblZero)
			, dblBasis = ISNULL(CASE WHEN ctSeqHist.ysnPartialPrice = 1 
									AND ctSeqHist.intPricingTypeId = 3
								THEN priceFixationDetailForHTA.dblBasis
								ELSE ctSeqHist.dblBasis
								END, @dblZero)
 	FROM #tempSaleContractInfo sContract
 	OUTER APPLY (
 		SELECT TOP 1 
 			    ysnPriced = CASE WHEN cb.strPricingStatus = 'Fully Priced' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
			  , ysnPartialPrice = CASE WHEN cb.strPricingStatus = 'Partially Priced' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
			  , ch.ysnMultiplePriceFixation
			  , cb.dblFutures
			  , cb.dblBasis
			  , cb.intContractDetailId
			  , cb.intPricingTypeId
			  , cb.dblQuantity
 		FROM tblCTSequenceHistory cb
		LEFT JOIN tblCTContractHeader ch
			ON ch.intContractHeaderId = cb.intContractDetailId
 		WHERE cb.intContractDetailId = sContract.intContractDetailId
		AND CAST(cb.dtmHistoryCreated AS DATE) <= @dtmEndDate
 		ORDER BY cb.dtmHistoryCreated DESC
 	) ctSeqHist
	OUTER APPLY (
		-- Weighted Average Futures Price for Basis (Priced Qty) in Multiple Price Fixations
		SELECT dblFutures = SUM(dblFutures) 
		FROM
		(
			SELECT dblFutures = (pfd.dblFutures) * (pfd.dblQuantity / ctSeqHist.dblQuantity)
			FROM tblCTPriceFixation pfh
			INNER JOIN tblCTPriceFixationDetail pfd
				ON pfh.intPriceFixationId = pfd.intPriceFixationId
				AND pfd.dtmFixationDate <= @dtmEndDate
			WHERE pfh.intContractDetailId = ctSeqHist.intContractDetailId
				AND ctSeqHist.ysnPartialPrice = 1
				AND ctSeqHist.intPricingTypeId = 2 
		) t
	) priceFixationDetail
	OUTER APPLY (
		-- Weighted Average Futures Price for HTA (Priced Qty) in Multiple Price Fixations
		SELECT dblBasis = SUM(dblBasis) 
		FROM
		(
			SELECT dblBasis = (pfd.dblBasis) * (pfd.dblQuantity / ctSeqHist.dblQuantity)
			FROM tblCTPriceFixation pfh
			INNER JOIN tblCTPriceFixationDetail pfd
				ON pfh.intPriceFixationId = pfd.intPriceFixationId
				AND pfd.dtmFixationDate <= @dtmEndDate
			WHERE pfh.intContractDetailId = ctSeqHist.intContractDetailId
				AND ctSeqHist.ysnPartialPrice = 1
				AND ctSeqHist.intPricingTypeId = 3 
		) t
	) priceFixationDetailForHTA

 	-- Get Latest Market Price
 	SELECT *
 	INTO #tempSettlePrice
 	FROM (
 		SELECT dblLastSettle
 			, p.intFutureMarketId
 			, pm.intFutureMonthId
 			, dtmPriceDate
 			, ROW_NUMBER() OVER (PARTITION BY p.intFutureMarketId, pm.intFutureMonthId ORDER BY dtmPriceDate DESC) intRowNum
 		FROM tblRKFuturesSettlementPrice p
 		INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
 		WHERE CAST(dtmPriceDate AS DATE) <= @dtmEndDate
 	) t WHERE intRowNum = 1

	
 	-- Get Latest Market Basis
 	DECLARE @intM2MBasisId INT = NULL

 	SELECT TOP 1 @intM2MBasisId = intM2MBasisId 
 	FROM tblRKM2MBasis 
 	WHERE strPricingType = 'Mark to Market' 
 	AND CAST(dtmM2MBasisDate AS DATE) <= @dtmEndDate
 	ORDER BY dtmM2MBasisDate DESC

 	SELECT dblRatio
 		, dblMarketBasis = (ISNULL(dblBasisOrDiscount, 0) + ISNULL(dblCashOrFuture, 0)) / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END
 		, intMarketBasisUOM = intCommodityUnitMeasureId
 		, intMarketBasisCurrencyId = c.intCurrencyID
 		, strMarketBasisCurrency = c.strCurrency
 		, intFutureMarketId = temp.intFutureMarketId
 		, intFutureMonthId = temp.intFutureMonthId
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
 	INTO #tempM2MBasisDetail
 	FROM tblRKM2MBasisDetail temp
 	LEFT JOIN tblSMCurrency c ON temp.intCurrencyId = c.intCurrencyID
 	JOIN tblICCommodityUnitMeasure cum 
 		ON cum.intCommodityId = temp.intCommodityId 
 		AND temp.intUnitMeasureId = cum.intUnitMeasureId
 	WHERE temp.intM2MBasisId = @intM2MBasisId 


 	-- Get Purchase Contract Cost (Freight)
 	SELECT intContractDetailId
 		, dblCosts = SUM(dblCosts)
 	INTO #tempContractCost
 	FROM ( 
 		SELECT dblCosts = dbo.fnRKGetCurrencyConvertion(CASE WHEN ISNULL(CU.ysnSubCurrency, 0) = 1 THEN CU.intMainCurrencyId ELSE dc.intCurrencyId END, @intCurrencyId, DEFAULT)
 							* (CASE WHEN (M2M.strContractType = 'Both') OR (M2M.strContractType = 'Purchase')
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
 		FROM #tempPurchaseContracts cd
 		INNER JOIN vyuRKM2MContractCost dc ON dc.intContractDetailId = cd.intContractDetailId
 		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
 		INNER JOIN tblRKM2MConfiguration M2M ON dc.intItemId = M2M.intItemId AND ch.intFreightTermId = M2M.intFreightTermId
 		INNER JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = cd.intCommodityId AND cu.intUnitMeasureId = cd.intUnitMeasureId
 		LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = dc.intCurrencyId
 		LEFT JOIN tblICCommodityUnitMeasure cu1 ON cu1.intCommodityId = cd.intCommodityId AND cu1.intUnitMeasureId = dc.intUnitMeasureId
 		GROUP BY cu.intCommodityUnitMeasureId
 			, cu1.intCommodityUnitMeasureId
 			, strAdjustmentType
 			, dc.intContractDetailId
 			, dc.strCostMethod
 			, CU.ysnSubCurrency
 			, CU.intMainCurrencyId
 			, dc.intCurrencyId
 			, M2M.strContractType
 	) t 
 	GROUP BY intContractDetailId


 	-- Facility Limits Report Output
 	SELECT 
 		-- Purchase Columns
 		  intRowNumber = ROW_NUMBER() OVER (PARTITION BY pContract.intContractDetailId ORDER BY pContract.dtmContractDate DESC)
 		, intPContractDetailId = pContract.intContractDetailId
 		, pContract.strBankName
		, pContract.strFacility
 		, pContract.strLimit
 		, dblLimitAmount = ISNULL(pContract.dblLimitAmount, @dblZero)
 		, pContract.strReference
 		, pContract.strPContractBankRef
 		, pContract.dtmTransactionDate
 		, pContract.dtmMaturityDate
 		, pContract.strCommodityCode
 		, pContract.strArticle
 		, strPCountry = pContract.strCountry
 		, pContract.strBuyFreightTerm
 		, pContract.strPContractNumber
 		, pContract.strSupplier
 		, pContract.strPurchaseTerm
 		, dblPurchaseBasis = ISNULL(purchaseCTSeqHist.dblBasis, @dblZero)
 		, dblPurchaseDifferential = ISNULL(pContract.dblPurchaseDifferential, @dblZero)
 		, dblPurchaseFixed = ISNULL((purchaseCTSeqHist.dblBasis + purchaseCTSeqHist.dblFutures), @dblZero)
 		, pContract.strPurchaseMarket
 		, pContract.strPurchaseMonth
 		, dblPurchaseUnitPrice = ISNULL((purchaseCTSeqHist.dblBasis + purchaseCTSeqHist.dblFutures), @dblZero)
 		, pContract.strPurchaseCurrency
 		, dblPurchaseLots = ISNULL(pContract.dblPurchaseLots, @dblZero)
 		, dblPHedgedLots = ISNULL(pHedge.dblHedgedLots, @dblZero)
 		, dblPExposed = ISNULL((ISNULL(pContract.dblPurchaseLots, @dblZero) - ISNULL(pHedge.dblHedgedLots, @dblZero)), @dblZero)
 		, strBuyVessel = pShipment.strFVessel
 		, pShipment.strShipmentStatus
 		, strPLoadNumber = pShipment.strLoadNumber
 		, dtmPDispatchedDate = CONVERT(DATE, pShipment.dtmDispatchedDate)
 		, dtmPDeliveredDate = pShipment.dtmDeliveredDate
 		, dblBuyPackingVolume = ISNULL(pShipment.dblPackingVolume, @dblZero)
 		, strBuyPackingType = pShipment.strPackingType
 		, dblBuyQuantityInKg = ISNULL(pShipment.dblQuantityInKg, @dblZero)
 		, strPDerivativeFutureMonth = pHedge.strFutureMonth
 		, strPLocation = pTicket.strLocation
 		, strPWarehouse = pTicket.strWarehouse
 		, strPInvoiceNumber = ISNULL(pVoucher.strInvoiceNumber, pVoucher2.strInvoiceNumber)
 		, strSupplierVoucherReference = ISNULL(pVoucher.strSupplierVoucherReference, pVoucher2.strSupplierVoucherReference)
 		, dblPurchaseInvoiceAmount = ISNULL(pVoucher.dblPurchaseInvoiceAmount, ISNULL(pVoucher2.dblPurchaseInvoiceAmount, @dblZero))
 		, dtmVoucherDate = ISNULL(pVoucher.dtmVoucherDate, pVoucher2.dtmVoucherDate)
 		, dtmVoucherDueDate = ISNULL(pVoucher.dtmVoucherDueDate, pVoucher2.dtmVoucherDueDate)
 		, dblVoucherPaidAmount = ISNULL(pVoucher.dblVoucherPaidAmount, ISNULL(pVoucher2.dblVoucherPaidAmount, @dblZero))
 		, dblVoucherBalance = CASE WHEN ISNULL(pVoucher.dblVoucherPaidAmount, ISNULL(pVoucher2.dblVoucherPaidAmount, @dblZero)) > 0
 									THEN ISNULL(pVoucher.dblVoucherBalance, ISNULL(pVoucher2.dblVoucherBalance, @dblZero))
 									ELSE ISNULL(pVoucher.dblPurchaseInvoiceAmount, ISNULL(pVoucher2.dblPurchaseInvoiceAmount, @dblZero))
 									END
 		, dblPContractCost = ISNULL(pContractCost.dblCosts, @dblZero)

 		-- Sale Column
 		, sContract.strSContractNumber
 		, sContract.strCustomer
 		, sContract.strSellFreightTerm
 		, strSaleCountry = sContract.strCountry
 		, strSaleInvoiceNumber = sInvoice.strInvoiceNumber
 		, dtmSaleInvoiceDate = sInvoice.dtmInvoiceDate
 		, dblSaleBasis = ISNULL(saleCTSeqHist.dblBasis,@dblZero) --sContract.dblSaleBasis
 		, dblSaleDifferential = ISNULL(sContract.dblSaleDifferential, @dblZero)
 		, dblSaleFixed = ISNULL((saleCTSeqHist.dblBasis + saleCTSeqHist.dblFutures), @dblZero) --sContract.dblSaleFixed
 		, sContract.strSaleMarket
 		, sContract.strSaleMonth
 		, sContract.strSaleCurrency
 		, dblSaleUnitPrice = ISNULL((saleCTSeqHist.dblBasis + saleCTSeqHist.dblFutures), @dblZero) --sContract.dblSaleUnitPrice
 		, strSaleShipmentStatus = sLoadShipment.strSaleShipmentStatus
 		, sLoadShipment.dtmSaleDeliveredDate
 		, strSaleInvoiceCurrency = sInvoice.strCurrency
 		, dblSaleInvoiceTotal = ISNULL(sInvoice.dblInvoiceTotal, @dblZero)
 		, dtmSaleInvoiceDueDate = sInvoice.dtmInvoiceDueDate
 		, dblSaleLots = ISNULL(sContract.dblSaleLots, @dblZero)
 		, dblSaleHedgedLots = ISNULL(sHedge.dblHedgedLots, @dblZero)
 		, dblSaleExposed = ISNULL((ISNULL(sContract.dblSaleLots, @dblZero) - ISNULL(sHedge.dblHedgedLots, @dblZero)), @dblZero)
 		, strSaleHedgeMonth = sHedge.strFutureMonth

 		-- Financing columns
 		, dblSInvoiceAmountInFacilityCurr = ISNULL(sInvoice.dblInvoiceTotal, @dblZero) * dbo.fnRKGetCurrencyConvertion(sInvoice.intCurrencyId, pContract.intFacilityCurrencyId, DEFAULT) -- Convert to Facility Currency
 		, dblPInvoiceAmountInFacilityCurr = ISNULL(pVoucher.dblPurchaseInvoiceAmount, ISNULL(pVoucher2.dblPurchaseInvoiceAmount, @dblZero)) * 
					dbo.fnRKGetCurrencyConvertion(ISNULL(pVoucher.intCurrencyId, pVoucher2.intCurrencyId) , pContract.intFacilityCurrencyId, DEFAULT) -- Convert to Facility Currency

 		-- Valuation columns
 		, dblMarketPrice = CASE WHEN ISNULL(marketBasis.strMarketBasisCurrency, '') = '' THEN @dblZero
 								ELSE ISNULL(marketFutures.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero)
 								END
 		, strMarketCurrency = marketBasis.strMarketBasisCurrency
 		, dblMarketPriceWithHaircut = CASE WHEN ISNULL(marketBasis.strMarketBasisCurrency, '') = '' THEN @dblZero
 						ELSE (ISNULL(marketFutures.dblLastSettle, @dblZero) + 
 							ISNULL(marketBasis.dblMarketBasis, @dblZero)) * 0.9 -- Reduced by 10%
 						END
 		, pContract.strBankValuationRule
		
		---- TESTING COLUMNS: FOR CHECKING BANK VALUATION COMPUTATIONS.
		--, pContract.dblFinanceQty
		--, pContract.intBankValuationRuleId
		--, purchaseCTSeqHist.ysnPriced
		--, secondFutureMonth.intSecondFutureMonthID
		--, dblMarketBasis
		--, firstMonthSettle = marketFutures.dblLastSettle
		--, secondMonthSettle = secondMonthSettlementPrice.dblLastSettle

 		, dblBankValuation = CASE WHEN pContract.dblFinanceQty < 0 
								AND ISNULL(sContract.dblFinanceQty, 0) <> 0 
								AND sContract.dtmTFLogCreateDate >= pContract.dtmTFLogCreateDate
							THEN ABS(sContract.dblFinanceQty) 
							ELSE ABS(pContract.dblFinanceQty) 	
							END * 
							(CASE	WHEN pContract.intBankValuationRuleId = 1 -- BANK VALUATION: Purchase Price
										THEN 
											CASE WHEN purchaseCTSeqHist.ysnPriced = 1 
												THEN  (purchaseCTSeqHist.dblBasis + purchaseCTSeqHist.dblFutures)  -- Purchase Price
												ELSE 
													-- Market Price
													CASE WHEN ISNULL(marketBasis.strMarketBasisCurrency, '') = '' THEN @dblZero
													ELSE ISNULL(marketFutures.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero)
 													END
												END
 									WHEN pContract.intBankValuationRuleId = 2 -- BANK VALUATION: Cost/M2M/Lower of Cost or Market
 										THEN 
 											 CASE WHEN ISNULL(marketBasis.strMarketBasisCurrency, '') = '' THEN @dblZero
											 WHEN purchaseCTSeqHist.ysnPriced = 0
													OR
												(purchaseCTSeqHist.dblBasis + purchaseCTSeqHist.dblFutures) > 
 												(ISNULL(marketFutures.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero))
 												THEN ISNULL(marketFutures.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero) -- Market Price
 												ELSE ISNULL(purchaseCTSeqHist.dblBasis, @dblZero) + ISNULL(purchaseCTSeqHist.dblFutures, @dblZero) -- Purchase Price
 												END
 									WHEN pContract.intBankValuationRuleId = 3 -- BANK VALUATION: Sale Price
 										THEN 
											CASE WHEN saleCTSeqHist.ysnPriced = 1 
												THEN (saleCTSeqHist.dblBasis + saleCTSeqHist.dblFutures) -- Sale Price
												ELSE @dblZero
												END
 									WHEN pContract.intBankValuationRuleId = 4 -- BANK VALUATION: LCM Lower of purchase or M2M unless sale is fixed
 										THEN 
 											CASE WHEN ISNULL(sContract.strSContractNumber, '') = '' OR saleCTSeqHist.ysnPriced <> 1
 												THEN 
													CASE WHEN ISNULL(marketBasis.strMarketBasisCurrency, '') = '' THEN @dblZero
 													WHEN purchaseCTSeqHist.ysnPriced = 0 
														OR ((purchaseCTSeqHist.dblBasis + purchaseCTSeqHist.dblFutures) > 
 															(ISNULL(marketFutures.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero))
														   )
 														THEN ISNULL(marketFutures.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero) -- Market Price
 														ELSE purchaseCTSeqHist.dblBasis + purchaseCTSeqHist.dblFutures -- Purchase Price
 														END
 												ELSE ISNULL(saleCTSeqHist.dblBasis, @dblZero) + ISNULL(saleCTSeqHist.dblFutures, @dblZero) -- Sale Price
 												END
 									WHEN pContract.intBankValuationRuleId = 5 -- BANK VALUATION: M2M
										THEN 
											CASE WHEN ISNULL(marketBasis.strMarketBasisCurrency, '') = '' THEN @dblZero
											ELSE ISNULL(secondMonthSettlementPrice.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero)
 											END
 									ELSE @dblZero
 									END
								)
		, intConcurrencyId = 1

 	FROM #tempPurchaseContractInfo pContract
 	LEFT JOIN #tempShipmentDetails pShipment
 		ON pShipment.intPContractDetailId = pContract.intContractDetailId
 	LEFT JOIN #tempHedgeInfo pHedge
 		ON pHedge.intContractDetailId = pContract.intContractDetailId
 	LEFT JOIN #tempTicketInfo pTicket
 		ON pTicket.intContractDetailId = pContract.intContractDetailId
	OUTER APPLY (
		SELECT TOP 1 *
		FROM #tempReceiptInfo pReceiptInfo
		WHERE pReceiptInfo.intContractDetailId = pContract.intContractDetailId
	) pReceipt
	OUTER APPLY (
		SELECT TOP 1 *
		FROM #tempVoucherInfo pVoucherInfo
		WHERE pVoucherInfo.intInventoryReceiptId = pReceipt.intInventoryReceiptId
 		AND pVoucherInfo.intInventoryReceiptItemId = pReceipt.intInventoryReceiptItemId
	) pVoucher
	OUTER APPLY (
		SELECT TOP 1 *
		FROM #tempVoucherInfo2 pVoucherInfo2
		WHERE pVoucherInfo2.intContractDetailId = pContract.intContractDetailId
		ORDER BY pVoucherInfo2.intBillId DESC
	) pVoucher2
	OUTER APPLY (
		SELECT TOP 1 *
		FROM #tempContractPair ctPair
		WHERE ctPair.intPContractDetailId = pContract.intContractDetailId
	) contractPair
 	LEFT JOIN #tempSaleContractInfo sContract
 		ON sContract.intContractDetailId = contractPair.intSContractDetailId
	OUTER APPLY (
		SELECT TOP 1 * 
		FROM #tempSaleHedgeInfo sHedgeInfo
		WHERE sHedgeInfo.intContractDetailId = sContract.intContractDetailId
	) sHedge
	OUTER APPLY (
		SELECT TOP 1 *
		FROM #tempSaleTicketInfo sTicketInfo
		WHERE sTicketInfo.intContractDetailId = contractPair.intSContractDetailId
	) sTicket
 	LEFT JOIN #tempSaleShipmentDetails sLoadShipment
 		ON sLoadShipment.intSContractDetailId = contractPair.intSContractDetailId
 	LEFT JOIN #tempInvShipmentInfo	sShipment
 		ON sShipment.intContractDetailId = contractPair.intSContractDetailId
 	LEFT JOIN #tempInvoiceInfo sInvoice
 		ON sInvoice.intContractDetailId = contractPair.intSContractDetailId
 	LEFT JOIN #tempContractBalance purchaseCB
 		ON purchaseCB.intContractDetailId = pContract.intContractDetailId
 		AND purchaseCB.intContractTypeId = 1
 	LEFT JOIN #tempContractBalance saleCB
 		ON saleCB.intContractDetailId = sContract.intContractDetailId
 		AND saleCB.intContractTypeId = 2
 	LEFT JOIN #tempContractCost pContractCost
 		ON pContractCost.intContractDetailId = pContract.intContractDetailId
 	LEFT JOIN #tempSettlePrice marketFutures
 		ON marketFutures.intFutureMarketId = pContract.intPFutureMarketId
 		AND marketFutures.intFutureMonthId = pContract.intPFutureMonthId	
 	OUTER APPLY (
 		SELECT TOP 1 dblRatio
 				, dblMarketBasis
 				, intMarketBasisUOM
 				, intMarketBasisCurrencyId
 				, strMarketBasisCurrency
 		FROM #tempM2MBasisDetail tmp
		WHERE ISNULL(tmp.intFutureMarketId,0) = ISNULL(pContract.intPFutureMarketId, ISNULL(tmp.intFutureMarketId,0))	
			AND ISNULL(tmp.intItemId,0) = CASE WHEN @strEvaluationBy = 'Item' 
												THEN ISNULL(pContract.intItemId, 0)
												ELSE ISNULL(tmp.intItemId, 0)
												END
			AND ISNULL(tmp.intContractTypeId, 0) = CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1
																			THEN ISNULL(pContract.intContractTypeId, 0)
																			ELSE ISNULL(tmp.intContractTypeId, 0) END
			AND ISNULL(tmp.intCompanyLocationId, 0) = CASE WHEN @ysnEvaluationByLocation = 1 
																			THEN ISNULL(pContract.intCompanyLocationId, 0)
																			ELSE ISNULL(tmp.intCompanyLocationId, 0) END
			AND ISNULL(tmp.intMarketZoneId, 0) = CASE WHEN @ysnEvaluationByMarketZone = 1 
																			THEN ISNULL(pContract.intMarketZoneId, 0)
																			ELSE ISNULL(tmp.intMarketZoneId, 0) END
			AND ISNULL(tmp.intOriginPortId, 0) = CASE WHEN @ysnEvaluationByOriginPort = 1 
																			THEN ISNULL(pContract.intOriginPortId, 0)
																			ELSE ISNULL(tmp.intOriginPortId, 0) END
			AND ISNULL(tmp.intDestinationPortId, 0) = CASE WHEN @ysnEvaluationByDestinationPort = 1 
																			THEN ISNULL(pContract.intDestinationPortId, 0)
																			ELSE ISNULL(tmp.intDestinationPortId, 0) END
			AND ISNULL(tmp.intCropYearId, 0) = CASE WHEN @ysnEvaluationByCropYear = 1 
																			THEN ISNULL(pContract.intCropYearId, 0)
																			ELSE ISNULL(tmp.intCropYearId, 0) END
			AND ISNULL(tmp.intStorageLocationId, 0) = CASE WHEN @ysnEvaluationByStorageLocation = 1 
																			THEN ISNULL(pContract.intStorageLocationId, 0)
																			ELSE ISNULL(tmp.intStorageLocationId, 0) END
			AND ISNULL(tmp.intStorageUnitId, 0) = CASE WHEN @ysnEvaluationByStorageUnit = 1 
																			THEN ISNULL(pContract.intStorageUnitId, 0)
																			ELSE ISNULL(tmp.intStorageUnitId, 0) END
			AND ISNULL(tmp.strPeriodTo, '') = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
												THEN dbo.fnRKFormatDate(pContract.dtmEndDate, 'MMM yyyy')
												ELSE ISNULL(tmp.strPeriodTo, '')
												END
			AND tmp.strContractInventory = 'Contract' 
 	) marketBasis
	LEFT JOIN #tempContractSeqHistory purchaseCTSeqHist
 		ON purchaseCTSeqHist.intContractDetailId = pContract.intContractDetailId
 		AND purchaseCTSeqHist.intContractTypeId = 1
	LEFT JOIN #tempContractSeqHistory saleCTSeqHist
 		ON saleCTSeqHist.intContractDetailId = sContract.intContractDetailId
 		AND saleCTSeqHist.intContractTypeId = 2
	OUTER APPLY (
		SELECT TOP 1 * 
		FROM
		(
			SELECT
				  intFirstFutureMonthId = intFutureMonthId
				, intSecondFutureMonthID = LEAD(intFutureMonthId) OVER (ORDER BY intYear, strSymbol)
			FROM tblRKFuturesMonth
			WHERE intFutureMarketId = pContract.intPFutureMarketId
		) t 
		WHERE t.intFirstFutureMonthId = pContract.intPFutureMonthId
		
	) secondFutureMonth
	LEFT JOIN #tempSettlePrice secondMonthSettlementPrice
 		ON secondMonthSettlementPrice.intFutureMarketId = pContract.intPFutureMarketId
 		AND secondMonthSettlementPrice.intFutureMonthId = secondFutureMonth.intSecondFutureMonthID

 	DROP TABLE #tempFacilityInfo
 	DROP TABLE #tempTradeLogContracts
 	DROP TABLE #tempPurchaseContracts
 	DROP TABLE #tempPurchaseContractInfo
 	DROP TABLE #tempContractCommodity
 	DROP TABLE #tempTradeFinanceLog
 	DROP TABLE #tempLatestLogValues
 	DROP TABLE #tempContractBalance
 	DROP TABLE #tempCommodity
 	DROP TABLE #tempLogisticsLog
 	DROP TABLE #tempShipmentDetails
 	DROP TABLE #tempTicketInfo
 	DROP TABLE #tempHedgeInfo
 	DROP TABLE #tempReceiptInfo
 	DROP TABLE #tempVoucherInfo
 	DROP TABLE #tempVoucherInfo2
 	--DROP TABLE #tempVoucher
 	--DROP TABLE #tempVoucherPayment

 	DROP TABLE #tempContractPair
 	DROP TABLE #tempSaleHedgeInfo
 	DROP TABLE #tempSaleContractInfo
 	DROP TABLE #tempSaleTicketInfo
 	DROP TABLE #tempSaleShipmentDetails
 	DROP TABLE #tempInvShipmentInfo
 	DROP TABLE #tempInvoiceInfo

 	DROP TABLE #tempSettlePrice
 	DROP TABLE #tempM2MBasisDetail
 	DROP TABLE #tempContractCost
 	DROP TABLE #tempContractSeqHistory

 END TRY

 BEGIN CATCH
 	SET @ErrMsg = ERROR_MESSAGE()
 	SET @ErrMsg = @ErrMsg
 	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
 END CATCH