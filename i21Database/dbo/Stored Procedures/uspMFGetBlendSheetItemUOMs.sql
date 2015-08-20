CREATE PROCEDURE [dbo].[uspMFGetBlendSheetItemUOMs]
	@intItemId int,
	@strUnitType nvarchar(50)
AS
Select i.intItemId,iu.intItemUOMId AS intItemUOMId,
iu.intUnitMeasureId,um.strUnitMeasure AS strUnitMeasure,
iu.dblUnitQty AS dblWeightPerUnit
From tblICItem i Join tblICItemUOM iu on i.intItemId=iu.intItemId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
Where i.intItemId=@intItemId And um.strUnitType=@strUnitType


