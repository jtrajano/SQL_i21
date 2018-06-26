CREATE PROCEDURE [dbo].[uspTRUpdateCostOnTransportLoad]
	@LoadHeaderId INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

BEGIN TRY
	SELECT intLoadReceiptId 
		, strReceiptLink = strReceiptLine
		, intItemId
	INTO #Receipts
	FROM tblTRLoadReceipt
	WHERE intLoadHeaderId = @LoadHeaderId
		AND strOrigin = 'Location'

	IF EXISTS(SELECT TOP 1 1 FROM #Receipts)
	BEGIN

		--Transfers
		IF EXISTS(SELECT TOP 1 1 FROM tblTRLoadReceipt WHERE intLoadHeaderId = @LoadHeaderId AND ISNULL(intInventoryTransferId, '') != '')
		BEGIN
			SELECT intLoadReceiptId
				,  dblCost = [dbo].[fnICGetTransWeightedAveCost](IT.strTransferNo
					, IT.intInventoryTransferId
					, ITD.intInventoryTransferDetailId
					, CAST(1 AS BIT))
			INTO #tmpTransfers
			FROM tblICInventoryTransfer IT
			LEFT JOIN tblICInventoryTransferDetail ITD ON ITD.intInventoryTransferId = IT.intInventoryTransferId
			LEFT JOIN tblTRLoadReceipt TR ON TR.intInventoryTransferId = IT.intInventoryTransferId AND TR.intLoadReceiptId = ITD.intSourceId
			WHERE IT.ysnPosted = 1
				AND TR.intLoadHeaderId = @LoadHeaderId
				AND TR.strOrigin = 'Location'

			UPDATE tblTRLoadReceipt
			SET dblUnitCost = dblCost
			FROM #tmpTransfers Patch
			WHERE Patch.intLoadReceiptId = tblTRLoadReceipt.intLoadReceiptId

			DROP TABLE #tmpTransfers

		END

		-- Invoices
		SELECT TR.intLoadReceiptId
			, Invoice.strInvoiceNumber
			, LDH.intInvoiceId
			, ID.intInvoiceDetailId
		INTO #tmpInvoices
		FROM tblTRLoadDistributionDetail LDD
		LEFT JOIN tblTRLoadDistributionHeader LDH ON LDH.intLoadDistributionHeaderId = LDD.intLoadDistributionHeaderId
		LEFT JOIN tblARInvoiceDetail ID ON ID.intInvoiceId = LDH.intInvoiceId AND ID.intItemId = LDD.intItemId
		LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = ID.intInvoiceId
		INNER JOIN #Receipts TR ON TR.strReceiptLink = LDD.strReceiptLink AND TR.intItemId = LDD.intItemId
		WHERE ysnBlendedItem = 0
			AND strDestination = 'Customer'
			AND intLoadHeaderId = @LoadHeaderId

		IF EXISTS(SELECT TOP 1 1 FROM #tmpInvoices)
		BEGIN
			SELECT intLoadReceiptId
				, dblCost = [dbo].[fnICGetTransWeightedAveCost](strInvoiceNumber
					, intInvoiceId
					, intInvoiceDetailId
					, CAST(0 AS BIT))
			INTO #tmpInvoiceCost
			FROM #tmpInvoices
			
			UPDATE tblTRLoadReceipt
			SET dblUnitCost = dblCost
			FROM #tmpInvoiceCost Patch
			WHERE Patch.intLoadReceiptId = tblTRLoadReceipt.intLoadReceiptId

			DROP TABLE #tmpInvoiceCost
		END
		DROP TABLE #tmpInvoices
		

		-- Blending
		SELECT intLoadDistributionDetailId, intIngredientItemId, intLoadReceiptId
		INTO #BlendIngredients
		FROM vyuTRGetLoadBlendIngredient Blends
		INNER JOIN #Receipts TR ON TR.strReceiptLink = Blends.strReceiptLink AND TR.intItemId = Blends.intIngredientItemId
		WHERE intLoadDistributionDetailId IN (SELECT intLoadDistributionDetailId FROM tblTRLoadDistributionDetail
											WHERE ysnBlendedItem = 1
												AND intLoadDistributionHeaderId IN (SELECT intLoadDistributionHeaderId
																					FROM tblTRLoadDistributionHeader
																					WHERE intLoadHeaderId = @LoadHeaderId))


		IF EXISTS(SELECT TOP 1 1 FROM #BlendIngredients)
		BEGIN
			SELECT BI.intLoadReceiptId
			, dblCost = [dbo].[fnICGetTransWeightedAveCost](WO.strWorkOrderNo
					, ConsumedLot.intBatchId
					, ConsumedLot.intWorkOrderConsumedLotId
					, CAST(0 AS BIT))
			INTO #tmpBlends
			FROM tblMFWorkOrder WO
			LEFT JOIN tblMFWorkOrderConsumedLot ConsumedLot ON ConsumedLot.intWorkOrderId = WO.intWorkOrderId
			LEFT JOIN #BlendIngredients BI ON BI.intLoadDistributionDetailId = WO.intLoadDistributionDetailId
			WHERE BI.intIngredientItemId = ConsumedLot.intItemId
			
			UPDATE tblTRLoadReceipt
			SET dblUnitCost = dblCost
			FROM #tmpBlends Patch
			WHERE Patch.intLoadReceiptId = tblTRLoadReceipt.intLoadReceiptId

			DROP TABLE #tmpBlends
		END

		DROP TABLE #BlendIngredients
	END
	
	DROP TABLE #Receipts
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH