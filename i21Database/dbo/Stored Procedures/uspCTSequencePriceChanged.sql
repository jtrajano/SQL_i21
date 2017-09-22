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
			@voucherDetailReceiptCharge		VoucherDetailReceiptCharge

	SELECT	@dblCashPrice			=	dblCashPrice, 
			@intPricingTypeId		=	intPricingTypeId, 
			@intLastModifiedById	=	ISNULL(intLastModifiedById,intCreatedById),
			@intContractHeaderId	=	intContractHeaderId
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId		=	@intContractDetailId
	
	SELECT @dblCashPrice = dblSeqPrice FROM dbo.fnCTGetAdditionalColumnForDetailView(@intContractDetailId) 
		
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

		SELECT	DISTINCT ISNULL(IR.ysnPosted,0) ysnPosted, strReceiptNumber, RI.intInventoryReceiptItemId, RI.intInventoryReceiptId,BD.intBillId
		INTO	#tblReceipt
		FROM	tblICInventoryReceipt		IR
		JOIN	tblICInventoryReceiptItem	RI	ON	RI.intInventoryReceiptId		=	IR.intInventoryReceiptId
   LEFT	JOIN	tblAPBillDetail				BD	ON	BD.intInventoryReceiptItemId	=	RI.intInventoryReceiptItemId
		WHERE	RI.intLineNo = @intContractDetailId AND IR.strReceiptType = 'Purchase Contract' --AND RI.dblUnitCost <> ISNULL(@dblCashPrice,0) 

		SELECT	@intInventoryReceiptId = MIN(intInventoryReceiptId) FROM #tblReceipt

		WHILE ISNULL(@intInventoryReceiptId,0) > 0
		BEGIN
			SELECT	@intBillId = intBillId FROM #tblReceipt WHERE intInventoryReceiptId = @intInventoryReceiptId
			IF ISNULL(@intBillId,0) = 0
			BEGIN
				INSERT	INTO @voucherDetailReceipt (intInventoryReceiptType,intInventoryReceiptItemId,dblCost)
				SELECT	intInventoryReceiptType		=	2,
						intInventoryReceiptItemId	=	intInventoryReceiptItemId,
						dblCost						=	@dblCashPrice
				FROM	#tblReceipt
				WHERE	intInventoryReceiptId		=	@intInventoryReceiptId

				INSERT INTO @voucherDetailReceiptCharge(intInventoryReceiptChargeId)
				SELECT intInventoryReceiptChargeId FROM tblICInventoryReceiptCharge WHERE intInventoryReceiptId = @intInventoryReceiptId

				EXEC [dbo].[uspAPCreateBillData] 
					 @userId						=	@intUserId
					,@vendorId						=	@intEntityId
					,@voucherDetailReceipt			=	@voucherDetailReceipt
					,@voucherDetailReceiptCharge	=	@voucherDetailReceiptCharge
					,@billId						=	@intNewBillId OUTPUT

				EXEC [dbo].[uspAPPostBill] 
					 @post = 1
					,@recap = 0
					,@isBatch = 0
					,@param = @intNewBillId
					,@userId = @intUserId
					,@success = @ysnSuccess OUTPUT
			END
			SELECT	@intInventoryReceiptId = MIN(intInventoryReceiptId) FROM #tblReceipt WHERE intInventoryReceiptId > @intInventoryReceiptId
		END
		

	END
	IF @intContractTypeId = 2
	BEGIN

		IF OBJECT_ID('tempdb..#tblShipment') IS NOT NULL  								
			DROP TABLE #tblShipment

		SELECT	DISTINCT SH.intInventoryShipmentId,ISNULL(ID.intInvoiceId ,0) intInvoiceId
		INTO	#tblShipment
		FROM	tblICInventoryShipment		SH 
		JOIN	tblICInventoryShipmentItem	SI	ON	SI.intInventoryShipmentId		=	SH.intInventoryShipmentId 
   LEFT	JOIN	tblARInvoiceDetail			ID	ON	ID.intInventoryShipmentItemId	=	SI.intInventoryShipmentItemId
		WHERE	SI.intLineNo	= @intContractDetailId 
		AND		SH.intOrderType = 1
		AND		SH.ysnPosted	= 1

		SELECT	@intInventoryShipmentId = MIN(intInventoryShipmentId) FROM #tblShipment

		WHILE ISNULL(@intInventoryShipmentId,0) > 0
		BEGIN

			SELECT	@intInvoiceId = intInvoiceId FROM #tblShipment WHERE intInventoryShipmentId = @intInventoryShipmentId

			IF	ISNULL(@intInvoiceId,0)	=	0
			BEGIN
				EXEC	uspARCreateInvoiceFromShipment 
						 @ShipmentId		= @intInventoryShipmentId
						,@UserId			= @intUserId
						,@NewInvoiceId		= @intNewInvoiceId	OUTPUT
			END

			SELECT	@intInventoryShipmentId = MIN(intInventoryShipmentId) FROM #tblShipment WHERE intInventoryShipmentId > @intInventoryShipmentId
		END
	END
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO