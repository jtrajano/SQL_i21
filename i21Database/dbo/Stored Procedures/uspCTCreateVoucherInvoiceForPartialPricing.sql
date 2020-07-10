CREATE PROCEDURE [dbo].[uspCTCreateVoucherInvoiceForPartialPricing]
		
	@intContractDetailId	INT,
	@intUserId				INT = NULL,
	@ysnDoUpdateCost		BIT = 0,
	@intTransactionId		INT = NULL
	
AS


BEGIN TRY
	--return
	DECLARE @ErrMsg							NVARCHAR(MAX),
			@dblCashPrice					NUMERIC(18,6),
			@ysnPosted						BIT,
			@strReceiptNumber				NVARCHAR(50),
			@intLastModifiedById			INT,
			@intInventoryReceiptId			INT,
			@intSourceTicketId				INT,
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
			@ysnBillPaid					BIT,
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
			@dblTicketQty			        NUMERIC(18,6),
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
			@ysnTicketBased					BIT = 0,
			@ysnPartialPriced				BIT = 0,
			@ysnCreateNew					BIT = 0,
			@receiptDetails					InventoryUpdateBillQty,
			@ysnLoad						BIT,
			@allowAddDetail					BIT,
			@dblPriceLoadQty				NUMERIC(18, 6),
			@dblPriceFixationLoadApplied	NUMERIC(18, 6),
			@dblInventoryItemLoadApplied	NUMERIC(18, 6),
			@dblInventoryShipmentItemLoadApplied	NUMERIC(18, 6),
			@intShipmentInvoiceDetailId		INT,
			@dtmFixationDate				DATE,
			@detailCreated					Id;

		declare @intPriceContractId int;
		declare @shipment cursor;
		declare @pricing cursor;
		declare @dblPriced numeric(18,6);
		declare @dblInvoicedShipped numeric(18,6);
		declare @dblShippedForInvoice numeric(18,6);
		declare @dblInvoicedPriced numeric(18,6);
		declare @dblPricedForInvoice numeric(18,6);
		declare @dblQuantityForInvoice numeric(18,6);

		
		declare @intShipmentCount int = 0;
		declare @intActiveShipmentId int = 0;
		declare @intPricedLoad int = 0;
		declare @intTotalLoadPriced int = 0;
		declare @PricedShipment table
		(
			intInventoryShipmentId int
		)
		declare @intCommulativeLoadPriced int = 0;
		
		declare @intApplied numeric(18,6) = 0;
		declare @intPreviousPricedLoad numeric(18,6);
		declare @dblLoadAppliedAndPriced numeric(18,6);
		declare @ysnDestinationWeightsGrades bit = convert(bit,0);
		declare @intWeightGradeId int = 0;
		declare @ContractPriceItemUOMId int = null;
		declare @ContractPriceUnitMeasureId int = null;
		declare @ContractDetailItemId int = null;

		declare @InvShp table (
			intInventoryShipmentId int
			,intInventoryShipmentItemId int
			,dblShipped numeric(18,6)
			,intInvoiceDetailId int null
			,intItemUOMId int null
			,intLoadShipped int null
			,dtmInvoiceDate datetime null
		)


		declare @InvShpFinal table (
			intInventoryShipmentId int
			,intInventoryShipmentItemId int
			,dblShipped numeric(18,6)
			,intInvoiceDetailId int null
			,intItemUOMId int null
			,intLoadShipped int null
			,dtmInvoiceDate datetime null
		)

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

	DECLARE @tblCreatedTransaction TABLE
	(
		intTransactionId			INT
	)

	DECLARE @tblReceipt TABLE
	(
		intReceiptUniqueId			INT IDENTITY,
		intInventoryReceiptId		INT,
		intInventoryReceiptItemId	INT,
		dblReceived					NUMERIC(26,16),
		strReceiptNumber			NVARCHAR(50),
		dblTotalIVForSHQty			NUMERIC(26,16),
		dblTicketQty				NUMERIC(26,16),
		dblInventoryItemLoad		NUMERIC(18,6)
	)

	DECLARE @tblShipment TABLE
	(
		intShipmentUniqueId				INT IDENTITY,
		intInventoryShipmentId			INT,
		intInventoryShipmentItemId		INT,
		dblShipped						NUMERIC(26,16),
		strShipmentNumber				NVARCHAR(50),
		dblTotalIVForSHQty				NUMERIC(26,16),
		ysnDestinationWeightsAndGrades	BIT,
		dblInventoryShipmentItemLoad	NUMERIC(18, 6),
		intInvoiceDetailId				INT NULL
	)

	SELECT	@intItemUOMId = intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
	select @intWeightGradeId = intWeightGradeId from tblCTWeightGrade where strWeightGradeDesc = 'Destination'
	--intWeightId, intGradeId
		
	SELECT	@intEntityId		=	intEntityId,
			@intContractTypeId	=	intContractTypeId,
			@ysnLoad			=	ysnLoad,
			@ysnDestinationWeightsGrades = (
												case
												when isnull(@intWeightGradeId,0) = 0
												then convert(bit,0) 
												else (
															case
															when intWeightId = @intWeightGradeId or intGradeId = @intWeightGradeId
															then convert(bit,1)
															else convert(bit,0)
															end
													  )
												end
											)
	FROM	tblCTContractHeader 
	WHERE	intContractHeaderId = @intContractHeaderId

	SELECT  @intUserId = ISNULL(@intUserId,@intLastModifiedById)

	SELECT	@ysnAllowChangePricing = ysnAllowChangePricing, @ysnEnablePriceContractApproval = ISNULL(ysnEnablePriceContractApproval,0) FROM tblCTCompanyPreference

	SELECT	@intPriceFixationId = intPriceFixationId, @intPriceContractId = intPriceContractId FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId

	IF	@ysnAllowChangePricing = 1 OR @intPriceFixationId IS NULL
		RETURN

	SELECT TOP 1 @ysnTicketBased = 1
	FROM tblCTPriceFixation PF 
	INNER JOIN tblCTPriceFixationTicket PFT ON PF.intPriceFixationId = PFT.intPriceFixationId
	WHERE PF.intContractDetailId = @intContractDetailId

	SELECT TOP 1 @ysnPartialPriced = 1 FROM tblCTPriceFixation PF
	INNER JOIN tblCTPriceFixationDetail PFD ON PF.intPriceFixationId = PFD.intPriceFixationId
	INNER JOIN tblCTPriceFixationDetailAPAR APAR ON PFD.intPriceFixationDetailId = APAR.intPriceFixationDetailId
	WHERE PF.intContractDetailId = @intContractDetailId

    IF @intContractTypeId = 1 
    BEGIN

    	SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId

		WHILE ISNULL(@intPriceFixationDetailId, 0)  > 0 
		BEGIN
			
			--SELECT	@intBillId = NULL, @intBillDetailId = NULL, @intInvoiceId = NULL, @intInvoiceDetailId = NULL

			SELECT	@dblPriceFixedQty	=	FD.dblQuantity,
					@dblPriceFxdQty		=	FD.dblQuantity - ISNULL(SS.dblQtyReceived,0),
					@intBillId			=	FD.intBillId,
					@intBillDetailId	=	FD.intBillDetailId, 
					--@intInvoiceId		=	FD.intInvoiceId, 
					--@intInvoiceDetailId =	FD.intInvoiceDetailId, 
					@dblFinalPrice		=	[dbo].[fnCTConvertToSeqFXCurrency](PF.intContractDetailId,PC.intFinalCurrencyId,IU.intItemUOMId,FD.dblFinalPrice),
					@dblPriceLoadQty	=	FD.dblLoadPriced,
					@dblPriceFixationLoadApplied =	ISNULL(FD.dblLoadApplied, 0),
					@dtmFixationDate	=	dtmFixationDate 
			FROM	tblCTPriceFixationDetail	FD
			JOIN	tblCTPriceFixation			PF	ON	PF.intPriceFixationId			=	FD.intPriceFixationId
			JOIN	tblCTPriceContract			PC	ON	PC.intPriceContractId			=	PF.intPriceContractId
			JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	PF.intContractDetailId
			JOIN	tblICCommodityUnitMeasure	CO	ON	CO.intCommodityUnitMeasureId	=	FD.intPricingUOMId
			JOIN	tblICItemUOM				IU	ON	IU.intItemId					=	CD.intItemId 
													AND IU.intUnitMeasureId				=	CO.intUnitMeasureId
			OUTER APPLY
			(
				SELECT	dblQtyReceived = SUM(dbo.fnCTConvertQtyToTargetItemUOM(AD.intUnitOfMeasureId,@intItemUOMId,dblQtyReceived))
				FROM	tblCTPriceFixationDetailAPAR	AA
				JOIN	tblAPBillDetail					AD	ON	AD.intBillDetailId	=	AA.intBillDetailId
				WHERE	intPriceFixationDetailId = @intPriceFixationDetailId
				AND		ISNULL(AD.intSettleStorageId,0) <> 0
			) SS
			WHERE	intPriceFixationDetailId = @intPriceFixationDetailId

			IF @intContractTypeId = 1 AND @dblPriceFxdQty > 0
			BEGIN
			
				DELETE FROM @tblReceipt
								
				IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixationTicket WHERE intPricingId = @intPriceFixationDetailId)
				BEGIN
					INSERT INTO @tblReceipt
					SELECT  RI.intInventoryReceiptId,
							RI.intInventoryReceiptItemId,
							dbo.fnCTConvertQtyToTargetItemUOM(RI.intUnitMeasureId,CD.intItemUOMId,RI.dblOpenReceive) dblReceived,
							IR.strReceiptNumber,
							(
								SELECT  SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intUnitOfMeasureId,@intItemUOMId,dblQtyReceived)) 
								FROM	tblAPBillDetail ID 
								WHERE	intInventoryReceiptItemId = RI.intInventoryReceiptItemId AND intInventoryReceiptChargeId IS NULL
							) AS dblTotalIVForSHQty,
							FT.dblQuantity,
							RI.intLoadReceive
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
							dbo.fnCTConvertQtyToTargetItemUOM(RI.intUnitMeasureId,CD.intItemUOMId,RI.dblOpenReceive) dblReceived,
							IR.strReceiptNumber,
							(
								SELECT  SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intUnitOfMeasureId,@intItemUOMId,dblQtyReceived)) 
								FROM	tblAPBillDetail ID 
								WHERE	intInventoryReceiptItemId = RI.intInventoryReceiptItemId AND intInventoryReceiptChargeId IS NULL
							) AS dblTotalIVForSHQty,
							0,
							RI.intLoadReceive
					FROM    tblICInventoryReceiptItem   RI
					JOIN    tblICInventoryReceipt		IR  ON  IR.intInventoryReceiptId		=   RI.intInventoryReceiptId
															AND IR.strReceiptType				=   'Purchase Contract'
					JOIN    tblCTContractDetail			CD  ON  CD.intContractDetailId			=   RI.intLineNo
					WHERE	RI.intLineNo	=  @intContractDetailId 
						AND (@ysnLoad = 0 or RI.dblBillQty <> dblOpenReceive)
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
							@intInventoryReceiptId	= intInventoryReceiptId,
							@dblTicketQty			= dblTicketQty,
							@dblInventoryItemLoadApplied = dblInventoryItemLoad
					FROM	@tblReceipt 
					WHERE	intInventoryReceiptItemId = @intInventoryReceiptItemId

					SELECT	@dblTotalIVForPFQty = SUM(dbo.fnCTConvertQtyToTargetItemUOM(AD.intUnitOfMeasureId,@intItemUOMId,dblQtyReceived))
					FROM	tblCTPriceFixationDetailAPAR	AA
					JOIN	tblAPBillDetail					AD	ON	AD.intBillDetailId	=	AA.intBillDetailId
					WHERE	intPriceFixationDetailId = @intPriceFixationDetailId
					AND		ISNULL(AD.intSettleStorageId,0) = 0

					SELECT	@dblTotalIVForPFQty = ISNULL(@dblTotalIVForPFQty,0)

					IF EXISTS(SELECT TOP 1 1 FROM @tblReceipt HAVING MIN(intReceiptUniqueId) = @intReceiptUniqueId AND @dblRemainingQty = 0)
					BEGIN
						SET @dblRemainingQty = @dblPriceFxdQty - @dblTotalIVForPFQty
					END

					SELECT	@strVendorOrderNumber = strTicketNumber, @intTicketId = intTicketId 
						FROM tblSCTicket WHERE intInventoryReceiptId = @intInventoryReceiptId

					IF @ysnLoad = 1
					BEGIN
						IF @dblPriceLoadQty = @dblPriceFixationLoadApplied
						BEGIN
							SELECT	@intReceiptUniqueId = MIN(intReceiptUniqueId)  FROM @tblReceipt WHERE intReceiptUniqueId > @intReceiptUniqueId
							CONTINUE
						END
					END
					
					IF CHARINDEX('TKT-', @strVendorOrderNumber) = 0
					BEGIN
						SELECT	@strVendorOrderNumber = ISNULL(strPrefix,'') + @strVendorOrderNumber FROM tblSMStartingNumber WHERE strTransactionType = 'Ticket Management' AND strModule = 'Ticket Management'
					END	

					IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCTicket WHERE intInventoryReceiptId = @intInventoryReceiptId)
					BEGIN
						SELECT @strVendorOrderNumber = strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId
					END
					
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

					
					IF @ysnLoad = 1
					BEGIN
						INSERT	INTO @tblToProcess
						SELECT	@intInventoryReceiptId,@intInventoryReceiptItemId,@dblReceived,@intPriceFixationDetailId
					END 
					ELSE
					BEGIN
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
								SELECT	@intInventoryReceiptId,
										@intInventoryReceiptItemId,
													CASE WHEN @dblTotalIVForSHQty <= @dblReceived 
															THEN @dblReceived - @dblTotalIVForSHQty
															ELSE @dblReceived END
										,@intPriceFixationDetailId
								SELECT	@dblRemainingQty = @dblRemainingQty - (CASE WHEN @dblTotalIVForSHQty <= @dblReceived THEN @dblReceived - @dblTotalIVForSHQty ELSE @dblReceived END)
							END
						END
						ELSE
						BEGIN
							IF @dblTotalIVForSHQty < @dblReceived
							BEGIN
								IF(@dblReceived - @dblTotalIVForSHQty) <= @dblPriceFxdQty
								BEGIN							
									INSERT	INTO @tblToProcess
									SELECT	@intInventoryReceiptId,@intInventoryReceiptItemId,CASE WHEN @ysnTicketBased = 1 THEN @dblTicketQty ELSE @dblReceived - @dblTotalIVForSHQty END,@intPriceFixationDetailId
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
					END

					SELECT	@intUniqueId = MIN(intUniqueId)  FROM @tblToProcess 
					
					IF EXISTS (SELECT TOP 1 1 FROM @tblToProcess)
					WHILE	ISNULL(@intUniqueId,0) > 0 
					BEGIN
						SELECT	@intInventoryReceiptId = intInventoryId, @dblQtyToBill = dblQty, @intInventoryReceiptItemId = intInventoryItemId  FROM @tblToProcess WHERE intUniqueId = @intUniqueId

						SET @allowAddDetail = 0

						IF EXISTS 
						(
							SELECT TOP 1 1 intBillId
							FROM tblAPBill BL
							INNER JOIN tblAPBillDetail BD ON BL.intBillId = BD.intBillId
							LEFT JOIN @tblCreatedTransaction CT ON CT.intTransactionId = BL.intBillId
							WHERE BL.intTransactionType <> 13 and  BD.intInventoryReceiptItemId = @intInventoryReceiptItemId
							AND (BL.ysnPosted = 0 OR ISNULL(CT.intTransactionId, 0) <> 0)
						)
						BEGIN
							SET @allowAddDetail = 1
						END

						IF EXISTS(SELECT top 1 1 FROM tblAPBillDetail a, tblAPBill b WHERE a.intInventoryReceiptItemId = @intInventoryReceiptItemId AND a.intInventoryReceiptChargeId IS NULL AND b.intBillId = a.intBillId and  b.intTransactionType <> 13 AND @allowAddDetail = 1)
						BEGIN
							SELECT	@intBillId = a.intBillId, @dblQtyReceived = a.dblQtyReceived FROM tblAPBillDetail a, tblAPBill b WHERE a.intInventoryReceiptItemId = @intInventoryReceiptItemId and b.intBillId = a.intBillId and b.intTransactionType <> 13

							SELECT  @ysnBillPosted = ysnPosted FROM tblAPBill WHERE intBillId = @intBillId

							DELETE	FROM @voucherDetailReceipt

							IF ISNULL(@ysnBillPosted,0) = 1
							BEGIN
								EXEC [dbo].[uspAPPostBill] @post = 0,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
							END

							-- INSERT	INTO @voucherDetailReceipt([intInventoryReceiptType], [intInventoryReceiptItemId], [dblQtyReceived], [dblCost])
							-- SELECT	2,@intInventoryReceiptItemId, @dblQtyToBill, @dblFinalPrice
					    
							-- EXEC	uspAPCreateVoucherDetailReceipt @intBillId,@voucherDetailReceipt

							DECLARE @voucherPayablesData AS VoucherPayable
							DECLARE @voucherPayableTax AS VoucherDetailTax
							DELETE FROM @voucherPayablesData

							INSERT INTO @voucherPayablesData(
								 [intBillId]
								,[intEntityVendorId]			
								,[intTransactionType]		
								,[intLocationId]	
								,[intShipToId]	
								,[intShipFromId]			
								,[intShipFromEntityId]
								,[intPayToAddressId]
								,[intCurrencyId]					
								,[dtmDate]				
								,[strVendorOrderNumber]			
								,[strReference]						
								,[intPurchaseDetailId]				
								,[intContractHeaderId]				
								,[intContractDetailId]				
								,[intContractSeqId]					
								,[intScaleTicketId]					
								,[intInventoryReceiptItemId]		
								,[intInventoryReceiptChargeId]		
								,[intInventoryShipmentChargeId]
								,[intLoadShipmentCostId]			
								,[intItemId]						
								,[intPurchaseTaxGroupId]
								,[strMiscDescription]				
								,[dblOrderQty]
								,[dblOrderUnitQty]
								,[intOrderUOMId]
								,[dblQuantityToBill]
								,[dblQtyToBillUnitQty]
								,[intQtyToBillUOMId]
								,[dblCost]							
								,[dblCostUnitQty]					
								,[intCostUOMId]						
								,[dblNetWeight]						
								,[dblWeightUnitQty]					
								,[intWeightUOMId]					
								,[intCostCurrencyId]
								,[dblTax]							
								,[dblDiscount]
								,[intCurrencyExchangeRateTypeId]	
								,[ysnSubCurrency]					
								,[intSubCurrencyCents]				
								,[intAccountId]						
								,[intShipViaId]						
								,[intTermId]
								,[strBillOfLading]					
								,[dtmVoucherDate]
								,[intStorageLocationId]
								,[intSubLocationId]
								,[ysnStage]
							)
							SELECT *
							FROM dbo.[fnCTCreateVoucherDetail](@intBillId, @dblQtyToBill, @dblFinalPrice)

							EXEC uspAPAddVoucherDetail @voucherDetails = @voucherPayablesData, @voucherPayableTax = @voucherPayableTax, @throwError = 1
					    
							-- Get the intBillDetailId of the newly inserted voucher item. 
							SELECT	TOP 1	
									@intBillDetailId = a.intBillDetailId 
							FROM	tblAPBillDetail a, tblAPBill b
							WHERE	a.intBillId = @intBillId 
									AND a.intContractDetailId = @intContractDetailId 
									AND a.intInventoryReceiptChargeId IS NULL
									and b.intBillId = a.intBillId
									and b.intTransactionType <> 13
							ORDER BY a.intBillDetailId DESC 
							--UPDATING OF QUANTITY Manual
							UPDATE tblAPBillDetail SET dblQtyOrdered = @dblReceived WHERE intBillDetailId = @intBillDetailId
					    
							-- Add the 'DP/Basis' other charges into the voucher
							BEGIN 
								EXEC uspICAddProRatedReceiptChargesToVoucher
									@intInventoryReceiptItemId
									,@intBillId
									,@intBillDetailId
							END 

							---- CT-3167: HOLD SINCE THE CURRENT IS STILL WORKING
							--DECLARE @voucherPayablesData VoucherPayable
							--DELETE FROM @voucherPayablesData
							--DECLARE @intEntityVendorId INT
							--SELECT @intEntityVendorId = intEntityVendorId FROM tblAPBill WHERE intBillId = @intBillId
							--DECLARE @intItemId INT
							--SELECT	@intItemId = intItemId FROM tblAPBillDetail WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
							--INSERT INTO @voucherPayablesData(intBillId, intTransactionType, intInventoryReceiptItemId, dblQuantityToBill, dblCost, intEntityVendorId, intItemId, strMiscDescription, intAccountId, intQtyToBillUOMId)
							--SELECT	@intBillId, 1, @intInventoryReceiptItemId, @dblQtyToBill, @dblFinalPrice, @intEntityVendorId, @intItemId, 'Soybean Meal - NGMO', 7, 40
							--EXEC uspAPAddVoucherDetail @voucherDetails = @voucherPayablesData, @throwError = 1
							--SELECT	TOP 1 @intBillDetailId = intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intBillId 
							----AND intContractDetailId = @intContractDetailId AND intInventoryReceiptChargeId IS NULL 
							--ORDER BY intBillDetailId DESC
							---- CT-3167: HOLD SINCE THE CURRENT IS STILL WORKING

							--UPDATE	tblAPBillDetail SET  dblQtyOrdered = @dblQtyToBill, dblQtyReceived = @dblQtyToBill,dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(intUnitOfMeasureId, intWeightUOMId, @dblQtyToBill) WHERE intBillDetailId = @intBillDetailId

							IF (ISNULL(@intBillDetailId, 0) <> 0)
							BEGIN
								EXEC uspAPUpdateCost @intBillDetailId, @dblFinalPrice, 1
							END

							-- CT-3983
							DELETE @detailCreated

							INSERT INTO @detailCreated
							SELECT @intBillDetailId

							UPDATE APD
							SET APD.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(APB.intEntityId,@intCompanyLocationId,APD.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
							FROM tblAPBillDetail APD 
							INNER JOIN tblAPBill APB
								ON APD.intBillId = APB.intBillId
							LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = APB.intEntityId
							INNER JOIN @detailCreated ON intBillDetailId = intId
							WHERE APD.intTaxGroupId IS NULL AND intInventoryReceiptChargeId IS NULL
							
							EXEC [uspAPUpdateVoucherDetailTax] @detailCreated
							--

							IF ISNULL(@ysnBillPosted,0) = 1
							BEGIN
								EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
							END

							DELETE FROM @receiptDetails

							-- DECLARE @dblBillQtyTotal NUMERIC(26,16)
							-- SELECT @dblBillQtyTotal = SUM(BD.dblQtyReceived)
							-- FROM tblCTPriceFixationDetailAPAR APAR
							-- INNER JOIN tblAPBillDetail BD ON APAR.intBillDetailId = BD.intBillDetailId
							-- WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId AND BD.intBillId = @intBillId
							-- GROUP BY BD.intInventoryReceiptItemId

							--INSERT INTO @receiptDetails
							--(
							--	[intInventoryReceiptItemId],
							--	[intInventoryReceiptChargeId],
							--	[intInventoryShipmentChargeId],
							--	[intSourceTransactionNoId],
							--	[strSourceTransactionNo],
							--	[intItemId],
							--	[intToBillUOMId],
							--	[dblToBillQty]
							--)
							--SELECT * FROM dbo.fnCTGenerateReceiptDetail(@intInventoryReceiptItemId, @intBillId, @intBillDetailId, @dblQtyToBill, 0)
							
							--EXEC uspICUpdateBillQty @updateDetails = @receiptDetails

							INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intBillId,intBillDetailId,intConcurrencyId)
							SELECT @intPriceFixationDetailId,@intBillId,@intBillDetailId,1
							
							--IF @ysnLoad = 1
							--BEGIN
							--	--Update the load applied and priced
							--	update tblCTPriceFixationDetail 
							--		set dblLoadApplied = ISNULL(dblLoadApplied, 0) + @dblInventoryItemLoadApplied  
							--	WHERE intPriceFixationDetailId = @intPriceFixationDetailId
							--END
							--UPDATE	tblCTPriceFixationDetail SET intBillId = @intBillId,intBillDetailId = @intBillDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
						END
						ELSE
						BEGIN

							IF @intTransactionId IS NOT NULL
							BEGIN
								DELETE	FROM @voucherDetailReceipt
								SET @intNewBillId = @intTransactionId

								INSERT	INTO @voucherDetailReceipt([intInventoryReceiptType], [intInventoryReceiptItemId], [dblQtyReceived], [dblCost])
								SELECT	2,@intInventoryReceiptItemId, @dblQtyToBill, @dblFinalPrice
								EXEC	uspAPCreateVoucherDetailReceipt @intNewBillId,@voucherDetailReceipt
							END
							ELSE
							BEGIN
								UPDATE
									tblICInventoryReceiptItem
								SET
									ysnAllowVoucher = 1
								WHERE
									intInventoryReceiptItemId = @intInventoryReceiptItemId
													
								EXEC uspICConvertReceiptToVoucher
									@intInventoryReceiptId
									,@intUserId
									, @intNewBillId OUTPUT
							END

							INSERT INTO @tblCreatedTransaction VALUES (@intNewBillId)
							
							IF (@intNewBillId IS NOT NULL AND @intNewBillId > 0)
							BEGIN
								IF EXISTS(SELECT TOP 1 1 FROM tblAPBill WHERE intBillId = @intNewBillId AND dtmDate <= @dtmFixationDate AND @intTransactionId IS NULL)
								BEGIN
									UPDATE	
										tblAPBill 
									SET		
										strVendorOrderNumber = @strVendorOrderNumber
										, dtmDate = @dtmFixationDate
										, dtmDueDate = @dtmFixationDate
										, dtmBillDate = @dtmFixationDate 
									WHERE 
										intBillId = @intNewBillId

									SELECT TOP 1 
										@intBillDetailId = intBillDetailId
									FROM 
										tblAPBillDetail 
									WHERE 
										intBillId = @intNewBillId 
										AND intInventoryReceiptChargeId IS NULL
									ORDER BY intBillDetailId DESC 

									update l set l.dtmTransactionDate = cast((convert(VARCHAR(10), @dtmFixationDate, 111) + ' ' + convert(varchar(20), getdate(), 114)) as datetime) from tblCTContractBalanceLog l where l.intTransactionReferenceDetailId = @intBillDetailId and l.strTransactionType = 'Purchase Basis Deliveries' and l.strAction = 'Created Voucher' and l.strTransactionReference = 'Voucher';
									update l set l.dtmTransactionDate = cast((convert(VARCHAR(10), @dtmFixationDate, 111) + ' ' + convert(varchar(20), getdate(), 114)) as datetime) from tblRKSummaryLog l where l.intTransactionRecordId = @intBillDetailId and l.strBucketType = 'Accounts Payables' and l.strAction = 'Created Voucher' and l.strTransactionType = 'Voucher';
								END
							
								DECLARE @total DECIMAL(18,6)
								SELECT TOP 1 
									@intBillDetailId = intBillDetailId
									, @total = dblQtyReceived 
								FROM 
									tblAPBillDetail 
								WHERE 
									intBillId = @intNewBillId 
									AND intInventoryReceiptChargeId IS NULL
								ORDER BY intBillDetailId DESC 

								UPDATE	
									tblAPBillDetail 
								SET 
									dblQtyReceived = @dblQtyToBill
									, dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId, intWeightUOMId, @dblQtyToBill) 
								WHERE 
									intBillDetailId = @intBillDetailId

								update l set l.dblQty = (@dblQtyToBill * -1) from tblCTContractBalanceLog l where l.intTransactionReferenceDetailId = @intBillDetailId and l.strTransactionType = 'Purchase Basis Deliveries' and l.strAction = 'Created Voucher' and l.strTransactionReference = 'Voucher';
								update l set l.dblOrigQty = @dblQtyToBill from tblRKSummaryLog l where l.intTransactionRecordId = @intBillDetailId and l.strBucketType = 'Accounts Payables' and l.strAction = 'Created Voucher' and l.strTransactionType = 'Voucher';

								IF @dblQtyToBill <> @total
								BEGIN
									DELETE FROM @receiptDetails
									INSERT INTO @receiptDetails
									(
										[intInventoryReceiptItemId],
										[intInventoryReceiptChargeId],
										[intInventoryShipmentChargeId],
										[intSourceTransactionNoId],
										[strSourceTransactionNo],
										[intItemId],
										[intToBillUOMId],
										[dblToBillQty]
									)
									SELECT * 
									FROM 
										dbo.fnCTGenerateReceiptDetail(
											@intInventoryReceiptItemId
											, @intNewBillId
											, @intBillDetailId
											, @dblQtyToBill
											, @total
									)
								
									EXEC uspICUpdateBillQty 
										@updateDetails = @receiptDetails
								END

								-- Add the 'DP/Basis' other charges into the voucher
								BEGIN 
									EXEC uspICAddProRatedReceiptChargesToVoucher
										@intInventoryReceiptItemId
										,@intNewBillId
										,@intBillDetailId
								END 

								IF (ISNULL(@intBillDetailId, 0) <> 0)
								BEGIN
									EXEC uspAPUpdateCost @intBillDetailId, @dblFinalPrice, 1
								END

								INSERT INTO tblCTPriceFixationDetailAPAR(
									intPriceFixationDetailId
									,intBillId
									,intBillDetailId
									,intConcurrencyId
								)
								SELECT 
									@intPriceFixationDetailId
									,@intNewBillId
									,@intBillDetailId
									,1

								--UPDATE	tblCTPriceFixationDetail SET intBillId = @intNewBillId,intBillDetailId = @intBillDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId

								SELECT	@intTicketId = intTicketId FROM tblSCTicket WHERE intInventoryReceiptId = @intInventoryReceiptId

								DELETE FROM @prePayId

								INSERT	INTO @prePayId([intId])
								SELECT	DISTINCT BD.intBillId
								FROM	tblAPBillDetail BD
								JOIN	tblAPBill		BL	ON BL.intBillId	=	BD.intBillId
								JOIN	tblSCTicket		TK  ON TK.intTicketId =  BD.intScaleTicketId
								WHERE	BD.intContractDetailId	=	@intContractDetailId 
								AND		BD.intScaleTicketId		=	@intTicketId 
								AND		BL.intTransactionType	IN (2, 13)
								AND		BL.ysnPosted			=	1 
								AND		BL.ysnPaid				=	0 

								IF EXISTS(SELECT * FROM	@prePayId)
								BEGIN
									EXEC uspAPApplyPrepaid @intNewBillId, @prePayId
								END

								-- CT-3983
								DELETE @detailCreated

								INSERT INTO @detailCreated
								SELECT @intBillDetailId

								UPDATE APD
								SET APD.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(APB.intEntityId,@intCompanyLocationId,APD.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
								FROM tblAPBillDetail APD 
								INNER JOIN tblAPBill APB
									ON APD.intBillId = APB.intBillId
								LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = APB.intEntityId
								INNER JOIN @detailCreated ON intBillDetailId = intId
								WHERE APD.intTaxGroupId IS NULL AND intInventoryReceiptChargeId IS NULL
							
								EXEC [uspAPUpdateVoucherDetailTax] @detailCreated
								--

								EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intNewBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT

								UPDATE	tblICInventoryReceiptItem SET ysnAllowVoucher = 0 WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId

								-- -- Reset create new counter for another voucher
								-- IF @ysnCreateNew = 1
								-- BEGIN
								-- 	SET @ysnCreateNew  = 0
								-- END

								IF @ysnLoad = 1
								BEGIN
									--Update the load applied and priced
									update tblCTPriceFixationDetail 
										set dblLoadApplied = ISNULL(dblLoadApplied, 0)  + @dblInventoryItemLoadApplied,
											dblLoadAppliedAndPriced = ISNULL(dblLoadAppliedAndPriced, 0) + @dblInventoryItemLoadApplied
									WHERE intPriceFixationDetailId = @intPriceFixationDetailId
								END						
							END
						END

						SELECT @intUniqueId = MIN(intUniqueId)  FROM @tblToProcess WHERE intUniqueId > @intUniqueId
					END	
					ELSE
					BEGIN
						IF(@ysnDoUpdateCost = 1)
						BEGIN
							IF EXISTS(SELECT top 1 1 FROM tblAPBillDetail a, tblAPBill b WHERE a.intInventoryReceiptItemId = @intInventoryReceiptItemId AND a.intInventoryReceiptChargeId IS	NULL and b.intBillId = a.intBillId and b.intTransactionType <> 13)
							BEGIN 
								SELECT	@intBillId = a.intBillId, @dblQtyReceived = a.dblQtyReceived, @dblVoucherPrice = a.dblCost FROM tblAPBillDetail a, tblAPBill b WHERE a.intInventoryReceiptItemId = @intInventoryReceiptItemId and b.intBillId = a.intBillId and b.intTransactionType <> 13
					    
								SELECT  @ysnBillPosted = ysnPosted, @ysnBillPaid = ysnPaid FROM tblAPBill WHERE intBillId = @intBillId
								
								SELECT	@intReceiptUniqueId = MIN(intReceiptUniqueId) FROM @tblReceipt WHERE intReceiptUniqueId > @intReceiptUniqueId

								IF @ysnBillPaid = 1 CONTINUE

								IF  @dblVoucherPrice <> @dblFinalPrice CONTINUE

								IF ISNULL(@ysnBillPosted,0) = 1
								BEGIN
									EXEC [dbo].[uspAPPostBill] @post = 0,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
								END
								SELECT	@intBillDetailId = a.intBillDetailId FROM tblAPBillDetail a, tblAPBill b WHERE a.intBillId = @intBillId AND a.intContractDetailId = @intContractDetailId AND a.intInventoryReceiptChargeId IS NULL and b.intBillId = a.intBillId and b.intTransactionType <> 13
					    
								--UPDATE	tblAPBillDetail SET  dblQtyOrdered = @dblQtyToBill, dblQtyReceived = @dblQtyToBill,dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(intUnitOfMeasureId, intWeightUOMId, @dblQtyToBill) WHERE intBillDetailId = @intBillDetailId

								IF (ISNULL(@intBillDetailId, 0) <> 0)
								BEGIN
									EXEC uspAPUpdateCost @intBillDetailId, @dblFinalPrice, 1
								END

								-- CT-3983
								DELETE FROM @detailCreated
							
								INSERT INTO @detailCreated
								SELECT @intBillDetailId

								UPDATE APD
								SET APD.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(APB.intEntityId,@intCompanyLocationId,APD.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
								FROM tblAPBillDetail APD 
								INNER JOIN tblAPBill APB
									ON APD.intBillId = APB.intBillId
								LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = APB.intEntityId
								INNER JOIN @detailCreated ON intBillDetailId = intId
								WHERE APD.intTaxGroupId IS NULL AND intInventoryReceiptChargeId IS NULL
							
								EXEC [uspAPUpdateVoucherDetailTax] @detailCreated
								--

								IF ISNULL(@ysnBillPosted,0) = 1
								BEGIN
									EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
								END
							END
						END
					END
					SELECT	@intInventoryReceiptItemId = MIN(intInventoryReceiptItemId)  FROM @tblReceipt WHERE intInventoryReceiptItemId > @intInventoryReceiptItemId
					SELECT	@intReceiptUniqueId = MIN(intReceiptUniqueId)  FROM @tblReceipt WHERE intReceiptUniqueId > @intReceiptUniqueId		
				END

				-- SELECT @intPriceFixationDetailAPARId = MIN(intPriceFixationDetailAPARId) FROM tblCTPriceFixationDetailAPAR WHERE intPriceFixationDetailId = @intPriceFixationDetailId

				-- WHILE ISNULL(@intPriceFixationDetailAPARId,0) > 0
				-- BEGIN

				-- 	SELECT	@intBillId = NULL, @intBillDetailId = NULL

				-- 	SELECT	@intBillId = intBillId, 
				-- 			@intBillDetailId = intBillDetailId 
				-- 	FROM	tblCTPriceFixationDetailAPAR 
				-- 	WHERE	intPriceFixationDetailAPARId = @intPriceFixationDetailAPARId

				-- 	SELECT  @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillDetailId = @intBillDetailId
					
				-- 	SELECT  @ysnBillPosted = ysnPosted, @strBillId = strBillId FROM tblAPBill WHERE intBillId = @intBillId
					
				-- 	SELECT  @intBillQtyUOMId = intUnitOfMeasureId,
				-- 			@dblTotalBillQty = dblQtyReceived,
				-- 			@dblTotalIVForPFQty   = dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intBillQtyUOMId,@dblPriceFixedQty),
				-- 			@dblVoucherPrice = dblCost
				-- 	FROM    tblAPBillDetail 
				-- 	WHERE   intBillDetailId = @intBillDetailId AND intInventoryReceiptChargeId IS NULL

				-- 	IF  @dblVoucherPrice	<>	@dblFinalPrice
				-- 	BEGIN
				-- 		IF @ysnBillPosted = 1
				-- 		BEGIN
				-- 			SELECT @strPostedAPAR = ISNULL(@strPostedAPAR + ',','') + @strBillId
				-- 		END

				-- 		EXEC	[dbo].[uspSMTransactionCheckIfRequiredApproval]
				-- 						@type					=	N'AccountsPayable.view.Voucher',
				-- 						@transactionEntityId	=	@intEntityId,
				-- 						@currentUserEntityId	=	@intUserId,
				-- 						@locationId				=	@intCompanyLocationId,
				-- 						@amount					=	@dblTotal,
				-- 						@requireApproval		=	@ysnRequireApproval OUTPUT

				-- 		IF  ISNULL(@ysnRequireApproval , 0) = 0
				-- 		BEGIN
				-- 				IF ISNULL(@ysnBillPosted,0) = 1
				-- 				BEGIN
				-- 					EXEC [dbo].[uspAPPostBill] @post = 0,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT, @batchIdUsed = @batchIdUsed OUTPUT
				-- 					IF ISNULL(@ysnSuccess, 0) = 0
				-- 					BEGIN
				-- 						SELECT @ErrMsg = strMessage FROM tblAPPostResult WHERE strBatchNumber = @batchIdUsed
				-- 						IF ISNULL(@ErrMsg, '') != ''
				-- 						BEGIN
				-- 							RAISERROR(@ErrMsg, 11, 1);
				-- 							RETURN;
				-- 						END
				-- 					END
				-- 				END

				-- 				--UPDATE tblAPBillDetail SET dblQtyOrdered = @dblTotalIVForPFQty, dblQtyReceived = @dblTotalIVForPFQty WHERE intBillDetailId = @intBillDetailId

				-- 				IF (ISNULL(@intBillDetailId, 0) <> 0)
				-- 				BEGIN
				-- 					EXEC uspAPUpdateCost @intBillDetailId, @dblFinalPrice, 1
				-- 				END

				-- 				IF ISNULL(@ysnBillPosted,0) = 1
				-- 				BEGIN
				-- 					EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
				-- 				END
				-- 		END
				-- 	END

				-- 	SELECT @intPriceFixationDetailAPARId = MIN(intPriceFixationDetailAPARId) FROM tblCTPriceFixationDetailAPAR WHERE intPriceFixationDetailId = @intPriceFixationDetailId AND intPriceFixationDetailAPARId > @intPriceFixationDetailAPARId
				-- END
			END

			/*

			--CT-4127 - Commented this block Creating Invoice from Contract Partial Pricing (@intContractTypeId = 2)

			IF @intContractTypeId = 2 
			BEGIN

				DELETE FROM @tblShipment

				IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixationTicket WHERE intPricingId = @intPriceFixationDetailId)
				BEGIN
					INSERT INTO @tblShipment
					SELECT  RI.intInventoryShipmentId,
							RI.intInventoryShipmentItemId,
							dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,ISNULL(RI.dblDestinationQuantity,RI.dblQuantity)) dblShipped,
							IR.strShipmentNumber,
							(
								SELECT  SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intItemUOMId,@intItemUOMId,dblQtyShipped)) 
								FROM	tblARInvoiceDetail ID 
								WHERE	intInventoryShipmentItemId = RI.intInventoryShipmentItemId AND intInventoryShipmentChargeId IS NULL
							) AS dblTotalIVForSHQty,
							ysnDestinationWeightsAndGrades,
							intLoadShipped,
							NULL
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
							dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,ISNULL(RI.dblDestinationQuantity,RI.dblQuantity)) dblShipped,
							IR.strShipmentNumber,
							(
								SELECT  SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intItemUOMId,@intItemUOMId,dblQtyShipped)) 
								FROM	tblARInvoiceDetail ID 
								WHERE	intInventoryShipmentItemId = RI.intInventoryShipmentItemId AND intInventoryShipmentChargeId IS NULL
							) AS dblTotalIVForSHQty,
							ysnDestinationWeightsAndGrades,
							intLoadShipped,
							ARD.intInvoiceDetailId
					FROM    tblICInventoryShipmentItem  RI
					JOIN    tblICInventoryShipment		IR  ON  IR.intInventoryShipmentId		=   RI.intInventoryShipmentId
															AND IR.intOrderType					=   1
					JOIN    tblCTContractDetail			CD  ON  CD.intContractDetailId			=   RI.intLineNo
					OUTER APPLY ( select top 1 intInvoiceDetailId 
									from tblARInvoiceDetail ARD 
										WHERE ARD.intContractDetailId = CD.intContractDetailId 
										and ARD.intInventoryShipmentItemId = RI.intInventoryShipmentItemId
										and ARD.intInventoryShipmentChargeId is null
									) ARD
						
					WHERE	RI.intLineNo	=   @intContractDetailId					
						--AND (@ysnLoad = 0 or RI.dblBillQty <> dblOpenReceive)
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
							@ysnDestinationWeightsAndGrades	=	ysnDestinationWeightsAndGrades,
							@dblInventoryShipmentItemLoadApplied = dblInventoryShipmentItemLoad,
							@intShipmentInvoiceDetailId = intInvoiceDetailId
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

					IF @ysnLoad = 1
					BEGIN
						IF @dblPriceLoadQty = @dblPriceFixationLoadApplied
						BEGIN
							SELECT	@intShipmentUniqueId = MIN(intShipmentUniqueId)  FROM @tblShipment WHERE intShipmentUniqueId > @intShipmentUniqueId
							CONTINUE
						END

						IF @intShipmentInvoiceDetailId is not null
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

					IF @dblTotalIVForSHQty = @dblShipped AND @dblTotalIVForPFQty >= 0
					BEGIN
						IF @dblTotalIVForPFQty = 0
							SELECT	@dblRemainingQty = CASE WHEN @dblRemainingQty = 0 THEN @dblPriceFxdQty ELSE @dblRemainingQty END - @dblShipped
						ELSE
							SELECT	@dblRemainingQty = @dblPriceFxdQty - @dblTotalIVForPFQty
						SELECT	@intShipmentUniqueId = MIN(intShipmentUniqueId)  FROM @tblShipment WHERE intShipmentUniqueId > @intShipmentUniqueId
						CONTINUE
					END

					IF @ysnLoad = 1
	                BEGIN
	                    INSERT    INTO @tblToProcess
	                    SELECT    @intInventoryShipmentId,@intInventoryShipmentItemId,@dblShipped,@intPriceFixationDetailId    
	                END 
	                ELSE
	                BEGIN
						IF @dblRemainingQty > 0
						BEGIN
							SELECT	@intPFDetailId = MAX(intPriceFixationDetailId) 
							FROM	tblCTPriceFixationDetail 
							WHERE	intPriceFixationId = @intPriceFixationId 
							AND		intPriceFixationDetailId < @intPriceFixationDetailId

							IF @dblRemainingQty <= @dblShipped
							BEGIN					
								IF @ysnLoad = 1
								BEGIN
									SET @dblRemainingQty = @dblShipped
								END	
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
									,@intContractDetailId	=	@intContractDetailId
									,@NewInvoiceId			=	@intNewInvoiceId	OUTPUT
					
							DELETE	AD
							FROM	tblARInvoiceDetail	AD 
							JOIN	tblCTContractDetail CD	ON AD.intContractDetailId = CD.intContractDetailId
							WHERE	AD.intInvoiceId		=	@intNewInvoiceId
							AND		AD.intInventoryShipmentChargeId IS NULL
							AND		CD.intPricingTypeId NOT IN (1,6)
							AND	NOT EXISTS(SELECT 1 FROM tblCTPriceFixation WHERE intContractDetailId = CD.intContractDetailId)
							AND NOT EXISTS(SELECT * FROM tblARInvoiceDetail WHERE  intContractDetailId = CD.intContractDetailId AND intInvoiceId <> @intNewInvoiceId)

							SELECT	@intInvoiceDetailId = intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId AND intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL

							IF (ISNULL(@intInvoiceDetailId,0) > 0)
							BEGIN
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
							END
							
							/*CT-2672
							EXEC	uspARPostInvoice
									@param				= @intNewInvoiceId
									,@post				= 1
									,@userId			= @intUserId
									,@raiseError		= 1
							*/

							IF @intNewInvoiceId IS NOT NULL
							BEGIN
								INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
								SELECT @intPFDetailId,@intNewInvoiceId,@intInvoiceDetailId,1
							END
						
							--UPDATE	tblCTPriceFixationDetail SET intInvoiceId = @intNewInvoiceId,intInvoiceDetailId = @intInvoiceDetailId WHERE intPriceFixationDetailId = @intPriceFixationDetailId
							IF @ysnLoad = 1
							BEGIN
								--Update the load applied and priced
								UPDATE tblCTPriceFixationDetail 
									SET dblLoadApplied = ISNULL(dblLoadApplied, 0)  + @dblInventoryShipmentItemLoadApplied,
										dblLoadAppliedAndPriced = ISNULL(dblLoadAppliedAndPriced, 0) + @dblInventoryShipmentItemLoadApplied
								WHERE intPriceFixationDetailId = @intPriceFixationDetailId
							END						

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

			*/


		   SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
	    END	
    END

	/*CT-4127 - Move here outside the Price Fixation Detail loop the creation of Invoice from Contract Partial Pricing*/
	IF (@intContractTypeId = 2)
	BEGIN

		if (@ysnLoad = 1)
		begin

		SET @pricing = CURSOR FOR
			select
				a.intContractHeaderId
				,a.intPriceFixationId
				,b.intPriceFixationDetailId
				,dblQuantity = b.dblLoadPriced
				,dblFinalPrice = dbo.fnCTConvertToSeqFXCurrency(a.intContractDetailId,c.intFinalCurrencyId,f.intItemUOMId,b.dblFinalPrice)
				,ContractPriceItemUOMId = intPricingUOMId
				,ContractDetailItemId = d.intItemId
			from
				tblCTPriceFixation a
				,tblCTPriceFixationDetail b
				,tblCTPriceContract c
				,tblCTContractDetail d
				,tblICCommodityUnitMeasure e
				,tblICItemUOM f
			where
				a.intPriceContractId = @intPriceContractId
				and b.intPriceFixationId = a.intPriceFixationId
				and c.intPriceContractId = a.intPriceContractId
				and d.intContractDetailId = a.intContractDetailId
				and e.intCommodityUnitMeasureId	=	b.intPricingUOMId
				and f.intItemId = d.intItemId
				and f.intUnitMeasureId = e.intUnitMeasureId
				and a.intContractDetailId = @intContractDetailId

		OPEN @pricing

		FETCH NEXT
		FROM
			@pricing
		INTO
			@intContractHeaderId
			,@intPriceFixationId
			,@intPriceFixationDetailId
			,@dblPriced
			,@dblFinalPrice
			,@ContractPriceUnitMeasureId
			,@ContractDetailItemId

		WHILE @@FETCH_STATUS = 0
		BEGIN			
			
			/*Loop Shipment*/
			set @intShipmentCount = 0;
			set @intCommulativeLoadPriced = @intCommulativeLoadPriced + @dblPriced;

			--@ysnDestinationWeightsGrades

			SET @shipment = CURSOR FOR
				SELECT
					intInventoryShipmentId = RI.intInventoryShipmentId,
					intInventoryShipmentItemId = RI.intInventoryShipmentItemId,
					--dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,ISNULL(RI.dblDestinationQuantity,RI.dblQuantity)),
					dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(
																	RI.intItemUOMId
																	,CD.intItemUOMId
																	,(
																			case
																			when @ysnDestinationWeightsGrades = convert(bit,1)
																			then ISNULL(RI.dblDestinationQuantity,0)
																			else ISNULL(RI.dblQuantity,0)
																			end
																	  )
																  ),
					intInvoiceDetailId = null,
					intItemUOMId = CD.intItemUOMId,
					intLoadShipped = convert(numeric(18,6),isnull(RI.intLoadShipped,0))
				FROM
					tblICInventoryShipmentItem RI
					JOIN tblICInventoryShipment IR ON IR.intInventoryShipmentId = RI.intInventoryShipmentId AND IR.intOrderType = 1
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = RI.intLineNo
					JOIN tblCTPriceFixationTicket FT ON FT.intInventoryShipmentId = RI.intInventoryShipmentId
				WHERE
					RI.intLineNo = @intContractDetailId

				union all

				SELECT
					intInventoryShipmentId = RI.intInventoryShipmentId,
					intInventoryShipmentItemId = RI.intInventoryShipmentItemId,
					--dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,ISNULL(RI.dblDestinationQuantity,RI.dblQuantity)),
					dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(
																	RI.intItemUOMId
																	,CD.intItemUOMId
																	,(
																			case
																			when @ysnDestinationWeightsGrades = convert(bit,1)
																			then ISNULL(RI.dblDestinationQuantity,0)
																			else ISNULL(RI.dblQuantity,0)
																			end
																	  )
																  ),
					intInvoiceDetailId = ARD.intInvoiceDetailId,
					intItemUOMId = CD.intItemUOMId,
					intLoadShipped = convert(numeric(18,6),isnull(RI.intLoadShipped,0))
				FROM tblICInventoryShipmentItem RI
				JOIN tblICInventoryShipment IR ON IR.intInventoryShipmentId = RI.intInventoryShipmentId AND IR.intOrderType = 1
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = RI.intLineNo
				OUTER APPLY (
								select top 1
									intInvoiceDetailId
								from
									tblARInvoiceDetail ARD
								WHERE
									ARD.intContractDetailId = CD.intContractDetailId
									and ARD.intInventoryShipmentItemId = RI.intInventoryShipmentItemId
									and ARD.intInventoryShipmentChargeId is null
								) ARD
							
				WHERE
					RI.intLineNo = @intContractDetailId

				OPEN @shipment

				FETCH NEXT
				FROM
					@shipment
				INTO
					@intInventoryShipmentId
					,@intInventoryShipmentItemId
					,@dblShipped
					,@intInvoiceDetailId
					,@intItemUOMId
					,@dblInventoryShipmentItemLoadApplied

				WHILE @@FETCH_STATUS = 0
				BEGIN

					if (@dblShipped = 0)
					begin
						UPDATE  tblICInventoryShipmentItem SET ysnAllowInvoice = 1 WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId;
						goto SkipShipmentLoop;
					end

					if (@intActiveShipmentId <> @intInventoryShipmentId)
					begin
						set @intShipmentCount = @intShipmentCount + 1;
					end

					set @intPricedLoad = (
							select count(*) from
							(
								select distinct intInvoiceId from tblCTPriceFixationDetailAPAR where intPriceFixationDetailId = @intPriceFixationDetailId
							) uniqueInvoice
						)

					select @intTotalLoadPriced = sum(df.dblLoadPriced) from tblCTPriceFixation f, tblCTPriceFixationDetail df where f.intContractDetailId = @intContractDetailId and df.intPriceFixationId = f.intPriceFixationId;

					if (@intShipmentCount <= @intPricedLoad)
					begin
						goto SkipShipmentLoop;
					end
					if (@intShipmentCount > @intTotalLoadPriced)
					begin
						goto SkipShipmentLoop;
					end

					if exists (select * from @PricedShipment where intInventoryShipmentId = @intInventoryShipmentId)
					begin
						goto SkipShipmentLoop;
					end


					if (@intInvoiceDetailId is not null)
					begin
						insert into @PricedShipment (intInventoryShipmentId) select intInventoryShipmentId = @intInventoryShipmentId;
						goto SkipShipmentLoop;
					end

					if (@intCommulativeLoadPriced < @intShipmentCount)
					begin
						goto SkipShipmentLoop;
					end


					/*Do Invoicing*/

					set @dblQuantityForInvoice = @dblShipped;

						--Shipment Item has no unposted Invoice, therefore create

						--Allow Shipment Item to create Invoice
						UPDATE  tblICInventoryShipmentItem SET ysnAllowInvoice = 1 WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId;
						--Create Invoice for Shipment Item

						print 'create new invoice';

						EXEC	uspCTCreateInvoiceFromShipment 
								@ShipmentId				=	@intInventoryShipmentId
								,@UserId				=	@intUserId
								,@intContractDetailId	=	@intContractDetailId
								,@NewInvoiceId			=	@intNewInvoiceId	OUTPUT

						--For some reason, I don't know why there's this code :)
						DELETE	AD
						FROM	tblARInvoiceDetail	AD 
						JOIN	tblCTContractDetail CD	ON AD.intContractDetailId = CD.intContractDetailId
						WHERE	AD.intInvoiceId		=	@intNewInvoiceId
						AND		AD.intInventoryShipmentChargeId IS NULL
						AND		CD.intPricingTypeId NOT IN (1,6)
						AND	NOT EXISTS(SELECT 1 FROM tblCTPriceFixation WHERE intContractDetailId = CD.intContractDetailId)
						AND NOT EXISTS(SELECT * FROM tblARInvoiceDetail WHERE  intContractDetailId = CD.intContractDetailId AND intInvoiceId <> @intNewInvoiceId)

						--Update the Invoice Detail with the correct quantity and price
						SELECT	@intInvoiceDetailId = intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId AND intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL

						IF (ISNULL(@intInvoiceDetailId,0) > 0)
						BEGIN
							EXEC	uspARUpdateInvoiceDetails	
									@intInvoiceDetailId	=	@intInvoiceDetailId,
									@intEntityId		=	@intUserId, 
									@dblQtyShipped		=	@dblQuantityForInvoice


							--select top 1 @ContractPriceItemUOMId = intItemUOMId from tblICItemUOM where intItemId = @ContractDetailItemId and intUnitMeasureId = @ContractPriceUnitMeasureId;
							select top 1 @ContractPriceItemUOMId = a.intItemUOMId
							from tblICItemUOM a 
							JOIN tblICCommodityUnitMeasure	PU	ON	PU.intCommodityUnitMeasureId	=	@ContractPriceUnitMeasureId
							JOIN tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=	PU.intUnitMeasureId
							where a.intItemId = @ContractDetailItemId and a.intUnitMeasureId = PM.intUnitMeasureId;

							set @dblFinalPrice = dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@ContractPriceItemUOMId,@dblFinalPrice);

							EXEC	uspARUpdateInvoicePrice 
									@InvoiceId			=	@intNewInvoiceId
									,@InvoiceDetailId	=	@intInvoiceDetailId
									,@Price				=	@dblFinalPrice
									,@ContractPrice		=	@dblFinalPrice
									,@UserId			=	@intUserId
						END

						--Create AR record to staging table tblCTPriceFixationDetailAPAR
						IF @intNewInvoiceId IS NOT NULL
						BEGIN
							INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
							SELECT @intPriceFixationDetailId,@intNewInvoiceId,@intInvoiceDetailId,1
						END

						insert into @PricedShipment (intInventoryShipmentId)
						select intInventoryShipmentId = @intInventoryShipmentId


						--Update the load applied and priced

						select @intApplied = count(distinct d.intInventoryShipmentId) from tblICInventoryShipmentItem c
						left join tblICInventoryShipment d on d.intInventoryShipmentId = c.intInventoryShipmentId
						where  c.intLineNo = @intContractDetailId

						select @intPreviousPricedLoad = isnull(sum(dblLoadPriced),0.00) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId and intPriceFixationDetailId < @intPriceFixationDetailId;

						if (@intApplied > @intPreviousPricedLoad)
						begin
							if ((@intApplied - @intPreviousPricedLoad) >= @dblPriced)
							begin
								set @dblLoadAppliedAndPriced = @dblPriced;
							end
							else
							begin
								set @dblLoadAppliedAndPriced = (@intApplied - @intPreviousPricedLoad);
							end
						end
						else
						begin
							set @dblLoadAppliedAndPriced = 0;
						end

						--Update the load applied and priced
						UPDATE tblCTPriceFixationDetail 
							SET dblLoadApplied = ISNULL(dblLoadApplied, 0)  + @dblInventoryShipmentItemLoadApplied,
								dblLoadAppliedAndPriced = @dblLoadAppliedAndPriced
						WHERE intPriceFixationDetailId = @intPriceFixationDetailId


						-- IF @ysnLoad = 1
						-- BEGIN
						-- 	UPDATE tblCTPriceFixationDetail 
						-- 		SET dblLoadApplied = ISNULL(dblLoadApplied, 0)  + @dblInventoryShipmentItemLoadApplied,
						-- 			dblLoadAppliedAndPriced = ISNULL(dblLoadAppliedAndPriced, 0) + @dblInventoryShipmentItemLoadApplied
						-- 	WHERE intPriceFixationDetailId = @intPriceFixationDetailId
						-- END

					/*
					--Check if Shipment Item has unposted Invoice
					if not exists (
									SELECT TOP 1 1
									FROM
										tblARInvoiceDetail AD
										JOIN tblARInvoice IV ON IV.intInvoiceId	= AD.intInvoiceId
									WHERE
										intInventoryShipmentItemId = -1--@intInventoryShipmentItemId
										AND ISNULL(IV.ysnPosted,0) = 0
								  )
					begin
						--Shipment Item has no unposted Invoice, therefore create

						--Allow Shipment Item to create Invoice
						UPDATE  tblICInventoryShipmentItem SET ysnAllowInvoice = 1 WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId;
						--Create Invoice for Shipment Item

						print 'create new invoice';

						EXEC	uspCTCreateInvoiceFromShipment 
								@ShipmentId				=	@intInventoryShipmentId
								,@UserId				=	@intUserId
								,@intContractDetailId	=	@intContractDetailId
								,@NewInvoiceId			=	@intNewInvoiceId	OUTPUT

						--For some reason, I don't know why there's this code :)
						DELETE	AD
						FROM	tblARInvoiceDetail	AD 
						JOIN	tblCTContractDetail CD	ON AD.intContractDetailId = CD.intContractDetailId
						WHERE	AD.intInvoiceId		=	@intNewInvoiceId
						AND		AD.intInventoryShipmentChargeId IS NULL
						AND		CD.intPricingTypeId NOT IN (1,6)
						AND	NOT EXISTS(SELECT 1 FROM tblCTPriceFixation WHERE intContractDetailId = CD.intContractDetailId)
						AND NOT EXISTS(SELECT * FROM tblARInvoiceDetail WHERE  intContractDetailId = CD.intContractDetailId AND intInvoiceId <> @intNewInvoiceId)

						--Update the Invoice Detail with the correct quantity and price
						SELECT	@intInvoiceDetailId = intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId AND intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL

						IF (ISNULL(@intInvoiceDetailId,0) > 0)
						BEGIN
							EXEC	uspARUpdateInvoiceDetails	
									@intInvoiceDetailId	=	@intInvoiceDetailId,
									@intEntityId		=	@intUserId, 
									@dblQtyShipped		=	@dblQuantityForInvoice

							EXEC	uspARUpdateInvoicePrice 
									@InvoiceId			=	@intNewInvoiceId
									,@InvoiceDetailId	=	@intInvoiceDetailId
									,@Price				=	@dblFinalPrice
									,@ContractPrice		=	@dblFinalPrice
									,@UserId			=	@intUserId
						END

						--Create AR record to staging table tblCTPriceFixationDetailAPAR
						IF @intNewInvoiceId IS NOT NULL
						BEGIN
							INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
							SELECT @intPriceFixationDetailId,@intNewInvoiceId,@intInvoiceDetailId,1
						END

						insert into @PricedShipment (intInventoryShipmentId)
						select intInventoryShipmentId = @intInventoryShipmentId


						--Update the load applied and priced
						IF @ysnLoad = 1
						BEGIN
							UPDATE tblCTPriceFixationDetail 
								SET dblLoadApplied = ISNULL(dblLoadApplied, 0)  + @dblInventoryShipmentItemLoadApplied,
									dblLoadAppliedAndPriced = ISNULL(dblLoadAppliedAndPriced, 0) + @dblInventoryShipmentItemLoadApplied
							WHERE intPriceFixationDetailId = @intPriceFixationDetailId
						END

					end
					
					else
					begin
						--Shipment Item has unposted Invoice, therefore add new details
						SELECT
							@intInvoiceId = AD.intInvoiceId 
						FROM
							tblARInvoiceDetail	AD 
							JOIN tblARInvoice IV ON IV.intInvoiceId	= AD.intInvoiceId
						WHERE
							intInventoryShipmentItemId = @intInventoryShipmentItemId
							AND ISNULL(IV.ysnPosted,0) = 0

						SELECT
							@intInvoiceDetailId = intInvoiceDetailId
						FROM
							tblARInvoiceDetail
						WHERE
							intInvoiceId = @intInvoiceId
							AND intContractDetailId = @intContractDetailId
							AND intInventoryShipmentChargeId IS NULL

						print 'add detail to existing invoice';

						EXEC uspCTCreateInvoiceDetail
							@intInvoiceDetailId
							,@intInventoryShipmentId
							,@dblQuantityForInvoice
							,@dblFinalPrice
							,@intUserId
							,@intInvoiceDetailId OUTPUT

						INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
						SELECT @intPriceFixationDetailId,@intInvoiceId,@intInvoiceDetailId,1
					end

					/*End of Do Invocing*/
					*/
					
					SkipShipmentLoop:

					FETCH NEXT
					FROM
						@shipment
					INTO
						@intInventoryShipmentId
						,@intInventoryShipmentItemId
						,@dblShipped
						,@intInvoiceDetailId
						,@intItemUOMId
						,@dblInventoryShipmentItemLoadApplied

				END

				CLOSE @shipment
				DEALLOCATE @shipment

			/*End Loop Shipment*/
										
			FETCH NEXT
			FROM
				@pricing
			INTO
				@intContractHeaderId
				,@intPriceFixationId
				,@intPriceFixationDetailId
				,@dblPriced
				,@dblFinalPrice
				,@ContractPriceUnitMeasureId
				,@ContractDetailItemId

		END

		CLOSE @pricing
		DEALLOCATE @pricing

		end
		else
		begin

			insert into @InvShp
			SELECT
				intInventoryShipmentId = RI.intInventoryShipmentId,
				intInventoryShipmentItemId = RI.intInventoryShipmentItemId,
				--dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,ISNULL(RI.dblDestinationQuantity,RI.dblQuantity)),
				dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(
																RI.intItemUOMId
																,CD.intItemUOMId
																,(
																		case
																		when @ysnDestinationWeightsGrades = convert(bit,1)
																		then ISNULL(RI.dblDestinationQuantity,0)
																		else ISNULL(RI.dblQuantity,0)
																		end
																  )
															  ),
				intInvoiceDetailId = null,
				intItemUOMId = CD.intItemUOMId,
				intLoadShipped = convert(numeric(18,6),isnull(RI.intLoadShipped,0)),
				dtmInvoiceDate = null
			FROM
				tblICInventoryShipmentItem RI
				JOIN tblICInventoryShipment IR ON IR.intInventoryShipmentId = RI.intInventoryShipmentId AND IR.intOrderType = 1
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = RI.intLineNo
				JOIN tblCTPriceFixationTicket FT ON FT.intInventoryShipmentId = RI.intInventoryShipmentId
			WHERE
				RI.intLineNo = @intContractDetailId

			union all

			SELECT
				intInventoryShipmentId = RI.intInventoryShipmentId,
				intInventoryShipmentItemId = RI.intInventoryShipmentItemId,
				--dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,ISNULL(RI.dblDestinationQuantity,RI.dblQuantity)),
				dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(
																RI.intItemUOMId
																,CD.intItemUOMId
																,(
																		case
																		when @ysnDestinationWeightsGrades = convert(bit,1)
																		then ISNULL(RI.dblDestinationQuantity,0)
																		else ISNULL(RI.dblQuantity,0)
																		end
																  )
															  ),
				intInvoiceDetailId = ARD.intInvoiceDetailId,
				intItemUOMId = CD.intItemUOMId,
				intLoadShipped = convert(numeric(18,6),isnull(RI.intLoadShipped,0)),
				dtmInvoiceDate = null
			FROM tblICInventoryShipmentItem RI
			JOIN tblICInventoryShipment IR ON IR.intInventoryShipmentId = RI.intInventoryShipmentId AND IR.intOrderType = 1
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = RI.intLineNo
			OUTER APPLY (
							select top 1
								intInvoiceDetailId
							from
								tblARInvoiceDetail ARD
							WHERE
								ARD.intContractDetailId = CD.intContractDetailId
								and ARD.intInventoryShipmentItemId = RI.intInventoryShipmentItemId
								and ARD.intInventoryShipmentChargeId is null
							) ARD
							
			WHERE
				RI.intLineNo = @intContractDetailId	

			if (@ysnDestinationWeightsGrades = convert(bit,1))
			begin
				insert into @InvShpFinal
				select * from
				(
				select
					si.intInventoryShipmentId
					,si.intInventoryShipmentItemId
					,si.dblShipped
					,si.intInvoiceDetailId
					,si.intItemUOMId
					,si.intLoadShipped
					,dtmInvoiceDate = isnull(i.dtmDate,getdate())
				from @InvShp si
				left join tblARInvoiceDetail di on di.intInventoryShipmentItemId = si.intInventoryShipmentItemId
				left join tblARInvoice i on i.intInvoiceId = di.intInvoiceId
				)t
				order by t.dtmInvoiceDate,t.intInventoryShipmentItemId
			end
			else
			begin
				insert into @InvShpFinal select * from @InvShp
			end



			SET @shipment = CURSOR FOR

				select 
					intInventoryShipmentId,
					intInventoryShipmentItemId,
					dblShipped,
					intInvoiceDetailId,
					intItemUOMId,
					intLoadShipped
				from @InvShpFinal

			/*---Loop Shipment---*/
			OPEN @shipment

			FETCH NEXT
			FROM
				@shipment
			INTO
				@intInventoryShipmentId
				,@intInventoryShipmentItemId
				,@dblShipped
				,@intInvoiceDetailId
				,@intItemUOMId
				,@dblInventoryShipmentItemLoadApplied

			WHILE @@FETCH_STATUS = 0
			BEGIN

				if (@dblShipped = 0)
				begin
					UPDATE  tblICInventoryShipmentItem SET ysnAllowInvoice = 1 WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId;
					goto SkipQtyShipmentLoop;
				end
				
				set @dblInvoicedShipped = (
											SELECT
												SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intItemUOMId,@intItemUOMId,dblQtyShipped)) 
											FROM
												tblARInvoiceDetail ID 
											WHERE
												intInventoryShipmentItemId = @intInventoryShipmentItemId
												AND intInventoryShipmentChargeId IS NULL
										  )

				set @dblShippedForInvoice = 0;
				set @dblInvoicedShipped = isnull(@dblInvoicedShipped,0.00);
				if (@dblShipped > @dblInvoicedShipped)
				begin
					set @dblShippedForInvoice = (@dblShipped - @dblInvoicedShipped);
				end

				if (@dblShippedForInvoice > 0)
				begin
					/*---Loop Pricing---*/
					SET @pricing = CURSOR FOR
						select
							a.intContractHeaderId
							,a.intPriceFixationId
							,b.intPriceFixationDetailId
							,b.dblQuantity
							,dblFinalPrice = dbo.fnCTConvertToSeqFXCurrency(a.intContractDetailId,c.intFinalCurrencyId,f.intItemUOMId,b.dblFinalPrice)
							,ContractPriceItemUOMId = b.intPricingUOMId
							,ContractDetailItemId = d.intItemId
						from
							tblCTPriceFixation a
							,tblCTPriceFixationDetail b
							,tblCTPriceContract c
							,tblCTContractDetail d
							,tblICCommodityUnitMeasure e
							,tblICItemUOM f
						where
							a.intPriceContractId = @intPriceContractId
							and b.intPriceFixationId = a.intPriceFixationId
							and c.intPriceContractId = a.intPriceContractId
							and d.intContractDetailId = a.intContractDetailId
							and e.intCommodityUnitMeasureId	=	b.intPricingUOMId
							and f.intItemId = d.intItemId
							and f.intUnitMeasureId = e.intUnitMeasureId
							and a.intContractDetailId = @intContractDetailId

					OPEN @pricing

					FETCH NEXT
					FROM
						@pricing
					INTO
						@intContractHeaderId
						,@intPriceFixationId
						,@intPriceFixationDetailId
						,@dblPriced
						,@dblFinalPrice
						,@ContractPriceUnitMeasureId
						,@ContractDetailItemId

					WHILE @@FETCH_STATUS = 0
					BEGIN
						
						--Skip Pricing loop if Shipped Quantity For Invoice is 0
						if (@dblShippedForInvoice = 0)
						begin
							goto SkipPricingLoop;
						end

						set @dblInvoicedPriced = (
													SELECT
														SUM(dbo.fnCTConvertQtyToTargetItemUOM(AD.intItemUOMId,@intItemUOMId,dblQtyShipped))
													FROM
														tblCTPriceFixationDetailAPAR AA
														JOIN tblARInvoiceDetail AD ON AD.intInvoiceDetailId	= AA.intInvoiceDetailId
													WHERE
														intPriceFixationDetailId = @intPriceFixationDetailId
												 )
						
						set @dblPricedForInvoice = 0;
						set @dblInvoicedPriced = isnull(@dblInvoicedPriced,0.00);

						/*
						-- if load based use the invoiced qty as priced qty
						if isnull(@ysnLoad,0) = 1
						begin
							set @dblPriced = case when @dblInvoicedPriced > 0 then @dblInvoicedPriced else @dblShippedForInvoice end
						end
						else
						begin
							--Check if Priced Detail has remaining quantity. If no, skip Pricing Loop
							if (@dblPriced = @dblInvoicedPriced)
							begin
								goto SkipPricingLoop;
							end

							if (@dblPriced > @dblInvoicedPriced)
							begin
								set @dblPricedForInvoice = (@dblPriced - @dblInvoicedPriced);
							end

							set @dblQuantityForInvoice = @dblPricedForInvoice;
							if (@dblPricedForInvoice > @dblShippedForInvoice)
							begin
								set @dblQuantityForInvoice = @dblShippedForInvoice;	
							end					
						end
						*/

						--Check if Priced Detail has remaining quantity. If no, skip Pricing Loop
						if (@dblPriced = @dblInvoicedPriced)
						begin
							goto SkipPricingLoop;
						end

						if (@dblPriced > @dblInvoicedPriced)
						begin
							set @dblPricedForInvoice = (@dblPriced - @dblInvoicedPriced);
						end

						set @dblQuantityForInvoice = @dblPricedForInvoice;
						if (@dblPricedForInvoice > @dblShippedForInvoice)
						begin
							set @dblQuantityForInvoice = @dblShippedForInvoice;	
						end

						print @dblQuantityForInvoice;

						--Check if Shipment Item has unposted Invoice
						if not exists (
										select
											top 1 1
										from
											tblICInventoryShipmentItem a
											,tblARInvoiceDetail b, tblARInvoice c
										where
											a.intInventoryShipmentId = @intInventoryShipmentId
											and b.intInventoryShipmentItemId = a.intInventoryShipmentItemId
											and c.intInvoiceId = b.intInvoiceId
											and isnull(c.ysnPosted,0) = 0
									  )
						begin
							--Shipment Item has no unposted Invoice, therefore create

							--Allow Shipment Item to create Invoice
							UPDATE  tblICInventoryShipmentItem SET ysnAllowInvoice = 1 WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId;
							--Create Invoice for Shipment Item

							print 'create new invoice';

							EXEC	uspCTCreateInvoiceFromShipment 
									@ShipmentId				=	@intInventoryShipmentId
									,@UserId				=	@intUserId
									,@intContractDetailId	=	@intContractDetailId
									,@NewInvoiceId			=	@intNewInvoiceId	OUTPUT

							--For some reason, I don't know why there's this code :)
							DELETE	AD
							FROM	tblARInvoiceDetail	AD 
							JOIN	tblCTContractDetail CD	ON AD.intContractDetailId = CD.intContractDetailId
							WHERE	AD.intInvoiceId		=	@intNewInvoiceId
							AND		AD.intInventoryShipmentChargeId IS NULL
							AND		CD.intPricingTypeId NOT IN (1,6)
							AND	NOT EXISTS(SELECT 1 FROM tblCTPriceFixation WHERE intContractDetailId = CD.intContractDetailId)
							AND NOT EXISTS(SELECT * FROM tblARInvoiceDetail WHERE  intContractDetailId = CD.intContractDetailId AND intInvoiceId <> @intNewInvoiceId)

							--Update the Invoice Detail with the correct quantity and price
							SELECT	@intInvoiceDetailId = intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId AND intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL

							IF (ISNULL(@intInvoiceDetailId,0) > 0)
							BEGIN
								EXEC	uspARUpdateInvoiceDetails	
										@intInvoiceDetailId	=	@intInvoiceDetailId,
										@intEntityId		=	@intUserId, 
										@dblQtyShipped		=	@dblQuantityForInvoice

							--select top 1 @ContractPriceItemUOMId = intItemUOMId from tblICItemUOM where intItemId = @ContractDetailItemId and intUnitMeasureId = @ContractPriceUnitMeasureId;
							select top 1 @ContractPriceItemUOMId = a.intItemUOMId
							from tblICItemUOM a 
							JOIN tblICCommodityUnitMeasure	PU	ON	PU.intCommodityUnitMeasureId	=	@ContractPriceUnitMeasureId
							JOIN tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=	PU.intUnitMeasureId
							where a.intItemId = @ContractDetailItemId and a.intUnitMeasureId = PM.intUnitMeasureId;

							set @dblFinalPrice = dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@ContractPriceItemUOMId,@dblFinalPrice);

								EXEC	uspARUpdateInvoicePrice 
										@InvoiceId			=	@intNewInvoiceId
										,@InvoiceDetailId	=	@intInvoiceDetailId
										,@Price				=	@dblFinalPrice
										,@ContractPrice		=	@dblFinalPrice
										,@UserId			=	@intUserId

								/*when there's multiple line item in IS, uspCTCreateInvoiceFromShipment will create all those line in invoice - need to remove the others and will create in the shipment item loop*/
								delete FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId AND intContractDetailId = @intContractDetailId AND intInvoiceDetailId <> @intInvoiceDetailId;
								exec uspARReComputeInvoiceAmounts @InvoiceId=@intNewInvoiceId,@AvailableDiscountOnly=0;
							END

							--Create AR record to staging table tblCTPriceFixationDetailAPAR
							IF @intNewInvoiceId IS NOT NULL
							BEGIN
								INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
								SELECT @intPriceFixationDetailId,@intNewInvoiceId,@intInvoiceDetailId,1
							END

							--Update the load applied and priced
							IF @ysnLoad = 1
							BEGIN
								UPDATE tblCTPriceFixationDetail 
									SET dblLoadApplied = ISNULL(dblLoadApplied, 0)  + @dblInventoryShipmentItemLoadApplied,
										dblLoadAppliedAndPriced = ISNULL(dblLoadAppliedAndPriced, 0) + @dblInventoryShipmentItemLoadApplied
								WHERE intPriceFixationDetailId = @intPriceFixationDetailId
							END

							set @dblPricedForInvoice = (@dblPricedForInvoice - @dblQuantityForInvoice);
							set @dblShippedForInvoice = (@dblShippedForInvoice - @dblQuantityForInvoice);

						end
						else
						begin
							--Shipment Item has unposted Invoice, therefore add new details
							select
								top 1 @intInvoiceId = c.intInvoiceId, @intInvoiceDetailId = b.intInvoiceDetailId
							from
								tblICInventoryShipmentItem a
								,tblARInvoiceDetail b, tblARInvoice c
							where
								a.intInventoryShipmentId = @intInventoryShipmentId
								and b.intInventoryShipmentItemId = a.intInventoryShipmentItemId
								and c.intInvoiceId = b.intInvoiceId
								and isnull(c.ysnPosted,0) = 0

							print 'add detail to existing invoice';

							UPDATE  tblICInventoryShipmentItem SET ysnAllowInvoice = 1 WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId;

							EXEC uspCTCreateInvoiceDetail
								@intInvoiceDetailId
								,@intInventoryShipmentId
								,@intInventoryShipmentItemId
								,@dblQuantityForInvoice
								,@dblFinalPrice
								,@intUserId
								,@intContractHeaderId
								,@intContractDetailId
								,@intInvoiceDetailId OUTPUT

							INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intInvoiceId,intInvoiceDetailId,intConcurrencyId)
							SELECT @intPriceFixationDetailId,@intInvoiceId,@intInvoiceDetailId,1
							
							--Deduct the quantity from @dblPricedForInvoice and @dblShippedForInvoice
							set @dblPricedForInvoice = (@dblPricedForInvoice - @dblQuantityForInvoice);
							set @dblShippedForInvoice = (@dblShippedForInvoice - @dblQuantityForInvoice);

						end

						SkipPricingLoop:
							
						FETCH NEXT
						FROM
							@pricing
						INTO
							@intContractHeaderId
							,@intPriceFixationId
							,@intPriceFixationDetailId
							,@dblPriced
							,@dblFinalPrice
							,@ContractPriceUnitMeasureId
							,@ContractDetailItemId

					END

					CLOSE @pricing
					DEALLOCATE @pricing
					/*---End Loop Pricing---*/
				end

				SkipQtyShipmentLoop:

				FETCH NEXT
				FROM
					@shipment
				INTO
					@intInventoryShipmentId
					,@intInventoryShipmentItemId
					,@dblShipped
					,@intInvoiceDetailId
					,@intItemUOMId
					,@dblInventoryShipmentItemLoadApplied

			END

			CLOSE @shipment
			DEALLOCATE @shipment
			/*---End Loop Shipment---*/

		end
	END


	IF ISNULL(@strPostedAPAR,'') <> ''
	BEGIN
		SET @ErrMsg = 'Cannot Update price as following posted Invoice/Vouchers are available. ' + @strPostedAPAR +'. Unpost those Invoice/Voucher to continue update the price.'
		RAISERROR(@ErrMsg,16,1)
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH