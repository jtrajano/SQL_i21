CREATE PROCEDURE [dbo].[uspGRGrainFlowReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	SET FMTONLY OFF
	SET NOCOUNT ON
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	-- XML Parameter Table
	DECLARE @temp_xml_table TABLE 
	(
		id int identity(1,1)
		,[fieldname] NVARCHAR(50)
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

	DECLARE @final_condition nvarchar(max) = ''
	
	UPDATE @temp_xml_table 
	SET [to] = CONVERT(nvarchar, DATEADD(day, 1,CAST([to] AS DATE)), 101) 
	WHERE datatype LIKE 'Date%' 
		AND ([to] IS NOT NULL AND [to] <> '')
	
	SELECT @final_condition = @final_condition + ' '  +
							dbo.fnAPCreateFilter(fieldname, condition, [from], [to], [join], begingroup, endgroup, datatype) + ' ' + [join]  
	FROM @temp_xml_table xml_table 
		WHERE condition <> 'Dummy'
	ORDER BY id ASC

	SET @final_condition = @final_condition + ' 1 = 1' 
	
	-- Query Parameters
	DECLARE @dtmTicketDateTimeFrom DATETIME
	DECLARE @dtmTicketDateTimeTo DATETIME
	
	DECLARE @MaxTicketNumber int = 999999999
	SELECT @dtmTicketDateTimeTo = [to]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmReceiptDate';

	SELECT @dtmTicketDateTimeFrom = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmReceiptDate';

	IF OBJECT_ID('tempdb..#tmpSampleExport') IS NOT NULL DROP TABLE #tmpSampleExport    

	DECLARE @sFrom nvarchar(50)
	DECLARE @sTo nvarchar(50)

	IF(@dtmTicketDateTimeFrom IS NULL)
		SET @sFrom = CONVERT(nvarchar, GETDATE(), 111)
	ELSE
		SET @sFrom = CONVERT(nvarchar, @dtmTicketDateTimeFrom, 111)


	IF (@dtmTicketDateTimeTo IS NULL)
		SET @sTo = CONVERT(nvarchar,  DATEADD(DAY, 1, GETDATE()), 111)
	ELSE 
		SET @sTo = CONVERT(nvarchar, DATEADD(day, 1, @dtmTicketDateTimeTo), 111)

	
	SELECT @sTo = REPLACE(@sTo, '/', '-') 
			,@sFrom = REPLACE(@sFrom, '/', '-') 

	SELECT TOP 0 * into #tmpSampleExport FROM vyuGRGrainFlowReport
	DECLARE @sqlcmd NVARCHAR(500)

	SET @sqlcmd = 'INSERT INTO #tmpSampleExport 
					SELECT *
					FROM vyuGRGrainFlowReport 
					WHERE ' + @final_condition
	exec (@sqlcmd)


	SELECT * FROM #tmpSampleExport

END