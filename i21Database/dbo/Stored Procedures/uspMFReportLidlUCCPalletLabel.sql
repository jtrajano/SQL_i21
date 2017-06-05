CREATE PROCEDURE uspMFReportLidlUCCPalletLabel @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	IF ISNULL(@xmlParam, '') = ''
	BEGIN
		SELECT '' AS 'strFromShipment'
			,'' AS 'strDescription'
			,'' AS 'strSSCCNo'
			,'' AS 'strOrderGTIN'
			,'' AS 'dtmExpiryDate'
			,'' AS 'intCasesPerPallet'
			,'' AS 'intUnitsPerCase'
			,'' AS 'dblNetWeight'
			,'' AS 'dblGrossWeight'
			,'' AS 'strBarCodeLabel1'
			,'' AS 'strBarCode1'
			,'' AS 'strBarCodeLabel2'
			,'' AS 'strBarCode2'

		RETURN
	END

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT
		,@strOrderManifestId NVARCHAR(MAX)
		,@intNoOfLabel INT
		,@intCustomerLabelTypeId INT

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

	SELECT @strOrderManifestId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intOrderManifestId'

	SELECT @intNoOfLabel = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNoOfLabel'

	SELECT @intCustomerLabelTypeId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intCustomerLabelTypeId'

	EXEC dbo.uspMFGenerateSSCCNo @strOrderManifestId = @strOrderManifestId
		,@intNoOfLabel = @intNoOfLabel
		,@intCustomerLabelTypeId = @intCustomerLabelTypeId

	SELECT LTRIM(RTRIM(CASE 
					WHEN ISNULL(CL.strLocationName, '') = ''
						THEN ''
					ELSE CL.strLocationName + CHAR(13)
					END + CASE 
					WHEN ISNULL(CL.strAddress, '') = ''
						THEN ''
					ELSE CL.strAddress + CHAR(13)
					END + CASE 
					WHEN ISNULL(CL.strCity, '') = ''
						THEN ''
					ELSE CL.strCity + ', '
					END + CASE 
					WHEN ISNULL(CL.strStateProvince, '') = ''
						THEN ''
					ELSE CL.strStateProvince + ' '
					END + CASE 
					WHEN ISNULL(CL.strZipPostalCode, '') = ''
						THEN ''
					ELSE CL.strZipPostalCode + CHAR(13)
					END + CASE 
					WHEN ISNULL(CL.strCountry, '') = ''
						THEN ''
					ELSE CL.strCountry
					END)) AS strFromShipment
		,I.strDescription
		,I.strGTIN AS strOrderGTIN
		,ISNULL((I.intLayerPerPallet * I.intUnitPerLayer), 0) AS intCasesPerPallet
		,I.intInnerUnits AS intUnitsPerCase
		,(
			SELECT CONVERT(VARCHAR(10), dtmExpiryDate, 101)
			FROM tblICLot LOT
			WHERE LOT.intLotId = OM.intLotId
			) AS dtmExpiryDate
		,(
			SELECT dblWeight
			FROM tblICLot LOT
			WHERE LOT.intLotId = OM.intLotId
			) AS dblNetWeight
		,(
			SELECT LOT.dblWeight + ISNULL(WPL.dblTareWeight, 0)
			FROM tblICLot LOT
			LEFT JOIN tblMFWorkOrderProducedLot WPL ON WPL.intLotId = LOT.intLotId
			WHERE LOT.intLotId = OM.intLotId
			) AS dblGrossWeight
		,REPLACE(REPLACE(REPLACE(OML.strSSCCNo, '(', ''), ')', ''), ' ', '') AS strSSCCNo -- check with prem
		,OML.strSSCCNo AS strBarCodeLabel1 -- check with prem
		,OML.strSSCCNo AS strBarCode1 -- check with prem
		,OML.strSSCCNo AS strBarCodeLabel2 -- check with prem
		,OML.strSSCCNo AS strBarCode2 -- check with prem
	FROM tblMFOrderManifest OM
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = OM.intOrderHeaderId
	JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intShipFromLocationId
	JOIN tblICInventoryShipmentItem SI ON SI.intInventoryShipmentId = S.intInventoryShipmentId
	JOIN tblICItem I ON I.intItemId = SI.intItemId
	JOIN tblMFOrderManifestLabel OML ON OML.intOrderManifestId = OM.intOrderManifestId
		AND OML.ysnPrinted = 0
	WHERE OM.intOrderManifestId IN (
			SELECT *
			FROM dbo.fnSplitString(@strOrderManifestId, '^')
			)

	UPDATE tblMFOrderManifestLabel
	SET ysnPrinted = 1
	WHERE ysnPrinted = 0
		AND intOrderManifestId IN (
			SELECT *
			FROM dbo.fnSplitString(@strOrderManifestId, '^')
			)
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFReportLidlUCCPalletLabel - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
