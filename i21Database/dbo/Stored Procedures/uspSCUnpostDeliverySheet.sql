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

DECLARE @storageHistoryData				AS StorageHistoryStagingTable
		,@InventoryReceiptId			INT
		,@intInventoryReceiptItemId		INT
		,@InventoryShipmentId			INT
		,@intInventoryShipmentItemId	INT
		,@strTransactionId				NVARCHAR(40) = NULL
		,@intBillId						INT
		,@intInvoiceId					INT
		,@success						INT
		,@ysnPosted						BIT
		,@successfulCount				INT
		,@invalidCount					INT
		,@batchIdUsed					NVARCHAR(100)
		,@recapId						INT
		,@strBatchId					NVARCHAR(40)
		,@intInventoryAdjustmentId		INT
		,@dblAdjustByQuantity			NUMERIC(38,20)
		,@strLogDescription				NVARCHAR(100)
		,@currencyDecimal				INT
		,@intCustomerStorageId			INT
		,@strDistributionOption			NVARCHAR(3)
		,@intStorageScheduleTypeId		INT
		,@intStorageScheduleId			INT
		,@dblSplitPercent				NUMERIC (38,20)
		,@dblTempSplitQty				NUMERIC (38,20)
		,@dblFinalSplitQty				NUMERIC (38,20)
		,@intInventoryReceiptId			INT
		,@intItemId						INT
		,@intLocationId					INT	
		,@intSubLocationId				INT	
		,@newBalance					NUMERIC (38,20)
		,@dblQuantity					NUMERIC (38,20)
		,@strFreightCostMethod			NVARCHAR(40)
		,@strFeesCostMethod				NVARCHAR(40);

DECLARE @_intLoopDeliverySheetContractAdjustmentId INT
DECLARE @intLoopDeliverySheetContractAdjustmentId INT
DECLARE @intDSContractAdjusmentDeliverySheetId INT
DECLARE @intDSContractAdjusmentContractDetailId INT
DECLARE @intDSContractAdjusmentEntityId INT
DECLARE @dblDSContractAdjusmentQuantity NUMERIC(38,20)
DECLARE @intDSContractAdjusmentItemUOMId INT
DECLARE @ysnImposeReversalTransaction BIT

BEGIN TRY

		SET @ysnImposeReversalTransaction = 0
		
		SELECT TOP 1
			@ysnImposeReversalTransaction = ysnImposeReversalTransaction
		FROM tblRKCompanyPreference
		
		IF(@ysnImposeReversalTransaction = 1)
		BEGIN
			EXEC uspSCReverseDeliverySheet @intDeliverySheetId, @intUserId
			GOTO _Exit
		END



		-- SELECT @currencyDecimal = intCurrencyDecimal from tblSMCompanyPreference
		SET @currencyDecimal = 20
		IF @strInOutFlag = 'I'
			BEGIN
				SELECT TOP 1 @strFeesCostMethod = ICFee.strCostMethod, @strFreightCostMethod = SC.strCostMethod  FROM tblSCTicket SC
				INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
				LEFT JOIN tblICItem ICFee ON ICFee.intItemId = SCS.intDefaultFeeItemId
				WHERE intDeliverySheetId = @intDeliverySheetId

				SELECT @dblQuantity = dblGross, @dblTempSplitQty = dblGross FROM tblSCDeliverySheet WHERE intDeliverySheetId = @intDeliverySheetId
				DECLARE ticketCursor CURSOR FOR
				select strAdjustmentNo, intInventoryAdjustmentId from tblICInventoryAdjustment where intSourceId = @intDeliverySheetId and strDescription LIKE 'Delivery Sheet Posting%'
				OPEN ticketCursor;  
				FETCH NEXT FROM ticketCursor INTO @strTransactionId, @intInventoryAdjustmentId
				WHILE @@FETCH_STATUS = 0  
				BEGIN
					EXEC uspICPostInventoryAdjustment 0, 0, @strTransactionId,@intUserId, @strBatchId OUTPUT

					SELECT @dblAdjustByQuantity = dblNewQuantity FROM tblICInventoryAdjustmentDetail WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId
					
					SET @strLogDescription = 'Quantity Adjustment : ' + @strTransactionId
					EXEC dbo.uspSMAuditLog 
						@keyValue			= @intDeliverySheetId				-- Primary Key Value of the Ticket. 
						,@screenName		= 'Grain.view.DeliverySheet'		-- Screen Namespace
						,@entityId			= @intUserId						-- Entity Id.
						,@actionType		= 'Unpost'							-- Action Type
						,@changeDescription	= @strLogDescription				-- Description
						,@fromValue			= @dblAdjustByQuantity				-- Old Value
						,@toValue			= '0'								-- New Value
						,@details			= '';

					INSERT INTO @storageHistoryData
					(
						[intCustomerStorageId]
						,[intTicketId]
						,[intDeliverySheetId]
						,[intInventoryAdjustmentId]
						,[dblUnits]
						,[dtmHistoryDate]
						,[dblCurrencyRate]
						,[strPaidDescription]
						,[intTransactionTypeId]
						,[intUserId]
						,[strType]
						,[ysnPost]
						,[strTransactionId]	
					)
					SELECT 	
						[intCustomerStorageId]				= intCustomerStorageId				
						,[intTicketId]						= NULL
						,[intDeliverySheetId]				= intDeliverySheetId
						,[intInventoryAdjustmentId]			= NULL
						,[dblUnits]							= (dblUnits * -1)
						,[dtmHistoryDate]					= dbo.fnRemoveTimeOnDate(GETDATE())
						,[dblCurrencyRate]					= 1
						,[strPaidDescription]				= 'Quantity Adjustment Reversal ' + @strTransactionId + ' From Delivery Sheet'
						,[intTransactionTypeId]				= 9
						,[intUserId]						= @intUserId
						,[strType]							= 'From Inventory Adjustment'
						,[ysnPost]							= 1
						,[strTransactionId]					= @strTransactionId
					FROM tblGRStorageHistory WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId

					UPDATE tblGRStorageHistory SET intInventoryAdjustmentId = null WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId
					DELETE FROM tblICInventoryAdjustmentDetail where intInventoryAdjustmentId = @intInventoryAdjustmentId
					DELETE FROM tblICInventoryAdjustment where intInventoryAdjustmentId = @intInventoryAdjustmentId

					FETCH NEXT FROM ticketCursor INTO @strTransactionId, @intInventoryAdjustmentId;
					
				END
				CLOSE ticketCursor;  
				DEALLOCATE ticketCursor;

				EXEC uspGRInsertStorageHistoryRecord @storageHistoryData, 0

				DELETE FROM tblQMTicketDiscount WHERE intTicketFileId IN (SELECT intCustomerStorageId FROM tblGRCustomerStorage WHERE intDeliverySheetId = @intDeliverySheetId) 
				AND strSourceType = 'Storage'

				DECLARE @splitTable TABLE(
					[intEntityId] INT NOT NULL, 
					[intItemId] INT NULL,
					[intCompanyLocationId] INT NULL,
					[dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
					[intStorageScheduleTypeId] INT NULL,
					[strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
					[intStorageScheduleId] INT NULL
				);

				INSERT INTO @splitTable(
					[intEntityId]
					,[intItemId]
					,[intCompanyLocationId]
					,[dblSplitPercent]
					,[intStorageScheduleTypeId]
					,[strDistributionOption]
					,[intStorageScheduleId]
				)
				SELECT  
					[intEntityId]					= SDS.intEntityId
					,[intItemId]					= SCD.intItemId
					,[intCompanyLocationId]			= SCD.intCompanyLocationId
					,[dblSplitPercent]				= SDS.dblSplitPercent
					,[intStorageScheduleTypeId]		= SDS.intStorageScheduleTypeId
					,[strDistributionOption]		= SDS.strDistributionOption
					,[intStorageScheduleId]			= SDS.intStorageScheduleRuleId
				FROM tblSCDeliverySheetSplit SDS
				INNER JOIN tblSCDeliverySheet SCD ON SCD.intDeliverySheetId = SDS.intDeliverySheetId
				WHERE SDS.intDeliverySheetId = @intDeliverySheetId

				DECLARE splitCursor CURSOR FOR SELECT intEntityId, dblSplitPercent, strDistributionOption, intStorageScheduleId, intItemId, intCompanyLocationId,intStorageScheduleTypeId FROM @splitTable
				OPEN splitCursor;  
				FETCH NEXT FROM splitCursor INTO @intEntityId, @dblSplitPercent, @strDistributionOption, @intStorageScheduleId, @intItemId, @intLocationId, @intStorageScheduleTypeId;  
				WHILE @@FETCH_STATUS = 0  
				BEGIN
					SET @dblFinalSplitQty =  ROUND((@dblQuantity * @dblSplitPercent) / 100, @currencyDecimal);
					IF @dblTempSplitQty > @dblFinalSplitQty
						SET @dblTempSplitQty = @dblTempSplitQty - @dblFinalSplitQty;
					ELSE
						SET @dblFinalSplitQty = @dblTempSplitQty

					SELECT @intCustomerStorageId = intCustomerStorageId FROM tblGRCustomerStorage WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intCompanyLocationId = @intLocationId AND intDeliverySheetId = @intDeliverySheetId

					UPDATE tblGRCustomerStorage SET dblOpenBalance = 0 , dblOriginalBalance = 0 WHERE intCustomerStorageId = @intCustomerStorageId

					EXEC uspGRCustomerStorageBalance
							@intEntityId = NULL
							,@intItemId = NULL
							,@intLocationId = NULL
							,@intDeliverySheetId = NULL
							,@intCustomerStorageId = @intCustomerStorageId
							,@dblBalance = @dblFinalSplitQty
							,@intStorageTypeId = @intStorageScheduleTypeId
							,@intStorageScheduleId = @intStorageScheduleId
							,@ysnDistribute = 1
							,@newBalance = @newBalance OUT

					EXEC uspGRDeleteStorageHistory @strSourceType = 'StorageAdjustment' ,@IntSourceKey = @intCustomerStorageId

					FETCH NEXT FROM splitCursor INTO @intEntityId, @dblSplitPercent, @strDistributionOption, @intStorageScheduleId, @intItemId, @intLocationId, @intStorageScheduleTypeId;
				END
				CLOSE splitCursor;  
				DEALLOCATE splitCursor;

				EXEC uspGRCheckStorageTicketStatus @intDeliverySheetId, 'DS', @intUserId

				CREATE TABLE #tmpItemReceiptIds (
					[intInventoryReceiptId] [INT] PRIMARY KEY,
					[strReceiptNumber] [VARCHAR](100),
					UNIQUE ([intInventoryReceiptId])
				);
				INSERT INTO #tmpItemReceiptIds(intInventoryReceiptId,strReceiptNumber) 
				SELECT DISTINCT(IR.intInventoryReceiptId),IR.strReceiptNumber FROM vyuICGetInventoryReceiptItem IR
				INNER JOIN tblSCTicket SC ON SC.intTicketId = IR.intSourceId
				WHERE SC.intDeliverySheetId = @intDeliverySheetId AND IR.strSourceType = 'Scale'
				
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
							,@batchIdUsed = @batchIdUsed OUTPUT
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
						EXEC [dbo].[uspAPDeleteVoucher] @intBillId, @intUserId, 2
						FETCH NEXT FROM voucherCursor INTO @intBillId;
					END

					CLOSE voucherCursor  
					DEALLOCATE voucherCursor 

					FETCH NEXT FROM intListCursor INTO @InventoryReceiptId , @strTransactionId;
				END
				CLOSE intListCursor  
				DEALLOCATE intListCursor 

				UPDATE CS SET CS.dblFeesDue = SC.dblFeesPerUnit,CS.dblFreightDueRate = SC.dblFreightPerUnit, CS.dblDiscountsDue = 0
				, CS.dblGrossQuantity = 0, intShipFromLocationId = null, intShipFromEntityId = null
				FROM tblGRCustomerStorage CS
				OUTER APPLY (
					SELECT 
						CASE WHEN @strFeesCostMethod = 'Amount' THEN (SUM(dblTicketFees)/@dblQuantity) ELSE SUM(dblTicketFees) END AS dblFeesPerUnit
						,CASE WHEN @strFreightCostMethod = 'Amount' THEN (SUM(dblFreightRate)/@dblQuantity) ELSE SUM(dblFreightRate) END AS dblFreightPerUnit
					FROM tblSCTicket SC WHERE SC.intDeliverySheetId = @intDeliverySheetId AND SC.strTicketStatus = 'C'
				) SC
				WHERE CS.intDeliverySheetId = @intDeliverySheetId
				EXEC [dbo].[uspSCUpdateDeliverySheetStatus] @intDeliverySheetId, 1;

				--- Check DP Contrac Adjustments
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblSCDeliverySheetContractAdjustment WHERE intDeliverySheetId = @intDeliverySheetId)
					BEGIN
						SELECT 
							*
						INTO #tblSCDeliverySheetContractAdjustment
						FROM tblSCDeliverySheetContractAdjustment
						WHERE intDeliverySheetId = @intDeliverySheetId

						SELECT TOP 1 
							@intLoopDeliverySheetContractAdjustmentId = intDeliverySheetContractAdjustmentId
							,@_intLoopDeliverySheetContractAdjustmentId = intDeliverySheetContractAdjustmentId
							,@intDSContractAdjusmentDeliverySheetId = [intDeliverySheetId]
							,@intDSContractAdjusmentContractDetailId = [intContractDetailId]
							,@intDSContractAdjusmentEntityId = [intEntityId]
							,@dblDSContractAdjusmentQuantity = -[dblQuantity]
							,@intDSContractAdjusmentItemUOMId = [intItemUOMId]
						FROM #tblSCDeliverySheetContractAdjustment
						ORDER BY intDeliverySheetContractAdjustmentId

						WHILE (ISNULL(@_intLoopDeliverySheetContractAdjustmentId,0) > 0)
						BEGIN

							EXEC uspCTUpdateSequenceQuantityUsingUOM @intDSContractAdjusmentContractDetailId, @dblDSContractAdjusmentQuantity, @intUserId, @intDSContractAdjusmentDeliverySheetId, 'Delivery Sheet',@intDSContractAdjusmentItemUOMId

							SET @_intLoopDeliverySheetContractAdjustmentId = NULL

							SELECT TOP 1 
								@intLoopDeliverySheetContractAdjustmentId = intDeliverySheetContractAdjustmentId
								,@_intLoopDeliverySheetContractAdjustmentId = intDeliverySheetContractAdjustmentId
								,@intDSContractAdjusmentDeliverySheetId = [intDeliverySheetId]
								,@intDSContractAdjusmentContractDetailId = [intContractDetailId]
								,@intDSContractAdjusmentEntityId = [intEntityId]
								,@dblDSContractAdjusmentQuantity = [dblQuantity]
								,@intDSContractAdjusmentItemUOMId = [intItemUOMId]
							FROM #tblSCDeliverySheetContractAdjustment
							WHERE intDeliverySheetContractAdjustmentId > @intLoopDeliverySheetContractAdjustmentId
							ORDER BY intDeliverySheetContractAdjustmentId

						END

						DELETE FROM tblSCDeliverySheetContractAdjustment
						WHERE intDeliverySheetId = @intDeliverySheetId 
					END
				END
			END
		ELSE
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