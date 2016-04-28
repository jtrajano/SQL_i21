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
		  intCommissionScheduleId	INT
		, strReviewPeriod			NVARCHAR(20)
		, strScheduleType			NVARCHAR(20)
		, dtmStartDate				DATETIME
		, dtmEndDate				DATETIME
		, ysnPayables				BIT
		, ysnPayroll				BIT
		, ysnAdjustPrevious			BIT
	)

	--FILTER BY COMMISSION SCHEDULE ID AND ACTIVE = 1
	IF EXISTS(SELECT TOP 1 1 FROM @tmpCommissionSchedule)
		BEGIN
			INSERT INTO @tblARCommissionSchedules
			SELECT intCommissionScheduleId
					, strReviewPeriod
					, strScheduleType
					, dtmStartDate
					, dtmEndDate
					, ysnPayables
					, ysnPayroll
					, ysnAdjustPrevious
			FROM tblARCommissionSchedule
			WHERE intCommissionScheduleId IN (SELECT intCommissionScheduleId FROM @tmpCommissionSchedule)
				AND ysnActive = 1
		END
	ELSE
		BEGIN
			INSERT INTO @tblARCommissionSchedules
			SELECT intCommissionScheduleId
					, strReviewPeriod
					, strScheduleType
					, dtmStartDate
					, dtmEndDate
					, ysnPayables
					, ysnPayroll
					, ysnAdjustPrevious
			FROM tblARCommissionSchedule
			WHERE ysnActive = 1
		END

	--FILTER BY START DATE AND END DATE
	IF @dtmStartDate IS NOT NULL AND @dtmEndDate IS NOT NULL
		BEGIN
			DELETE FROM @tblARCommissionSchedules
			WHERE CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmStartDate))) NOT BETWEEN CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmStartDate))) 
																								AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmEndDate))) 
		END
			
	--GET COMM. SCHED. DETAILS WHERE intCommissionScheduleId
	IF EXISTS(SELECT NULL FROM @tblARCommissionSchedules)
		BEGIN
			DECLARE @tblARCommissionScheduleDetails TABLE (intEntityId INT, intCommissionPlanId INT, dblPercentage NUMERIC(18,6))

			WHILE EXISTS(SELECT TOP 1 1 FROM @tblARCommissionSchedules)
				BEGIN
					DECLARE @intActiveCommSchedId	INT,
							@ysnPayables		BIT,
							@ysnPayroll			BIT

					SELECT TOP 1 
							  @intActiveCommSchedId		= intCommissionScheduleId
							, @ysnPayables				= ysnPayables
							, @ysnPayroll				= ysnPayroll
					FROM @tblARCommissionSchedules ORDER BY intCommissionScheduleId

					INSERT INTO @tblARCommissionScheduleDetails
							(intEntityId
							, intCommissionPlanId
							, dblPercentage)
					SELECT CSD.intEntityId
							, CSD.intCommissionPlanId
							, CSD.dblPercentage
					FROM tblARCommissionScheduleDetail CSD 
						INNER JOIN tblARCommissionPlan CP ON CSD.intCommissionPlanId = CP.intCommissionPlanId
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
									SELECT TOP 1
											@intCommissionPlanId = intCommissionPlanId
										  , @intEntityId		 = intEntityId											
									FROM @tblARCommissionScheduleDetails
											
									EXEC dbo.uspARCalculateCommission @intCommissionPlanId, @intEntityId

									DELETE FROM @tblARCommissionScheduleDetails WHERE intCommissionPlanId = @intCommissionPlanId
								END									
						END

					DELETE FROM @tblARCommissionSchedules WHERE intCommissionScheduleId = @intActiveCommSchedId
				END
		END