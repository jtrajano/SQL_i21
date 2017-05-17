CREATE PROCEDURE uspMFReportBondedPalletTag @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strLotNumber NVARCHAR(50)
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

	SELECT @strLotNumber = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strLotNumber'

	SELECT TOP 1 CONVERT(NVARCHAR, LI.dtmReceiptDate, 1) AS dtmReceiptDate
		,LI.strWarehouseRefNo AS strEntryNo
		,RL.strContainerNo AS stContainerNo
		,LI.strReceiptNumber AS strOrderNo
		,L.strBOLNo AS strBOLNo
		,'' AS strDoorNo
		,'BONDED CARGO' AS strTopBottomTitle
	FROM tblMFLotInventory LI
	JOIN tblICInventoryReceiptItemLot RL ON RL.intLotId = LI.intLotId
	JOIN tblICLot L ON L.intLotId = RL.intLotId
	WHERE L.strLotNumber = @strLotNumber
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFReportBondedPalletTag - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
