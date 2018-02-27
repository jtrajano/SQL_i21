CREATE PROCEDURE [dbo].[uspMFGetKits]
	@intKitStatusId int,
	@intBlendRequirementId int,
	@intWorkOrderId int
AS

If @intKitStatusId = -1 and @intWorkOrderId = -1 --Kit Status _All , Work Order _All
	Select w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
	w.dblQuantity,um.strUnitMeasure AS strUOM,w.intBlendRequirementId,br.strDemandNo,w.dtmExpectedDate AS dtmDueDate,
	w.intLocationId,cl.strLocationName,w.intStatusId,ws.strName AS strBlendSheetStatus,w.intKitStatusId,ks.strName AS strKitStatus,
	mc.strCellName,w.intExecutionOrder, ISNULL(pl.intPickListId,0) AS intPickListId, pl.strPickListNo , sl.strName AS strStagingLocationName, w.dtmStagedDate AS dtmTransferDate,
	mc.intManufacturingCellId,w.intManufacturingProcessId,sl1.intStorageLocationId AS intDefaultStagingLocationId,sl1.strName AS strDefaultStagingLocation,
	sbl1.intCompanyLocationSubLocationId AS intDefaultStagingSubLocationId,sbl1.strSubLocationName AS strDefaultStagingSubLocation,
	CAST(CASE WHEN pa1.strAttributeValue='True' THEN 1 ELSE 0 End AS BIT) AS ysnDirectTransferToBlendFloor,CASE WHEN pa2.strAttributeValue>0 THEN CAST(pa2.strAttributeValue AS int) Else 0 End AS intKitStagingLocationId 
	from tblMFWorkOrder w 
	Join tblMFBlendRequirement br on w.intBlendRequirementId=br.intBlendRequirementId 
	Join tblICItem i on w.intItemId=i.intItemId
	Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId  
	Join tblSMCompanyLocation cl on w.intLocationId=cl.intCompanyLocationId
	Join tblMFWorkOrderStatus ws on w.intStatusId=ws.intStatusId
	Join tblMFWorkOrderStatus ks on w.intKitStatusId=ks.intStatusId
	Join tblMFManufacturingCell mc on w.intManufacturingCellId=mc.intManufacturingCellId
	Left Join tblICStorageLocation sl on w.intStagingLocationId=sl.intStorageLocationId
	Left Join tblMFPickList pl on w.intPickListId=pl.intPickListId
	Left Join tblMFManufacturingProcessAttribute pa on w.intManufacturingProcessId=pa.intManufacturingProcessId AND pa.intLocationId=w.intLocationId AND pa.intAttributeId=75
	Left Join tblICStorageLocation sl1 on pa.strAttributeValue=sl1.intStorageLocationId
	Left Join tblSMCompanyLocationSubLocation sbl1 on sl1.intSubLocationId=sbl1.intCompanyLocationSubLocationId
	Left Join tblMFManufacturingProcessAttribute pa1 on w.intManufacturingProcessId=pa1.intManufacturingProcessId AND pa1.intLocationId=w.intLocationId AND pa1.intAttributeId=72
	Left Join tblMFManufacturingProcessAttribute pa2 on w.intManufacturingProcessId=pa2.intManufacturingProcessId AND pa2.intLocationId=w.intLocationId AND pa2.intAttributeId=36
	Where w.intBlendRequirementId=@intBlendRequirementId 
	And w.ysnKittingEnabled=1 And w.intKitStatusId is not null And w.intStatusId in (9,10,12)

If @intKitStatusId = -1 and @intWorkOrderId > 0 --Kit Status _All , Selected Work Order
	Select w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
	w.dblQuantity,um.strUnitMeasure AS strUOM,w.intBlendRequirementId,br.strDemandNo,w.dtmExpectedDate AS dtmDueDate,
	w.intLocationId,cl.strLocationName,w.intStatusId,ws.strName AS strBlendSheetStatus,w.intKitStatusId,ks.strName AS strKitStatus,
	mc.strCellName,w.intExecutionOrder, ISNULL(pl.intPickListId,0) AS intPickListId, pl.strPickListNo , sl.strName AS strStagingLocationName, w.dtmStagedDate AS dtmTransferDate,
	mc.intManufacturingCellId,w.intManufacturingProcessId,sl1.intStorageLocationId AS intDefaultStagingLocationId,sl1.strName AS strDefaultStagingLocation,
	sbl1.intCompanyLocationSubLocationId AS intDefaultStagingSubLocationId,sbl1.strSubLocationName AS strDefaultStagingSubLocation,
	CAST(CASE WHEN pa1.strAttributeValue='True' THEN 1 ELSE 0 End AS BIT) AS ysnDirectTransferToBlendFloor,CASE WHEN pa2.strAttributeValue>0 THEN CAST(pa2.strAttributeValue AS int) Else 0 End AS intKitStagingLocationId  
	from tblMFWorkOrder w 
	Join tblMFBlendRequirement br on w.intBlendRequirementId=br.intBlendRequirementId 
	Join tblICItem i on w.intItemId=i.intItemId
	Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId  
	Join tblSMCompanyLocation cl on w.intLocationId=cl.intCompanyLocationId
	Join tblMFWorkOrderStatus ws on w.intStatusId=ws.intStatusId
	Join tblMFWorkOrderStatus ks on w.intKitStatusId=ks.intStatusId
	Join tblMFManufacturingCell mc on w.intManufacturingCellId=mc.intManufacturingCellId
	Left Join tblICStorageLocation sl on w.intStagingLocationId=sl.intStorageLocationId
	Left Join tblMFPickList pl on w.intPickListId=pl.intPickListId
	Left Join tblMFManufacturingProcessAttribute pa on w.intManufacturingProcessId=pa.intManufacturingProcessId AND pa.intLocationId=w.intLocationId AND pa.intAttributeId=75
	Left Join tblICStorageLocation sl1 on pa.strAttributeValue=sl1.intStorageLocationId
	Left Join tblSMCompanyLocationSubLocation sbl1 on sl1.intSubLocationId=sbl1.intCompanyLocationSubLocationId
	Left Join tblMFManufacturingProcessAttribute pa1 on w.intManufacturingProcessId=pa1.intManufacturingProcessId AND pa1.intLocationId=w.intLocationId AND pa1.intAttributeId=72
	Left Join tblMFManufacturingProcessAttribute pa2 on w.intManufacturingProcessId=pa2.intManufacturingProcessId AND pa2.intLocationId=w.intLocationId AND pa2.intAttributeId=36
	Where w.intBlendRequirementId=@intBlendRequirementId And w.intWorkOrderId=@intWorkOrderId 
	And w.ysnKittingEnabled=1 And w.intKitStatusId is not null And w.intStatusId in (9,10,12)

If @intKitStatusId > 0 and @intWorkOrderId = -1 --Any Kit Status , Work Order _All
	Select w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
	w.dblQuantity,um.strUnitMeasure AS strUOM,w.intBlendRequirementId,br.strDemandNo,w.dtmExpectedDate AS dtmDueDate,
	w.intLocationId,cl.strLocationName,w.intStatusId,ws.strName AS strBlendSheetStatus,w.intKitStatusId,ks.strName AS strKitStatus,
	mc.strCellName,w.intExecutionOrder, ISNULL(pl.intPickListId,0) AS intPickListId, pl.strPickListNo , sl.strName AS strStagingLocationName, w.dtmStagedDate AS dtmTransferDate,
	mc.intManufacturingCellId,w.intManufacturingProcessId,sl1.intStorageLocationId AS intDefaultStagingLocationId,sl1.strName AS strDefaultStagingLocation,
	sbl1.intCompanyLocationSubLocationId AS intDefaultStagingSubLocationId,sbl1.strSubLocationName AS strDefaultStagingSubLocation,
	CAST(CASE WHEN pa1.strAttributeValue='True' THEN 1 ELSE 0 End AS BIT) AS ysnDirectTransferToBlendFloor,CASE WHEN pa2.strAttributeValue>0 THEN CAST(pa2.strAttributeValue AS int) Else 0 End AS intKitStagingLocationId  
	from tblMFWorkOrder w 
	Join tblMFBlendRequirement br on w.intBlendRequirementId=br.intBlendRequirementId 
	Join tblICItem i on w.intItemId=i.intItemId
	Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId  
	Join tblSMCompanyLocation cl on w.intLocationId=cl.intCompanyLocationId
	Join tblMFWorkOrderStatus ws on w.intStatusId=ws.intStatusId
	Join tblMFWorkOrderStatus ks on w.intKitStatusId=ks.intStatusId
	Join tblMFManufacturingCell mc on w.intManufacturingCellId=mc.intManufacturingCellId
	Left Join tblICStorageLocation sl on w.intStagingLocationId=sl.intStorageLocationId
	Left Join tblMFPickList pl on w.intPickListId=pl.intPickListId
	Left Join tblMFManufacturingProcessAttribute pa on w.intManufacturingProcessId=pa.intManufacturingProcessId AND pa.intLocationId=w.intLocationId AND pa.intAttributeId=75
	Left Join tblICStorageLocation sl1 on pa.strAttributeValue=sl1.intStorageLocationId
	Left Join tblSMCompanyLocationSubLocation sbl1 on sl1.intSubLocationId=sbl1.intCompanyLocationSubLocationId
	Left Join tblMFManufacturingProcessAttribute pa1 on w.intManufacturingProcessId=pa1.intManufacturingProcessId AND pa1.intLocationId=w.intLocationId AND pa1.intAttributeId=72
	Left Join tblMFManufacturingProcessAttribute pa2 on w.intManufacturingProcessId=pa2.intManufacturingProcessId AND pa2.intLocationId=w.intLocationId AND pa2.intAttributeId=36
	Where w.intBlendRequirementId=@intBlendRequirementId And w.intKitStatusId=@intKitStatusId 
	And w.ysnKittingEnabled=1 And w.intKitStatusId is not null And w.intStatusId in (9,10,12)