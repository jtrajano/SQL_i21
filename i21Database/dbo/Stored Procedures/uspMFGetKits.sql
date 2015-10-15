CREATE PROCEDURE [dbo].[uspMFGetKits]
	@intKitStatusId int,
	@intBlendRequirementId int,
	@intWorkOrderId int
AS

If @intKitStatusId = -1 and @intWorkOrderId = -1
	Select w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
	w.dblQuantity,um.strUnitMeasure AS strUOM,w.intBlendRequirementId,br.strDemandNo,w.dtmExpectedDate AS dtmDueDate,
	w.intLocationId,cl.strLocationName,w.intStatusId,ws.strName AS strBlendSheetStatus,w.intKitStatusId,ks.strName AS strKitStatus,
	mc.strCellName,w.intExecutionOrder, ISNULL(pl.intPickListId,0) AS intPickListId, pl.strPickListNo , sl.strName AS strStagingLocationName, w.dtmStagedDate AS dtmTransferDate 
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
	Where w.intBlendRequirementId=@intBlendRequirementId 
	And w.ysnKittingEnabled=1 And w.intKitStatusId is not null And w.intStatusId in (9,10,12)

If @intKitStatusId = -1 and @intWorkOrderId > 0
	Select w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
	w.dblQuantity,um.strUnitMeasure AS strUOM,w.intBlendRequirementId,br.strDemandNo,w.dtmExpectedDate AS dtmDueDate,
	w.intLocationId,cl.strLocationName,w.intStatusId,ws.strName AS strBlendSheetStatus,w.intKitStatusId,ks.strName AS strKitStatus,
	mc.strCellName,w.intExecutionOrder, ISNULL(pl.intPickListId,0) AS intPickListId, pl.strPickListNo , sl.strName AS strStagingLocationName, w.dtmStagedDate AS dtmTransferDate 
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
	Where w.intBlendRequirementId=@intBlendRequirementId And w.intWorkOrderId=@intWorkOrderId 
	And w.ysnKittingEnabled=1 And w.intKitStatusId is not null And w.intStatusId in (9,10,12)

If @intKitStatusId > 0 and @intWorkOrderId = -1
	Select w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,
	w.dblQuantity,um.strUnitMeasure AS strUOM,w.intBlendRequirementId,br.strDemandNo,w.dtmExpectedDate AS dtmDueDate,
	w.intLocationId,cl.strLocationName,w.intStatusId,ws.strName AS strBlendSheetStatus,w.intKitStatusId,ks.strName AS strKitStatus,
	mc.strCellName,w.intExecutionOrder, ISNULL(pl.intPickListId,0) AS intPickListId, pl.strPickListNo , sl.strName AS strStagingLocationName, w.dtmStagedDate AS dtmTransferDate 
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
	Where w.intBlendRequirementId=@intBlendRequirementId And w.intKitStatusId=@intKitStatusId 
	And w.ysnKittingEnabled=1 And w.intKitStatusId is not null And w.intStatusId in (9,10,12)