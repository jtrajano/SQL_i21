CREATE PROCEDURE [dbo].[uspMFGetBlendSheetLotUOMs]
	@intLotId int
AS
Select l.intLotId,l.intWeightUOMId AS intItemUOMId,
iu.intUnitMeasureId,um.strUnitMeasure AS strUnitMeasure,
1 AS dblWeightPerUnit
From tblICLot l Join tblICItemUOM iu on l.intWeightUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
Where intLotId=@intLotId And ISNULL(l.intWeightUOMId,0) <> 0
UNION
Select l.intLotId,l.intWeightUOMId AS intItemUOMId,
iu.intUnitMeasureId,um.strUnitMeasure AS strUnitMeasure,
Case When ISNULL(l.intWeightUOMId,0) <> 0 Then l.dblWeightPerQty Else 1 End AS dblWeightPerUnit
From tblICLot l Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
Where intLotId=@intLotId

