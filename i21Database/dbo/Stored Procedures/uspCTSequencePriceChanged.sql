CREATE PROCEDURE [dbo].[uspCTSequencePriceChanged]
		
	@intContractDetailId	INT,
	@intUserId				INT = NULL,
	@ScreenName				NVARCHAR(50),
	@ysnDelete				BIT = NULL
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg							NVARCHAR(MAX),
			@dblCashPrice					NUMERIC(18,6),
			@dblPartialCashPrice			NUMERIC(18,6),
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


			declare @AvailableQuantityForVoucher cursor;
			declare @dblCashPriceForVoucher numeric(18,6);
			declare @dblAvailableQuantity numeric(18,6);
			declare @dblProcessQuantity numeric(18,6);
			
	SELECT	@dblCashPrice			=	dblCashPrice, 
			@intPricingTypeId		=	intPricingTypeId, 
			@intLastModifiedById	=	ISNULL(intLastModifiedById,intCreatedById),
			@intContractHeaderId	=	intContractHeaderId,
			@intCompanyLocationId	=	intCompanyLocationId,
			@intItemId				=	intItemId
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId		=	@intContractDetailId
	
	SELECT @dblCashPrice = dblSeqPrice,@intSeqPriceUOMId = intSeqPriceUOMId,@dblPartialCashPrice = dblSeqPartialPrice FROM dbo.fnCTGetAdditionalColumnForDetailView(@intContractDetailId) 
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
	
	IF 	@intPricingTypeId NOT IN (1,2,6) OR @ysnAllowChangePricing = 1
		RETURN


	if (@intPricingTypeId = 2 or (@intPricingTypeId = 1 and (SELECT count(*) FROM tblAPBillDetail WHERE intContractDetailId = @intContractDetailId) > 0))
	BEGIN

		if (@ysnDelete = 1) return;

		set @dblProcessQuantity = 0;
		SET @AvailableQuantityForVoucher = CURSOR FOR

			select
				dblCashPrice
				,dblAvailableQuantity
			from
				vyuCTAvailableQuantityForVoucher where intContractDetailId = @intContractDetailId

		OPEN @AvailableQuantityForVoucher
		FETCH NEXT
		FROM
			@AvailableQuantityForVoucher
		INTO
			@dblCashPriceForVoucher
			,@dblAvailableQuantity

		WHILE @@FETCH_STATUS = 0
		BEGIN
			print @dblCashPriceForVoucher;
			print @dblAvailableQuantity
			
			set @dblAvailableQuantity = @dblAvailableQuantity - @dblProcessQuantity;

			EXEC uspCTCreateBillForBasisContract @intContractDetailId, @dblCashPriceForVoucher, @dblAvailableQuantity

			set @dblProcessQuantity = @dblProcessQuantity + @dblAvailableQuantity;
				
			FETCH NEXT
			FROM
				@AvailableQuantityForVoucher
			INTO
			@dblCashPriceForVoucher
			,@dblAvailableQuantity
		END

		CLOSE @AvailableQuantityForVoucher;
		DEALLOCATE @AvailableQuantityForVoucher;

	END
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT * FROM tblAPBillDetail WHERE intContractDetailId = @intContractDetailId AND intContractCostId IS NULL AND intInventoryReceiptChargeId IS NULL)
		BEGIN
			SELECT	@dblCashPrice = dbo.fnCTConvertQtyToTargetItemUOM(@intStockUOMId,@intSeqPriceUOMId,@dblCashPrice)
			EXEC uspCTCreateBillForBasisContract @intContractDetailId, @dblCashPrice, null
		END
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO