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
		,@strOrderManifestLabelId NVARCHAR(MAX) = ''
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
		,@intInventoryShipmentId INT
		,@strGTINNumber NVARCHAR(50)

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

	SELECT @strOrderManifestLabelId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intOrderManifestLabelId'

	-- only for print mode
	IF ISNULL(@strOrderManifestLabelId, '') = ''
	BEGIN
		EXEC dbo.uspMFGenerateSSCCNo @strOrderManifestId = @strOrderManifestId
			,@intNoOfLabel = @intNoOfLabel
			,@intCustomerLabelTypeId = @intCustomerLabelTypeId
	END

	-- only for print mode
	IF ISNULL(@strOrderManifestLabelId, '') = ''
	BEGIN
		IF @intCustomerLabelTypeId = 1 OR @intCustomerLabelTypeId = 3 -- Pallet Label / Pallet Label with Weight
		BEGIN
			INSERT INTO @tblMFGenerateSSNo
			SELECT *
			FROM dbo.fnSplitString(@strOrderManifestId, '^')
			WHERE Item <> ''

			SELECT @intOrderManifestId = min(intOrderManifestId)
			FROM @tblMFGenerateSSNo

			SELECT @intEntityCustomerId = S.intEntityCustomerId
				,@intInventoryShipmentId = S.intInventoryShipmentId
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

			--SELECT TOP 1 @strGTINNumber = FV.strValue
			--FROM tblSMTabRow TR
			--JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
			--JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			--	AND LOWER(TD.strControlName) = 'GTIN Number'
			--JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
			--JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			--	AND S.strNamespace = 'Inventory.view.InventoryShipment'
			--WHERE T.intRecordId = @intInventoryShipmentId

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
						,@strGTINNumber = ''

					-- Order GTIN No
					SELECT @strGTINNumber = OD.strOrderGTIN
					FROM tblMFOrderManifest OM
					JOIN tblMFOrderDetail OD ON OD.intOrderDetailId = OM.intOrderDetailId
					WHERE OM.intOrderManifestId = @intOrderManifestId

					-- Bar Code 1
					SELECT @strBarcodeLabel1 = @strFirstBarcodeStart + LEFT((CASE WHEN ISNULL(@strGTINNumber, '') <> '' THEN @strGTINNumber ELSE I.strGTIN END),14) + @strFirstBarcodeFollowGTIN + CONVERT(NVARCHAR(6), L.dtmExpiryDate, 12) + @strFirstBarcodeEnd + LTRIM(Convert(NUMERIC(18, 0), ISNULL(L.dblQty, 0)))
						,@strBarcode1 = REPLACE(REPLACE(@strGS1SpecialCode + @strFirstBarcodeStart + LEFT((CASE WHEN ISNULL(@strGTINNumber, '') <> '' THEN @strGTINNumber ELSE I.strGTIN END),14) + @strFirstBarcodeFollowGTIN + CONVERT(NVARCHAR(6), L.dtmExpiryDate, 12) + @strFirstBarcodeEnd + LTRIM(Convert(NUMERIC(18, 0), ISNULL(L.dblQty, 0))), '(', ''), ')', '')
					FROM tblMFOrderManifest OM
					JOIN tblICLot L ON L.intLotId = OM.intLotId
					JOIN tblICItem I ON I.intItemId = L.intItemId
					WHERE OM.intOrderManifestId = @intOrderManifestId

					-- Bar Code 2
					SELECT @strBarcodeLabel2 = @strSecondBarcodeStart + dbo.[fnMFConvertNumberToString](Convert(NUMERIC(18, 0), L.dblQty * I.dblUnitPerCase), 2, 6) + @strSecondBarcodeFollowGrossWeight + dbo.[fnMFConvertNumberToString](Convert(NUMERIC(18, 0), L.dblWeight), 2, 6) + @strSecondBarcodeEnd + LTRIM(I.intInnerUnits)
						,@strBarcode2 = REPLACE(REPLACE(@strGS1SpecialCode + @strSecondBarcodeStart + dbo.[fnMFConvertNumberToString](Convert(NUMERIC(18, 0), L.dblQty * I.dblUnitPerCase), 2, 6) + @strSecondBarcodeFollowGrossWeight + dbo.[fnMFConvertNumberToString](Convert(NUMERIC(18, 0), L.dblWeight), 2, 6) + @strSecondBarcodeEnd + LTRIM(I.intInnerUnits), '(', ''), ')', '')
					FROM tblMFOrderManifest OM
					JOIN tblICLot L ON L.intLotId = OM.intLotId
					JOIN tblICItem I ON I.intItemId = L.intItemId
					LEFT JOIN tblMFWorkOrderProducedLot WPL ON WPL.intLotId = L.intLotId
					WHERE OM.intOrderManifestId = @intOrderManifestId

					-- Bar Code 3
					SELECT @strBarcodeLabel3 = @strThirdBarcodeStart + Right(Ltrim(RTrim(REPLACE(REPLACE(REPLACE(OML.strSSCCNo, '(', ''), ')', ''), ' ', ''))), 18)
						,@strBarcode3 = REPLACE(REPLACE(@strGS1SpecialCode + @strThirdBarcodeStart + Right(Ltrim(RTrim(REPLACE(REPLACE(REPLACE(OML.strSSCCNo, '(', ''), ')', ''), ' ', ''))), 18), '(', ''), ')', '')
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
	END

	-- only for re-print mode
	IF ISNULL(@strOrderManifestLabelId, '') <> ''
	BEGIN
		UPDATE tblMFOrderManifestLabel
		SET ysnPrinted = 0
			,intCustomerLabelTypeId = @intCustomerLabelTypeId
		WHERE ysnPrinted = 1
			AND intOrderManifestLabelId IN (
				SELECT *
				FROM dbo.fnSplitString(@strOrderManifestLabelId, '^')
				)
	END

	SELECT LTRIM(RTRIM(CASE 
					WHEN ISNULL(CL.strLocationName, '') = ''
						THEN ''
					ELSE (
							IsNULL((
									SELECT TOP 1 strFromLocation
									FROM tblMFReportLidlUCCPalletLabel
									), CL.strLocationName)
							) + CHAR(13)
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
		,I.strDescription + ' ' + CHAR(13) + ISNULL(I.strShortName, '') AS strDescription
		,LEFT((CASE WHEN ISNULL(OD.strOrderGTIN, '') <> '' THEN OD.strOrderGTIN ELSE I.strGTIN END),14) AS strOrderGTIN
		,Convert(NUMERIC(18, 0), ISNULL(LOT.dblQty, 0)) AS intCasesPerPallet
		,I.intInnerUnits AS intUnitsPerCase
		,CONVERT(VARCHAR(10), LOT.dtmExpiryDate, 101) AS dtmExpiryDate
		,Convert(NUMERIC(18, 0), LOT.dblQty * I.dblWeight) AS dblNetWeight
		,Convert(NUMERIC(18, 0), LOT.dblQty * I.dblUnitPerCase) AS dblGrossWeight
		,Right(Ltrim(RTrim(REPLACE(REPLACE(REPLACE(OML.strSSCCNo, '(', ''), ')', ''), ' ', ''))), 18) AS strSSCCNo
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
	JOIN tblICLot LOT ON LOT.intLotId = OM.intLotId
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
