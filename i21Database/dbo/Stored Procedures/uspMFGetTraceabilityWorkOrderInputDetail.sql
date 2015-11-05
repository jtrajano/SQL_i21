﻿CREATE PROCEDURE [dbo].[uspMFGetTraceabilityWorkOrderInputDetail]
	@intWorkOrderId int
AS
	Select 'Consume' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
	t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
	MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId,'L' AS strType
	FROM (  
	Select DISTINCT 'Consume' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
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
	Where wi.intWorkOrderId=@intWorkOrderId) t
	group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,t.strCategoryCode,t.intLotId,t.strLotNumber,t.strLotAlias,t.intParentLotId