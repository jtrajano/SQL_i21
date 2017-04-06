CREATE VIEW vyuQMSampleStaticPropertiesResult
AS
SELECT TR.intTestResultId
	,TR.intSampleId
	,S.strSampleNumber
	,P.strPropertyName
	,TR.strPropertyValue
	,TR.strResult
	,TR.dtmLastModified
	,TR.dblMinValue
	,TR.dblMaxValue
	,ST.strSampleTypeName
	,S.dtmSampleReceivedDate
	,S.strLotNumber
	,I.strItemNo
	,I.strDescription
	,IR.strReceiptNumber
	,WO.strWorkOrderNo
	,MC.strCellName
FROM tblQMTestResult TR
JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
	AND TR.strResult = 'Failed'
JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	AND P.ysnNotify = 1
	AND TR.dtmLastModified > (GETDATE() - 1)
JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
JOIN tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = S.intInventoryReceiptId
LEFT JOIN tblMFWorkOrder WO ON WO.intWorkOrderId = S.intWorkOrderId
LEFT JOIN tblMFManufacturingCell MC ON MC.intManufacturingCellId = WO.intManufacturingCellId
