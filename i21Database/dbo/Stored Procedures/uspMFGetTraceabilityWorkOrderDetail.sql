CREATE PROCEDURE [dbo].[uspMFGetTraceabilityWorkOrderDetail]
	@intLotId int,
	@intDirectionId int,
	@ysnParentLot bit=0
AS

SET NOCOUNT ON;

Declare @strLotNumber nvarchar(50)

Select @strLotNumber=strLotNumber From tblICLot Where intLotId=@intLotId

IF @intDirectionId=1
	Begin
	If @ysnParentLot=0
		Select 'Consume' AS strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.strProcessName,'W' AS strType,t.intAttributeTypeId
		FROM (  
		Select DISTINCT 'Consume' AS strTransactionName,wi.intLotId,w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,w.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,ps.strProcessName,ps.intAttributeTypeId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderConsumedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Join tblICItem i on w.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where wi.intLotId IN (Select intLotId From tblICLot Where strLotNumber=@strLotNumber)) t
		group by t.strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,t.intCategoryId,t.strCategoryCode,
		t.intLotId,t.strProcessName,t.intAttributeTypeId

	If @ysnParentLot=1
		Select 'Consume' AS strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.strProcessName,'W' AS strType,t.intAttributeTypeId
		FROM (  
		Select DISTINCT 'Consume' AS strTransactionName,l.intParentLotId AS intLotId,w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,w.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,ps.strProcessName,ps.intAttributeTypeId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderConsumedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Join tblICItem i on w.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICLot l on wi.intLotId=l.intLotId
		Where l.intParentLotId=@intLotId) t
		group by t.strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,t.intCategoryId,t.strCategoryCode,
		t.intLotId,t.strProcessName,t.intAttributeTypeId
	End
ELSE
	Begin
		If @ysnParentLot=0
			Select 'Produce' AS strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,
			t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
			MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.strProcessName,'W' AS strType,t.intAttributeTypeId
			FROM (  
			Select DISTINCT 'Produce' AS strTransactionName,wi.intLotId,w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
			mt.intCategoryId,mt.strCategoryCode,w.dblQuantity,um.strUnitMeasure AS strUOM,
			wi.dtmCreated AS dtmTransactionDate,ps.strProcessName,ps.intAttributeTypeId
			from tblMFWorkOrder w 
			Join tblMFWorkOrderProducedLot wi on w.intWorkOrderId=wi.intWorkOrderId
			Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
			Join tblICItem i on w.intItemId=i.intItemId
			Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
			Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
			Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
			Where wi.intLotId IN (Select intLotId From tblICLot Where strLotNumber=@strLotNumber)) t
			group by t.strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,t.intCategoryId,t.strCategoryCode,
			t.intLotId,t.strProcessName,t.intAttributeTypeId

		If @ysnParentLot=1
			Select 'Produce' AS strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,
			t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
			MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.strProcessName,'W' AS strType,t.intAttributeTypeId
			FROM (  
			Select DISTINCT 'Produce' AS strTransactionName,l.intParentLotId AS intLotId,w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
			mt.intCategoryId,mt.strCategoryCode,w.dblQuantity,um.strUnitMeasure AS strUOM,
			wi.dtmCreated AS dtmTransactionDate,ps.strProcessName,ps.intAttributeTypeId
			from tblMFWorkOrder w 
			Join tblMFWorkOrderProducedLot wi on w.intWorkOrderId=wi.intWorkOrderId
			Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
			Join tblICItem i on w.intItemId=i.intItemId
			Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
			Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
			Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
			Join tblICLot l on wi.intLotId=l.intLotId
			Where l.intParentLotId=@intLotId) t
			group by t.strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,t.intCategoryId,t.strCategoryCode,
			t.intLotId,t.strProcessName,t.intAttributeTypeId
	End