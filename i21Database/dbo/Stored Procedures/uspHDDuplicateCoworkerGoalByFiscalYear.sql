CREATE PROCEDURE [dbo].[uspHDDuplicateCoworkerGoalByFiscalYear]
	 @strFromFiscalYear			NVARCHAR(50)
	,@strToFiscalYear			NVARCHAR(50)
	,@RaiseError			BIT				= 0
	,@ErrorMessage			NVARCHAR(250)	= NULL	OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON


DECLARE @InitTranCount INT
		,@Savepoint NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('HDDuplicateCoworkerGoalByFiscalYear' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

BEGIN TRY

DECLARE  @CoworkerGoalId INT
		,@EntityId INT
		,@NewCoworkerGoalId INT

IF ISNULL(LTRIM(RTRIM(@strFromFiscalYear)), '') = ''
BEGIN
	SET @ErrorMessage = 'Please select From Fiscal Year.'

	RETURN
END

IF ISNULL(LTRIM(RTRIM(@strToFiscalYear)), '') = ''
BEGIN
	SET @ErrorMessage = 'Please select To Fiscal Year.'

	RETURN
END

IF @strFromFiscalYear > @strToFiscalYear
BEGIN
	SET @ErrorMessage = 'To Fiscal Year should not be less than From Fiscal Year.'

	RETURN
END

IF @strFromFiscalYear = @strToFiscalYear
BEGIN
	SET @ErrorMessage = 'From Fiscal Year should not be the same To Fiscal Year.'

	RETURN
END

IF NOT EXISTS (
	SELECT TOP 1 ''
	FROM tblHDTimeEntryPeriod
	WHERE strFiscalYear =  @strFromFiscalYear
)
BEGIN
	SET @ErrorMessage = 'Please setup Time Entry Period for Fiscal Year ' + @strFromFiscalYear  + ' .'

	RETURN
END

IF NOT EXISTS (
	SELECT TOP 1 ''
	FROM tblHDTimeEntryPeriod
	WHERE strFiscalYear =  @strToFiscalYear
)
BEGIN
	SET @ErrorMessage = 'Please setup Time Entry Period for Fiscal Year ' + @strToFiscalYear  + ' .'

	RETURN
END

DECLARE CoworkerGoalLoop CURSOR 
	LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 

SELECT a.intEntityId 
FROM tblHDCoworkerGoal a
	INNER JOIN vyuHDAgentDetail b
ON a.intEntityId = b.intEntityId
WHERE a.strFiscalYear = @strFromFiscalYear
GROUP BY a.intEntityId

OPEN CoworkerGoalLoop
FETCH NEXT FROM CoworkerGoalLoop INTO @EntityId
WHILE @@FETCH_STATUS = 0 
BEGIN 
		
	IF NOT EXISTS(
			SELECT TOP 1 ''
			FROM tblHDCoworkerGoal
			WHERE intEntityId = @EntityId AND
				  strFiscalYear = @strToFiscalYear
	) 
	BEGIN

	--Insert Coworker Goal

	INSERT INTO tblHDCoworkerGoal
	(
			 [intEntityId]						
			,[strFiscalYear]						
			,[intCurrencyId]						
			,[intUtilizationTargetAnnual]		
			,[intUtilizationTargetWeekly]		
			,[intUtilizationTargetMonthly]		
			,[dblAnnualHurdle]									
			,[dblAnnualBudget]					
			,[intCommissionAccountId]			
			,[intRevenueAccountId]				
			,[strGoal]							
			,[strCommissionType]					
			,[strCommissionRateType]					    
			,[dblCommissionRate]
			,[strIncentiveType]					
			,[strIncentiveRateType]
			,[dblIncentiveRate]	
			,[dblUnderAllocated]
			,[intReportsToId]					
			,[intConcurrencyId] 			
			,[ysnActive]							
			,[ysnCanViewOtherCoworker]			
	 )

	 SELECT  
			 [intEntityId]						=	CoworkerGoal.[intEntityId]					
			,[strFiscalYear]					=	@strToFiscalYear				
			,[intCurrencyId]					=	CoworkerGoal.[intCurrencyId]				
			,[intUtilizationTargetAnnual]		=	CoworkerGoal.[intUtilizationTargetAnnual]	
			,[intUtilizationTargetWeekly]		=	CoworkerGoal.[intUtilizationTargetWeekly]	
			,[intUtilizationTargetMonthly]		=	CoworkerGoal.[intUtilizationTargetMonthly]	
			,[dblAnnualHurdle]					=	CoworkerGoal.[dblAnnualHurdle]							
			,[dblAnnualBudget]					=	CoworkerGoal.[dblAnnualBudget]				
			,[intCommissionAccountId]			=	CoworkerGoal.[intCommissionAccountId]		
			,[intRevenueAccountId]				=	CoworkerGoal.[intRevenueAccountId]			
			,[strGoal]							=	CoworkerGoal.[strGoal]						
			,[strCommissionType]				=	CoworkerGoal.[strCommissionType]			
			,[strCommissionRateType]		    =	CoworkerGoal.[strCommissionRateType]	
			,[dblCommissionRate]				=	CoworkerGoal.[dblCommissionRate]
			,[strIncentiveType]					=	CoworkerGoal.[strIncentiveType]			
			,[strIncentiveRateType]				=	CoworkerGoal.[strIncentiveRateType]	
			,[dblIncentiveRate]					=	CoworkerGoal.[dblIncentiveRate]	
			,[dblUnderAllocated]				=   CoworkerGoal.[dblAnnualBudget]
			,[intReportsToId]					=	CoworkerGoal.[intReportsToId]				
			,[intConcurrencyId] 				=	1 			
			,[ysnActive]						=	CoworkerGoal.[ysnActive]					
			,[ysnCanViewOtherCoworker]			=	CoworkerGoal.[ysnCanViewOtherCoworker]	
	 FROM tblHDCoworkerGoal CoworkerGoal		
	 WHERE CoworkerGoal.intEntityId = @EntityId AND
		   CoworkerGoal.strFiscalYear = @strFromFiscalYear

	 SET @NewCoworkerGoalId = SCOPE_IDENTITY()

	 --Insert Coworker Goal Detail

	 EXEC uspHDCreateCoworkerGoalDetail @NewCoworkerGoalId
	 EXEC uspHDSyncAgentTimeEntrySummary @NewCoworkerGoalId, 0, 1, 0
	
	END
	ELSE
	BEGIN

		SET @ErrorMessage = 'There are coworker goal/s that already exist.'

	END

	FETCH NEXT FROM CoworkerGoalLoop INTO @EntityId
END
CLOSE CoworkerGoalLoop
DEALLOCATE CoworkerGoalLoop

END TRY
BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = ERROR_MESSAGE();
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN
END CATCH

IF ISNULL(@RaiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END
	
RETURN 1;

END

GO