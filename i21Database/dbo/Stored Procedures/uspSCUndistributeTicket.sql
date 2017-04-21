CREATE PROCEDURE [dbo].[uspSCUndistributeTicket]
	@intTicketId INT,
	@intUserId INT,
	@intEntityId INT,
	@strInOutFlag NVARCHAR(2),
	@ysnTransfer BIT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@jsonData NVARCHAR(MAX);

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
		,@recapId AS INT
		,@intLoadId INT
		,@intLoadDetailId INT
		,@intLoadContractId INT
		,@dblLoadScheduledUnits AS NUMERIC(12,4)
		,@intInventoryTransferId AS INT
		,@intMatchTicketId AS INT;

BEGIN TRY
		SELECT @intLoadId = LGLD.intLoadId ,@intLoadDetailId = LGLD.intLoadDetailId, @dblLoadScheduledUnits = LGLD.dblDeliveredQuantity 
		FROM tblLGLoad LGL INNER JOIN vyuLGLoadDetailView LGLD ON LGL.intLoadId = LGLD.intLoadId 
		WHERE LGL.intTicketId = @intTicketId

		IF @strInOutFlag = 'I'
			BEGIN
				CREATE TABLE #tmpItemReceiptIds (
					[intInventoryReceiptId] [INT] PRIMARY KEY,
					[strReceiptNumber] [VARCHAR](100),
					UNIQUE ([intInventoryReceiptId])
				);
				INSERT INTO #tmpItemReceiptIds(intInventoryReceiptId,strReceiptNumber) SELECT DISTINCT(intInventoryReceiptId),strReceiptNumber FROM vyuICGetInventoryReceiptItem WHERE intSourceId = @intTicketId AND strSourceType = 'Scale'
				
				DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT intInventoryReceiptId,  strReceiptNumber
				FROM #tmpItemReceiptIds

				OPEN intListCursor;

				-- Initial fetch attempt
				FETCH NEXT FROM intListCursor INTO @InventoryReceiptId, @strTransactionId;

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SELECT @intInventoryReceiptItemId = intInventoryReceiptItemId FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @InventoryReceiptId
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
					EXEC [dbo].[uspICPostInventoryReceipt] 0, 0, @strTransactionId, @intUserId
					EXEC [dbo].[uspICDeleteInventoryReceipt] @InventoryReceiptId, @intUserId
					EXEC [dbo].[uspGRReverseOnReceiptDelete] @InventoryReceiptId

					FETCH NEXT FROM intListCursor INTO @InventoryReceiptId , @strTransactionId;
				END
				EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
			END
		ELSE
			BEGIN
				IF @intEntityId = 0
					BEGIN
						SELECT @intInventoryTransferId = ICTD.intInventoryTransferId, @strTransactionId = ICTD.strTransferNo, @intMatchTicketId = SC.intMatchTicketId
						FROM vyuICGetInventoryTransferDetail  ICTD
						LEFT JOIN tblSCTicket SC ON SC.strTicketNumber = ICTD.strSourceNumber AND SC.intTicketId = ICTD.intSourceId
						WHERE intSourceId = @intTicketId

						IF @intMatchTicketId > 0
						BEGIN
							SET @ErrorMessage = 'Undistribute failed, this ticket is using in other ticket';
							RAISERROR(@ErrorMessage, 11, 1);
						END 

						IF @intInventoryTransferId > 0
							EXEC [dbo].[uspICPostInventoryTransfer] 0, 0, @strTransactionId, @intUserId;	
							EXEC [dbo].[uspICDeleteInventoryTransfer] @intInventoryTransferId, @intUserId	

						EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
					END
				
				IF @intEntityId > 0
					BEGIN
						CREATE TABLE #tmpItemShipmentIds (
							[intInventoryShipmentId] [INT] PRIMARY KEY,
							[strShipmentNumber] [VARCHAR](100),
							UNIQUE ([intInventoryShipmentId])
						);
						INSERT INTO #tmpItemShipmentIds(intInventoryShipmentId,strShipmentNumber) SELECT DISTINCT(intInventoryShipmentId),strShipmentNumber from vyuICGetInventoryShipmentItem WHERE intSourceId = @intTicketId AND strSourceType = 'Scale'
				
						DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
						FOR
						SELECT intInventoryShipmentId, strShipmentNumber
						FROM #tmpItemShipmentIds

						OPEN intListCursor;

						-- Initial fetch attempt
						FETCH NEXT FROM intListCursor INTO @InventoryShipmentId, @strTransactionId;

						WHILE @@FETCH_STATUS = 0
						BEGIN
							SELECT @intInventoryShipmentItemId = intInventoryShipmentItemId FROM tblICInventoryShipmentItem WHERE intInventoryShipmentId = @InventoryShipmentId
							SELECT @intInvoiceId = intInvoiceId FROM tblARInvoiceDetail WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId;
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
							EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
							EXEC [dbo].[uspICPostInventoryShipment] 0, 0, @strTransactionId, @intUserId;
							EXEC [dbo].[uspGRDeleteStorageHistory] @strSourceType = 'InventoryShipment' ,@IntSourceKey = @InventoryShipmentId
							EXEC [dbo].[uspICDeleteInventoryShipment] @InventoryShipmentId, @intEntityId;
							EXEC [dbo].[uspGRReverseTicketOpenBalance] 'InventoryShipment' , @InventoryShipmentId ,@intUserId;
							DELETE tblQMTicketDiscount WHERE intTicketFileId = @InventoryShipmentId AND strSourceType = 'Inventory Shipment'
							FETCH NEXT FROM intListCursor INTO @InventoryShipmentId, @strTransactionId;
						END

						EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
					END
			END
		
		--Audit Log
		
		SET @jsonData = 'Updated - Record:' + CAST(@intTicketId AS NVARCHAR(MAX)) + '","keyValue":"' + CAST(@intTicketId AS NVARCHAR(MAX)) + ''          
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intTicketId						-- Primary Key Value of the Ticket. 
			,@screenName		= 'Grain.view.ScaleViewController'	-- Screen Namespace
			,@entityId			= @intUserId						-- Entity Id.
			,@actionType		= 'Updated'							-- Action Type
			,@changeDescription	= 'Ticket Status'					-- Description
			,@fromValue			= 'Completed'						-- Previous Value
			,@toValue			= 'Reopened'						-- New Value
			,@details			= @jsonData;

		IF ISNULL(@intLoadDetailId,0) > 0
		BEGIN
			EXEC [dbo].[uspLGUpdateLoadDetails] @intLoadDetailId, 1 , @intTicketId, NULL, 0;
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