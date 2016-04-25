CREATE PROCEDURE [dbo].[uspARProcessCommissionSchedule]
	  @commissionIds	NVARCHAR(MAX)	= ''
	, @dtmStartDate		DATETIME		= NULL
	, @dtmEndDate		DATETIME		= NULL
	, @ysnRecap			BIT				= 1
	, @batchId			NVARCHAR(100)	= NULL OUTPUT
AS
	--INSERT PARSE SELECTED COMM. SCHED. FROM STRING INTO TEMP TABLE
	DECLARE @tmpCommissionSchedule TABLE (intCommissionScheduleId INT)
	
	INSERT INTO @tmpCommissionSchedule
	SELECT intID FROM fnGetRowsFromDelimitedValues(@commissionIds)
			
	DECLARE @tblARCommissionSchedules TABLE (
		intCommissionScheduleId INT
		, strReviewPeriod			NVARCHAR(20)
		, dtmReviewStartDate		DATETIME
		, ysnAutoPayables			BIT
		, ysnAutoPayroll			BIT
		, ysnAutoProcess			BIT
	)

	--FILTER BY COMMISSION SCHEDULE ID AND ACTIVE = 1
	IF EXISTS(SELECT TOP 1 1 FROM @tmpCommissionSchedule)
		BEGIN
			INSERT INTO @tblARCommissionSchedules
			SELECT intCommissionScheduleId
					, strReviewPeriod
					, dtmReviewStartDate
					, ysnAutoPayables
					, ysnAutoPayroll
					, ysnAutoProcess
			FROM tblARCommissionSchedule
			WHERE intCommissionScheduleId IN (SELECT intCommissionScheduleId FROM @tmpCommissionSchedule)
				AND ysnActive = 1
		END
	ELSE
		BEGIN
			INSERT INTO @tblARCommissionSchedules
			SELECT intCommissionScheduleId
					, strReviewPeriod
					, dtmReviewStartDate
					, ysnAutoPayables
					, ysnAutoPayroll
					, ysnAutoProcess
			FROM tblARCommissionSchedule
			WHERE ysnActive = 1
		END

	--FILTER BY START DATE AND END DATE
	IF @dtmStartDate IS NOT NULL AND @dtmEndDate IS NOT NULL
		BEGIN
			DELETE FROM @tblARCommissionSchedules
			WHERE CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmReviewStartDate))) NOT BETWEEN CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmStartDate))) 
																								AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmEndDate))) 
		END
			
	--GET COMM. SCHED. DETAILS WHERE intCommissionScheduleId
	IF EXISTS(SELECT NULL FROM @tblARCommissionSchedules)
		BEGIN
			DECLARE @tblARCommissionScheduleDetails TABLE (intEntityId INT, intCommissionPlanId INT, ysnAdjustForPrevious BIT, ysnEmployee BIT)

			WHILE EXISTS(SELECT TOP 1 1 FROM @tblARCommissionSchedules)
				BEGIN
					DECLARE @intActiveCommSchedId	INT,
							@ysnAutoPayables		BIT,
							@ysnAutoPayroll			BIT

					SELECT TOP 1 
							@intActiveCommSchedId	= intCommissionScheduleId
							, @ysnAutoPayables			= ysnAutoPayables
							, @ysnAutoPayroll			= ysnAutoPayroll
					FROM @tblARCommissionSchedules ORDER BY intCommissionScheduleId

					INSERT INTO @tblARCommissionScheduleDetails
							(intEntityId
							, intCommissionPlanId
							, ysnAdjustForPrevious
							, ysnEmployee)
					SELECT CSD.intEntityId
							, CSD.intCommissionId
							, CSD.ysnAdjustPrevious
							, Employee
					FROM tblARCommissionScheduleDetail CSD 
						INNER JOIN tblARCommissionPlan CP ON CSD.intCommissionId = CP.intCommissionId
						LEFT JOIN vyuEMSearch E ON CSD.intEntityId = E.intEntityId
					WHERE CSD.intCommissionScheduleId = @intActiveCommSchedId
						AND CP.ysnActive = 1
							
					--CALCULATE COMMISSION PLANS
					IF EXISTS(SELECT NULL FROM @tblARCommissionScheduleDetails)
						BEGIN
							WHILE EXISTS(SELECT TOP 1 1 FROM @tblARCommissionScheduleDetails)
								BEGIN
									DECLARE @intCommissionPlanId	INT
									        , @intEntityId			INT
											, @ysnEmployee			BIT
									SELECT TOP 1
											@intCommissionPlanId = intCommissionPlanId
											, @intEntityId			= intEntityId
											, @ysnEmployee			= ysnEmployee
									FROM @tblARCommissionScheduleDetails
											
									EXEC dbo.uspARCalculateCommission @intCommissionPlanId, @intEntityId, @ysnEmployee, @ysnAutoPayables, @ysnAutoPayroll

									DELETE FROM @tblARCommissionScheduleDetails WHERE intCommissionPlanId = @intCommissionPlanId
								END									
						END

					DELETE FROM @tblARCommissionSchedules WHERE intCommissionScheduleId = @intActiveCommSchedId
				END
		END