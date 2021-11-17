CREATE PROCEDURE [dbo].[uspCTCreateVoucherInvoiceForPartialPricing]
		
	@intContractDetailId	INT,
	@intUserId				INT = NULL,
	@ysnDoUpdateCost		BIT = 0,
	@intTransactionId		INT = NULL
	
AS


BEGIN TRY
	DECLARE @ErrMsg								NVARCHAR(MAX)
			,@intContractTypeId					INT
			,@intInventoryReceiptId				INT
			,@dblFinalPrice						NUMERIC(18,6)
			,@intNewBillId						INT
			,@intPricingTypeId					INT
			,@ysnAllowChangePricing				BIT
			,@intPriceFixationId				INT
			,@intContractHeaderId				INT
			,@ysnMultiPrice						BIT = 0
			,@intLastModifiedById				INT
			;

	SELECT	@intPricingTypeId			=	intPricingTypeId,
			@intLastModifiedById		=	ISNULL(intLastModifiedById,intCreatedById),
			@intContractHeaderId		=	intContractHeaderId
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId			=	@intContractDetailId
		
	SELECT
		@intContractTypeId	=	intContractTypeId,
		@ysnMultiPrice 		= 	ISNULL(ysnMultiplePriceFixation,0)
	FROM
		tblCTContractHeader with (nolock)
	WHERE
		intContractHeaderId = @intContractHeaderId

	SELECT  @intUserId = ISNULL(@intUserId,@intLastModifiedById)

	SELECT
		@ysnAllowChangePricing = ysnAllowChangePricing
	FROM
		tblCTCompanyPreference

	IF @ysnMultiPrice = 1
	BEGIN
		SELECT
			@intPriceFixationId = intPriceFixationId
		FROM
			tblCTPriceFixation
		WHERE
			intContractHeaderId = @intContractHeaderId
	END
	ELSE
	BEGIN
		SELECT
			@intPriceFixationId = intPriceFixationId
		FROM
			tblCTPriceFixation
		WHERE
			intContractDetailId = @intContractDetailId
	END

	IF	@ysnAllowChangePricing = 1 OR @intPriceFixationId IS NULL
		RETURN
		
	IF (@intContractTypeId = 1)
	BEGIN

		declare @ContractReceipts as table (
			intId int
			,intInventoryReceiptId int
			,dtmCreated datetime
			,strTransactionType nvarchar(5)
		)

		declare
			@intUTCOffsetInMinutes int
			,@intId int
			,@strTransactionType nvarchar(5);

		select @intUTCOffsetInMinutes = DATEDIFF(minute,getutcdate(),getdate());

		insert into @ContractReceipts
		select
			intId = convert(int,row_number() over (order by dtmCreated))
			,*
		from
		(
			select
				intInventoryReceiptId = ri.intInventoryReceiptId
				,ir.dtmCreated 
				,strTransactionType = 'IR'
			from
				tblICInventoryReceiptItem ri with (nolock)
				join tblICInventoryReceipt ir with (nolock) on ir.intInventoryReceiptId = ri.intInventoryReceiptId and ir.strReceiptType = 'Purchase Contract'
			where
				ri.intLineNo = @intContractDetailId

			union all

			SELECT
				intInventoryReceiptId = SC.intSettleStorageId
				,dtmCreated = DATEADD(minute,@intUTCOffsetInMinutes,SS.dtmCreated)   
				,strTransactionType = 'STR'
			FROM
				tblGRSettleContract SC with (nolock)
				JOIN tblGRSettleStorage SS with (nolock) ON SS.intSettleStorageId = SC.intSettleStorageId
			WHERE
				SC.intContractDetailId = @intContractDetailId
				AND SS.intParentSettleStorageId IS NOT NULL
		) tbl order by dtmCreated

		if exists (select top 1 1 from @ContractReceipts)
		begin
			set @intId = 0
			select @intId = min(intId) from @ContractReceipts where intId > @intId;

			while (@intId is not null and @intId > 0)
			begin

				select @intInventoryReceiptId = intInventoryReceiptId, @strTransactionType = strTransactionType from @ContractReceipts where intId = @intId;

				if (@strTransactionType = 'STR')
				begin
					declare @dblAvailableQuantity numeric(18,6);  
			        select top 1 @dblAvailableQuantity = dblAvailableQuantity, @dblFinalPrice = dblCashPrice from vyuCTAvailableQuantityForVoucher with (nolock) where intContractDetailId = @intContractDetailId;  
			  		EXEC [dbo].[uspGRPostSettleStorage] @intInventoryReceiptId,1, 1,@dblFinalPrice, @dblAvailableQuantity; 

				end
				else
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
				end
				select @intId = min(intId) from @ContractReceipts where intId > @intId;
			end
		end
	END
	ELSE IF (@intContractTypeId = 2)
	BEGIN

		exec uspCTCreateInvoice
			@intContractDetailId = @intContractDetailId
			,@intUserId = @intUserId

	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH