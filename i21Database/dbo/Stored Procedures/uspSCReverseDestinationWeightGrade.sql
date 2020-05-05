﻿CREATE PROCEDURE [dbo].[uspSCReverseDestinationWeightGrade]
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
DECLARE @ysnTicketContractLoadBased BIT

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