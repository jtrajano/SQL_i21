CREATE PROCEDURE uspMFReportActualOutTurn (@xmlParam NVARCHAR(MAX) = NULL)
AS
DECLARE @strProcessName NVARCHAR(50)
	,@strProcessDate NVARCHAR(50)
	,@strWeightUOM NVARCHAR(50)
	,@xmlDocumentId INT
	,@strProcessToDate NVARCHAR(50)

IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE (
	[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
	)

EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
	,@xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

SELECT @strProcessName = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'ProcessName'

SELECT @strProcessDate = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'ProcessDate'

SELECT @strProcessToDate = [to]
FROM @temp_xml_table
WHERE [fieldname] = 'ProcessDate'

IF @strProcessToDate IS NULL
	OR @strProcessToDate = ''
BEGIN
	SELECT @strProcessToDate = @strProcessDate
END

SELECT @strWeightUOM = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'WeightUOM'

DECLARE @intUnitMeasureId INT

SELECT @intUnitMeasureId = intUnitMeasureId
FROM tblICUnitMeasure
WHERE strUnitMeasure = @strWeightUOM

SELECT Row_Number() OVER (
		PARTITION BY W.intWorkOrderId ORDER BY W.intWorkOrderId
		) AS intId
	,W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dtmPlannedDate
	,MP.strProcessName
	,CL.strLocationName
	,CL.strAddress
	,CL.strZipPostalCode
	,CL.strCity
	,CL.strStateProvince
	,CL.strCountry
	,OH.strOrderNo
	,OH.dtmOrderDate
	,I.strItemNo
	,I.strDescription
	,L.strLotNumber
	,dbo.fnMFConvertQuantityToTargetItemUOM(T.intItemUOMId, IU.intItemUOMId, T.dblQty) AS dblQty
	,@strWeightUOM AS strWeightUOM
INTO #IssueDetail
FROM tblMFWorkOrder W
JOIN tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
	AND W.intStatusId = 13
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
LEFT JOIN tblMFStageWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
LEFT JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = SW.intOrderHeaderId
LEFT JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = SW.intOrderHeaderId
LEFT JOIN tblICLot L ON L.intLotId = OM.intLotId
LEFT JOIN tblMFTask T ON T.intLotId = L.intLotId
	AND T.intOrderHeaderId = OH.intOrderHeaderId
LEFT JOIN tblICItemUOM IU ON IU.intItemId = T.intItemId
	AND IU.intUnitMeasureId = @intUnitMeasureId
LEFT JOIN tblICItem I ON I.intItemId = L.intItemId
WHERE MP.strProcessName = IsNULL(@strProcessName, MP.strProcessName)
	AND W.dtmPlannedDate BETWEEN @strProcessDate
		AND @strProcessToDate

SELECT Row_Number() OVER (
		PARTITION BY W.intWorkOrderId ORDER BY W.intWorkOrderId
		) AS intId
	,W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dtmPlannedDate
	,MP.strProcessName
	,CL.strLocationName
	,CL.strAddress
	,CL.strZipPostalCode
	,CL.strCity
	,CL.strStateProvince
	,CL.strCountry
	,L.strLotNumber
	,WP.dtmProductionDate
	,I.strItemNo
	,I.strDescription
	,WP.strParentLotNumber
	,dbo.fnMFConvertQuantityToTargetItemUOM(WP.intItemUOMId, IU.intItemUOMId, WP.dblQuantity) AS dblQty
	,@strWeightUOM AS strWeightUOM
INTO #ReceiveDetail
FROM tblMFWorkOrder W
JOIN tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
	AND W.intStatusId = 13
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
JOIN tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
	AND WP.ysnProductionReversed = 0
JOIN tblICLot L ON L.intLotId = WP.intLotId
JOIN tblICItemUOM IU ON IU.intItemId = WP.intItemId
	AND IU.intUnitMeasureId = @intUnitMeasureId
LEFT JOIN tblICItem I ON I.intItemId = L.intItemId
WHERE MP.strProcessName = IsNULL(@strProcessName, MP.strProcessName)
	AND W.dtmPlannedDate BETWEEN @strProcessDate
		AND @strProcessToDate

SELECT IsNULL(S.strWorkOrderNo, R.strWorkOrderNo) AS strWorkOrderNo
	,IsNULL(S.dtmPlannedDate, R.dtmPlannedDate) AS dtmPlannedDate
	,IsNULL(S.strProcessName, R.strProcessName) AS strProcessName
	,IsNULL(S.strLocationName, R.strLocationName) AS strLocationName
	,IsNULL(S.strAddress, R.strAddress) AS strAddress
	,IsNULL(S.strCity, R.strCity) AS strCity
	,IsNULL(S.strZipPostalCode, R.strZipPostalCode) AS strZipPostalCode
	,IsNULL(S.strStateProvince, R.strStateProvince) AS strStateProvince
	,IsNULL(S.strCountry, R.strCountry) AS strCountry
	,IsNULL(S.strLocationName, R.strLocationName) + IsNULL(S.strAddress, R.strAddress) + IsNULL(S.strCity, R.strCity) + IsNULL(S.strZipPostalCode, R.strZipPostalCode) + IsNULL(S.strStateProvince, R.strStateProvince) + IsNULL(S.strCountry, R.strCountry) AS strLocationWithAddress
	,S.dtmOrderDate AS dtmIssueDate
	,S.strItemNo AS strIssueItemNo
	,S.strDescription AS strIssueDescription
	,S.strLotNumber AS strIssueBatchNumber
	,S.dblQty AS dblIssueQty
	,S.strWeightUOM AS strIssueUOM
	,R.dtmProductionDate AS dtmReceiptDate
	,R.strItemNo AS strReceiptItemNo
	,R.strDescription AS strReceiptDescription
	,R.strParentLotNumber AS strReceiptBatchNumber
	,R.dblQty AS dblReceiptQty
	,R.strWeightUOM AS strReceiptUOM
FROM #IssueDetail S
FULL JOIN #ReceiveDetail R ON S.intId = R.intId
	AND R.intWorkOrderId = S.intWorkOrderId
ORDER BY IsNULL(S.intWorkOrderId, R.intWorkOrderId)
