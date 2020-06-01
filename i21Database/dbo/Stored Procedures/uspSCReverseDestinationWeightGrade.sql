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
DECLARE @ysnTicketContractLoadBased BIT
DECLARE @ysnContractLoadBased BIT
DECLARE @intMatchTicketContractDetailId INT
DECLARE @strTicketWeightFinalizedWhere NVARCHAR(20)
DECLARE @strTicketGradeFinalizedWhere NVARCHAR(20)
DECLARE @intMatchTicketStorageScheduleTypeId AS INT
DECLARE @dblMatchTicketScheduleQty NUMERIC(38,20)
DECLARE @intMatchTicketItemUOMIdTo INT
DECLARE @dblMatchTicketNetUnits NUMERIC(38,20)
DECLARE @dblUnits NUMERIC(38,20)
DECLARE @ysnImposeReversalTransaction BIT
DECLARE @intReversedBillId INT

BEGIN TRY

	SELECT TOP 1 
		@ysnImposeReversalTransaction  = ysnImposeReversalTransaction 
	FROM tblRKCompanyPreference

	SET	@ysnImposeReversalTransaction = ISNULL(@ysnImposeReversalTransaction,0)

	IF @strTicketType = 'Direct'
	BEGIN
		IF ISNULL(@intMatchTicketId, 0) > 0
		BEGIN
			SELECT @intTicketItemUOMId = SC.intItemUOMIdTo
				, @intContractDetailId = SC.intContractId
				, @dblContractQty = SC.dblNetUnits
				, @intMatchTicketContractDetailId = SC.intContractId
				, @intMatchTicketStorageScheduleTypeId = SC.intStorageScheduleTypeId
				,@strTicketWeightFinalizedWhere = CTWeight.strWhereFinalized
				,@strTicketGradeFinalizedWhere = CTGrade.strWhereFinalized
				, @dblMatchTicketScheduleQty = ISNULL(SC.dblScheduleQty,0)
				,@dblMatchTicketNetUnits = SC.dblNetUnits
			FROM tblSCTicket SC
			LEFT JOIN tblCTWeightGrade CTGrade 
				ON CTGrade.intWeightGradeId = SC.intGradeId
			LEFT JOIN tblCTWeightGrade CTWeight 
				ON CTWeight.intWeightGradeId = SC.intWeightId
			WHERE intTicketId = @intMatchTicketId
				AND ysnReversed = 0

			IF(@ysnImposeReversalTransaction = 0)
			BEGIN
		
				IF(ISNULL(@strTicketWeightFinalizedWhere,'Origin') = 'Destination' OR ISNULL(@strTicketGradeFinalizedWhere,'Origin') = 'Destination')
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
						EXEC [dbo].[uspAPDeleteVoucher] @intBillId, @intUserId


					IF ISNULL(@intMatchTicketContractDetailId,0) != 0
					BEGIN
						SELECT TOP 1
							@ysnContractLoadBased = ISNULL(B.ysnLoad,0)
						FROM tblCTContractDetail A
						INNER JOIN tblCTContractHeader B
							ON A.intContractHeaderId = B.intContractHeaderId
						WHERE A.intContractDetailId = @intMatchTicketContractDetailId 

						SELECT @dblContractAvailableQty = dbo.fnCalculateQtyBetweenUOM(@intTicketItemUOMId, intItemUOMId, @dblMatchTicketScheduleQty) FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
						SET @dblUnits = (@dblMatchTicketNetUnits * -1)

						IF(ISNULL(@ysnContractLoadBased,0) = 1)
						BEGIN
							SET @dblContractAvailableQty = 1
							SET @dblUnits = (@dblMatchTicketNetUnits / @dblMatchTicketNetUnits) * -1
						END
						
						EXEC uspCTUpdateSequenceBalance @intContractDetailId, @dblUnits, @intUserId, @intMatchTicketId, 'Scale'
						EXEC uspCTUpdateScheduleQuantity
												@intContractDetailId	=	@intContractDetailId,
												@dblQuantityToUpdate	=	@dblContractAvailableQty,
												@intUserId				=	@intUserId,
												@intExternalId			=	@intMatchTicketId,
												@strScreenName			=	'Scale'	
					END
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
			EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
		END

		EXEC dbo.uspSCInsertDestinationInventoryShipment @intTicketId, @intUserId, 0
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
			EXEC dbo.uspSCInsertDestinationInventoryShipment @intTicketId, @intUserId, 0
		END
		ELSE ----Reverse Invoice
		BEGIN
			EXEC uspSCReverseInventoryShipmentInvoice @intTicketId,@intUserId
		END
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
