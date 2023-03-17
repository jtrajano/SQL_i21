CREATE PROCEDURE [dbo].[uspHDDuplicateCoworkerGoal]
	 @CoworkerGoalId		INT
	,@NewCoworkerGoalId		INT				= NULL	OUTPUT
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
SET @Savepoint = SUBSTRING(('HDDuplicateCoworkerGoal' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

BEGIN TRY

DECLARE  @FiscalYearUp	 nvarchar(100)
		,@FiscalYearDown nvarchar(100)
		,@FiscalYear	 nvarchar(100)
		,@NewFiscalYear	 nvarchar(100)
		,@intEntityId INT
		,@ysnCursorClosed BIT = 0

SELECT	 @FiscalYear = strFiscalYear
		,@intEntityId = intEntityId
FROM tblHDCoworkerGoal
WHERE intCoworkerGoalId = @CoworkerGoalId


DECLARE FiscalYearUpLoop CURSOR 
	LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 

SELECT DISTINCT a.strFiscalYear 
FROM tblGLFiscalYear a
WHERE CAST(strFiscalYear AS int) > CAST(@FiscalYear AS int)
ORDER BY a.strFiscalYear

OPEN FiscalYearUpLoop
FETCH NEXT FROM FiscalYearUpLoop INTO @FiscalYearUp
WHILE @@FETCH_STATUS = 0 AND @ysnCursorClosed = 0
BEGIN 
		
	IF NOT EXISTS(
			SELECT TOP 1 ''
			FROM tblHDCoworkerGoal
			WHERE intEntityId = @intEntityId AND
					strFiscalYear = @FiscalYearUp
	) 
	BEGIN

		SET @NewFiscalYear = @FiscalYearUp

		SET @ysnCursorClosed = 1
		
	END

	FETCH NEXT FROM FiscalYearUpLoop INTO @FiscalYearUp
END
CLOSE FiscalYearUpLoop
DEALLOCATE FiscalYearUpLoop

SET @ysnCursorClosed = 0

IF @NewFiscalYear IS NULL
BEGIN
					
	DECLARE FiscalYearDownLoop CURSOR 
		LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR 

	SELECT DISTINCT a.strFiscalYear 
	FROM tblGLFiscalYear a
	WHERE CAST(strFiscalYear AS int) < CAST(@FiscalYear AS int)
	ORDER BY a.strFiscalYear DESC

	OPEN FiscalYearDownLoop
	FETCH NEXT FROM FiscalYearDownLoop INTO @FiscalYearDown
	WHILE @@FETCH_STATUS = 0 AND @ysnCursorClosed = 0
	BEGIN 
				
		IF NOT EXISTS(
				SELECT TOP 1 ''
				FROM tblHDCoworkerGoal
				WHERE intEntityId = @intEntityId AND
						strFiscalYear = @FiscalYearDown
		)
		BEGIN
			SET @NewFiscalYear = @FiscalYearDown
			
			SET @ysnCursorClosed = 1
		END

		FETCH NEXT FROM FiscalYearDownLoop INTO @FiscalYearDown
	END
	CLOSE FiscalYearDownLoop
	DEALLOCATE FiscalYearDownLoop

	SET @ysnCursorClosed = 0 

END

IF @NewFiscalYear IS NOT NULL
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
			,[strFiscalYear]					=	@NewFiscalYear				
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
	 WHERE CoworkerGoal.intCoworkerGoalId = @CoworkerGoalId

	 SET @NewCoworkerGoalId = SCOPE_IDENTITY()

	 --Insert Coworker Goal Detail

	 EXEC uspHDCreateCoworkerGoalDetail @NewCoworkerGoalId
	 EXEC uspHDSyncAgentTimeEntrySummary @NewCoworkerGoalId, 0, 1, 0

END

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