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
	FROM dbo.tblSMCompanySetup

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	IF (@xmlParam IS NULL)
	BEGIN
		SELECT NULL intSampleId
			,NULL strSampleNumber
			,NULL strItemShortNameDescription
			,NULL strPONo
			,NULL strContractNumber
			,NULL strContainerNumber
			,NULL strVendor
			,NULL strMarks
			,NULL Volume
			,NULL Moisture
			,NULL Color
			,NULL Uniformity
			,NULL Acidity
			,NULL Body
			,NULL Flavor
			,NULL [Taints/Defects]
			,NULL [Rate (1-100)]
			,NULL [Screen size (16)]
			,NULL [Screen size (15)]
			,NULL [Screen size (14)]
			,NULL [Screen size (13)]
			,NULL [Screen size (12)]
			,NULL [Screen size (PAN)]
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
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

	DECLARE @strFieldNames NVARCHAR(MAX) = ''
	DECLARE @strFieldNamesWithAlias NVARCHAR(MAX) = ''
	DECLARE @SQL NVARCHAR(MAX)

	SELECT @strFieldNames = @strFieldNames + '[' + strActualPropertyName + ']' + ','
		,@strFieldNamesWithAlias = @strFieldNamesWithAlias + '[' + strActualPropertyName + '] AS [' + strPropertyName + '],'
	FROM tblQMReportCuppingPropertyMapping

	IF LEN(@strFieldNames) > 0
		SET @strFieldNames = LEFT(@strFieldNames, CASE 
					WHEN ISNULL(@strFieldNames, '') = ''
						THEN 0
					ELSE LEN(@strFieldNames) - 1
					END)

	IF LEN(@strFieldNamesWithAlias) > 0
		SET @strFieldNamesWithAlias = LEFT(@strFieldNamesWithAlias, CASE 
					WHEN ISNULL(@strFieldNamesWithAlias, '') = ''
						THEN 0
					ELSE LEN(@strFieldNamesWithAlias) - 1
					END)
	SET @SQL = 'SELECT intSampleId,
		strSampleNumber,
		strItemShortNameDescription,
		strPONo,
		strContractNumber,
		strContainerNumber,
		strVendor,
		strMarks,
		@strCompanyName AS strCompanyName,
		@strCompanyAddress AS strCompanyAddress,
		@strCity + '', '' + @strState + '', '' + @strZip + '','' AS strCityStateZip,
		@strCountry AS strCompanyCountry,
		' + @strFieldNamesWithAlias + ' FROM (
		SELECT S.intSampleId
			,S.strSampleNumber
			,I.strShortName + '', '' + I.strDescription AS strItemShortNameDescription
			,CH.strCustomerContract AS strPONo
			,CH.strContractNumber
			,S.strContainerNumber
			,E.strEntityName AS strVendor
			,S.strMarks
			,P.strPropertyName
			,TR.strPropertyValue
		FROM tblQMSample S
		JOIN tblICItem I ON I.intItemId = S.intItemId
			AND S.intSampleId = ' + CONVERT(NVARCHAR, @intSampleId) + 
		'JOIN tblQMTestResult TR ON TR.intSampleId = S.intSampleId
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		LEFT JOIN vyuCTContractDetailView CH ON CH.intContractDetailId = S.intContractDetailId
		LEFT JOIN vyuCTEntity E ON E.intEntityId = S.intEntityId
		) AS s
	PIVOT(MAX(strPropertyValue) FOR strPropertyName IN (' + @strFieldNames + ')) AS pvt'

	EXEC sp_executesql @SQL
		,N'@strCompanyName NVARCHAR(100), @strCompanyAddress NVARCHAR(100), @strCity NVARCHAR(25), @strState NVARCHAR(50), @strZip NVARCHAR(12), @strCountry NVARCHAR(25)'
		,@strCompanyName
		,@strCompanyAddress
		,@strCity
		,@strState
		,@strZip
		,@strCountry
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
