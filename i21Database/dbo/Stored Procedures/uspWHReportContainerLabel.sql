CREATE PROCEDURE uspWHReportContainerLabel 
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strContainerNo NVARCHAR(100)
		,@xmlDocumentId INT

--RAISERROR('TEST' ,16,1)

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

	SELECT @strContainerNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strContainerNo'
	
	SELECT clsl.intCompanyLocationId, 
		   UPPER(c.strContainerNo) ContainerBarcode
	FROM tblWHContainer c
	INNER JOIN tblICStorageLocation sl ON sl.intStorageLocationId = c.intStorageLocationId
	INNER JOIN tblSMCompanyLocationSubLocation clsl ON sl.intSubLocationId = clsl.intCompanyLocationSubLocationId
	WHERE strContainerNo = @strContainerNo

END TRY

BEGIN CATCH

	SET @strErrMsg = 'uspWHReportContainerLabel - ' + ERROR_MESSAGE()
	RAISERROR (@strErrMsg,18,1,'WITH NOWAIT')
	
END CATCH