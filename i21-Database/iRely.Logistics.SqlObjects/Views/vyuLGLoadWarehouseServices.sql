CREATE VIEW vyuLGLoadWarehouseServices
AS
SELECT LWS.intLoadWarehouseServicesId
	,LW.intLoadWarehouseId
	,strCategory
	,strActivity
	,intType
	,LWS.intItemId
	,I.strItemNo
	,dblUnitRate
	,LWS.intItemUOMId
	,UM.strUnitMeasure
	,dblQuantity
	,dblCalculatedAmount
	,dblActualAmount
	,ysnChargeCustomer
	,dblBillAmount
	,ysnPrint
	,LWS.intSort
	,strComments
	,LWS.intBillId
	,B.strBillId
	,intWarehouseRateMatrixDetailId
FROM tblLGLoadWarehouse LW
JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseId = LW.intLoadWarehouseId
JOIN tblICItemUOM IU ON IU.intItemUOMId = LWS.intItemUOMId 
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICItem I ON I.intItemId = LWS.intItemId
LEFT JOIN tblAPBill B ON B.intBillId = LWS.intBillId