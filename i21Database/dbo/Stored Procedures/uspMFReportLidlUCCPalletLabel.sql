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
			,'' AS 'strBarCodeLabel3'
			,'' AS 'strBarCode3'

		RETURN
	END

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT
		,@strOrderManifestId NVARCHAR(MAX)
		,@intNoOfLabel INT
		,@intCustomerLabelTypeId INT
		,@strSSCCNo NVARCHAR(50)
		,@intOrderManifestId INT
		,@intEntityCustomerId INT
	DECLARE @tblMFGenerateSSNo TABLE (intOrderManifestId INT)
	DECLARE @strGS1SpecialCode NVARCHAR(10)
		,@strFirstBarcodeStart NVARCHAR(10)
		,@strFirstBarcodeFollowGTIN NVARCHAR(10)
		,@strFirstBarcodeEnd NVARCHAR(10)
		,@strSecondBarcodeStart NVARCHAR(10)
		,@strSecondBarcodeFollowGrossWeight NVARCHAR(10)
		,@strSecondBarcodeEnd NVARCHAR(10)
		,@strThirdBarcodeStart NVARCHAR(10)
	DECLARE @strBarcode1 NVARCHAR(MAX)
		,@strBarcodeLabel1 NVARCHAR(MAX)
		,@strBarcode2 NVARCHAR(MAX)
		,@strBarcodeLabel2 NVARCHAR(MAX)
		,@strBarcode3 NVARCHAR(MAX)
		,@strBarcodeLabel3 NVARCHAR(MAX)

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

	IF @intCustomerLabelTypeId = 1 -- Pallet Label
	BEGIN
		INSERT INTO @tblMFGenerateSSNo
		SELECT *
		FROM dbo.fnSplitString(@strOrderManifestId, '^')
		WHERE Item <> ''

		SELECT @intOrderManifestId = min(intOrderManifestId)
		FROM @tblMFGenerateSSNo

		SELECT @intEntityCustomerId = S.intEntityCustomerId
		FROM tblMFOrderManifest OM
		JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = OM.intOrderHeaderId
		JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
		WHERE intOrderManifestId = @intOrderManifestId

		IF NOT EXISTS (
				SELECT 1
				FROM tblMFItemOwner
				WHERE intOwnerId = @intEntityCustomerId
					AND intCustomerLabelTypeId = @intCustomerLabelTypeId
				)
			RETURN

		SELECT TOP 1 @strGS1SpecialCode = strGS1SpecialCode
			,@strFirstBarcodeStart = strFirstBarcodeStart
			,@strFirstBarcodeFollowGTIN = strFirstBarcodeFollowGTIN
			,@strFirstBarcodeEnd = strFirstBarcodeEnd
			,@strSecondBarcodeStart = strSecondBarcodeStart
			,@strSecondBarcodeFollowGrossWeight = strSecondBarcodeFollowGrossWeight
			,@strSecondBarcodeEnd = strSecondBarcodeEnd
			,@strThirdBarcodeStart = strThirdBarcodeStart
		FROM tblMFItemOwner
		WHERE intOwnerId = @intEntityCustomerId
			AND intCustomerLabelTypeId = @intCustomerLabelTypeId

		WHILE @intOrderManifestId IS NOT NULL
		BEGIN
			SELECT @strSSCCNo = ''

			SELECT @strSSCCNo = strSSCCNo
			FROM tblMFOrderManifestLabel
			WHERE intOrderManifestId = @intOrderManifestId
				AND intCustomerLabelTypeId = @intCustomerLabelTypeId

			IF ISNULL(@strSSCCNo, '') <> ''
			BEGIN
				SELECT @strBarcode1 = ''
					,@strBarcodeLabel1 = ''
					,@strBarcode2 = ''
					,@strBarcodeLabel2 = ''
					,@strBarcode3 = ''
					,@strBarcodeLabel3 = ''

				-- Bar Code 1
				SELECT @strBarcodeLabel1 = @strFirstBarcodeStart + '0' + I.strGTIN + @strFirstBarcodeFollowGTIN + CONVERT(NVARCHAR(6), L.dtmExpiryDate, 12) + @strFirstBarcodeEnd + LTRIM(ISNULL((I.intLayerPerPallet * I.intUnitPerLayer), 0))
					,@strBarcode1 = REPLACE(REPLACE(@strGS1SpecialCode + @strFirstBarcodeStart + '0' + I.strGTIN + @strFirstBarcodeFollowGTIN + CONVERT(NVARCHAR(6), L.dtmExpiryDate, 12) + @strFirstBarcodeEnd + LTRIM(ISNULL((I.intLayerPerPallet * I.intUnitPerLayer), 0)), '(', ''), ')', '')
				FROM tblMFOrderManifest OM
				JOIN tblICLot L ON L.intLotId = OM.intLotId
				JOIN tblICItem I ON I.intItemId = L.intItemId
				WHERE OM.intOrderManifestId = @intOrderManifestId

				-- Bar Code 2
				SELECT @strBarcodeLabel2 = @strSecondBarcodeStart + dbo.[fnMFConvertNumberToString]((L.dblWeight + ISNULL(WPL.dblTareWeight, 0)), 2, 6) + @strSecondBarcodeFollowGrossWeight + dbo.[fnMFConvertNumberToString](L.dblWeight, 2, 6) + @strSecondBarcodeEnd + LTRIM(I.intInnerUnits)
					,@strBarcode2 = REPLACE(REPLACE(@strGS1SpecialCode + @strSecondBarcodeStart + dbo.[fnMFConvertNumberToString]((L.dblWeight + ISNULL(WPL.dblTareWeight, 0)), 2, 6) + @strSecondBarcodeFollowGrossWeight + dbo.[fnMFConvertNumberToString](L.dblWeight, 2, 6) + @strSecondBarcodeEnd + LTRIM(I.intInnerUnits), '(', ''), ')', '')
				FROM tblMFOrderManifest OM
				JOIN tblICLot L ON L.intLotId = OM.intLotId
				JOIN tblICItem I ON I.intItemId = L.intItemId
				LEFT JOIN tblMFWorkOrderProducedLot WPL ON WPL.intLotId = L.intLotId
				WHERE OM.intOrderManifestId = @intOrderManifestId

				-- Bar Code 3
				SELECT @strBarcodeLabel3 = @strThirdBarcodeStart + REPLACE(REPLACE(REPLACE(OML.strSSCCNo, '(', ''), ')', ''), ' ', '')
					,@strBarcode3 = REPLACE(REPLACE(@strGS1SpecialCode + @strThirdBarcodeStart + REPLACE(REPLACE(REPLACE(OML.strSSCCNo, '(', ''), ')', ''), ' ', ''), '(', ''), ')', '')
				FROM tblMFOrderManifest OM
				JOIN tblMFOrderManifestLabel OML ON OML.intOrderManifestId = OM.intOrderManifestId
					AND OML.ysnPrinted = 0
					AND OML.intCustomerLabelTypeId = @intCustomerLabelTypeId
				WHERE OM.intOrderManifestId = @intOrderManifestId

				UPDATE tblMFOrderManifestLabel
				SET strBarcode1 = @strBarcode1
					,strBarcodeLabel1 = @strBarcodeLabel1
					,strBarcode2 = @strBarcode2
					,strBarcodeLabel2 = @strBarcodeLabel2
					,strBarcode3 = @strBarcode3
					,strBarcodeLabel3 = @strBarcodeLabel3
				WHERE intOrderManifestId = @intOrderManifestId
					AND intCustomerLabelTypeId = @intCustomerLabelTypeId
			END

			SELECT @intOrderManifestId = MIN(intOrderManifestId)
			FROM @tblMFGenerateSSNo
			WHERE intOrderManifestId > @intOrderManifestId
		END
	END

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
		,OML.strBarcodeLabel1
		,OML.strBarcode1
		,OML.strBarcodeLabel2
		,OML.strBarcode2
		,OML.strBarcodeLabel3
		,OML.strBarcode3
	FROM tblMFOrderManifest OM
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = OM.intOrderHeaderId
	JOIN tblMFOrderDetail OD ON OD.intOrderDetailId = OM.intOrderDetailId
	JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intShipFromLocationId
	JOIN tblICInventoryShipmentItem SI ON SI.intInventoryShipmentId = S.intInventoryShipmentId
	JOIN tblICItem I ON I.intItemId = SI.intItemId
		AND I.intItemId = OD.intItemId
	JOIN tblMFOrderManifestLabel OML ON OML.intOrderManifestId = OM.intOrderManifestId
		AND OML.ysnPrinted = 0
		AND OML.intCustomerLabelTypeId = @intCustomerLabelTypeId
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
