CREATE PROCEDURE [dbo].[uspTRLogTransactionDetail]
	@TransactionType NVARCHAR(50),
	@TransactionId INT,
	@UserId INT,
	@ForDelete BIT = 0
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
			AND LR.strOrigin = 'Terminal'
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
			LEFT JOIN tblTRLoadDistributionHeader DH ON LH.intLoadHeaderId = DH.intLoadHeaderId		
			LEFT JOIN tblTRLoadDistributionDetail DD ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
		WHERE LH.intLoadHeaderId = @TransactionId
			AND ((LR.strOrigin = 'Location' AND DH.strDestination = 'Location') 
				OR (LR.strOrigin = 'Terminal' AND DH.strDestination = 'Location' AND LR.intCompanyLocationId != DH.intCompanyLocationId)
				OR (LR.strOrigin = 'Location' AND DH.strDestination = 'Customer' AND LR.intCompanyLocationId != DH.intCompanyLocationId)
				OR (LR.strOrigin = 'Terminal' AND DH.strDestination = 'Customer' AND LR.intCompanyLocationId != DH.intCompanyLocationId AND (ISNULL(LR.dblUnitCost, 0) <> 0 OR ISNULL(LR.dblFreightRate, 0) <> 0 OR ISNULL(LR.dblPurSurcharge, 0) <> 0)))
		UNION ALL
		SELECT strTransactionType = @TransactionType_TransportLoad
			, intTransactionId = DH.intLoadHeaderId
			, intTransactionDetailId = DD.intLoadDistributionDetailId
			, strSourceType = @SourceType_Invoice
			, intSourceId = DH.intInvoiceId
			, dblQuantity = DD.dblUnits
			, intItemId = NULL
			, intItemUOMId = NULL
			, DD.intContractDetailId
		FROM tblTRLoadDistributionHeader DH
			LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
		WHERE DH.intLoadHeaderId = @TransactionId
			AND DH.strDestination = 'Customer'
			AND ISNULL(DD.intLoadDistributionDetailId, '') <> ''

		IF (@ForDelete = 1)
		BEGIN

			UPDATE tblLGLoad
			SET intLoadHeaderId = NULL
				, ysnInProgress = 0
				, intConcurrencyId	= intConcurrencyId + 1
			WHERE intLoadHeaderId = @TransactionId
			
			UPDATE tblTRLoadDistributionHeader
			SET intInvoiceId = NULL
			WHERE intLoadHeaderId = @TransactionId

			UPDATE tblARInvoice
			SET intLoadDistributionHeaderId = NULL
			WHERE intLoadDistributionHeaderId IN (SELECT DISTINCT intLoadDistributionHeaderId 
												FROM tblTRLoadDistributionHeader
												WHERE intLoadHeaderId = @TransactionId)

			--EXEC uspTRLoadProcessContracts @TransactionId, 'Delete', @UserId
			EXEC uspTRLoadProcessLogisticsLoad @TransactionId, 'Delete', @UserId
		END
	END

END