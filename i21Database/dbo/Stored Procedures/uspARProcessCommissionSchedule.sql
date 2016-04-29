CREATE PROCEDURE [dbo].[uspARProcessCommissionSchedule]
	  @commissionIds	NVARCHAR(MAX)	= ''
	, @dtmStartDate		DATETIME		= NULL
	, @dtmEndDate		DATETIME		= NULL
	, @ysnRecap			BIT				= 1
	, @batchId			NVARCHAR(100)	= NULL OUTPUT
AS
	--CONSTANT VARIABLES
	DECLARE @SCHEDTYPE_INDIVIDUAL	NVARCHAR(20) = 'Individual'
	      , @SCHEDTYPE_GROUP		NVARCHAR(20) = 'Group'

	--INSERT PARSE SELECTED COMM. SCHED. FROM STRING INTO TEMP TABLE
	DECLARE @tmpCommissionSchedule TABLE (intCommissionScheduleId INT)	

	INSERT INTO @tmpCommissionSchedule
	SELECT intID FROM fnGetRowsFromDelimitedValues(@commissionIds)
			
	DECLARE @tblARCommissionSchedules TABLE (
		  intCommissionScheduleId	INT
		, intEntityId				INT
		, intCommissionPlanId		INT
		, strReviewPeriod			NVARCHAR(20)
		, strScheduleType			NVARCHAR(20)
		, dtmStartDate				DATETIME
		, dtmEndDate				DATETIME
		, ysnPayables				BIT
		, ysnPayroll				BIT
		, ysnAdjustPrevious			BIT
	)

	INSERT INTO @tblARCommissionSchedules
	SELECT intCommissionScheduleId
		 , intEntityId			= CASE WHEN strScheduleType = 'Individual' THEN intEntityId ELSE NULL END
		 , intCommissionPlanId	= CASE WHEN strScheduleType = 'Group' THEN intCommissionPlanId ELSE NULL END
		 , strReviewPeriod
		 , strScheduleType
		 , dtmStartDate
		 , dtmEndDate
		 , ysnPayables
		 , ysnPayroll
		 , ysnAdjustPrevious
	FROM tblARCommissionSchedule
	WHERE ysnActive = 1

	--FILTER BY COMMISSION SCHEDULE ID AND ACTIVE = 1
	IF EXISTS(SELECT TOP 1 1 FROM @tmpCommissionSchedule)
		BEGIN
			DELETE FROM @tblARCommissionSchedules
			WHERE intCommissionScheduleId NOT IN (SELECT intCommissionScheduleId FROM @tmpCommissionSchedule)
		END

	----FILTER BY START DATE AND END DATE
	--IF @dtmStartDate IS NOT NULL AND @dtmEndDate IS NOT NULL
	--	BEGIN
	--		DELETE FROM @tblARCommissionSchedules
	--		WHERE CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmStartDate))) NOT BETWEEN CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmStartDate))) 
	--																							AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmEndDate))) 
	--	END
			
	--GET COMM. SCHED. DETAILS WHERE intCommissionScheduleId
	IF EXISTS(SELECT NULL FROM @tblARCommissionSchedules)
		BEGIN
			DECLARE @tblARCommissionScheduleDetails TABLE (intEntityId INT, intCommissionPlanId INT, dblPercentage NUMERIC(18,6))

			WHILE EXISTS(SELECT TOP 1 1 FROM @tblARCommissionSchedules)
				BEGIN
					DECLARE @intActiveCommSchedId	INT
						  , @intSchedEntityId		INT
						  , @intSchedCommPlanId		INT
						  , @strReviewPeriod		NVARCHAR(20)
						  , @strScheduleType		NVARCHAR(20)
						  , @dtmSchedStartDate		DATETIME
						  , @dtmSchedEndDate		DATETIME	
						  , @ysnPayables			BIT
						  , @ysnPayroll				BIT
						  , @ysnAdjustPrevious		BIT

					SELECT TOP 1 
							  @intActiveCommSchedId		= intCommissionScheduleId
							, @intSchedEntityId			= intEntityId
							, @intSchedCommPlanId		= intCommissionPlanId
							, @strReviewPeriod			= strReviewPeriod
							, @strScheduleType			= strScheduleType
							, @dtmSchedStartDate		= dtmStartDate
							, @dtmSchedEndDate			= dtmEndDate
							, @ysnPayables				= ysnPayables
							, @ysnPayroll				= ysnPayroll
							, @ysnAdjustPrevious		= ysnAdjustPrevious
					FROM @tblARCommissionSchedules ORDER BY intCommissionScheduleId

					SET @dtmStartDate = CASE WHEN @dtmStartDate < @dtmSchedStartDate THEN @dtmSchedStartDate ELSE @dtmStartDate END
					SET @dtmEndDate = CASE WHEN @dtmEndDate > @dtmSchedEndDate THEN @dtmSchedEndDate ELSE @dtmEndDate END
					
					IF @strScheduleType = @SCHEDTYPE_INDIVIDUAL
						BEGIN
							INSERT INTO @tblARCommissionScheduleDetails (intCommissionPlanId)
							SELECT CSD.intCommissionPlanId
							FROM tblARCommissionScheduleDetail CSD
								INNER JOIN tblARCommissionPlan CP ON CSD.intCommissionPlanId = CP.intCommissionPlanId
							WHERE CSD.intCommissionScheduleId = @intActiveCommSchedId
								AND CP.ysnActive = 1
						END
					ELSE IF @strScheduleType = @SCHEDTYPE_GROUP
						BEGIN
							INSERT INTO @tblARCommissionScheduleDetails (intEntityId, dblPercentage)
							SELECT CSD.intEntityId, ISNULL(dblPercentage, 0)
							FROM tblARCommissionScheduleDetail CSD
								INNER JOIN tblARCommissionPlan CP ON CSD.intCommissionPlanId = CP.intCommissionPlanId
							WHERE CSD.intCommissionScheduleId = @intActiveCommSchedId
								AND CP.ysnActive = 1
						END					
							
					--CALCULATE COMMISSION PLANS
					IF EXISTS(SELECT NULL FROM @tblARCommissionScheduleDetails)
						BEGIN
							WHILE EXISTS(SELECT TOP 1 1 FROM @tblARCommissionScheduleDetails)
								BEGIN
									DECLARE @intCommissionPlanId	INT
									      , @intEntityId			INT
										  , @dblPercentage			NUMERIC(18,6)
									SELECT TOP 1
											@intCommissionPlanId = CASE WHEN @strScheduleType = @SCHEDTYPE_GROUP THEN intCommissionPlanId ELSE @intSchedCommPlanId END
										  , @intEntityId		 = CASE WHEN @strScheduleType = @SCHEDTYPE_INDIVIDUAL THEN intEntityId ELSE @intSchedEntityId END
										  , @dblPercentage		 = dblPercentage
									FROM @tblARCommissionScheduleDetails
											
									EXEC dbo.uspARCalculateCommission @intCommissionPlanId, @intEntityId, @dtmStartDate, @dtmEndDate

									DELETE FROM @tblARCommissionScheduleDetails WHERE intCommissionPlanId = @intCommissionPlanId
								END
						END

					DELETE FROM @tblARCommissionSchedules WHERE intCommissionScheduleId = @intActiveCommSchedId
				END
		END