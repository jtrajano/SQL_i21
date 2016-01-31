﻿CREATE VIEW [dbo].[vyuMFGetBlendConsolidationView]
	AS 
    Select DISTINCT 
	wc.intWorkOrderConsumedLotId AS intRowNo,
	br.strDemandNo,
	w.strWorkOrderNo,
	i.strItemNo strBlendItemNo,
	i.strDescription strBlendItemDesc,
	cg.strCategoryCode strBlendCategoryCode, 
	w.dblQuantity dblWOQuantity,
	um2.strUnitMeasure strWOUOM,
	l.strLotNumber strConsumedLotNumber,
	l.strLotAlias strConsumedLotAlias,
	l.strGarden,
	'' strGrade,
	'' strChop,
	i1.strItemNo strConsumedItemNo,
	i1.strDescription strConsumedItemDesc,
	wc.dblQuantity dblConsumedQuantity,
	um.strUnitMeasure strConsumedUOM,
	wc.dblIssuedQuantity dblConsumedIssuedQuantity,
	um1.strUnitMeasure strConsumedIssuedUOM,
	l1.strLotNumber strProducedLotNumber,
	wp.dblQuantity dblProducedLotQuantity,
	cl.strLocationName,
	cl.intCompanyLocationId intLocationId,
	l1.dtmDateCreated dtmLotProducedDate,
	e1.strName as strUserName
	from tblMFWorkOrder w
	JOIN tblMFBlendRequirement br ON br.intBlendRequirementId=w.intBlendRequirementId
	JOIN tblMFWorkOrderConsumedLot wc ON wc.intWorkOrderId=w.intWorkOrderId
	JOIN tblICItem i ON i.intItemId=w.intItemId
	JOIN tblICLot l on l.intLotId=wc.intLotId
	JOIN tblICItem i1 ON i1.intItemId=l.intItemId
	JOIN tblMFWorkOrderProducedLot wp on wp.intWorkOrderId=w.intWorkOrderId
	JOIN tblICLot l1 on l1.intLotId=wp.intLotId
	LEFT JOIN tblICCategory cg on cg.intCategoryId=i.intCategoryId
	JOIN tblICItemUOM iu on iu.intItemUOMId=wc.intItemUOMId
	JOIN tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	JOIN tblICItemUOM iu1 on iu1.intItemUOMId=wc.intItemIssuedUOMId
	JOIN tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=w.intLocationId
	JOIN tblICItemUOM iu2 on iu2.intItemUOMId=w.intItemUOMId
	JOIN tblICUnitMeasure um2 on iu2.intUnitMeasureId=um2.intUnitMeasureId
	LEFT JOIN tblEntity e1 ON l1.intCreatedEntityId=e1.intEntityId
	LEFT JOIN tblEntityType et1 ON e1.intEntityId=et1.intEntityId AND et1.strType='User'
	WHERE w.intStatusId=13
