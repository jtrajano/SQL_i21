CREATE PROCEDURE [dbo].[uspMFGetItemCostInTargetUOM]
	@intItemId int,
	@intLocationId int,
	@intToItemUOMId int,
	@intContractDetailId int,
	@dblCostInTargetUOM NUMERIC(38,20) OUT
AS

Declare @dblCost NUMERIC(38,20)
Declare @intItemStockUOMId int
Declare @dblCashPriceInStockUOM NUMERIC(38,20)
Declare @dblUnitQtyFrom NUMERIC(38,20)
Declare @dblUnitQtyTo NUMERIC(38,20)
Declare @intFromItemUOMId int

If ISNULL(@intContractDetailId,0)=0
Begin
	Select @dblCost=ISNULL(dblCost,0),@intItemStockUOMId=intStockItemUOMId 
	From vyuMFGetItemByLocation Where intItemId=@intItemId AND intLocationId=@intLocationId

	Select @dblCostInTargetUOM=dbo.fnMFConvertCostToTargetItemUOM(@intItemStockUOMId,@intToItemUOMId,@dblCost)

	Set @dblCostInTargetUOM=ISNULL(@dblCostInTargetUOM,0)
End
Else
Begin
	Select @dblCashPriceInStockUOM=dblCashPriceInStockUOM,@intFromItemUOMId=intStockUOMId From vyuCTContractDetailView Where intContractDetailId=@intContractDetailId
	Select @dblUnitQtyFrom=ISNULL(dblUnitQty,1) From tblICItemUOM Where intItemUOMId=@intFromItemUOMId
	Select @dblUnitQtyTo=ISNULL(dblUnitQty,1) From tblICItemUOM Where intItemUOMId=@intToItemUOMId

	Set @dblCostInTargetUOM = @dblCashPriceInStockUOM / (@dblUnitQtyFrom/@dblUnitQtyTo)
	Set @dblCostInTargetUOM=ISNULL(@dblCostInTargetUOM,0)
End