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
		,@ysnRecap BIT
		,@intContractDetailId INT
		,@dblContractQty NUMERIC(18,6)
		,@intTicketItemUOMId INT
		,@dblContractAvailableQty NUMERIC(38,20);
DECLARE @ysnImposeReversalTransaction BIT
DECLARE @intReversedBillId INT
DECLARE @ysnTicketContractLoadBased BIT
DECLARE @dblTicketMatchScheduleQty NUMERIC(18,6)

BEGIN TRY

	SELECT TOP 1 
		@ysnImposeReversalTransaction  = ysnImposeReversalTransaction 
	FROM tblRKCompanyPreference

	SET	@ysnImposeReversalTransaction = ISNULL(@ysnImposeReversalTransaction,0)

	IF @strTicketType = 'Direct'
	BEGIN
		
		IF ISNULL(@intMatchTicketId, 0) > 0
		BEGIN
			SELECT @intTicketItemUOMId = intItemUOMIdTo
				, @intContractDetailId = intContractId
				, @dblContractQty = dblNetUnits
				, @dblTicketMatchScheduleQty = dblScheduleQty
			FROM tblSCTicket WHERE intTicketId = @intMatchTicketId
				AND ysnReversed = 0
		END

		IF(@ysnImposeReversalTransaction = 0)
		BEGIN
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
				EXEC [dbo].[uspAPDeleteVoucher] @intBillId, @intUserId, 2

		IF ISNULL(@intContractDetailId,0) != 0
		BEGIN
			SELECT TOP 1 @ysnTicketContractLoadBased = ISNULl(A.ysnLoad,0)
			FROM tblCTContractHeader A
			INNER JOIN tblCTContractDetail B	
				ON A.intContractHeaderId = B.intContractHeaderId
			WHERE B.intContractDetailId = @intContractDetailId

			SELECT @dblContractAvailableQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblContractQty) FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

			IF(@ysnTicketContractLoadBased = 1)
			BEGIN
				SET @dblContractAvailableQty = 1
			END

			SET @dblContractAvailableQty = (@dblContractAvailableQty * -1)
			EXEC uspCTUpdateSequenceBalance @intContractDetailId, @dblContractAvailableQty, @intUserId, @intMatchTicketId, 'Scale'
			IF(ISNULL(@dblTicketMatchScheduleQty,0) <> 0)
			BEGIN
				EXEC uspCTUpdateScheduleQuantity
											@intContractDetailId	=	@intContractDetailId,
											@dblQuantityToUpdate	=	@dblTicketMatchScheduleQty,
											@intUserId				=	@intUserId,
											@intExternalId			=	@intMatchTicketId,
											@strScreenName			=	'Scale'	
			END
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
		---------------REversal Process
		BEGIN

			--Reverse voucher of match ticket
			EXEC uspSCReverseInventoryReceiptVoucher @intMatchTicketId, @intUserId

			
			IF ISNULL(@intContractDetailId,0) != 0
			BEGIN
				SELECT @dblContractAvailableQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblContractQty) FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
				SET @dblContractAvailableQty = (@dblContractAvailableQty * -1)

				EXEC uspCTUpdateSequenceBalance @intContractDetailId, @dblContractAvailableQty, @intUserId, @intTicketId, 'Scale'
				EXEC uspCTUpdateScheduleQuantity
									@intContractDetailId	=	@intContractDetailId,
									@dblQuantityToUpdate	=	@dblContractAvailableQty,
									@intUserId				=	@intUserId,
									@intExternalId			=	@intTicketId,
									@strScreenName			=	'Scale'	

			END

			--Reverse Invoice
			EXEC uspSCReverseInventoryShipmentInvoice @intTicketId,@intUserId
		
		END
	END
	ELSE
	BEGIN
		IF(@ysnImposeReversalTransaction = 0)
		BEGIN
			SELECT TOP 1 @intInvoiceId = intInvoiceId FROM tblARInvoiceDetail WHERE intTicketId = @intTicketId;
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
				EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
		END
		ELSE
		BEGIN
			--Reverse Invoice
			EXEC uspSCReverseInventoryShipmentInvoice @intTicketId,@intUserId
		END

		EXEC dbo.uspSCInsertDestinationInventoryShipment @intTicketId, @intUserId, 0
	END


	EXEC dbo.uspSMAuditLog 
			@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
			,@screenName		= 'Grain.view.Scale'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Unposted'				-- Action Type
			,@changeDescription	= ''						-- Description
			,@fromValue			= ''						-- Old Value
			,@toValue			= ''						-- New Value
			,@details			= '';

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
