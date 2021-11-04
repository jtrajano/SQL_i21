CREATE VIEW vyuMFWorkOrderWarehouseServicesSearch
AS
SELECT WWRMD.intWorkOrderWarehouseRateMatrixDetailId
	,W.intWorkOrderId
	,W.strWorkOrderNo
	,WRMD.strCategory
	,WRMD.strActivity
	,WRMD.dblUnitRate
	,U.strUnitMeasure
	,I.strItemNo
	,WWRMD.dblQuantity
	,WWRMD.dblProcessedQty
	,WWRMD.dblEstimatedAmount
	,WWRMD.dblActualAmount
	,WWRMD.dblDifference
	,WWRMD.dtmCreated
	,CUS.strUserName AS strCreatedUserName
	,WWRMD.dtmLastModified
	,UUS.strUserName AS strLastModifiedUserName
	,WWRMD.intBillId
	,B.strBillId
	,W.strERPServicePONumber
	,WWRMD.strERPServicePOLineNo
	,WRMH.strServiceContractNo
	,W.intLocationId
	,W.intManufacturingProcessId
	,W.strReferenceNo
FROM dbo.tblMFWorkOrderWarehouseRateMatrixDetail WWRMD
JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WWRMD.intWorkOrderId
JOIN dbo.tblLGWarehouseRateMatrixDetail AS WRMD ON WWRMD.intWarehouseRateMatrixDetailId = WRMD.intWarehouseRateMatrixDetailId
JOIN dbo.tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = WRMD.intWarehouseRateMatrixHeaderId
JOIN dbo.tblICItem AS I ON WRMD.intItemId = I.intItemId
JOIN dbo.tblICItemUOM AS IU ON WRMD.intItemUOMId = IU.intItemUOMId
JOIN dbo.tblICUnitMeasure AS U ON IU.intUnitMeasureId = U.intUnitMeasureId
JOIN dbo.tblSMUserSecurity CUS ON CUS.intEntityId = WWRMD.intCreatedUserId
JOIN dbo.tblSMUserSecurity UUS ON UUS.intEntityId = WWRMD.intLastModifiedUserId
LEFT JOIN dbo.tblAPBill B ON B.intBillId = WWRMD.intBillId
