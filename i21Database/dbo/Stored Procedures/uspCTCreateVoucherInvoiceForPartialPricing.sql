CREATE PROCEDURE [dbo].[uspCTCreateVoucherInvoiceForPartialPricing]
		
	@intContractDetailId	INT,
	@intUserId			INT = NULL
	
AS

BEGIN TRY
	--return
	DECLARE @ErrMsg							NVARCHAR(MAX),
			@dblCashPrice					NUMERIC(18,6),
			@ysnPosted						BIT,
			@strReceiptNumber				NVARCHAR(50),
			@intLastModifiedById			INT,
			@intInventoryReceiptId			INT,
			@intPricingTypeId				INT,
			@intContractHeaderId			INT,
			@ysnOnceApproved				BIT,
			@ysnApprovalExist				BIT,
			@ysnAllowChangePricing			BIT,
			@ysnEnablePriceContractApproval BIT,
			@intEntityId					INT,
			@intContractTypeId				INT,
			@intInvoiceId					INT,
			@intInventoryShipmentId			INT,
			@intNewInvoiceId				INT,
			@intBillId						INT,
			@intNewBillId					INT,
			@ysnSuccess						BIT,
			@voucherDetailReceipt			VoucherDetailReceipt,
			@voucherDetailReceiptCharge		VoucherDetailReceiptCharge,
			@InvoiceEntries					InvoiceIntegrationStagingTable,
			@LineItemTaxEntries				LineItemTaxDetailStagingTable,
			@ErrorMessage					NVARCHAR(250),
			@CreatedIvoices					NVARCHAR(MAX),
			@UpdatedIvoices					NVARCHAR(MAX),
			@strShipmentNumber				NVARCHAR(50),
			@intBillDetailId				INT,
			@strVendorOrderNumber			NVARCHAR(50),
			@ysnBillPosted					BIT,
			@intCompanyLocationId			INT,
			@dblTotal						NUMERIC(18,6),
			@ysnRequireApproval				BIT,
			@prePayId						Id,
			@intTicketId					INT,
			@intInvoiceDetailId				INT,
			@ysnInvoicePosted				BIT,
			@intPriceFixationDetailId		INT,
			@intPriceFixationId				INT,
			@dblPriceFixedQty				NUMERIC(18,6),
			@dblTotalBillQty			    NUMERIC(18,6),
			@dblReceived			        NUMERIC(18,6),
			@dblQtyToBill			        NUMERIC(18,6),
			@intUniqueId					INT,
			@dblFinalPrice					NUMERIC(18,6),
			@intBillQtyUOMId				INT,
			@intItemUOMId				    INT,
			@intInventoryReceiptItemId		INT,  
			@dblTotalInvoiceQty 			NUMERIC(18,6),  
			@intInventoryShipmentItemId		INT,  
			@dblShipped						NUMERIC(18,6),  
			@dblQtyToInvoice				NUMERIC(18,6),
			@intInvoiceQtyUOMId				INT,
			@dblInvoicePrice				NUMERIC(18,6),
			@dblVoucherPrice				NUMERIC(18,6),
			@dblQtyToCheck					NUMERIC(18,6),
			@batchIdUsed					NVARCHAR(MAX)

	SELECT	@dblCashPrice			=	dblCashPrice, 
			@intPricingTypeId		=	intPricingTypeId, 
			@intLastModifiedById	=	ISNULL(intLastModifiedById,intCreatedById),
			@intContractHeaderId	=	intContractHeaderId,
			@intCompanyLocationId	=	intCompanyLocationId
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId		=	@intContractDetailId
	
	DECLARE @tblToProcess TABLE
	(
			intUniqueId					INT IDENTITY,
			intInventoryId				INT,
			intInventoryItemId			INT,
			dblQty						NUMERIC(18,6)
	)

	SELECT	@intItemUOMId = intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
		
	SELECT	@intEntityId		=	intEntityId,
			@intContractTypeId	=	intContractTypeId
	FROM	tblCTContractHeader 
	WHERE	intContractHeaderId = @intContractHeaderId

	SELECT  @intUserId = ISNULL(@intUserId,@intLastModifiedById)

	SELECT	@ysnAllowChangePricing = ysnAllowChangePricing, @ysnEnablePriceContractApproval = ISNULL(ysnEnablePriceContractApproval,0) FROM tblCTCompanyPreference

	SELECT	@intPriceFixationId = intPriceFixationId FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId

	IF	@ysnAllowChangePricing = 1 OR @intPriceFixationId IS NULL
		RETURN

    SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId

	WHILE ISNULL(@intPriceFixationDetailId, 0)  > 0 
	BEGIN

		SELECT	@intBillId = NULL, @intBillDetailId = NULL, @intInvoiceId = NULL, @intInvoiceDetailId = NULL

		SELECT	@dblPriceFixedQty	=	dblQuantity, 
				@intBillId			=	intBillId,
				@intBillDetailId	=	intBillDetailId, 
				@intInvoiceId		=	intInvoiceId, 
				@intInvoiceDetailId =	intInvoiceDetailId, 
				@dblFinalPrice		=	dblFinalPrice 
		FROM	tblCTPriceFixationDetail 
		WHERE	intPriceFixationDetailId = @intPriceFixationDetailId

		IF @intContractTypeId = 1 
		BEGIN
			IF OBJECT_ID('tempdb..#tblReceipt') IS NOT NULL  								
				DROP TABLE #tblReceipt								

			SELECT  RI.intInventoryReceiptId,
					RI.intInventoryReceiptItemId,
					dbo.fnCTConvertQtyToTargetItemUOM(RI.intUnitMeasureId,CD.intItemUOMId,RI.dblReceived) dblReceived,
					RI.intUnitMeasureId,
					BD.intBillId,
					BD.intBillDetailId,
					IR.strReceiptNumber,
					dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId,CD.intItemUOMId,BD.dblQtyReceived) dblQtyReceived
			
			INTO    #tblReceipt
			FROM    tblICInventoryReceiptItem   RI
			JOIN    tblICInventoryReceipt		IR  ON  IR.intInventoryReceiptId		=   RI.intInventoryReceiptId
													AND IR.strReceiptType				=   'Purchase Contract'
			JOIN    tblCTContractDetail			CD  ON  CD.intContractDetailId			=   RI.intLineNo
	  LEFT  JOIN    tblAPBillDetail				BD  ON  BD.intInventoryReceiptItemId	=   RI.intInventoryReceiptItemId 
													AND	BD.intInventoryReceiptChargeId	IS	NULL
			WHERE	RI.intLineNo	=   @intContractDetailId 
			

			IF ISNULL(@intBillId,0) = 0
			BEGIN

				DELETE	FROM @tblToProcess

				SELECT	@intInventoryReceiptId = MIN(intInventoryReceiptId)  FROM #tblReceipt
			 
				WHILE	ISNULL(@intInventoryReceiptId,0) > 0 AND @dblPriceFixedQty > 0
				BEGIN
					SELECT	@dblTotalBillQty = SUM(ISNULL(dblQtyReceived,0)),@dblReceived = dblReceived,@intInventoryReceiptItemId = intInventoryReceiptItemId FROM #tblReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId GROUP BY dblReceived,intInventoryReceiptItemId
					SELECT	@strVendorOrderNumber = strTicketNumber, @intTicketId = intTicketId FROM tblSCTicket WHERE intInventoryReceiptId = @intInventoryReceiptId
					SELECT	@strVendorOrderNumber = ISNULL(strPrefix,'') + @strVendorOrderNumber FROM tblSMStartingNumber WHERE strTransactionType = 'Ticket Management' AND strModule = 'Ticket Management'

					IF @dblTotalBillQty < @dblReceived 
					BEGIN
						SELECT	@dblQtyToBill = @dblReceived - @dblTotalBillQty - @dblPriceFixedQty
						IF	@dblQtyToBill >= 0
						BEGIN
							INSERT	INTO @tblToProcess
							SELECT	@intInventoryReceiptId,@intInventoryReceiptItemId,@dblPriceFixedQty
							SELECT	@dblPriceFixedQty = 0
						END
						ELSE 
						BEGIN
							INSERT	INTO @tblToProcess
							SELECT	@intInventoryReceiptId,@intInventoryReceiptItemId,@dblPriceFixedQty + @dblQtyToBill
							SELECT	@dblPriceFixedQty = ABS(@dblQtyToBill)
							SELECT	@intInventoryReceiptId = MIN(intInventoryReceiptId)  FROM #tblReceipt WHERE intInventoryReceiptId > @intInventoryReceiptId
						END  
					END
					ELSE
					BEGIN
						SELECT	@intInventoryReceiptId = MIN(intInventoryReceiptId)  FROM #tblReceipt WHERE intInventoryReceiptId > @intInventoryReceiptId
					END
				END

				SELECT	@intUniqueId = MIN(intUniqueId)  FROM @tblToProcess 
			 
				WHILE	ISNULL(@intUniqueId,0) > 0 
				BEGIN
					SELECT	@intInventoryReceiptId = intInventoryId,@dblQtyToBill = dblQty,@intInventoryReceiptItemId = intInventoryItemId  FROM @tblToProcess WHERE intUniqueId = @intUniqueId							

					IF EXISTS(SELECT * FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId AND intInventoryReceiptChargeId IS	NULL)
					BEGIN
						SELECT	@intBillId = intBillId FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
				    
						SELECT  @ysnBillPosted = ysnPosted FROM tblAPBill WHERE intBillId = @intBillId
						
						DELETE	FROM @voucherDetailReceipt

						IF ISNULL(@ysnBillPosted,0) = 1
						BEGIN
							EXEC [dbo].[uspAPPostBill] @post = 0,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
						END

						INSERT	INTO @voucherDetailReceipt([intInventoryReceiptType], [intInventoryReceiptItemId], [dblQtyReceived], [dblCost])
						SELECT	2,@intInventoryReceiptItemId, @dblQtyToBill, @dblFinalPrice
				    
						EXEC	uspAPCreateVoucherDetailReceipt @intBillId,@voucherDetailReceipt
				    
						SELECT	@intBillDetailId = intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intBillId AND intContractDetailId = @intContractDetailId AND intInventoryReceiptChargeId IS NULL
				    
						UPDATE	tblAPBillDetail SET dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(intUnitOfMeasureId, intWeightUOMId, dblQtyOrdered) WHERE intBillDetailId = @intBillDetailId

						EXEC	uspAPUpdateCost @intBillDetailId,@dblFinalPrice,1

						IF ISNULL(@ysnBillPosted,0) = 1
						BEGIN
							EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
						END

						UPDATE	tblCTPriceFixationDetail SET intBillId = @intBillId,intBillDetailId = @intBillDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
					END
					ELSE
					BEGIN
						EXEC	uspICProcessToBill @intInventoryReceiptId,@intUserId, @intNewBillId OUTPUT

						UPDATE	tblAPBill SET strVendorOrderNumber = @strVendorOrderNumber WHERE intBillId = @intNewBillId

						SELECT	@intBillDetailId = intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intNewBillId AND intInventoryReceiptChargeId IS NULL

						UPDATE	tblAPBillDetail SET dblQtyOrdered = @dblQtyToBill, dblQtyReceived = @dblQtyToBill,dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId, intWeightUOMId, @dblQtyToBill) WHERE intBillDetailId = @intBillDetailId

						EXEC	uspAPUpdateCost @intBillDetailId,@dblFinalPrice,1

						UPDATE	tblCTPriceFixationDetail SET intBillId = @intNewBillId,intBillDetailId = @intBillDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId

						SELECT	@intTicketId = intTicketId FROM tblSCTicket WHERE intInventoryReceiptId = @intInventoryReceiptId

						DELETE FROM @prePayId

						INSERT	INTO @prePayId([intId])
						SELECT	DISTINCT BD.intBillId
						FROM	tblAPBillDetail BD
						JOIN	tblAPBill		BL	ON BL.intBillId	=	BD.intBillId
						JOIN	tblSCTicket		TK  ON TK.intTicketId =  BD.intScaleTicketId
						WHERE	BD.intContractDetailId = @intContractDetailId AND BD.intScaleTicketId = @intTicketId AND BL.intTransactionType IN (2, 13)

						IF EXISTS(SELECT * FROM	@prePayId)
						BEGIN
							EXEC uspAPApplyPrepaid @intNewBillId, @prePayId
						END

						EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intNewBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
					END

					SELECT @intUniqueId = MIN(intUniqueId)  FROM @tblToProcess WHERE intUniqueId > @intUniqueId
				END		
			END
			ELSE
			BEGIN
				SELECT  @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillDetailId = @intBillDetailId
				
				SELECT  @ysnBillPosted = ysnPosted FROM tblAPBill WHERE intBillId = @intBillId
				
				SELECT  @intBillQtyUOMId = intUnitOfMeasureId,
						@dblTotalBillQty = dblQtyReceived,
						@dblQtyToCheck   = dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intBillQtyUOMId,@dblPriceFixedQty),
						@dblVoucherPrice = dblCost
				FROM    tblAPBillDetail 
				WHERE   intBillDetailId = @intBillDetailId AND intInventoryReceiptChargeId IS NULL

				IF  @dblQtyToCheck		<>	@dblTotalBillQty	OR
					@dblVoucherPrice	<>	@dblFinalPrice
					
				BEGIN
					EXEC	[dbo].[uspSMTransactionCheckIfRequiredApproval]
									@type					=	N'AccountsPayable.view.Voucher',
									@transactionEntityId	=	@intEntityId,
									@currentUserEntityId	=	@intUserId,
									@locationId				=	@intCompanyLocationId,
									@amount					=	@dblTotal,
									@requireApproval		=	@ysnRequireApproval OUTPUT

					IF  ISNULL(@ysnRequireApproval , 0) = 0
					BEGIN
							IF ISNULL(@ysnBillPosted,0) = 1
							BEGIN
								EXEC [dbo].[uspAPPostBill] @post = 0,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT, @batchIdUsed = @batchIdUsed OUTPUT
								IF ISNULL(@ysnSuccess, 0) = 0
								BEGIN
									SELECT @ErrMsg = strMessage FROM tblAPPostResult WHERE strBatchNumber = @batchIdUsed
									IF ISNULL(@ErrMsg, '') != ''
									BEGIN
										RAISERROR(@ErrMsg, 11, 1);
										RETURN;
									END
								END
							END

							UPDATE tblAPBillDetail SET dblQtyOrdered = @dblQtyToCheck, dblQtyReceived = @dblQtyToCheck WHERE intBillDetailId = @intBillDetailId

							EXEC uspAPUpdateCost @intBillDetailId,@dblFinalPrice,1

							IF ISNULL(@ysnBillPosted,0) = 1
							BEGIN
								EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
							END
					END
				END
			END
		END

		IF @intContractTypeId = 2 
		BEGIN
			IF OBJECT_ID('tempdb..#tblShipment') IS NOT NULL  								
				DROP TABLE #tblShipment								

			SELECT  RI.intInventoryShipmentId,
					RI.intInventoryShipmentItemId,
					dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,RI.dblQuantity) dblShipped,
					BD.intInvoiceId,
					BD.intInvoiceDetailId,
					IR.strShipmentNumber,
					dbo.fnCTConvertQtyToTargetItemUOM(BD.intItemUOMId,CD.intItemUOMId,BD.dblQtyShipped) dblQtyShipped
			
			INTO    #tblShipment
			FROM    tblICInventoryShipmentItem  RI
			JOIN    tblICInventoryShipment		IR  ON  IR.intInventoryShipmentId		=   RI.intInventoryShipmentId
													AND IR.intOrderType					=   1
			JOIN    tblCTContractDetail			CD  ON  CD.intContractDetailId			=   RI.intLineNo
	  LEFT  JOIN    tblARInvoiceDetail			BD  ON  BD.intInventoryShipmentItemId	=   RI.intInventoryShipmentItemId 

			WHERE	RI.intLineNo	=   @intContractDetailId 
			AND		BD.intInventoryShipmentChargeId IS NULL

			IF ISNULL(@intInvoiceId,0) = 0
			BEGIN
			
				DELETE	FROM @tblToProcess

				SELECT	@intInventoryShipmentId = MIN(intInventoryShipmentId)  FROM #tblShipment
			 
				WHILE	ISNULL(@intInventoryShipmentId,0) > 0 AND @dblPriceFixedQty > 0
				BEGIN
					SELECT	@dblTotalInvoiceQty = SUM(ISNULL(dblQtyShipped,0)),@dblShipped = dblShipped, @intInventoryShipmentItemId = intInventoryShipmentItemId FROM #tblShipment WHERE intInventoryShipmentId = @intInventoryShipmentId GROUP BY dblShipped,intInventoryShipmentItemId

					IF @dblTotalInvoiceQty < @dblShipped 
					BEGIN
						SELECT	@dblQtyToInvoice = @dblShipped - @dblTotalInvoiceQty - @dblPriceFixedQty
						IF	@dblQtyToInvoice >= 0
						BEGIN
							INSERT	INTO @tblToProcess
							SELECT	@intInventoryShipmentId,@intInventoryShipmentItemId,@dblPriceFixedQty
							SELECT	@dblPriceFixedQty = 0
						END
						ELSE 
						BEGIN
							INSERT	INTO @tblToProcess
							SELECT	@intInventoryShipmentId,@intInventoryShipmentItemId,@dblPriceFixedQty + @dblQtyToInvoice
							SELECT	@dblPriceFixedQty = ABS(@dblQtyToInvoice)
							SELECT	@intInventoryShipmentId = MIN(intInventoryShipmentId)  FROM #tblShipment WHERE intInventoryShipmentId > @intInventoryShipmentId
						END  
					END
					ELSE
					BEGIN
						SELECT	@intInventoryShipmentId = MIN(intInventoryShipmentId)  FROM #tblShipment WHERE intInventoryShipmentId > @intInventoryShipmentId
					END
				END

				SELECT	@intUniqueId = MIN(intUniqueId)  FROM @tblToProcess 
			 
				WHILE	ISNULL(@intUniqueId,0) > 0 
				BEGIN
					SELECT	@intInventoryShipmentId = intInventoryId,@dblQtyToInvoice = dblQty,@intInventoryShipmentItemId = intInventoryItemId  FROM @tblToProcess WHERE intUniqueId = @intUniqueId							

					IF EXISTS(SELECT * FROM tblARInvoiceDetail WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId)
					BEGIN
						SELECT	@intInvoiceId = intInvoiceId FROM tblARInvoiceDetail WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId

						SELECT	@strShipmentNumber = strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intInventoryShipmentId

						SELECT  @ysnInvoicePosted = ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId

						SELECT	@intInvoiceDetailId = intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId AND intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL

						IF ISNULL(@ysnInvoicePosted,0) = 1
						BEGIN
							EXEC	uspARPostInvoice
									 @param				= @intInvoiceId
									,@post				= 0
									,@userId			= @intUserId
									,@raiseError		= 1
						END

						EXEC	[uspCTCreateInvoiceDetail] @intInvoiceDetailId, @intInventoryShipmentId, @dblQtyToInvoice, @dblFinalPrice, @intUserId

						IF ISNULL(@ysnInvoicePosted,0) = 1
						BEGIN
							EXEC	uspARPostInvoice
									 @param				= @intInvoiceId
									,@post				= 1
									,@userId			= @intUserId
									,@raiseError		= 1
						END		
						
						SELECT	@intInvoiceDetailId = intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId AND intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL

						UPDATE	tblCTPriceFixationDetail SET intInvoiceId = @intInvoiceId, intInvoiceDetailId = @intInvoiceDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
					END
					ELSE
					BEGIN

						EXEC	uspARCreateInvoiceFromShipment 
								 @ShipmentId		= @intInventoryShipmentId
								,@UserId			= @intUserId
								,@NewInvoiceId		= @intNewInvoiceId	OUTPUT
				
						SELECT	@intInvoiceDetailId = intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId AND intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL

						EXEC	uspARUpdateInvoiceDetails	
								@intInvoiceDetailId	=	@intInvoiceDetailId,
								@intEntityId		=	@intUserId, 
								@dblQtyShipped		=	@dblQtyToInvoice

						EXEC	uspARUpdateInvoicePrice 
								 @InvoiceId			=	@intNewInvoiceId
								,@InvoiceDetailId	=	@intInvoiceDetailId
								,@Price				=	@dblFinalPrice
								,@UserId			=	@intUserId

						EXEC	uspARPostInvoice
								 @param				= @intNewInvoiceId
								,@post				= 1
								,@userId			= @intUserId
								,@raiseError		= 1

						UPDATE	tblCTPriceFixationDetail SET intInvoiceId = @intNewInvoiceId,intInvoiceDetailId = @intInvoiceDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
					END

					SELECT @intUniqueId = MIN(intUniqueId)  FROM @tblToProcess WHERE intUniqueId > @intUniqueId
				END					 
			END
			ELSE
			BEGIN
				SELECT  @dblTotal = SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId
				
				SELECT  @ysnInvoicePosted = ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId
				
				SELECT  @intInvoiceQtyUOMId =	intItemUOMId,
						@dblTotalInvoiceQty =	dblQtyShipped,
						@dblInvoicePrice	=	dblPrice,
						@dblQtyToCheck		=	dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intInvoiceQtyUOMId,@dblPriceFixedQty)

				FROM    tblARInvoiceDetail 
				WHERE   intInvoiceDetailId = @intInvoiceDetailId AND intInventoryShipmentChargeId IS NULL

				IF	@dblQtyToCheck		<>	@dblTotalInvoiceQty OR
					@dblInvoicePrice	<>	@dblFinalPrice
				BEGIN
					
					IF ISNULL(@ysnInvoicePosted,0) = 1
					BEGIN
						EXEC	uspARPostInvoice
								 @param				= @intInvoiceId
								,@post				= 0
								,@userId			= @intUserId
								,@raiseError		= 1
					END
						
					EXEC	uspARUpdateInvoiceDetails	
							@intInvoiceDetailId	=	@intInvoiceDetailId,
							@intEntityId		=	@intUserId, 
							@dblQtyShipped		=	@dblQtyToCheck

					EXEC	uspARUpdateInvoicePrice 
							 @InvoiceId			=	@intInvoiceId
							,@InvoiceDetailId	=	@intInvoiceDetailId
							,@Price				=	@dblFinalPrice
							,@UserId			=	@intUserId

					IF ISNULL(@ysnInvoicePosted,0) = 1
					BEGIN
						EXEC	uspARPostInvoice
								 @param				= @intInvoiceId
								,@post				= 1
								,@userId			= @intUserId
								,@raiseError		= 1
					END					
				END
			END
		END

	   SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
    END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO