CREATE PROCEDURE [dbo].[uspARLogInventorySubLedger]
	@ysnPost 		BIT,
	@intUserId 		INT,
	@strSessionId	NVARCHAR(50) = NULL
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
	FROM tblARPostInvoiceDetail d
	INNER JOIN tblARPostInvoiceHeader h ON h.intInvoiceId = d.intInvoiceId
	WHERE h.strTransactionType = 'Credit Memo' 
	  AND d.intItemId <> NULL 
	  AND h.strSessionId = @strSessionId
	  AND d.strSessionId = @strSessionId

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
	FROM tblARPostInvoiceHeader h
	WHERE h.strTransactionType = 'Credit Memo'
	  AND h.strSessionId = @strSessionId

	EXEC [dbo].[uspICSubLedgerRemoveReportEntries] @SubLedgerTransactions = @TransactionIds, @intUserId = @intUserId
END