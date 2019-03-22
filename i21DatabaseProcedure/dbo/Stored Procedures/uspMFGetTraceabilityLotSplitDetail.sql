CREATE PROCEDURE [dbo].[uspMFGetTraceabilityLotSplitDetail]
	@intLotId int,
	@intDirectionId int,
	@ysnParentLot bit=0
AS

Declare @strLotNumber nvarchar(50)

Select @strLotNumber=strLotNumber From tblICLot Where intLotId=@intLotId

if @intDirectionId=1
Begin
	If @ysnParentLot=0
		Select 'Split' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,l.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,l.dblQty AS dblQuantity,
		um.strUnitMeasure AS strUOM,
		l.dtmDateCreated AS dtmTransactionDate,l.intParentLotId,'L',2 AS intImageTypeId
		from tblICLot l
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where l.intSplitFromLotId IN (Select intLotId From tblICLot Where strLotNumber=@strLotNumber) AND l.strLotNumber <> @strLotNumber

	If @ysnParentLot=1
		Select 'Split' AS strTransactionName,pl.intParentLotId,pl.strParentLotNumber,pl.strParentLotAlias,l.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,l.dblQty AS dblQuantity,
		um.strUnitMeasure AS strUOM,
		l.dtmDateCreated AS dtmTransactionDate,l.intParentLotId,'L',2 AS intImageTypeId
		from tblICLot l
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
		Where l.intSplitFromLotId IN (Select intLotId From tblICLot Where strLotNumber=@strLotNumber) AND l.strLotNumber <> @strLotNumber
End

if @intDirectionId=2
Begin
	If @ysnParentLot=0
		Select 'Split' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,l.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,l.dblQty AS dblQuantity,
		um.strUnitMeasure AS strUOM,
		l.dtmDateCreated AS dtmTransactionDate,l.intParentLotId,'L',2 AS intImageTypeId
		from tblICLot l
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where l.intLotId = (Select intSplitFromLotId From tblICLot Where intLotId=@intLotId) AND l.strLotNumber <> @strLotNumber

	If @ysnParentLot=1
		Select 'Split' AS strTransactionName,pl.intParentLotId,pl.strParentLotNumber,pl.strParentLotAlias,l.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,l.dblQty AS dblQuantity,
		um.strUnitMeasure AS strUOM,
		l.dtmDateCreated AS dtmTransactionDate,l.intParentLotId,'L',2 AS intImageTypeId
		from tblICLot l
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
		Where l.intLotId = (Select intSplitFromLotId From tblICLot Where intLotId=@intLotId) AND l.strLotNumber <> @strLotNumber
End
