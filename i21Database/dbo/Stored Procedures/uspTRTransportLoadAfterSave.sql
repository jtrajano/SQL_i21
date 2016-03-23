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

	DECLARE @TransactionType_TransportLoad NVARCHAR(50) = 'Transport Load'

	DECLARE @SourceType_InventoryReceipt NVARCHAR(50) = 'Inventory Receipt'
	DECLARE @SourceType_InventoryTransfer NVARCHAR(50) = 'Inventory Transfer'
	DECLARE @SourceType_Invoice NVARCHAR(50) = 'Invoice'

	DECLARE @tblToProcess TABLE
			(
				intKeyId				INT IDENTITY,
				intTransactionId		INT,
				strTransactionType		NVARCHAR(50)
			)

	IF (@ForDelete = 1)
	BEGIN

		-- Delete Receipts associated to this deleted Transport Load
		INSERT INTO @tblToProcess(intTransactionId, strTransactionType)

		SELECT DISTINCT intSourceId, @SourceType_InventoryReceipt FROM tblTRTransactionDetailLog
		WHERE intTransactionId = @LoadHeaderId
			AND strTransactionType = @TransactionType_TransportLoad
			AND strSourceType = @SourceType_InventoryReceipt

		UNION ALL

		-- Delete Transfers associated to this deleted Transport Load
		SELECT DISTINCT intSourceId, @SourceType_InventoryTransfer FROM tblTRTransactionDetailLog
		WHERE intTransactionId = @LoadHeaderId
			AND strTransactionType = @TransactionType_TransportLoad
			AND strSourceType = @SourceType_InventoryTransfer

		UNION ALL
		-- Delete Invoices associated to this deleted Transport Load
		SELECT DISTINCT intSourceId, @SourceType_Invoice FROM tblTRTransactionDetailLog
		WHERE intTransactionId = @LoadHeaderId
			AND strTransactionType = @TransactionType_TransportLoad
			AND strSourceType = @SourceType_Invoice
			
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
		INSERT INTO @tblToProcess(intTransactionId, strTransactionType)

		SELECT DISTINCT previousSnapshot.intSourceId
			, @SourceType_InventoryReceipt
		FROM #tmpPreviousSnapshot previousSnapshot
		WHERE
			previousSnapshot.strSourceType = @SourceType_InventoryReceipt
			AND previousSnapshot.intTransactionId IS NOT NULL
			AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInventoryReceiptId
													FROM tblTRLoadReceipt 
													WHERE intLoadHeaderId = @LoadHeaderId
														AND ISNULL(intInventoryReceiptId, '') <> '')

		UNION ALL

		-- Check and Delete Deleted Inventory Transfer line items
		SELECT DISTINCT previousSnapshot.intSourceId
			, @SourceType_InventoryTransfer
		FROM #tmpPreviousSnapshot previousSnapshot
		WHERE
			previousSnapshot.strSourceType = @SourceType_InventoryTransfer
			AND previousSnapshot.intTransactionId IS NOT NULL
			AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInventoryTransferId
													FROM tblTRLoadReceipt 
													WHERE intLoadHeaderId = @LoadHeaderId
														AND ISNULL(intInventoryTransferId, '') <> '')

		UNION ALL

		-- Check and Delete Deleted Invoice line items
		SELECT DISTINCT previousSnapshot.intSourceId
			, @SourceType_Invoice
		FROM #tmpPreviousSnapshot previousSnapshot
		WHERE
			previousSnapshot.strSourceType = @SourceType_Invoice
			AND previousSnapshot.intTransactionId IS NOT NULL
			AND previousSnapshot.intSourceId NOT IN (SELECT DISTINCT intInvoiceId
													FROM tblTRLoadDistributionHeader
													WHERE intLoadHeaderId = @LoadHeaderId
														AND ISNULL(intInvoiceId, '') <> '')
		
	END

	-- Iterate and process records
	DECLARE @Id					INT = NULL,
			@intTransactionId	INT = NULL,
			@strTransactionType NVARCHAR(50)

	WHILE EXISTS(SELECT TOP 1 1 FROM @tblToProcess)
	BEGIN
		SELECT TOP 1 
			@Id		=	intKeyId,
			@intTransactionId =	intTransactionId,
			@strTransactionType = strTransactionType
		FROM	@tblToProcess 

		IF (@strTransactionType = @SourceType_InventoryReceipt)
		BEGIN
			EXEC uspICDeleteInventoryReceipt @intTransactionId, @UserId
		END
		ELSE IF (@strTransactionType = @SourceType_InventoryTransfer)
		BEGIN
			EXEC uspICDeleteInventoryTransfer @intTransactionId, @UserId
		END
		ELSE IF (@strTransactionType = @SourceType_Invoice)
		BEGIN
			UPDATE tblTRLoadDistributionHeader
			SET intInvoiceId = NULL
			WHERE intInvoiceId = @intTransactionId

			EXEC uspARDeleteInvoice @intTransactionId, @UserId
		END

		DELETE FROM @tblToProcess WHERE intKeyId = @Id
	END

	DELETE FROM tblTRTransactionDetailLog
	WHERE intTransactionId = @LoadHeaderId
		AND strTransactionType = @TransactionType_TransportLoad

	UPDATE tblLGLoad
	SET intLoadHeaderId = NULL
	WHERE intLoadHeaderId = @LoadHeaderId

END