CREATE PROCEDURE [dbo].[uspTRLogTransactionDetail]
	@TransactionType NVARCHAR(50),
	@TransactionId int
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

	IF (@TransactionType = @TransactionType_TransportLoad)
	BEGIN
		
		INSERT INTO tblTRTransactionDetailLog(
			strTransactionType
			, intTransactionId
			, intTransactionDetailId
			, strSourceType
			, intSourceId
			, dblQuantity
			, intItemId
			, intItemUOMId)
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = @TransactionId
			, intTransactionDetailId = LR.intLoadReceiptId
			, strSourceType = @SourceType_InventoryReceipt
			, intSourceId = LR.intInventoryReceiptId
			, dblQuantity = LR.dblGross
			, intItemId = LR.intItemId
			, intItemUOMId = NULL
		FROM tblTRLoadReceipt LR
			LEFT JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = LR.intLoadHeaderId
			LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = LR.intInventoryReceiptId
		WHERE LH.intLoadHeaderId = @TransactionId
			AND ISNULL(LR.intInventoryReceiptId, '') <> ''

		UNION ALL
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = @TransactionId
			, intTransactionDetailId = LR.intLoadReceiptId
			, strSourceType = @SourceType_InventoryTransfer
			, intSourceId = LR.intInventoryTransferId
			, dblQuantity = LR.dblGross
			, intItemId = LR.intItemId
			, intItemUOMId = NULL
		FROM tblTRLoadReceipt LR
			LEFT JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = LR.intLoadHeaderId
			LEFT JOIN tblICInventoryTransfer IT ON IT.intInventoryTransferId = LR.intInventoryTransferId
		WHERE LH.intLoadHeaderId = @TransactionId
			AND ISNULL(LR.intInventoryTransferId, '') <> ''

		UNION ALL
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = @TransactionId
			, intTransactionDetailId = DH.intLoadDistributionHeaderId
			, strSourceType = @SourceType_Invoice
			, intSourceId = DH.intInvoiceId
			, dblQuantity = 0.00
			, intItemId = NULL
			, intItemUOMId = NULL
		FROM tblTRLoadDistributionHeader DH
			LEFT JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = DH.intLoadHeaderId
			LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = DH.intInvoiceId
		WHERE LH.intLoadHeaderId = @TransactionId
			AND ISNULL(DH.intInvoiceId, '') <> ''

	END

END