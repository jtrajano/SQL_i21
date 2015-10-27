CREATE PROCEDURE uspMFReportProductSpecification @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intWorkOrderId INT
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

	SELECT @intWorkOrderId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intWorkOrderId'

	SELECT intWorkOrderId
		,strParameterName
		,strParameterValue
	FROM dbo.tblMFWorkOrderProductSpecification
	WHERE intWorkOrderId = @intWorkOrderId
	ORDER BY intWorkOrderId
		,strParameterName
		,strParameterValue
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFReportProductSpecification - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


