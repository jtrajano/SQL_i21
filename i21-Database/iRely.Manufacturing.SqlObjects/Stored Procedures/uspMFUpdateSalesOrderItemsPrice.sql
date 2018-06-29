CREATE PROCEDURE [dbo].[uspMFUpdateSalesOrderItemsPrice]
	@intSalesOrderId int,
	@intUserId int
AS

Declare @intMinRecipe INT
Declare @intRecipeId INT
Declare @intLocationId int
Declare @dblQuantity numeric(38,20)
Declare @intCostTypeId int
Declare @intMarginById int
Declare @dblMargin numeric(38,20)

Declare @tblRecipe AS Table
(
 intRowNo int IDENTITY,	
 intRecipeId int
)

Declare @tblRecipeItems AS Table
(
	[intRecipeId] [int] NULL,
	[intRecipeItemId] [int] NULL,
	[intItemId] [int] NULL,
	[strItemNo] [nvarchar](50) NULL,
	[strItemDescription] [nvarchar](250) NULL,
	[strItemType] [nvarchar](50) NULL,
	[dblQuantity] [numeric](38, 20) NULL,
	[dblCalculatedQuantity] [numeric](38, 20) NULL,
	[intItemUOMId] [int] NULL,
	[strUOM] [nvarchar](50) NULL,
	[intMarginById] [int] NULL,
	[strMarginBy] [nvarchar](50) NULL,
	[dblMargin] [numeric](38, 20) NULL,
	[dblCost] [numeric](38, 20) NULL,
	[intCostSourceId] [int] NULL,
	[strCostSource] [varchar](50) NULL,
	[dblRetailPrice] [numeric](38, 20) NULL,
	[dblUnitQty] [numeric](38, 20) NULL,
	[dblCalculatedLowerTolerance] [numeric](38, 20) NULL,
	[dblCalculatedUpperTolerance] [numeric](38, 20) NULL,
	[dblLowerTolerance] [numeric](38, 20) NULL,
	[dblUpperTolerance] [numeric](38, 20) NULL,
	[intCommentTypeId] [int] NULL,
	[strCommentType] [nvarchar](50) NULL,
	[intContractHeaderId] [int] NULL,
	[intContractDetailId] [int] NULL,
	[strContractNumber] [nvarchar](50) NULL,
	[intContractSeq] [int] NULL,
	[strSequenceNumber] [nvarchar](100) NULL,
	[dblStandardCost] [numeric](38, 20) NULL,
	[dblUnitMargin] [numeric](38, 20) NULL,
	[intSequenceNo] [int] NULL,
	[strDocumentNo] [nvarchar](100) NULL,
	[dblCostCopy] [numeric](38, 20) NULL
)

Select @intLocationId=intCompanyLocationId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId

Insert Into @tblRecipe(intRecipeId)
select distinct intRecipeId from tblSOSalesOrderDetail where intSalesOrderId=@intSalesOrderId AND intRecipeId>0

Select @intMinRecipe=Min(intRowNo) From @tblRecipe
While(@intMinRecipe is not null)
Begin
	Select @intRecipeId=intRecipeId From @tblRecipe Where intRowNo=@intMinRecipe

	Select TOP 1 @dblQuantity=dblRecipeQuantity,@intCostTypeId=intCostTypeId,@intMarginById=intMarginById,@dblMargin=dblMargin
	From tblSOSalesOrderDetail Where intSalesOrderId=@intRecipeId AND intSalesOrderId=@intSalesOrderId

	Insert Into @tblRecipeItems
	Exec [uspMFGetRecipeItems] @intRecipeId,@intLocationId,@dblQuantity,@intCostTypeId,@intMarginById,@dblMargin,@intSalesOrderId

	Select @intMinRecipe=Min(intRowNo) From @tblRecipe Where intRowNo>@intMinRecipe
End

Update @tblRecipeItems
Set dblCost=dblCost + ((dblMargin*dblCost) / 100) Where intMarginById=1 AND intCostSourceId=1

Update @tblRecipeItems
Set dblCost=dblCost + dblMargin Where intMarginById=2 AND intCostSourceId=1

Update sd Set sd.dblPrice=ri.dblCost,sd.dblTotal=sd.dblQtyOrdered * ri.dblCost
From tblSOSalesOrderDetail sd Join @tblRecipeItems ri on sd.intRecipeItemId=ri.intRecipeItemId
Where sd.intSalesOrderId=@intSalesOrderId AND ISNULL(sd.intContractDetailId,0)=0 AND ISNULL(sd.intStorageScheduleTypeId,0)=0