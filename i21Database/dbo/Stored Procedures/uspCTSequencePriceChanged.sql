CREATE PROCEDURE [dbo].[uspCTSequencePriceChanged]
		
	@intContractDetailId	INT,
	@intUserId				INT = NULL,
	@ScreenName				NVARCHAR(50)
	
AS

BEGIN TRY
	
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
			@intSeqPriceUOMId				INT,
			@intCommodityId					INT,
			@intStockUOMId					INT,
			@intItemId						INT

	SELECT	@dblCashPrice			=	dblCashPrice, 
			@intPricingTypeId		=	intPricingTypeId, 
			@intLastModifiedById	=	ISNULL(intLastModifiedById,intCreatedById),
			@intContractHeaderId	=	intContractHeaderId,
			@intCompanyLocationId	=	intCompanyLocationId,
			@intItemId				=	intItemId
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId		=	@intContractDetailId
	
	SELECT @dblCashPrice = dblSeqPrice,@intSeqPriceUOMId = intSeqPriceUOMId FROM dbo.fnCTGetAdditionalColumnForDetailView(@intContractDetailId) 
	SELECT @intCommodityId = intCommodityId FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId
	SELECT @intStockUOMId = intUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId AND ysnStockUOM = 1
	SELECT @intStockUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = @intItemId AND intUnitMeasureId = @intStockUOMId
			
	SELECT	@intEntityId		=	intEntityId,
			@intContractTypeId	=	intContractTypeId
	FROM	tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId

	SELECT  @intUserId = ISNULL(@intUserId,@intLastModifiedById)

	SELECT @ysnAllowChangePricing = ysnAllowChangePricing, @ysnEnablePriceContractApproval = ISNULL(ysnEnablePriceContractApproval,0) FROM tblCTCompanyPreference

	IF @ScreenName = 'Price Contract'
	BEGIN
		SELECT	@ysnOnceApproved = TR.ysnOnceApproved
		FROM	tblSMTransaction	TR
		JOIN	tblSMScreen			SC	ON	SC.intScreenId		=	TR.intScreenId
		WHERE	SC.strNamespace IN( 'ContractManagement.view.Contract',
									'ContractManagement.view.Amendments')
				AND TR.intRecordId = @intContractHeaderId
		
		SELECT	@ysnApprovalExist = dbo.fnCTContractApprovalExist(@intUserId,'ContractManagement.view.Amendments')

		IF ISNULL(@ysnOnceApproved,0) = 1 AND	((@ysnEnablePriceContractApproval = 1 AND ISNULL(@ysnApprovalExist,0) = 0) 
													OR @ysnEnablePriceContractApproval = 0
												)
		BEGIN
			EXEC [uspCTContractApproved] @intContractHeaderId,@intUserId,@intContractDetailId
		END
	END

	IF 	@intPricingTypeId NOT IN (1,6) OR @ysnAllowChangePricing = 1
		RETURN

	IF @intContractTypeId = 1 
	BEGIN
		IF OBJECT_ID('tempdb..#tblReceipt') IS NOT NULL  								
		DROP TABLE #tblReceipt								

		SELECT	DISTINCT ISNULL(IR.ysnPosted,0) ysnPosted, strReceiptNumber, RI.intInventoryReceiptItemId, RI.intInventoryReceiptId,BD.intBillId,BD.intBillDetailId,ISNULL(BL.ysnPosted,0) AS ysnBillPosted
		INTO	#tblReceipt
		FROM	tblICInventoryReceipt		IR
		JOIN	tblICInventoryReceiptItem	RI	ON	RI.intInventoryReceiptId		=	IR.intInventoryReceiptId
   LEFT	JOIN	tblAPBillDetail				BD	ON	BD.intInventoryReceiptItemId	=	RI.intInventoryReceiptItemId
   LEFT	JOIN	tblAPBill					BL	ON	BL.intBillId					=	BD.intBillId
		WHERE	RI.intLineNo = @intContractDetailId AND IR.strReceiptType = 'Purchase Contract'  AND BD.intInventoryReceiptChargeId IS NULL

		SELECT	@intInventoryReceiptId = MIN(intInventoryReceiptId) FROM #tblReceipt

		WHILE ISNULL(@intInventoryReceiptId,0) > 0
		BEGIN
			SELECT	@intBillId = NULL, @intBillDetailId = NULL

			SELECT	@intBillId = intBillId, @intBillDetailId = intBillDetailId,@strVendorOrderNumber = strReceiptNumber,@ysnBillPosted = ysnBillPosted FROM #tblReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId

			IF ISNULL(@intBillId,0) = 0
			BEGIN
				SELECT @strVendorOrderNumber = strTicketNumber, @intTicketId = intTicketId FROM tblSCTicket WHERE intInventoryReceiptId = @intInventoryReceiptId
				SELECT @strVendorOrderNumber = ISNULL(strPrefix,'') + @strVendorOrderNumber FROM tblSMStartingNumber WHERE strTransactionType = 'Ticket Management' AND strModule = 'Ticket Management'
				 
				EXEC [uspICProcessToBill] @intInventoryReceiptId,@intUserId, @intNewBillId OUTPUT

				UPDATE tblAPBill SET strVendorOrderNumber = @strVendorOrderNumber WHERE intBillId = @intNewBillId

				SELECT @intBillDetailId = intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intNewBillId AND intInventoryReceiptChargeId IS NULL

				EXEC uspAPUpdateCost @intBillDetailId,@dblCashPrice,1

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
				

				EXEC [dbo].[uspAPPostBill] 
					 @post = 1
					,@recap = 0
					,@isBatch = 0
					,@param = @intNewBillId
					,@userId = @intUserId
					,@success = @ysnSuccess OUTPUT
			END
			ELSE
			BEGIN
				SELECT @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = @intBillId
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

					EXEC uspAPUpdateCost @intBillDetailId,@dblCashPrice,1

					IF ISNULL(@ysnBillPosted,0) = 1
					BEGIN
						EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intBillId,@userId = @intUserId,@success = @ysnSuccess OUTPUT
					END
				END
			END

			SELECT	@intInventoryReceiptId = MIN(intInventoryReceiptId) FROM #tblReceipt WHERE intInventoryReceiptId > @intInventoryReceiptId
		END
		

	END
	IF @intContractTypeId = 2
	BEGIN

		IF OBJECT_ID('tempdb..#tblShipment') IS NOT NULL  								
			DROP TABLE #tblShipment

		SELECT	DISTINCT SH.ysnPosted,SH.strShipmentNumber,SI.intInventoryShipmentItemId,SH.intInventoryShipmentId,ISNULL(ID.intInvoiceId ,0) intInvoiceId,ID.intInvoiceDetailId,IV.ysnPosted ysnInvoicePosted
		INTO	#tblShipment
		FROM	tblICInventoryShipment		SH 
		JOIN	tblICInventoryShipmentItem	SI	ON	SI.intInventoryShipmentId		=	SH.intInventoryShipmentId 
   LEFT	JOIN	tblARInvoiceDetail			ID	ON	ID.intInventoryShipmentItemId	=	SI.intInventoryShipmentItemId
   LEFT	JOIN	tblARInvoice				IV	ON	IV.intInvoiceId					=	ID.intInvoiceId
		WHERE	SI.intLineNo	= @intContractDetailId 
		AND		SH.intOrderType = 1
		AND		SH.ysnPosted	= 1

		SELECT	@intInventoryShipmentId = MIN(intInventoryShipmentId) FROM #tblShipment

		WHILE ISNULL(@intInventoryShipmentId,0) > 0
		BEGIN

			SELECT	@intInvoiceId = intInvoiceId,@strShipmentNumber = strShipmentNumber, @intInvoiceDetailId = intInvoiceDetailId, @ysnInvoicePosted = ysnInvoicePosted 
			FROM	#tblShipment 
			WHERE	intInventoryShipmentId = @intInventoryShipmentId

			IF	ISNULL(@intInvoiceId,0)	=	0
			BEGIN
				EXEC	uspARCreateInvoiceFromShipment 
						 @ShipmentId		= @intInventoryShipmentId
						,@UserId			= @intUserId
						,@NewInvoiceId		= @intNewInvoiceId	OUTPUT
				
				SELECT	@intInvoiceDetailId = intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId AND intContractDetailId = @intContractDetailId AND intInventoryShipmentChargeId IS NULL

				EXEC	uspARUpdateInvoicePrice 
						 @InvoiceId			=	@intNewInvoiceId
						,@InvoiceDetailId	=	@intInvoiceDetailId
						,@Price				=	@dblCashPrice
						,@UserId			=	@intUserId

				EXEC	uspARPostInvoice
						 @param				= @intNewInvoiceId
						,@post				= 1
						,@userId			= @intUserId
						,@raiseError		= 1

			END
			ELSE
			BEGIN
				IF ISNULL(@ysnInvoicePosted,0) = 1
				BEGIN
					EXEC	uspARPostInvoice
							 @param				= @intNewInvoiceId
							,@post				= 0
							,@userId			= @intUserId
							,@raiseError		= 1
				END

				EXEC	uspARUpdateInvoicePrice 
						 @InvoiceId			=	@intInvoiceId
						,@InvoiceDetailId	=	@intInvoiceDetailId
						,@Price				=	@dblCashPrice
						,@UserId			=	@intUserId

				IF ISNULL(@ysnInvoicePosted,0) = 1
				BEGIN
					EXEC	uspARPostInvoice
							 @param				= @intNewInvoiceId
							,@post				= 1
							,@userId			= @intUserId
							,@raiseError		= 1
				END
			END
			SELECT	@intInventoryShipmentId = MIN(intInventoryShipmentId) FROM #tblShipment WHERE intInventoryShipmentId > @intInventoryShipmentId
		END
	END
	
	SELECT	@dblCashPrice = dbo.fnCTConvertQtyToTargetItemUOM(@intStockUOMId,@intSeqPriceUOMId,@dblCashPrice)
	EXEC uspCTCreateBillForBasisContract @intContractDetailId, @dblCashPrice

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO