CREATE PROCEDURE [dbo].[uspARProcessCommissionSchedule]
	@commissionIds	NVARCHAR(MAX) = ''
AS
	--INSERT PARSE SELECTED COMM. SCHED. FROM STRING INTO TEMP TABLE
	DECLARE @tmpCommissionSchedule TABLE (intCommissionScheduleId INT)
	
	INSERT INTO @tmpCommissionSchedule
	SELECT intID FROM fnGetRowsFromDelimitedValues(@commissionIds)
			
	IF EXISTS(SELECT NULL FROM @tmpCommissionSchedule)
		BEGIN
			--GET COMM. SCHED. INFO WHERE ysnActive = 1
			DECLARE @tblCommissionSchedules TABLE (intCommissionScheduleId INT, ysnAutoCreatePayables BIT, ysnAutoCreatePayroll BIT)

			WHILE EXISTS(SELECT TOP 1 1 FROM @tmpCommissionSchedule)
				BEGIN
					DECLARE @intCommissionScheduleId	INT

					SELECT TOP 1 @intCommissionScheduleId = intCommissionScheduleId FROM @tmpCommissionSchedule ORDER BY intCommissionScheduleId

					INSERT INTO @tblCommissionSchedules 
						  (intCommissionScheduleId
						 , ysnAutoCreatePayables
						 , ysnAutoCreatePayroll)
					SELECT intCommissionScheduleId
						 , ysnAutoPayables
						 , ysnAutoPayroll
					FROM tblARCommissionSchedule
					WHERE intCommissionScheduleId = @intCommissionScheduleId
					  AND ysnActive = 1

					DELETE FROM @tmpCommissionSchedule WHERE intCommissionScheduleId = @intCommissionScheduleId
				END

			--GET COMM. SCHED. DETAILS WHERE intCommissionScheduleId
			IF EXISTS(SELECT NULL FROM @tblCommissionSchedules)
				BEGIN
					DECLARE @tblCommissionScheduleDetails TABLE (intEntityId INT, intCommissionPlanId INT, ysnAdjustForPrevious BIT, ysnEmployee BIT)

					WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommissionSchedules)
						BEGIN
							DECLARE @intActiveCommSchedId	INT,
								    @ysnAutoCreatePayables	BIT,
								    @ysnAutoCreatePayroll	BIT

							SELECT TOP 1 
							       @intActiveCommSchedId  = intCommissionScheduleId
							     , @ysnAutoCreatePayables = ysnAutoCreatePayables
								 , @ysnAutoCreatePayroll  = ysnAutoCreatePayroll
							FROM @tblCommissionSchedules ORDER BY intCommissionScheduleId

							INSERT INTO @tblCommissionScheduleDetails
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
							IF EXISTS(SELECT NULL FROM @tblCommissionScheduleDetails)
								BEGIN
									WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommissionScheduleDetails)
										BEGIN
											DECLARE @intCommissionPlanId	INT
									              , @intEntityId			INT
												  , @ysnEmployee			BIT
											SELECT TOP 1
												   @intCommissionPlanId = intCommissionPlanId
											     , @intEntityId			= intEntityId
												 , @ysnEmployee			= ysnEmployee
											FROM @tblCommissionScheduleDetails
											
											EXEC dbo.uspARCalculateCommission @intCommissionPlanId, @intEntityId, @ysnEmployee, @ysnAutoCreatePayables, @ysnAutoCreatePayroll

											DELETE FROM @tblCommissionScheduleDetails WHERE intCommissionPlanId = @intCommissionPlanId
										END									
								END

							DELETE FROM @tblCommissionSchedules WHERE intCommissionScheduleId = @intActiveCommSchedId
						END
				END
			
		END