CREATE PROCEDURE uspQMReportTest @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT
	DECLARE @intSampleId INT
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

	SELECT @companyLogo = blbFile
	FROM tblSMUpload
	WHERE intAttachmentId = (
			SELECT TOP 1 intAttachmentId
			FROM tblSMAttachment
			WHERE strScreen = 'SystemManager.CompanyPreference'
				AND strComment = 'Header'
			ORDER BY intAttachmentId DESC
			)

	SELECT @strTestReportComments = ISNULL(strTestReportComments, '')
	FROM tblQMCompanyPreference

	SELECT strItemNo + '-' + I.strDescription AS strItemNo
		,strLoadNumber
		,strSealNumber
		,CONVERT(VARCHAR(8), dtmScheduledDate, 1) AS [dtmScheduledDate]
		,CL.strAddress
		,(CL.strAddress + CHAR(13) + CHAR(10) + CL.strCity + ' ' + strStateProvince + ' ' + strZipPostalCode + CHAR(13) + CHAR(10) + 'Phone : ' + CL.strPhone) AS strShipperAddress
		,E.strName + CHAR(13) + CHAR(10) + EL.strLocationName + CHAR(13) + CHAR(10) + EL.strAddress + CHAR(13) + CHAR(10) + EL.strCity + ',' + strState AS [To Address]
		,strPropertyName
		,strPropertyValue
		,strTestMethod
		,@companyLogo companyLogo
		,(
			CASE 
				WHEN ISNULL(PRD.strNote, '') = ''
					THEN @strTestReportComments
				ELSE PRD.strNote
				END
			) AS CompanyPreference
	FROM tblQMSample S
	INNER JOIN tblICItem I ON I.intItemId = S.intItemId
		AND S.intSampleId = @intSampleId
	INNER JOIN tblQMTestResult TR ON TR.intSampleId = S.intSampleId
	INNER JOIN tblQMProduct PRD ON PRD.intProductId = TR.intProductId
	INNER JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	INNER JOIN tblQMTest T ON T.intTestId = TR.intTestId
	LEFT JOIN tblLGLoad L ON L.intLoadId = S.intLoadId
	LEFT JOIN tblLGLoadContainer C ON C.intLoadId = S.intLoadId
	LEFT JOIN tblEMEntity E ON E.intEntityId = L.intEntityId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = L.intEntityLocationId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = L.intCompanyLocationId
		--WHERE S.intSampleId = @intSampleId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportTest - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
