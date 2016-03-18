CREATE PROCEDURE [dbo].[uspTRTransportLoadAfterSave]
	@LoadHeaderId INT,
	@ForDelete BIT = 0,
	@UserId INT = NULL

AS

	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET XACT_ABORT ON  
	SET ANSI_WARNINGS OFF  

BEGIN

	DECLARE @TransactionType_TransportLoad NVARCHAR = 'Transport Load'

	DECLARE @SourceType_InventoryReceipt NVARCHAR = 'Inventory Receipt'
	DECLARE @SourceType_InventoryTransfer NVARCHAR = 'Inventory Transfer'
	DECLARE @SourceType_Invoice NVARCHAR = 'Invoice'

	IF (@ForDelete = 1)
	BEGIN
		-- Delete Receipts associated to this deleted Transport Load
		DELETE FROM tblICInventoryReceipt
		WHERE intInventoryReceiptId IN (
			SELECT DISTINCT intSourceId FROM tblTRTransactionDetailLog
			WHERE intTransactionId = @LoadHeaderId
				AND strTransactionType = @TransactionType_TransportLoad
				AND strSourceType = @SourceType_InventoryReceipt)

		-- Delete Transfers associated to this deleted Transport Load
		DELETE FROM tblICInventoryTransfer
		WHERE intInventoryTransferId IN (
			SELECT DISTINCT intSourceId FROM tblTRTransactionDetailLog
			WHERE intTransactionId = @LoadHeaderId
				AND strTransactionType = @TransactionType_TransportLoad
				AND strSourceType = @SourceType_InventoryTransfer)

		-- Delete Invoices associated to this deleted Transport Load
		DELETE FROM tblARInvoice
		WHERE intInvoiceId IN (
			SELECT DISTINCT intSourceId FROM tblTRTransactionDetailLog
			WHERE intTransactionId = @LoadHeaderId
				AND strTransactionType = @TransactionType_TransportLoad
				AND strSourceType = @SourceType_Invoice)

	END
	ELSE
	BEGIN

		-- Create snapshot of Transport Loads before Save
		SELECT strTransactionType
			, intTransactionId
			, intTransactionDetailId
			, strSourceType
			, intSourceId
			, dblQuantity
			, intItemId
			, intItemUOMId
		INTO #tmpPreviousSnapshot
		FROM tblTRTransactionDetailLog
		WHERE intTransactionId = @LoadHeaderId
			AND strTransactionType = @TransactionType_TransportLoad

		-- Check and Delete Deleted Inventory Receipt line items
		DELETE FROM tblICInventoryReceipt
		WHERE intInventoryReceiptId IN (
			SELECT DISTINCT previousSnapshot.intSourceId
			FROM #tmpPreviousSnapshot previousSnapshot
			WHERE
				previousSnapshot.strSourceType = @SourceType_InventoryReceipt
				AND previousSnapshot.intTransactionId IS NOT NULL
				AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInventoryReceiptId
														FROM tblTRLoadReceipt 
														WHERE intLoadHeaderId = @LoadHeaderId
															AND ISNULL(intInventoryReceiptId, '') <> ''))

		-- Check and Delete Deleted Inventory Transfer line items
		DELETE FROM tblICInventoryTransfer
		WHERE intInventoryTransferId IN (
			SELECT DISTINCT previousSnapshot.intSourceId
			FROM #tmpPreviousSnapshot previousSnapshot
			WHERE
				previousSnapshot.strSourceType = @SourceType_InventoryTransfer
				AND previousSnapshot.intTransactionId IS NOT NULL
				AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInventoryTransferId
														FROM tblTRLoadReceipt 
														WHERE intLoadHeaderId = @LoadHeaderId
															AND ISNULL(intInventoryTransferId, '') <> ''))

		-- Check and Delete Deleted Invoice line items
		DELETE FROM tblICInventoryTransfer
		WHERE intInventoryTransferId IN (
			SELECT DISTINCT previousSnapshot.intSourceId
			FROM #tmpPreviousSnapshot previousSnapshot
			WHERE
				previousSnapshot.strSourceType = @SourceType_Invoice
				AND previousSnapshot.intTransactionId IS NOT NULL
				AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInvoiceId
														FROM tblTRDistributionHeader
														WHERE intLoadHeaderId = @LoadHeaderId
															AND ISNULL(intInvoiceId, '') <> ''))

	END




	DELETE FROM tblTRTransactionDetailLog
	WHERE intTransactionId = @LoadHeaderId
		AND strTransactionType = @TransactionType_TransportLoad

END