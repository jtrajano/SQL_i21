CREATE PROCEDURE [dbo].[uspMFGetTraceabilityLotDetail]
	@intLotId int,
	@intDirectionId int
AS

SET NOCOUNT ON;

if @intDirectionId=1
Begin
	If Exists(Select 1 from tblMFWorkOrderConsumedLot where intLotId=@intLotId)
		Select 'Receipt' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId
		FROM (  
		Select DISTINCT '' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
		mt.strCategoryCode,wi.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,l.intParentLotId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderConsumedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblICLot l on wi.intLotId=l.intLotId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where wi.intLotId=@intLotId) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,t.strCategoryCode,t.intLotId,t.strLotNumber,t.strLotAlias,t.intParentLotId
	--ELSE
	--	Select 'Receipt' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.strItemNo,i.strDescription,
	--	mt.strCategoryCode,CASE WHEN l.intWeightUOMId is null then rm.dblQuantity Else rm.dblGrossWeight End AS dblQuantity,
	--	CASE WHEN l.intWeightUOMId is null then um.strUnitMeasure Else um1.strUnitMeasure End AS strUOM,
	--	l.dtmDateCreated AS dtmTransactionDate,l.intParentLotId,v.strName
	--	from tblICInventoryLotTransaction lt  
	--	Join tblICLot l on lt.intLotId=l.intLotId
	--	Join tblICItem i on l.intItemId=i.intItemId
	--	Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
	--	Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
	--	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	--	Left Join tblICItemUOM iu1 on l.intWeightUOMId=iu1.intItemUOMId
	--	Left Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	--	Left Join vyuAPVendor v on l.intEntityVendorId=v.intEntityVendorId
	--	Where l.intLotId=@intLotId
End

if @intDirectionId=2
Begin
	If Exists(Select 1 from tblMFWorkOrderProducedLot where intLotId=@intLotId)
		Select 'Ship' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId
		FROM (  
		Select DISTINCT '' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
		mt.strCategoryCode,wi.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,l.intParentLotId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderProducedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblICLot l on wi.intLotId=l.intLotId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where wi.intLotId=@intLotId) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,t.strCategoryCode,t.intLotId,t.strLotNumber,t.strLotAlias,t.intParentLotId
End
