CREATE PROCEDURE [dbo].[uspSCReverseDestinationWeightGrade]
	@intTicketId INT,
	@intMatchTicketId INT,
	@intUserId INT,
	@strTicketType NVARCHAR(10)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @InventoryReceiptId AS INT; 
DECLARE @ErrMsg NVARCHAR(MAX);
DECLARE @ItemsToIncreaseInTransitDirect AS InTransitTableType
		,@invoiceIntegrationStagingTable AS InvoiceIntegrationStagingTable
		,@success INT
		,@intFreightTermId INT
		,@intShipToId INT
		,@CreatedInvoices NVARCHAR(MAX)
		,@UpdatedInvoices NVARCHAR(MAX)
		,@successfulCount INT
		,@invalidCount INT
		,@batchIdUsed NVARCHAR(100)
		,@recapId INT
		,@recCount INT
		,@intInvoiceId INT
		,@intBillId INT
		,@ysnPosted BIT
		,@strInvoiceNumber AS NVARCHAR(50)
		,@intInventoryShipmentId INT
		,@ysnRecap BIT
		,@intContractDetailId INT
		,@dblContractQty INT
		,@intTicketItemUOMId INT
		,@dblContractAvailableQty NUMERIC(38,20);

BEGIN TRY
	IF @strTicketType = 'Direct'
	BEGIN
		IF ISNULL(@intMatchTicketId, 0) > 0
		BEGIN
			SELECT @intTicketItemUOMId = intItemUOMIdTo
				, @intContractDetailId = intContractId
				, @dblContractQty = dblNetUnits
			FROM tblSCTicket WHERE intTicketId = @intMatchTicketId
		END

		SELECT TOP 1 @intBillId = intBillId FROM tblAPBillDetail WHERE intScaleTicketId = @intMatchTicketId
		SELECT @ysnPosted = ysnPosted  FROM tblAPBill WHERE intBillId = @intBillId
		IF @ysnPosted = 1
		BEGIN
			EXEC [dbo].[uspAPPostBill]
			@post = 0
			,@recap = 0
			,@isBatch = 0
			,@param = @intBillId
			,@userId = @intUserId
			,@success = @success OUTPUT
		END
		IF ISNULL(@intBillId, 0) > 0
			EXEC [dbo].[uspAPDeleteVoucher] @intBillId, @intUserId

		IF ISNULL(@intContractDetailId,0) != 0
		BEGIN
			SELECT @dblContractAvailableQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblContractQty) FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
			SET @dblContractAvailableQty = (@dblContractAvailableQty * -1)
			EXEC uspCTUpdateSequenceBalance @intContractDetailId, @dblContractAvailableQty, @intUserId, @intTicketId, 'Scale'
		END

		SELECT TOP 1 @intInvoiceId = intInvoiceId FROM tblARInvoiceDetail WHERE intTicketId = @intTicketId
		SELECT @ysnPosted = ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId;
		IF @ysnPosted = 1
		BEGIN
			EXEC [dbo].[uspARPostInvoice]
				@batchId			= NULL,
				@post				= 0,
				@recap				= 0,
				@param				= @intInvoiceId,
				@userId				= @intUserId,
				@beginDate			= NULL,
				@endDate			= NULL,
				@beginTransaction	= NULL,
				@endTransaction		= NULL,
				@exclude			= NULL,
				@successfulCount	= @successfulCount OUTPUT,
				@invalidCount		= @invalidCount OUTPUT,
				@success			= @success OUTPUT,
				@batchIdUsed		= @batchIdUsed OUTPUT,
				@recapId			= @recapId OUTPUT,
				@transType			= N'all',
				@accrueLicense		= 0,
				@raiseError			= 1
		END
		IF ISNULL(@intInvoiceId, 0) > 0
		BEGIN
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceId = @intInvoiceId;
			EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @intInvoiceId = intInvoiceId FROM tblARInvoiceDetail WHERE intTicketId = @intTicketId;
		SELECT @ysnPosted = ysnPosted, @strInvoiceNumber = strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId;
		IF @ysnPosted = 1
		BEGIN
			SET @ErrMsg = 'Unpost invoice ' + @strInvoiceNumber + ' before unposting Destination Weight/Grade.';
			RAISERROR(@ErrMsg, 11, 1);
			RETURN;
			-- EXEC [dbo].[uspARPostInvoice]
			-- 	@batchId			= NULL,
			-- 	@post				= 0,
			-- 	@recap				= 0,
			-- 	@param				= @intInvoiceId,
			-- 	@userId				= @intUserId,
			-- 	@beginDate			= NULL,
			-- 	@endDate			= NULL,
			-- 	@beginTransaction	= NULL,
			-- 	@endTransaction		= NULL,
			-- 	@exclude			= NULL,
			-- 	@successfulCount	= @successfulCount OUTPUT,
			-- 	@invalidCount		= @invalidCount OUTPUT,
			-- 	@success			= @success OUTPUT,
			-- 	@batchIdUsed		= @batchIdUsed OUTPUT,
			-- 	@recapId			= @recapId OUTPUT,
			-- 	@transType			= N'all',
			-- 	@accrueLicense		= 0,
			-- 	@raiseError			= 1
		END
		IF ISNULL(@intInvoiceId, 0) > 0
		BEGIN
			---Check if there are multiple IS on the invoice.
			IF (SELECT COUNT(DISTINCT strDocumentNumber)
				FROM tblARInvoiceDetail
				WHERE intInvoiceId = @intInvoiceId) > 1
			BEGIN
				-- Fetch inventory shipment ID
				SELECT TOP 1 @intInventoryShipmentId = ISH.intInventoryShipmentId
				FROM tblICInventoryShipmentItem ISD
				INNER JOIN tblICInventoryShipment ISH
					ON ISH.intInventoryShipmentId = ISD.intInventoryShipmentId
				WHERE ISD.intSourceId = @intTicketId
					AND ISH.intSourceType = 1
				-- Update invoice
				EXEC uspARDeleteInvoice @intInvoiceId, @intUserId, NULL, @intInventoryShipmentId
				EXEC dbo.uspARUpdateInvoiceIntegrations @intInvoiceId, 0, @intUserId
				EXEC dbo.uspARReComputeInvoiceTaxes @intInvoiceId
			END
			ELSE
			BEGIN
				EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
			END
		END
		EXEC dbo.uspSCInsertDestinationInventoryShipment @intTicketId, @intUserId, 0
	END

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