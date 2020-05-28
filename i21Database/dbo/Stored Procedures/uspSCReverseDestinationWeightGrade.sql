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
		,@dblContractQty INT
		,@intTicketItemUOMId INT
		,@dblContractAvailableQty NUMERIC(38,20);
DECLARE @ysnContractLoadBased BIT
DECLARE @intMatchTicketContractDetailId INT
DECLARE @strTicketWeightFinalizedWhere NVARCHAR(20)
DECLARE @strTicketGradeFinalizedWhere NVARCHAR(20)
DECLARE @intMatchTicketStorageScheduleTypeId AS INT
DECLARE @dblMatchTicketScheduleQty NUMERIC(38,20)
DECLARE @intMatchTicketItemUOMIdTo INT
DECLARE @dblMatchTicketNetUnits NUMERIC(38,20)
DECLARE @dblUnits NUMERIC(38,20)


BEGIN TRY
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

				-- INSERT INTO @ItemsToIncreaseInTransitDirect(
				-- 	[intItemId]
				-- 	,[intItemLocationId]
				-- 	,[intItemUOMId]
				-- 	,[intLotId]
				-- 	,[intSubLocationId]
				-- 	,[intStorageLocationId]
				-- 	,[dblQty]
				-- 	,[intTransactionId]
				-- 	,[strTransactionId]
				-- 	,[intTransactionTypeId]
				-- 	,[intFOBPointId]
				-- )
				-- SELECT 
				-- 	intItemId = SC.intItemId
				-- 	,intItemLocationId = ICIL.intItemLocationId
				-- 	,intItemUOMId = SC.intItemUOMIdTo
				-- 	,intLotId = SC.intLotId
				-- 	,intSubLocationId = SC.intSubLocationId
				-- 	,intStorageLocationId = SC.intStorageLocationId
				-- 	,dblQty = (SC.dblNetUnits * -1)
				-- 	,intTransactionId = 1
				-- 	,strTransactionId = SC.strTicketNumber
				-- 	,intTransactionTypeId = 1
				-- 	,intFOBPointId = NULL
				-- FROM tblSCTicket SC 
				-- INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
				-- WHERE SC.intTicketId = @intMatchTicketId
				-- EXEC uspICIncreaseInTransitDirectQty @ItemsToIncreaseInTransitDirect;

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
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceDetailId in(SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId)
			EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
		END
	END
	ELSE
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
		BEGIN
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceId = @intInvoiceId;
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceDetailId in(SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId)
			EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
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