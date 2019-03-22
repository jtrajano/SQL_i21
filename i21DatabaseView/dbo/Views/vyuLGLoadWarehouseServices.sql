CREATE VIEW vyuLGLoadWarehouseServices
AS
SELECT LWS.intLoadWarehouseServicesId
	,LW.intLoadWarehouseId
	,LWS.strCategory
	,LWS.strActivity
	,LWS.intType
	,strType = CASE (LWS.intType)
				WHEN 2 THEN 'Inbound'
				WHEN 3 THEN 'Outbound'
				ELSE 'General' END COLLATE Latin1_General_CI_AS
	,WMD.intCalculateQty
	,strCalculateQty = CASE (WMD.intCalculateQty) 
							WHEN 1 THEN 'By Shipped Net Wt'
							WHEN 2 THEN 'By Shipped Gross Wt'
							WHEN 3 THEN 'By Received Net Wt'
							WHEN 4 THEN 'By Received Gross Wt'
							WHEN 5 THEN 'By Delivered Net Wt'
							WHEN 6 THEN 'By Delivered Gross Wt'
							WHEN 7 THEN 'By Quantity'
							ELSE 'Manual Entry' END COLLATE Latin1_General_CI_AS
	,LWS.intItemId
	,I.strItemNo
	,LWS.dblUnitRate
	,LWS.intItemUOMId
	,UM.strUnitMeasure
	,dblQuantity
	,dblCalculatedAmount
	,dblActualAmount
	,ysnChargeCustomer
	,dblBillAmount
	,LWS.ysnPrint
	,LWS.intSort
	,LWS.strComments
	,LWS.intBillId
	,B.strBillId
	,LWS.intWarehouseRateMatrixDetailId
	,LWS.intConcurrencyId
FROM tblLGLoadWarehouse LW
JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseId = LW.intLoadWarehouseId
JOIN tblLGWarehouseRateMatrixDetail WMD ON LWS.intWarehouseRateMatrixDetailId = WMD.intWarehouseRateMatrixDetailId
JOIN tblICItem I ON I.intItemId = LWS.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LWS.intItemUOMId 
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblAPBill B ON B.intBillId = LWS.intBillId