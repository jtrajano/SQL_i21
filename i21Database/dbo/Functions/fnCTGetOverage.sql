CREATE FUNCTION [dbo].[fnCTGetOverage]
(
	@dblDestinationQuantity numeric(38,20) --> Destination Quantity
	,@intInventoryShipmentItemId int --> Shipment Item ID
	,@ysnExcludeFromCalculation bit --> Pass 1 to exclude the Shipment Item quantity from the calculation
)
RETURNS numeric(38,20)

AS 
BEGIN

	declare
		@dblOverageQuantity numeric(38,20)
		,@dblSequenceQuantity numeric(38,20)
		,@intSequenceItemUOMId int
		,@intContractDetailId int
		,@intContractHeaderId int
		,@dblShipmentQuantity numeric(38,20)
		,@intShipmentItemUOMId int
		,@dblSequenceRemainingQuantity numeric(38,20)

	select
		@intContractHeaderId = si.intOrderId
		,@intContractDetailId = si.intLineNo
		,@intShipmentItemUOMId = si.intItemUOMId
	from
		tblICInventoryShipmentItem si
	where
		si.intInventoryShipmentItemId = @intInventoryShipmentItemId
		and isnull(si.ysnDestinationWeightsAndGrades,0) = 1


	select
		@dblSequenceQuantity = cd.dblQuantity
		,@intSequenceItemUOMId = cd.intItemUOMId
		,@intContractHeaderId = cd.intContractHeaderId
	from
		tblCTContractDetail cd
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		left join tblCTWeightGrade w on w.intWeightGradeId = ch.intWeightId
		left join tblCTWeightGrade g on w.intWeightGradeId = ch.intGradeId
	where
		cd.intContractDetailId = @intContractDetailId
		and isnull(ch.ysnLoad,0) <> 1
		and (isnull(w.strWhereFinalized,'') = 'Destination' or isnull(g.strWhereFinalized,'') = 'Destination')

	select
		@dblShipmentQuantity = dbo.fnCTConvertQtyToTargetItemUOM(si.intItemUOMId,isnull(@intSequenceItemUOMId,si.intItemUOMId),isnull(si.dblDestinationQuantity,si.dblQuantity))
	from
		tblICInventoryShipmentItem si
		join tblICInventoryShipment s on s.intInventoryShipmentId = si.intInventoryShipmentId
	where
		si.intOrderId = @intContractHeaderId
		and si.intLineNo = @intContractDetailId
		and si.intInventoryShipmentItemId <> (case when @ysnExcludeFromCalculation = 1 then 0 else @intInventoryShipmentItemId end)
		and s.intOrderType = 1

	select @dblSequenceRemainingQuantity = isnull(@dblSequenceQuantity,0) - isnull(@dblShipmentQuantity,0);

	select @dblOverageQuantity = dbo.fnCTConvertQtyToTargetItemUOM(isnull(@intSequenceItemUOMId,@intShipmentItemUOMId),@intShipmentItemUOMId,isnull(@dblSequenceRemainingQuantity,0)) - @dblDestinationQuantity;

	select @dblOverageQuantity = case when @dblOverageQuantity < 0 then abs(@dblOverageQuantity) else 0 end;

	RETURN	@dblOverageQuantity;	
END
