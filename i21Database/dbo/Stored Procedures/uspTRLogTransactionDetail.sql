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

	DECLARE @TransactionType_TransportLoad NVARCHAR(50) = 'Transport Load'

	DECLARE @SourceType_InventoryReceipt NVARCHAR(50) = 'Inventory Receipt'
	DECLARE @SourceType_InventoryTransfer NVARCHAR(50) = 'Inventory Transfer'
	DECLARE @SourceType_Invoice NVARCHAR(50) = 'Invoice'

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
			, intItemUOMId
			, intContractDetailId)
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = LR.intLoadHeaderId
			, intTransactionDetailId = LR.intLoadReceiptId
			, strSourceType = @SourceType_InventoryReceipt
			, intSourceId = LR.intInventoryReceiptId
			, dblQuantity = CASE WHEN (SP.strGrossOrNet = 'Gross') THEN LR.dblGross ELSE LR.dblNet END
			, intItemId = LR.intItemId
			, intItemUOMId = NULL
			, LR.intContractDetailId
		FROM tblTRLoadReceipt LR
			LEFT JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = LR.intLoadHeaderId
			LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = LR.intInventoryReceiptId
			LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = LR.intSupplyPointId
		WHERE LH.intLoadHeaderId = @TransactionId
			AND ISNULL(LR.intInventoryReceiptId, '') <> ''
		UNION ALL
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = LR.intLoadHeaderId
			, intTransactionDetailId = LR.intLoadReceiptId
			, strSourceType = @SourceType_InventoryTransfer
			, intSourceId = LR.intInventoryTransferId
			, dblQuantity = CASE WHEN (SP.strGrossOrNet = 'Gross') THEN LR.dblGross ELSE LR.dblNet END
			, intItemId = LR.intItemId
			, intItemUOMId = NULL
			, LR.intContractDetailId
		FROM tblTRLoadReceipt LR
			LEFT JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = LR.intLoadHeaderId
			LEFT JOIN tblICInventoryTransfer IT ON IT.intInventoryTransferId = LR.intInventoryTransferId
			LEFT JOIN tblTRSupplyPoint SP ON SP.intSupplyPointId = LR.intSupplyPointId
		WHERE LH.intLoadHeaderId = @TransactionId
			AND ISNULL(LR.intInventoryTransferId, '') <> ''
		UNION ALL
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = DH.intLoadHeaderId
			, intTransactionDetailId = DH.intLoadDistributionHeaderId
			, strSourceType = @SourceType_Invoice
			, intSourceId = DH.intInvoiceId
			, dblQuantity = DD.dblUnits
			, intItemId = NULL
			, intItemUOMId = NULL
			, DD.intContractDetailId
		FROM tblTRLoadDistributionHeader DH
			LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
		WHERE DH.intLoadHeaderId = @TransactionId
			AND ISNULL(DH.intInvoiceId, '') <> ''

	END

END