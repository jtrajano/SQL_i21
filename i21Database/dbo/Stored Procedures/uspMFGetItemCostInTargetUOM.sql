CREATE PROCEDURE [dbo].[uspMFGetItemCostInTargetUOM]
	@intItemId int,
	@intLocationId int,
	@intToItemUOMId int,
	@intContractDetailId int,
	@intCostTypeId int,
	@dblCostInTargetUOM NUMERIC(38,20) OUT
AS

Declare @dblCost NUMERIC(38,20)
Declare @intItemStockUOMId int
Declare @dblCashPriceInStockUOM NUMERIC(38,20)
Declare @dblUnitQtyFrom NUMERIC(38,20)
Declare @dblUnitQtyTo NUMERIC(38,20)
Declare @intFromItemUOMId int

If ISNULL(@intCostTypeId,0)=0
	Set @intCostTypeId=1

If ISNULL(@intContractDetailId,0)=0
Begin
	Select TOP 1 @dblCost=CASE When @intCostTypeId=2 AND ISNULL(ip.dblAverageCost,0) > 0 THEN ISNULL(ip.dblAverageCost,0) 
				When @intCostTypeId=3 AND ISNULL(ip.dblLastCost,0) > 0 THEN ISNULL(ip.dblLastCost,0)
				Else ISNULL(ip.dblStandardCost,0) End
	From tblICItemPricing ip Join tblICItemLocation il on ip.intItemLocationId=il.intItemLocationId 
	Where ip.intItemId=@intItemId AND il.intLocationId=@intLocationId

	Select TOP 1 @intItemStockUOMId=intItemUOMId
	From tblICItemUOM Where intItemId=@intItemId AND ysnStockUnit=1

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