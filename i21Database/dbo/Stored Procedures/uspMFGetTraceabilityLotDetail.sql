CREATE PROCEDURE [dbo].[uspMFGetTraceabilityLotDetail]
	@intLotId int,
	@intDirectionId int,
	@ysnParentLot bit=0
AS

SET NOCOUNT ON;

Declare @strLotNumber nvarchar(50)

Select @strLotNumber=strLotNumber From tblICLot Where intLotId=@intLotId

if @intDirectionId=1
Begin
	If Exists(Select 1 from tblMFWorkOrderConsumedLot where intLotId IN (Select intLotId From tblICLot Where strLotNumber=@strLotNumber)) AND @ysnParentLot=0
		Select 'Receipt' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId,2 AS intImageTypeId
		FROM (  
		Select DISTINCT '' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,wi.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,l.intParentLotId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderConsumedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblICLot l on wi.intLotId=l.intLotId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where wi.intLotId IN (Select intLotId From tblICLot Where strLotNumber=@strLotNumber)) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,t.intCategoryId,t.strCategoryCode,t.intLotId,t.strLotNumber,t.strLotAlias,t.intParentLotId

	If Exists(Select 1 from tblMFWorkOrderConsumedLot where intLotId in (Select intLotId From tblICLot Where intParentLotId=@intLotId)) AND @ysnParentLot=1
		Select 'Receipt' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId,2 AS intImageTypeId
		FROM (  
		Select DISTINCT '' AS strTransactionName,@intLotId intLotId,pl.strParentLotNumber AS strLotNumber,pl.strParentLotAlias AS strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,wi.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,l.intParentLotId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderConsumedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblICLot l on wi.intLotId=l.intLotId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
		Where l.intParentLotId=@intLotId) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,t.intCategoryId,t.strCategoryCode,t.intLotId,t.strLotNumber,t.strLotAlias,t.intParentLotId
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
	If Exists(Select 1 from tblMFWorkOrderProducedLot where intLotId IN (Select intLotId From tblICLot Where strLotNumber=@strLotNumber)) AND @ysnParentLot=0
		Select 'Ship' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId,6 AS intImageTypeId
		FROM (  
		Select DISTINCT '' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,wi.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,l.intParentLotId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderProducedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblICLot l on wi.intLotId=l.intLotId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where wi.intLotId IN (Select intLotId From tblICLot Where strLotNumber=@strLotNumber)) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,t.intCategoryId,t.strCategoryCode,t.intLotId,t.strLotNumber,t.strLotAlias,t.intParentLotId

	If Exists(Select 1 from tblMFWorkOrderProducedLot where intLotId in (Select intLotId From tblICLot Where intParentLotId=@intLotId)) AND @ysnParentLot=1
		Select 'Ship' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId,6 AS intImageTypeId
		FROM (  
		Select DISTINCT '' AS strTransactionName,@intLotId intLotId,pl.strParentLotNumber AS strLotNumber,pl.strParentLotAlias AS strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,wi.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,l.intParentLotId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderProducedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblICLot l on wi.intLotId=l.intLotId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
		Where l.intParentLotId=@intLotId) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,t.intCategoryId,t.strCategoryCode,t.intLotId,t.strLotNumber,t.strLotAlias,t.intParentLotId
End
