CREATE PROCEDURE [dbo].[uspCTCreateVoucherInvoiceForPartialPricing]
		
	@intContractDetailId	INT,
	@intUserId				INT = NULL
	
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
			@dblTotalIVForPFQty				NUMERIC(18,6),
			@batchIdUsed					NVARCHAR(MAX),
			@dblQtyShipped					NUMERIC(18,6),
			@dblQtyReceived					NUMERIC(18,6),
			@intPriceFixationDetailAPARId	INT,
			@dblPriceFxdQty					NUMERIC(18,6),
			@dblRemainingQty				NUMERIC(18,6),
			@dblTotalIVForSHQty				NUMERIC(18,6),
			@intPFDetailId					INT,
			@ysnDestinationWeightsAndGrades	BIT,
			@strInvoiceNumber				NVARCHAR(100),
			@strBillId						NVARCHAR(100),
			@strPostedAPAR					NVARCHAR(MAX),
			@intReceiptUniqueId				INT,  
			@intShipmentUniqueId			INT,
			@ysnTicketBased					BIT

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
		dblQty						NUMERIC(18,6),
		intPFDetailId				INT
	)

	DECLARE @tblReceipt TABLE
	(
		intReceiptUniqueId			INT IDENTITY,
		intInventoryReceiptId		INT,
		intInventoryReceiptItemId	INT,
		dblReceived					NUMERIC(26,16),
		strReceiptNumber			NVARCHAR(50),
		dblTotalIVForSHQty			NUMERIC(26,16)
	)

	DECLARE @tblShipment TABLE
	(
		intShipmentUniqueId				INT IDENTITY,
		intInventoryShipmentId			INT,
		intInventoryShipmentItemId		INT,
		dblShipped						NUMERIC(26,16),
		strShipmentNumber				NVARCHAR(50),
		dblTotalIVForSHQty				NUMERIC(26,16),
		ysnDestinationWeightsAndGrades	BIT
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

		--SELECT	@intBillId = NULL, @intBillDetailId = NULL, @intInvoiceId = NULL, @intInvoiceDetailId = NULL

		SELECT	@dblPriceFixedQty	=	FD.dblQuantity,
				@dblPriceFxdQty		=	FD.dblQuantity, 
				@intBillId			=	FD.intBillId,
				@intBillDetailId	=	FD.intBillDetailId, 
				--@intInvoiceId		=	FD.intInvoiceId, 
				--@intInvoiceDetailId =	FD.intInvoiceDetailId, 
				@dblFinalPrice		=	[dbo].[fnCTConvertToSeqFXCurrency](PF.intContractDetailId,PC.intFinalCurrencyId,IU.intItemUOMId,FD.dblFinalPrice)
		FROM	tblCTPriceFixationDetail	FD
		JOIN	tblCTPriceFixation			PF	ON	PF.intPriceFixationId			=	FD.intPriceFixationId
		JOIN	tblCTPriceContract			PC	ON	PC.intPriceContractId			=	PF.intPriceContractId
		JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	PF.intContractDetailId
		JOIN	tblICCommodityUnitMeasure	CO	ON	CO.intCommodityUnitMeasureId	=	FD.intPricingUOMId
		JOIN	tblICItemUOM				IU	ON	IU.intItemId					=	CD.intItemId 
												AND IU.intUnitMeasureId				=	CO.intUnitMeasureId
		WHERE	intPriceFixationDetailId = @intPriceFixationDetailId

		IF @intContractTypeId = 1 
		BEGIN
		
			DELETE FROM @tblReceipt
							
			IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixationTicket WHERE intPricingId = @intPriceFixationDetailId)
			BEGIN
				INSERT INTO @tblReceipt
				SELECT  RI.intInventoryReceiptId,
						RI.intInventoryReceiptItemId,
						dbo.fnCTConvertQtyToTargetItemUOM(RI.intUnitMeasureId,CD.intItemUOMId,RI.dblReceived) dblReceived,
						IR.strReceiptNumber,
						(
							SELECT  SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intUnitOfMeasureId,@intItemUOMId,dblQtyReceived)) 
							FROM	tblAPBillDetail ID 
							WHERE	intInventoryReceiptItemId = RI.intInventoryReceiptItemId AND intInventoryReceiptChargeId IS NULL
						) AS dblTotalIVForSHQty
				FROM    tblICInventoryReceiptItem   RI
				JOIN    tblICInventoryReceipt		IR  ON  IR.intInventoryReceiptId		=   RI.intInventoryReceiptId
														AND IR.strReceiptType				=   'Purchase Contract'
				JOIN    tblCTContractDetail			CD  ON  CD.intContractDetailId			=   RI.intLineNo
				---- TICKET BASED
				JOIN	tblCTPriceFixationTicket	FT	ON	FT.intInventoryReceiptId		=	RI.intInventoryReceiptId 
														AND	FT.intPricingId					=	@intPriceFixationDetailId
				WHERE	RI.intLineNo	=   @intContractDetailId
				ORDER BY dblTotalIVForSHQty DESC

				SET @ysnTicketBased = 1
			END
			ELSE
			BEGIN
				IF @ysnTicketBased = 1 
				BEGIN
					SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
					CONTINUE
				END		
				INSERT INTO @tblReceipt
				SELECT  RI.intInventoryReceiptId,
						RI.intInventoryReceiptItemId,
						dbo.fnCTConvertQtyToTargetItemUOM(RI.intUnitMeasureId,CD.intItemUOMId,RI.dblReceived) dblReceived,
						IR.strReceiptNumber,
						(
							SELECT  SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intUnitOfMeasureId,@intItemUOMId,dblQtyReceived)) 
							FROM	tblAPBillDetail ID 
							WHERE	intInventoryReceiptItemId = RI.intInventoryReceiptItemId AND intInventoryReceiptChargeId IS NULL
						) AS dblTotalIVForSHQty

				FROM    tblICInventoryReceiptItem   RI
				JOIN    tblICInventoryReceipt		IR  ON  IR.intInventoryReceiptId		=   RI.intInventoryReceiptId
														AND IR.strReceiptType				=   'Purchase Contract'
				JOIN    tblCTContractDetail			CD  ON  CD.intContractDetailId			=   RI.intLineNo
				WHERE	RI.intLineNo	=  @intContractDetailId
			END
			
			SELECT	@dblRemainingQty = 0

			SELECT	@intReceiptUniqueId = MIN(intReceiptUniqueId)  FROM @tblReceipt

			WHILE	ISNULL(@intReceiptUniqueId,0) > 0 
			BEGIN

				SELECT	@intInventoryReceiptItemId = MIN(intInventoryReceiptItemId)  FROM @tblReceipt WHERE intReceiptUniqueId = @intReceiptUniqueId

				SELECT @intPFDetailId = 0

				DELETE	FROM @tblToProcess

				SELECT	@dblTotalIVForSHQty		= ISNULL(dblTotalIVForSHQty,0),
						@dblReceived			= dblReceived,
						@intInventoryReceiptId = intInventoryReceiptId 
				FROM	@tblReceipt 
				WHERE	intInventoryReceiptItemId = @intInventoryReceiptItemId

				SELECT	@dblTotalIVForPFQty = SUM(dbo.fnCTConvertQtyToTargetItemUOM(AD.intUnitOfMeasureId,@intItemUOMId,dblQtyReceived))
				FROM	tblCTPriceFixationDetailAPAR	AA
				JOIN	tblAPBillDetail					AD	ON	AD.intBillDetailId	=	AA.intBillDetailId
				WHERE	intPriceFixationDetailId = @intPriceFixationDetailId

				SELECT	@dblTotalIVForPFQty = ISNULL(@dblTotalIVForPFQty,0)

				SELECT	@strVendorOrderNumber = strTicketNumber, @intTicketId = intTicketId FROM tblSCTicket WHERE intInventoryReceiptId = @intInventoryReceiptId
				SELECT	@strVendorOrderNumber = ISNULL(strPrefix,'') + @strVendorOrderNumber FROM tblSMStartingNumber WHERE strTransactionType = 'Ticket Management' AND strModule = 'Ticket Management'

				IF @dblTotalIVForPFQty = @dblPriceFxdQty
				BEGIN
					SELECT	@dblRemainingQty = 0
					SELECT	@intReceiptUniqueId = MIN(intReceiptUniqueId)  FROM @tblReceipt WHERE intReceiptUniqueId > @intReceiptUniqueId
					CONTINUE
				END

				IF @dblTotalIVForSHQty = @dblReceived AND @dblTotalIVForPFQty > 0
				BEGIN
					SELECT	@dblRemainingQty = @dblPriceFxdQty - @dblTotalIVForPFQty
					SELECT	@intReceiptUniqueId = MIN(intReceiptUniqueId)  FROM @tblReceipt WHERE intReceiptUniqueId > @intReceiptUniqueId
					CONTINUE
				END

				IF @dblRemainingQty > 0
				BEGIN
					SELECT	@intPFDetailId = MAX(intPriceFixationDetailId) 
					FROM	tblCTPriceFixationDetail 
					WHERE	intPriceFixationId = @intPriceFixationId 
					AND		intPriceFixationDetailId < @intPriceFixationDetailId

					IF @dblRemainingQty <= @dblReceived
					BEGIN						
						INSERT	INTO @tblToProcess
						SELECT	@intInventoryReceiptId,@intInventoryReceiptItemId,@dblRemainingQty,@intPriceFixationDetailId

						SELECT	@dblRemainingQty = 0
					END
					ELSE
					BEGIN
						INSERT	INTO @tblToProcess
						SELECT	@intInventoryReceiptId,@intInventoryReceiptItemId,@dblReceived,@intPriceFixationDetailId
						SELECT	@dblRemainingQty = @dblRemainingQty - @dblReceived
					END
				END
				ELSE
				BEGIN
					IF @dblTotalIVForSHQty < @dblReceived
					BEGIN
						IF(@dblReceived - @dblTotalIVForSHQty) <= @dblPriceFxdQty
						BEGIN
							INSERT	INTO @tblToProcess
							SELECT	@intInventoryReceiptId,@intInventoryReceiptItemId,@dblReceived - @dblTotalIVForSHQty,@intPriceFixationDetailId
							SELECT	@dblRemainingQty = @dblPriceFxdQty - (@dblReceived - @dblTotalIVForSHQty)
						END
						ELSE
						BEGIN
							INSERT	INTO @tblToProcess
							SELECT	@intInventoryReceiptId,@intInventoryReceiptItemId,@dblPriceFxdQty,@intPriceFixationDetailId
							SELECT	@dblRemainingQty = 0
						END
					END
				END

				SELECT	@intUniqueId = MIN(intUniqueId)  FROM @tblToProcess 
			 
				WHILE	ISNULL(@intUniqueId,0) > 0 
				BEGIN
					SELECT	@intInventoryReceiptId = intInventoryId,@dblQtyToBill = dblQty,@intInventoryReceiptItemId = intInventoryItemId  FROM @tblToProcess WHERE intUniqueId = @intUniqueId							

					IF EXISTS(SELECT * FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId AND intInventoryReceiptChargeId IS	NULL)
					BEGIN
						SELECT	@intBillId = intBillId, @dblQtyReceived = dblQtyReceived FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
				    
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
				    
						--UPDATE	tblAPBillDetail SET  dblQtyOrdered = @dblQtyToBill, dblQtyReceived = @dblQtyToBill,dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(intUnitOfMeasureId, intWeightUOMId, @dblQtyToBill) WHERE intBillDetailId = @intBillDetailId

						EXEC	uspAPUpdateCost @intBillDetailId,@dblFinalPrice,1

						IF ISNULL(@ysnBillPosted,0) = 1
						BEGIN
							EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
						END

						INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intBillId,intBillDetailId,intConcurrencyId)
						SELECT @intPriceFixationDetailId,@intBillId,@intBillDetailId,1

						--UPDATE	tblCTPriceFixationDetail SET intBillId = @intBillId,intBillDetailId = @intBillDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
					END
					ELSE
					BEGIN
						EXEC	uspICConvertReceiptToVoucher @intInventoryReceiptId,@intUserId, @intNewBillId OUTPUT

						UPDATE	tblAPBill SET strVendorOrderNumber = @strVendorOrderNumber WHERE intBillId = @intNewBillId

						SELECT	@intBillDetailId = intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intNewBillId AND intInventoryReceiptChargeId IS NULL

						UPDATE	tblAPBillDetail SET dblQtyReceived = @dblQtyToBill,dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId, intWeightUOMId, @dblQtyToBill) WHERE intBillDetailId = @intBillDetailId

						EXEC	uspAPUpdateCost @intBillDetailId,@dblFinalPrice,1

						INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intBillId,intBillDetailId,intConcurrencyId)
						SELECT @intPriceFixationDetailId,@intNewBillId,@intBillDetailId,1

						--UPDATE	tblCTPriceFixationDetail SET intBillId = @intNewBillId,intBillDetailId = @intBillDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId

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

				SELECT	@intReceiptUniqueId = MIN(intReceiptUniqueId)  FROM @tblReceipt WHERE intReceiptUniqueId > @intReceiptUniqueId
			END

			SELECT @intPriceFixationDetailAPARId = MIN(intPriceFixationDetailAPARId) FROM tblCTPriceFixationDetailAPAR WHERE intPriceFixationDetailId = @intPriceFixationDetailId

			WHILE ISNULL(@intPriceFixationDetailAPARId,0) > 0
			BEGIN

				SELECT	@intBillId = NULL, @intBillDetailId = NULL

				SELECT	@intBillId = intBillId, 
						@intBillDetailId = intBillDetailId 
				FROM	tblCTPriceFixationDetailAPAR 
				WHERE	intPriceFixationDetailAPARId = @intPriceFixationDetailAPARId

				SELECT  @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillDetailId = @intBillDetailId
				
				SELECT  @ysnBillPosted = ysnPosted, @strBillId = strBillId FROM tblAPBill WHERE intBillId = @intBillId
				
				SELECT  @intBillQtyUOMId = intUnitOfMeasureId,
						@dblTotalBillQty = dblQtyReceived,
						@dblTotalIVForPFQty   = dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intBillQtyUOMId,@dblPriceFixedQty),
						@dblVoucherPrice = dblCost
				FROM    tblAPBillDetail 
				WHERE   intBillDetailId = @intBillDetailId AND intInventoryReceiptChargeId IS NULL

				

				IF  @dblVoucherPrice	<>	@dblFinalPrice
					
				BEGIN
					IF @ysnBillPosted = 1
					BEGIN
						SELECT @strPostedAPAR = ISNULL(@strPostedAPAR + ',','') + @strBillId
					END

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

							--UPDATE tblAPBillDetail SET dblQtyOrdered = @dblTotalIVForPFQty, dblQtyReceived = @dblTotalIVForPFQty WHERE intBillDetailId = @intBillDetailId

							EXEC uspAPUpdateCost @intBillDetailId,@dblFinalPrice,1

							IF ISNULL(@ysnBillPosted,0) = 1
							BEGIN
								EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
							END
					END
				END

				SELECT @intPriceFixationDetailAPARId = MIN(intPriceFixationDetailAPARId) FROM tblCTPriceFixationDetailAPAR WHERE intPriceFixationDetailId = @intPriceFixationDetailId AND intPriceFixationDetailAPARId > @intPriceFixationDetailAPARId
			END
		END

		IF @intContractTypeId = 2 
		BEGIN

			DELETE FROM @tblShipment

			IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixationTicket WHERE intPricingId = @intPriceFixationDetailId)
			BEGIN
				INSERT INTO @tblShipment
				SELECT  RI.intInventoryShipmentId,
						RI.intInventoryShipmentItemId,
						dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,RI.dblQuantity) dblShipped,
						IR.strShipmentNumber,
						(
							SELECT  SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intItemUOMId,@intItemUOMId,dblQtyShipped)) 
							FROM	tblARInvoiceDetail ID 
							WHERE	intInventoryShipmentItemId = RI.intInventoryShipmentItemId AND intInventoryShipmentChargeId IS NULL
						) AS dblTotalIVForSHQty,
						ysnDestinationWeightsAndGrades
				FROM    tblICInventoryShipmentItem  RI
				JOIN    tblICInventoryShipment		IR  ON  IR.intInventoryShipmentId		=   RI.intInventoryShipmentId
														AND IR.intOrderType					=   1
				JOIN    tblCTContractDetail			CD  ON  CD.intContractDetailId			=   RI.intLineNo
				---- TICKET BASED
				JOIN	tblCTPriceFixationTicket	FT	ON	FT.intInventoryShipmentId		=	RI.intInventoryShipmentId 
														AND	FT.intPricingId					=	@intPriceFixationDetailId
				WHERE	RI.intLineNo	=   @intContractDetailId
				ORDER BY dblTotalIVForSHQty DESC

				SET @ysnTicketBased = 1
			END
			ELSE
			BEGIN
				IF @ysnTicketBased = 1 
				BEGIN
					SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
					CONTINUE
				END				

				INSERT INTO @tblShipment
				SELECT  RI.intInventoryShipmentId,
						RI.intInventoryShipmentItemId,
						dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,RI.dblQuantity) dblShipped,
						IR.strShipmentNumber,
						(
							SELECT  SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intItemUOMId,@intItemUOMId,dblQtyShipped)) 
							FROM	tblARInvoiceDetail ID 
							WHERE	intInventoryShipmentItemId = RI.intInventoryShipmentItemId AND intInventoryShipmentChargeId IS NULL
						) AS dblTotalIVForSHQty,
						ysnDestinationWeightsAndGrades
				FROM    tblICInventoryShipmentItem  RI
				JOIN    tblICInventoryShipment		IR  ON  IR.intInventoryShipmentId		=   RI.intInventoryShipmentId
														AND IR.intOrderType					=   1
				JOIN    tblCTContractDetail			CD  ON  CD.intContractDetailId			=   RI.intLineNo
				WHERE	RI.intLineNo	=   @intContractDetailId
			END

			SELECT	@dblRemainingQty = 0

			SELECT	@intShipmentUniqueId = MIN(intShipmentUniqueId)  FROM @tblShipment
			
			WHILE	ISNULL(@intShipmentUniqueId,0) > 0
			BEGIN
			
				SELECT	@intInventoryShipmentItemId = MIN(intInventoryShipmentItemId)  FROM @tblShipment WHERE intShipmentUniqueId = @intShipmentUniqueId
			
				SELECT @intPFDetailId = 0

				DELETE	FROM @tblToProcess

				SELECT	@dblTotalIVForSHQty		= ISNULL(dblTotalIVForSHQty,0),
						@dblShipped				= dblShipped,
						@intInventoryShipmentId = intInventoryShipmentId,
						@ysnDestinationWeightsAndGrades	=	ysnDestinationWeightsAndGrades
				FROM	@tblShipment 
				WHERE	intInventoryShipmentItemId = @intInventoryShipmentItemId

				SELECT	@dblTotalIVForPFQty = SUM(dbo.fnCTConvertQtyToTargetItemUOM(AD.intItemUOMId,@intItemUOMId,dblQtyShipped))
				FROM	tblCTPriceFixationDetailAPAR	AA
				JOIN	tblARInvoiceDetail				AD	ON	AD.intInvoiceDetailId	=	AA.intInvoiceDetailId
				WHERE	intPriceFixationDetailId = @intPriceFixationDetailId

				SELECT	@dblTotalIVForPFQty = ISNULL(@dblTotalIVForPFQty,0)

				IF @ysnDestinationWeightsAndGrades = 1 
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblSCTicket WHERE ISNULL(ysnDestinationWeightGradePost,0) = 0 AND intInventoryShipmentId = @intInventoryShipmentId)
					BEGIN
						SELECT	@intShipmentUniqueId = MIN(intShipmentUniqueId)  FROM @tblShipment WHERE intShipmentUniqueId > @intShipmentUniqueId
						CONTINUE
					END
				END

				IF @dblTotalIVForPFQty = @dblPriceFxdQty
				BEGIN
					SELECT	@dblRemainingQty = 0
					SELECT	@intShipmentUniqueId = MIN(intShipmentUniqueId)  FROM @tblShipment WHERE intShipmentUniqueId > @intShipmentUniqueId
					CONTINUE
				END

				IF @dblTotalIVForSHQty = @dblShipped AND @dblTotalIVForPFQty > 0
				BEGIN
					SELECT	@dblRemainingQty = @dblPriceFxdQty - @dblTotalIVForPFQty
					SELECT	@intShipmentUniqueId = MIN(intShipmentUniqueId)  FROM @tblShipment WHERE intShipmentUniqueId > @intShipmentUniqueId
					CONTINUE
				END

				IF @dblRemainingQty > 0
				BEGIN
					SELECT	@intPFDetailId = MAX(intPriceFixationDetailId) 
					FROM	tblCTPriceFixationDetail 
					WHERE	intPriceFixationId = @intPriceFixationId 
					AND		intPriceFixationDetailId < @intPriceFixationDetailId

					IF @dblRemainingQty <= @dblShipped
					BEGIN						
						INSERT	INTO @tblToProcess
						SELECT	@intInventoryShipmentId,@intInventoryShipmentItemId,@dblRemainingQty,@intPriceFixationDetailId

						SELECT	@dblRemainingQty = 0
					END
					ELSE
					BEGIN
						INSERT	INTO @tblToProcess
						SELECT	@intInventoryShipmentId,@intInventoryShipmentItemId,@dblShipped,@intPriceFixationDetailId
						SELECT	@dblRemainingQty = @dblRemainingQty - @dblShipped
					END
				END
				ELSE
				BEGIN
					IF @dblTotalIVForSHQty < @dblShipped
					BEGIN
						IF(@dblShipped - @dblTotalIVForSHQty) <= @dblPriceFxdQty
						BEGIN
							INSERT	INTO @tblToProcess
							SELECT	@intInventoryShipmentId,@intInventoryShipmentItemId,@dblShipped - @dblTotalIVForSHQty,@intPriceFixationDetailId
							SELECT	@dblRemainingQty = @dblPriceFxdQty - (@dblShipped - @dblTotalIVForSHQty)
						END
						ELSE
						BEGIN
							INSERT	INTO @tblToProcess
							SELECT	@intInventoryShipmentId,@intInventoryShipmentItemId,@dblPriceFxdQty,@intPriceFixationDetailId
							SELECT	@dblRemainingQty = 0
						END
					END
				END

				SELECT	@intUniqueId = MIN(intUniqueId)  FROM @tblToProcess 
			 
				WHILE	ISNULL(@intUniqueId,0) > 0 
				BEGIN
					SELECT	@intInventoryShipmentId = intInventoryId,@dblQtyToInvoice = dblQty,@intInventoryShipmentItemId = intInventoryItemId,@intPFDetailId = intPFDetailId  FROM @tblToProcess WHERE intUniqueId = @intUniqueId							

					IF EXISTS(	SELECT TOP 1 1 FROM tblARInvoiceDetail AD 
								JOIN tblARInvoice IV ON IV.intInvoiceId	=	AD.intInvoiceId
								WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId
								AND	 ISNULL(IV.ysnPosted,0) = 0	)
					BEGIN
						SELECT	@intInvoiceId = AD.intInvoiceId 
						FROM	tblARInvoiceDetail	AD 
						JOIN	tblARInvoice		IV ON IV.intInvoiceId	=	AD.intInvoiceId
						WHERE	intInventoryShipmentItemId = @intInventoryShipmentItemId
						AND		ISNULL(IV.ysnPosted,0) = 0	

						SELECT	@strShipmentNumber = strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intInventoryShipmentId

						SELECT	@intInvoiceDetailId = intInvoiceDetailId,@dblQtyShipped = dblQtyShipped FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId AND intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL
						
						EXEC	[uspCTCreateInvoiceDetail] @intInvoiceDetailId, @intInventoryShipmentId, @dblQtyToInvoice, @dblFinalPrice, @intUserId,@intInvoiceDetailId OUTPUT
						
						INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
						SELECT @intPFDetailId,@intInvoiceId,@intInvoiceDetailId,1
												
					END
					ELSE
					BEGIN

						UPDATE  tblICInventoryShipmentItem SET ysnAllowInvoice = 1 WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId

						EXEC	uspCTCreateInvoiceFromShipment 
								@ShipmentId				=	@intInventoryShipmentId
								,@UserId				=	@intUserId
								,@NewInvoiceId			=	@intNewInvoiceId	OUTPUT
				
						SELECT	@intInvoiceDetailId = intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId AND intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL

						EXEC	uspARUpdateInvoiceDetails	
								@intInvoiceDetailId	=	@intInvoiceDetailId,
								@intEntityId		=	@intUserId, 
								@dblQtyShipped		=	@dblQtyToInvoice

						EXEC	uspARUpdateInvoicePrice 
								@InvoiceId			=	@intNewInvoiceId
								,@InvoiceDetailId	=	@intInvoiceDetailId
								,@Price				=	@dblFinalPrice
								,@ContractPrice		=	@dblFinalPrice
								,@UserId			=	@intUserId
						
						/*CT-2672
						EXEC	uspARPostInvoice
								@param				= @intNewInvoiceId
								,@post				= 1
								,@userId			= @intUserId
								,@raiseError		= 1
						*/

						INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
						SELECT @intPFDetailId,@intNewInvoiceId,@intInvoiceDetailId,1
					
						--UPDATE	tblCTPriceFixationDetail SET intInvoiceId = @intNewInvoiceId,intInvoiceDetailId = @intInvoiceDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
					END

					SELECT @intUniqueId = MIN(intUniqueId)  FROM @tblToProcess WHERE intUniqueId > @intUniqueId
				END

				SELECT	@intShipmentUniqueId = MIN(intShipmentUniqueId)  FROM @tblShipment WHERE intShipmentUniqueId > @intShipmentUniqueId
			END

			SELECT @intPriceFixationDetailAPARId = MIN(intPriceFixationDetailAPARId) FROM tblCTPriceFixationDetailAPAR WHERE intPriceFixationDetailId = @intPriceFixationDetailId

			WHILE ISNULL(@intPriceFixationDetailAPARId,0) > 0
			BEGIN
					
				SELECT	@intInvoiceId = NULL, @intInvoiceDetailId = NULL

				SELECT	@intInvoiceId = intInvoiceId, 
						@intInvoiceDetailId = intInvoiceDetailId 
				FROM	tblCTPriceFixationDetailAPAR 
				WHERE	intPriceFixationDetailAPARId = @intPriceFixationDetailAPARId

				SELECT  @dblTotal = SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId
				
				SELECT  @ysnInvoicePosted = ysnPosted,@strInvoiceNumber = strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId
				
				SELECT  @intInvoiceQtyUOMId =	intItemUOMId,
						@dblTotalInvoiceQty =	dblQtyShipped,
						@dblInvoicePrice	=	dblPrice,
						@dblQtyShipped		=	dblQtyShipped,
						@dblTotalIVForPFQty	=	dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intInvoiceQtyUOMId,@dblPriceFixedQty)

				FROM    tblARInvoiceDetail 
				WHERE   intInvoiceDetailId = @intInvoiceDetailId AND intInventoryShipmentChargeId IS NULL
				
				IF	@dblInvoicePrice	<>	@dblFinalPrice
				BEGIN
					IF @ysnInvoicePosted = 1
					BEGIN
						SELECT @strPostedAPAR = ISNULL(@strPostedAPAR + ',','') + @strInvoiceNumber
					END
				END

				IF	@dblInvoicePrice	<>	@dblFinalPrice AND ISNULL(@ysnInvoicePosted,0) = 0
				BEGIN
					/*CT-2672
					IF ISNULL(@ysnInvoicePosted,0) = 1
					BEGIN
						EXEC	uspARPostInvoice
									@param				= @intInvoiceId
								,@post				= 0
								,@userId			= @intUserId
								,@raiseError		= 1
					END
					*/

					EXEC	uspARUpdateInvoiceDetails	
							@intInvoiceDetailId	=	@intInvoiceDetailId,
							@intEntityId		=	@intUserId, 
							@dblQtyShipped		=	@dblQtyShipped

					EXEC	uspARUpdateInvoicePrice 
								@InvoiceId			=	@intInvoiceId
							,@InvoiceDetailId	=	@intInvoiceDetailId
							,@Price				=	@dblFinalPrice
							,@ContractPrice		=	@dblFinalPrice
							,@UserId			=	@intUserId
						
					/*CT-2672
					IF ISNULL(@ysnInvoicePosted,0) = 1
					BEGIN
						EXEC	uspARPostInvoice
									@param				= @intInvoiceId
								,@post				= 1
								,@userId			= @intUserId
								,@raiseError		= 1
					END	
					*/				
				END

				SELECT @intPriceFixationDetailAPARId = MIN(intPriceFixationDetailAPARId) FROM tblCTPriceFixationDetailAPAR WHERE intPriceFixationDetailId = @intPriceFixationDetailId AND intPriceFixationDetailAPARId > @intPriceFixationDetailAPARId
			END
		END

	   SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
    END

	IF ISNULL(@strPostedAPAR,'') <> ''
	BEGIN
		SET @ErrMsg = 'Cannot Update price as following posted Invoice/Vouchers are available. ' + @strPostedAPAR +'. Unpost those Invoice/Vocuher to continue update the price.'
		RAISERROR(@ErrMsg,16,1)
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO