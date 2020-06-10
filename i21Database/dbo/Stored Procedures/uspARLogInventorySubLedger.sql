CREATE PROCEDURE [dbo].[uspARLogInventorySubLedger]
	@ysnPost BIT,
	@intUserId INT
AS
DECLARE @InventorySubLedger SubLedgerReportUdt
IF @ysnPost = 1
BEGIN
	INSERT INTO @InventorySubLedger
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
		,intItemUOMId
		,intWeightUOMId
		,intPurchaseContractId
	)
	SELECT
		  d.intItemId
		, h.strTransactionType
		, h.dtmDate
		, 'Credit Memo'
		, h.strInvoiceNumber
		, d.dblInvoiceTotal
		, d.dblQtyShipped
		, d.dblShipmentNetWt
		, d.dblPrice
		, d.intItemUOMId
		, d.intItemWeightUOMId
		, d.intContractHeaderId
	FROM #ARPostInvoiceDetail d
		INNER JOIN #ARPostInvoiceHeader h ON h.intInvoiceId = d.intInvoiceId
	WHERE h.strTransactionType = 'Credit Memo'

	EXEC uspICSubLedgerAddReportEntries @SubLedgerReportEntries = @InventorySubLedger, @intUserId = @intUserId
END
ELSE
BEGIN
	DECLARE @TransactionIds SubLedgerTransactionsUdt;
	INSERT INTO @TransactionIds
	(
		strSourceTransactionType,
		strSourceTransactionNo
	)
	SELECT h.strTransactionType, h.strInvoiceNumber
	FROM #ARPostInvoiceHeader h
	WHERE h.strTransactionType = 'Credit Memo'

	EXEC [dbo].[uspICSubLedgerRemoveReportEntries] @SubLedgerTransactions = @TransactionIds, @intUserId = @intUserId
END