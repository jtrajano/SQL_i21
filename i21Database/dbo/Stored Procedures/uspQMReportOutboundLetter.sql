-- Exec uspQMReportOutboundLetter '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intSampleId</fieldname><condition>EQUAL TO</condition><from>37</from><join /><begingroup /><endgroup /><datatype>Int32</datatype></filter></filters></xmlparam>'
CREATE PROCEDURE uspQMReportOutboundLetter @xmlParam NVARCHAR(MAX) = NULL
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
		,@intContractDetailId INT
		,@strCertificationName NVARCHAR(MAX)
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
			,'' strSampleTypeName
			,'We herewith send you below samples.' AS strMsg1
			,'Kindly send your testing results to: ' AS strMsg2
			,'samples@douque.com' AS strMsg3
			,'' strContractNumber
			,'' strCustomerReference
			,'' strRepresentingQtyUOM
			,'' strItemDescription
			,'' strCertifiedType
			,'' strRemarks
			,'' strShipper
			,'' strWarehouse
			,'' strCeelNo
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strZip + ' ' + @strCity + ' ' + @strState AS strZipCityState
			,@strCountry AS strCompanyCountry
			,'' AS strPartyName
			,'' AS strPartyAddress
			,'' AS strPartyZipCityState
			,'' AS strPartyCountry
			,NULL AS blbFooterLogo

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
		,@intContractDetailId = intContractDetailId
	FROM tblQMSample
	WHERE intSampleId = @intSampleId

	IF (@intOrgSampleId IS NULL)
	BEGIN
		SELECT 0 intSampleId
			,'' strSampleNumber
			,'' strSampleTypeName
			,'We herewith send you below samples.' AS strMsg1
			,'Kindly send your testing results to: ' AS strMsg2
			,'samples@douque.com' AS strMsg3
			,'' strContractNumber
			,'' strCustomerReference
			,'' strRepresentingQtyUOM
			,'' strItemDescription
			,'' strCertifiedType
			,'' strRemarks
			,'' strShipper
			,'' strWarehouse
			,'' strCeelNo
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strZip + ' ' + @strCity + ' ' + @strState AS strZipCityState
			,@strCountry AS strCompanyCountry
			,'' AS strPartyName
			,'' AS strPartyAddress
			,'' AS strPartyZipCityState
			,'' AS strPartyCountry
			,NULL AS blbFooterLogo

		RETURN
	END

	SELECT @strCertificationName = COALESCE(@strCertificationName + ', ', '') + CONVERT(NVARCHAR, IC.strCertificationName)
	FROM tblCTContractCertification CC
	JOIN tblICCertification IC ON IC.intCertificationId = CC.intCertificationId
	WHERE CC.intContractDetailId = @intContractDetailId

	SELECT S.intSampleId
		,S.strSampleNumber
		,ST.strSampleTypeName
		,'We herewith send you below samples.' AS strMsg1
		,'Kindly send your testing results to: ' AS strMsg2
		,'samples@douque.com' AS strMsg3
		,ISNULL(CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq), '') AS strContractNumber
		,ISNULL(CH.strCustomerContract, '') AS strCustomerReference
		,dbo.fnRemoveTrailingZeroes(ISNULL(S.dblRepresentingQty, 0)) + ' ' + UM.strUnitMeasure AS strRepresentingQtyUOM
		,CASE 
			WHEN ISNULL(CD.strItemSpecification, '') = ''
				THEN I.strDescription
			ELSE I.strDescription + ', ' + CD.strItemSpecification
			END AS strItemDescription
		,ISNULL(@strCertificationName, '') AS strCertifiedType
		,ISNULL(S.strComment, '') AS strRemarks
		,ISNULL(E.strName, '') AS strShipper
		,ISNULL(CS.strSubLocationName, '') AS strWarehouse
		,ISNULL(S.strLotNumber, '') AS strCeelNo
		,@strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strZip + ' ' + @strCity + ' ' + @strState AS strZipCityState
		,@strCountry AS strCompanyCountry
		,E1.strName AS strPartyName
		,EL.strAddress AS strPartyAddress
		,EL.strZipCode + ' ' + EL.strCity + ' ' + EL.strState AS strPartyZipCityState
		,EL.strCountry AS strPartyCountry
		,dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		AND S.intSampleId = @intSampleId
	JOIN tblICItem I ON I.intItemId = S.intItemId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = S.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intRepresentingUOMId
	LEFT JOIN tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
	LEFT JOIN tblEMEntity E ON E.intEntityId = CD.intShipperId
	LEFT JOIN tblEMEntity E1 ON E1.intEntityId = S.intEntityId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = E1.intEntityId
		AND EL.ysnDefaultLocation = 1
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportOutboundLetter - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
