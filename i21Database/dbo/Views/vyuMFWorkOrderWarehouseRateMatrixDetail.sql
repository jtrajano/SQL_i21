CREATE VIEW vyuMFWorkOrderWarehouseRateMatrixDetail
AS
SELECT WWRMD.intWorkOrderWarehouseRateMatrixDetailId
	--,WRMD.intWarehouseRateMatrixDetailId
	--,WRMD.intWarehouseRateMatrixHeaderId
	,WRMD.strCategory
	,WRMD.strActivity
	--,WRMD.intType
	,WRMD.dblUnitRate
	--,WRMD.strComments
	--,WRMD.intCalculateQty
	--,I.intItemId
	,I.strItemNo
	--,WRMD.intItemUOMId
	--,U.intUnitMeasureId
	,U.strUnitMeasure
	--,I.strType
	--,WWRMD.dblQuantity
	--,WWRMD.dblProcessedQty
	--,WWRMD.dblEstimatedAmount
	--,WWRMD.dblActualAmount
	--,WWRMD.dblDifference
	--,WWRMD.[dtmCreated]
	--,CUS.strUserName AS strCreatedUserName
	--,WWRMD.[dtmLastModified]
	--,UUS.strUserName AS strLastModifiedUserName
	--,WRMD.intSort
	--,WWRMD.intBillId
	,B.strBillId
	--,WWRMD.strERPServicePOLineNo
	--,WWRMD.intConcurrencyId
FROM dbo.tblMFWorkOrderWarehouseRateMatrixDetail WWRMD
JOIN dbo.tblLGWarehouseRateMatrixDetail AS WRMD ON WWRMD.intWarehouseRateMatrixDetailId = WRMD.intWarehouseRateMatrixDetailId
JOIN dbo.tblICItem AS I ON WRMD.intItemId = I.intItemId
JOIN dbo.tblICItemUOM AS IU ON WRMD.intItemUOMId = IU.intItemUOMId
JOIN dbo.tblICUnitMeasure AS U ON IU.intUnitMeasureId = U.intUnitMeasureId
JOIN dbo.tblSMUserSecurity CUS ON CUS.intEntityId = WWRMD.intCreatedUserId
JOIN dbo.tblSMUserSecurity UUS ON UUS.intEntityId = WWRMD.intLastModifiedUserId
LEFT JOIN dbo.tblAPBill B ON B.intBillId = WWRMD.intBillId
