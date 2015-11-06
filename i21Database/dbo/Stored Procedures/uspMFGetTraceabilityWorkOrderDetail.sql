CREATE PROCEDURE [dbo].[uspMFGetTraceabilityWorkOrderDetail]
	@intLotId int,
	@intDirectionId int
AS

SET NOCOUNT ON;

IF @intDirectionId=1
	Select 'Consume' AS strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,
	t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
	MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.strProcessName,'W' AS strType
	FROM (  
	Select DISTINCT 'Consume' AS strTransactionName,wi.intLotId,w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
	mt.strCategoryCode,w.dblQuantity,um.strUnitMeasure AS strUOM,
	wi.dtmCreated AS dtmTransactionDate,ps.strProcessName
	from tblMFWorkOrder w 
	Join tblMFWorkOrderConsumedLot wi on w.intWorkOrderId=wi.intWorkOrderId
	Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
	Join tblICItem i on w.intItemId=i.intItemId
	Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
	Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Where wi.intLotId=@intLotId) t
	group by t.strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,t.strCategoryCode,t.intLotId,t.strProcessName
ELSE
	Select 'Produce' AS strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,
	t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
	MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.strProcessName,'W' AS strType
	FROM (  
	Select DISTINCT 'Produce' AS strTransactionName,wi.intLotId,w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
	mt.strCategoryCode,w.dblQuantity,um.strUnitMeasure AS strUOM,
	wi.dtmCreated AS dtmTransactionDate,ps.strProcessName
	from tblMFWorkOrder w 
	Join tblMFWorkOrderProducedLot wi on w.intWorkOrderId=wi.intWorkOrderId
	Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
	Join tblICItem i on w.intItemId=i.intItemId
	Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
	Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Where wi.intLotId=@intLotId) t
	group by t.strTransactionName,t.intWorkOrderId,t.strWorkOrderNo,t.intItemId,t.strItemNo,t.strDescription,t.strCategoryCode,t.intLotId,t.strProcessName
