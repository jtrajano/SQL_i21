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
			@intInventoryReceiptItemId		INT  

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
			intInventoryReceiptId		INT,
			intInventoryReceiptItemId   INT,
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

		SELECT	@intBillId = NULL, @intBillDetailId = NULL

		SELECT	@dblPriceFixedQty = dblQuantity, @intBillId =  intBillId,@intBillDetailId =  intBillDetailId, @intInvoiceId  = intInvoiceId, @dblFinalPrice = dblFinalPrice FROM tblCTPriceFixationDetail WHERE intPriceFixationDetailId = @intPriceFixationDetailId

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

			WHERE	RI.intLineNo	=   @intContractDetailId 
			AND		BD.intInventoryReceiptChargeId IS NULL

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
					SELECT	@intInventoryReceiptId = intInventoryReceiptId,@dblQtyToBill = dblQty,@intInventoryReceiptItemId = intInventoryReceiptItemId  FROM @tblToProcess WHERE intUniqueId = @intUniqueId							

					IF EXISTS(SELECT * FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId)
					BEGIN
						SELECT	@intBillId = intBillId FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
				    
						DELETE	FROM @voucherDetailReceipt

						INSERT	INTO @voucherDetailReceipt([intInventoryReceiptType], [intInventoryReceiptItemId], [dblQtyReceived], [dblCost])
						SELECT	2,@intInventoryReceiptItemId, @dblQtyToBill, @dblFinalPrice
				    
						EXEC	uspAPCreateVoucherDetailReceipt @intBillId,@voucherDetailReceipt
				    
						SELECT	@intBillDetailId = intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intBillId AND intContractDetailId = @intContractDetailId AND intInventoryReceiptChargeId IS NULL
				    
						EXEC	uspAPUpdateCost @intBillDetailId,@dblFinalPrice,1

						UPDATE	tblCTPriceFixationDetail SET intBillId = @intBillId,intBillDetailId = @intBillDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
					END
					ELSE
					BEGIN
						EXEC	uspICProcessToBill @intInventoryReceiptId,@intUserId, @intNewBillId OUTPUT

						UPDATE	tblAPBill SET strVendorOrderNumber = @strVendorOrderNumber WHERE intBillId = @intNewBillId

						SELECT	@intBillDetailId = intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intNewBillId AND intInventoryReceiptChargeId IS NULL

						UPDATE	tblAPBillDetail SET dblQtyOrdered = @dblQtyToBill, dblQtyReceived = @dblQtyToBill WHERE intBillDetailId = @intBillDetailId

						EXEC	uspAPUpdateCost @intBillDetailId,@dblFinalPrice,1

						UPDATE	tblCTPriceFixationDetail SET intBillId = @intNewBillId,intBillDetailId = @intBillDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
					END

					SELECT @intUniqueId = MIN(intUniqueId)  FROM @tblToProcess WHERE intUniqueId > @intUniqueId
				END		

				/*
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
				*/	
			 
			END
			ELSE
			BEGIN
				SELECT  @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillDetailId = @intBillDetailId
				
				SELECT  @ysnBillPosted = ysnPosted FROM tblAPBill WHERE intBillId = @intBillId
				
				SELECT  @intBillQtyUOMId = intUnitOfMeasureId,
						@dblTotalBillQty = dblQtyReceived
				FROM    tblAPBillDetail 
				WHERE   intBillDetailId = @intBillDetailId AND intInventoryReceiptChargeId IS NULL

				IF dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intBillQtyUOMId,@dblPriceFixedQty) <> @dblTotalBillQty
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
								EXEC [dbo].[uspAPPostBill] @post = 0,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
							END

							UPDATE tblAPBillDetail SET dblQtyOrdered = @dblPriceFixedQty, dblQtyReceived = @dblPriceFixedQty WHERE intBillDetailId = @intBillDetailId

							EXEC uspAPUpdateCost @intBillDetailId,@dblFinalPrice,1

							IF ISNULL(@ysnBillPosted,0) = 1
							BEGIN
								EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
							END
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