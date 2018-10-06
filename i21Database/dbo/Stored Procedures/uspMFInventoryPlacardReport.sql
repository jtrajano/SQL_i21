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

	DECLARE @intLogoId INT

	--DECLARE @SQL Nvarchar(MAX)
	--DECLARE @imgLogo VARBINARY(max)
	SELECT @intItemID = intInventoryReceiptItemId
	FROM tblICInventoryReceipt R
	JOIN tblICInventoryReceiptItem IR ON IR.intInventoryReceiptId = R.intInventoryReceiptId
	WHERE strReceiptNumber = @strReceiptNo ---'IR-25' --

	DECLARE @tblLogo AS TABLE (
		intLogoId INT IDENTITY(1, 1)
		,intUploadId INT
		,strCertificationName NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		,strComment NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		,strName NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		,strFileIdentifier NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,blbFile VARBINARY(MAX)
		)

	INSERT INTO @tblLogo (
		intUploadId
		,strCertificationName
		,strComment
		,strName
		,strFileIdentifier
		,blbFile
		)
	SELECT U.intUploadId
		,C.strCertificationName
		,L.strComment
		,strName
		,L.strFileIdentifier
		,U.blbFile
	FROM tblICItemCertification IC
	JOIN tblICCertification C ON C.intCertificationId = IC.intCertificationId
	CROSS JOIN tblSMAttachment L
	JOIN tblSMUpload U ON U.intAttachmentId = L.intAttachmentId
		AND U.strFileIdentifier = L.strFileIdentifier
	WHERE IC.intItemId = @intItemID
		AND CHARINDEX(C.strCertificationName, L.strComment COLLATE Latin1_General_CI_AS) > 0
	ORDER BY L.intAttachmentId

	SELECT @intLogoId = MIN(intLogoId)
	FROM @tblLogo

	WHILE @intLogoId > 0
	BEGIN
		IF @intLogoId = 1
			SELECT @variable1 = blbFile
			FROM @tblLogo
			WHERE intLogoId = 1
		ELSE IF @intLogoId = 2
			SELECT @variable2 = blbFile
			FROM @tblLogo
			WHERE intLogoId = 2
		ELSE IF @intLogoId = 3
			SELECT @variable3 = blbFile
			FROM @tblLogo
			WHERE intLogoId = 3
		ELSE IF @intLogoId = 4
			SELECT @variable4 = blbFile
			FROM @tblLogo
			WHERE intLogoId = 4
		ELSE IF @intLogoId = 5
			SELECT @variable5 = blbFile
			FROM @tblLogo
			WHERE intLogoId = 5
		ELSE IF @intLogoId = 6
			SELECT @variable6 = blbFile
			FROM @tblLogo
			WHERE intLogoId = 6

		SELECT @intLogoId = MIN(intLogoId)
		FROM @tblLogo
		WHERE intLogoId > @intLogoId
	END

	SELECT TOP 1 CONVERT(NVARCHAR, LI.dtmReceiptDate, 1) AS dtmReceiptDate
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
		,Logo1 = @variable1
		,Logo2 = @variable2
		,Logo3 = @variable3
		,Logo4 = @variable4
		,Logo5 = @variable5
		,Logo6 = @variable6
		,dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo
		,Ltrim(convert(NUMERIC(24, 2), (ISNULL(RL.dblGrossWeight, 0) - ISNULL(RL.dblTareWeight, 0)))) + ' ' + UOM.strUnitMeasure AS Weight_UOM
	FROM tblMFLotInventory LI
	JOIN tblICInventoryReceiptItemLot RL ON RL.intLotId = LI.intLotId
	JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RL.intInventoryReceiptItemId
	JOIN tblICInventoryReceipt R ON RI.intInventoryReceiptId = R.intInventoryReceiptId
	JOIN tblICItem I ON I.intItemId = RL.intInventoryReceiptItemId
	LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = RL.intItemUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
	WHERE RL.strLotNumber IN (
			SELECT x.Item COLLATE DATABASE_DEFAULT
			FROM dbo.fnSplitString(@strLotNumber, '^') x
			)
		AND I.intItemId = @intItemID
		AND R.strReceiptNumber = @strReceiptNo --'IR-25'
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
