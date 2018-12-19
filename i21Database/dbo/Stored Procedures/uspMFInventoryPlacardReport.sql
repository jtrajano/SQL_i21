CREATE PROCEDURE uspMFInventoryPlacardReport @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @xmlDocumentId INT
	DECLARE @strReceiptNo NVARCHAR(50)
	DECLARE @variable1 VARBINARY(max)
	DECLARE @variable2 VARBINARY(max)
	DECLARE @variable3 VARBINARY(max)
	DECLARE @variable4 VARBINARY(max)
	DECLARE @variable5 VARBINARY(max)
	DECLARE @variable6 VARBINARY(max)
	DECLARE @intItemID INT

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

	SELECT @strLotNumber = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strLotNo'

	SELECT @strReceiptNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strReceiptNo'

	DECLARE @strColumn1 NVARCHAR(100)
		,@strColumn2 NVARCHAR(100)
		,@strColumn3 NVARCHAR(100)
		,@strColumn4 NVARCHAR(100)
		,@strColumn5 NVARCHAR(100)
		,@strColumn6 NVARCHAR(100)

	SELECT @strColumn1 = ''
		,@strColumn2 = ''
		,@strColumn3 = ''
		,@strColumn4 = ''
		,@strColumn5 = ''
		,@strColumn6 = ''

	DECLARE @tblMFCustomTable TABLE (
		intRecordId INT identity(1, 1)
		,strFieldName NVARCHAR(50)
		)

	INSERT INTO @tblMFCustomTable (strFieldName)
	SELECT DISTINCT L.strComment
	FROM tblICItemCertification IC
	JOIN tblICCertification C ON C.intCertificationId = IC.intCertificationId
	CROSS JOIN tblSMAttachment L
	JOIN tblSMUpload U ON U.intAttachmentId = L.intAttachmentId
		AND U.strFileIdentifier = L.strFileIdentifier
	WHERE CHARINDEX(C.strCertificationName, L.strComment COLLATE Latin1_General_CI_AS) > 0

	SELECT @strColumn1 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 1

	SELECT @strColumn2 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 2

	SELECT @strColumn3 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 3

	SELECT @strColumn4 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 4

	SELECT @strColumn5 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 5

	SELECT @strColumn6 = strFieldName
	FROM @tblMFCustomTable
	WHERE intRecordId = 6

	DECLARE @tblMFCustomValue TABLE (
		intItemId INT
		,strColumn1 VARBINARY(MAX)
		,strColumn2 VARBINARY(MAX)
		,strColumn3 VARBINARY(MAX)
		,strColumn4 VARBINARY(MAX)
		,strColumn5 VARBINARY(MAX)
		,strColumn6 VARBINARY(MAX)
		)

	INSERT INTO @tblMFCustomValue (
		intItemId
		,strColumn1
		,strColumn2
		,strColumn3
		,strColumn4
		,strColumn5
		,strColumn6
		)
	SELECT intItemId
		,strColumn1
		,strColumn2
		,strColumn3
		,strColumn4
		,strColumn5
		,strColumn6
	FROM (
		SELECT IC.intItemId
			,Replace(Replace(Replace(Replace(Replace(Replace(L.strComment, @strColumn1, 'strColumn1'), @strColumn2, 'strColumn2'), @strColumn3, 'strColumn3'), @strColumn4, 'strColumn4'), @strColumn5, 'strColumn5'), @strColumn6, 'strColumn6') AS strFieldName
			,U.blbFile
		FROM tblICItemCertification IC
		JOIN tblICCertification C ON C.intCertificationId = IC.intCertificationId
		CROSS JOIN tblSMAttachment L
		JOIN tblSMUpload U ON U.intAttachmentId = L.intAttachmentId
			AND U.strFileIdentifier = L.strFileIdentifier
		WHERE CHARINDEX(C.strCertificationName, L.strComment COLLATE Latin1_General_CI_AS) > 0
		) AS SourceTable
	PIVOT(MAX(SourceTable.blbFile) FOR strFieldName IN (
				strColumn1
				,strColumn2
				,strColumn3
				,strColumn4
				,strColumn5
				,strColumn6
				)) AS PivotTable

	SELECT CONVERT(NVARCHAR, LI.dtmReceiptDate, 1) AS dtmReceiptDate
		,LI.strWarehouseRefNo AS strEntryNo
		,RL.strContainerNo AS stContainerNo
		,LI.strReceiptNumber AS strOrderNo
		,RL.strParentLotNumber
		,RL.strLotNumber
		,(ISNULL(RL.dblGrossWeight, 0) - ISNULL(RL.dblTareWeight, 0)) AS dblNetWeight
		,UOM.strUnitMeasure
		,I.strItemNo
		,I.strDescription
		,RL.strContainerNo AS strCustomerPO
		,RL.strLotAlias AS strBatchNo
		,Logo1 = strColumn1
		,Logo2 = strColumn2
		,Logo3 = strColumn3
		,Logo4 = strColumn4
		,Logo5 = strColumn5
		,Logo6 = strColumn6
		,dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo
		,Ltrim(convert(NUMERIC(24, 2), (ISNULL(RL.dblGrossWeight, 0) - ISNULL(RL.dblTareWeight, 0)))) + ' ' + UOM.strUnitMeasure AS Weight_UOM
	FROM tblMFLotInventory LI
	JOIN tblICInventoryReceiptItemLot RL ON RL.intLotId = LI.intLotId
	JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RL.intInventoryReceiptItemId
	JOIN tblICInventoryReceipt R ON RI.intInventoryReceiptId = R.intInventoryReceiptId
	JOIN tblICItem I ON I.intItemId = RI.intItemId
	LEFT JOIN @tblMFCustomValue tbl ON tbl.intItemId = I.intItemId
	LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = RL.intItemUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
	WHERE RL.strLotNumber IN (
			SELECT x.Item COLLATE DATABASE_DEFAULT
			FROM dbo.fnSplitString(@strLotNumber, '^') x
			)
		AND R.strReceiptNumber IN (
			SELECT x.Item COLLATE DATABASE_DEFAULT
			FROM dbo.fnSplitString(@strReceiptNo, '^') x
			)
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFInventoryPlacardReport - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
