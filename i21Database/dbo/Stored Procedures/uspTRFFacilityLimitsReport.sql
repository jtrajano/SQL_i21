CREATE PROCEDURE [dbo].[uspTRFFacilityLimitsReport]
	  @intBankId INT
	, @intFacilityId INT = NULL
	, @dtmStartDate DATETIME
	, @dtmEndDate DATETIME
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

	-- Format as date only
	SELECT @dtmStartDate = DATEADD(dd, 0, DATEDIFF(dd, 0, @dtmStartDate))
	SELECT @dtmEndDate = DATEADD(dd, 0, DATEDIFF(dd, 0, @dtmEndDate)) 

	-- Company Preference values
	DECLARE @ysnEnterForwardCurveForMarketBasisDifferential BIT
		  , @strEvaluationByZone NVARCHAR(50)
		  , @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell BIT
		
	SELECT TOP 1
		  @ysnEnterForwardCurveForMarketBasisDifferential = ysnEnterForwardCurveForMarketBasisDifferential
		, @strEvaluationByZone = strEvaluationByZone
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell
	FROM tblRKCompanyPreference


	-- Clear temp tables
	IF OBJECT_ID('tempdb..#tempFacilityInfo') IS NOT NULL
		DROP TABLE #tempFacilityInfo
	IF OBJECT_ID('tempdb..#tempTradeLogContracts') IS NOT NULL
		DROP TABLE #tempTradeLogContracts
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
		
	IF OBJECT_ID('tempdb..#tempVoucher') IS NOT NULL
		DROP TABLE #tempVoucher
	IF OBJECT_ID('tempdb..#tempVoucherPayment') IS NOT NULL
		DROP TABLE #tempVoucherPayment

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

	-- Start
	-- Filter by Loan/Limit of selected bank and facility.
	SELECT DISTINCT 
		  facility.intBorrowingFacilityId
		, loanLimits.intBankLoanId
		, facility.intBankId
		, bank.strBankName
		, bankValRule.intBankValuationRuleId
		, bankValRule.strBankValuationRule
		, intFacilityCurrencyId = facility.intPositionCurrencyId
	INTO #tempFacilityInfo
	FROM tblCMBorrowingFacility facility
	JOIN tblCMBorrowingFacilityDetail facilityDetail
		ON facility.intBorrowingFacilityId = facilityDetail.intBorrowingFacilityId
	LEFT JOIN tblCMBank bank
		ON	facility.intBankId = bank.intBankId
	LEFT JOIN tblCMBankLoan loanLimits
		ON facilityDetail.intBankLoanId = loanLimits.intBankLoanId
	LEFT JOIN tblCMBankAccount bankAccount
		ON bankAccount.intBankAccountId = loanLimits.intBankAccountId
	LEFT JOIN tblCMBankValuationRule bankValRule
		ON bankValRule.intBankValuationRuleId = facility.intBankValuationRuleId
	WHERE facility.intBankId = @intBankId 
	AND facility.intBorrowingFacilityId = ISNULL(@intFacilityId, facility.intBorrowingFacilityId)
	AND bankAccount.intCurrencyId = ISNULL(@intCurrencyId, bankAccount.intCurrencyId)


	-- Get All Contracts and filter by loan/limit and transaction date
	SELECT  
		  intContractHeaderId
		, intContractDetailId
	INTO #tempTradeLogContracts
	FROM tblTRFTradeFinanceLog tlog
	JOIN #tempFacilityInfo facility
		ON tlog.intLoanLimitId = facility.intBankLoanId
	WHERE tlog.intContractHeaderId IS NOT NULL 
	AND tlog.intContractDetailId IS NOT NULL
	AND DATEADD(dd, 0, DATEDIFF(dd, 0, tlog.dtmTransactionDate)) >= @dtmStartDate
	AND DATEADD(dd, 0, DATEDIFF(dd, 0, tlog.dtmTransactionDate)) <= @dtmEndDate


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

	INTO #tempTradeFinanceLog
	FROM tblTRFTradeFinanceLog tlog
	JOIN #tempTradeLogContracts tContract
		ON	tContract.intContractDetailId = tlog.intContractDetailId
		AND DATEADD(dd, 0, DATEDIFF(dd, 0, tlog.dtmTransactionDate)) >= @dtmStartDate
		AND DATEADD(dd, 0, DATEDIFF(dd, 0, tlog.dtmTransactionDate)) <= @dtmEndDate

	SELECT intContractHeaderId
		, intContractDetailId
		, dtmTransactionDate
		, intBankTransactionId
		, dblTransactionAmountAllocated
		, dblTransactionAmountActual
		, dtmAppliedToTransactionDate
		, intWarrantId
		, bankLoan.intBankLoanId
		, bankLoan.strBankLoanId
		, bankLoan.dblLimit
		, bankLoan.dblLoanAmount
		, bankLoan.strLimitDescription
		, bankLoan.strLimitComments
		, bankLoan.dblHaircut
		, intLoanTypeId = bankLoan.intLimitTypeId
		, bankLoan.dtmOpened
		, bankLoan.dtmMaturity
		, bankLoan.dtmEntered
	INTO #tempLatestLogValues
	FROM 
	(
		SELECT 
			intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmTransactionDate DESC)
			, *
		FROM #tempTradeFinanceLog
	) t
	LEFT JOIN tblCMBankLoan bankLoan
		ON bankLoan.intBankLoanId = t.intLoanLimitId
	WHERE intRowNum = 1


	-- Get All Contracts filtered by loan/limit, Facility and contract date
	SELECT ctd.intContractHeaderId
		, ctd.intContractDetailId
		, facility.intBankId
		, facility.strBankName
		, latestLog.intBankLoanId
		, latestLog.strBankLoanId
		, dblLimit = latestLog.dblLimit
		, latestLog.strLimitDescription
		, latestLog.strLimitComments
		, latestLog.dblHaircut
		, latestLog.dblLoanAmount
		, latestLog.intLoanTypeId
		, dtmOpened = CAST(latestLog.dtmOpened AS datetime)
		, dtmMaturity = CAST(latestLog.dtmMaturity AS datetime)
		, dtmEntered = CAST(latestLog.dtmEntered AS datetime)
		, cth.intCommodityId
		, cth.intContractTypeId
		, intPurchasePriceCurrencyId = ctd.intCurrencyId 
		, intPContractItemId = ctd.intItemId
		, facility.intBankValuationRuleId
		, facility.strBankValuationRule
		, facility.intFacilityCurrencyId
	INTO #tempPurchaseContracts
	FROM tblCTContractDetail ctd
	JOIN tblCTContractHeader cth
		ON cth.intContractHeaderId = ctd.intContractHeaderId
	JOIN #tempLatestLogValues latestLog
		ON latestLog.intContractDetailId = ctd.intContractDetailId
	OUTER APPLY (
		SELECT TOP 1 * 
		FROM #tempFacilityInfo facInfo
		WHERE facInfo.intBankLoanId = latestLog.intBankLoanId
	) facility
	WHERE ctd.intContractDetailId IN (SELECT intContractDetailId FROM #tempTradeLogContracts)


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


	-- Get only Hedged contracts
	DELETE FROM #tempPurchaseContracts
	WHERE intContractDetailId NOT IN (SELECT intContractDetailId FROM #tempHedgeInfo)


	-- Get Purchase Contract Info
	SELECT 
		  ctd.intContractHeaderId
		, ctd.intContractDetailId
		, tempLogCT.intBankId
		, tempLogCT.strBankName
		, tempLogCT.intBankLoanId
		, strLimit = tempLogCT.strLimitDescription
		, dblLimitAmount = tempLogCT.dblLimit
		, strReference = tempLogCT.strBankLoanId
		, strPContractBankRef = ctd.strBankReferenceNo
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
		, ctd.intCompanyLocationId
		, ctd.dtmEndDate
		, tempLogCT.intBankValuationRuleId
		, tempLogCT.strBankValuationRule
		, intFacilityCurrencyId = tempLogCT.intFacilityCurrencyId
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
	WHERE cth.intContractTypeId = 1 -- Purchase
	AND ctd.intPricingTypeId IN (1, 2, 3) -- Basis, Priced and HTA


	SELECT * 
	INTO #tempLogisticsLog
	FROM
	(
		SELECT 
			intRowNum = ROW_NUMBER() OVER (PARTITION BY tlog.intContractDetailId ORDER BY dtmTransactionDate DESC)
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

	
	SELECT * 
	INTO #tempVoucher
	FROM
	(
		SELECT 
			intRowNum = ROW_NUMBER() OVER (PARTITION BY tlog.intContractDetailId ORDER BY dtmTransactionDate DESC)
			, tlog.intContractHeaderId
			, tlog.intContractDetailId
			, tlog.intTransactionHeaderId
			, tlog.intTransactionDetailId
		FROM #tempTradeFinanceLog tlog 
		WHERE tlog.strTransactionType = 'AP'
		AND tlog.strAction = 'Created Voucher'
	) t
	WHERE intRowNum = 1
	

	SELECT * 
	INTO #tempVoucherPayment
	FROM
	(
		SELECT 
			intRowNum = ROW_NUMBER() OVER (PARTITION BY tlog.intContractDetailId ORDER BY dtmTransactionDate DESC)
			, tlog.intContractHeaderId
			, tlog.intContractDetailId
			, tlog.intTransactionHeaderId
			, tlog.intTransactionDetailId
		FROM #tempTradeFinanceLog tlog 
		WHERE tlog.strTransactionType = 'AP'
		AND tlog.strAction = 'Created AP Payment'
	) t
	WHERE intRowNum = 1


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
		, ysnHasVoucher = CAST(CASE WHEN EXISTS (SELECT TOP 1 '' FROM #tempVoucher tempV WHERE tempV.intContractDetailId = intContractDetailId)
			THEN 1 ELSE 0 END AS BIT)
		, ysnHasVoucherPayment = CAST(CASE WHEN EXISTS (SELECT TOP 1 '' FROM #tempVoucherPayment tempV WHERE tempV.intContractDetailId = intContractDetailId)
			THEN 1 ELSE 0 END AS BIT)
	INTO #tempReceiptInfo
	FROM tblICInventoryReceiptItem receiptItem
	JOIN tblICInventoryReceipt receipt
		ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
	WHERE intContractDetailId IN (SELECT intContractDetailId FROM #tempPurchaseContracts)

	
	-- Get Purchase Contract Voucher
	SELECT 
		  voucher.intInventoryReceiptId
		, voucher.intInventoryReceiptItemId
		, voucher.intBillId
		, strInvoiceNumber = bill.strVendorOrderNumber
		, strSupplierVoucherReference = voucher.strBillId
		, dblPurchaseInvoiceAmount = bill.dblTotalController
		, dtmVoucherDate = bill.dtmDate
		, dtmVoucherDueDate = bill.dtmDueDate
		, dblVoucherPaidAmount = bill.dblPayment
		, dblVoucherBalance = bill.dblAmountDue
		, bill.intCurrencyId
	INTO #tempVoucherInfo
	FROM vyuICGetInventoryReceiptVoucher voucher
	JOIN tblAPBill bill
	ON bill.intBillId = voucher.intBillId
	WHERE voucher.intInventoryReceiptItemId IN (SELECT intInventoryReceiptItemId FROM #tempReceiptInfo WHERE ysnHasVoucher = 1)


	-- Get Purchase Contract's Allocated Sale Contract
	SELECT intPContractDetailId
		, intSContractDetailId
	INTO #tempContractPair
	FROM tblLGAllocationDetail allocation
	WHERE intPContractDetailId IN (SELECT intContractDetailId FROM #tempPurchaseContracts)


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
	INTO #tempSaleContractInfo
	FROM tblCTContractDetail ctd
	JOIN tblCTContractHeader cth
		ON cth.intContractHeaderId = ctd.intContractHeaderId
	JOIN #tempSaleHedgeInfo saleHedgeInfo
		ON saleHedgeInfo.intContractDetailId = ctd.intContractDetailId
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

	
	-- Allocated Sale Contract Inventory Shipment Info
	SELECT  intContractDetailId
		, intTicketId = intSourceId
		, shipmentItem.intInventoryShipmentId
		, shipmentItem.intInventoryShipmentItemId
	INTO #tempInvShipmentInfo
	FROM tblICInventoryShipmentItem shipmentItem
	JOIN tblICInventoryShipment shipment
		ON shipment.intInventoryShipmentId = shipmentItem.intInventoryShipmentId
	JOIN #tempSaleTicketInfo saleTicketInfo
		ON saleTicketInfo.intTicketId = shipmentItem.intSourceId

		
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
		WHERE CONVERT(NVARCHAR, dtmPriceDate, 111) <= CONVERT(NVARCHAR, @dtmEndDate, 111)
	) t WHERE intRowNum = 1

	
	-- Get Latest Market Basis
	DECLARE @intM2MBasisId INT = NULL

	SELECT TOP 1 @intM2MBasisId = intM2MBasisId 
	FROM tblRKM2MBasis 
	WHERE strPricingType = 'Mark to Market' 
	AND CONVERT(NVARCHAR, dtmM2MBasisDate, 111) <= CONVERT(NVARCHAR, @dtmEndDate, 111)
	ORDER BY dtmM2MBasisDate DESC

	SELECT dblRatio
		, dblMarketBasis = (ISNULL(dblBasisOrDiscount, 0) + ISNULL(dblCashOrFuture, 0)) / CASE WHEN c.ysnSubCurrency = 1 THEN 100 ELSE 1 END
		, intMarketBasisUOM = intCommodityUnitMeasureId
		, intMarketBasisCurrencyId = intCurrencyId
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
		SELECT dblCosts = dbo.fnRKGetCurrencyConvertion(CASE WHEN ISNULL(CU.ysnSubCurrency, 0) = 1 THEN CU.intMainCurrencyId ELSE dc.intCurrencyId END, @intCurrencyId)
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
		INNER JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = cd.intCommodityId AND cu.intUnitMeasureId = cd.intPurchasePriceCurrencyId
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
		, dblPurchaseBasis = ISNULL(purchaseCB.dblBasis, @dblZero)
		, dblPurchaseDifferential = ISNULL(pContract.dblPurchaseDifferential, @dblZero)
		, dblPurchaseFixed = ISNULL((purchaseCB.dblBasis + pContract.dblPurchaseDifferential), @dblZero)
		, pContract.strPurchaseMarket
		, pContract.strPurchaseMonth
		, dblPurchaseUnitPrice = ISNULL((purchaseCB.dblBasis + purchaseCB.dblFutures), @dblZero)
		, pContract.strPurchaseCurrency
		, dblPurchaseLots = ISNULL(pContract.dblPurchaseLots, @dblZero)
		, dblPHedgedLots = ISNULL(pHedge.dblHedgedLots, @dblZero)
		, dblPExposed = ISNULL((pContract.dblPurchaseLots - pHedge.dblHedgedLots), @dblZero)
		, strBuyVessel = pShipment.strFVessel
		, pShipment.strShipmentStatus
		, strPLoadNumber = pShipment.strLoadNumber
		, dtmPDispatchedDate = pShipment.dtmDispatchedDate
		, dtmPDeliveredDate = pShipment.dtmDeliveredDate
		, dblBuyPackingVolume = ISNULL(pShipment.dblPackingVolume, @dblZero)
		, strBuyPackingType = pShipment.strPackingType
		, dblBuyQuantityInKg = ISNULL(pShipment.dblQuantityInKg, @dblZero)
		, strPDerivativeFutureMonth = pHedge.strFutureMonth
		, strPLocation = pTicket.strLocation
		, strPWarehouse = pTicket.strWarehouse
		, strPInvoiceNumber = pVoucher.strInvoiceNumber
		, pVoucher.strSupplierVoucherReference
		, dblPurchaseInvoiceAmount = ISNULL(pVoucher.dblPurchaseInvoiceAmount, @dblZero)
		, pVoucher.dtmVoucherDate
		, pVoucher.dtmVoucherDueDate
		, dblVoucherPaidAmount = CASE WHEN pReceipt.ysnHasVoucherPayment = 1 
										THEN ISNULL(pVoucher.dblVoucherPaidAmount, @dblZero)
										ELSE @dblZero END
		, dblVoucherBalance = CASE WHEN pReceipt.ysnHasVoucherPayment = 1 
									THEN ISNULL(pVoucher.dblVoucherBalance, @dblZero)
									ELSE ISNULL(pVoucher.dblPurchaseInvoiceAmount, @dblZero)
									END
		, dblPContractCost = ISNULL(pContractCost.dblCosts, @dblZero)

		-- Sale Column
		, sContract.strSContractNumber
		, sContract.strCustomer
		, sContract.strSellFreightTerm
		, strSaleCountry = sContract.strCountry
		, strSaleInvoiceNumber = sInvoice.strInvoiceNumber
		, dtmSaleInvoiceDate = sInvoice.dtmInvoiceDate
		, dblSaleBasis = ISNULL(saleCB.dblBasis,@dblZero) --sContract.dblSaleBasis
		, dblSaleDifferential = ISNULL(sContract.dblSaleDifferential, @dblZero)
		, dblSaleFixed = ISNULL((saleCB.dblBasis + sContract.dblSaleDifferential), @dblZero) --sContract.dblSaleFixed
		, sContract.strSaleMarket
		, sContract.strSaleMonth
		, sContract.strSaleCurrency
		, dblSaleUnitPrice = ISNULL((saleCB.dblBasis + saleCB.dblFutures), @dblZero) --sContract.dblSaleUnitPrice
		, strSaleShipmentStatus = sLoadShipment.strSaleShipmentStatus
		, sLoadShipment.dtmSaleDeliveredDate
		, strSaleInvoiceCurrency = sInvoice.strCurrency
		, dblSaleInvoiceTotal = ISNULL(sInvoice.dblInvoiceTotal, @dblZero)
		, dtmSaleInvoiceDueDate = sInvoice.dtmInvoiceDueDate
		, dblSaleLots = ISNULL(sContract.dblSaleLots, @dblZero)
		, dblSaleHedgedLots = ISNULL(sHedge.dblHedgedLots, @dblZero)
		, dblSaleExposed = ISNULL((sContract.dblSaleLots - sHedge.dblHedgedLots), @dblZero)
		, strSaleHedgeMonth = sHedge.strFutureMonth

		-- Financing columns
		, dblSInvoiceAmountInFacilityCurr = ISNULL(sInvoice.dblInvoiceTotal, @dblZero) * dbo.fnRKGetCurrencyConvertion(sInvoice.intCurrencyId, pContract.intFacilityCurrencyId) -- Convert to Facility Currency
		, dblPInvoiceAmountInFacilityCurr = ISNULL(pVoucher.dblPurchaseInvoiceAmount, @dblZero) * dbo.fnRKGetCurrencyConvertion(pVoucher.intCurrencyId, pContract.intFacilityCurrencyId) -- Convert to Facility Currency

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
		, dblBankValuation = CASE WHEN pContract.intBankValuationRuleId = 1 THEN purchaseCB.dblBasis + purchaseCB.dblFutures -- Purchase Price
								WHEN pContract.intBankValuationRuleId = 2 
									THEN 
										CASE WHEN (purchaseCB.dblBasis + purchaseCB.dblFutures) > 
											(ISNULL(marketFutures.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero))
											THEN ISNULL(marketFutures.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero) -- Market Price
											ELSE purchaseCB.dblBasis + purchaseCB.dblFutures -- Purchase Price
											END
								WHEN pContract.intBankValuationRuleId = 3
									THEN saleCB.dblBasis + saleCB.dblFutures -- Sale Price
								WHEN pContract.intBankValuationRuleId = 4
									THEN 
										CASE WHEN ISNULL(sContract.strSContractNumber, '') = ''
											THEN 
												CASE WHEN (purchaseCB.dblBasis + purchaseCB.dblFutures) > 
													(ISNULL(marketFutures.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero))
													THEN ISNULL(marketFutures.dblLastSettle, @dblZero) + ISNULL(marketBasis.dblMarketBasis, @dblZero) -- Market Price
													ELSE purchaseCB.dblBasis + purchaseCB.dblFutures -- Purchase Price
													END
											ELSE saleCB.dblBasis + saleCB.dblFutures -- Sale Price
											END
								ELSE @dblZero
								END

	FROM #tempPurchaseContractInfo pContract
	LEFT JOIN #tempShipmentDetails pShipment
		ON pShipment.intPContractDetailId = pContract.intContractDetailId
	LEFT JOIN #tempHedgeInfo pHedge
		ON pHedge.intContractDetailId = pContract.intContractDetailId
	LEFT JOIN #tempTicketInfo pTicket
		ON pTicket.intContractDetailId = pContract.intContractDetailId
	LEFT JOIN #tempReceiptInfo pReceipt
		ON pReceipt.intContractDetailId = pContract.intContractDetailId
	LEFT JOIN #tempVoucherInfo pVoucher
		ON pVoucher.intInventoryReceiptId = pReceipt.intInventoryReceiptId
		AND pVoucher.intInventoryReceiptItemId = pReceipt.intInventoryReceiptItemId
	LEFT JOIN #tempContractPair contractPair
		ON contractPair.intPContractDetailId = pContract.intContractDetailId
	LEFT JOIN #tempSaleContractInfo sContract
		ON sContract.intContractDetailId = contractPair.intSContractDetailId
	LEFT JOIN #tempSaleHedgeInfo sHedge
		ON sHedge.intContractDetailId = sContract.intContractDetailId
	LEFT JOIN #tempSaleTicketInfo sTicket
		ON sTicket.intContractDetailId = sHedge.intContractDetailId
	LEFT JOIN #tempSaleShipmentDetails sLoadShipment
		ON sLoadShipment.intSContractDetailId = sHedge.intContractDetailId
	LEFT JOIN #tempInvShipmentInfo	sShipment
		ON sShipment.intContractDetailId = sHedge.intContractDetailId
	LEFT JOIN #tempInvoiceInfo sInvoice
		ON sInvoice.intContractDetailId = sHedge.intContractDetailId
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
		WHERE ISNULL(tmp.intFutureMarketId, 0) = ISNULL(pContract.intPFutureMarketId, ISNULL(tmp.intFutureMarketId, 0))
			AND ISNULL(tmp.intItemId,0) = ISNULL(pContract.intItemId, ISNULL(tmp.intItemId,0))
			AND ISNULL(tmp.intContractTypeId, pContract.intContractTypeId) = CASE WHEN @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = 1
												THEN CASE WHEN ISNULL(tmp.intContractTypeId, 0) = 0 THEN ISNULL(tmp.intContractTypeId, pContract.intContractTypeId) ELSE pContract.intContractTypeId END
												ELSE ISNULL(tmp.intContractTypeId, pContract.intContractTypeId) END 
			AND ISNULL(tmp.intCompanyLocationId, pContract.intCompanyLocationId) = CASE WHEN @strEvaluationByZone <> 'Company'
																	THEN ISNULL(tmp.intCompanyLocationId, pContract.intCompanyLocationId)
																	ELSE pContract.intCompanyLocationId END
			AND tmp.strPeriodTo = CASE WHEN @ysnEnterForwardCurveForMarketBasisDifferential = 1
											THEN CASE WHEN tmp.strPeriodTo = '' THEN tmp.strPeriodTo ELSE dbo.fnRKFormatDate(pContract.dtmEndDate, 'MMM yyyy') END
										ELSE tmp.strPeriodTo END
			AND tmp.strContractInventory = 'Contract'
	) marketBasis


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
	DROP TABLE #tempVoucher
	DROP TABLE #tempVoucherPayment

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

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH