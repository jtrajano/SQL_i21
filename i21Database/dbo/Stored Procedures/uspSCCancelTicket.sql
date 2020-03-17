CREATE PROCEDURE [dbo].[uspSCCancelTicket]
	@intTicketId INT,
	@intUserId INT,
	@intDuplicateTicketId INT OUTPUT
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

DECLARE @strInOutFlag NVARCHAR(1)
DECLARE @TicketReceiptShipmentIds Id
DECLARE @_intInventoryReceiptShipmentId INT
DECLARE @_intReversalReceiptShipmentId INT
dECLARE @_strReceiptShipmentNumber NVARCHAR(50)
DECLARE @strTicketStatus NVARCHAR(1)
DECLARE @CustomerStorageStagingTable AS CustomerStorageStagingTable
DECLARE @strTicketNumber NVARCHAR(50)
DECLARE @strReversalTicketNumber NVARCHAR(50)
DECLARE @intRecordCounter INT
DECLARE @intTicketPoolId INT
DECLARE @intTicketType INT
DECLARE @intProcessingLocationId INT
DECLARE @intCustomerStorageId INT
DECLARE @intDeliverySheetId INT
dECLARE @strDistributionOption NVARCHAR
DECLARE @intTicketContractDetailId INT
DECLARE @_intInventoryReceiptShipmentEntityId INT
DECLARE @_ysnLoadBaseContract BIT
dECLARE @_dblLoadUsedQty NUMERIC(18,6)
DECLARE @_ysnReceiptShipmetContainTicketContract BIT
DECLARE @_dblContractAvailableQty NUMERIC(18,6)
DECLARE @dblTicketScheduledQty NUMERIC(18,6)
DECLARE @intTicketItemUOMId INT
DECLARE @intTicketLoadDetailId INT
DECLARE @_intInventoryReceiptShipmentItemId INT
DECLARE @intMatchTicketId INT
DECLARE @strMatchTicketStatus NVARCHAR(1)
dECLARE @intMatchLoadDetailId INT
DECLARE @TransferEntries AS InventoryTransferStagingTable
DECLARE @intTicketItemId INT
DECLARE @intLotType INT
DECLARE @_intInventoryTransfer INT
DECLARE @_strInventoryTransferNumber NVARCHAR(50)

BEGIN TRY


		---get ticket information
		BEGIN
			SELECT TOP 1
				@strInOutFlag = strInOutFlag
				,@strTicketStatus = strTicketStatus
				,@intTicketPoolId = intTicketPoolId
				,@intTicketType = intTicketType
				,@strTicketNumber = strTicketNumber
				,@intProcessingLocationId = intProcessingLocationId
				,@intDeliverySheetId = intDeliverySheetId
				,@strDistributionOption = strDistributionOption
				,@intTicketContractDetailId = intContractId
				,@intTicketLoadDetailId = intLoadDetailId
				,@dblTicketScheduledQty = dblScheduleQty
				,@intTicketItemUOMId = intItemUOMIdTo
				,@intMatchTicketId = intMatchTicketId
				,@intTicketItemId = intItemId
			FROM tblSCTicket SC
			WHERE intTicketId = @intTicketId

			SELECT @intLotType = dbo.fnGetItemLotType(@intTicketItemId) 
		END


		

		--get match ticket information for direct 
		BEGIN
			SET @intMatchTicketId = ISNULL(@intMatchTicketId,0)
			IF(@intMatchTicketId > 0)
			BEGIN
				SELECT TOP 1
					@strMatchTicketStatus = strTicketStatus
					,@intMatchLoadDetailId = intLoadDetailId
				FROM tblSCTicket SC
				WHERE intTicketId = @intMatchTicketId
			END
		END

		IF(@intMatchTicketId > 0 AND @intTicketType = 6)
		BEGIN
			IF ISNULL(@strMatchTicketStatus,'') = 'C'
			BEGIN
				RAISERROR('Unable to reverse ticket, match ticket already completed', 11, 1);
				RETURN;
			END
		END

		IF(@strTicketStatus <> 'C')
		BEGIN
			SET @ErrorMessage = 'Ticket is not yet completed. Use the void process instead.';
			RAISERROR(@ErrorMessage, 11, 1);
		END

		IF(@strInOutFlag = 'I')
		BEGIN
			--GEt all IR for the ticket that don't have reversals
			BEGIN
				INSERT INTO @TicketReceiptShipmentIds
				SELECT DISTINCT
					A.intInventoryReceiptId
				FROM tblICInventoryReceipt A
				INNER JOIN tblICInventoryReceiptItem B
					ON A.intInventoryReceiptId = B.intInventoryReceiptId
				WHERE A.intSourceType = 1
					AND B.intSourceId = @intTicketId
					AND ISNULL(A.strDataSource,0) <> 'Reversal'
					AND NOT EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intSourceInventoryReceiptId = A.intInventoryReceiptId)
				ORDER BY A.intInventoryReceiptId ASC
			END

			SELECT TOP 1 
				@_intInventoryReceiptShipmentId = MIN(intId)
			FROM @TicketReceiptShipmentIds
			

			---Create reversal
			WHILE ISNULL(@_intInventoryReceiptShipmentId,0) > 0
			BEGIN
				SET @_intReversalReceiptShipmentId = 0
				
				EXEC uspICReverseInventoryReceipt NULL,@_intInventoryReceiptShipmentId, @intUserId, NULL, @_intReversalReceiptShipmentId OUTPUT

				
				IF ISNULL(@_intReversalReceiptShipmentId,0) > 0
				BEGIN
					SELECT TOP 1 
						@_strReceiptShipmentNumber = strReceiptNumber
						,@_intInventoryReceiptShipmentEntityId = intEntityVendorId
					FROM tblICInventoryReceipt
					WHERE intInventoryReceiptId = @_intReversalReceiptShipmentId

					EXEC dbo.uspICPostInventoryReceipt 1, 0, @_strReceiptShipmentNumber, @intUserId;
				
					-----insert into storage history of storage based on the previous IR and update customer storage open balance		
					BEGIN
						SET @intCustomerStorageId = 0
						SET @intCustomerStorageId = (SELECT TOP 1 intCustomerStorageId FROM tblGRStorageHistory WHERE intInventoryReceiptId = @_intInventoryReceiptShipmentId)

						
						IF ISNULL(@intCustomerStorageId,0)> 0
						
							
						--insert customer history
						INSERT INTO tblGRStorageHistory (
							intConcurrencyId
							,intCustomerStorageId
							,intTicketId
							,intInventoryReceiptId
							,intInvoiceId
							,intInventoryShipmentId
							,intBillId
							,intContractHeaderId
							,dblUnits
							,dtmHistoryDate
							,dblPaidAmount
							,strPaidDescription
							,dblCurrencyRate
							,strType
							,strUserName
							,intUserId
							,intTransactionTypeId
							,intEntityId
							,intCompanyLocationId
							,strTransferTicket
							,strSettleTicket
							,strVoucher
							,intSettleStorageId
							,intDeliverySheetId
							,dtmDistributionDate
							,strTransactionId
							,intTransferStorageId
							,ysnPost
							,intInventoryAdjustmentId
							,dblOldCost

						)
						SELECT TOP 1
							intConcurrencyId						= 1
							,intCustomerStorageId					= A.intCustomerStorageId
							,intTicketId							= A.intTicketId
							,intInventoryReceiptId					= B.intInventoryReceiptId
							,intInvoiceId							= A.intInvoiceId
							,intInventoryShipmentId					= A.intInventoryShipmentId
							,intBillId								= A.intBillId
							,intContractHeaderId					= A.intContractHeaderId
							,dblUnits								= B.dblOpenReceive
							,dtmHistoryDate							= B.dtmReceiptDate
							,dblPaidAmount							= A.dblPaidAmount
							,strPaidDescription						= A.strPaidDescription
							,dblCurrencyRate						= A.dblCurrencyRate
							,strType								= A.strType
							,strUserName							= NULL
							,intUserId								= B.intEntityId
							,intTransactionTypeId					= A.intTransactionTypeId
							,intEntityId							= A.intEntityId
							,intCompanyLocationId					= A.intCompanyLocationId
							,strTransferTicket						= A.strTransferTicket
							,strSettleTicket						= A.strSettleTicket
							,strVoucher								= strVoucher
							,intSettleStorageId						= A.intSettleStorageId
							,intDeliverySheetId						= A.intDeliverySheetId
							,dtmDistributionDate					= B.dtmDateCreated
							,strTransactionId						= A.strTransactionId
							,intTransferStorageId					= A.intTransferStorageId
							,ysnPost								= A.ysnPost
							,intInventoryAdjustmentId				= A.intInventoryAdjustmentId
							,dblOldCost								= A.dblOldCost
						FROM tblGRStorageHistory A
							,(SELECT TOP 1 
									AA.intEntityId
									,AA.intInventoryReceiptId
									,BB.dblOpenReceive
									,AA.dtmReceiptDate
									,AA.dtmDateCreated
								FROM tblICInventoryReceipt AA
								INNER JOIN tblICInventoryReceiptItem BB
									ON  AA.intInventoryReceiptId = BB.intInventoryReceiptId
								WHERE AA.intInventoryReceiptId = @_intReversalReceiptShipmentId) B
						WHERE A.intInventoryReceiptId = @_intInventoryReceiptShipmentId

						--update customer storage
						UPDATE tblGRCustomerStorage
						SET dblOriginalBalance = dbo.[fnGRCalculateStorageUnits](@intCustomerStorageId)
							,dblOpenBalance = dbo.[fnGRCalculateStorageUnits](@intCustomerStorageId)
						WHERE intCustomerStorageId = @intCustomerStorageId

						--Update storage discount
						IF(ISNULL(@intDeliverySheetId,0) = 0) 
						BEGIN

							--backup discount
							INSERT INTO [dbo].[tblSCTicketDiscountHistory]
								([intTicketDiscountId]
								,[intConcurrencyId]
								,[dblGradeReading]
								,[strCalcMethod]
								,[strShrinkWhat]
								,[dblShrinkPercent]
								,[dblDiscountAmount]
								,[dblDiscountDue]
								,[dblDiscountPaid]
								,[ysnGraderAutoEntry]
								,[intDiscountScheduleCodeId]
								,[dtmDiscountPaidDate]
								,[intTicketId]
								,[intTicketFileId]
								,[strSourceType]
								,[intSort]
								,[strDiscountChargeType]
								,[dtmCreatedDate])
							SELECT 
								[intTicketDiscountId]
								,[intConcurrencyId] =1
								,[dblGradeReading]
								,[strCalcMethod]
								,[strShrinkWhat]
								,[dblShrinkPercent]
								,[dblDiscountAmount]
								,[dblDiscountDue]
								,[dblDiscountPaid]
								,[ysnGraderAutoEntry]
								,[intDiscountScheduleCodeId]
								,[dtmDiscountPaidDate]
								,[intTicketId]
								,[intTicketFileId]
								,[strSourceType]
								,[intSort]
								,[strDiscountChargeType]
								,[dtmCreatedDate] = GETDATE()
							FROM tblQMTicketDiscount A
							WHERE intTicketFileId = @intCustomerStorageId
								AND strSourceType = 'Storage'
								AND NOT EXISTS(SELECT TOP 1 1 FROM tblSCTicketDiscountHistory WHERE intTicketDiscountId = A.intTicketDiscountId)

							--delete old discount
							DELETE FROM tblQMTicketDiscount
							WHERE intTicketFileId = @intCustomerStorageId
								AND strSourceType = 'Storage'

						END
						ELSE
						BEGIN
							--Discount is updated during posting of delivery sheet
							print 'with delivery sheet'
						END

						
					END

					---- Update contract schedule if ticket Distribution type is load and link it to reversal IR
					BEGIN
						SET @_ysnReceiptShipmetContainTicketContract = 0 
						SET @_intInventoryReceiptShipmentItemId = 0

						SELECT TOP 1 
								@_intInventoryReceiptShipmentItemId = B.intInventoryReceiptItemId
						FROM tblICInventoryReceipt A
						INNER JOIN tblICInventoryReceiptItem B
							ON A.intInventoryReceiptId = B.intInventoryReceiptId
						WHERE A.intInventoryReceiptId = @_intInventoryReceiptShipmentId
							AND intContractDetailId = @intTicketContractDetailId
						
						IF(ISNULL(@_intInventoryReceiptShipmentItemId,0) > 0)		
						BEGIN
							SET @_ysnReceiptShipmetContainTicketContract = 1  
						END

						IF(@strDistributionOption = 'LOD')
						BEGIN
							--- check if the current loop IS have the selected contract in ticket
							IF(@_ysnReceiptShipmetContainTicketContract = 1)							
							BEGIN

								SET @_ysnLoadBaseContract = 0
								SELECT TOP 1 
									@_ysnLoadBaseContract = ysnLoad
								FROM tblCTContractHeader A
								INNER JOIN tblCTContractDetail B
									ON A.intContractHeaderId = B.intContractHeaderId
								WHERE intContractDetailId = @intTicketContractDetailId

								SET @_ysnLoadBaseContract = ISNULL(@_ysnLoadBaseContract,0)

								--NON Load based contract
								IF(@_ysnLoadBaseContract = 0)
								BEGIN
									SET @_dblLoadUsedQty = 0
									SELECT TOP 1 
										@_dblLoadUsedQty = dblQty
									FROM tblSCTicketLoadUsed
									WHERE intTicketId = @intTicketId
										AND intLoadDetailId = @intTicketLoadDetailId
										AND intEntityId = @_intInventoryReceiptShipmentEntityId

									SET @_dblContractAvailableQty = 0
									SELECT TOP 1 
										@_dblContractAvailableQty = ISNULL(dblAvailableQtyInItemStockUOM,0)
									FROM vyuCTContractDetailView
									WHERE intContractDetailId = @intTicketContractDetailId

									IF @dblTicketScheduledQty <= @_dblContractAvailableQty
									BEGIN
										SET @_dblLoadUsedQty = @dblTicketScheduledQty
									END
									ELSE
									BEGIN
										SET @_dblLoadUsedQty = @_dblContractAvailableQty
									END

									IF @_dblLoadUsedQty <> 0
									BEGIN
							
										EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, @_dblLoadUsedQty, @intUserId, @_intInventoryReceiptShipmentItemId, 'Inventory Receipt', @intTicketItemUOMId
									END
								END
								ELSE ---Load based contract
								BEGIN
									EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, 1, @intUserId, @_intInventoryReceiptShipmentItemId, 'Inventory Receipt', @intTicketItemUOMId
								END
							END
						END
					END

					
				END



				-------------------------- Loop Iterator
				IF NOT EXISTS (SELECT TOP 1 1 FROM @TicketReceiptShipmentIds WHERE intId > @_intInventoryReceiptShipmentId)
				BEGIN
					SET @_intInventoryReceiptShipmentId = 0
				END
				ELSE
				BEGIN
					SELECT TOP 1 
						@_intInventoryReceiptShipmentId = MIN(intId)
					FROM @TicketReceiptShipmentIds
					WHERE intId > @_intInventoryReceiptShipmentId
					
				END
			END

			
		END
		ELSE
		BEGIN
			--GEt all IS for the ticket that don't have reversals
			BEGIN
				INSERT INTO @TicketReceiptShipmentIds
				SELECT DISTINCT
					A.intInventoryShipmentId
				FROM tblICInventoryShipment A
				INNER JOIN tblICInventoryShipmentItem B
					ON A.intInventoryShipmentId = B.intInventoryShipmentId
				WHERE A.intSourceType = 1
					AND B.intSourceId = @intTicketId
					AND ISNULL(A.strDataSource,'') <> 'Reversal'
					AND NOT EXISTS(SELECT TOP 1 1 FROM tblICInventoryShipment WHERE intSourceInventoryShipmentId = A.intInventoryShipmentId)
				ORDER BY A.intInventoryShipmentId ASC
			END

			SELECT TOP 1 
				@_intInventoryReceiptShipmentId = MIN(intId)
			FROM @TicketReceiptShipmentIds
			

			---Create IS reversal
			WHILE ISNULL(@_intInventoryReceiptShipmentId,0) > 0
			BEGIN
				SET @_intReversalReceiptShipmentId = 0
				
				EXEC uspICReverseInventoryShipment NULL,@_intInventoryReceiptShipmentId, @intUserId, NULL, @_intReversalReceiptShipmentId OUTPUT

				IF ISNULL(@_intReversalReceiptShipmentId,0) > 0
				BEGIN
					SELECT TOP 1 
						@_strReceiptShipmentNumber = strShipmentNumber
					FROM tblICInventoryShipment
					WHERE intInventoryShipmentId = @_intReversalReceiptShipmentId

					EXEC dbo.uspICPostInventoryShipment 1, 0, @_strReceiptShipmentNumber, @intUserId;

					-----insert into storage history of storage based on the previous IS			
					BEGIN
						SET @intCustomerStorageId = 0
						SET @intCustomerStorageId = (SELECT TOP 1 intCustomerStorageId FROM tblGRStorageHistory WHERE intInventoryShipmentId = @_intInventoryReceiptShipmentId)
						IF ISNULL(@intCustomerStorageId,0)> 0
						BEGIN

							INSERT INTO tblGRStorageHistory (
								intConcurrencyId
								,intCustomerStorageId
								,intTicketId
								,intInventoryReceiptId
								,intInvoiceId
								,intInventoryShipmentId
								,intBillId
								,intContractHeaderId
								,dblUnits
								,dtmHistoryDate
								,dblPaidAmount
								,strPaidDescription
								,dblCurrencyRate
								,strType
								,strUserName
								,intUserId
								,intTransactionTypeId
								,intEntityId
								,intCompanyLocationId
								,strTransferTicket
								,strSettleTicket
								,strVoucher
								,intSettleStorageId
								,intDeliverySheetId
								,dtmDistributionDate
								,strTransactionId
								,intTransferStorageId
								,ysnPost
								,intInventoryAdjustmentId
								,dblOldCost

							)
							SELECT TOP 1
								intConcurrencyId						= 1
								,intCustomerStorageId					= A.intCustomerStorageId
								,intTicketId							= A.intTicketId
								,intInventoryReceiptId					= A.intInventoryReceiptId
								,intInvoiceId							= A.intInvoiceId
								,intInventoryShipmentId					= B.intInventoryShipmentId
								,intBillId								= A.intBillId
								,intContractHeaderId					= A.intContractHeaderId
								,dblUnits								= B.dblQuantity
								,dtmHistoryDate							= B.dtmShipDate
								,dblPaidAmount							= A.dblPaidAmount
								,strPaidDescription						= A.strPaidDescription
								,dblCurrencyRate						= A.dblCurrencyRate
								,strType								= A.strType
								,strUserName							= NULL
								,intUserId								= B.intEntityId
								,intTransactionTypeId					= A.intTransactionTypeId
								,intEntityId							= A.intEntityId
								,intCompanyLocationId					= A.intCompanyLocationId
								,strTransferTicket						= A.strTransferTicket
								,strSettleTicket						= A.strSettleTicket
								,strVoucher								= strVoucher
								,intSettleStorageId						= A.intSettleStorageId
								,intDeliverySheetId						= A.intDeliverySheetId
								,dtmDistributionDate					= B.dtmDateCreated
								,strTransactionId						= A.strTransactionId
								,intTransferStorageId					= A.intTransferStorageId
								,ysnPost								= A.ysnPost
								,intInventoryAdjustmentId				= A.intInventoryAdjustmentId
								,dblOldCost								= A.dblOldCost
							FROM tblGRStorageHistory A
								,(SELECT TOP 1 
										AA.intEntityId
										,AA.intInventoryShipmentId
										,BB.dblQuantity
										,AA.dtmShipDate
										,AA.dtmDateCreated
									FROM tblICInventoryShipment AA
									INNER JOIN tblICInventoryShipmentItem BB
										ON  AA.intInventoryShipmentId = BB.intInventoryShipmentId
									WHERE AA.intInventoryShipmentId = @_intReversalReceiptShipmentId) B
							WHERE A.intInventoryShipmentId = @_intInventoryReceiptShipmentId


							
							--update customer storage
							BEGIN
								--update orignal and open balance
								UPDATE tblGRCustomerStorage
								SET dblOriginalBalance = dbo.[fnGRCalculateStorageUnits](@intCustomerStorageId)
									,dblOpenBalance = dbo.[fnGRCalculateStorageUnits](@intCustomerStorageId)
								WHERE intCustomerStorageId = @intCustomerStorageId
							END
						END

					END

					---- Update contract schedule if ticket Distribution type is load and link it to reversal IS
						BEGIN
							SET @_ysnReceiptShipmetContainTicketContract = 0 
							SET @_intInventoryReceiptShipmentItemId = 0

							SELECT TOP 1 
									@_intInventoryReceiptShipmentItemId = B.intInventoryShipmentItemId
							FROM tblICInventoryShipmentItem A
							INNER JOIN tblICInventoryShipmentItem B
								ON A.intInventoryShipmentId = B.intInventoryShipmentId
							WHERE A.intInventoryShipmentId = @_intInventoryReceiptShipmentId
								AND B.intLineNo  = @intTicketContractDetailId
							
							IF(ISNULL(@_intInventoryReceiptShipmentItemId,0) > 0)		
							BEGIN
								SET @_ysnReceiptShipmetContainTicketContract = 1  
							END

							IF(@strDistributionOption = 'LOD')
							BEGIN
								--- check if the current loop IS have the selected contract in ticket
								IF(@_ysnReceiptShipmetContainTicketContract = 1)							
								BEGIN

									SET @_ysnLoadBaseContract = 0
									SELECT TOP 1 
										@_ysnLoadBaseContract = ysnLoad
									FROM tblCTContractHeader A
									INNER JOIN tblCTContractDetail B
										ON A.intContractHeaderId = B.intContractHeaderId
									WHERE intContractDetailId = @intTicketContractDetailId

									SET @_ysnLoadBaseContract = ISNULL(@_ysnLoadBaseContract,0)

									--NON Load based contract
									IF(@_ysnLoadBaseContract = 0)
									BEGIN
										SET @_dblLoadUsedQty = 0
										SELECT TOP 1 
											@_dblLoadUsedQty = dblQty
										FROM tblSCTicketLoadUsed
										WHERE intTicketId = @intTicketId
											AND intLoadDetailId = @intTicketLoadDetailId
											AND intEntityId = @_intInventoryReceiptShipmentEntityId

										SET @_dblContractAvailableQty = 0
										SELECT TOP 1 
											@_dblContractAvailableQty = ISNULL(dblAvailableQtyInItemStockUOM,0)
										FROM vyuCTContractDetailView
										WHERE intContractDetailId = @intTicketContractDetailId

										IF @dblTicketScheduledQty <= @_dblContractAvailableQty
										BEGIN
											SET @_dblLoadUsedQty = @dblTicketScheduledQty
										END
										ELSE
										BEGIN
											SET @_dblLoadUsedQty = @_dblContractAvailableQty
										END

										IF @_dblLoadUsedQty <> 0
										BEGIN
								
											EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, @_dblLoadUsedQty, @intUserId, @_intInventoryReceiptShipmentItemId, 'Inventory Shipment', @intTicketItemUOMId
										END
									END
									ELSE ---Load based contract
									BEGIN
										EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, 1, @intUserId, @_intInventoryReceiptShipmentItemId, 'Inventory Shipment', @intTicketItemUOMId
									END
								END
							END
						END
					

				END

			
				-------------------------- Loop Iterator
				IF NOT EXISTS (SELECT TOP 1 1 FROM @TicketReceiptShipmentIds WHERE intId > @_intInventoryReceiptShipmentId)
				BEGIN
					SET @_intInventoryReceiptShipmentId = 0
				END
				ELSE
				BEGIN
					SELECT TOP 1 
						@_intInventoryReceiptShipmentId = MIN(intId)
					FROM @TicketReceiptShipmentIds
					WHERE intId > @_intInventoryReceiptShipmentId
					
				END
			END
		END

		-----Single Ticket Transfer reversal
		IF @intTicketType = 7		
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult'))
			BEGIN
				CREATE TABLE #tmpAddInventoryTransferResult (
					intSourceId INT
					,intInventoryTransferId INT
				)
			END
			
			-- Insert the data needed to create the inventory transfer.
			INSERT INTO @TransferEntries (
				-- Header
				[dtmTransferDate]
				,[strTransferType]
				,[intSourceType]
				,[strDescription]
				,[intFromLocationId]
				,[intToLocationId]
				,[ysnShipmentRequired]
				,[intStatusId]
				,[intShipViaId]
				,[intFreightUOMId]
				-- Detail
				,[intItemId]
				,[intLotId]
				,[intItemUOMId]
				,[dblQuantityToTransfer]
				,[intItemWeightUOMId]		
				,[dblGrossWeight]			
				,[dblTareWeight]			
				,[strNewLotId]
				,[intFromSubLocationId]
				,[intToSubLocationId]
				,[intFromStorageLocationId]
				,[intToStorageLocationId]
				,[ysnWeights]
				-- Integration Field
				,[intInventoryTransferId]
				,[intSourceId]   
				,[strSourceId]  
				,[strSourceScreenName]
			)
			SELECT      
				-- Header
				[dtmTransferDate]           = GETDATE()
				,[strTransferType]          = 'Location to Location'
				,[intSourceType]            = 1
				,[strDescription]           = (select top 1 strDescription from vyuICGetItemStock IC where SC.intItemId = IC.intItemId)
				,[intFromLocationId]        = SC.intTransferLocationId
				,[intToLocationId]          = SC.intProcessingLocationId
				,[ysnShipmentRequired]      = 0
				,[intStatusId]              = 1
				,[intShipViaId]             = NULL
				,[intFreightUOMId]          = NULL
				-- Detail
				,[intItemId]                = SC.intItemId
				,[intLotId]                 = SC.intLotId
				,[intItemUOMId]             = SC.intItemUOMIdTo
				,[dblQuantityToTransfer]    = SC.dblNetUnits
				,[intItemWeightUOMId]		= CASE WHEN ISNULL(@intLotType,0) != 0 AND ISNULL(IC.ysnLotWeightsRequired,0) = 1 THEN SC.intItemUOMIdFrom ELSE SC.intItemUOMIdTo END
				,[dblGrossWeight]			= CASE WHEN ISNULL(@intLotType,0) != 0 AND ISNULL(IC.ysnLotWeightsRequired,0) = 1 THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo, SC.intItemUOMIdFrom, SC.dblGrossUnits) ELSE SC.dblGrossUnits END
				,[dblTareWeight]			= CASE WHEN ISNULL(@intLotType,0) != 0 AND ISNULL(IC.ysnLotWeightsRequired,0) = 1 THEN dbo.fnCalculateQtyBetweenUOM(SC.intItemUOMIdTo, SC.intItemUOMIdFrom, SC.dblShrink) ELSE CASE WHEN SC.dblShrink > 0 THEN SC.dblShrink ELSE 0 END END
				,[strNewLotId]              = NULL
				,[intFromSubLocationId]     = SC.intSubLocationToId
				,[intToSubLocationId]       = SC.intSubLocationId
				,[intFromStorageLocationId] = SC.intStorageLocationToId
				,[intToStorageLocationId]   = SC.intStorageLocationId  
				,[ysnWeights]				= CASE
												WHEN SC.intWeightId > 0 THEN 1
												ELSE 0
											END
				-- Integration Field
				,[intInventoryTransferId]   = NULL
				,[intSourceId]              = SC.intTicketId
				,[strSourceId]				= SC.strTicketNumber
				,[strSourceScreenName]		= 'Scale Ticket'
			FROM tblSCTicket SC 
			INNER JOIN tblSCScaleSetup SCS ON SC.intScaleSetupId = SCS.intScaleSetupId
			INNER JOIN tblICItem IC ON IC.intItemId = SC.intItemId
			WHERE SC.intTicketId = @intTicketId 

			---- create transfer
			EXEC dbo.uspICAddInventoryTransfer
						@TransferEntries
						,@intUserId

			--Post Transfer
			BEGIN
				SELECT TOP 1 
					@_intInventoryTransfer = intInventoryTransferId 
				FROM #tmpAddInventoryTransferResult
				

				SELECT TOP 1
					@_strInventoryTransferNumber = strTransferNo
				FROM tblICInventoryTransfer
				WHERE intInventoryTransferId = @_intInventoryTransfer

				EXEC [dbo].[uspICPostInventoryTransfer] 1, 0, @_strInventoryTransferNumber, @intUserId;
			END	
		END
	
		--- Generate reversal ticket number
		BEGIN
			SET @intRecordCounter = 1
			SET @strReversalTicketNumber = @strTicketNumber + '-R'
			WHILE EXISTS(	SELECT TOP 1 1
							FROM tblSCTicket 
							WHERE strTicketNumber = @strReversalTicketNumber
								AND [intTicketPoolId] = @intTicketPoolId
								AND [intTicketType] = @intTicketType
								AND [strInOutFlag] = @strInOutFlag
								AND [strTicketNumber] = @strReversalTicketNumber
								AND [intProcessingLocationId] = @intProcessingLocationId)
			BEGIN
				SET @strReversalTicketNumber = @strTicketNumber + '-R-' + CAST(@intRecordCounter AS NVARCHAR)
				SET @intRecordCounter = @intRecordCounter + 1
			END
		END

		---delinking of load
		IF(@strDistributionOption = 'LOD')
		BEGIN
			EXEC uspLGUpdateLoadDetails @intTicketLoadDetailId, 0
		END

		--Mark the ticket as void and reveresed
		UPDATE tblSCTicket
		SET strTicketStatus = 'V'
			,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
			,dtmTicketVoidDateTime = GETDATE()
			,ysnReversed = 1
			,strTicketNumber = @strReversalTicketNumber 
		WHERE intTicketId = @intTicketId

		--Duplicate Ticket
		BEGIN
			--tblSCTicket
			INSERT INTO [dbo].[tblSCTicket]
					([strTicketStatus]
					,[strTicketNumber]
					,[strOriginalTicketNumber]
					,[intScaleSetupId]
					,[intTicketPoolId]
					,[intTicketLocationId]
					,[intTicketType]
					,[strInOutFlag]
					,[dtmTicketDateTime]
					,[dtmTicketTransferDateTime]
					,[dtmTicketVoidDateTime]
					,[dtmTransactionDateTime]
					,[intProcessingLocationId]
					,[intTransferLocationId]
					,[strScaleOperatorUser]
					,[intEntityScaleOperatorId]
					,[strTruckName]
					,[strDriverName]
					,[ysnDriverOff]
					,[ysnSplitWeightTicket]
					,[ysnGrossManual]
					,[ysnGross1Manual]
					,[ysnGross2Manual]
					,[dblGrossWeight]
					,[dblGrossWeight1]
					,[dblGrossWeight2]
					,[dblGrossWeightOriginal]
					,[dblGrossWeightSplit1]
					,[dblGrossWeightSplit2]
					,[dtmGrossDateTime]
					,[dtmGrossDateTime1]
					,[dtmGrossDateTime2]
					,[intGrossUserId]
					,[ysnTareManual]
					,[ysnTare1Manual]
					,[ysnTare2Manual]
					,[dblTareWeight]
					,[dblTareWeight1]
					,[dblTareWeight2]
					,[dblTareWeightOriginal]
					,[dblTareWeightSplit1]
					,[dblTareWeightSplit2]
					,[dtmTareDateTime]
					,[dtmTareDateTime1]
					,[dtmTareDateTime2]
					,[intTareUserId]
					,[dblGrossUnits]
					,[dblShrink]
					,[dblNetUnits]
					,[strItemUOM]
					,[intCustomerId]
					,[intSplitId]
					,[strDistributionOption]
					,[intDiscountSchedule]
					,[strDiscountLocation]
					,[dtmDeferDate]
					,[strContractNumber]
					,[intContractSequence]
					,[strContractLocation]
					,[dblUnitPrice]
					,[dblUnitBasis]
					,[dblTicketFees]
					,[intCurrencyId]
					,[dblCurrencyRate]
					,[strTicketComment]
					,[strCustomerReference]
					,[ysnTicketPrinted]
					,[ysnPlantTicketPrinted]
					,[ysnGradingTagPrinted]
					,[intHaulerId]
					,[intFreightCarrierId]
					,[dblFreightRate]
					,[dblFreightAdjustment]
					,[intFreightCurrencyId]
					,[dblFreightCurrencyRate]
					,[strFreightCContractNumber]
					,[ysnFarmerPaysFreight]
					,[ysnCusVenPaysFees]
					,[strLoadNumber]
					,[intLoadLocationId]
					,[intAxleCount]
					,[intAxleCount1]
					,[intAxleCount2]
					,[strPitNumber]
					,[intGradingFactor]
					,[strVarietyType]
					,[strFarmNumber]
					,[strFieldNumber]
					,[strDiscountComment]
					,[intCommodityId]
					,[intDiscountId]
					,[intContractId]
					,[intContractCostId]
					,[intDiscountLocationId]
					,[intItemId]
					,[intEntityId]
					,[intLoadId]
					,[intMatchTicketId]
					,[intSubLocationId]
					,[intStorageLocationId]
					,[intSubLocationToId]
					,[intStorageLocationToId]
					,[intFarmFieldId]
					,[intDistributionMethod]
					,[intSplitInvoiceOption]
					,[intDriverEntityId]
					,[intStorageScheduleId]
					,[intConcurrencyId]
					,[dblNetWeightDestination]
					,[ysnHasGeneratedTicketNumber]
					,[intInventoryTransferId]
					,[intInventoryReceiptId]
					,[intInventoryShipmentId]
					,[intInventoryAdjustmentId]
					,[dblScheduleQty]
					,[dblConvertedUOMQty]
					,[dblContractCostConvertedUOM]
					,[intItemUOMIdFrom]
					,[intItemUOMIdTo]
					,[intTicketTypeId]
					,[intStorageScheduleTypeId]
					,[strFreightSettlement]
					,[strCostMethod]
					,[intGradeId]
					,[intWeightId]
					,[intDeliverySheetId]
					,[intCommodityAttributeId]
					,[strElevatorReceiptNumber]
					,[ysnRailCar]
					,[ysnDeliverySheetPost]
					,[intLotId]
					,[strLotNumber]
					,[intSalesOrderId]
					,[intTicketLVStagingId]
					,[intBillId]
					,[intInvoiceId]
					,[intCompanyId]
					,[intEntityContactId]
					,[strPlateNumber]
					,[blbPlateNumber]
					,[ysnDestinationWeightGradePost]
					,[strSourceType]
					,[ysnReadyToTransfer]
					,[ysnExport]
					,[dtmImportedDate]
					,[strUberStatusCode]
					,[intEntityShipViaTrailerId]
					,[intLoadDetailId]
					,[intCropYearId]
					,[ysnHasSpecialDiscount]
					,[ysnSpecialGradePosted]
					,[intItemContractDetailId]
					,[ysnCertOfAnalysisPosted]
					,[ysnExportRailXML]
					,[strTrailerId]
					,[intParentTicketId]
					,[intTicketTransactionType]
					,[ysnReversed])
			SELECT 	[strTicketStatus] = 'O'
					,[strTicketNumber]	= @strTicketNumber
					,[strOriginalTicketNumber]
					,[intScaleSetupId]
					,[intTicketPoolId]
					,[intTicketLocationId]
					,[intTicketType]
					,[strInOutFlag]
					,[dtmTicketDateTime] = GETDATE()
					,[dtmTicketTransferDateTime] = NULL
					,[dtmTicketVoidDateTime] = NULL
					,[dtmTransactionDateTime]
					,[intProcessingLocationId]
					,[intTransferLocationId]
					,[strScaleOperatorUser]
					,[intEntityScaleOperatorId]
					,[strTruckName]
					,[strDriverName]
					,[ysnDriverOff]
					,[ysnSplitWeightTicket]
					,[ysnGrossManual]
					,[ysnGross1Manual]
					,[ysnGross2Manual]
					,[dblGrossWeight]
					,[dblGrossWeight1]
					,[dblGrossWeight2]
					,[dblGrossWeightOriginal]
					,[dblGrossWeightSplit1]
					,[dblGrossWeightSplit2]
					,[dtmGrossDateTime]
					,[dtmGrossDateTime1]
					,[dtmGrossDateTime2]
					,[intGrossUserId]
					,[ysnTareManual]
					,[ysnTare1Manual]
					,[ysnTare2Manual]
					,[dblTareWeight]
					,[dblTareWeight1]
					,[dblTareWeight2]
					,[dblTareWeightOriginal]
					,[dblTareWeightSplit1]
					,[dblTareWeightSplit2]
					,[dtmTareDateTime]
					,[dtmTareDateTime1]
					,[dtmTareDateTime2]
					,[intTareUserId]
					,[dblGrossUnits]
					,[dblShrink]
					,[dblNetUnits]
					,[strItemUOM]
					,[intCustomerId]
					,[intSplitId]
					,[strDistributionOption]
					,[intDiscountSchedule]
					,[strDiscountLocation]
					,[dtmDeferDate]
					,[strContractNumber]
					,[intContractSequence]
					,[strContractLocation]
					,[dblUnitPrice]
					,[dblUnitBasis]
					,[dblTicketFees]
					,[intCurrencyId]
					,[dblCurrencyRate]
					,[strTicketComment]
					,[strCustomerReference]
					,[ysnTicketPrinted]
					,[ysnPlantTicketPrinted]
					,[ysnGradingTagPrinted]
					,[intHaulerId]
					,[intFreightCarrierId]
					,[dblFreightRate]
					,[dblFreightAdjustment]
					,[intFreightCurrencyId]
					,[dblFreightCurrencyRate]
					,[strFreightCContractNumber]
					,[ysnFarmerPaysFreight]
					,[ysnCusVenPaysFees]
					,[strLoadNumber]
					,[intLoadLocationId]
					,[intAxleCount]
					,[intAxleCount1]
					,[intAxleCount2]
					,[strPitNumber]
					,[intGradingFactor]
					,[strVarietyType]
					,[strFarmNumber]
					,[strFieldNumber]
					,[strDiscountComment]
					,[intCommodityId]
					,[intDiscountId]
					,[intContractId]
					,[intContractCostId]
					,[intDiscountLocationId]
					,[intItemId]
					,[intEntityId]
					,[intLoadId]
					,[intMatchTicketId]
					,[intSubLocationId]
					,[intStorageLocationId]
					,[intSubLocationToId]
					,[intStorageLocationToId]
					,[intFarmFieldId]
					,[intDistributionMethod]
					,[intSplitInvoiceOption]
					,[intDriverEntityId]
					,[intStorageScheduleId]
					,[intConcurrencyId] = 1
					,[dblNetWeightDestination]
					,[ysnHasGeneratedTicketNumber]
					,[intInventoryTransferId] = NULL
					,[intInventoryReceiptId] = NULL
					,[intInventoryShipmentId] = NULL
					,[intInventoryAdjustmentId] = NULL
					,[dblScheduleQty]
					,[dblConvertedUOMQty]
					,[dblContractCostConvertedUOM]
					,[intItemUOMIdFrom]
					,[intItemUOMIdTo]
					,[intTicketTypeId]
					,[intStorageScheduleTypeId]
					,[strFreightSettlement]
					,[strCostMethod]
					,[intGradeId]
					,[intWeightId]
					,[intDeliverySheetId]
					,[intCommodityAttributeId]
					,[strElevatorReceiptNumber]
					,[ysnRailCar]
					,[ysnDeliverySheetPost] = 0
					,[intLotId]
					,[strLotNumber]
					,[intSalesOrderId]
					,[intTicketLVStagingId]
					,[intBillId]
					,[intInvoiceId]
					,[intCompanyId]
					,[intEntityContactId]
					,[strPlateNumber]
					,[blbPlateNumber]
					,[ysnDestinationWeightGradePost]
					,[strSourceType]
					,[ysnReadyToTransfer]
					,[ysnExport] = 0
					,[dtmImportedDate]
					,[strUberStatusCode]
					,[intEntityShipViaTrailerId]
					,[intLoadDetailId]
					,[intCropYearId]
					,[ysnHasSpecialDiscount]
					,[ysnSpecialGradePosted] = 0
					,[intItemContractDetailId]
					,[ysnCertOfAnalysisPosted] = 0
					,[ysnExportRailXML]
					,[strTrailerId]
					,[intParentTicketId] = @intTicketId
					,[intTicketTransactionType]
					,[ysnReversed] = 0
			FROM tblSCTicket
			WHERE intTicketId = @intTicketId
		
			SET @intDuplicateTicketId = SCOPE_IDENTITY()
					
			--Discount
			INSERT INTO [dbo].[tblQMTicketDiscount]
					([intConcurrencyId]
					,[dblGradeReading]
					,[strCalcMethod]
					,[strShrinkWhat]
					,[dblShrinkPercent]
					,[dblDiscountAmount]
					,[dblDiscountDue]
					,[dblDiscountPaid]
					,[ysnGraderAutoEntry]
					,[intDiscountScheduleCodeId]
					,[dtmDiscountPaidDate]
					,[intTicketId]
					,[intTicketFileId]
					,[strSourceType]
					,[intSort]
					,[strDiscountChargeType])
			SELECT 	[intConcurrencyId] = 1
					,[dblGradeReading]
					,[strCalcMethod]
					,[strShrinkWhat]
					,[dblShrinkPercent]
					,[dblDiscountAmount]
					,[dblDiscountDue]
					,[dblDiscountPaid]
					,[ysnGraderAutoEntry]
					,[intDiscountScheduleCodeId]
					,[dtmDiscountPaidDate]
					,[intTicketId] = @intDuplicateTicketId 
					,[intTicketFileId]  
					,[strSourceType]
					,[intSort]
					,[strDiscountChargeType]
			FROM tblQMTicketDiscount
			WHERE intTicketId = @intTicketId
				AND strSourceType = 'Scale'

			--Split
			INSERT INTO [dbo].[tblSCTicketSplit]
				([intTicketId]
				,[intCustomerId]
				,[dblSplitPercent]
				,[intStorageScheduleTypeId]
				,[strDistributionOption]
				,[intStorageScheduleId]
				,[intConcurrencyId])
			SELECT 
				[intTicketId] = @intDuplicateTicketId 
				,[intCustomerId]
				,[dblSplitPercent]
				,[intStorageScheduleTypeId]
				,[strDistributionOption]
				,[intStorageScheduleId]
				,[intConcurrencyId] = 1
			FROM tblSCTicketSplit 
			WHERE intTicketId = @intTicketId

			--SealNumber
			INSERT INTO [dbo].[tblSCTicketSealNumber]
				([intTicketId]
				,[intSealNumberId]
				,[intTruckDriverReferenceId]
				,[intUserId]
				,[intConcurrencyId])
			SELECT 
				[intTicketId] = @intDuplicateTicketId 
				,[intSealNumberId]
				,[intTruckDriverReferenceId]
				,[intUserId]
				,[intConcurrencyId] = 1
			FROM tblSCTicketSealNumber
			WHERE intTicketId = @intTicketId

			--CofA
			INSERT INTO [dbo].[tblSCTicketCertificateOfAnalysis]
				([intTicketId]
				,[dblReading]
				,[intCertificateOfAnalysisId]
				,[intEnteredByUserId]
				,[dtmDateEntered]
				,[intConcurrencyId])
			SELECT [intTicketId] = @intDuplicateTicketId 
				,[dblReading]
				,[intCertificateOfAnalysisId]
				,[intEnteredByUserId]
				,[dtmDateEntered]
				,[intConcurrencyId]
			FROM tblSCTicketCertificateOfAnalysis

		END

		--Apply load to the reversed ticket
		IF(@strDistributionOption = 'LOD')
		BEGIN
			EXEC uspLGUpdateLoadDetails @intTicketLoadDetailId, 1, @intDuplicateTicketId
		END

		--Apply Contract to the reversed ticket
		IF(@strDistributionOption = 'CNT')
		BEGIN

			SET @_ysnLoadBaseContract = 0
			SELECT TOP 1 
				@_ysnLoadBaseContract = ysnLoad
			FROM tblCTContractHeader A
			INNER JOIN tblCTContractDetail B
				ON A.intContractHeaderId = B.intContractHeaderId
			WHERE intContractDetailId = @intTicketContractDetailId

			IF(ISNULL(@_ysnLoadBaseContract,0) = 0)
			BEGIN
				EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, @dblTicketScheduledQty, @intUserId, @intDuplicateTicketId, 'Scale', @intTicketItemUOMId
			END
			ELSE
			BEGIN
				SET @dblTicketScheduledQty = 1
				EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, @dblTicketScheduledQty, @intUserId, @intDuplicateTicketId, 'Scale', @intTicketItemUOMId
			END
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


