CREATE PROCEDURE [dbo].[uspGRReportSplitView]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	SET FMTONLY OFF
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	-- XML Parameter Table
	DECLARE @temp_xml_table TABLE 
	(
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(MAX)
		,[to] NVARCHAR(MAX)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)
	DECLARE @xmlDocumentId AS INT

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH 
	(
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)

	DECLARE @strMainEntityName nvarchar(100)


	SELECT @strMainEntityName = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strMainEntityName';

	
	select 
	strMainEntityName	
	, intEntityId
	, strEntityNo
	, intSplitId
	, strSplitInfo 
	, strSplitDetailName
	, dblSplitPercent
	from [vyuGRReportSplitView]
		where ( @strMainEntityName is null or strMainEntityName = @strMainEntityName )

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
