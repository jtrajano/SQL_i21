CREATE PROCEDURE [dbo].[uspSCUndistributeTicket]
	@intTicketId INT,
	@intUserId INT,
	@intEntityId INT,
	@strInOutFlag NVARCHAR(2),
	@ysnTransfer BIT = NULL,
	@ysnDirectShip BIT = NULL
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
		,@dblLoadScheduledUnits AS NUMERIC(38,20)
		,@dblDeliveredQuantity AS NUMERIC(38,20)
		,@intInventoryTransferId AS INT
		,@intMatchTicketId AS INT
		,@strXml NVARCHAR(MAX)
		,@intSettleStorageId INT
		,@ItemsToIncreaseInTransitDirect AS InTransitTableType
		,@ysnIRPosted BIT;

BEGIN TRY
		SELECT @intLoadId = LGLD.intLoadId ,@intLoadDetailId = LGLD.intLoadDetailId
		, @dblDeliveredQuantity = LGLD.dblDeliveredQuantity
		, @dblLoadScheduledUnits = LGLD.dblQuantity
		, @intLoadContractId = 
				CASE WHEN @strInOutFlag = 'I' THEN LGLD.intPContractDetailId
					WHEN @strInOutFlag = 'O' THEN LGLD.intSContractDetailId
				END
		FROM tblLGLoad LGL INNER JOIN vyuLGLoadDetailView LGLD ON LGL.intLoadId = LGLD.intLoadId 
		WHERE LGL.intTicketId = @intTicketId

		IF @strInOutFlag = 'I'
			BEGIN
				IF ISNULL(@ysnDirectShip,0) = 0
				BEGIN
					IF OBJECT_ID (N'tempdb.dbo.#tmpSettleStorage') IS NOT NULL
						DROP TABLE #tmpSettleStorage
					CREATE TABLE #tmpSettleStorage (
						[intSettleStorageId] INT PRIMARY KEY,
						UNIQUE ([intSettleStorageId])
					);
					INSERT INTO #tmpSettleStorage(intSettleStorageId) SELECT GRS.intSettleStorageId from tblGRSettleStorage GRS
						INNER JOIN tblGRSettleStorageTicket GRT ON GRT.intSettleStorageId = GRS.intSettleStorageId
						INNER JOIN tblGRCustomerStorage GRC ON GRC.intCustomerStorageId = GRT.intCustomerStorageId
					WHERE GRC.intTicketId = @intTicketId

					DECLARE settleStorageCursor CURSOR LOCAL FAST_FORWARD
					FOR
					SELECT intSettleStorageId FROM #tmpSettleStorage

					OPEN settleStorageCursor;

					FETCH NEXT FROM settleStorageCursor INTO @intSettleStorageId;

					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @strXml = '<root><intSettleStorageId>'+  CAST(@intSettleStorageId as nvarchar(20)) + '</intSettleStorageId>
						<intEntityUserSecurityId>' + CAST(@intUserId as nvarchar(20)) + '</intEntityUserSecurityId></root>';

						EXEC [dbo].[uspGRUnPostSettleStorage] @strXml;

						FETCH NEXT FROM settleStorageCursor INTO @intSettleStorageId;
					END

					CLOSE settleStorageCursor  
					DEALLOCATE settleStorageCursor 

					CREATE TABLE #tmpItemReceiptIds (
						[intInventoryReceiptId] [INT] PRIMARY KEY,
						[strReceiptNumber] [VARCHAR](100),
						[ysnPosted] [BIT],
						UNIQUE ([intInventoryReceiptId])
					);
					INSERT INTO #tmpItemReceiptIds(intInventoryReceiptId,strReceiptNumber,ysnPosted) SELECT DISTINCT(intInventoryReceiptId),strReceiptNumber,ysnPosted FROM vyuICGetInventoryReceiptItem WHERE intSourceId = @intTicketId AND strSourceType = 'Scale'
				
					DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
					FOR
					SELECT intInventoryReceiptId,  strReceiptNumber
					FROM #tmpItemReceiptIds

					OPEN intListCursor;

					-- Initial fetch attempt
					FETCH NEXT FROM intListCursor INTO @InventoryReceiptId, @strTransactionId, @ysnIRPosted;

					WHILE @@FETCH_STATUS = 0
					BEGIN
						IF OBJECT_ID (N'tempdb.dbo.#tmpVoucherDetail') IS NOT NULL
							DROP TABLE #tmpVoucherDetail
						CREATE TABLE #tmpVoucherDetail (
							[intBillId] [INT] PRIMARY KEY,
							UNIQUE ([intBillId])
						);
						INSERT INTO #tmpVoucherDetail(intBillId)SELECT DISTINCT(AP.intBillId) FROM tblAPBillDetail AP
						LEFT JOIN tblICInventoryReceiptItem IC ON IC.intInventoryReceiptItemId = AP.intInventoryReceiptItemId
						WHERE IC.intInventoryReceiptId = @InventoryReceiptId
					
						DECLARE voucherCursor CURSOR LOCAL FAST_FORWARD
						FOR
						SELECT intBillId FROM #tmpVoucherDetail

						OPEN voucherCursor;

						FETCH NEXT FROM voucherCursor INTO @intBillId;

						WHILE @@FETCH_STATUS = 0
						BEGIN
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
									,@batchIdUsed = @success OUTPUT
								END
							IF ISNULL(@success, 0) = 0
							BEGIN
								SELECT @ErrorMessage = strMessage FROM tblAPPostResult WHERE strBatchNumber = @batchIdUsed
								IF ISNULL(@ErrorMessage, '') != ''
								BEGIN
									RAISERROR(@ErrorMessage, 11, 1);
									RETURN;
								END
							END
							EXEC [dbo].[uspAPDeleteVoucher] @intBillId, @intUserId
							FETCH NEXT FROM voucherCursor INTO @intBillId;
						END

						CLOSE voucherCursor  
						DEALLOCATE voucherCursor
						IF ISNULL(@ysnIRPosted, 0) = 1
							EXEC [dbo].[uspICPostInventoryReceipt] 0, 0, @strTransactionId, @intUserId
						EXEC [dbo].[uspGRReverseOnReceiptDelete] @InventoryReceiptId
						EXEC [dbo].[uspICDeleteInventoryReceipt] @InventoryReceiptId, @intUserId

						FETCH NEXT FROM intListCursor INTO @InventoryReceiptId , @strTransactionId;
					END
					CLOSE intListCursor  
					DEALLOCATE intListCursor 
					EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
				END
				ELSE
					BEGIN
						SELECT @intMatchTicketId = intMatchTicketId FROM tblSCTicket WHERE intTicketId = @intTicketId

						IF EXISTS (SELECT intMatchTicketId FROM tblSCTicket WHERE intTicketId = @intMatchTicketId AND strTicketStatus = 'C')
						BEGIN
							RAISERROR('Unable to un-distribute ticket, match ticket already completed', 11, 1);
							RETURN;
						END

						SELECT TOP 1 @intBillId = intBillId FROM tblAPBillDetail WHERE intScaleTicketId = @intTicketId
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
						UPDATE tblSCTicket SET intMatchTicketId = null WHERE intTicketId = @intTicketId
						DELETE FROM tblQMTicketDiscount WHERE intTicketId = @intMatchTicketId AND strSourceType = 'Scale'
						DELETE FROM tblSCTicket WHERE intTicketId = @intMatchTicketId

						INSERT INTO @ItemsToIncreaseInTransitDirect(
							[intItemId]
							,[intItemLocationId]
							,[intItemUOMId]
							,[intLotId]
							,[intSubLocationId]
							,[intStorageLocationId]
							,[dblQty]
							,[intTransactionId]
							,[strTransactionId]
							,[intTransactionTypeId]
							,[intFOBPointId]
						)
						SELECT 
							intItemId = SC.intItemId
							,intItemLocationId = ICIL.intItemLocationId
							,intItemUOMId = SC.intItemUOMIdTo
							,intLotId = SC.intLotId
							,intSubLocationId = SC.intSubLocationId
							,intStorageLocationId = SC.intStorageLocationId
							,dblQty = (SC.dblNetUnits * -1)
							,intTransactionId = 1
							,strTransactionId = SC.strTicketNumber
							,intTransactionTypeId = 1
							,intFOBPointId = NULL
						FROM tblSCTicket SC 
						INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
						WHERE SC.intTicketId = @intTicketId
						EXEC uspICIncreaseInTransitDirectQty @ItemsToIncreaseInTransitDirect;

						EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
					END
			END
		ELSE
			BEGIN
				IF ISNULL(@ysnTransfer ,0) = 1
				BEGIN
					SELECT @intInvoiceId = ARD.intInvoiceId, @ysnPosted = AR.ysnPosted FROM tblSCTicket SCT
					LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = SCT.intSalesOrderId
					LEFT JOIN tblSOSalesOrderDetail SOD ON SOD.intSalesOrderId = SCT.intSalesOrderId
					LEFT JOIN tblARInvoiceDetail ARD ON ARD.intSalesOrderDetailId = SOD.intSalesOrderDetailId
					LEFT JOIN tblARInvoice AR ON AR.intInvoiceId = ARD.intInvoiceId
					WHERE SCT.intTicketId = @intTicketId

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
					EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
				END
				IF ISNULL(@ysnDirectShip,0) = 1
				BEGIN 
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
						EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
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
							IF ISNULL(@intInvoiceId, 0) > 0
								EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
							EXEC [dbo].[uspICPostInventoryShipment] 0, 0, @strTransactionId, @intUserId;
							EXEC [dbo].[uspGRDeleteStorageHistory] @strSourceType = 'InventoryShipment' ,@IntSourceKey = @InventoryShipmentId
							EXEC [dbo].[uspGRReverseTicketOpenBalance] 'InventoryShipment' , @InventoryShipmentId ,@intUserId;
							EXEC [dbo].[uspICDeleteInventoryShipment] @InventoryShipmentId, @intEntityId;
							DELETE tblQMTicketDiscount WHERE intTicketFileId = @InventoryShipmentId AND strSourceType = 'Inventory Shipment'
							FETCH NEXT FROM intListCursor INTO @InventoryShipmentId, @strTransactionId;
						END
						CLOSE intListCursor  
						DEALLOCATE intListCursor 
						EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
					END
				END
			END
		
		--Audit Log
		
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intTicketId						-- Primary Key Value of the Ticket. 
			,@screenName		= 'Grain.view.Scale'				-- Screen Namespace
			,@entityId			= @intUserId						-- Entity Id.
			,@actionType		= 'Updated'							-- Action Type
			,@changeDescription	= 'Ticket Status'					-- Description
			,@fromValue			= 'Completed'						-- Previous Value
			,@toValue			= 'Reopened'						-- New Value
			,@details			= '';

		IF ISNULL(@intLoadDetailId,0) > 0
		BEGIN
			EXEC [dbo].[uspLGUpdateLoadDetails] @intLoadDetailId, 1 , @intTicketId, NULL, 0;
			SET @dblDeliveredQuantity = @dblDeliveredQuantity * -1;
			EXEC uspCTUpdateScheduleQuantity @intLoadContractId, @dblDeliveredQuantity, @intUserId, @intTicketId, 'Scale'
			EXEC uspCTUpdateScheduleQuantity @intLoadContractId, @dblLoadScheduledUnits, @intUserId, @intLoadDetailId, 'Load Schedule'
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