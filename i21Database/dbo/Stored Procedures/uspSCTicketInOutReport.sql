﻿CREATE PROCEDURE [dbo].[uspSCTicketInOutReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
begin
	SET FMTONLY OFF
	SET NOCOUNT ON
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
	

	declare @final_condition nvarchar(max) = ''
	
	update @temp_xml_table set [to] = convert(nvarchar, dateadd(day, 1,cast([to] as date)), 101) where datatype like 'Date%' and ([to] is not null and [to] <> '')
	
	select @final_condition  = @final_condition + ' '  + dbo.fnAPCreateFilter(fieldname, condition, [from], [to], [join], begingroup, endgroup, datatype) + ' ' + [join]  
		from @temp_xml_table xml_table 
			where condition <> 'Dummy'
		order by id asc

	set @final_condition = @final_condition + ' 1 = 1' 
	--select @final_condition
	-- Query Parameters
	DECLARE 
		@dtmTicketDateTimeFrom DATETIME
		,@dtmTicketDateTimeTo DATETIME
		;
	
	DECLARE @MaxTicketNumber int = 999999999
	SELECT @dtmTicketDateTimeTo = [to]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmTicketDateTime';

	SELECT @dtmTicketDateTimeFrom = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmTicketDateTime';

	IF OBJECT_ID('tempdb..#tmpSampleExport') IS NOT NULL DROP TABLE #tmpSampleExport
    

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

	select top 0 cast(null as int ) as intTicketNumber, strTicketNumber as strModTicketNumber, * into #tmpSampleExport from vyuSCTicketInOutReport
	declare @sqlcmd nvarchar(500)
	set @sqlcmd = 'insert into #tmpSampleExport 
					select null as intTicketNumber
							, strTicketNumber as strModTicketNumber
							, *  
					from vyuSCTicketInOutReport 
					where ' + @final_condition


	-- print @sqlcmd
	exec (@sqlcmd)
	

	update #tmpSampleExport set strModTicketNumber = dbo.fnSCGetStartingNumericValue(strTicketNumber) --where isnumeric(strTicketNumber) = 0

	update #tmpSampleExport set intTicketNumber = case when isnumeric(strModTicketNumber) = 1 then cast(strModTicketNumber as int) else @MaxTicketNumber end
						,strModTicketNumber= case when isnumeric(strModTicketNumber) = 1 then '' else strModTicketNumber end


	declare @Min int
	declare @Max int

	/*
	declare @MinMaxTable table ( id int identity(1,1), intMin int, intMax int, intDifference int, intLocationId int, strIndicator nvarchar(50))
	declare @RangedTicketNumber table( intTicketNumber int, intLocationId int, strIndicator nvarchar(50) )

	
	insert @MinMaxTable ( intMin, intMax, intLocationId, strIndicator)
	select min(intTicketNumber), max(intTicketNumber), intProcessingLocationId, strIndicator
		from #tmpSampleExport
			where intTicketNumber < @MaxTicketNumber
				and isnumeric(strTicketNumber) = 1
			group by intProcessingLocationId, strIndicator

	update @MinMaxTable set intDifference = intMax - intMin
	
	declare @CurrentLocationId int
	declare @CurrentIndicator nvarchar(50)

	declare @id int
	select @id= min(id) from @MinMaxTable
	
	while @id is not null
	begin

		
		select @Min = intMin
			, @Max = intMax
			, @CurrentIndicator = strIndicator
			, @CurrentLocationId = intLocationId
		from @MinMaxTable
			where id = @id
		


		while @Min <= @Max
		begin
			insert into @RangedTicketNumber(intTicketNumber, intLocationId, strIndicator)
			select @Min, @CurrentLocationId, @CurrentIndicator

			set @Min = @Min + 1
		end

		if exists(select top 1 1 
						from #tmpSampleExport 
							where intTicketNumber = @MaxTicketNumber 
								and intProcessingLocationId = @CurrentLocationId
								and strIndicator = @CurrentIndicator)
		begin
			insert into @RangedTicketNumber (intTicketNumber, intLocationId, strIndicator)
			select @MaxTicketNumber, @CurrentLocationId, @CurrentIndicator
		end

		insert into @RangedTicketNumber (intTicketNumber, intLocationId)
		select intTicketNumber, intProcessingLocationId 
			from #tmpSampleExport
				where intTicketNumber < @MaxTicketNumber
				and isnumeric(strTicketNumber) = 0
				and intProcessingLocationId = @CurrentLocationId
				and strIndicator = @CurrentIndicator

		select @id = min(id) 
			from @MinMaxTable 
				where id > @id
		
	end

	*/
	select 
	
		AllExport.intTicketNumber
		,AllExport.intTicketId
		,case when AllExport.intTicketNumber is null then cast(AllExport.intTicketNumber as nvarchar(50)) + '*' else AllExport.strTicketNumber end as strTicketNumber
		,AllExport.strName
		,CompanyLocation.strLocationName
		,AllExport.strStorageTypeDescription
		,case when AllExport.intTicketNumber is null then cast(AllExport.strIndicator as nvarchar(50)) else AllExport.strIndicator end as strIndicator
		,AllExport.dblGrossUnits
		,AllExport.intTicketType
		,AllExport.strTicketType
		,AllExport.dtmTicketDateTime
		,AllExport.strGroupIndicator
		,AllExport.intProcessingLocationId

		,AllExport.strItemNo
		,AllExport.strCommodityCode
		,AllExport.strUnitMeasure
		,AllExport.dblComputedGrossUnits
		,AllExport.strStationUnitMeasure
		,AllExport.dblNetUnits
		,AllExport.dblComputedNetUnits
		,CASE WHEN TICKET.intDeliverySheetId IS NULL 
		THEN SUBSTRING((
				SELECT ','+ ICI2.strItemNo + '=' + LTRIM(STR(QMD2.dblGradeReading, 10, 2))
				FROM tblSCTicket SC2
				INNER JOIN tblQMTicketDiscount QMD2
					ON QMD2.intTicketId = SC2.intTicketId and QMD2.strSourceType = 'Scale'
				INNER JOIN tblGRDiscountScheduleCode DSC2
					ON QMD2.intDiscountScheduleCodeId = DSC2.intDiscountScheduleCodeId
				INNER JOIN tblICItem ICI2
					ON ICI2.intItemId = DSC2.intItemId
				WHERE (QMD2.dblGradeReading IS NOT NULL AND QMD2.dblGradeReading > 0) and SC2.intTicketId = TICKET.intTicketId
				FOR XML PATH('')
			),2,1000) 
		ELSE SUBSTRING((
				SELECT ','+ ICI2.strItemNo + '=' + LTRIM(STR(QMD2.dblGradeReading, 10, 2)) FROM tblSCDeliverySheet DSS2
				INNER JOIN tblSCTicket SC2
					ON DSS2.intDeliverySheetId = SC2.intDeliverySheetId
				INNER JOIN tblQMTicketDiscount QMD2
					ON QMD2.intTicketFileId = DSS2.intDeliverySheetId and QMD2.strSourceType = 'Delivery Sheet'
				INNER JOIN tblGRDiscountScheduleCode DSC2
					ON QMD2.intDiscountScheduleCodeId = DSC2.intDiscountScheduleCodeId
				INNER JOIN tblICItem ICI2
					ON ICI2.intItemId = DSC2.intItemId
				WHERE (QMD2.dblGradeReading IS NOT NULL AND QMD2.dblGradeReading > 0) and SC2.intTicketId = TICKET.intTicketId 
				FOR XML PATH('')
			),2,1000)
	END COLLATE Latin1_General_CI_AS AS  strGradeReading
		from #tmpSampleExport AllExport				
			JOIN tblSCTicket TICKET
				ON AllExport.intTicketId = TICKET.intTicketId
			left join tblSMCompanyLocation CompanyLocation
				on AllExport.intProcessingLocationId = CompanyLocation.intCompanyLocationId
			
			order by AllExport.intTicketNumber asc, strModTicketNumber
			/*
		from @RangedTicketNumber AllTicketNumber
			join #tmpSampleExport AllExport
				on AllTicketNumber.intTicketNumber = AllExport.intTicketNumber
					and AllTicketNumber.intLocationId = AllExport.intProcessingLocationId
					and AllTicketNumber.strIndicator = AllExport.strIndicator
			left join tblSMCompanyLocation CompanyLocation
				on AllTicketNumber.intLocationId = CompanyLocation.intCompanyLocationId
			order by AllTicketNumber.intTicketNumber asc, strModTicketNumber */



end