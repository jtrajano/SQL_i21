CREATE PROCEDURE [dbo].[uspCTCreateInvoice]
		
	@intContractDetailId int
	,@intUserId int
	,@strCreatedVoucherInvoiceIds NVARCHAR(1000) = '' OUTPUT

AS

BEGIN TRY

	declare
		@ErrMsg nvarchar(max)
		,@pricing cursor
		,@intContractHeaderId int
		,@intPriceFixationId int
		,@intPriceFixationDetailId int
		,@dblPriced numeric(18,6)
		,@dblFinalPrice numeric(18,6)
		,@ContractPriceUnitMeasureId int = null
		,@ContractDetailItemId int = null
		,@intShipmentCount int
		,@intCommulativeLoadPriced int = 0

		,@shipment cursor
		,@intInventoryShipmentId int
		,@intInventoryShipmentItemId int
		,@strShipmentNumber NVARCHAR(50)
		,@dblShipped numeric(18,6)
		,@intInvoiceDetailId int
		,@dblInventoryShipmentItemLoadApplied numeric(18,6)
		,@intActiveShipmentId int = 0
		,@intPricedLoad int = 0
		,@intTotalLoadPriced int = 0
		,@dblQuantityForInvoice numeric(18,6)
		,@intNewInvoiceId int
		,@ContractPriceItemUOMId int = null
		,@intApplied numeric(18,6)
		,@intPreviousPricedLoad numeric(18,6)
		,@dblLoadAppliedAndPriced numeric(18,6)
		,@dblInvoicedShipped numeric(18,6)
		,@dblShippedForInvoice numeric(18,6)
		,@dblInvoicedPriced numeric(18,6)
		,@dblPricedForInvoice numeric(18,6)
		,@intInvoiceId int

		,@ysnMultiPrice bit
		,@intWeightGradeId int
		,@ysnLoad bit = 0
		,@intPriceContractId int
		,@strPriceContractNo NVARCHAR(50)
		,@intItemUOMId int
		,@ysnDestinationWeightsGrades bit
		,@intPricingTypeId int
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

	declare @CreatedInvoiceDetails table (
		intInvoiceId int not null
		,intInvoiceDetailId int not null
	);

	select @intWeightGradeId = intWeightGradeId from tblCTWeightGrade where strWeightGradeDesc = 'Destination';

	select
		@ysnLoad = isnull(ch.ysnLoad,convert(bit,0))
		,@ysnMultiPrice = isnull(ch.ysnMultiplePriceFixation,convert(bit,0))
		,@intContractHeaderId = ch.intContractHeaderId
		,@intItemUOMId = cd.intItemUOMId
		,@ysnDestinationWeightsGrades = (
									case
									when isnull(@intWeightGradeId,0) = 0
									then convert(bit,0) 
									else (
												case
												when ch.intWeightId = @intWeightGradeId or ch.intGradeId = @intWeightGradeId
												then convert(bit,1)
												else convert(bit,0)
												end
											)
									end
								)
		,@intPricingTypeId = cd.intPricingTypeId
	from
		tblCTContractDetail cd
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
	where
		cd.intContractDetailId = @intContractDetailId;

	IF @ysnMultiPrice = 1
	BEGIN
		SELECT
			@intPriceContractId = intPriceContractId
		FROM
			tblCTPriceFixation
		WHERE
			intContractHeaderId = @intContractHeaderId
	END
	ELSE
	BEGIN
		SELECT
			@intPriceContractId = intPriceContractId
		FROM
			tblCTPriceFixation
		WHERE
			intContractDetailId = @intContractDetailId
	END

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
				,strPriceContractNo = c.strPriceContractNo
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
			,@strPriceContractNo

		WHILE @@FETCH_STATUS = 0
		BEGIN			
				
			--Loop Shipment
			set @intShipmentCount = 0;
			set @intCommulativeLoadPriced = @intCommulativeLoadPriced + @dblPriced;
				
			SET @shipment = CURSOR FOR
				select
					intInventoryShipmentId
					,intInventoryShipmentItemId
					,dblShipped
					,intInvoiceDetailId
					,intItemUOMId
					,intLoadShipped
					,strShipmentNumber
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
						IR.strShipmentNumber
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
						IR.strShipmentNumber
					FROM tblICInventoryShipmentItem RI with (nolock)
					JOIN tblICInventoryShipment IR with (nolock) ON IR.intInventoryShipmentId = RI.intInventoryShipmentId AND IR.intOrderType = 1
					OUTER APPLY (
									select top 1
										intInvoiceDetailId
									from
										tblARInvoiceDetail ARD with (nolock)
									WHERE
										ARD.intContractDetailId = @intContractDetailId
										and ARD.intInventoryShipmentItemId = RI.intInventoryShipmentItemId
										and ARD.intInventoryShipmentChargeId is null
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
					,@strShipmentNumber

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


					---------------------Do Invoicing---------------------

					set @dblQuantityForInvoice = @dblShipped;

						--Shipment Item has no unposted Invoice, therefore create

						--Allow Shipment Item to create Invoice
						UPDATE  tblICInventoryShipmentItem SET ysnAllowInvoice = 1 WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId;
						--Create Invoice for Shipment Item

						IF (ISNULL(@intPriceContractId, 0) <> 0 )
						BEGIN
							-- Traceability Feature - CT-5847
							DECLARE @TransactionLink udtICTransactionLinks
							INSERT INTO @TransactionLink (strOperation
								, intSrcId
								, strSrcTransactionNo
								, strSrcModuleName
								, strSrcTransactionType
								, intDestId
								, strDestTransactionNo
								, strDestModuleName
								, strDestTransactionType)
							SELECT 'Price Contract'
								, intSrcId = @intInventoryShipmentId
								, strSrcTransactionNo = @strShipmentNumber
								, strSrcModuleName = 'Inventory'
								, strSrcTransactionType = 'Inventory Shipment'
								, intDestId = @intPriceContractId
								, strDestTransactionNo = @strPriceContractNo
								, 'Contract Management'
								, 'Price Contract'
					
							EXEC dbo.uspICAddTransactionLinks @TransactionLink
						END

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

								insert into @CreatedInvoiceDetails select intInvoiceId = @intNewInvoiceId, intInvoiceDetailId = @intInvoiceDetailId;
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
						,@strShipmentNumber

				END

				CLOSE @shipment
				DEALLOCATE @shipment

			---------------------End Loop Shipment---------------------
											
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
				,@strPriceContractNo

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
			OUTER APPLY (
							select top 1
								intInvoiceDetailId
							from
								tblARInvoiceDetail ARD with (nolock)
							WHERE
								ARD.intContractDetailId = @intContractDetailId
								and ARD.intInventoryShipmentItemId = RI.intInventoryShipmentItemId
								and ARD.intInventoryShipmentChargeId is null
							) ARD
							
			WHERE
				RI.intLineNo = @intContractDetailId	
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

		---------------------Loop Shipment---------------------
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
				---------------------Loop Pricing---------------------
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

							--when there's multiple line item in IS, uspCTCreateInvoiceFromShipment will create all those line in invoice - need to remove the others and will create in the shipment item loop
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

								insert into @CreatedInvoiceDetails select intInvoiceId = @intNewInvoiceId, intInvoiceDetailId = @intInvoiceDetailId;

						END

						if (isnull(@ysnDestinationWeightsGrades,0) = 1)
						begin
							exec uspARUpdateOverageContracts
								@intInvoiceId = @intNewInvoiceId
								, @intScaleUOMId = default
								, @intUserId = @intUserId
								, @dblNetWeight =  default
								, @ysnFromSalesOrder =  default
								, @ysnFromImport =  default
								, @dblSpotPrice =  default
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

						insert into @CreatedInvoiceDetails select intInvoiceId = @intInvoiceId, intInvoiceDetailId = @intInvoiceDetailId;
							
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
				---End Loop Pricing---
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
		---End Loop Shipment---

	end

	if exists (select top 1 1 from @CreatedInvoiceDetails)
	begin
		declare @dblDiscountChargeQty numeric(18,6);

		while exists (select top 1 1 from @CreatedInvoiceDetails)
		begin
			select top 1 @intInvoiceId = intInvoiceId, @intInvoiceDetailId = intInvoiceDetailId from @CreatedInvoiceDetails;

			set @strCreatedVoucherInvoiceIds = @strCreatedVoucherInvoiceIds + ',' + convert(nvarchar(20),@intInvoiceId);

			select
				@intInventoryShipmentId = shipment.intInventoryShipmentId
				,@dblDiscountChargeQty = case when sum(di.dblQtyShipped) > shipment.dblTotalShipped then shipment.dblTotalShipped else sum(di.dblQtyShipped) end
			from
				tblARInvoiceDetail di
				join @CreatedInvoiceDetails dip on dip.intInvoiceId = di.intInvoiceId
				cross apply (
					select top 1 intInventoryShipmentId = intInventoryShipmentId, dblTotalShipped = isnull(si.dblDestinationQuantity,si.dblQuantity) from tblICInventoryShipmentItem si where si.intInventoryShipmentItemId = di.intInventoryShipmentItemId
				) shipment
			where
				di.intInvoiceId = @intInvoiceId
				and di.intInvoiceDetailId = dip.intInvoiceDetailId
				and di.intInventoryShipmentChargeId is null
			group by
				shipment.intInventoryShipmentId
				,shipment.dblTotalShipped;


			exec uspCTAddDiscountsChargesToInvoice
				@intContractDetailId  = @intContractDetailId
				,@intInventoryShipmentId = @intInventoryShipmentId
				,@UserId = @intUserId
				,@intInvoiceDetailId = @intInvoiceDetailId
				,@dblQuantityToCharge = @dblDiscountChargeQty

			delete from @CreatedInvoiceDetails where intInvoiceId = @intInvoiceId;
		end

	end

END TRY
BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH