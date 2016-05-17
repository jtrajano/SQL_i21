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
		  , @BASIS_CONDITIONAL		NVARCHAR(20) = 'Conditional'

	--INSERT PARSE SELECTED COMM. SCHED. FROM STRING INTO TEMP TABLE
	DECLARE @tmpCommissionSchedule TABLE (intCommissionScheduleId INT)	

	INSERT INTO @tmpCommissionSchedule
	SELECT intID FROM fnGetRowsFromDelimitedValues(@commissionIds)
			
	DECLARE @tblARCommissionSchedules TABLE (
		  intCommissionScheduleId	INT
		, strEntityIds				NVARCHAR(500)
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
		 , strEntityIds			= CASE WHEN strScheduleType = @SCHEDTYPE_INDIVIDUAL THEN strEntityIds ELSE NULL END
		 , intCommissionPlanId	= CASE WHEN strScheduleType = @SCHEDTYPE_GROUP THEN intCommissionPlanId ELSE NULL END
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
	IF EXISTS(SELECT TOP 1 1 FROM @tmpCommissionSchedule) AND ISNULL(@commissionIds, '') <> ''
		BEGIN
			DELETE FROM @tblARCommissionSchedules
			WHERE intCommissionScheduleId NOT IN (SELECT intCommissionScheduleId FROM @tmpCommissionSchedule)
		END
				
	--GET COMM. SCHED. DETAILS WHERE intCommissionScheduleId
	IF EXISTS(SELECT NULL FROM @tblARCommissionSchedules)
		BEGIN
			DECLARE @tblARCommissionScheduleDetails TABLE (intCommissionScheduleDetailId INT, intEntityId INT, intCommissionPlanId INT, dblPercentage NUMERIC(18,6))

			WHILE EXISTS(SELECT TOP 1 1 FROM @tblARCommissionSchedules)
				BEGIN
					DECLARE @intActiveCommSchedId	INT						  
						  , @intSchedCommPlanId		INT
						  , @strEntityIds			NVARCHAR(500)
						  , @strReviewPeriod		NVARCHAR(20)
						  , @strScheduleType		NVARCHAR(20)
						  , @dtmSchedStartDate		DATETIME
						  , @dtmSchedEndDate		DATETIME	
						  , @ysnPayables			BIT
						  , @ysnPayroll				BIT
						  , @ysnAdjustPrevious		BIT

					SELECT TOP 1 
							  @intActiveCommSchedId		= intCommissionScheduleId							
							, @intSchedCommPlanId		= intCommissionPlanId
							, @strEntityIds				= strEntityIds
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
					
					INSERT INTO @tblARCommissionScheduleDetails
					SELECT CSD.intCommissionScheduleDetailId
						 , CASE WHEN @strScheduleType = @SCHEDTYPE_INDIVIDUAL THEN NULL ELSE CSD.intEntityId END
						 , CASE WHEN @strScheduleType = @SCHEDTYPE_GROUP THEN @intSchedCommPlanId ELSE CSD.intCommissionPlanId END
						 , CASE WHEN @strScheduleType = @SCHEDTYPE_INDIVIDUAL THEN 0 ELSE CSD.dblPercentage END
					FROM tblARCommissionScheduleDetail CSD						
						INNER JOIN tblARCommissionPlan CP ON CSD.intCommissionPlanId = CP.intCommissionPlanId
					WHERE CSD.intCommissionScheduleId = @intActiveCommSchedId
						AND CP.ysnActive = 1
					
					--CALCULATE COMMISSION PLANS
					IF EXISTS(SELECT NULL FROM @tblARCommissionScheduleDetails)
						BEGIN
							DECLARE @dblLineTotal			NUMERIC(18,6) = 0
								  , @intNewCommissionId		INT
							
							INSERT INTO tblARCommission
								( intCommissionScheduleId
								, intCommissionPlanId
								, intEntityId
								, dtmStartDate
								, dtmEndDate
								, ysnConditional
								, ysnApproved
								, ysnRejected
								, ysnPayroll
								, ysnPayables
								, dblTotalAmount
								, strReason
								, intConcurrencyId)
							SELECT TOP 1
								  @intActiveCommSchedId
								, CS.intCommissionPlanId
								, CS.strEntityIds
								, @dtmStartDate
								, @dtmEndDate
								, CASE WHEN CP.strBasis = @BASIS_CONDITIONAL THEN 1 ELSE 0 END
								, 0
								, 0
								, CS.ysnPayroll
								, CS.ysnPayables
								, @dblLineTotal
								, NULL
								, 1
							FROM tblARCommissionSchedule CS
								LEFT JOIN tblARCommissionPlan CP ON CS.intCommissionPlanId = CP.intCommissionPlanId
							WHERE CS.intCommissionScheduleId = @intActiveCommSchedId

							SET @intNewCommissionId = SCOPE_IDENTITY()

							IF @strScheduleType = @SCHEDTYPE_GROUP
								BEGIN
									EXEC dbo.uspARCalculateCommission @intSchedCommPlanId, NULL, @dtmStartDate, @dtmEndDate, @dblLineTotal OUT

									UPDATE tblARCommission SET dblTotalAmount = @dblLineTotal WHERE intCommissionId = @intNewCommissionId

									IF EXISTS(SELECT TOP 1 1 FROM @tblARCommissionScheduleDetails)
										BEGIN											
											INSERT INTO tblARCommissionDetail
												( intCommissionId
												, intEntityId	
												, intCommissionPlanId
												, intSourceId
												, strSourceType
												, dtmSourceDate
												, dblAmount)
											SELECT 
												  @intNewCommissionId
												, intEntityId
												, intCommissionPlanId
												, 0
												, ''
												, GETDATE()
												, @dblLineTotal * ISNULL(dblPercentage, 0)
											FROM @tblARCommissionScheduleDetails
										END

									DELETE FROM @tblARCommissionScheduleDetails
								END
							ELSE IF @strScheduleType = @SCHEDTYPE_INDIVIDUAL
								BEGIN
									DECLARE @totalAmount NUMERIC(18,6) = 0
									DECLARE @tblEntities TABLE(intEntityId INT)

									INSERT INTO @tblEntities
									SELECT intID FROM fnGetRowsFromDelimitedValues(@strEntityIds)

									IF EXISTS(SELECT TOP 1 1 FROM @tblEntities) AND ISNULL(@strEntityIds, '') <> ''
										BEGIN
											DECLARE @intEntityId INT = NULL

											SELECT TOP 1 @intEntityId = intEntityId FROM @tblEntities											

											WHILE EXISTS(SELECT TOP 1 1 FROM @tblARCommissionScheduleDetails)
												BEGIN
													DECLARE @intCommissionScheduleDetailId	INT
														  , @intCommissionPlanId			INT

													SELECT TOP 1
															@intCommissionScheduleDetailId	= intCommissionScheduleDetailId
														  , @intCommissionPlanId			= intCommissionPlanId
													FROM @tblARCommissionScheduleDetails
																				
													EXEC dbo.uspARCalculateCommission @intCommissionPlanId, @intEntityId, @dtmStartDate, @dtmEndDate, @dblLineTotal OUT

													INSERT INTO tblARCommissionDetail
														( intCommissionId
														, intEntityId	
														, intCommissionPlanId
														, intSourceId
														, strSourceType
														, dtmSourceDate
														, dblAmount)
													SELECT TOP 1
														  @intNewCommissionId
														, @intEntityId
														, @intCommissionPlanId
														, 0
														, ''
														, GETDATE()
														, @dblLineTotal
													FROM @tblARCommissionScheduleDetails
										
													SET @totalAmount = @totalAmount + @dblLineTotal
																			
													DELETE FROM @tblARCommissionScheduleDetails WHERE intCommissionScheduleDetailId = @intCommissionScheduleDetailId
												END

											UPDATE tblARCommission SET dblTotalAmount = @totalAmount WHERE intCommissionId = @intNewCommissionId

											DELETE FROM @tblEntities WHERE intEntityId = @intEntityId
										END									
								END
						END
					
					
					DELETE FROM @tblARCommissionSchedules WHERE intCommissionScheduleId = @intActiveCommSchedId
				END
		END