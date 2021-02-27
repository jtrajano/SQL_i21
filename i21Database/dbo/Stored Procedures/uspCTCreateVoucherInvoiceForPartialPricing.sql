﻿CREATE PROCEDURE [dbo].[uspCTCreateVoucherInvoiceForPartialPricing]
		
	@intContractDetailId	INT,
	@intUserId				INT = NULL,
	@ysnDoUpdateCost		BIT = 0,
	@intReceiptId           INT = NULL
	
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
			@dblPriceLoadQty				NUMERIC(18, 6),
			@dblPriceFixationLoadApplied	NUMERIC(18, 6),
			@dblInventoryItemLoadApplied	NUMERIC(18, 6),
			@dblInventoryShipmentItemLoadApplied	NUMERIC(18, 6),
			@intShipmentInvoiceDetailId		INT,
			@dtmFixationDate				DATE,
			@allowAddDetail					BIT,
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
		
	SELECT	@intEntityId		=	intEntityId,
			@intContractTypeId	=	intContractTypeId,
			@ysnLoad			=	ysnLoad
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
  
	--CT-5059  
	if (@intContractTypeId = 1)  
	begin  
  
		declare @ContractReceipts as table (  
			intInventoryReceiptId int  
		)  
  
		insert into @ContractReceipts  
		select  
			intInventoryReceiptId = ri.intInventoryReceiptId  
		from  
			tblICInventoryReceiptItem ri  
			join tblICInventoryReceipt ir on ir.intInventoryReceiptId = ri.intInventoryReceiptId and ir.strReceiptType = 'Purchase Contract'  
		where  
			ri.intLineNo = @intContractDetailId
			and ri.intInventoryReceiptId = (case when isnull(@intReceiptId,0) = 0 then ri.intInventoryReceiptId else @intReceiptId end)
		order by ir.intInventoryReceiptId  
  
  
  
		if exists (select top 1 1 from @ContractReceipts)  
		begin  
			set @intInventoryReceiptId = 0  
			select @intInventoryReceiptId = min(intInventoryReceiptId) from @ContractReceipts where intInventoryReceiptId > @intInventoryReceiptId;  
  
			while (@intInventoryReceiptId is not null and @intInventoryReceiptId > 0)  
			begin  
  
				update tblICInventoryReceiptItem set ysnAllowVoucher = 1 where intInventoryReceiptId = @intInventoryReceiptId and intLineNo = @intContractDetailId;  
				exec uspICConvertReceiptToVoucher  
				@intInventoryReceiptId  
				,@intUserId  
				,@intNewBillId OUTPUT  
  
				if (@intPricingTypeId = 2)  
				begin  
					update tblICInventoryReceiptItem set ysnAllowVoucher = 0 where intInventoryReceiptId = @intInventoryReceiptId and intLineNo = @intContractDetailId;  
				end  
  
				select @intInventoryReceiptId = min(intInventoryReceiptId) from @ContractReceipts where intInventoryReceiptId > @intInventoryReceiptId;  
			end  
		end  
  
	end  
  
 --End of CT-5059 


	/*


	if (@intContractTypeId = 1)
	BEGIN

	    SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId

		WHILE ISNULL(@intPriceFixationDetailId, 0)  > 0 
		BEGIN
			
			SELECT	@dblPriceFixedQty	=	FD.dblQuantity,
					@dblPriceFxdQty		=	FD.dblQuantity, 
					@intBillId			=	FD.intBillId,
					@intBillDetailId	=	FD.intBillDetailId, 
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
								FROM	tblAPBillDetail ID, tblAPBill B
								WHERE	intInventoryReceiptItemId = RI.intInventoryReceiptItemId AND intInventoryReceiptChargeId IS NULL and B.intBillId = ID.intBillId and B.intTransactionType <> 13
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
							dbo.fnCTConvertQtyToTargetItemUOM(RI.intUnitMeasureId,CD.intItemUOMId,RI.dblReceived) dblReceived,
							IR.strReceiptNumber,
							(
								SELECT  SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intUnitOfMeasureId,@intItemUOMId,dblQtyReceived)) 
								FROM	tblAPBillDetail ID, tblAPBill B
								WHERE	ID.intInventoryReceiptItemId = RI.intInventoryReceiptItemId AND ID.intInventoryReceiptChargeId IS NULL and B.intBillId = ID.intBillId and B.intTransactionType <> 13
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

					SELECT	@dblTotalIVForPFQty = ISNULL(@dblTotalIVForPFQty,0)

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

								IF (@dblReceived - @dblTotalIVForSHQty) < @dblRemainingQty
								BEGIN
									SET @dblRemainingQty = (@dblReceived - @dblTotalIVForSHQty)
								END
								
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

						-- Check IF need to create new voucher
						IF @ysnPartialPriced = 1
						BEGIN
							IF EXISTS (SELECT TOP 1 1 FROM tblAPBill WHERE ysnPosted = 1 AND intBillId = (SELECT TOP 1 a.intBillId FROM tblAPBillDetail a, tblAPBill b WHERE a.intInventoryReceiptItemId = @intInventoryReceiptItemId and b.intBillId = a.intBillId and b.intTransactionType <> 13) AND @ysnCreateNew = 0)
							BEGIN
								SET @ysnCreateNew = 1
							END
							ELSE
							BEGIN
								SET @ysnCreateNew = 0
							END
						END

						IF EXISTS(SELECT top 1 1 FROM tblAPBillDetail a, tblAPBill b WHERE a.intInventoryReceiptItemId = @intInventoryReceiptItemId AND a.intInventoryReceiptChargeId IS	NULL and b.intBillId = a.intBillId and b.intTransactionType <> 13 AND @ysnCreateNew = 0)
						BEGIN
							SELECT	@intBillId = a.intBillId, @dblQtyReceived = a.dblQtyReceived FROM tblAPBillDetail a, tblAPBill b WHERE a.intInventoryReceiptItemId = @intInventoryReceiptItemId and b.intBillId = a.intBillId and b.intTransactionType <> 13

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
					    
							-- CT-3983
							DELETE @detailCreated
							
							INSERT INTO @detailCreated
							SELECT @intBillDetailId

							UPDATE APD
							SET APD.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(APB.intEntityId,intCompanyLocationId,APD.intItemId,EM.intEntityLocationId, CASE WHEN ISNULL(FT.strFobPoint,'') = 'Destination' THEN CD.intFreightTermId ELSE EM.intFreightTermId END)
							FROM tblAPBillDetail APD 
							INNER JOIN tblAPBill APB
								ON APD.intBillId = APB.intBillId
							LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = APB.intEntityId
							INNER JOIN @detailCreated ON intBillDetailId = intId
							INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = APD.intContractDetailId
							LEFT JOIN tblSMFreightTerms FT ON CD.intFreightTermId = FT.intFreightTermId
							WHERE APD.intTaxGroupId IS NULL AND intInventoryReceiptChargeId IS NULL
							
							EXEC [uspAPUpdateVoucherDetailTax] @detailCreated

							IF (ISNULL(@intBillDetailId, 0) <> 0)
							BEGIN
								EXEC uspAPUpdateCost @intBillDetailId, @dblFinalPrice, 1
							END

							IF ISNULL(@ysnBillPosted,0) = 1
							BEGIN
								EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
							END

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
							SELECT * FROM dbo.fnCTGenerateReceiptDetail(@intInventoryReceiptItemId, @intBillId, @intBillDetailId, @dblQtyToBill, 0)

							EXEC uspICUpdateBillQty @updateDetails = @receiptDetails

							INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intBillId,intBillDetailId,intConcurrencyId)
							SELECT @intPriceFixationDetailId,@intBillId,@intBillDetailId,1
							
						END
						ELSE
						BEGIN
							UPDATE	tblICInventoryReceiptItem SET ysnAllowVoucher = 1 WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
													
							EXEC	uspICConvertReceiptToVoucher @intInventoryReceiptId,@intUserId, @intNewBillId OUTPUT
							
							UPDATE	tblAPBill SET strVendorOrderNumber = @strVendorOrderNumber, dtmDate = @dtmFixationDate, dtmDueDate = @dtmFixationDate, dtmBillDate = @dtmFixationDate WHERE intBillId = @intNewBillId
							
							DECLARE @total DECIMAL(18,6)
							SELECT	@intBillDetailId = a.intBillDetailId, @total = a.dblQtyReceived FROM tblAPBillDetail a, tblAPBill b WHERE a.intBillId = @intNewBillId AND a.intInventoryReceiptChargeId IS NULL and b.intBillId = a.intBillId and b.intTransactionType <> 13

							UPDATE	tblAPBillDetail SET dblQtyReceived = @dblQtyToBill, dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId, intWeightUOMId, @dblQtyToBill) WHERE intBillDetailId = @intBillDetailId

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
								SELECT * FROM dbo.fnCTGenerateReceiptDetail(@intInventoryReceiptItemId, @intNewBillId, @intBillDetailId, @dblQtyToBill, @total)
								
								EXEC uspICUpdateBillQty @updateDetails = @receiptDetails
							END

							INSERT INTO tblCTPriceFixationDetailAPAR(intPriceFixationDetailId,intBillId,intBillDetailId,intConcurrencyId)
							SELECT @intPriceFixationDetailId,@intNewBillId,@intBillDetailId,1

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
							SET APD.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(APB.intEntityId,intCompanyLocationId,APD.intItemId,EM.intEntityLocationId, CASE WHEN ISNULL(FT.strFobPoint,'') = 'Destination' THEN CD.intFreightTermId ELSE EM.intFreightTermId END)
							FROM tblAPBillDetail APD 
							INNER JOIN tblAPBill APB
								ON APD.intBillId = APB.intBillId
							LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = APB.intEntityId
							INNER JOIN @detailCreated ON intBillDetailId = intId
							INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = APD.intContractDetailId
							LEFT JOIN tblSMFreightTerms FT ON CD.intFreightTermId = FT.intFreightTermId
							WHERE APD.intTaxGroupId IS NULL AND intInventoryReceiptChargeId IS NULL
							
							EXEC [uspAPUpdateVoucherDetailTax] @detailCreated

							IF (ISNULL(@intBillDetailId, 0) <> 0)
							BEGIN
								EXEC uspAPUpdateCost @intBillDetailId, @dblFinalPrice, 1
							END
							
							EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intNewBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT

							UPDATE	tblICInventoryReceiptItem SET ysnAllowVoucher = 0 WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId

							IF @ysnLoad = 1
							BEGIN
								update tblCTPriceFixationDetail 
									set dblLoadApplied = ISNULL(dblLoadApplied, 0)  + @dblInventoryItemLoadApplied,
										dblLoadAppliedAndPriced = ISNULL(dblLoadAppliedAndPriced, 0) + @dblInventoryItemLoadApplied
								WHERE intPriceFixationDetailId = @intPriceFixationDetailId
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

								-- CT-3983
								DELETE FROM @detailCreated
							
								INSERT INTO @detailCreated
								SELECT @intBillDetailId

								UPDATE APD
								SET APD.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(APB.intEntityId,intCompanyLocationId,APD.intItemId,EM.intEntityLocationId, CASE WHEN ISNULL(FT.strFobPoint,'') = 'Destination' THEN CD.intFreightTermId ELSE EM.intFreightTermId END)
								FROM tblAPBillDetail APD 
								INNER JOIN tblAPBill APB
									ON APD.intBillId = APB.intBillId
								LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = APB.intEntityId
								INNER JOIN @detailCreated ON intBillDetailId = intId
								INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = APD.intContractDetailId
								LEFT JOIN tblSMFreightTerms FT ON CD.intFreightTermId = FT.intFreightTermId
								WHERE APD.intTaxGroupId IS NULL AND intInventoryReceiptChargeId IS NULL
							
								EXEC [uspAPUpdateVoucherDetailTax] @detailCreated
								--

								IF (ISNULL(@intBillDetailId, 0) <> 0)
								BEGIN
									EXEC uspAPUpdateCost @intBillDetailId, @dblFinalPrice, 1
								END

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

								IF (ISNULL(@intBillDetailId, 0) <> 0)
								BEGIN
									EXEC uspAPUpdateCost @intBillDetailId, @dblFinalPrice, 1
								END

								IF ISNULL(@ysnBillPosted,0) = 1
								BEGIN
									EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
								END
						END
					END

					SELECT @intPriceFixationDetailAPARId = MIN(intPriceFixationDetailAPARId) FROM tblCTPriceFixationDetailAPAR WHERE intPriceFixationDetailId = @intPriceFixationDetailId AND intPriceFixationDetailAPARId > @intPriceFixationDetailAPARId
				END
			END

		   SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
	    END

	END

	*/

	/*CT-4127 - Move here outside the Price Fixation Detail loop the creation of Invoice from Contract Partial Pricing*/
	IF (@intContractTypeId = 2)
	BEGIN

		SET @shipment = CURSOR FOR
			SELECT
				intInventoryShipmentId = RI.intInventoryShipmentId,
				intInventoryShipmentItemId = RI.intInventoryShipmentItemId,
				dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,ISNULL(RI.dblDestinationQuantity,RI.dblQuantity)),
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
				dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(RI.intItemUOMId,CD.intItemUOMId,ISNULL(RI.dblDestinationQuantity,RI.dblQuantity)),
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
									SELECT TOP 1 1
									FROM
										tblARInvoiceDetail AD
										JOIN tblARInvoice IV ON IV.intInvoiceId	= AD.intInvoiceId
									WHERE
										intInventoryShipmentItemId = @intInventoryShipmentItemId
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

				END

				CLOSE @pricing
				DEALLOCATE @pricing
				/*---End Loop Pricing---*/
			end
			
						
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

GO