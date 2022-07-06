CREATE PROCEDURE [dbo].[uspHDImportTimeEntryPeriodDetail]
	 @TimeEntryPeriodId INT
	,@BillingPeriod NVARCHAR(100)
	,@BillingPeriodName NVARCHAR(100)
	,@BillingPeriodStart NVARCHAR(100)
	,@BillingPeriodEnd NVARCHAR(100)
	,@RequiredHours NVARCHAR(100)
	,@RaiseError		    BIT				= 0
	,@ErrorMessage			nvarchar(max)	= '' OUTPUT
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
SET @Savepoint = SUBSTRING(('HDImportTimeEntryPeriodDetail' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

BEGIN TRY

	DECLARE @newLine nvarchar(5) = '</br>';
	DECLARE @message nvarchar(max) = '';

	DECLARE @intFiscalYear INT
	DECLARE @intFirstWarningDays INT
	DECLARE @intSecondWarningDays INT
	DECLARE @intLockoutDays INT

	SELECT TOP 1 @intFiscalYear = CAST(strFiscalYear AS INT)
				,@intFirstWarningDays = intFirstWarningDays
				,@intSecondWarningDays = intSecondWarningDays
				,@intLockoutDays = intLockoutDays
	FROM tblHDTimeEntryPeriod
	WHERE intTimeEntryPeriodId = CAST(@TimeEntryPeriodId AS INT)


	/*Validate Time Entry Period Id - required*/
	IF (@TimeEntryPeriodId IS NULL OR LTRIM(RTRIM(@TimeEntryPeriodId)) = '')
	BEGIN
		SET @message = @message + '- Time Entry Period Id is required.' + @newLine;
	END

	/*Validate Billing Period - required*/
	IF (@BillingPeriod IS NULL OR LTRIM(RTRIM(@BillingPeriod)) = '')
	BEGIN
		SET @message = @message + '- Billing Period is required.' + @newLine;
	END

	/*Validate Billing Period Name - required*/
	IF (@BillingPeriodName IS NULL OR LTRIM(RTRIM(@BillingPeriodName)) = '')
	BEGIN
		SET @message = @message + '- Billing Period Name is required.' + @newLine;
	END

	/*Validate Billing Period Start - required*/
	IF (@BillingPeriodStart IS NULL OR LTRIM(RTRIM(@BillingPeriodStart)) = '')
	BEGIN
		SET @message = @message + '- Billing Period Start is required.' + @newLine;
	END
	ELSE  /*Validate Billing Period Start - overlapping*/
	BEGIN

		IF ISDATE(@BillingPeriodStart) <> 1
		BEGIN
			SET @message = @message + '- Billing Period Start has invalid format.' + @newLine;
		END
		BEGIN
				IF DATEPART(YEAR, @BillingPeriodStart) <> @intFiscalYear
				BEGIN
						SET @message = @message + '- Billing Period Start year is different with selected fiscal year.' + @newLine;
				END
				ELSE  IF EXISTS( 
							SELECT TOP 1 ''
								FROM tblHDTimeEntryPeriodDetail
								WHERE dtmBillingPeriodStart <= CAST(@BillingPeriodStart AS DATETIME) AND 
									  dtmBillingPeriodEnd >= CAST(@BillingPeriodStart AS DATETIME) AND
									  intTimeEntryPeriodId = CAST(@TimeEntryPeriodId AS INT)
							 )
				BEGIN
							SET @message = @message + '- Billing Period Start is overlapping.' + @newLine;
				END
		END
	END

	/*Validate Billing Period End - required*/
	IF (@BillingPeriodEnd IS NULL OR LTRIM(RTRIM(@BillingPeriodEnd)) = '')
	BEGIN
		SET @message = @message + '- Billing Period End is required.' + @newLine;
	END
	ELSE  /*Validate Billing Period End - overlapping*/
	BEGIN

		IF ISDATE(@BillingPeriodEnd) <> 1
		BEGIN
			SET @message = @message + '- Billing Period End has invalid format.' + @newLine;
		END
		BEGIN
				IF DATEPART(YEAR, @BillingPeriodEnd) <> @intFiscalYear
				BEGIN
						SET @message = @message + '- Billing Period End year is different with selected fiscal year.' + @newLine;
				END
				ELSE  IF EXISTS( 
							SELECT TOP 1 ''
								FROM tblHDTimeEntryPeriodDetail
								WHERE dtmBillingPeriodStart <= CAST(@BillingPeriodEnd AS DATETIME) AND 
									  dtmBillingPeriodEnd >= CAST(@BillingPeriodEnd AS DATETIME) AND
									  intTimeEntryPeriodId = CAST(@TimeEntryPeriodId AS INT)
							 )
				BEGIN
							SET @message = @message + '- Billing Period End is overlapping.' + @newLine;
				END
		END
	END

	/*Validate if Billing Period Start is less than Billing Period End*/
	IF (
	     (@BillingPeriodStart IS NOT NULL AND LTRIM(RTRIM(@BillingPeriodStart)) <> '') AND
		 ISDATE(@BillingPeriodStart) = 1 AND
		 (@BillingPeriodEnd IS NOT NULL AND LTRIM(RTRIM(@BillingPeriodEnd)) <> '') AND
		 ISDATE(@BillingPeriodEnd) = 1 AND
		 CAST(@BillingPeriodStart AS DATETIME) > CAST(@BillingPeriodEnd AS DATETIME)	 	 
		)
	BEGIN
		SET @message = @message + '- Billing Period Start should not be greater than Billing Period End.' + @newLine;
	END


	/*Validate Required Hours - required*/
	IF (@RequiredHours IS NULL OR LTRIM(RTRIM(@RequiredHours)) = '')
	BEGIN
		SET @message = @message  + '- Required Hours is required.' + @newLine;
	END

	IF (LTRIM(RTRIM(@message)) = '')
	BEGIN
		
		DECLARE @dtmFirstWarningDate DATETIME,
				@dtmSecondWarningDate DATETIME,
				@dtmLockoutDate DATETIME

		SET @dtmFirstWarningDate = DATEADD(DAY, @intFirstWarningDays, CAST(@BillingPeriodEnd AS DATETIME))
		SET @dtmSecondWarningDate = DATEADD(DAY, @intSecondWarningDays, CAST(@BillingPeriodEnd AS DATETIME))
		SET @dtmLockoutDate = DATEADD(DAY, @intLockoutDays, CAST(@BillingPeriodEnd AS DATETIME))

		INSERT INTO tblHDTimeEntryPeriodDetail
					(
						[intTimeEntryPeriodId]
					   ,[intBillingPeriod]
					   ,[strBillingPeriodName]
					   ,[dtmBillingPeriodStart]
					   ,[dtmBillingPeriodEnd]
					   ,[dtmFirstWarningDate]
					   ,[dtmSecondWarningDate]
					   ,[dtmLockoutDate]
					   ,[strBillingPeriodStatus]
					   ,[intRequiredHours]
					)
		SELECT  [intTimeEntryPeriodId]		 = CAST(@TimeEntryPeriodId AS INT)
			   ,[intBillingPeriod]			 = CAST(@BillingPeriod AS INT)
			   ,[strBillingPeriodName]		 = @BillingPeriodName
			   ,[dtmBillingPeriodStart]		 = CAST(@BillingPeriodStart AS DATETIME)
			   ,[dtmBillingPeriodEnd]		 = CAST(@BillingPeriodEnd AS DATETIME)
			   ,[dtmFirstWarningDate]		 = @dtmFirstWarningDate
			   ,[dtmSecondWarningDate]		 = @dtmSecondWarningDate
			   ,[dtmLockoutDate]			 = @dtmLockoutDate
			   ,[strBillingPeriodStatus]     = 'Open'
			   ,[intRequiredHours]			 = CAST(@RequiredHours AS INT)

	END
	ELSE 
	BEGIN
		SET @ErrorMessage = @message + @newLine;
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