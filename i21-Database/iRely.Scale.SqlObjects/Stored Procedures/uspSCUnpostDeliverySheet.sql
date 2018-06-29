CREATE PROCEDURE [dbo].[uspSCUnpostDeliverySheet]
	@intDeliverySheetId INT,
	@intUserId INT,
	@intEntityId INT,
	@strInOutFlag NVARCHAR(2)
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
		,@intInventoryTransferId AS INT
		,@InTransitTableType AS InTransitTableType;

BEGIN TRY
		
		IF @strInOutFlag = 'I'
			BEGIN

				CREATE TABLE #tmpItemReceiptIds (
					[intInventoryReceiptId] [INT] PRIMARY KEY,
					[strReceiptNumber] [VARCHAR](100),
					UNIQUE ([intInventoryReceiptId])
				);
				INSERT INTO #tmpItemReceiptIds(intInventoryReceiptId,strReceiptNumber) SELECT DISTINCT(intInventoryReceiptId),strReceiptNumber FROM vyuICGetInventoryReceiptItem WHERE intSourceId = @intDeliverySheetId AND strSourceType = 'Delivery Sheet'
				
				DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT intInventoryReceiptId,  strReceiptNumber
				FROM #tmpItemReceiptIds

				OPEN intListCursor;

				-- Initial fetch attempt
				FETCH NEXT FROM intListCursor INTO @InventoryReceiptId, @strTransactionId;

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SELECT @intInventoryReceiptItemId = intInventoryReceiptItemId FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @InventoryReceiptId AND dblUnitCost > 0
					IF OBJECT_ID (N'tempdb.dbo.#tmpVoucherDetail') IS NOT NULL
                        DROP TABLE #tmpVoucherDetail
					CREATE TABLE #tmpVoucherDetail (
						[intBillId] [INT] PRIMARY KEY,
						UNIQUE ([intBillId])
					);
					INSERT INTO #tmpVoucherDetail(intBillId)SELECT DISTINCT(intBillId) FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
					
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

					EXEC [dbo].[uspICPostInventoryReceipt] 0, 0, @strTransactionId, @intUserId
					EXEC [dbo].[uspSCReverseScheduleQty] @InventoryReceiptId, @intUserId
					EXEC [dbo].[uspGRReverseOnReceiptDelete] @InventoryReceiptId
					EXEC [dbo].[uspICDeleteInventoryReceipt] @InventoryReceiptId, @intUserId

					FETCH NEXT FROM intListCursor INTO @InventoryReceiptId , @strTransactionId;
				END
				CLOSE intListCursor  
				DEALLOCATE intListCursor 
				EXEC [dbo].[uspSCUpdateDeliverySheetStatus] @intDeliverySheetId, 1;

				INSERT INTO @InTransitTableType (
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
				)
				SELECT	[intItemId]				= SCD.intItemId
						,[intItemLocationId]	= ICIL.intItemLocationId
						,[intItemUOMId]			= UOM.intItemUOMId
						,[intLotId]				= NULL
						,[intSubLocationId]		= NULL
						,[intStorageLocationId]	= NULL
						,[dblQty]				= (SELECT SUM(dblNetUnits) FROM tblSCTicket WHERE intDeliverySheetId = @intDeliverySheetId AND strTicketStatus = 'H')
						,[intTransactionId]		= @intDeliverySheetId
						,[strTransactionId]		= SCD.strDeliverySheetNumber
						,[intTransactionTypeId] = 1
				FROM	tblSCDeliverySheet SCD 
				INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SCD.intItemId AND ICIL.intLocationId = SCD.intCompanyLocationId
				INNER JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = SCD.intItemId AND UOM.ysnStockUnit = 1
				WHERE SCD.intDeliverySheetId = @intDeliverySheetId

				EXEC dbo.uspICIncreaseInTransitInBoundQty @InTransitTableType;
			END
		ELSE
			BEGIN
				IF @intEntityId > 0
					BEGIN
						CREATE TABLE #tmpItemShipmentIds (
							[intInventoryShipmentId] [INT] PRIMARY KEY,
							[strShipmentNumber] [VARCHAR](100),
							UNIQUE ([intInventoryShipmentId])
						);
						INSERT INTO #tmpItemShipmentIds(intInventoryShipmentId,strShipmentNumber) SELECT DISTINCT(intInventoryShipmentId),strShipmentNumber from vyuICGetInventoryShipmentItem WHERE intSourceId = @intDeliverySheetId AND strSourceType = 'Delivery Sheet'
				
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
						EXEC [dbo].[uspSCUpdateDeliverySheetStatus] @intDeliverySheetId, 1;

						INSERT INTO @InTransitTableType (
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
						)
						SELECT	[intItemId]				= SCD.intItemId
								,[intItemLocationId]	= ICIL.intItemLocationId
								,[intItemUOMId]			= UOM.intItemUOMId
								,[intLotId]				= NULL
								,[intSubLocationId]		= NULL
								,[intStorageLocationId]	= NULL
								,[dblQty]				= (SELECT SUM(dblNetUnits) FROM tblSCTicket WHERE intDeliverySheetId = @intDeliverySheetId AND strTicketStatus = 'H')
								,[intTransactionId]		= @intDeliverySheetId
								,[strTransactionId]		= SCD.strDeliverySheetNumber
								,[intTransactionTypeId] = 1
						FROM	tblSCDeliverySheet SCD 
						INNER JOIN dbo.tblICItemLocation ICIL ON ICIL.intItemId = SCD.intItemId AND ICIL.intLocationId = SCD.intCompanyLocationId
						INNER JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = SCD.intItemId AND UOM.ysnStockUnit = 1
						WHERE SCD.intDeliverySheetId = @intDeliverySheetId

						EXEC dbo.uspICIncreaseInTransitOutBoundQty @InTransitTableType;
					END
			END
		
		--Audit Log
		
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intDeliverySheetId				-- Primary Key Value of the Ticket. 
			,@screenName		= 'Grain.view.DeliverySheet'		-- Screen Namespace
			,@entityId			= @intUserId						-- Entity Id.
			,@actionType		= 'Updated'							-- Action Type
			,@changeDescription	= 'Delivery Sheet Status'			-- Description
			,@fromValue			= 'Posted'							-- Previous Value
			,@toValue			= 'Unposted'						-- New Value
			,@details			= '';
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