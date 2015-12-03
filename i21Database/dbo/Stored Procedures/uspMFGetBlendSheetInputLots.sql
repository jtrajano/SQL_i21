﻿CREATE PROCEDURE [dbo].[uspMFGetBlendSheetInputLots]
@intWorkOrderId int
AS

Declare @dblRecipeQty numeric(18,6)
Declare @ysnEnableParentLot bit=0

Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference

Select TOP 1 @dblRecipeQty=r.dblQuantity 
from tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId 
Join tblMFWorkOrder w on r.intItemId=w.intItemId And r.intLocationId=w.intLocationId
where r.ysnActive=1

If @ysnEnableParentLot=0
Begin
	If (Select Count(1) From tblMFWorkOrderInputLot Where intWorkOrderId=@intWorkOrderId) >0
		Select wi.intWorkOrderInputLotId,wi.intWorkOrderId,wi.intLotId,wi.dblQuantity,
		wi.intItemUOMId,wi.dblIssuedQuantity,wi.intItemIssuedUOMId,
		l.dblWeightPerQty AS dblWeightPerUnit,wi.intSequenceNo,wi.dtmCreated,wi.intCreatedUserId,
		wi.dtmLastModified,wi.intLastModifiedUserId,cast(0 as bit) AS ysnParentLot,
		l.strLotNumber,i.intItemId,i.strItemNo,i.strDescription,um.strUnitMeasure AS strUOM,
		um1.strUnitMeasure AS strIssuedUOM,wi.intRecipeItemId,l.dblLastCost AS dblUnitCost,
		ISNULL(l.strLotAlias,'') AS strLotAlias,
		l.strGarden AS strGarden,l.intLocationId,
		cl.strLocationName AS strLocationName,
		sbl.strSubLocationName,
		sl.strName AS strStorageLocationName,
		l.strNotes AS strRemarks,
		i.dblRiskScore,
		ri.dblQuantity/@dblRecipeQty AS dblConfigRatio,
		CAST(ISNULL(q.Density,0) AS decimal) AS dblDensity,
		CAST(ISNULL(q.Score,0) AS decimal) AS dblScore
		From tblMFWorkOrderInputLot wi Join tblMFWorkOrder w on wi.intWorkOrderId=w.intWorkOrderId
		Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICLot l on wi.intLotId=l.intLotId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICItemUOM iu1 on wi.intItemIssuedUOMId=iu1.intItemUOMId
		Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
		Join tblSMCompanyLocation cl on cl.intCompanyLocationId=l.intLocationId
		Left Join tblSMCompanyLocationSubLocation sbl on sbl.intCompanyLocationSubLocationId=l.intSubLocationId
		Left Join tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
		Left Join vyuQMGetLotQuality q on l.intLotId=q.intLotId
		Left Join tblMFRecipeItem ri on wi.intRecipeItemId=ri.intRecipeItemId
		Where wi.intWorkOrderId=@intWorkOrderId
	Else -- When blend sheet created from Sales Order , directly produced in blend production screen, then only consumed lot table will have the values, to show in blend management screen from traceability
		Select wi.intWorkOrderConsumedLotId AS intWorkOrderInputLotId,wi.intWorkOrderId,wi.intLotId,wi.dblQuantity,
		wi.intItemUOMId,wi.dblIssuedQuantity,wi.intItemIssuedUOMId,
		l.dblWeightPerQty AS dblWeightPerUnit,wi.intSequenceNo,wi.dtmCreated,wi.intCreatedUserId,
		wi.dtmLastModified,wi.intLastModifiedUserId,cast(0 as bit) AS ysnParentLot,
		l.strLotNumber,i.intItemId,i.strItemNo,i.strDescription,um.strUnitMeasure AS strUOM,
		um1.strUnitMeasure AS strIssuedUOM,wi.intRecipeItemId,l.dblLastCost AS dblUnitCost,
		ISNULL(l.strLotAlias,'') AS strLotAlias,
		l.strGarden AS strGarden,l.intLocationId,
		cl.strLocationName AS strLocationName,
		sbl.strSubLocationName,
		sl.strName AS strStorageLocationName,
		l.strNotes AS strRemarks,
		i.dblRiskScore,
		ri.dblQuantity/@dblRecipeQty AS dblConfigRatio,
		CAST(ISNULL(q.Density,0) AS decimal) AS dblDensity,
		CAST(ISNULL(q.Score,0) AS decimal) AS dblScore
		From tblMFWorkOrderConsumedLot wi Join tblMFWorkOrder w on wi.intWorkOrderId=w.intWorkOrderId
		Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICLot l on wi.intLotId=l.intLotId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICItemUOM iu1 on wi.intItemIssuedUOMId=iu1.intItemUOMId
		Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
		Join tblSMCompanyLocation cl on cl.intCompanyLocationId=l.intLocationId
		Left Join tblSMCompanyLocationSubLocation sbl on sbl.intCompanyLocationSubLocationId=l.intSubLocationId
		Left Join tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
		Left Join vyuQMGetLotQuality q on l.intLotId=q.intLotId
		Left Join tblMFRecipeItem ri on wi.intRecipeItemId=ri.intRecipeItemId
		Where wi.intWorkOrderId=@intWorkOrderId
End
Else
Begin
	Select wi.intWorkOrderInputParentLotId AS intWorkOrderInputLotId,wi.intWorkOrderId,wi.intParentLotId AS intLotId,wi.dblQuantity,
	wi.intItemUOMId,wi.dblIssuedQuantity,wi.intItemIssuedUOMId,
	wi.dblWeightPerUnit,wi.intSequenceNo,wi.dtmCreated,wi.intCreatedUserId,
	wi.dtmLastModified,wi.intLastModifiedUserId,cast(1 as bit) AS ysnParentLot,
	pl.strParentLotNumber AS strLotNumber,i.intItemId,i.strItemNo,i.strDescription,um.strUnitMeasure AS strUOM,
	um1.strUnitMeasure AS strIssuedUOM,wi.intRecipeItemId,CAST(0 AS numeric(18,6)) AS dblUnitCost,
	ISNULL(pl.strParentLotAlias,'') AS strLotAlias,
	'' AS strGarden,wi.intLocationId,
	cl.strLocationName AS strLocationName,
	sbl.strSubLocationName,
	sl.strName AS strStorageLocationName,
	'' AS strRemarks,
	i.dblRiskScore,
	ri.dblQuantity/@dblRecipeQty AS dblConfigRatio,
	CAST(ISNULL(q.Density,0) AS decimal) AS dblDensity,
	CAST(ISNULL(q.Score,0) AS decimal) AS dblScore
	into #tblWorkOrderInputParent
	From tblMFWorkOrderInputParentLot wi Join tblMFWorkOrder w on wi.intWorkOrderId=w.intWorkOrderId
	Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICParentLot pl on wi.intParentLotId=pl.intParentLotId
	--Join tblICLot l on pl.intParentLotId=l.intParentLotId
	Join tblICItem i on pl.intItemId=i.intItemId
	Join tblICItemUOM iu1 on wi.intItemIssuedUOMId=iu1.intItemUOMId
	Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Join tblSMCompanyLocation cl on cl.intCompanyLocationId=wi.intLocationId
	Left Join tblICStorageLocation sl on sl.intStorageLocationId=wi.intStorageLocationId
	Left Join tblSMCompanyLocationSubLocation sbl on sbl.intCompanyLocationSubLocationId=sl.intSubLocationId
	Left Join vyuQMGetLotQuality q on pl.intParentLotId=q.intLotId
	Left Join tblMFRecipeItem ri on wi.intRecipeItemId=ri.intRecipeItemId
	Where wi.intWorkOrderId=@intWorkOrderId

	Update wi Set wi.dblUnitCost=l.dblLastCost,wi.strGarden=ISNULL(l.strGarden,''),wi.strRemarks=l.strNotes
	From #tblWorkOrderInputParent wi Join tblICLot l on wi.intLotId=l.intParentLotId

	Select * from #tblWorkOrderInputParent
End