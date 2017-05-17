CREATE PROCEDURE uspMFReportUCCPalletLabel @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intInventoryShipmentId INT
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

	SELECT @intInventoryShipmentId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intInventoryShipmentId'

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
		,S.strReferenceNumber AS strPONumber
		,I.strGTIN AS strDPCI
		,I.intInnerUnits AS intCasePack
		,I.strItemNo AS strStyle
		,'(00) 3 0012511 000130720 2' AS strBarCodeLabel -- Check with Prem
		,'00000846430018142227' AS strBarCode -- Check with Prem
	FROM tblICInventoryShipment S
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intShipFromLocationId
	JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = S.intShipToLocationId
	JOIN tblICInventoryShipmentItem SI ON SI.intInventoryShipmentId = S.intInventoryShipmentId
	JOIN tblICItem I ON I.intItemId = SI.intItemId
	LEFT JOIN tblSMShipVia SV ON SV.intEntityId = S.intShipViaId
	WHERE S.intInventoryShipmentId = @intInventoryShipmentId
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
