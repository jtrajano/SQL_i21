CREATE PROCEDURE [dbo].[uspSCUndistributeTicket]
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
DECLARE @strMatchTicketDistributionOption NVARCHAR(5)
DECLARE @strTicketDistributionOption NVARCHAR(5)
DECLARE @dblMatchTicketScheduleQty NUMERIC(18,6)
DECLARE @intMatchTicketContractDetailId AS INT;
DECLARE @intMatchTicketStorageScheduleTypeId AS INT
DECLARE @strTicketWeightFinalizedWhere NVARCHAR(20)
DECLARE @strTicketGradeFinalizedWhere NVARCHAR(20)
DECLARE @ysnContractLoadBased BIT
DECLARE @intTicketContractDetailId INT
DECLARE @dblTicketScheduleQty NUMERIC(18,6)
DECLARE @dblTicketNetUnits NUMERIC(18,6)
DECLARE @intTicketTypeId AS INT
DECLARE @intTicketLoadId INT
DECLARE @intTicketStorageScheduleTypeId INT
DECLARE @strZeroPriceTransaction NVARCHAR(50)

BEGIN TRY
		---Check for Zero Spot Transaction
		IF EXISTS(SELECT TOP 1 1 FROM tblGRUnPricedSpotTicket WHERE intTicketId = @intTicketId)
		BEGIN
			SELECT TOP 1
				@strZeroPriceTransaction = strPriceTicket
			FROM tblGRUnPricedSpotTicket A
			INNER JOIN tblGRUnPriced B
				ON A.intUnPricedId = B.intUnPricedId
			WHERE A.intTicketId = @intTicketId

			SET @ErrorMessage = 'Undistributing ticket is not allowed. Ticket is being used in ''' + ISNULL(@strZeroPriceTransaction,'') +''', Unpost and remove it first before undistributing the Ticket.'
			
			RAISERROR(@ErrorMessage, 11, 1);
		END

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

							/* CURSOR for Split Contract*/
							DECLARE @intEntityVendorId AS INT
							DECLARE @strDistributionOption AS VARCHAR(MAX)
							DECLARE @cursor_intContractDetailId INT
							DECLARE @cursor_dblScheduleQty DECIMAL(18,6)
							DECLARE @cursor_intInventoryReceiptId INT
							
							DECLARE splitCursor CURSOR LOCAL FAST_FORWARD
							FOR
							SELECT SCC.intContractDetailId ,SCC.intEntityId,SCC.dblScheduleQty
								-- If contract pricing type is DP, set strDistributionOption to 'DP' to avoid updating the scheduled qty of the DP contract
								,[strDistributionOption] = CASE WHEN CTH.intPricingTypeId = 5 THEN 'DP' ELSE SPL.strDistributionOption END
							FROM tblSCTicketSplit SPL
							INNER JOIN tblSCTicketContractUsed SCC 
								ON SCC.intTicketId = SCC.intTicketId
							INNER JOIN tblCTContractDetail CTD
								ON SCC.intContractDetailId = CTD.intContractDetailId
							INNER JOIN tblCTContractHeader CTH
								ON CTH.intContractHeaderId = CTD.intContractHeaderId
							WHERE SPL.intTicketId = @intTicketId and SCC.intTicketId = @intTicketId and SPL.intCustomerId = SCC.intEntityId and SPL.intCustomerId = @_intIRVendorId

							OPEN splitCursor;

							FETCH NEXT FROM splitCursor INTO @cursor_intContractDetailId, @intEntityVendorId, @cursor_dblScheduleQty, @strDistributionOption;
							WHILE @@FETCH_STATUS = 0
							BEGIN
								IF(@strDistributionOption = 'CNT')
									BEGIN		

									SET @cursor_dblScheduleQty = @cursor_dblScheduleQty *-1
									EXEC uspCTUpdateScheduleQuantity @intContractDetailId=@cursor_intContractDetailId,@dblQuantityToUpdate=@cursor_dblScheduleQty,@intUserId=@intUserId,@intExternalId=@intTicketId, @strScreenName= 'Scale'	
										
									END

								FETCH NEXT FROM splitCursor INTO @cursor_intContractDetailId, @intEntityVendorId, @cursor_dblScheduleQty, @strDistributionOption;
							END

							CLOSE splitCursor  
							DEALLOCATE splitCursor 

							/* END CURSOR for Split Contract*/

							FETCH NEXT FROM intListCursor INTO @InventoryReceiptId , @strTransactionId, @ysnIRPosted;
						END
						CLOSE intListCursor  
						DEALLOCATE intListCursor 
						EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;

						declare @intInventoryAdjustmentId int 
						declare @strAdjustmentNo AS NVARCHAR(40)
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
					ELSE
					BEGIN
						
						SELECT TOP 1 
							@strMatchTicketStatus = strTicketStatus
							, @intMatchTicketId = intTicketId
							, @intTicketType = intTicketType
							, @intStorageScheduleTypeId = intStorageScheduleTypeId
							, @intMatchTicketItemUOMId = intItemUOMIdTo
							, @intContractDetailId = intContractId
							, @dblScheduleQty = (dblScheduleQty * -1) 
							, @dblMatchTicketScheduleQty = ISNULL(dblScheduleQty,0)
							,@strMatchTicketDistributionOption = strDistributionOption
							,@intMatchTicketContractDetailId = intContractId
							,@intMatchTicketStorageScheduleTypeId = intStorageScheduleTypeId
						FROM tblSCTicket WHERE intMatchTicketId = @intTicketId

						SELECT TOP 1 
							@strTicketDistributionOption = SC.strDistributionOption
							,@strTicketWeightFinalizedWhere = CTWeight.strWhereFinalized
							,@strTicketGradeFinalizedWhere = CTGrade.strWhereFinalized
							,@intTicketContractDetailId = SC.intContractId
							,@dblTicketScheduleQty = ISNULL(dblScheduleQty,0)
							,@intTicketLoadId = intLoadId
							,@dblTicketNetUnits = dblNetUnits
						FROM tblSCTicket SC
						LEFT JOIN tblCTWeightGrade CTGrade 
							ON CTGrade.intWeightGradeId = SC.intGradeId
						LEFT JOIN tblCTWeightGrade CTWeight 
							ON CTWeight.intWeightGradeId = SC.intWeightId
						WHERE intTicketId = @intTicketId


						IF @strMatchTicketStatus = 'C'
						BEGIN
							RAISERROR('Unable to un-distribute ticket, match ticket already completed', 11, 1);
							RETURN;
						END
						IF ISNULL(@intMatchTicketId,0) > 0 AND @intTicketType = 6 
						BEGIN 
							IF(ISNULL(@intMatchTicketContractDetailId,0) > 0)
							BEGIN
								IF @intStorageScheduleTypeId = -6 -- load distribution
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
										UPDATE tblLGLoad set intTicketId = NULL, ysnInProgress = 0 WHERE intTicketId = @intMatchTicketId
										
									END
								END
								ELSE IF @intStorageScheduleTypeId = -2
								BEGIN  
									SET @dblScheduleQty = @dblMatchTicketScheduleQty *-1

									EXEC uspCTUpdateScheduleQuantityUsingUOM @intMatchTicketContractDetailId, @dblScheduleQty, @intUserId, @intMatchTicketId, 'Scale', @intMatchTicketItemUOMId
								END
							END

							UPDATE tblSCTicket SET intMatchTicketId = null WHERE intTicketId = @intTicketId
							UPDATE tblSCTicket SET ysnHasGeneratedTicketNumber = 0 WHERE intTicketId = @intMatchTicketId
							DELETE FROM tblQMTicketDiscount WHERE intTicketId = @intMatchTicketId AND strSourceType = 'Scale'
							DELETE FROM tblSCTicket WHERE intTicketId = @intMatchTicketId
						END
						
						IF(ISNULL(@strTicketWeightFinalizedWhere,'Origin') <> 'Destination' AND ISNULL(@strTicketGradeFinalizedWhere,'Origin') <> 'Destination')
						BEGIN
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

							SELECT TOP 1
								@ysnContractLoadBased = ISNULL(B.ysnLoad,0)
							FROM tblCTContractDetail A
							INNER JOIN tblCTContractHeader B
								ON A.intContractHeaderId = B.intContractHeaderId
							WHERE A.intContractDetailId = @intTicketContractDetailId 

							SET @dblScheduleQty = @dblTicketNetUnits
							IF(ISNULL(@ysnContractLoadBased,0) = 1)
							BEGIN
								SET @dblScheduleQty = 1
							END
							

							SET @dblScheduleQty = (@dblScheduleQty * -1)
							EXEC uspCTUpdateSequenceBalance @intTicketContractDetailId, @dblScheduleQty, @intUserId, @intTicketId, 'Scale'
							SET @dblScheduleQty = (@dblScheduleQty * -1)
							IF(@intTicketStorageScheduleTypeId <> -6)
							BEGIN
								EXEC uspCTUpdateScheduleQuantity
									@intContractDetailId	=	@intTicketContractDetailId,
									@dblQuantityToUpdate	=	@dblScheduleQty,
									@intUserId				=	@intUserId,
									@intExternalId			=	@intTicketId,
									@strScreenName			=	'Scale'	
							END
							ELSE
							BEGIN
								EXEC uspCTUpdateScheduleQuantity
									@intContractDetailId	=	@intTicketContractDetailId,
									@dblQuantityToUpdate	=	@dblTicketScheduleQty,
									@intUserId				=	@intUserId,
									@intExternalId			=	@intTicketId,
									@strScreenName			=	'Scale'	
							END

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
						END

						

						-- EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
						UPDATE tblSCTicket SET strTicketStatus = 'R' WHERE intTicketId = @intTicketId
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

						/* For Direct Out Undistribute */
						DECLARE @dblNetUnit DECIMAL(18,6)
						DECLARE @_intContractDetailId INT
						DECLARE @_strDistributionOption VARCHAR(MAX)
						DECLARE @strGrade VARCHAR(20)
						DECLARE @strWght VARCHAR(20)
						
						SELECT 
							@strGrade = Grade.strWhereFinalized
							,@strWght = Wght.strWhereFinalized 
							,@dblNetUnit = SC.dblNetUnits*-1
							,@_intContractDetailId = SC.intContractId
							,@_strDistributionOption = SC.strDistributionOption
							,@intTicketTypeId = SC.intTicketTypeId
							,@dblTicketScheduleQty = SC.dblScheduleQty
						FROM tblSCTicket SC
						LEFT JOIN tblCTWeightGrade Grade  
							ON Grade.intWeightGradeId = SC.intGradeId
						LEFT JOIN tblCTWeightGrade Wght 
							ON Wght.intWeightGradeId = SC.intWeightId
						WHERE intTicketId = @intTicketId

						IF(@intTicketTypeId = 9 AND ((LOWER(ISNULL(@strGrade,'')) <> 'destination') AND LOWER(ISNULL(@strWght,'')) <> 'destination'))
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
							BEGIN
								DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceId = @intInvoiceId;
								DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceDetailId in(SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId)
								EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
							END
						END

						UPDATE tblSCTicket
						SET strTicketStatus = 'R'
						WHERE intTicketId = @intTicketId

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

								IF OBJECT_ID (N'tempdb.dbo.#invoiceIdTable') IS NOT NULL
								BEGIN 
									DROP TABLE #invoiceIdTable
								END

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
									SELECT @ysnPosted = ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId;

									-- unpost invoice
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

									--Delete Invoice
									IF ISNULL(@intInvoiceId, 0) > 0
									BEGIN
										EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
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

				EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;

				UPDATE GRC SET dtmDeliveryDate = SC.dtmTicketDateTime
				FROM tblGRCustomerStorage GRC
				OUTER APPLY(
					SELECT TOP 1 dtmTicketDateTime FROM tblSCTicket WHERE intDeliverySheetId = GRC.intDeliverySheetId AND strTicketStatus = 'C' ORDER BY dtmTicketDateTime DESC
				) SC
				WHERE GRC.intDeliverySheetId = @intDeliverySheetId  


				exec uspSCUpdateDeliverySheetDate @intTicketId = @intTicketId, @ysnUndistribute = 1
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