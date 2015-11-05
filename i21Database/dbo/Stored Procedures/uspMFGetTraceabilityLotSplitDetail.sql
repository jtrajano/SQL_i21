CREATE PROCEDURE [dbo].[uspMFGetTraceabilityLotSplitDetail]
	@intLotId int,
	@intDirectionId int
AS
if @intDirectionId=1
Begin
	Select 'Split' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.strItemNo,i.strDescription,
	mt.strCategoryCode,lt.dblQty AS dblQuantity,
	um.strUnitMeasure AS strUOM,
	l.dtmDateCreated AS dtmTransactionDate,l.intParentLotId
	from tblICInventoryLotTransaction lt  
	Join tblICLot l on lt.intLotId=l.intLotId
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
	Join tblICItemUOM iu on lt.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Where l.intSplitFromLotId=@intLotId And lt.intTransactionTypeId=17
End

if @intDirectionId=2
Begin
	Select 'Split' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.strItemNo,i.strDescription,
	mt.strCategoryCode,lt.dblQty AS dblQuantity,
	um.strUnitMeasure AS strUOM,
	l.dtmDateCreated AS dtmTransactionDate,l.intParentLotId
	from tblICInventoryLotTransaction lt  
	Join tblICLot l on lt.intLotId=l.intLotId
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
	Join tblICItemUOM iu on lt.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Where l.intSplitFromLotId=@intLotId
End
