CREATE PROCEDURE [dbo].[uspMFGetTraceabilityWorkOrderInputDetail]
	@intWorkOrderId int,
	@ysnParentLot bit=0
AS
	If @ysnParentLot=0
		Select 'Consume' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId,'L' AS strType,t.intAttributeTypeId,t.intImageTypeId
		FROM (  
		Select DISTINCT 'Consume' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,wi.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,l.intParentLotId,ps.intAttributeTypeId,
		Case When l.strReceiptNumber IS NOT NULL THEN 2 Else 4 End AS intImageTypeId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderConsumedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblICLot l on wi.intLotId=l.intLotId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where wi.intWorkOrderId=@intWorkOrderId) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,intCategoryId,t.strCategoryCode,t.intLotId,t.strLotNumber,
		t.strLotAlias,t.intParentLotId,t.intAttributeTypeId,t.intImageTypeId
		UNION --Item Tracked
		Select 'Consume' AS strTransactionName,t.intLotId,t.strLotNumber,'' strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,'' intParentLotId,'IT' AS strType,t.intAttributeTypeId,t.intImageTypeId
		FROM (  
		Select DISTINCT 'Consume' AS strTransactionName,wi.intWorkOrderConsumedLotId AS intLotId,i.strItemNo AS strLotNumber,'' strLotAlias,
		i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,wi.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,null intParentLotId,ps.intAttributeTypeId,
		2 AS intImageTypeId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderConsumedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Left Join tblICItem i on wi.intItemId=i.intItemId
		Left Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Left Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Left Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where wi.intWorkOrderId=@intWorkOrderId AND ISNULL(wi.intLotId,0)=0) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,intCategoryId,t.strCategoryCode,t.intLotId,t.strLotNumber,
		t.intAttributeTypeId,t.intImageTypeId

	If @ysnParentLot=1
		Select 'Consume' AS strTransactionName,t.intLotId,t.strLotNumber,t.strLotAlias,t.intItemId,t.strItemNo,t.strDescription,
		t.intCategoryId,t.strCategoryCode,SUM(t.dblQuantity) AS dblQuantity,MAX(t.strUOM) AS strUOM,
		MAX(t.dtmTransactionDate) AS dtmTransactionDate,t.intParentLotId,'L' AS strType,t.intAttributeTypeId,t.intImageTypeId
		FROM (  
		Select DISTINCT 'Consume' AS strTransactionName,pl.intParentLotId AS intLotId, pl.strParentLotNumber AS strLotNumber,pl.strParentLotAlias AS strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
		mt.intCategoryId,mt.strCategoryCode,wi.dblQuantity,um.strUnitMeasure AS strUOM,
		wi.dtmCreated AS dtmTransactionDate,l.intParentLotId,ps.intAttributeTypeId,
		Case When l.strReceiptNumber IS NOT NULL THEN 2 Else 4 End AS intImageTypeId
		from tblMFWorkOrder w 
		Join tblMFWorkOrderConsumedLot wi on w.intWorkOrderId=wi.intWorkOrderId
		Join tblICLot l on wi.intLotId=l.intLotId
		Join tblMFManufacturingProcess ps on ps.intManufacturingProcessId=w.intManufacturingProcessId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
		Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
		Where wi.intWorkOrderId=@intWorkOrderId) t
		group by t.strTransactionName,t.intItemId,t.strItemNo,t.strDescription,intCategoryId,t.strCategoryCode,t.intLotId,t.strLotNumber,
		t.strLotAlias,t.intParentLotId,t.intAttributeTypeId,t.intImageTypeId