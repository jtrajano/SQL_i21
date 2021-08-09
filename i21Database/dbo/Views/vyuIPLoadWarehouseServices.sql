CREATE VIEW vyuIPLoadWarehouseServices
AS
SELECT 
	LWS.intLoadWarehouseServicesId
	,LWS.intLoadWarehouseId
	,LWS.strCategory
	,LWS.strActivity
	,I.strItemNo
	,LWS.dblUnitRate
	,UM.strUnitMeasure
	,dblQuantity
	,dblCalculatedAmount
	,dblActualAmount
	,ysnChargeCustomer
	,dblBillAmount
	,LWS.ysnPrint
	,LWS.intSort
	,LWS.strComments
From tblLGLoadWarehouseServices LWS
JOIN tblICItem I ON I.intItemId = LWS.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LWS.intItemUOMId 
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
