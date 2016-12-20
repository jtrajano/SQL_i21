CREATE PROCEDURE [dbo].[uspMFGetRecipeGuideSOItems]
	@intSalesOrderId int = 0,
	@intRecipeGuideId int = 0
AS

If @intRecipeGuideId>0
	Select TOP 1 @intSalesOrderId=intSalesOrderId From tblSOSalesOrder Where intRecipeGuideId=@intRecipeGuideId Order By intSalesOrderId Desc

If ISNULL(@intSalesOrderId,0)>0
Begin
	Select i.intItemId,i.strItemNo,i.strDescription,sd.dblQtyOrdered/rg.dblNoOfAcre AS dblQuantity,sd.intItemUOMId,um.strUnitMeasure AS strUOM,
	sd.dblPrice AS dblCost
	From tblSOSalesOrderDetail sd 
	Join tblICItem i on sd.intItemId=i.intItemId 
	Join tblICItemUOM iu on sd.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblSOSalesOrder s on sd.intSalesOrderId=s.intSalesOrderId
	Join tblMFRecipeGuide rg on s.intRecipeGuideId=rg.intRecipeGuideId
	Where s.intSalesOrderId=@intSalesOrderId

	Return
End
