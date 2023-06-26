CREATE PROCEDURE [dbo].[uspCTCreateVoucherInvoiceForPartialPricing]
		
	@intContractDetailId	INT,
	@intUserId				INT = NULL,
	@ysnDoUpdateCost		BIT = 0,
	@intTransactionId		INT = NULL
	
AS


BEGIN TRY
	DECLARE @ErrMsg								NVARCHAR(MAX)
			,@dblCashPrice						NUMERIC(18,6)
			,@ysnPosted							BIT
			,@strReceiptNumber					NVARCHAR(50)
			,@intLastModifiedById				INT
			,@intInventoryReceiptId				INT
			,@intSourceTicketId					INT
			,@intPricingTypeId					INT
			,@intContractHeaderId				INT
			,@ysnOnceApproved					BIT
			,@ysnApprovalExist					BIT
			,@ysnAllowChangePricing				BIT
			,@ysnEnablePriceContractApproval	BIT
			,@intEntityId						INT
			,@intContractTypeId					INT
			,@intInvoiceId						INT
			,@intInventoryShipmentId			INT
			,@intNewInvoiceId					INT
			,@intBillId							INT
			,@intNewBillId						INT
			,@ysnSuccess						BIT
			,@voucherDetailReceipt				VoucherDetailReceipt
			,@voucherDetailReceiptCharge		VoucherDetailReceiptCharge
			,@InvoiceEntries					InvoiceIntegrationStagingTable
			,@LineItemTaxEntries				LineItemTaxDetailStagingTable
			,@ErrorMessage						NVARCHAR(250)
			,@CreatedIvoices					NVARCHAR(MAX)
			,@UpdatedIvoices					NVARCHAR(MAX)
			,@strShipmentNumber					NVARCHAR(50)
			,@intBillDetailId					INT
			,@strVendorOrderNumber				NVARCHAR(50)
			,@ysnBillPosted						BIT
			,@ysnBillPaid						BIT
			,@intCompanyLocationId				INT
			,@dblTotal							NUMERIC(18,6)
			,@ysnRequireApproval				BIT
			,@prePayId							Id
			,@intTicketId						INT
			,@intInvoiceDetailId				INT
			,@ysnInvoicePosted					BIT
			,@intPriceFixationDetailId			INT
			,@intPriceFixationId				INT
			,@dblPriceFixedQty					NUMERIC(18,6)
			,@dblTotalBillQty					NUMERIC(18,6)
			,@dblReceived						NUMERIC(18,6)
			,@dblQtyToBill						NUMERIC(18,6)
			,@dblTicketQty						NUMERIC(18,6)
			,@intUniqueId						INT
			,@dblFinalPrice						NUMERIC(18,6)
			,@intBillQtyUOMId					INT
			,@intItemUOMId						INT
			,@intInventoryReceiptItemId			INT  
			,@dblTotalInvoiceQty 				NUMERIC(18,6)  
			,@intInventoryShipmentItemId		INT  
			,@dblShipped						NUMERIC(18,6)  
			,@dblQtyToInvoice					NUMERIC(18,6)
			,@intInvoiceQtyUOMId				INT
			,@dblInvoicePrice					NUMERIC(18,6)
			,@dblVoucherPrice					NUMERIC(18,6)
			,@dblTotalIVForPFQty				NUMERIC(18,6)
			,@batchIdUsed						NVARCHAR(MAX)
			,@dblQtyShipped						NUMERIC(18,6)
			,@dblQtyReceived					NUMERIC(18,6)
			,@intPriceFixationDetailAPARId		INT
			,@dblPriceFxdQty					NUMERIC(18,6)
			,@dblRemainingQty					NUMERIC(18,6)
			,@dblTotalIVForSHQty				NUMERIC(18,6)
			,@intPFDetailId						INT
			,@ysnDestinationWeightsAndGrades	BIT
			,@strInvoiceNumber					NVARCHAR(100)
			,@strBillId							NVARCHAR(100)
			,@strPostedAPAR						NVARCHAR(MAX)
			,@intReceiptUniqueId				INT  
			,@intShipmentUniqueId				INT
			,@ysnTicketBased					BIT = 0
			,@ysnPartialPriced					BIT = 0
			,@ysnCreateNew						BIT = 0
			,@receiptDetails					InventoryUpdateBillQty
			,@ysnLoad							BIT
			,@allowAddDetail					BIT
			,@dblPriceLoadQty					NUMERIC(18, 6)
			,@dblPriceFixationLoadApplied		NUMERIC(18, 6)
			,@dblInventoryItemLoadApplied		NUMERIC(18, 6)
			,@dblInventoryShipmentItemLoadApplied	NUMERIC(18, 6)
			,@intShipmentInvoiceDetailId		INT
			,@dtmFixationDate					DATE
			,@detailCreated						Id
			,@intPriceContractId				int
			,@shipment							cursor
			,@pricing							cursor
			,@dblPriced							numeric(18,6)
			,@dblInvoicedShipped				numeric(18,6)
			,@dblInvoicedShippedReturned		numeric(18,6)
			,@dblShippedForInvoice				numeric(18,6)
			,@dblInvoicedPriced					numeric(18,6)
			,@dblPricedForInvoice				numeric(18,6)
			,@dblQuantityForInvoice				numeric(18,6)
			,@intShipmentCount					int = 0
			,@intActiveShipmentId				int = 0
			,@intPricedLoad						int = 0
			,@intTotalLoadPriced				int = 0
			,@intCommulativeLoadPriced			int = 0
			,@intApplied						numeric(18,6) = 0
			,@intPreviousPricedLoad				numeric(18,6)
			,@dblLoadAppliedAndPriced			numeric(18,6)
			,@ysnDestinationWeightsGrades		bit = convert(bit,0)
			,@intWeightGradeId					int = 0
			,@ContractPriceItemUOMId			int = null
			,@ContractPriceUnitMeasureId		int = null
			,@ContractDetailItemId				int = null
			,@intSequenceFreightTermId			int
			,@ysnMultiPrice						BIT = 0
			,@NewInvoiceSpotDetailId			int
			,@dblBalance 						numeric(18,6)
			,@dblBalanceLoad 					numeric(18,6)
			,@dblDestinationQuantity numeric(18,6)
			,@dblInvoiceQtyShipped numeric(18,6)
			,@dblSequenceQuantity numeric(18,6)
			,@dblSpotQuantity numeric(18,6)
			,@intItemId int
			;

		
	declare @PricedShipment table
	(
		intInventoryShipmentId int
	)

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

	SELECT	@dblCashPrice				=	dblCashPrice, 
			@intPricingTypeId			=	intPricingTypeId, 
			@intLastModifiedById		=	ISNULL(intLastModifiedById,intCreatedById),
			@intContractHeaderId		=	intContractHeaderId,
			@intCompanyLocationId		=	intCompanyLocationId,
			@intSequenceFreightTermId 	= 	intFreightTermId,
			@intItemUOMId 				= 	intItemUOMId,
			@dblBalance					=	isnull(dblBalance,0),
			@dblBalanceLoad				=	isnull(dblBalanceLoad,0)
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId			=	@intContractDetailId

	select @intWeightGradeId = intWeightGradeId from tblCTWeightGrade where strWeightGradeDesc = 'Destination'
		
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
											),
			@ysnMultiPrice 		= 	ISNULL(ysnMultiplePriceFixation,0)
	FROM	tblCTContractHeader with (nolock)
	WHERE	intContractHeaderId = @intContractHeaderId


	SELECT  @intUserId = ISNULL(@intUserId,@intLastModifiedById), @dblBalance = (case when @ysnLoad = 1 then @dblBalanceLoad else @dblBalance end)

	SELECT	@ysnAllowChangePricing = ysnAllowChangePricing, @ysnEnablePriceContractApproval = ISNULL(ysnEnablePriceContractApproval,0) FROM tblCTCompanyPreference

	IF @ysnMultiPrice = 1
	BEGIN
		SELECT	@intPriceFixationId = intPriceFixationId, @intPriceContractId = intPriceContractId FROM tblCTPriceFixation WHERE intContractHeaderId = @intContractHeaderId
	END
	ELSE
	BEGIN
		SELECT	@intPriceFixationId = intPriceFixationId, @intPriceContractId = intPriceContractId FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId
	END

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

	end
	else IF (@intContractTypeId = 2)
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
					,tblCTContractDetail d with (nolock)
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
	 				and b.dblLoadPriced >= 0

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
					select
						intInventoryShipmentId
						,intInventoryShipmentItemId
						,dblShipped
						,intInvoiceDetailId
						,intItemUOMId
						,intLoadShipped
					from
					(
						SELECT
							intInventoryShipmentId = RI.intInventoryShipmentId,
							intInventoryShipmentItemId = RI.intInventoryShipmentItemId,
							dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(
																			RI.intItemUOMId
																			,@intItemUOMId
																			,(
																					case
																					when @ysnDestinationWeightsGrades = convert(bit,1)
																					then ISNULL(RI.dblDestinationQuantity,0)
																					else ISNULL(RI.dblQuantity,0)
																					end
																			  )
																		  ),
							intInvoiceDetailId = null,
							intItemUOMId = @intItemUOMId,
							intLoadShipped = convert(numeric(18,6),isnull(RI.intLoadShipped,0))
						FROM
							tblICInventoryShipmentItem RI with (nolock)
							JOIN tblICInventoryShipment IR with (nolock) ON IR.intInventoryShipmentId = RI.intInventoryShipmentId AND IR.intOrderType = 1
							JOIN tblCTPriceFixationTicket FT ON FT.intInventoryShipmentId = RI.intInventoryShipmentId
						WHERE
							RI.intLineNo = @intContractDetailId

						union all

						SELECT
							intInventoryShipmentId = RI.intInventoryShipmentId,
							intInventoryShipmentItemId = RI.intInventoryShipmentItemId,
							dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(
																			RI.intItemUOMId
																			,@intItemUOMId
																			,(
																					case
																					when @ysnDestinationWeightsGrades = convert(bit,1)
																					then ISNULL(RI.dblDestinationQuantity,0)
																					else ISNULL(RI.dblQuantity,0)
																					end
																			  )
																		  ),
							intInvoiceDetailId = ARD.intInvoiceDetailId,
							intItemUOMId = @intItemUOMId,
							intLoadShipped = convert(numeric(18,6),isnull(RI.intLoadShipped,0))
						FROM tblICInventoryShipmentItem RI with (nolock)
						JOIN tblICInventoryShipment IR with (nolock) ON IR.intInventoryShipmentId = RI.intInventoryShipmentId AND IR.intOrderType = 1
						OUTER APPLY (
										select top 1
											intInvoiceDetailId
										from
											tblARInvoiceDetail ARD with (nolock)
											join tblARInvoice I on I.intInvoiceId = ARD.intInvoiceId
										WHERE
											ARD.intContractDetailId = @intContractDetailId
											and ARD.intInventoryShipmentItemId = RI.intInventoryShipmentItemId
											and ARD.intInventoryShipmentChargeId is null
											and isnull(ARD.ysnReturned,0) = 0
											and I.strTransactionType = 'Invoice'
										) ARD
									
						WHERE
							RI.intLineNo = @intContractDetailId
					) t
					ORDER BY t.intInventoryShipmentItemId


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
							set @intActiveShipmentId = @intInventoryShipmentId;
						end

						set @intPricedLoad = (
								select count(*) from
								(
									select distinct
										ar.intInvoiceId
									from
										tblCTPriceFixationDetailAPAR ar
										,tblARInvoice i
									where
										ar.intPriceFixationDetailId = @intPriceFixationDetailId
										and i.intInvoiceId = ar.intInvoiceId
										and i.strTransactionType = 'Invoice'
										and isnull(i.ysnReturned,0) = 0
										
								) uniqueInvoice
							)

						if (@intPricedLoad >= @dblPriced) 
		  				begin
							goto SkipShipmentLoop; 
						end

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
									,@ShipmentItemId		=	@intInventoryShipmentItemId
									,@UserId				=	@intUserId
									,@intContractHeaderId	=   @intContractHeaderId
									,@intContractDetailId	=	@intContractDetailId
									,@dblQuantity           =   @dblQuantityForInvoice
									,@NewInvoiceId			=	@intNewInvoiceId	OUTPUT
									,@intPriceFixationDetailId 	= 	@intPriceFixationDetailId

							--For some reason, I don't know why there's this code :)
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
										@dblQtyShipped		=	@dblQuantityForInvoice


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
								exec uspCTCreatePricingAPARLink
									@intPriceFixationDetailId = @intPriceFixationDetailId
									,@intHeaderId = @intNewInvoiceId
									,@intDetailId = @intInvoiceDetailId
									,@intSourceHeaderId = null
									,@intSourceDetailId = @intInventoryShipmentItemId
									,@dblQuantity = @dblQuantityForInvoice
									,@strScreen = 'Invoice'

									exec uspCTAddDiscountsChargesToInvoice
										@intContractDetailId  = @intContractDetailId
										,@intInventoryShipmentId = @intInventoryShipmentId
										,@UserId = @intUserId
										,@intInvoiceDetailId = @intInvoiceDetailId
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
			select
				intInventoryShipmentId
				,intInventoryShipmentItemId
				,dblShipped
				,intInvoiceDetailId
				,intItemUOMId
				,intLoadShipped
				,dtmInvoiceDate
			from
			(
				SELECT
					intInventoryShipmentId = RI.intInventoryShipmentId,
					intInventoryShipmentItemId = RI.intInventoryShipmentItemId,
					dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(
																	RI.intItemUOMId
																	,@intItemUOMId
																	,(
																			case
																			when @ysnDestinationWeightsGrades = convert(bit,1)
																			then ISNULL(RI.dblDestinationQuantity,0)
																			else ISNULL(RI.dblQuantity,0)
																			end
																	  )
																  ),
					intInvoiceDetailId = null,
					intItemUOMId = @intItemUOMId,
					intLoadShipped = convert(numeric(18,6),isnull(RI.intLoadShipped,0)),
					dtmInvoiceDate = null
				FROM
					tblICInventoryShipmentItem RI with (nolock)
					JOIN tblICInventoryShipment IR with (nolock) ON IR.intInventoryShipmentId = RI.intInventoryShipmentId AND IR.intOrderType = 1
					JOIN tblCTPriceFixationTicket FT ON FT.intInventoryShipmentId = RI.intInventoryShipmentId
				WHERE
					RI.intLineNo = @intContractDetailId

				union all

				SELECT
					intInventoryShipmentId = RI.intInventoryShipmentId,
					intInventoryShipmentItemId = RI.intInventoryShipmentItemId,
					dblShipped = dbo.fnCTConvertQtyToTargetItemUOM(
																	RI.intItemUOMId
																	,@intItemUOMId
																	,(
																			case
																			when @ysnDestinationWeightsGrades = convert(bit,1)
																			then ISNULL(RI.dblDestinationQuantity,0)
																			else ISNULL(RI.dblQuantity,0)
																			end
																	  )
																  ),
					intInvoiceDetailId = ARD.intInvoiceDetailId,
					intItemUOMId = @intItemUOMId,
					intLoadShipped = convert(numeric(18,6),isnull(RI.intLoadShipped,0)),
					dtmInvoiceDate = null
				FROM tblICInventoryShipmentItem RI with (nolock)
				JOIN tblICInventoryShipment IR with (nolock) ON IR.intInventoryShipmentId = RI.intInventoryShipmentId AND IR.intOrderType = 1
				left join tblARInvoiceDetail di on di.intInventoryShipmentItemId = RI.intInventoryShipmentItemId and isnull(di.ysnReturned,0) = 1
				OUTER APPLY (
								select top 1
									intInvoiceDetailId
								from
									tblARInvoiceDetail ARD with (nolock)
									join tblARInvoice I on I.intInvoiceId = ARD.intInvoiceId
								WHERE
									ARD.intContractDetailId = @intContractDetailId
									and ARD.intInventoryShipmentItemId = RI.intInventoryShipmentItemId
									and ARD.intInventoryShipmentChargeId is null
									and isnull(ARD.ysnReturned,0) = 0
									and I.strTransactionType = 'Invoice'
								) ARD
								
				WHERE
					RI.intLineNo = @intContractDetailId
					and isnull(di.intInvoiceDetailId,0) = 0
			) t
			ORDER BY t.intInventoryShipmentItemId

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
				left join tblARInvoiceDetail di with (nolock) on di.intInventoryShipmentItemId = si.intInventoryShipmentItemId
				left join tblARInvoice i with (nolock) on i.intInvoiceId = di.intInvoiceId
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
												SUM(dbo.fnCTConvertQtyToTargetItemUOM(ID.intItemUOMId,@intItemUOMId,(case when isnull(ID.ysnReturned,0) = 1 then ID.dblQtyShipped * - 1 else ID.dblQtyShipped end)))
											FROM
												tblARInvoiceDetail ID with (nolock), tblARInvoice I with (nolock)
											WHERE
												ID.intInventoryShipmentItemId = @intInventoryShipmentItemId
												AND ID.intInventoryShipmentChargeId IS NULL
												AND isnull(ID.ysnReturned,0) = 0
												AND I.intInvoiceId = ID.intInvoiceId
												and I.strTransactionType = 'Invoice'
												
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
							,dblSequenceQuantity = d.dblQuantity
						from
							tblCTPriceFixation a
							,tblCTPriceFixationDetail b
							,tblCTPriceContract c
							,tblCTContractDetail d with (nolock)
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
	   						and b.dblQuantity >= 0

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
						,@dblSequenceQuantity

					WHILE @@FETCH_STATUS = 0
					BEGIN
						
						--Skip Pricing loop if Shipped Quantity For Invoice is 0
						if (@dblShippedForInvoice = 0)
						begin
							goto SkipPricingLoop;
						end

						set @dblInvoicedPriced = (
													SELECT
														SUM(dbo.fnCTConvertQtyToTargetItemUOM(AD.intItemUOMId,@intItemUOMId,AD.dblQtyShipped))
													FROM
														tblCTPriceFixationDetailAPAR AA
														JOIN tblARInvoiceDetail AD with (nolock) ON AD.intInvoiceDetailId	= AA.intInvoiceDetailId
													WHERE
														AA.intPriceFixationDetailId = @intPriceFixationDetailId
														and isnull(AA.ysnReturn,0) = 0
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

						--Check if Shipment Item has unposted Invoice
						if not exists (
										select
											top 1 1
										from
											tblICInventoryShipmentItem a with (nolock)
											,tblARInvoiceDetail b with (nolock), tblARInvoice c with (nolock)
										where
											a.intInventoryShipmentId = @intInventoryShipmentId
											and b.intInventoryShipmentItemId = a.intInventoryShipmentItemId
											and c.intInvoiceId = b.intInvoiceId
											and isnull(c.ysnPosted,0) = 0
											and c.strTransactionType = 'Invoice'
									  )
						begin
							--Shipment Item has no unposted Invoice, therefore create

							--Allow Shipment Item to create Invoice
							UPDATE  tblICInventoryShipmentItem SET ysnAllowInvoice = 1 WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId;
							--Create Invoice for Shipment Item

							print 'create new invoice';

							EXEC	uspCTCreateInvoiceFromShipment 
									@ShipmentId				=	@intInventoryShipmentId
									,@ShipmentItemId		=	@intInventoryShipmentItemId
									,@UserId				=	@intUserId
									,@intContractHeaderId	=   @intContractHeaderId
									,@intContractDetailId	=	@intContractDetailId
									,@NewInvoiceId			=	@intNewInvoiceId	OUTPUT
									,@dblQuantity           =   @dblQuantityForInvoice
									,@intPriceFixationDetailId 	= 	@intPriceFixationDetailId

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
								exec uspCTCreatePricingAPARLink
									@intPriceFixationDetailId = @intPriceFixationDetailId
									,@intHeaderId = @intNewInvoiceId
									,@intDetailId = @intInvoiceDetailId
									,@intSourceHeaderId = null
									,@intSourceDetailId = @intInventoryShipmentItemId
									,@dblQuantity = @dblQuantityForInvoice
									,@strScreen = 'Invoice'

									exec uspCTAddDiscountsChargesToInvoice
										@intContractDetailId  = @intContractDetailId
										,@intInventoryShipmentId = @intInventoryShipmentId
										,@UserId = @intUserId
										,@intInvoiceDetailId = @intInvoiceDetailId

							END

							if (isnull(@ysnDestinationWeightsGrades,0) = 1)
							begin

								select
									@intItemId = @ContractDetailItemId
									,@dblDestinationQuantity = null
									,@dblInvoiceQtyShipped = null
									,@dblSequenceQuantity = @dblSequenceQuantity
									,@dblSpotQuantity = null

								select @dblDestinationQuantity = sum(si.dblDestinationQuantity) from tblICInventoryShipmentItem si where si.intLineNo = @intContractDetailId and si.intItemId = @intItemId;
								select @dblInvoiceQtyShipped = sum(di.dblQtyShipped) from tblARInvoiceDetail di where di.intContractDetailId = @intContractDetailId and di.intItemId = @intItemId;

								if (@dblSequenceQuantity < @dblDestinationQuantity and @dblSequenceQuantity <= @dblInvoiceQtyShipped)
								begin
									select @dblSpotQuantity = @dblDestinationQuantity - @dblSequenceQuantity;

									exec uspCTCreateInvoiceDetail
										@intInvoiceDetailId = @intInvoiceDetailId
										,@intInventoryShipmentId = @intInventoryShipmentId
										,@intInventoryShipmentItemId = @intInventoryShipmentItemId
										,@dblQty = @dblSpotQuantity
										,@dblPrice = 0.00
										,@intUserId = @intUserId
										,@intContractHeaderId = null
										,@intContractDetailId = null
										,@NewInvoiceDetailId = @NewInvoiceSpotDetailId
										,@intPriceFixationDetailId = @intPriceFixationDetailId;
								end
							end

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
								tblICInventoryShipmentItem a with (nolock)
								,tblARInvoiceDetail b with (nolock), tblARInvoice c with (nolock)
							where
								a.intInventoryShipmentId = @intInventoryShipmentId
								and b.intInventoryShipmentItemId = a.intInventoryShipmentItemId
								and c.intInvoiceId = b.intInvoiceId
								and isnull(c.ysnPosted,0) = 0
								and c.strTransactionType = 'Invoice'

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
								,@intPriceFixationDetailId

							exec uspCTCreatePricingAPARLink
								@intPriceFixationDetailId = @intPriceFixationDetailId
								,@intHeaderId = @intInvoiceId
								,@intDetailId = @intInvoiceDetailId
								,@intSourceHeaderId = null
								,@intSourceDetailId = @intInventoryShipmentItemId
								,@dblQuantity = @dblQuantityForInvoice
								,@strScreen = 'Invoice'

							exec uspCTAddDiscountsChargesToInvoice
								@intContractDetailId  = @intContractDetailId
								,@intInventoryShipmentId = @intInventoryShipmentId
								,@UserId = @intUserId
								,@intInvoiceDetailId = @intInvoiceDetailId

							if (isnull(@ysnDestinationWeightsGrades,0) = 1)
							begin

								select
									@intItemId = @ContractDetailItemId
									,@dblDestinationQuantity = null
									,@dblInvoiceQtyShipped = null
									,@dblSequenceQuantity = @dblSequenceQuantity
									,@dblSpotQuantity = null

								select @dblDestinationQuantity = sum(si.dblDestinationQuantity) from tblICInventoryShipmentItem si where si.intLineNo = @intContractDetailId and si.intItemId = @intItemId;
								select @dblInvoiceQtyShipped = sum(di.dblQtyShipped) from tblARInvoiceDetail di where di.intContractDetailId = @intContractDetailId and di.intItemId = @intItemId;

								if (@dblSequenceQuantity < @dblDestinationQuantity and @dblSequenceQuantity <= @dblInvoiceQtyShipped)
								begin
									select @dblSpotQuantity = @dblDestinationQuantity - @dblSequenceQuantity;

									exec uspCTCreateInvoiceDetail
										@intInvoiceDetailId = @intInvoiceDetailId
										,@intInventoryShipmentId = @intInventoryShipmentId
										,@intInventoryShipmentItemId = @intInventoryShipmentItemId
										,@dblQty = @dblSpotQuantity
										,@dblPrice = 0.00
										,@intUserId = @intUserId
										,@intContractHeaderId = null
										,@intContractDetailId = null
										,@NewInvoiceDetailId = @NewInvoiceSpotDetailId
										,@intPriceFixationDetailId = @intPriceFixationDetailId;
								end

							end
							
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
							,@dblSequenceQuantity

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

	exec uspCTUpdateAppliedAndPrice
	@intContractDetailId = @intContractDetailId
	,@dblBalance = @dblBalance

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH