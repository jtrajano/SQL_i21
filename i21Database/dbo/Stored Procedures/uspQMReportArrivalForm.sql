CREATE PROCEDURE uspQMReportArrivalForm
    @xmlParam NVARCHAR(MAX) = NULL
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

	SELECT @intSampleId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intSampleId'

	SELECT pvt.*
		,pvt.[Rate (1-100)] AS Rate1to100
		,dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo
	FROM (
		SELECT S.intSampleId
			,S.strSampleNumber
			,I.strShortName + ', ' + I.strDescription AS strItemShortNameDescription
			,CH.strCustomerContract AS strPONo
			,CH.strContractNumber
			,S.strContainerNumber
			,E.strEntityName AS strVendor
			,S.strMarks
			,P.strPropertyName
			,TR.strPropertyValue
		FROM tblQMSample S
		JOIN tblICItem I ON I.intItemId = S.intItemId
			AND S.intSampleId = @intSampleId
		JOIN tblQMTestResult TR ON TR.intSampleId = S.intSampleId
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = S.intContractHeaderId
		LEFT JOIN vyuCTEntity E ON E.intEntityId = S.intEntityId
		) AS s
	PIVOT(MAX(strPropertyValue) FOR strPropertyName IN (
				[Volume]
				,[Moisture]
				,[Color]
				,[Uniformity]
				,[Acidity]
				,[Body]
				,[Flavor]
				,[Taints]
				,[Rate (1-100)]
				,[16]
				,[15]
				,[14]
				,[13]
				,[12]
				,[PAN]
				)) AS pvt
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportArrivalForm - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
