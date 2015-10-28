CREATE PROCEDURE uspQMReportSampleLabel @xmlParam NVARCHAR(MAX) = NULL
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

	SELECT TOP 1 I.strItemNo
		,I.strDescription
		,S.strSampleNumber
		,CONVERT(NVARCHAR, S.dtmSampleReceivedDate, 107) AS dtmSampleReceivedDate
		,CASE 
			WHEN C.strCategoryCode = 'C'
				THEN L.strLotNumber
			ELSE ''
			END AS strLotNumber
		,PL.strParentLotNumber
		,ST.strDescription AS strSampleTypeDescription
		,C.strCategoryCode
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
	JOIN tblICItem I ON S.intItemId = I.intItemId
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	LEFT JOIN tblQMTestResult TR ON TR.intSampleId = S.intSampleId
		AND TR.intProductTypeId = 11
	LEFT JOIN tblICParentLot PL ON PL.intParentLotId = TR.intProductValueId
	LEFT JOIN tblICLot L ON PL.intParentLotId = L.intParentLotId
	WHERE S.intSampleId = @intSampleId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportSampleLabel - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
