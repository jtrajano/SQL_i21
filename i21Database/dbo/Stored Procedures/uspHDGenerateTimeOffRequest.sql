CREATE PROCEDURE [dbo].[uspHDGenerateTimeOffRequest]
	@intEntityId int
AS

declare @queryResult cursor
		,@intTimeOffRequestId int
		,@dtmDateFrom datetime
		,@intEntityEmployeeId int
		,@strRequestId nvarchar(20)
		,@dblRequest numeric(18,6)
		,@intNoOfDays int
		
		,@strPRDayName nvarchar(20)
		,@dtmPRDate datetime
		
		,@intI int
		,@intFixEightHours int = 8;

if (@intEntityId = 0)
begin
	set @queryResult = cursor for
		select
			intTimeOffRequestId
			,dtmDateFrom
			,intEntityEmployeeId
			,strRequestId
			,dblRequest
			,intNoOfDays = datediff(day, dtmDateFrom, dtmDateTo) + 1
		from
			tblPRTimeOffRequest

	OPEN @queryResult
	FETCH NEXT
	FROM
		@queryResult
	INTO
		@intTimeOffRequestId
		,@dtmDateFrom
		,@intEntityEmployeeId
		,@strRequestId
		,@dblRequest
		,@intNoOfDays
end
else
begin
	set @queryResult = cursor for
		select
			intTimeOffRequestId
			,dtmDateFrom
			,intEntityEmployeeId
			,strRequestId
			,dblRequest
			,intNoOfDays = datediff(day, dtmDateFrom, dtmDateTo) + 1
		from
			tblPRTimeOffRequest
		where
			intEntityEmployeeId = @intEntityId

	OPEN @queryResult
	FETCH NEXT
	FROM
		@queryResult
	INTO
		@intTimeOffRequestId
		,@dtmDateFrom
		,@intEntityEmployeeId
		,@strRequestId
		,@dblRequest
		,@intNoOfDays
end

WHILE @@FETCH_STATUS = 0
BEGIN

	if (@intNoOfDays > 1)
	begin
		set @intI = 0;
		while @intI < @intNoOfDays
		begin
			set @dtmPRDate = DATEADD(day,@intI,@dtmDateFrom);
			set @strPRDayName = DATENAME(WEEKDAY,@dtmPRDate);

			if (@strPRDayName <> 'Saturday' and @strPRDayName <> 'Sunday')
			begin

				if not exists (select * from tblHDTimeOffRequest where intPREntityEmployeeId = @intEntityEmployeeId and dtmPRDate = @dtmPRDate)
				begin
					if (@intI < @intNoOfDays)
					begin
						set @dblRequest = @dblRequest - 8;
					end
					else
					begin
						set @intFixEightHours = @dblRequest;
					end
					
					--time off was edited, update the record
					if exists (select 1 from tblHDTimeOffRequest where intPREntityEmployeeId = @intEntityEmployeeId and intPRTimeOffRequestId = @intTimeOffRequestId)
					begin
						UPDATE [dbo].[tblHDTimeOffRequest] 
						SET 
							[dtmPRDate] = @dtmPRDate,
							[strPRDayName] = @strPRDayName,
							[dblPRRequest] = @intFixEightHours,
							[intPRNoOfDays] = @intNoOfDays,
							[intConcurrencyId] = [intConcurrencyId] + 1
						WHERE 
						intPRTimeOffRequestId = @intTimeOffRequestId
					end
					else
					begin
						INSERT INTO [dbo].[tblHDTimeOffRequest]
								   ([intPRTimeOffRequestId]
								   ,[intPREntityEmployeeId]
								   ,[strPRRequestId]
								   ,[dtmPRDate]
								   ,[strPRDayName]
								   ,[dblPRRequest]
								   ,[intPRNoOfDays]
								   ,[intConcurrencyId])
							 VALUES
								   (@intTimeOffRequestId
								   ,@intEntityEmployeeId
								   ,@strRequestId
								   ,@dtmPRDate
								   ,@strPRDayName
								   ,@intFixEightHours
								   ,@intNoOfDays
								   ,1)
					end
				end

			end

			set @intI = @intI + 1;
		end

	end
	else
	begin

		set @dtmPRDate = @dtmDateFrom;
		set @strPRDayName = DATENAME(WEEKDAY,@dtmPRDate);

			if (@strPRDayName <> 'Saturday' and @strPRDayName <> 'Sunday')
			begin

				if not exists (select * from tblHDTimeOffRequest where intPREntityEmployeeId = @intEntityEmployeeId and dtmPRDate = @dtmPRDate)
				begin
				--time off was edited, update the record
					if exists (select 1 from tblHDTimeOffRequest where intPREntityEmployeeId = @intEntityEmployeeId and intPRTimeOffRequestId = @intTimeOffRequestId)
					begin
						UPDATE [dbo].[tblHDTimeOffRequest] 
						SET 
							[dtmPRDate] = @dtmPRDate,
							[strPRDayName] = @strPRDayName,
							[dblPRRequest] = @intFixEightHours,
							[intPRNoOfDays] = @intNoOfDays,
							[intConcurrencyId] = [intConcurrencyId] + 1
						WHERE 
						intPRTimeOffRequestId = @intTimeOffRequestId
					end
					else
					begin
						INSERT INTO [dbo].[tblHDTimeOffRequest]
								   ([intPRTimeOffRequestId]
								   ,[intPREntityEmployeeId]
								   ,[strPRRequestId]
								   ,[dtmPRDate]
								   ,[strPRDayName]
								   ,[dblPRRequest]
								   ,[intPRNoOfDays]
								   ,[intConcurrencyId])
							 VALUES
								   (@intTimeOffRequestId
								   ,@intEntityEmployeeId
								   ,@strRequestId
								   ,@dtmPRDate
								   ,@strPRDayName
								   ,@dblRequest
								   ,@intNoOfDays
								   ,1)
					end
				end

			end

	end

	FETCH NEXT
	FROM
		@queryResult
	INTO
		@intTimeOffRequestId
		,@dtmDateFrom
		,@intEntityEmployeeId
		,@strRequestId
		,@dblRequest
		,@intNoOfDays
END

CLOSE @queryResult
DEALLOCATE @queryResult