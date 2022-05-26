CREATE PROCEDURE [dbo].[uspCTUpdateDWGSequenceBalance]
	@ContractSequenceBalance	CTContractSequenceBalanceType readonly,
	@ysnPost bit
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
		,@dblQuantity NUMERIC(38, 20) 
		,@dblAdjustment NUMERIC(24, 10) 
		,@dblContractQuantity NUMERIC(24, 10) 
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
		,dblQuantity NUMERIC(38, 20) NULL
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
		,dblOldQuantity =
							case
								when isnull(ch.ysnLoad,0) = 0
								then
									case
										when cb.dblOldQuantity > cd.dblQuantity
										then cd.dblQuantity
										else cb.dblOldQuantity
									end
								else cb.dblOldQuantity
							end
		,dblQuantity = cb.dblQuantity
		,intFromItemUOMId = cb.intItemUOMId
		,strScreenName = (case when cb.strScreenName = 'Inventory' then 'Inventory Shipment' else cb.strScreenName end)
		,intUserId = cb.intUserId
		,ysnFromInvoice = (case when cb.strScreenName = 'Invoice' then convert(bit,1) else convert(bit,0) end)
	from
		@ContractSequenceBalance cb
		left join tblCTContractDetail cd on cd.intContractDetailId = cb.intContractDetailId
		left join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId

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
			,@dblAdjustment = (dblOldQuantity - dblQuantity)
			,@intFromItemUOMId = intFromItemUOMId
			,@strScreenName = strScreenName
			,@intUserId  = intUserId
			,@ysnFromInvoice  = ysnFromInvoice
		from
			@ContractSequenceBalanceSummary
		where
			intId = @intId

		-------------------------------------
		-- Scenario 1
		-- Distribute SI-1 50
		-- Distribute SI-2 50
		-- Post SI-1 DWG 40 | Adjustment 10
		-- Currently Applied: 50
		-- Balance less other shipment: 50
		-- if -10 > 50
		-- Converted Qty: 10
		-------------------------------------
		-- Scenario 2
		-- Distribute SI-1 50
		-- Distribute SI-2 50
		-- Post SI-1 DWG 60 | Adjustment -10
		-- Currently Applied: 50
		-- Balance less other shipment: 50
		-- if 10 > 50
		-- Converted Qty: 10
		-------------------------------------
		-- Scenario 3
		-- Distribute SI-1 90
		-- Post SI-1 DWG 110 | Adjustment -20
		-- Currently Applied: 90
		-- Balance less other shipment: 10
		-- if 20 > 10 ? 10 
		-- Converted Qty: 10
		-------------------------------------
		-- Scenario 4
		-- Distribute SI-1 100
		-- Post SI-1 DWG 110 | Adjustment -10
		-- Currently Applied: 100
		-- Balance less other shipment: 0
		-- if 10 > 0 ? 0 
		-- Converted Qty: 0
		-------------------------------------
		select @dblCurrentlyApplied = sum(isnull(si.dblDestinationQuantity, si.dblQuantity)) from tblICInventoryShipmentItem si where si.intLineNo = @intContractDetailId and si.intInventoryShipmentItemId <> @intExternalId;
		select @dblContractQuantity = dblQuantity, @intContractHeaderId = intContractHeaderId from tblCTContractDetail where intContractDetailId = @intContractDetailId;
		select @ysnLoad = isnull(ysnLoad, convert(bit,0)) from tblCTContractHeader where intContractHeaderId = @intContractHeaderId;    
		
		if (@ysnLoad = 0 and (@dblQuantity + isnull(@dblCurrentlyApplied,0)) > @dblContractQuantity  and @dblSequenceBalanceQuantity <= 0)
		begin
			select @intId = min(cb.intId) from @ContractSequenceBalance cb where cb.intId > @intId;
			continue
		end

		set @dblBalanceLessOtherShipmentItem = @dblContractQuantity - isnull(@dblCurrentlyApplied,0)

		if (@dblAdjustment * -1) > @dblBalanceLessOtherShipmentItem
		begin
			set @dblAdjustment = @dblBalanceLessOtherShipmentItem;
		end
		
		select @dblConvertedQty =	(dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblAdjustment) * -1);

		--If there's available balance and the tota applied quantity (posted DWG quantity) is more than sequence quantity, need to just zero out the sequence balance.
		if (@dblConvertedQty > @dblSequenceBalanceQuantity)
		begin
			select @dblConvertedQty = @dblSequenceBalanceQuantity;
		end

		EXEC	uspCTUpdateSequenceBalance
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblConvertedQty,
				@intUserId				=	@intUserId,
				@intExternalId			=	@intExternalId,
				@strScreenName			=	@strScreenName,
				@ysnFromInvoice 		= 	@ysnFromInvoice,
				@ysnDWG					=   1,
				@ysnPostDWG				=   @ysnPost
				

		select @intId = min(cb.intId) from @ContractSequenceBalance cb where cb.intId > @intId;

	end

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH