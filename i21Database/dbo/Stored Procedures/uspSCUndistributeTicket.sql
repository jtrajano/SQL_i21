﻿CREATE PROCEDURE [dbo].[uspSCUndistributeTicket]
	@intTicketId INT,
	@intUserId INT,
	@intEntityId INT,
	@strInOutFlag NVARCHAR(2),
	@ysnTransfer BIT = NULL,
	@ysnDirectShip BIT = NULL,
	@ysnDeliverySheet BIT = NULL
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
		,@ysnIRPosted BIT
        ,@intContractDetailId INT
        ,@intContractStatusId INT
        ,@strContractNumber NVARCHAR(40)
        ,@strContractStatus NVARCHAR(40)
        ,@intContractSeq INT
        ,@intId INT
		,@intStorageScheduleTypeId INT
		,@dblScheduleQty NUMERIC(38,20)
		,@intMatchTicketItemUOMId INT
		,@intMatchLoadId INT
		,@intMatchLoadDetailId INT
		,@intMatchLoadContractId INT
		,@dblMatchScheduledUnits NUMERIC(38,20)
		,@dblMatchDeliveredQuantity NUMERIC(38,20)
		,@dblMatchLoadScheduledUnits NUMERIC(38,20)
		,@strMatchTicketStatus NVARCHAR(40)
		,@intTicketType INT;
DECLARE @intTicketLoadDetailId INT
DECLARE @intLoopLoadDetailId INT
DECLARE @intTicketItemUOMId INT
DECLARE @strDistributionOption NVARCHAR(20)
DECLARE @dblTicketScheduledQty NUMERIC(18,6)
DECLARE @intTicketContractDetailId INT
DECLARE @ysnLoadContract BIT
DECLARE @intTicketEntityId INT
DECLARE @intInventoryShipmentEntityId INT

DECLARE @intLoopContractDetailId INT
DECLARE @intLoopId INT
DECLARE @dblLoopScheduleQty NUMERIC(18,6)
DECLARE @intLoopCurrentId INT
DECLARE @UNDISTRIBUTE_NOT_ALLOWED NVARCHAR(100)
DECLARE @dblLoadUsedQty NUMERIC(18,6)
DECLARE @dblScheduleQtyToUpdate NUMERIC(18,6)

SET @UNDISTRIBUTE_NOT_ALLOWED = 'Un-distribute ticket with posted invoice is not allowed.'
declare @intInventoryAdjustmentId int
declare @strAdjustmentNo AS NVARCHAR(40)
DECLARE @ysnAllInvoiceHasCreditMemo BIT
DECLARE @strInvoiceNumber AS NVARCHAR(50)
DECLARE @NeedCreditMemoMessage NVARCHAR(200)
DECLARE @ysnTicketHasSpecialDiscount BIT

BEGIN TRY
		SELECT TOP 1
			@intTicketItemUOMId = SC.intItemUOMIdTo
			,@strDistributionOption = SC.strDistributionOption
			,@dblTicketScheduledQty = SC.dblScheduleQty
			,@intTicketContractDetailId = SC.intContractId
			,@ysnTicketHasSpecialDiscount = ysnHasSpecialDiscount
			,@intTicketLoadDetailId = intLoadDetailId
			,@intTicketEntityId = intEntityId
		FROM tblSCTicket SC
		WHERE intTicketId = @intTicketId

		IF ISNULL(@ysnDeliverySheet, 0) = 0
		BEGIN
			SELECT @intLoadId = LGLD.intLoadId ,@intLoadDetailId = LGLD.intLoadDetailId
			, @dblDeliveredQuantity = LGLD.dblDeliveredQuantity
			, @dblLoadScheduledUnits = LGLD.dblQuantity
			, @intLoadContractId = CASE WHEN @strInOutFlag = 'I' THEN LGLD.intPContractDetailId WHEN @strInOutFlag = 'O' THEN LGLD.intSContractDetailId END
			FROM tblLGLoad LGL INNER JOIN vyuLGLoadDetailView LGLD ON LGL.intLoadId = LGLD.intLoadId 
			WHERE LGL.intTicketId = @intTicketId

			IF ISNULL(@ysnDirectShip,0) = 0 AND ISNULL(@intEntityId,0) > 0
			BEGIN
				SELECT @intId = MIN(intInventoryReceiptItemId) 
				FROM vyuICGetInventoryReceiptItem where intSourceId = @intTicketId and strSourceType = 'Scale' AND intInventoryReceiptItemId > @intId
				WHILE ISNULL(@intId,0) > 0
				BEGIN
					SELECT @intContractDetailId = intLineNo FROM tblICInventoryReceiptItem WHERE intInventoryReceiptItemId = @intId
					IF ISNULL(@intContractDetailId,0) > 0
					BEGIN
						SELECT @intContractStatusId = intContractStatusId
						, @strContractStatus = strContractStatus 
						, @intContractSeq = intContractSeq
						, @strContractNumber = strContractNumber 
						from vyuCTContractDetailView WHERE intContractDetailId = @intContractDetailId
						IF ISNULL(@intContractStatusId, 0) != 1 AND ISNULL(@intContractStatusId, 0) != 4
						BEGIN
							SET @ErrorMessage = 'Contract ' + @strContractNumber +'-Seq.' + CAST(@intContractSeq AS nvarchar) + ' is ' + @strContractStatus +'. Please Open before Undistributing.';
							RAISERROR(@ErrorMessage, 11, 1);
							RETURN;
						END
					END
					SELECT @intId = MIN(intInventoryReceiptItemId) 
					FROM vyuICGetInventoryReceiptItem where intSourceId = @intTicketId and strSourceType = 'Scale' AND intInventoryReceiptItemId > @intId
				END
			END

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
						SELECT intInventoryReceiptId,  strReceiptNumber, ysnPosted
						FROM #tmpItemReceiptIds

						OPEN intListCursor;

						-- Initial fetch attempt
						FETCH NEXT FROM intListCursor INTO @InventoryReceiptId, @strTransactionId, @ysnIRPosted;

						WHILE @@FETCH_STATUS = 0
						BEGIN
							DECLARE @_intIRVendorId INT
							SELECT @_intIRVendorId = intEntityVendorId FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @InventoryReceiptId
							IF OBJECT_ID (N'tempdb.dbo.#tmpVoucherDetail') IS NOT NULL
								DROP TABLE #tmpVoucherDetail
							CREATE TABLE #tmpVoucherDetail (
								[intBillId] [INT] PRIMARY KEY,
								UNIQUE ([intBillId])
							);
							INSERT INTO #tmpVoucherDetail(intBillId)SELECT DISTINCT(AP.intBillId) FROM tblAPBillDetail AP
							LEFT JOIN tblICInventoryReceiptItem IC ON IC.intInventoryReceiptItemId = AP.intInventoryReceiptItemId
							WHERE IC.intInventoryReceiptId = @InventoryReceiptId
							SELECT @InventoryReceiptId
							DECLARE voucherCursor CURSOR LOCAL FAST_FORWARD
							FOR
							SELECT intBillId FROM #tmpVoucherDetail
							OPEN voucherCursor;
							FETCH NEXT FROM voucherCursor INTO @intBillId;
							WHILE @@FETCH_STATUS = 0
							BEGIN								
								EXEC [dbo].[uspAPDeletePayment] @intBillId, @intUserId
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

								DELETE FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @intBillId
								EXEC [dbo].[uspAPDeleteVoucher] @intBillId, @intUserId
								/*
									uspAPDeleteVoucher removes the payables from Voucher
									uspICPostInventoryReceipt deletes payable
								*/
								--EXEC [dbo].[uspSCProcessTicketPayables] @intTicketId = @intTicketId, @intInventoryReceiptId = @InventoryReceiptId, @intUserId = @intUserId,@ysnAdd = 0, @strErrorMessage = @ErrorMessage OUT, @intBillId = DEFAULT
								FETCH NEXT FROM voucherCursor INTO @intBillId;
							END

							CLOSE voucherCursor  
							DEALLOCATE voucherCursor
							
							IF ISNULL(@ysnIRPosted, 0) = 1
								EXEC [dbo].[uspICPostInventoryReceipt] 0, 0, @strTransactionId, @intUserId
							EXEC [dbo].[uspGRReverseOnReceiptDelete] @InventoryReceiptId
							EXEC [dbo].[uspICDeleteInventoryReceipt] @InventoryReceiptId, @intUserId

							IF(@ysnTicketHasSpecialDiscount = 1)
							BEGIN
								DELETE FROM tblSCInventoryReceiptAllowVoucherTracker
									WHERE intInventoryReceiptId = @InventoryReceiptId
							END

							FETCH NEXT FROM intListCursor INTO @InventoryReceiptId, @strTransactionId, @ysnIRPosted;
						END
						CLOSE intListCursor  
						DEALLOCATE intListCursor 

						-----UPDATE Contract scehdule and balances
						--IF(@strDistributionOption = 'SPL')
						--BEGIN
						--	/* CURSOR for Split Contract*/
						--	DECLARE @intEntityVendorId AS INT
						--	DECLARE @cursor_strDistributionOption AS VARCHAR(MAX)
						--	DECLARE @cursor_intContractDetailId INT
						--	DECLARE @cursor_dblScheduleQty DECIMAL(18,6)
						--	DECLARE @cursor_intInventoryReceiptId INT
							
						--	DECLARE splitCursor CURSOR LOCAL FAST_FORWARD
						--	FOR
						--	SELECT SCC.intContractDetailId ,SCC.intEntityId,SCC.dblScheduleQty,SC.strDistributionOption
						--	FROM tblSCTicketSplit SPL
						--	INNER JOIN tblSCTicketContractUsed SCC 
						--		ON SCC.intTicketId = SCC.intTicketId
						--	INNER JOIN tblSCTicket SC
						--		ON SPL.intTicketId = SC.intTicketId
						--	WHERE SPL.intTicketId = @intTicketId and SCC.intTicketId = @intTicketId and SPL.intCustomerId = SCC.intEntityId and SPL.intCustomerId = @_intIRVendorId

						

						--	OPEN splitCursor;

						--	FETCH NEXT FROM splitCursor INTO @cursor_intContractDetailId, @intEntityVendorId, @cursor_dblScheduleQty, @cursor_strDistributionOption;
						--	WHILE @@FETCH_STATUS = 0
						--	BEGIN
						--		IF(@cursor_strDistributionOption = 'CNT')
						--		BEGIN		

						--			SET @cursor_dblScheduleQty = @cursor_dblScheduleQty *-1
						--			EXEC uspCTUpdateScheduleQuantity @intContractDetailId=@cursor_intContractDetailId,@dblQuantityToUpdate=@cursor_dblScheduleQty,@intUserId=@intUserId,@intExternalId=@intTicketId, @strScreenName= 'Scale'	
										
						--		END
						--		FETCH NEXT FROM splitCursor INTO @cursor_intContractDetailId, @intEntityVendorId, @cursor_dblScheduleQty, @cursor_strDistributionOption;
						--	END

						--	CLOSE splitCursor  
						--	DEALLOCATE splitCursor 

						--	/* END CURSOR for Split Contract*/

						--END
						--ELSE
						--BEGIN
						--	IF(@strDistributionOption = 'LOD')
						--	BEGIN

						--		--Remove contract scheduled by IR
						--		BEGIN
						--			SELECT 
						--				SCC.intContractDetailId 
						--				,intLoopId = SCC.intTicketContractUsed
						--				,SCC.dblScheduleQty
						--			INTO #tmpTicketContractUsed
						--			FROM tblSCTicket SC
						--			INNER JOIN tblSCTicketContractUsed SCC 
						--				ON SC.intTicketId = SCC.intTicketId
						--			WHERE SC.intTicketId = @intTicketId 
						--			ORDER BY SCC.intTicketContractUsed

						--			SET @intLoopId = NULL
									
						--			SELECT TOP 1 
						--				@intLoopContractDetailId = intContractDetailId
						--				,@intLoopId = intLoopId
						--				,@dblLoopScheduleQty = dblScheduleQty
						--			FROM #tmpTicketContractUsed
						--			ORDER BY intLoopId ASC

						--			WHILE @intLoopId IS NOT NULL
						--			BEGIN
						--				SET @intLoopCurrentId = @intLoopId

						--				SET @dblLoopScheduleQty = @dblLoopScheduleQty * -1

						--				-- remove the schedule quantity on contract
						--				EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractDetailId, @dblLoopScheduleQty, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId  

						--				SET @intLoopId = NULL
						--				SELECT TOP 1 
						--					@intLoopContractDetailId = intContractDetailId
						--					,@intLoopId = intLoopId
						--					,@dblLoopScheduleQty = dblScheduleQty
						--				FROM #tmpTicketContractUsed 
						--				WHERE intLoopId > @intLoopCurrentId
						--				ORDER BY intLoopId ASC
						--			END
						--		END

						--		--Reschedule the Quantity Used by loadshipments
						--		BEGIN
						--			SELECT
						--				intContractDetailId = CASE WHEN @strInOutFlag = 'I' THEN LD.intPContractDetailId ELSE LD.intSContractDetailId  END
						--				,intLoopId = TL.intTicketLoadUsedId
						--				,dblScheduleQty = LD.dblQuantity
						--			INTO #tmpTicketLoadUsed
						--			FROM tblSCTicket SC
						--			INNER JOIN tblSCTicketLoadUsed TL			
						--				ON SC.intTicketId = TL.intTicketId
						--			INNER JOIN tblLGLoadDetail LD
						--				ON TL.intLoadDetailId = LD.intLoadDetailId
						--			WHERE SC.intTicketId = @intTicketId 
						--			ORDER BY TL.intLoadDetailId ASC


						--			SET @intLoopId = NULL
									
						--			SELECT TOP 1 
						--				@intLoopContractDetailId = intContractDetailId
						--				,@intLoopId = intLoopId
						--				,@dblLoopScheduleQty = dblScheduleQty
						--			FROM #tmpTicketLoadUsed
						--			ORDER BY intLoopId ASC

						--			WHILE @intLoopId IS NOT NULL
						--			BEGIN
						--				SET @intLoopCurrentId = @intLoopId

						--				-- Add the load shipment quantity to contract schedule
						--				EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractDetailId, @dblLoopScheduleQty, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId  

						--				SET @intLoopId = NULL
						--				SELECT TOP 1 
						--					@intLoopContractDetailId = intContractDetailId
						--					,@intLoopId = intLoopId
						--					,@dblLoopScheduleQty = dblScheduleQty
						--				FROM #tmpTicketLoadUsed
						--				WHERE intLoopId > @intLoopCurrentId
						--				ORDER BY intLoopId ASC
						--			END
						--		END

						--	END
						--END


						---- Update contract schedule based on ticket schedule qty							

						IF ISNULL(@intTicketContractDetailId, 0) > 0 AND (@strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD')
						BEGIN
							-- For Review
							SET @ysnLoadContract = 0
							SELECT TOP 1 
								@ysnLoadContract = A.ysnLoad
							FROM tblCTContractHeader A
							INNER JOIN tblCTContractDetail B
								ON A.intContractHeaderId = B.intContractHeaderId
							WHERE B.intContractDetailId = @intTicketContractDetailId

							IF(ISNULL(@ysnLoadContract,0) = 0)
							BEGIN
								-- UPDATE tblCTContractDetail
								-- SET dblScheduleQty = ISNULL(dblScheduleQty,0) + @dblTicketScheduledQty
								-- WHERE intContractDetailId = @intTicketContractDetailId
								EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, @dblTicketScheduledQty, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
							END
						END

						EXEC [dbo].[uspSCUpdateTicketStatus] @intTicketId, 1;
                        set @intInventoryAdjustmentId = null
                        select @intInventoryAdjustmentId = intInventoryAdjustmentId from tblSCTicket where intTicketId = @intTicketId

                        if( isnull(@intInventoryAdjustmentId, 0) > 0)
						begin
                            SELECT @strAdjustmentNo = strAdjustmentNo
                            FROM tblICInventoryAdjustment
                            WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId

                            if(isnull(@strAdjustmentNo, '') <> '')
                            begin
                                EXEC dbo.uspICPostInventoryAdjustment
                                    @ysnPost = 0
                                    ,@ysnRecap = 0
                                    ,@strTransactionId = @strAdjustmentNo
                                    ,@intEntityUserSecurityId = @intUserId
                                DELETE FROM tblICInventoryAdjustment WHERE strAdjustmentNo = @strAdjustmentNo
                            end

                        end

						UPDATE tblSCTicket
						SET ysnSpecialGradePosted = 0
						WHERE intTicketId = @intTicketId
					END
					ELSE
					BEGIN
						
						SELECT @strMatchTicketStatus = strTicketStatus
							, @intMatchTicketId = intTicketId
							, @intTicketType = intTicketType
							, @intStorageScheduleTypeId = intStorageScheduleTypeId
							, @intMatchTicketItemUOMId = intItemUOMIdTo
							, @intContractDetailId = intContractId
							, @dblScheduleQty = (dblScheduleQty * -1) 
						FROM tblSCTicket WHERE intMatchTicketId = @intTicketId

						IF @strMatchTicketStatus = 'C'
						BEGIN
							RAISERROR('Unable to un-distribute ticket, match ticket already completed', 11, 1);
							RETURN;
						END
						IF ISNULL(@intMatchTicketId,0) > 0 AND @intTicketType = 6
						BEGIN 
							
							IF @intStorageScheduleTypeId = -6
							BEGIN
								SELECT @intMatchLoadId = LGLD.intLoadId 
								, @intMatchLoadDetailId = LGLD.intLoadDetailId
								, @dblMatchDeliveredQuantity = LGLD.dblDeliveredQuantity
								, @dblMatchLoadScheduledUnits = LGLD.dblQuantity
								, @intMatchLoadContractId = LGLD.intSContractDetailId
								FROM tblLGLoad LGL INNER JOIN vyuLGLoadDetailView LGLD ON LGL.intLoadId = LGLD.intLoadId 
								WHERE LGL.intTicketId = @intMatchTicketId
								SELECT @intMatchLoadDetailId
								IF ISNULL(@intMatchLoadDetailId, 0) > 0
								BEGIN
									EXEC [dbo].[uspLGUpdateLoadDetails] @intMatchLoadDetailId, 0;
									SET @dblMatchDeliveredQuantity = @dblMatchDeliveredQuantity * -1;
									/*For Match Ticket */
									IF(@strMatchTicketStatus = 'O')
									BEGIN
										EXEC uspCTUpdateScheduleQuantity @intMatchLoadContractId, @dblMatchDeliveredQuantity, @intUserId, @intMatchTicketId, 'Scale'
										--EXEC uspCTUpdateScheduleQuantity @intMatchLoadContractId, @dblMatchLoadScheduledUnits, @intUserId, @intLoadDetailId, 'Load Schedule'
									END

									SELECT @intLoadContractId = intContractId,@dblLoadScheduledUnits = dblNetUnits*-1 FROM tblSCTicket WHERE intTicketId = @intTicketId
									EXEC uspCTUpdateSequenceBalance @intLoadContractId, @dblLoadScheduledUnits, @intUserId, @intTicketId, 'Scale'

									DECLARE @dblToUpdateQty DECIMAL(18,6)
									SET @dblToUpdateQty = @dblLoadScheduledUnits *-1
									EXEC uspCTUpdateScheduleQuantity
														@intContractDetailId	=	@intLoadContractId,
														@dblQuantityToUpdate	=	@dblToUpdateQty,
														@intUserId				=	@intUserId,
														@intExternalId			=	@intTicketId,
														@strScreenName			=	'Scale'	
									
									UPDATE tblLGLoad set intTicketId = NULL, ysnInProgress = 0 WHERE intLoadId = @intMatchLoadId
								END
							END
							ELSE IF @intStorageScheduleTypeId = -2
							BEGIN  
								DECLARE @intMatchContractDetailId AS INT;
								DECLARE @__strDistributionOption AS VARCHAR(MAX);
								SELECT @intMatchContractDetailId = intContractId, @__strDistributionOption  = strDistributionOption FROM tblSCTicket WHERE intTicketId = @intMatchTicketId
								SELECT @intContractDetailId = intContractId, @dblScheduleQty = dblNetUnits *-1 FROM tblSCTicket WHERE intTicketId = @intTicketId

								EXEC uspCTUpdateSequenceBalance @intContractDetailId, @dblScheduleQty, @intUserId, @intTicketId, 'Scale'
								SET @dblScheduleQty = @dblScheduleQty *-1

								IF(@__strDistributionOption  = 'LOD')
								BEGIN
									EXEC uspCTUpdateScheduleQuantity
															@intContractDetailId	=	@intContractDetailId,
															@dblQuantityToUpdate	=	@dblScheduleQty,
															@intUserId				=	@intUserId,
															@intExternalId			=	@intTicketId,
															@strScreenName			=	'Scale'	
								END
								ELSE
									EXEC uspCTUpdateScheduleQuantityUsingUOM @intContractDetailId, @dblScheduleQty, @intUserId, @intMatchTicketId, 'Scale', @intMatchTicketItemUOMId
							END

							UPDATE tblSCTicket SET intMatchTicketId = null WHERE intTicketId = @intTicketId
							DELETE FROM tblQMTicketDiscount WHERE intTicketId = @intMatchTicketId AND strSourceType = 'Scale'
							DELETE FROM tblSCTicket WHERE intTicketId = @intMatchTicketId
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
							BEGIN							
								DELETE FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @intBillId
								EXEC [dbo].[uspAPDeleteVoucher] @intBillId, @intUserId
							END
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

						EXEC [dbo].[uspSCUpdateTicketStatus] @intTicketId, 1;


                        set @intInventoryAdjustmentId = null
                        select @intInventoryAdjustmentId = intInventoryAdjustmentId from tblSCTicket where intTicketId = @intTicketId

                        if( isnull(@intInventoryAdjustmentId, 0) > 0)
                        begin
                            SELECT @strAdjustmentNo = strAdjustmentNo
                            FROM tblICInventoryAdjustment
                            WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId

                            if(isnull(@strAdjustmentNo, '') <> '')
                            begin
                                EXEC dbo.uspICPostInventoryAdjustment
                                    @ysnPost = 0
                                    ,@ysnRecap = 0
                                    ,@strTransactionId = @strAdjustmentNo
                  ,@intEntityUserSecurityId = @intUserId
                                DELETE FROM tblICInventoryAdjustment WHERE strAdjustmentNo = @strAdjustmentNo
                            end

                        end

					END
				END
			ELSE
				BEGIN
					IF ISNULL(@ysnTransfer ,0) = 1
					BEGIN
						SELECT TOP 1 @intInvoiceId = ARD.intInvoiceId, @ysnPosted = AR.ysnPosted FROM tblSCTicket SCT
						INNER JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = SCT.intSalesOrderId 
						INNER JOIN tblSOSalesOrderDetail SOD ON SOD.intSalesOrderId = SO.intSalesOrderId 
						INNER JOIN tblARInvoiceDetail ARD ON ARD.intSalesOrderDetailId = SOD.intSalesOrderDetailId
						INNER JOIN tblARInvoice AR ON AR.intInvoiceId = ARD.intInvoiceId
						WHERE SCT.intTicketId = @intTicketId

						IF @ysnPosted = 1
						BEGIN
							if (exists ( select top 1 1 from tblGRCompanyPreference where ysnDoNotAllowUndistributePostedInvoice = 1 ))
							begin
								RAISERROR(@UNDISTRIBUTE_NOT_ALLOWED, 11, 1);
								RETURN;
							end

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
						EXEC [dbo].[uspSCUpdateTicketStatus] @intTicketId, 1;
					END
					IF ISNULL(@ysnDirectShip,0) = 1
					BEGIN 
						
						SELECT TOP 1 @intInvoiceId = intInvoiceId FROM tblARInvoiceDetail WHERE intTicketId = @intTicketId
						SELECT @ysnPosted = ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId;
						IF @ysnPosted = 1
						BEGIN
							if (exists ( select top 1 1 from tblGRCompanyPreference where ysnDoNotAllowUndistributePostedInvoice = 1 ))
							begin
								RAISERROR(@UNDISTRIBUTE_NOT_ALLOWED, 11, 1);
								RETURN;
							end
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

						/* For Direct Out Undistribute */
						DECLARE @strTicketType VARCHAR(MAX)
						DECLARE @dblNetUnit DECIMAL(18,6)
						DECLARE @_intContractDetailId INT
						DECLARE @_strDistributionOption VARCHAR(MAX)
						DECLARE @strGrade VARCHAR(MAX)
						DECLARE @strWght VARCHAR(MAX)
						SELECT @strTicketType = strTicketType,@dblNetUnit = dblNetUnits*-1,@_intContractDetailId = intContractId, @_strDistributionOption  = strDistributionOption FROM vyuSCTicketScreenView WHERE intTicketId = @intTicketId
						
						SELECT @strGrade = Grade.strWeightGradeDesc,@strWght = Wght.strWeightGradeDesc FROM tblSCTicket SC
						LEFT JOIN tblCTWeightGrade Grade  ON Grade.intWeightGradeId = SC.intGradeId
						LEFT JOIN tblCTWeightGrade Wght ON Wght.intWeightGradeId = SC.intWeightId
						WHERE intTicketId = @intTicketId
						IF(@strTicketType = 'Direct Out' and ((LOWER(ISNULL(@strGrade,'')) <> 'destination') AND LOWER(ISNULL(@strWght,'')) <> 'destination'))
						BEGIN
							IF(ISNULL(@dblScheduleQty,0) = 0)
							BEGIN
								SELECT @dblScheduleQty = -dblScheduleQty  FROM tblSCTicket WHERE intTicketId = @intTicketId
							END

							IF((SELECT strPricingType FROM vyuCTContractDetailView WHERE intContractDetailId = @_intContractDetailId) <> 'Basis')
							BEGIN
								EXEC uspCTUpdateSequenceBalance @_intContractDetailId, @dblScheduleQty, @intUserId, @intTicketId, 'Scale'
								SET @dblScheduleQty = @dblScheduleQty *-1
								IF(@_strDistributionOption = 'LOD')
								BEGIN
									EXEC uspCTUpdateScheduleQuantity
														@intContractDetailId	=	@_intContractDetailId,
														@dblQuantityToUpdate	=	@dblScheduleQty,
														@intUserId				=	@intUserId,
														@intExternalId			=	@intTicketId,
														@strScreenName			=	'Scale'		
																								
								END
							END
						END
						ELSE
						BEGIN
							IF ISNULL(@intTicketContractDetailId, 0) > 0 AND (@strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD')
							BEGIN
								-- For Review
								SET @ysnLoadContract = 0
								SELECT TOP 1 
									@ysnLoadContract = A.ysnLoad
								FROM tblCTContractHeader A
								INNER JOIN tblCTContractDetail B
									ON A.intContractHeaderId = B.intContractHeaderId
								WHERE B.intContractDetailId = @intTicketContractDetailId

								IF(ISNULL(@ysnLoadContract,0) = 0)
								BEGIN
									UPDATE tblCTContractDetail
									SET dblScheduleQty = ISNULL(dblScheduleQty,0) + @dblTicketScheduledQty
									WHERE intContractDetailId = @intTicketContractDetailId
								END
							END
						END

						EXEC [dbo].[uspSCUpdateTicketStatus] @intTicketId, 1;
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

							EXEC [dbo].[uspSCUpdateTicketStatus] @intTicketId, 1;
						END
				
						IF @intEntityId > 0
						BEGIN
							CREATE TABLE #tmpItemShipmentIds (
								[intInventoryShipmentId] [INT] PRIMARY KEY,
								[strShipmentNumber] [VARCHAR](100),
								UNIQUE ([intInventoryShipmentId])
							);
							INSERT INTO #tmpItemShipmentIds(intInventoryShipmentId,strShipmentNumber) SELECT DISTINCT(intInventoryShipmentId),strShipmentNumber from vyuICGetInventoryShipmentItem WHERE intSourceId = @intTicketId AND strSourceType = 'Scale'

							----------------------------------------------------------------------------------------
							----------------------------------------------------------------------------------------
							BEGIN
								---GEt all the invoice Detail Id for the inventory shipment item details
								CREATE TABLE #tmpShipmentInvoiceDetailIds (
									intInventoryShipmentItemId INT
									,[intInvoiceId] INT
									,[intInvoiceDetailId] INT

								);
								INSERT INTO #tmpShipmentInvoiceDetailIds(
									intInventoryShipmentItemId
									,[intInvoiceDetailId]
									,[intInvoiceId]
								)
								SELECT
									DISTINCT (A.intInventoryShipmentItemId)
									,B.[intInvoiceDetailId]
									,B.[intInvoiceId]
								FROM  tblICInventoryShipmentItem A
								LEFT JOIN tblARInvoiceDetail  B
									ON A.intInventoryShipmentItemId = B.intInventoryShipmentItemId
								LEFT JOIN tblARInvoice D
									ON B.intInvoiceId = D.intInvoiceId
								INNER JOIN #tmpItemShipmentIds C
									ON A.intInventoryShipmentId = C.intInventoryShipmentId
								WHERE D.strTransactionType = 'Invoice'


								---GEt all the invoice Detail Id for the inventory shipment charge details
								CREATE TABLE #tmpShipmentChargeInvoiceDetailIds (
									intInventoryShipmentChargeId INT
									,[intInvoiceId] INT
									,[intInvoiceDetailId] INT
								);
								INSERT INTO #tmpShipmentChargeInvoiceDetailIds(
									intInventoryShipmentChargeId
									,[intInvoiceDetailId]
									,[intInvoiceId]
								)
								SELECT
									DISTINCT (A.intInventoryShipmentChargeId)
									,B.[intInvoiceDetailId]
									,B.[intInvoiceId]
								FROM  tblICInventoryShipmentCharge A
								LEFT JOIN tblARInvoiceDetail  B
									ON A.intInventoryShipmentChargeId = B.intInventoryShipmentChargeId
								LEFT JOIN tblARInvoice D
									ON B.intInvoiceId = D.intInvoiceId
								INNER JOIN #tmpItemShipmentIds C
									ON A.intInventoryShipmentId = C.intInventoryShipmentId
								WHERE D.strTransactionType = 'Invoice'
										AND D.ysnPosted = 1


								--Check if all invoice have credit memo

								--ITEM
								SET @ysnAllInvoiceHasCreditMemo = 1
								IF EXISTS(	SELECT TOP 1 1
											FROM #tmpShipmentInvoiceDetailIds A
											LEFT JOIN tblARInvoiceDetail B
												ON A.intInvoiceDetailId = B.intOriginalInvoiceDetailId
											LEFT JOIN tblARInvoice C
												ON B.intInvoiceId = C.intInvoiceId
											WHERE A.intInvoiceDetailId IS NOT NULL
												AND B.intInvoiceDetailId IS NULL
												-- AND C.strTransactionType = 'Credit Memo'
												)

								BEGIN
									SET @ysnAllInvoiceHasCreditMemo = 0
								END

								IF(@ysnAllInvoiceHasCreditMemo = 1)
								BEGIN
									--CHARGES
									IF EXISTS(	SELECT TOP 1 1
												FROM #tmpShipmentChargeInvoiceDetailIds A
												LEFT JOIN tblARInvoiceDetail B
													ON A.intInvoiceDetailId = B.intOriginalInvoiceDetailId
												LEFT JOIN tblARInvoice C
													ON B.intInvoiceId = C.intInvoiceId
												WHERE A.intInvoiceDetailId IS NOT NULL
													AND B.intInvoiceDetailId IS NULL
													-- AND C.strTransactionType = 'Credit Memo'
													)

									BEGIN
										SET @ysnAllInvoiceHasCreditMemo = 0
									END
								END



							END
							-------------------------------------------------------------------------------------------
							-------------------------------------------------------------------------------------------


							DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
							FOR
							SELECT intInventoryShipmentId, strShipmentNumber
							FROM #tmpItemShipmentIds

							OPEN intListCursor;

							-- Initial fetch attempt
							FETCH NEXT FROM intListCursor INTO @InventoryShipmentId, @strTransactionId;

							WHILE @@FETCH_STATUS = 0
							BEGIN
								IF  @ysnAllInvoiceHasCreditMemo = 1
								BEGIN
									if (exists ( select top 1 1 from tblGRCompanyPreference where ysnDoNotAllowUndistributePostedInvoice = 1 ))
									begin
										RAISERROR(@UNDISTRIBUTE_NOT_ALLOWED, 11, 1);
										RETURN;
									end

									EXEC [dbo].[uspGRDeleteStorageHistory] @strSourceType = 'InventoryShipment' ,@IntSourceKey = @InventoryShipmentId
									EXEC [dbo].[uspGRReverseTicketOpenBalance] 'InventoryShipment' , @InventoryShipmentId ,@intUserId;
									DELETE tblQMTicketDiscount WHERE intTicketFileId = @InventoryShipmentId AND strSourceType = 'Inventory Shipment'
								END
								ELSE
								BEGIN

									SELECT DISTINCT
										ARID.intInvoiceId
									INTO #invoiceIdTable
									FROM tblARInvoiceDetail ARID
									INNER JOIN tblARInvoice ARI
										ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
									INNER JOIN tblICInventoryShipmentItem ICISI
										ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]
									WHERE ICISI.[intInventoryShipmentId] = @InventoryShipmentId
									ORDER BY ARID.intInvoiceId ASC

									SELECT @intInvoiceId = MIN(intInvoiceId)
									FROM #invoiceIdTable

									WHILE (ISNULL(@intInvoiceId,0) > 0)
									BEGIN
										SELECT @ysnPosted = ysnPosted, @strInvoiceNumber = strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId;

										-- unpost invoice
										IF @ysnPosted = 1
										BEGIN
											if (exists ( select top 1 1 from tblGRCompanyPreference where ysnDoNotAllowUndistributePostedInvoice = 1 ))
											begin
												RAISERROR(@UNDISTRIBUTE_NOT_ALLOWED, 11, 1);
												RETURN;
											end



											-- EXEC [dbo].[uspARPostInvoice]
											-- 	@batchId			= NULL,
											-- 	@post				= 0,
											-- 	@recap				= 0,
											-- 	@param				= @intInvoiceId,
											-- 	@userId				= @intUserId,
											-- 	@beginDate			= NULL,
											-- 	@endDate			= NULL,
											-- 	@beginTransaction	= NULL,
											-- 	@endTransaction		= NULL,
											-- 	@exclude			= NULL,
											-- 	@successfulCount	= @successfulCount OUTPUT,
											-- 	@invalidCount		= @invalidCount OUTPUT,
											-- 	@success			= @success OUTPUT,
											-- 	@batchIdUsed		= @batchIdUsed OUTPUT,
											-- 	@recapId			= @recapId OUTPUT,
											-- 	@transType			= N'all',
											-- 	@accrueLicense		= 0,
											-- 	@raiseError			= 1

											SET @NeedCreditMemoMessage = 'Please create a credit memo for invoice ' + @strInvoiceNumber + ' with document number of ' + @strTransactionId +'.'
											RAISERROR(@NeedCreditMemoMessage, 11, 1);
											RETURN;


										END

										--Delete/update Invoice
										IF ISNULL(@intInvoiceId, 0) > 0
										BEGIN

											---Check if there are multiple IS on the invoice.

											IF (SELECT COUNT(DISTINCT strDocumentNumber)
												FROM tblARInvoiceDetail
												WHERE intInvoiceId = @intInvoiceId) > 1
											BEGIN
												--update invoice
												EXEC uspARDeleteInvoice @intInvoiceId, @intUserId, NULL, @InventoryShipmentId
												EXEC dbo.uspARUpdateInvoiceIntegrations @intInvoiceId, 0, @intUserId
												EXEC dbo.uspARReComputeInvoiceTaxes @intInvoiceId
											END
											ELSE
											BEGIN
												EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
											END

										END

									
										IF EXISTS(SELECT TOP 1 1 FROM #invoiceIdTable WHERE intInvoiceId > @intInvoiceId)
										BEGIN
											SELECT TOP 1 @intInvoiceId = intInvoiceId
											FROM #invoiceIdTable
											WHERE intInvoiceId > @intInvoiceId
											ORDER BY intInvoiceId ASC
										END
										ELSE
										BEGIN
											SET @intInvoiceId = 0
										END
									
									END
								
									EXEC [dbo].[uspICPostInventoryShipment] 0, 0, @strTransactionId, @intUserId;
									EXEC [dbo].[uspGRDeleteStorageHistory] @strSourceType = 'InventoryShipment' ,@IntSourceKey = @InventoryShipmentId
									EXEC [dbo].[uspGRReverseTicketOpenBalance] 'InventoryShipment' , @InventoryShipmentId ,@intUserId;

									---- Update contract schedule if ticket Distribution type is load and link it to IS
									IF(@strDistributionOption = 'LOD')
									BEGIN
										SET @intInventoryShipmentEntityId = 0
										SELECT TOP 1
											@intInventoryShipmentEntityId = intEntityCustomerId
										FROM tblICInventoryShipment
										WHERE intInventoryShipmentId = @InventoryShipmentId

										SET @dblLoadUsedQty = 0
										SELECT TOP 1 
											@dblLoadUsedQty = dblQty
										FROM tblSCTicketLoadUsed
										WHERE intTicketId = @intTicketId
											AND intLoadDetailId = @intTicketLoadDetailId
											AND intEntityId = @intInventoryShipmentEntityId

										IF @dblLoadUsedQty <> 0
										BEGIN
											EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, @dblLoadUsedQty, @intUserId, @InventoryShipmentId, 'Inventory Shipment', @intTicketItemUOMId
										END
									END


									EXEC [dbo].[uspICDeleteInventoryShipment] @InventoryShipmentId, @intEntityId;
									DELETE tblQMTicketDiscount WHERE intTicketFileId = @InventoryShipmentId AND strSourceType = 'Inventory Shipment'

								END

								FETCH NEXT FROM intListCursor INTO @InventoryShipmentId, @strTransactionId;
							END
							CLOSE intListCursor  
							DEALLOCATE intListCursor 

							UPDATE tblSCTicket
							SET intInventoryShipmentId = NULL
							WHERE intTicketId = @intTicketId

							EXEC [dbo].[uspSCUpdateTicketStatus] @intTicketId, 1;

							---- Update contract schedule based on ticket schedule qty

							IF ISNULL(@intTicketContractDetailId, 0) > 0 AND (@strDistributionOption = 'CNT')
							BEGIN
								-- For Review
								SET @ysnLoadContract = 0
								SELECT TOP 1
									@ysnLoadContract = A.ysnLoad
								FROM tblCTContractHeader A
								INNER JOIN tblCTContractDetail B
									ON A.intContractHeaderId = B.intContractHeaderId
								WHERE B.intContractDetailId = @intTicketContractDetailId

								IF(ISNULL(@ysnLoadContract,0) = 0)
								BEGIN
									EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, @dblTicketScheduledQty, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
								END
							END

						END
					END
				END
		END
		ELSE
		BEGIN
			DECLARE	@intItemId				INT
					,@intDiscountCodeId		INT
					,@EntitySplitId			INT
					,@intLocationId			INT
					,@intDeliverySheetId	INT
					,@intCustomerStorageId	INT
					,@dblBalance			NUMERIC(38,20)
					,@newBalance			NUMERIC(38,20)
					,@finalGrossWeight		NUMERIC (38,20)
					,@wsGrossShrinkWeight	NUMERIC (38,20)
					,@wsWetShrinkWeight		NUMERIC (38,20)
					,@wsNetShrinkWeight		NUMERIC (38,20)
					,@wetWeight				NUMERIC (38,20)
					,@wsWetWeight			NUMERIC (38,20)
					,@totalWetShrink		NUMERIC (38,20)
					,@totalNetShrink		NUMERIC (38,20)
					,@totalShrinkPrice		NUMERIC (38,20)
					,@dblShrinkPercent		NUMERIC(38,20)
					,@finalShrinkUnits		NUMERIC(38,20)
					,@strShrinkWhat			NVARCHAR(40)
					,@currencyDecimal		INT;
				-- SELECT @currencyDecimal = intCurrencyDecimal from tblSMCompanyPreference
				SET @currencyDecimal = 20
				SELECT @intId = MIN(intInventoryReceiptItemId) 
				FROM vyuICGetInventoryReceiptItem where intSourceId = @intTicketId and strSourceType = 'Scale'
				WHILE ISNULL(@intId,0) > 0
				BEGIN
					SELECT @strTransactionId = IR.strReceiptNumber, @InventoryReceiptId = IRI.intInventoryReceiptId
					, @EntitySplitId = IR.intEntityVendorId
					, @intLocationId = IR.intLocationId
					, @dblBalance = ROUND(IRI.dblOpenReceive, @currencyDecimal) 
					FROM tblICInventoryReceiptItem IRI 
					INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
					WHERE IRI.intInventoryReceiptItemId = @intId
					
					SELECT @intItemId = intItemId
					, @intDeliverySheetId = intDeliverySheetId 
					, @intStorageScheduleTypeId = ISNULL(SCS.intStorageScheduleTypeId,SC.intStorageScheduleTypeId)
					FROM tblSCTicket SC
					OUTER APPLY(
						SELECT intStorageScheduleTypeId FROM tblSCTicketSplit WHERE intTicketId = @intTicketId AND intCustomerId = @EntitySplitId
					) SCS
					WHERE SC.intTicketId = @intTicketId 
					
					EXEC uspGRCustomerStorageBalance	
						@EntitySplitId 
						,@intItemId
						,@intLocationId
						,@intDeliverySheetId
						,@intCustomerStorageId
						,@dblBalance
						,@intStorageScheduleTypeId
						,NULL
						,0
						,NULL
						,NULL
						,@newBalance OUTPUT

					IF ISNULL(ROUND(ISNULL(@newBalance,0), @currencyDecimal), 0) > 0
						DELETE FROM tblGRStorageHistory WHERE intInventoryReceiptId = @InventoryReceiptId
					ELSE
						EXEC [dbo].[uspGRReverseOnReceiptDelete] @InventoryReceiptId
					
					EXEC [dbo].[uspICPostInventoryReceipt] 0, 0, @strTransactionId, @intUserId
					EXEC [dbo].[uspICDeleteInventoryReceipt] @InventoryReceiptId, @intUserId
					
					SET @finalGrossWeight = ISNULL(@finalGrossWeight,0) + @dblBalance

					SELECT @intId = MIN(intInventoryReceiptItemId) 
					FROM vyuICGetInventoryReceiptItem where intSourceId = @intTicketId and strSourceType = 'Scale' AND intInventoryReceiptItemId > @intId
				END

				--DELIVERY SHEET QUANTITY REVERSAL
				DECLARE @CalculatedDiscount TABLE
				(
					[intExtendedKey] INT
					,[dblFrom] NUMERIC(38, 20) NULL
					,[dblTo] NUMERIC(38, 20) NULL
					,[dblDiscountAmount] NUMERIC(38, 20) NULL
					,[dblShrink] NUMERIC(38, 20) NULL
					,[strMessage] NVARCHAR(40)
					,[intDiscountCalculationOptionId] INT NULL
					,[strCalculationDiscountOption] NVARCHAR(40)
					,[strDiscountChargeType] NVARCHAR(40)
					,[intShrinkCalculationOptionId] INT NULL
					,[strCalculationShrinkOption] NVARCHAR(40)
					,[intDiscountUOMId] INT NULL
					,[intDeliverySheetId] INT NULL
					,[intDiscountScheduleCodeId] INT NULL
				)
				INSERT INTO @CalculatedDiscount(
					[intExtendedKey]
					,[dblFrom]
					,[dblTo]
					,[dblDiscountAmount]
					,[dblShrink]
					,[strMessage]
					,[intDiscountCalculationOptionId]
					,[strCalculationDiscountOption]
					,[strDiscountChargeType]
					,[intShrinkCalculationOptionId]
					,[strCalculationShrinkOption]
					,[intDiscountUOMId]
					,[intDeliverySheetId]
					,[intDiscountScheduleCodeId]
				)
				SELECT 
					[intExtendedKey]						= Discount.intExtendedKey
					,[dblFrom]								= Discount.dblFrom
					,[dblTo]								= Discount.dblTo
					,[dblDiscountAmount]					= Discount.dblDiscountAmount
					,[dblShrink]							= Discount.dblShrink
					,[strMessage]							= Discount.strMessage
					,[intDiscountCalculationOptionId]		= Discount.intDiscountCalculationOptionId
					,[strCalculationDiscountOption]			= Discount.strCalculationDiscountOption
					,[strDiscountChargeType]				= Discount.strDiscountChargeType
					,[intShrinkCalculationOptionId]			= Discount.intShrinkCalculationOptionId
					,[strCalculationShrinkOption]			= Discount.strCalculationShrinkOption
					,[intDiscountUOMId] 					= Discount.intDiscountUOMId
					,[intDeliverySheetId]					= SC.intDeliverySheetId
					,[intDiscountScheduleCodeId]			= QM.intDiscountScheduleCodeId
				FROM tblSCTicket SC
				LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = SC.intDeliverySheetId AND QM.strSourceType = 'Delivery Sheet'
				LEFT JOIN tblGRDiscountScheduleCode GR ON GR.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
				OUTER APPLY (
					SELECT * FROM dbo.fnGRCalculateDiscountandShrink(QM.intDiscountScheduleCodeId, QM.dblGradeReading , 0, GR.intItemId)
				) Discount
				WHERE SC.intTicketId = @intTicketId

				SELECT @finalGrossWeight = (SCD.dblGross - @finalGrossWeight) FROM tblSCTicket SC
				INNER JOIN tblSCDeliverySheet SCD ON SC.intDeliverySheetId = SCD.intDeliverySheetId
				WHERE SC.intTicketId = @intTicketId

				SELECT @intDiscountCodeId = MIN(intDiscountScheduleCodeId) FROM @CalculatedDiscount WHERE intDiscountScheduleCodeId > 0
				WHILE ISNULL(@intDiscountCodeId,0) > 0
				BEGIN
					SELECT @strShrinkWhat = strCalculationShrinkOption, @dblShrinkPercent = dblShrink FROM @CalculatedDiscount WHERE intDiscountScheduleCodeId = @intDiscountCodeId
					IF @strShrinkWhat = 'Wet Weight'
						SET @totalWetShrink = ISNULL(@totalWetShrink,0) + @dblShrinkPercent;
					ELSE IF @strShrinkWhat = 'Net Weight'
						SET @totalNetShrink = ISNULL(@totalNetShrink,0) + @dblShrinkPercent
					ELSE IF @strShrinkWhat = 'Gross Weight'
						SET @totalShrinkPrice = ISNULL(@totalShrinkPrice,0) + @dblShrinkPercent;
					SELECT @intDiscountCodeId = MIN(intDiscountScheduleCodeId) FROM @CalculatedDiscount WHERE intDiscountScheduleCodeId > @intDiscountCodeId
				END

				SET @wsGrossShrinkWeight = (ISNULL(@finalGrossWeight, 0) * ISNULL(@totalShrinkPrice, 0)) / 100
				SET @wetWeight = (@finalGrossWeight - @wsGrossShrinkWeight)
				SET @wsWetShrinkWeight = (ISNULL(@wetWeight, 0) * ISNULL(@totalWetShrink, 0) ) / 100
				SET @wsWetWeight = (@wetWeight - @wsWetShrinkWeight)
				SET @wsNetShrinkWeight = (ISNULL(@wsWetWeight, 0) * ISNULL(@totalNetShrink, 0)) / 100
				SET @finalShrinkUnits = (@wsGrossShrinkWeight + @wsWetShrinkWeight + @wsNetShrinkWeight)
				IF @finalGrossWeight <= 0
				BEGIN
					SET @finalGrossWeight = 0;
					SET @finalShrinkUnits = 0;
				END

				UPDATE SCD SET SCD.dblGross = @finalGrossWeight, SCD.dblShrink = @finalShrinkUnits , SCD.dblNet = (@finalGrossWeight - @finalShrinkUnits)
				FROM tblSCDeliverySheet SCD
				WHERE intDeliverySheetId = @intDeliverySheetId


		

				EXEC [dbo].[uspSCUpdateTicketStatus] @intTicketId, 1;

				UPDATE GRC SET dtmDeliveryDate = SC.dtmTicketDateTime
				FROM tblGRCustomerStorage GRC
				OUTER APPLY(
					SELECT TOP 1 dtmTicketDateTime FROM tblSCTicket WHERE intDeliverySheetId = GRC.intDeliverySheetId AND strTicketStatus = 'C' ORDER BY dtmTicketDateTime DESC
				) SC
				WHERE GRC.intDeliverySheetId = @intDeliverySheetId  
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