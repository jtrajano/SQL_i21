CREATE PROCEDURE [dbo].[uspMFGetBlendSheetItemUOMs]
	@intItemId int,
	@strUnitType nvarchar(50),
	@intItemUOMId int,
	@strUnitMeasure nvarchar(50)
AS

Declare @tblItemUOM As table
(
	intItemId int,
	intItemUOMId int,
	intUnitMeasureId int,
	strUnitMeasure nvarchar(50),
	dblWeightPerUnit numeric(18,6)
)
if @strUnitType='All'
	insert into @tblItemUOM(intItemId,intItemUOMId,intUnitMeasureId,strUnitMeasure,dblWeightPerUnit)
	Select i.intItemId,iu.intItemUOMId AS intItemUOMId,
	iu.intUnitMeasureId,um.strUnitMeasure AS strUnitMeasure,
	iu.dblUnitQty AS dblWeightPerUnit
	From tblICItem i Join tblICItemUOM iu on i.intItemId=iu.intItemId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
	Where i.intItemId=@intItemId
Else
	insert into @tblItemUOM(intItemId,intItemUOMId,intUnitMeasureId,strUnitMeasure,dblWeightPerUnit)
	Select i.intItemId,iu.intItemUOMId AS intItemUOMId,
	iu.intUnitMeasureId,um.strUnitMeasure AS strUnitMeasure,
	iu.dblUnitQty AS dblWeightPerUnit
	From tblICItem i Join tblICItemUOM iu on i.intItemId=iu.intItemId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
	Where i.intItemId=@intItemId And um.strUnitType=@strUnitType

	If @intItemUOMId > 0
			Select TOP 1 * from @tblItemUOM Where intItemUOMId=@intItemUOMId
	Else if @strUnitMeasure <> ''
			Select TOP 1 * from @tblItemUOM Where strUnitMeasure=@strUnitMeasure
	Else
			Select * from @tblItemUOM