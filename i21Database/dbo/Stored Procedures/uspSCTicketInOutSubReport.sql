CREATE PROCEDURE [dbo].[uspSCTicketInOutSubReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
begin
	SET FMTONLY OFF

	--IF OBJECT_ID('tempdb..##tmpTblGRDestinationWeightVariance') IS NOT NULL
	--	DROP TABLE ##tmpTblGRDestinationWeightVariance
	
	--IF OBJECT_ID('tempdb..##tmpTblGRDestinationWeightVarianceLogs') IS NOT NULL
	--	DROP TABLE ##tmpTblGRDestinationWeightVarianceLogs

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

	-- Query Parameters
	DECLARE 
		@dtmTicketDateTimeFrom DATETIME
		,@dtmTicketDateTimeTo DATETIME
		;
	

	SELECT @dtmTicketDateTimeTo = [to]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmTicketDateTime';

	SELECT @dtmTicketDateTimeFrom = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmTicketDateTime';

	/*
	select 
	   strGroupIndicator as strStorageTypeDescription
	   , sum(dblGrossUnits) as dblGrossUnits 

	from vyuSCTicketInOutReport
		where (@dtmTicketDateTimeTo is null or (dtmTicketDateTime between @dtmTicketDateTimeFrom and dateadd(day, 1, @dtmTicketDateTimeTo) ) )

	group by strGroupIndicator
	
	*/

	declare @sFrom nvarchar(50)
	declare @sTo nvarchar(50)

	if(@dtmTicketDateTimeFrom is null)
		set @sFrom = convert(nvarchar, GETDATE(), 111)
	else 
		set @sFrom = convert(nvarchar, @dtmTicketDateTimeFrom, 111)


	if(@dtmTicketDateTimeTo is null)
		set @sTo = convert(nvarchar,  dateadd(day, 1, GETDATE()), 111)
	else 
		set @sTo = convert(nvarchar, dateadd(day, 1, @dtmTicketDateTimeTo), 111)

	
	select @sTo = replace(@sTo, '/', '-') 
			,@sFrom = replace(@sFrom, '/', '-') 

	declare @sqlcmd nvarchar(500)
	set @sqlcmd = 'select 
					   strGroupIndicator as strStorageTypeDescription
					   , sum(dblGrossUnits) as dblGrossUnits 

					from vyuSCTicketInOutReport
						where (dtmTicketDateTime between ''' + @sFrom + ''' and  ''' + @sTo + ''')
						group by strGroupIndicator	
					'


	exec (@sqlcmd)

end


go
