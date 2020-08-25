CREATE PROCEDURE [dbo].[uspCTUpdateDWGSequenceBalance]
	@ContractSequenceBalance	CTContractSequenceBalanceType readonly
AS

BEGIN TRY
	
	DECLARE
		@ErrMsg NVARCHAR(MAX)
		,@intId int = 0
		,@dblConvertedQty numeric(24,10)
		,@dblCalculatedQty numeric(24,10)

		,@intContractDetailId int
		,@dblSequenceQuantity numeric (18,6)
		,@dblSequenceBalanceQuantity numeric (18,6)
		,@intToItemUOMId int
		,@intExternalId int
		,@dblOldQuantity NUMERIC(24, 10) 
		,@dblQuantity NUMERIC(24, 10) 
		,@intFromItemUOMId int
		,@strScreenName nvarchar(50)
		,@intUserId int
		,@ysnFromInvoice bit = convert(bit,0)
		,@dblCurrentBalanceQuantity numeric (18,6)
		,@dblCurrentlyApplied numeric (18,6)
		,@dblBalanceLessOtherShipmentItem numeric (18,6)
		,@intContractHeaderId int
		,@ysnLoad bit = convert(bit,0);

	declare @ContractSequenceBalanceSummary table (
		intId int 
		,intContractDetailId int
		,dblSequenceQuantity numeric(18,6)
		,dblSequenceBalanceQuantity numeric(18,6)
		,intToItemUOMId int
		,intExternalId int NULL
		,dblOldQuantity NUMERIC(24, 10) NULL
		,dblQuantity NUMERIC(24, 10) NULL
		,intFromItemUOMId int NULL
		,strScreenName NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
		,intUserId INT NULL
		,ysnFromInvoice bit
	);
	
	BEGINING:

	insert into @ContractSequenceBalanceSummary
	(
		intId
		,intContractDetailId
		,dblSequenceQuantity
		,dblSequenceBalanceQuantity
		,intToItemUOMId
		,intExternalId
		,dblOldQuantity
		,dblQuantity
		,intFromItemUOMId
		,strScreenName
		,intUserId
		,ysnFromInvoice
	)
	select
		intId = cb.intId
		,intContractDetailId = cd.intContractDetailId
		,dblSequenceQuantity = cd.dblQuantity
		,dblSequenceBalanceQuantity = cd.dblBalance
		,intToItemUOMId = cd.intItemUOMId
		,intExternalId = cb.intExternalId
		,dblOldQuantity = cb.dblOldQuantity
		,dblQuantity = cb.dblQuantity
		,intFromItemUOMId = cb.intItemUOMId
		,strScreenName = (case when cb.strScreenName = 'Inventory' then 'Inventory Shipment' else cb.strScreenName end)
		,intUserId = cb.intUserId
		,ysnFromInvoice = (case when cb.strScreenName = 'Invoice' then convert(bit,1) else convert(bit,0) end)
	from
		@ContractSequenceBalance cb
		left join tblCTContractDetail cd on cd.intContractDetailId = cb.intContractDetailId

	select @intId = min(cb.intId) from @ContractSequenceBalance cb where cb.intId > @intId;

	while (@intId is not null)
	begin

		select
			@intContractDetailId = intContractDetailId
			,@dblSequenceQuantity  = dblSequenceQuantity
			,@dblSequenceBalanceQuantity = dblSequenceBalanceQuantity
			,@intToItemUOMId = intToItemUOMId
			,@intExternalId = intExternalId
			,@dblOldQuantity = dblOldQuantity
			,@dblQuantity = dblQuantity
			,@intFromItemUOMId = intFromItemUOMId
			,@strScreenName = strScreenName
			,@intUserId  = intUserId
			,@ysnFromInvoice  = ysnFromInvoice
		from
			@ContractSequenceBalanceSummary
		where
			intId = @intId

		/*Return the Shipment quantity*/
		--Get all quantity applied to other Shipment Item
		select @dblCurrentlyApplied = sum(isnull(si.dblDestinationQuantity, si.dblQuantity)) from tblICInventoryShipmentItem si where si.intLineNo = @intContractDetailId and si.intInventoryShipmentItemId <> @intExternalId;
		select @dblBalanceLessOtherShipmentItem = (dblQuantity - @dblCurrentlyApplied), @intContractHeaderId = intContractHeaderId from tblCTContractDetail where intContractDetailId = @intContractDetailId;
		select @ysnLoad = ysnLoad from tblCTContractHeader where intContractHeaderId = @intContractHeaderId;

		if (@dblBalanceLessOtherShipmentItem < @dblOldQuantity)
		begin
			set @dblOldQuantity = @dblBalanceLessOtherShipmentItem;
		end

		SELECT @dblConvertedQty =	(dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblOldQuantity) * -1);
		if (@ysnLoad = convert(bit,1))
		begin
			set @dblConvertedQty = -1;
		end

		EXEC	uspCTUpdateSequenceBalance
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblConvertedQty,
				@intUserId				=	@intUserId,
				@intExternalId			=	@intExternalId,
				@strScreenName			=	@strScreenName,
				@ysnFromInvoice 		= 	@ysnFromInvoice

		/*Calculate if the sequence remaining balance is enough for the DWG quantity*/
		select @dblCurrentBalanceQuantity = dblBalance from tblCTContractDetail where intContractDetailId = @intContractDetailId;
		set @dblCalculatedQty = (case when @dblCurrentBalanceQuantity > @dblQuantity then @dblQuantity else @dblCurrentBalanceQuantity end);

		/*Apply the DWG quantity (or the remianing sequence balance) to sequence balance*/
		SELECT @dblConvertedQty =	dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblCalculatedQty);
		if (@ysnLoad = convert(bit,1))
		begin
			set @dblConvertedQty = 1;
		end

		EXEC	uspCTUpdateSequenceBalance
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblConvertedQty,
				@intUserId				=	@intUserId,
				@intExternalId			=	@intExternalId,
				@strScreenName			=	@strScreenName,
				@ysnFromInvoice 		= 	@ysnFromInvoice

		select @intId = min(cb.intId) from @ContractSequenceBalance cb where cb.intId > @intId;

	end

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH