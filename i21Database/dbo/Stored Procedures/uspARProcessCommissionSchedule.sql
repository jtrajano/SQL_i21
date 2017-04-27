CREATE PROCEDURE [dbo].[uspARProcessCommissionSchedule]
	  @commissionScheduleIds	NVARCHAR(MAX)	= ''
	, @dtmStartDate				DATETIME		= NULL
	, @dtmEndDate				DATETIME		= NULL
	, @ysnRecap					BIT				= 1
	, @batchId					NVARCHAR(100)	= NULL OUTPUT
	, @totalAmount				NUMERIC(18,6)	= NULL OUTPUT
	, @ysnAllowCalculate		BIT				= 0
AS

DECLARE  @strCommissionSchedule	NVARCHAR(500)

	--VALIDATE DATES
	IF @dtmStartDate IS NULL
		BEGIN
			RAISERROR('Start Date is Required.', 16, 1);
			RETURN 0;
		END

	IF @dtmEndDate IS NULL
		BEGIN
			RAISERROR('End Date is Required.', 16, 1);
			RETURN 0;
		END

	SET @batchId = CONVERT(NVARCHAR(100), NEWID())
	SET @totalAmount = 0

	--CONSTANT VARIABLES
	DECLARE @SCHEDTYPE_INDIVIDUAL	NVARCHAR(20) = 'Individual'
	      , @SCHEDTYPE_GROUP		NVARCHAR(20) = 'Group'
		  , @BASIS_CONDITIONAL		NVARCHAR(20) = 'Conditional'

	--INSERT PARSE SELECTED COMM. SCHED. FROM STRING INTO TEMP TABLE
	DECLARE @tmpCommissionSchedule TABLE (intCommissionScheduleId INT)	

	IF (@commissionScheduleIds = '')
		BEGIN
			INSERT INTO @tmpCommissionSchedule
			SELECT intCommissionScheduleId FROM tblARCommissionSchedule WHERE ysnActive = 1
		END
	ELSE
		BEGIN
			INSERT INTO @tmpCommissionSchedule
			SELECT intID FROM fnGetRowsFromDelimitedValues(@commissionScheduleIds)
		END	
			
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

	IF @ysnAllowCalculate = 0 AND @ysnRecap = 0
	BEGIN
		IF EXISTS(SELECT NULL FROM tblARCommission WHERE [intCommissionScheduleId] IN (SELECT intCommissionScheduleId FROM @tmpCommissionSchedule) 
		AND [dtmStartDate] = @dtmStartDate AND [dtmEndDate] = @dtmEndDate) 
			BEGIN
				SELECT @strCommissionSchedule = strCommissionScheduleName FROM tblARCommissionSchedule WHERE intCommissionScheduleId IN (SELECT intCommissionScheduleId FROM @tmpCommissionSchedule) 
				DECLARE @formatMessage AS NVARCHAR(200)				
				SET @formatMessage = 'Commission Schedule ''' + @strCommissionSchedule  + ''' was already calculated for this date.'
				RAISERROR(@formatMessage, 16, 1);	
				RETURN 0;
			END
	END
	
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
	IF EXISTS(SELECT TOP 1 1 FROM @tmpCommissionSchedule) AND ISNULL(@commissionScheduleIds, '') <> ''
		BEGIN
			DELETE FROM @tblARCommissionSchedules
			WHERE intCommissionScheduleId NOT IN (SELECT intCommissionScheduleId FROM @tmpCommissionSchedule)
		END
				
	--GET COMMISSION SCHEDULE DETAILS BY intCommissionScheduleId
	IF EXISTS(SELECT NULL FROM @tblARCommissionSchedules)
		BEGIN
			DECLARE @tblARCommissionScheduleDetails TABLE (
				intCommissionScheduleDetailId	INT
			  , intEntityId						INT
			  , intCommissionPlanId				INT
			  , dblPercentage NUMERIC(18,6)
			)

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
								  , @intNewCommissionRecapId INT

							IF @strScheduleType = @SCHEDTYPE_GROUP
								BEGIN
									INSERT INTO tblARCommissionRecap
										( intCommissionScheduleId
										, intCommissionPlanId
										, intEntityId
										, intApproverEntityId
										, dtmStartDate
										, dtmEndDate
										, ysnConditional
										, ysnApproved
										, ysnRejected
										, ysnPayroll
										, ysnPayables
										, dblTotalAmount
										, strReason
										, strBatchId
										, intConcurrencyId)
									SELECT TOP 1
										  @intActiveCommSchedId
										, CS.intCommissionPlanId
										, CS.strEntityIds
										, CASE WHEN CP.strBasis = @BASIS_CONDITIONAL THEN (SELECT TOP 1 ISNULL(AL.intEntityUserSecurityId, AL.intAlternateEntityUserSecurityId) FROM tblSMApprovalListUserSecurity AL WHERE intApprovalListId = CP.intApprovalListId ORDER BY intApproverLevel) ELSE NULL END
										, @dtmStartDate
										, @dtmEndDate
										, CASE WHEN CP.strBasis = @BASIS_CONDITIONAL THEN 1 ELSE 0 END
										, 0
										, 0
										, CS.ysnPayroll
										, CS.ysnPayables
										, @dblLineTotal
										, NULL
										, @batchId
										, 1
									FROM tblARCommissionSchedule CS
										LEFT JOIN tblARCommissionPlan CP ON CS.intCommissionPlanId = CP.intCommissionPlanId
									WHERE CS.intCommissionScheduleId = @intActiveCommSchedId

									SET @intNewCommissionRecapId = SCOPE_IDENTITY()

									EXEC dbo.uspARCalculateCommission @intSchedCommPlanId, NULL, @intNewCommissionRecapId, @dtmStartDate, @dtmEndDate, @dblLineTotal OUT

									UPDATE tblARCommissionRecap SET dblTotalAmount = (SELECT SUM(ISNULL(dblAmount, 0)) FROM tblARCommissionRecapDetail WHERE intCommissionRecapId = @intNewCommissionRecapId) WHERE intCommissionRecapId = @intNewCommissionRecapId

									IF @ysnRecap = 0
										BEGIN
											INSERT INTO tblARCommission
												( intCommissionScheduleId
												, intCommissionPlanId
												, intEntityId
												, intApproverEntityId
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
												  intCommissionScheduleId
												, intCommissionPlanId
												, intEntityId
												, intApproverEntityId
												, dtmStartDate
												, dtmEndDate
												, ysnConditional
												, ysnApproved
												, ysnRejected
												, ysnPayroll
												, ysnPayables
												, dblTotalAmount
												, strReason
												, 1
											FROM tblARCommissionRecap
											WHERE intCommissionRecapId = @intNewCommissionRecapId

											SET @intNewCommissionId = SCOPE_IDENTITY()

											IF EXISTS(SELECT TOP 1 1 FROM @tblARCommissionScheduleDetails)
											BEGIN											
												INSERT INTO tblARCommissionDetail
													( intCommissionId
													, intEntityId	
													, intSourceId
													, strSourceType
													, dtmSourceDate
													, dblAmount)
												SELECT 
													  @intNewCommissionId
													, intEntityId
													, 0
													, ''
													, GETDATE()
													, @dblLineTotal * ISNULL(dblPercentage, 0)
												FROM @tblARCommissionScheduleDetails
											END

											DELETE FROM tblARCommissionRecap WHERE intCommissionRecapId = @intNewCommissionRecapId
										END									

									DELETE FROM @tblARCommissionScheduleDetails
								END
							ELSE IF @strScheduleType = @SCHEDTYPE_INDIVIDUAL
								BEGIN
									IF ISNULL(@strEntityIds, '') <> ''
										BEGIN
											--loop through commission plans
											WHILE EXISTS(SELECT TOP 1 1 FROM @tblARCommissionScheduleDetails)
												BEGIN
													DECLARE @tblEntities TABLE(intEntityId INT)
													DECLARE @intCommissionScheduleDetailId	INT
															, @intCommissionPlanId			INT

													--get all selected entities
													INSERT INTO @tblEntities
													SELECT intID FROM fnGetRowsFromDelimitedValues(@strEntityIds)

													SELECT TOP 1
															@intCommissionScheduleDetailId	= intCommissionScheduleDetailId
															, @intCommissionPlanId			= intCommissionPlanId
													FROM @tblARCommissionScheduleDetails
															
													WHILE EXISTS(SELECT TOP 1 1 FROM @tblEntities)
														BEGIN
															DECLARE @intEntityId INT = NULL
															SELECT TOP 1 @intEntityId = intEntityId FROM @tblEntities
															
															INSERT INTO tblARCommissionRecap
																( intCommissionScheduleId
																, intCommissionPlanId
																, intEntityId
																, intApproverEntityId
																, dtmStartDate
																, dtmEndDate
																, ysnConditional
																, ysnApproved
																, ysnRejected
																, ysnPayroll
																, ysnPayables
																, dblTotalAmount
																, strReason
																, strBatchId
																, intConcurrencyId)
															SELECT TOP 1
																  @intActiveCommSchedId
																, @intCommissionPlanId
																, @intEntityId
																, CASE WHEN CP.strBasis = @BASIS_CONDITIONAL THEN (SELECT TOP 1 ISNULL(AL.intEntityUserSecurityId, AL.intAlternateEntityUserSecurityId) FROM tblSMApprovalListUserSecurity AL WHERE intApprovalListId = CP.intApprovalListId ORDER BY intApproverLevel) ELSE NULL END
																, @dtmStartDate
																, @dtmEndDate
																, CASE WHEN CP.strBasis = @BASIS_CONDITIONAL THEN 1 ELSE 0 END
																, 0
																, 0
																, CS.ysnPayroll
																, CS.ysnPayables
																, @dblLineTotal
																, NULL
																, @batchId
																, 1
															FROM tblARCommissionSchedule CS
																LEFT JOIN tblARCommissionPlan CP ON CP.intCommissionPlanId = @intCommissionPlanId
															WHERE CS.intCommissionScheduleId = @intActiveCommSchedId

															SET @intNewCommissionRecapId = SCOPE_IDENTITY()

															EXEC dbo.uspARCalculateCommission @intCommissionPlanId, @intEntityId, @intNewCommissionRecapId, @dtmStartDate, @dtmEndDate, @dblLineTotal OUT

															UPDATE tblARCommissionRecap SET dblTotalAmount = (SELECT SUM(ISNULL(dblAmount, 0)) FROM tblARCommissionRecapDetail WHERE intCommissionRecapId = @intNewCommissionRecapId) WHERE intCommissionRecapId = @intNewCommissionRecapId

															IF @ysnRecap = 0
																BEGIN
																	INSERT INTO tblARCommission
																		( intCommissionScheduleId
																		, intCommissionPlanId
																		, intEntityId
																		, intApproverEntityId
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
																		  intCommissionScheduleId
																		, intCommissionPlanId
																		, intEntityId
																		, intApproverEntityId
																		, dtmStartDate
																		, dtmEndDate
																		, ysnConditional
																		, ysnApproved
																		, ysnRejected
																		, ysnPayroll
																		, ysnPayables
																		, dblTotalAmount
																		, strReason
																		, 1
																	FROM tblARCommissionRecap
																	WHERE intCommissionRecapId = @intNewCommissionRecapId

																	SET @intNewCommissionId = SCOPE_IDENTITY()

																	INSERT INTO tblARCommissionDetail
																		( intCommissionId
																		, intEntityId	
																		, intSourceId
																		, strSourceType
																		, dtmSourceDate
																		, dblAmount
																		, intConcurrencyId)
																	SELECT @intNewCommissionId
																		, intEntityId
																		, intSourceId
																		, strSourceType
																		, dtmSourceDate
																		, dblAmount
																		, intConcurrencyId
																	FROM tblARCommissionRecapDetail
																	WHERE intCommissionRecapId = @intNewCommissionRecapId

																	DELETE FROM tblARCommissionRecap WHERE intCommissionRecapId = @intNewCommissionRecapId
																END

															DELETE FROM @tblEntities WHERE intEntityId = @intEntityId
														END															
																			
													DELETE FROM @tblARCommissionScheduleDetails WHERE intCommissionScheduleDetailId = @intCommissionScheduleDetailId
												END
										END									
								END
						END
					
					SET @totalAmount = ISNULL((SELECT ISNULL(SUM(dblTotalAmount), 0) FROM tblARCommissionRecap WHERE strBatchId = @batchId), 0)
					DELETE FROM @tblARCommissionSchedules WHERE intCommissionScheduleId = @intActiveCommSchedId
				END
		END