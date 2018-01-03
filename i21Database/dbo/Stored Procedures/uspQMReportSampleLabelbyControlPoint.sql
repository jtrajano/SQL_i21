-- Exec uspQMReportSampleLabelbyControlPoint '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intSampleId</fieldname><condition>EQUAL TO</condition><from>115</from><join /><begingroup /><endgroup /><datatype>Int32</datatype></filter></filters></xmlparam>'
CREATE PROCEDURE uspQMReportSampleLabelbyControlPoint @xmlParam NVARCHAR(MAX) = NULL
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
	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
	FROM tblSMCompanySetup

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	IF (@xmlParam IS NULL)
	BEGIN
		SELECT 0 intSampleId
			,'' strSampleNumber
			,'' dtmSampleReceivedDate
			,'' strSampleTypeName
			,'' strContractNumber
			,'' strBuyerReferenceNo
			,'' strSellerReferenceNo
			,'' strItemNo
			,'' strItemDescription
			,'' strPartyName
			,'' strRemarks
			,'' strOrigin
			,'' strRepresentingQtyUOM
			,'' strContainerNumber
			,'' strShipmentNumber
			,'' strBOLNumber
			,'' strLotNumber
			,'' strWarehouse
			,'' strCropYear
			,'' strPeriod
			,'' strFarmNumber
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip AS strCityStateZip
			,@strCountry AS strCompanyCountry

		RETURN
	END

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

	-- To check whether the sample is available
	DECLARE @intOrgSampleId INT

	SELECT @intOrgSampleId = intSampleId
	FROM tblQMSample
	WHERE intSampleId = @intSampleId

	IF (@intOrgSampleId IS NULL)
	BEGIN
		SELECT 0 intSampleId
			,'' strSampleNumber
			,'' dtmSampleReceivedDate
			,'' strSampleTypeName
			,'' strContractNumber
			,'' strBuyerReferenceNo
			,'' strSellerReferenceNo
			,'' strItemNo
			,'' strItemDescription
			,'' strPartyName
			,'' strRemarks
			,'' strOrigin
			,'' strRepresentingQtyUOM
			,'' strContainerNumber
			,'' strShipmentNumber
			,'' strBOLNumber
			,'' strLotNumber
			,'' strWarehouse
			,'' strCropYear
			,'' strPeriod
			,'' strFarmNumber
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip AS strCityStateZip
			,@strCountry AS strCompanyCountry

		RETURN
	END

	SELECT S.intSampleId
		,S.strSampleNumber
		,S.dtmSampleReceivedDate
		,ST.strSampleTypeName
		,ISNULL(CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq), '') AS strContractNumber
		,ISNULL(CH.strCustomerContract, '') AS strBuyerReferenceNo
		,ISNULL(CH.strCustomerContract, '') AS strSellerReferenceNo
		,I.strItemNo
		,I.strDescription AS strItemDescription
		,ISNULL(E.strName, '') AS strPartyName
		,ISNULL(S.strComment, '') AS strRemarks
		,ISNULL(S.strCountry, '') AS strOrigin
		,dbo.fnRemoveTrailingZeroes(ISNULL(S.dblRepresentingQty, 0)) + ' ' + UM.strUnitMeasure AS strRepresentingQtyUOM
		,ISNULL(S.strContainerNumber, '') AS strContainerNumber
		,ISNULL(L.strLoadNumber, '') AS strShipmentNumber
		,ISNULL(L.strBLNumber, '') AS strBOLNumber
		,ISNULL(S.strLotNumber, '') AS strLotNumber
		,ISNULL(CS.strSubLocationName, '') AS strWarehouse
		,ISNULL(CY.strCropYear, '') AS strCropYear
		,CONVERT(NVARCHAR, CD.dtmStartDate, 106) + ' - ' + CONVERT(NVARCHAR, CD.dtmEndDate, 106) AS strPeriod
		,ISNULL(EF.strFarmNumber, '') AS strFarmNumber
		,@strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strCity + ', ' + @strState + ', ' + @strZip AS strCityStateZip
		,@strCountry AS strCompanyCountry
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		AND S.intSampleId = @intSampleId
	JOIN tblICItem I ON I.intItemId = S.intItemId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = S.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblCTCropYear CY ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblEMEntityFarm EF ON EF.intFarmFieldId = CD.intFarmFieldId
	LEFT JOIN tblLGLoad L ON L.intLoadId = S.intLoadId
	LEFT JOIN tblEMEntity E ON E.intEntityId = S.intEntityId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intRepresentingUOMId
	LEFT JOIN tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportSampleLabelbyControlPoint - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
