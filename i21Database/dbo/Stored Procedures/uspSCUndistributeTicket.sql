CREATE PROCEDURE [dbo].[uspSCUndistributeTicket]
	@intTicketId INT,
	@intUserId INT,
	@intEntityId INT,
	@strInOutFlag NVARCHAR(2)
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000),
		@ErrorSeverity INT,
		@ErrorState INT;

DECLARE @InventoryReceiptId INT
		,@intInventoryReceiptItemId INT
		,@InventoryShipmentId INT
		,@intInventoryShipmentItemId INT
		,@strTransactionId NVARCHAR(40) = NULL
		,@intBillId INT
		,@intInvoiceId INT
		,@success INT
		,@ysnPosted BIT
		,@successfulCount AS INT
		,@invalidCount AS INT
		,@batchIdUsed AS NVARCHAR(100)
		,@recapId AS INT;

BEGIN TRY
		IF @strInOutFlag = 'I'
			BEGIN
				CREATE TABLE #tmpItemReceiptIds (
					[intInventoryReceiptId] [INT] PRIMARY KEY,
					[intInventoryReceiptItemId] [INT],
					[strReceiptNumber] [VARCHAR](100),
					UNIQUE ([intInventoryReceiptId])
				);
				INSERT INTO #tmpItemReceiptIds(intInventoryReceiptId,intInventoryReceiptItemId,strReceiptNumber) SELECT intInventoryReceiptId,intInventoryReceiptItemId,strReceiptNumber FROM vyuICGetInventoryReceiptItem WHERE intSourceId = @intTicketId AND strSourceType = 'Scale'
				
				DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT intInventoryReceiptId, intInventoryReceiptItemId, strReceiptNumber
				FROM #tmpItemReceiptIds

				OPEN intListCursor;

				-- Initial fetch attempt
				FETCH NEXT FROM intListCursor INTO @InventoryReceiptId, @intInventoryReceiptItemId , @strTransactionId;

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SELECT @intBillId = intBillId FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId GROUP BY intBillId
					SELECT @ysnPosted = ysnPosted  FROM tblAPBill WHERE intBillId = @intBillId
					IF @ysnPosted =1
						BEGIN
							EXEC [dbo].[uspAPPostBill]
							@post = 0
							,@recap = 0
							,@isBatch = 0
							,@param = @intBillId
							,@userId = @intUserId
							,@success = @success OUTPUT
						END
					EXEC [dbo].[uspAPDeleteVoucher] @intBillId, @intUserId
					EXEC [dbo].[uspICPostInventoryReceipt] 0, 0, @strTransactionId, @intEntityId
					EXEC [dbo].[uspICDeleteInventoryReceipt] @InventoryReceiptId, @intEntityId

					FETCH NEXT FROM intListCursor INTO @InventoryReceiptId, @intInventoryReceiptItemId , @strTransactionId;
				END
				EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
			END
		ELSE
			BEGIN
				CREATE TABLE #tmpItemShipmentIds (
					[intInventoryShipmentId] [INT] PRIMARY KEY,
					[intInventoryShipmentItemId] [INT],
					[strShipmentNumber] [VARCHAR],
					UNIQUE ([intInventoryReceiptId])
				);
				INSERT INTO #tmpItemReceiptIds(intInventoryShipmentId,intInventoryShipmentItemId,strShipmentNumber) SELECT intInventoryShipmentId, intInventoryShipmentItemId,strShipmentNumber FROM vyuICGetInventoryShipmentItem WHERE intSourceId = @intTicketId AND strSourceType = 'Scale'
				
				DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT intInventoryShipmentId, intInventoryShipmentItemId, strShipmentNumber
				FROM #tmpItemShipmentIds

				OPEN intListCursor;

				-- Initial fetch attempt
				FETCH NEXT FROM intListCursor INTO @InventoryShipmentId, @intInventoryShipmentItemId , @strTransactionId;

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SELECT @intInvoiceId = intInvoiceId FROM tblARInvoiceDetail WHERE intInventoryShipmentItemId = @InventoryShipmentId;
					SELECT @ysnPosted = @ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId;
					IF @ysnPosted =1
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
					EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
					EXEC [dbo].[uspICPostInventoryShipment] 1, 0, @strTransactionId, @intUserId;
					EXEC [dbo].[uspICDeleteInventoryShipment] @InventoryShipmentId, @intEntityId;

					FETCH NEXT FROM intListCursor INTO @InventoryShipmentId, @intInventoryShipmentItemId , @strTransactionId;
				END
				EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
			END
	_Exit:

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