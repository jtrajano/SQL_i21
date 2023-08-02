CREATE FUNCTION [dbo].[fnCTAppliedQuantity]
(
	@intContractDetailId int
	,@intUnitMeasureId int
	,@intItemUOMId int
	,@intItemId int
	,@intContractTypeId int
)
RETURNS NUMERIC(26,12)
AS 
BEGIN 
	DECLARE	@dblReturn NUMERIC(26,12);

	if (@intContractTypeId = 1)
	begin
		select @dblReturn = sum(dbo.fnCTConvertQtyToTargetItemUOM(ri.intUnitMeasureId,@intItemUOMId,isnull(ri.dblReceived,0))) from tblICInventoryReceiptItem ri where ri.intLineNo = @intContractDetailId and ri.intItemId = @intItemId;
	end
	else
	begin
		select @dblReturn = sum(dbo.fnCTConvertQtyToTargetItemUOM(si.intItemUOMId,@intItemUOMId,isnull(si.dblQuantity,0))) from tblICInventoryShipmentItem si where si.intLineNo = @intContractDetailId and si.intItemId = @intItemId;
	end
	
	RETURN isnull(@dblReturn,0.00);	
END
GO