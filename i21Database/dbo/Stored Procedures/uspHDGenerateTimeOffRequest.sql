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
		,@intFixEightHours int = 8

		,@intScreenId int
		,@strApprovalStatus nvarchar(100)
		,@intHDTimeOffRequestId int;

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
			order by intTimeOffRequestId desc

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

	select @intScreenId = intScreenId from tblSMScreen where strNamespace = 'Payroll.view.TimeOffRequest'
end

WHILE @@FETCH_STATUS = 0
BEGIN

	--check if time off was rejected in approval
	--if rejescted, do not insert, or remove it from tblHDTimeOffRequest
	select @strApprovalStatus = strApprovalStatus from tblSMTransaction where intScreenId = @intScreenId and intRecordId = @intTimeOffRequestId
	if ISNULL(@strApprovalStatus, '') <> ''
	begin
		if @strApprovalStatus = 'Rejected' or @strApprovalStatus = 'Closed'
		begin
			--check if already inserted to tblHDTimeOffRequest to delete it
			select @intHDTimeOffRequestId = intTimeOffRequestId from tblHDTimeOffRequest where intPREntityEmployeeId = @intEntityEmployeeId and intPRTimeOffRequestId = @intTimeOffRequestId
			if ISNULL(@intHDTimeOffRequestId, 0) <> 0
			begin
				DELETE from [dbo].[tblHDTimeOffRequest] where intTimeOffRequestId = @intHDTimeOffRequestId
			end

			--continue
			FETCH NEXT FROM @queryResult
			INTO @intTimeOffRequestId
				,@dtmDateFrom
				,@intEntityEmployeeId
				,@strRequestId
				,@dblRequest
				,@intNoOfDays

			continue
		end
	end
	


	if (@intNoOfDays > 1)
	begin
		set @intI = 0;
		while @intI < @intNoOfDays
		begin
			set @dtmPRDate = DATEADD(day,@intI,@dtmDateFrom);
			set @strPRDayName = DATENAME(WEEKDAY,@dtmPRDate);

			if (@strPRDayName <> 'Saturday' and @strPRDayName <> 'Sunday')
			begin
				--insert when payroll timeoff does not exist based on current entity, timeOff id and date
				if not exists (select * from tblHDTimeOffRequest where intPREntityEmployeeId = @intEntityEmployeeId and dtmPRDate = @dtmPRDate and intPRTimeOffRequestId = @intTimeOffRequestId)
				begin
					if (@intI < @intNoOfDays)
					begin
						set @dblRequest = @dblRequest - 8;
					end
					if (sign(@dblRequest) = -1)
					begin
						set @dblRequest = @intFixEightHours;
					end
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

			set @intI = @intI + 1;
		end

	end
	else
	begin

		set @dtmPRDate = @dtmDateFrom;
		set @strPRDayName = DATENAME(WEEKDAY,@dtmPRDate);

		if (@strPRDayName <> 'Saturday' and @strPRDayName <> 'Sunday')
		begin
			--time off was edited, update the record
			if exists (select 1 from tblHDTimeOffRequest where intPREntityEmployeeId = @intEntityEmployeeId and intPRTimeOffRequestId = @intTimeOffRequestId and (
				dtmPRDate != @dtmPRDate or dblPRRequest != @dblRequest
			))
			begin
				UPDATE [dbo].[tblHDTimeOffRequest] 
				SET 
					[dtmPRDate] = @dtmPRDate,
					[strPRDayName] = @strPRDayName,
					[dblPRRequest] = @dblRequest,
					[intPRNoOfDays] = @intNoOfDays,
					[intConcurrencyId] = [intConcurrencyId] + 1
				WHERE 
				intPRTimeOffRequestId = @intTimeOffRequestId
				
				--time off was edited from multiple days to 1, delete other days
				Declare @count int
				Set @count=(Select count(*) from tblHDTimeOffRequest where intPRTimeOffRequestId = @intTimeOffRequestId)-1
				if (@count > 0)
				begin
					Delete top (@count) from tblHDTimeOffRequest where intPRTimeOffRequestId = @intTimeOffRequestId
				end
			end
			
			else if not exists (select 1 from tblHDTimeOffRequest where intPREntityEmployeeId = @intEntityEmployeeId and intPRTimeOffRequestId = @intTimeOffRequestId)
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