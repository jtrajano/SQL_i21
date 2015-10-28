﻿CREATE PROCEDURE uspMFReportGTINCaseBarcode @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strWorkOrderNo NVARCHAR(50)
		,@xmlDocumentId INT
		,@strUserName NVARCHAR(50)
		,@strGTINCaseCode NVARCHAR(50)

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

	SELECT @strWorkOrderNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strWorkOrderNo'

	SELECT @strUserName = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strUserName'

	SELECT @strGTINCaseCode = strGTINCaseCode
	FROM tblMFCompanyPreference

	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,IsNULL(PS.strParameterValue, I.strItemNo) AS strValue
		,GETDATE() AS dtmDate
		,@strUserName AS strUserName
	FROM tblMFWorkOrder W
	JOIN tblICItem I ON W.intItemId = I.intItemId
	LEFT JOIN dbo.tblMFWorkOrderProductSpecification PS ON W.intWorkOrderId = PS.intWorkOrderId
		AND PS.strParameterName = @strGTINCaseCode
	WHERE W.strWorkOrderNo = @strWorkOrderNo

	EXEC sp_xml_removedocument @xmlDocumentId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFReportProductSpecification - ' + ERROR_MESSAGE()

	IF @xmlDocumentId <> 0
		EXEC sp_xml_removedocument @xmlDocumentId

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


