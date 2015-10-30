CREATE PROCEDURE uspQMReportSampleLabel
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSampleId INT
		,@xmlDocumentId INT

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

	SELECT @intSampleId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intSampleId'

	SELECT TOP 1 I.strItemNo
		,I.strDescription
		,S.strSampleNumber
		,CONVERT(NVARCHAR, S.dtmSampleReceivedDate, 107) AS dtmSampleReceivedDate
		,CASE 
			WHEN C.strCategoryCode = 'C'
				THEN L.strLotNumber
			ELSE ''
			END AS strLotNumber
		,PL.strParentLotNumber
		,ST.strDescription AS strSampleTypeDescription
		,C.strCategoryCode
		,@intSampleId AS intSampleId
		,W.strERPOrderNo AS BPCSshopOrder#
		,ISNULL(PD.intLineNo, 1) AS BPCSLineNumber
		,ISNULL(P.strReference, S.strRefNo) AS BPCSPoNumber
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
	JOIN tblICItem I ON S.intItemId = I.intItemId
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	LEFT JOIN tblQMTestResult TR ON TR.intSampleId = S.intSampleId
		AND TR.intProductTypeId = 11
	LEFT JOIN tblICParentLot PL ON PL.intParentLotId = TR.intProductValueId
	LEFT JOIN tblICLot L ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN tblMFWorkOrderInputParentLot WPL ON WPL.intParentLotId = PL.intParentLotId
	LEFT JOIN tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
	LEFT JOIN tblICInventoryReceiptItemLot RIL ON RIL.intLotId = L.intLotId
	LEFT JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	LEFT JOIN tblPOPurchaseDetail PD ON PD.intPurchaseDetailId = RI.intLineNo
		AND PD.intPurchaseId = RI.intOrderId
	LEFT JOIN tblPOPurchase P ON P.intPurchaseId = PD.intPurchaseId
	WHERE S.intSampleId = @intSampleId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportSampleLabel - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
