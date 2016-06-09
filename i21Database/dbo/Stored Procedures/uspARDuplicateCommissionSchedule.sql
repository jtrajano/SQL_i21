CREATE PROCEDURE [dbo].[uspARDuplicateCommissionSchedule]
	@intCommissionScheduleId		INT		
   ,@NewCommissionScheduleId		INT = NULL OUTPUT
AS
	INSERT INTO tblARCommissionSchedule
		([strCommissionScheduleName]
		,[strCommissionScheduleDesc]
		,[strReviewPeriod]
		,[strScheduleType]
		,[dtmStartDate]
		,[dtmEndDate]
		,[strEntityIds]
		,[intCommissionPlanId]
		,[ysnActive]
		,[ysnPayables]
		,[ysnPayroll]
		,[ysnAdjustPrevious]
		,[intConcurrencyId])
	SELECT 
		 'DUP:' + [strCommissionScheduleName]
		,[strCommissionScheduleDesc]
		,[strReviewPeriod]
		,[strScheduleType]
		,[dtmStartDate]
		,[dtmEndDate]
		,[strEntityIds]
		,[intCommissionPlanId]
		,[ysnActive]
		,[ysnPayables]
		,[ysnPayroll]
		,[ysnAdjustPrevious]
		,1
	FROM tblARCommissionSchedule
		WHERE intCommissionScheduleId = @intCommissionScheduleId

	SET @NewCommissionScheduleId = SCOPE_IDENTITY()

	DECLARE @CommSchedDetails TABLE(intCommissionScheduleDetailId INT)
		
	INSERT INTO @CommSchedDetails
		([intCommissionScheduleDetailId])
	SELECT 	
		 [intCommissionScheduleDetailId]
	FROM
		tblARCommissionScheduleDetail
	WHERE
		[intCommissionScheduleId] = @intCommissionScheduleId
	ORDER BY
		[intCommissionScheduleDetailId]

	WHILE EXISTS(SELECT TOP 1 NULL FROM @CommSchedDetails)
	BEGIN
		DECLARE @CommSchedDetailId INT
					
		SELECT TOP 1 @CommSchedDetailId = [intCommissionScheduleDetailId] FROM @CommSchedDetails ORDER BY [intCommissionScheduleDetailId]
			
		INSERT INTO [tblARCommissionScheduleDetail]
			([intCommissionScheduleId]
			,[intEntityId]
			,[intCommissionPlanId]
			,[intSort]
			,[dblPercentage]
			,[intConcurrencyId])
		SELECT 
			@NewCommissionScheduleId
			,[intEntityId]
			,[intCommissionPlanId]
			,[intSort]
			,[dblPercentage]
			,1
		FROM
			[tblARCommissionScheduleDetail]
		WHERE
			[intCommissionScheduleDetailId] = @CommSchedDetailId
												
		DELETE FROM @CommSchedDetails WHERE [intCommissionScheduleDetailId] = @CommSchedDetailId
	END
RETURN