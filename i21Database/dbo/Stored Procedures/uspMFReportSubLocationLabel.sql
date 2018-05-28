CREATE PROCEDURE uspMFReportSubLocationLabel
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intSubLocationId NVARCHAR(MAX)
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

	SELECT @intSubLocationId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intSubLocationId'

	SELECT intCompanyLocationSubLocationId
		,strSubLocationName
		,strSubLocationDescription
	FROM tblSMCompanyLocationSubLocation CSL
	WHERE CSL.intCompanyLocationSubLocationId IN (
			SELECT *
			FROM dbo.fnSplitString(@intSubLocationId, '^')
			)
	ORDER BY CSL.strSubLocationName
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspMFReportSubLocationLabel - ' + ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
