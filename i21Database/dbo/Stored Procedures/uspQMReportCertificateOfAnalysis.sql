CREATE PROCEDURE uspQMReportCertificateOfAnalysis @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT
	DECLARE @strUserName NVARCHAR(200)
	DECLARE @strCheckPayeeName NVARCHAR(50)
	DECLARE @UserSign VARBINARY(MAX)
	DECLARE @intSampleId INT
	Declare @ysnShowItemDescriptionOnly BIT
	DECLARE @strTestReportComments NVARCHAR(max)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @companyLogo VARBINARY(max)
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

	SELECT @strUserName = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strUserName'

	SELECT @companyLogo = blbFile
	FROM tblSMUpload
	WHERE intAttachmentId = (
			SELECT TOP 1 intAttachmentId
			FROM tblSMAttachment
			WHERE strScreen = 'SystemManager.CompanyPreference'
				AND strComment = 'Header'
			ORDER BY intAttachmentId DESC
			)

	SELECT TOP 1 @UserSign = Sig.blbDetail
	FROM tblSMSignature Sig
	JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId = Sig.intSignatureId
	WHERE Sig.intEntityId = (
			SELECT TOP 1 intEntityId
			FROM tblSMUserSecurity
			WHERE strUserName = @strUserName
			)

	SELECT @strCheckPayeeName = strCheckPayeeName
	FROM tblEMEntityLocation
	WHERE intEntityId = (
			SELECT TOP 1 intEntityId
			FROM tblSMUserSecurity
			WHERE strUserName = @strUserName
			)

	Select @ysnShowItemDescriptionOnly=ysnShowItemDescriptionOnly
			,@strTestReportComments = ISNULL(strTestReportComments, '')
	from tblQMCompanyPreference

	SELECT Case When @ysnShowItemDescriptionOnly=1 Then I.strDescription Else strItemNo + '-' + I.strDescription End AS strItemNo
		,strLoadNumber
		,CONVERT(VARCHAR(8), dtmScheduledDate, 1) AS [dtmScheduledDate]
		,(CL.strLocationName + CHAR(13) + CHAR(10) + CL.strAddress + CHAR(13) + CHAR(10) + CL.strCity + ',  ' + strStateProvince + '  ' + strZipPostalCode) AS strShipperAddress --- + CHAR(13) + CHAR(10) + 'Phone : ' + CL.strPhone
		,E.strName + CHAR(13) + CHAR(10) + EL.strLocationName + CHAR(13) + CHAR(10) + EL.strAddress + CHAR(13) + CHAR(10) + EL.strCity + ',' + strState AS [To Address]
		,strPropertyName
		,strPropertyValue
		,('       ' + strTestMethod) strTestMethod
		,@companyLogo CompanyLogo
		,S.strMarks
		,S.strComment
		,S.strRefNo
		,@strCheckPayeeName strCheckPayeeName
		,L1.strLotNumber
		,Convert(Decimal(24,2),SUM(LDL.dblLotQuantity)) dblLotQuantity
		,UM.strUnitMeasure
		,Rtrim(Ltrim(L1.strLotNumber + ' ' + '(' + convert(NVARCHAR(50), Convert(Decimal(24,2),SUM(LDL.dblLotQuantity))) + ' ' + UM.strUnitMeasure + ')')) AS [LotDetails]
		,@UserSign AS UserSignature
		,(
			CASE 
				WHEN ISNULL(PRD.strNote, '') = ''
					THEN @strTestReportComments
				ELSE PRD.strNote
				END
			) AS strNote
	FROM tblQMSample S
	INNER JOIN tblICItem I ON I.intItemId = S.intItemId
	INNER JOIN tblQMTestResult TR ON TR.intSampleId = S.intSampleId
	INNER JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	INNER JOIN tblQMTest T ON T.intTestId = TR.intTestId
	INNER JOIN tblQMProduct PRD ON PRD.intProductId = TR.intProductId
	LEFT JOIN tblLGLoad L ON L.intLoadId = S.intLoadId
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblICLot L1 ON L1.intLotId = LDL.intLotId
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LDL.intItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = LD.intCustomerEntityLocationId
	LEFT JOIN tblEMEntity E ON EL.intEntityId = E.intEntityId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = ISNULL(LD.intSCompanyLocationId, S.intLocationId)
	WHERE S.intSampleId = @intSampleId
	GROUP BY strItemNo
		,I.strDescription
		,strLoadNumber
		,dtmScheduledDate
		,CL.strAddress
		,CL.strCity
		,strStateProvince
		,strZipPostalCode
		,CL.strPhone
		,E.strName
		,EL.strLocationName
		,EL.strAddress
		,EL.strCity
		,strState
		,strPropertyName
		,strPropertyValue
		,strTestMethod
		,S.strMarks
		,S.strComment
		,S.strRefNo
		,EL.strCheckPayeeName
		,L1.strLotNumber
		,UM.strUnitMeasure
		,CL.strLocationName
		,PRD.strNote
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportCertificateOfAnalysis - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
