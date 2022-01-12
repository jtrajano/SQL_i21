﻿CREATE PROCEDURE uspMFReportUCCPalletLabel @xmlParam NVARCHAR(MAX) = NULL
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
			,'' AS 'strToShipment'
			,'' AS 'strShipToZipCode'
			,'' AS 'strCarrier'
			,'' AS 'strPONumber'
			,'' AS 'strDPCI'
			,'' AS 'intCasePack'
			,'' AS 'strStyle'
			,'' AS 'strBarCodeLabel'
			,'' AS 'strBarCode'
			,'' AS 'strReferenceNumber'
			,'' AS 'strShipToPostalCode'
			,'' AS 'strShipmentNumber'
			,'' AS 'strProNumber'
			,'' AS 'strHEBItemNo'
			,'' AS 'dblQty'
			,'' AS 'strGTIN'
			,'' AS 'strDescription'
			,'' AS 'dtmExpiryDate'
			,'' AS 'dblNetWeight'
			,'' AS 'strLotNumber'

		RETURN
	END

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT
		,@strOrderManifestId NVARCHAR(MAX)
		,@intNoOfLabel INT
		,@intInventoryShipmentId INT
		,@strCustomCustomerPO NVARCHAR(50)
		,@intCustomerLabelTypeId INT
		,@strOrderManifestLabelId NVARCHAR(MAX) = ''

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

	SELECT TOP 1 @intInventoryShipmentId = intInventoryShipmentId
	FROM tblMFOrderManifest OM
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = OM.intOrderHeaderId
	JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
	WHERE OM.intOrderManifestId IN (
			SELECT *
			FROM dbo.fnSplitString(@strOrderManifestId, '^')
			)

	-- Taking 'Customer PO No' value from custom tab
	SELECT @strCustomCustomerPO = FV.strValue
	FROM tblSMTabRow TR
	JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
	JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
		AND LOWER(TD.strControlName) = 'customer po no'
	JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
	JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
		AND S.strNamespace = 'Inventory.view.InventoryShipment'
	WHERE T.intRecordId = @intInventoryShipmentId

	-- only for re-print mode
	IF ISNULL(@strOrderManifestLabelId, '') <> ''
	BEGIN
		UPDATE tblMFOrderManifestLabel
		SET ysnPrinted = 0
		WHERE ysnPrinted = 1
			AND intOrderManifestLabelId IN (
				SELECT *
				FROM dbo.fnSplitString(@strOrderManifestLabelId, '^')
				)
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
		,LTRIM(RTRIM(CASE 
					WHEN ISNULL(EL.strLocationName, '') = ''
						THEN ''
					ELSE EL.strLocationName + CHAR(13)
					END + CASE 
					WHEN ISNULL(EL.strAddress, '') = ''
						THEN ''
					ELSE EL.strAddress + CHAR(13)
					END + CASE 
					WHEN ISNULL(EL.strCity, '') = ''
						THEN ''
					ELSE EL.strCity + ', '
					END + CASE 
					WHEN ISNULL(EL.strState, '') = ''
						THEN ''
					ELSE EL.strState + ' '
					END + CASE 
					WHEN ISNULL(EL.strZipCode, '') = ''
						THEN ''
					ELSE EL.strZipCode + CHAR(13)
					END + CASE 
					WHEN ISNULL(EL.strCountry, '') = ''
						THEN ''
					ELSE EL.strCountry
					END)) AS strToShipment
		,EL.strZipCode AS strShipToZipCode
		,SV.strShipVia AS strCarrier
		,@strCustomCustomerPO AS strPONumber
		,I.strGTIN AS strDPCI
		,I.intInnerUnits AS intCasePack
		,I.strItemNo AS strStyle
		,OML.strSSCCNo AS strBarCodeLabel
		,OML.strSSCCNo AS strBarCode
		,S.strReferenceNumber
		,'(420) ' + EL.strZipCode AS strShipToPostalCode
		,S.strShipmentNumber
		,S.strProNumber
		,'' AS strHEBItemNo
		,CONVERT(NUMERIC(18, 0), ISNULL(T.dblQty, L.dblQty)) AS dblQty
		,(
			CASE 
				WHEN ISNULL(OD.strOrderGTIN, '') = ''
					THEN I.strGTIN
				ELSE OD.strOrderGTIN
				END
			) AS strGTIN
		,I.strDescription
		,dbo.fnConvertDateToReportDateFormat(L.dtmExpiryDate, 0) AS dtmExpiryDate
		--,CONVERT(NUMERIC(18, 0), ISNULL(T.dblQty, L.dblQty) * I.dblWeight) AS dblNetWeight
		,'' AS dblNetWeight
		,PL.strParentLotNumber AS strLotNumber
	FROM tblMFOrderManifest OM
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = OM.intOrderHeaderId
	JOIN tblMFOrderDetail OD ON OD.intOrderDetailId = OM.intOrderDetailId
	JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intShipFromLocationId
	JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = S.intShipToLocationId
	JOIN tblICInventoryShipmentItem SI ON SI.intInventoryShipmentId = S.intInventoryShipmentId
	JOIN tblICItem I ON I.intItemId = SI.intItemId
		AND I.intItemId = OD.intItemId
	JOIN tblMFOrderManifestLabel OML ON OML.intOrderManifestId = OM.intOrderManifestId
		AND OML.ysnPrinted = 0
		AND OML.intCustomerLabelTypeId = @intCustomerLabelTypeId
	LEFT JOIN tblSMShipVia SV ON SV.intEntityId = S.intShipViaId
	LEFT JOIN tblICLot L ON L.intLotId = OM.intLotId
	LEFT JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN tblMFTask T ON T.intOrderHeaderId = OH.intOrderHeaderId
		AND T.intLotId = OM.intLotId
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
	SET @ErrMsg = 'uspMFReportUCCPalletLabel - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
