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
			SELECT		TOP 1 intAttachmentId
			FROM		tblSMAttachment AS a
			INNER JOIN	tblSMTransaction AS b
			ON			a.intTransactionId = b.intTransactionId
			INNER JOIN	tblSMScreen AS c
			ON			b.intScreenId = c.intScreenId
			WHERE		c.strNamespace = 'SystemManager.view.CompanyPreference'
					AND a.strComment = 'Header'
			ORDER BY	intAttachmentId DESC
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
		,CONVERT(VARCHAR(10), IsNULL(L.dtmDeliveredDate,dtmScheduledDate), 101) AS [dtmScheduledDate]
		,(CL.strLocationName + CHAR(13) + CHAR(10) + CL.strAddress + CHAR(13) + CHAR(10) + CL.strCity + ',  ' + strStateProvince + '  ' + strZipPostalCode) AS strShipperAddress --- + CHAR(13) + CHAR(10) + 'Phone : ' + CL.strPhone
		,CASE WHEN L.intLoadId IS NOT NULL
			THEN E.strName + CHAR(13) + CHAR(10) + EL.strLocationName + CHAR(13) + CHAR(10) + EL.strAddress + CHAR(13) + CHAR(10) + EL.strCity + ',' + EL.strState
			ELSE EP.strName + CHAR(13) + CHAR(10) + EPL.strLocationName + CHAR(13) + CHAR(10) + EPL.strAddress + CHAR(13) + CHAR(10) + EPL.strCity + ',' + EPL.strState
			END AS [To Address]
		,strPropertyName
		,strPropertyValue
		,CASE 
			WHEN strResult = 'Failed'
				THEN ' OOS'
			ELSE ''
			END AS strResult
		,('       ' + strTestMethod) strTestMethod
		,@companyLogo CompanyLogo
		,S.strMarks
		,S.strComment
		,S.strRefNo
		,@strCheckPayeeName strCheckPayeeName
		,S.strLotNumber
		,0.0 dblLotQuantity
		,'' AS strUnitMeasure
		--,IsNULL(Rtrim(Ltrim(L1.strLotNumber + ' ' + '(' + convert(NVARCHAR(50), Convert(Decimal(24,2),SUM(LDL.dblLotQuantity))) + ' ' + UM.strUnitMeasure + ')')),Rtrim(Ltrim(S.strLotNumber + ' ' + '(' + convert(NVARCHAR(50), Convert(Decimal(24,2),SUM(IsNULL(LD.dblQuantity,S.dblRepresentingQty)))) + ' ' + UM.strUnitMeasure + ')'))) AS [LotDetails]
		,S.strLotNumber AS [LotDetails]
		,@UserSign AS UserSignature
		,(
			CASE 
				WHEN ISNULL(PRD.strNote, '') = ''
					THEN @strTestReportComments
				ELSE PRD.strNote
				END
			) AS strNote
		,TR.intSequenceNo
	FROM tblQMSample S
	INNER JOIN tblICItem I ON I.intItemId = S.intItemId
		AND S.intSampleId = @intSampleId
	INNER JOIN tblQMTestResult TR ON TR.intSampleId = S.intSampleId
	INNER JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	INNER JOIN tblQMTest T ON T.intTestId = TR.intTestId
	INNER JOIN tblQMProduct PRD ON PRD.intProductId = TR.intProductId
	INNER JOIN tblQMProductProperty PP ON PP.intProductId = PRD.intProductId
		AND PP.intTestId = TR.intTestId
		AND PP.intPropertyId = TR.intPropertyId
		AND PP.ysnPrintInLabel = 1
	LEFT JOIN tblLGLoad L ON L.intLoadId = S.intLoadId
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId and LD.intItemId =S.intItemId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = LD.intCustomerEntityLocationId
	LEFT JOIN tblEMEntity E ON EL.intEntityId = E.intEntityId
	LEFT JOIN (tblEMEntity EP INNER JOIN tblEMEntityLocation EPL ON EPL.intEntityId = EP.intEntityId AND EPL.ysnDefaultLocation = 1) ON EP.intEntityId = S.intEntityId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = ISNULL(LD.intSCompanyLocationId, S.intLocationId)
	--WHERE S.intSampleId = @intSampleId
	GROUP BY strItemNo
		,I.strDescription
		,strLoadNumber
		,IsNULL(L.dtmDeliveredDate,dtmScheduledDate)
		,CL.strAddress
		,CL.strCity
		,strStateProvince
		,strZipPostalCode
		,CL.strPhone
		,E.strName
		,EL.strLocationName
		,EL.strAddress
		,EL.strCity
		,EL.strState
		,EP.strName
		,EPL.strLocationName
		,EPL.strAddress
		,EPL.strCity
		,EPL.strState
		,strPropertyName
		,strPropertyValue
		,strTestMethod
		,S.strMarks
		,S.strComment
		,S.strRefNo
		,EL.strCheckPayeeName
		,S.strLotNumber
		,CL.strLocationName
		,PRD.strNote
		,TR.intSequenceNo
		,strResult
		,L.intLoadId
	ORDER BY TR.intSequenceNo
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
