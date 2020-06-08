CREATE PROCEDURE [dbo].[uspAPLogInventorySubLedger]
	@billIds AS Id READONLY,
	@remove BIT = 0,
	@userId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @remove = 0
BEGIN

	DECLARE @inventorySubLedger SubLedgerReportUdt;
	INSERT INTO @inventorySubLedger
	(
		intItemId
		,strSourceTransactionType
		,dtmDate
		,strInvoiceType
		,strInvoiceNo
		,dblInvoiceAmount
		,dblQty
		,dblNetWeight
		,dblPricePerUOM
		,dblBags
		,dblPricePerBag
		,intItemUOMId
		,intWeightUOMId
		,intPriceUOMId
		,intPurchaseContractId
		,strPurchaseContractNo
		,strContractSequenceNo
		,strFuturesMarket
		,intFuturesMarketId
		,strCounterParty
		,strDestinationPort
		,strLoadShipmentNo
		,strContainerNo
		,strWarehouseName
		,strContainerId
		,strVessel
		,strMarks
		,strFixationStatus
		,strBLNo
		,strOrigin
	)
	SELECT
		intItemId					= BillDetail.intItemId
		,strSourceTransactionType 	= CASE 
										WHEN Bill.intTransactionType = 1 THEN 'Bill'
										ELSE
										'Debit Memo'
										END
		,dtmDate					= Bill.dtmDate
		,strInvoiceType				= 'Final Purchase Invoice'
		,strInvoiceNo				= Bill.strBillId
		,dblInvoiceAmount			= Bill.dblTotal
		,dblQty						= BillDetail.dblQtyReceived
		,dblNetWeight				= BillDetail.dblNetWeight
		,dblPricePerUOM				= BillDetail.dblCost
		,dblBags					= NULL
		,dblPricePerBag				= NULL
		,intItemUOMId				= BillDetail.intUnitOfMeasureId
		,intWeightUOMId				= BillDetail.intWeightUOMId
		,intPriceUOMId				= BillDetail.intCostUOMId
		,intPurchaseContractId		= BillDetail.intContractHeaderId
		,strPurchaseContractNo		= ct.strContractNumber
		,strContractSequenceNo		= ctd.intContractSeq
		,strFuturesMarket			= NULL
		,intFuturesMarketId			= NULL
		,strCounterParty			= NULL
		,strDestinationPort			= NULL
		,strLoadShipmentNo			= lg.strLoadNumber
		,strContainerNo				= lgd.strContainerNumbers
		,strWarehouseName			= NULL
		,strContainerId				= NULL
		,strVessel					= NULL
		,strMarks					= NULL
		,strFixationStatus			= NULL
		,strBLNo					= NULL
		,strOrigin					= NULL
	FROM tblAPBill Bill
	INNER JOIN @billIds ids
		ON ids.intId = Bill.intBillId
	INNER JOIN tblAPBillDetail BillDetail
		ON Bill.intBillId = BillDetail.intBillId
	LEFT JOIN (tblCTContractDetail ctd INNER JOIN tblCTContractHeader ct ON ct.intContractHeaderId = ctd.intContractHeaderId)
		ON ctd.intContractDetailId = BillDetail.intContractDetailId
	LEFT JOIN (tblLGLoadDetail lgd INNER JOIN tblLGLoad lg ON lg.intLoadId = lgd.intLoadId)
		ON lgd.intLoadDetailId = BillDetail.intLoadDetailId
	WHERE Bill.intTransactionType IN (1,3)
		
	EXEC uspICSubLedgerAddReportEntries 
		@SubLedgerReportEntries = @inventorySubLedger
		,@intUserId = @userId

	END
ELSE
BEGIN

	DECLARE @transactionIds SubLedgerTransactionsUdt;
	INSERT INTO @transactionIds
	(
		strSourceTransactionType,
		strSourceTransactionNo
	)
	SELECT
		CASE 
			WHEN Bill.intTransactionType = 1 THEN 'Bill'
		ELSE
			'Debit Memo'
		END,
		Bill.strBillId
	FROM tblAPBill Bill
	INNER JOIN @billIds ids
		ON ids.intId = Bill.intBillId

	EXEC [dbo].[uspICSubLedgerRemoveReportEntries]
		@SubLedgerTransactions = @transactionIds,
		@intUserId = @userId
END