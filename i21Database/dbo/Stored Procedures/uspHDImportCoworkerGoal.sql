CREATE PROCEDURE [dbo].[uspHDImportCoworkerGoal]
	 @User NVARCHAR(100)
	,@ReportsTo NVARCHAR(100)
	,@FiscalYear NVARCHAR(100)
	,@Currency NVARCHAR(100)
	,@CommissionAccount NVARCHAR(100)
	,@RevenueAccount NVARCHAR(100)
	,@CommisionType NVARCHAR(100)
	,@RateType NVARCHAR(100)
	,@Active NVARCHAR(100)
	,@UtilizationTargetAnnual NVARCHAR(100)
	,@UtilizationTargetWeekly NVARCHAR(100)
	,@UtilizationTargetMonthly NVARCHAR(100)
	,@IncentiveRate NVARCHAR(100)
	,@CommissionRate NVARCHAR(100)
	,@AnnualHurdle NVARCHAR(100)
	,@AnnualBudget NVARCHAR(100)
	,@CanViewOtherCoworker NVARCHAR(100)
	,@Goal NVARCHAR(4000)
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
SET @Savepoint = SUBSTRING(('HDImportCoworkerGoal' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

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

	/*Validate User - required*/
	IF (@User IS NULL OR LTRIM(RTRIM(@User)) = '')
	BEGIN
		SET @message = @message + '- User is required.' + @newLine;
	END
	ELSE

	/*Validate Fiscal year - required*/
	IF (@FiscalYear IS NULL OR LTRIM(RTRIM(@FiscalYear)) = '')
	BEGIN
		SET @message = @message + '- Fiscal Year is required.' + @newLine;
	END
	ELSE
	BEGIN
		IF NOT EXISTS (
			SELECT TOP 1 ''
			FROM tblGLFiscalYear
			WHERE strFiscalYear = @FiscalYear
		)
		BEGIN
			SET @message = @message + '- Fiscal Year is not valid or not in the GL Fiscal Year.' + @newLine;
		END
	END

	/*Validate Currency - required*/
	IF (@Currency IS NULL OR LTRIM(RTRIM(@Currency)) = '')
	BEGIN
		SET @message = @message + '- Currency is required.' + @newLine;
	END

	/*Validate Commission Type*/
	IF (@CommisionType IS NOT NULL AND LTRIM(RTRIM(@CommisionType)) <> '')
	BEGIN
		IF lower(@CommisionType) NOT IN ('hourly no hurdle', 'hourly hurdle annual', 'hourly hurdle per period')
		BEGIN
			SET @message = @message + '- Commision Type should be Hourly no hurdle, Hourly hurdle annual or Hourly hurdle per period.' + @newLine;
		END
	END

	/*Validate Rate Type*/
	IF (@RateType IS NOT NULL AND LTRIM(RTRIM(@RateType)) <> '')
	BEGIN
		IF lower(@RateType) NOT IN ('flat amount', 'percentage')
		BEGIN
			SET @message = @message + '- Rate Type should be Flat Amount or Percentage.' + @newLine;
		END
	END

	/*Validate Active*/
	IF (@Active IS NOT NULL AND LTRIM(RTRIM(@Active)) <> '')
	BEGIN
		IF LTRIM(RTRIM(LOWER(@Active))) NOT IN ('yes', 'no')
		BEGIN
			SET @message = @message + '- Active should be Yes or No.' + @newLine;
		END
	END
	
	/*Validate Utilization Target Annual*/
	IF (@UtilizationTargetAnnual IS NOT NULL AND LTRIM(RTRIM(@UtilizationTargetAnnual)) <> '')
	BEGIN
		IF ISNUMERIC(LTRIM(RTRIM(@UtilizationTargetAnnual))) = 0
		BEGIN
			SET @message = @message + '- Utilization Target Annual should be numeric.' + @newLine;
		END
		ELSE IF ISNUMERIC(LTRIM(RTRIM(@UtilizationTargetAnnual))) = 1 AND ( CAST(@UtilizationTargetAnnual AS INT) < 1 OR CAST(@UtilizationTargetAnnual AS INT) > 150 )
		BEGIN
			SET @message = @message + '- Utilization Target Annual must be between 1-150.' + @newLine;
		END
	END
	ELSE
	BEGIN
		SET @message = @message + '- Utilization Target Weekly Annual have a value between 1-150.' + @newLine;
	END

	/*Validate Utilization Target Weekly*/
	IF (@UtilizationTargetWeekly IS NOT NULL AND LTRIM(RTRIM(@UtilizationTargetWeekly)) <> '')
	BEGIN
		IF ISNUMERIC(LTRIM(RTRIM(@UtilizationTargetWeekly))) = 0
		BEGIN
			SET @message = @message + '- Utilization Target Weekly should be numeric.' + @newLine;
		END
		ELSE IF ISNUMERIC(LTRIM(RTRIM(@UtilizationTargetWeekly))) = 1 AND ( CAST(@UtilizationTargetWeekly AS INT) < 1 OR CAST(@UtilizationTargetWeekly AS INT) > 60 )
		BEGIN
			SET @message = @message + '- Utilization Target Weekly must be between 1-60.' + @newLine;
		END
	END
	ELSE
	BEGIN
		SET @message = @message + '- Utilization Target Weekly should have a value between 1-60.' + @newLine;
	END

	/*Validate Utilization Target Monthly - required*/
	IF (@UtilizationTargetMonthly IS NOT NULL AND LTRIM(RTRIM(@UtilizationTargetMonthly)) <> '')
	BEGIN
		IF ISNUMERIC(LTRIM(RTRIM(@UtilizationTargetMonthly))) = 0
		BEGIN
			SET @message = @message + '- Utilization Target Monthly should be numeric.' + @newLine;
		END
		ELSE IF ISNUMERIC(LTRIM(RTRIM(@UtilizationTargetMonthly))) = 1 AND ( CAST(@UtilizationTargetMonthly AS INT) < 1 OR CAST(@UtilizationTargetMonthly AS INT) > 200 )
		BEGIN
			SET @message = @message + '- Utilization Target Monthly must be between 1-200.' + @newLine;
		END
	END
	ELSE
	BEGIN
		SET @message = @message + '- Utilization Target Monthly should have a value between 1-200.' + @newLine;
	END

	/*Validate Incentive Rate*/
	IF (@IncentiveRate IS NOT NULL AND LTRIM(RTRIM(@IncentiveRate)) <> '')
	BEGIN
		IF ISNUMERIC(LTRIM(RTRIM(@IncentiveRate))) = 0
		BEGIN
			SET @message = @message + '- Incentive Rate should be numeric.' + @newLine;
		END
	END

	/*Validate Commission Rate*/
	IF (@CommissionRate IS NOT NULL AND LTRIM(RTRIM(@CommissionRate)) <> '')
	BEGIN
		IF ISNUMERIC(LTRIM(RTRIM(@CommissionRate))) = 0
		BEGIN
			SET @message = @message + '- Commission Rate should be numeric.' + @newLine;
		END
	END

	/*Validate Annual Budget*/
	IF (@AnnualBudget IS NOT NULL AND LTRIM(RTRIM(@AnnualBudget)) <> '')
	BEGIN
		IF ISNUMERIC(LTRIM(RTRIM(@AnnualBudget))) = 0
		BEGIN
			SET @message = @message + '- Annual Budget should be numeric.' + @newLine;
		END
	END

	/*Validate Annual Hurdle*/
	IF (@AnnualHurdle IS NOT NULL AND LTRIM(RTRIM(@AnnualHurdle)) <> '')
	BEGIN
		IF ISNUMERIC(LTRIM(RTRIM(@AnnualHurdle))) = 0
		BEGIN
			SET @message = @message + '- Annual Hurdle should be numeric.' + @newLine;
		END
	END

	/*Validate Can View Other Coworker*/
	IF (@CanViewOtherCoworker IS NOT NULL AND LTRIM(RTRIM(@CanViewOtherCoworker)) <> '')
	BEGIN
		IF LTRIM(RTRIM(LOWER(@CanViewOtherCoworker))) NOT IN ('yes', 'no')
		BEGIN
			SET @message = @message + '- Can View Other Coworker should be Yes or No.' + @newLine;
		END
	END

	--Set Values
	DECLARE  @intEntityId INT
			,@intReportsToId INT
			,@intCurrencyId INT
			,@intCommissionAccount INT
			,@intRevenueAccount INT
			,@ysnActive bit
			,@ysnCanViewOtherCoworker bit

	/*Set intEntityId*/
	IF (@User IS NOT NULL AND LTRIM(RTRIM(@User)) <> '')
	BEGIN
		SELECT TOP 1 @intEntityId = intEntityId
		FROM vyuHDAgentDetail
		WHERE LTRIM(RTRIM(lower(strFullName))) = LTRIM(RTRIM(lower(@User)))
	END

	/*Set @intReportsToId*/
	IF (@ReportsTo IS NOT NULL AND LTRIM(RTRIM(@ReportsTo)) <> '')
	BEGIN
		SELECT TOP 1 @intReportsToId = intEntityId
		FROM vyuHDAgentDetail
		WHERE LTRIM(RTRIM(lower(strFullName))) = LTRIM(RTRIM(lower(@ReportsTo)))
	END

	/*Set currency*/
	IF (@Currency IS NOT NULL AND LTRIM(RTRIM(@Currency)) <> '')
	BEGIN
		SELECT TOP 1 @intCurrencyId = intCurrencyID
		FROM tblSMCurrency
		WHERE lower(strCurrency) = LTRIM(RTRIM(lower(@Currency)))
	END

	/*Set commission account*/
	IF (@CommissionAccount IS NOT NULL AND LTRIM(RTRIM(@CommissionAccount)) <> '')
	BEGIN
		SELECT TOP 1 @intCommissionAccount = intAccountId
		FROM vyuHDAccountDetail
		WHERE strAccountCategory = 'General' AND
			  strAccountId = @CommissionAccount 
	END

	/*Set revenue account*/
	IF (@RevenueAccount IS NOT NULL AND LTRIM(RTRIM(@RevenueAccount)) <> '')
	BEGIN
		SELECT TOP 1 @intRevenueAccount = intAccountId
		FROM vyuHDAccountDetail
		WHERE strAccountCategory = 'General' AND
			  strAccountId = @RevenueAccount 
	END

	/*Set Active*/
	IF (@Active IS NOT NULL AND LTRIM(RTRIM(@Active)) <> '')
	BEGIN
		IF LOWER(@Active) = 'yes'
		BEGIN
			SET @ysnActive = 1 
		END
		ELSE
		BEGIN
			SET @ysnActive = 0
		END
	END

	/*Set Can View Other Coworker*/
	IF (@CanViewOtherCoworker IS NOT NULL AND LTRIM(RTRIM(@CanViewOtherCoworker)) <> '')
	BEGIN
		IF LOWER(@CanViewOtherCoworker) = 'yes'
		BEGIN
			SET @ysnCanViewOtherCoworker = 1 
		END
		ELSE
		BEGIN
			SET @ysnCanViewOtherCoworker = 0
		END
	END

	IF (@User IS NOT NULL AND LTRIM(RTRIM(@User)) <> '' AND @intEntityId IS NULL)
	BEGIN
		SET @message = @message + '- User ' + @User + ' does not exist.' + @newLine;
	END

	IF (@ReportsTo IS NOT NULL AND LTRIM(RTRIM(@ReportsTo)) <> '' AND @intReportsToId IS NULL)
	BEGIN
		SET @message = @message + '- Reports To ' + @ReportsTo + ' does not exist.' + @newLine;
	END

	IF (@Currency IS NOT NULL AND LTRIM(RTRIM(@Currency)) <> '' AND @intCurrencyId IS NULL)
	BEGIN
		SET @message = @message + '- Currency ' + @Currency + ' does not exist.' + @newLine;
	END

	IF (@CommissionAccount IS NOT NULL AND LTRIM(RTRIM(@CommissionAccount)) <> ''  AND @intCommissionAccount IS NULL)
	BEGIN
		SET @message = @message + '- Commission Account does not exist.' + @newLine;
	END

	IF (@RevenueAccount IS NOT NULL AND LTRIM(RTRIM(@RevenueAccount)) <> ''  AND @RevenueAccount IS NULL)
	BEGIN
		SET @message = @message + '- Revenue Account does not exist.' + @newLine;
	END

	IF (@RevenueAccount IS NOT NULL AND LTRIM(RTRIM(@RevenueAccount)) <> ''  AND @RevenueAccount IS NULL)
	BEGIN
		SET @message = @message + '- Revenue Account does not exist.' + @newLine;
	END


	/*Validate if User / Fiscal Year is existing*/
	IF (@intEntityId IS NOT NULL AND (@FiscalYear IS NOT NULL OR LTRIM(RTRIM(@FiscalYear)) = ''))
	BEGIN

		IF EXISTS(SELECT TOP 1 '' 
				  FROM tblHDCoworkerGoal
				  WHERE intEntityId = @intEntityId AND
						strFiscalYear = @FiscalYear) OR 

		  EXISTS(SELECT TOP 1 '' 
				  FROM tblHDImportCoworkerGoal
				  WHERE intEntityId = @intEntityId AND
						strFiscalYear = @FiscalYear)  

		SET @message = @message + '- User ' + @User + ' with fiscal year ' + @FiscalYear + ' already exist.' + @newLine;
	END

	IF (LTRIM(RTRIM(@message)) = '')
	BEGIN
		INSERT INTO tblHDImportCoworkerGoal		
				(
					 [intEntityId]					
					,[strFiscalYear]					
					,[intCurrencyId]					
					,[intUtilizationTargetAnnual]	
					,[intUtilizationTargetWeekly]	
					,[intUtilizationTargetMonthly]	
					,[dblAnnualHurdle]				
					,[dblIncentiveRate]				
					,[dblAnnualBudget]				
					,[intCommissionAccountId]		
					,[intRevenueAccountId]			
					,[strGoal]						
					,[strCommissionType]				
					,[strRateType]					
					,[intCommissionRate]				
					,[intReportsToId]				
					,[intConcurrencyId]		
					,[ysnActive]						
					,[ysnCanViewOtherCoworker]		
				)
				SELECT  [intEntityId]					= @intEntityId
					   ,[strFiscalYear]					= @FiscalYear			
					   ,[intCurrencyId]					= @intCurrencyId		
					   ,[intUtilizationTargetAnnual]	= CAST(@UtilizationTargetAnnual AS INT)
					   ,[intUtilizationTargetWeekly]	= CAST(@UtilizationTargetWeekly AS INT)
					   ,[intUtilizationTargetMonthly]	= CAST(@UtilizationTargetMonthly AS INT)
					   ,[dblAnnualHurdle]				= CASE WHEN @AnnualHurdle IS NULL OR LTRIM(RTRIM(@AnnualHurdle)) = '' THEN 0 ELSE CAST(@AnnualHurdle AS NUMERIC(18, 6)) END
					   ,[dblIncentiveRate]				= CASE WHEN @IncentiveRate IS NULL OR LTRIM(RTRIM(@IncentiveRate)) = '' THEN 0 ELSE CAST(@IncentiveRate AS NUMERIC(18, 6)) END
					   ,[dblAnnualBudget]				= CASE WHEN @AnnualBudget IS NULL OR LTRIM(RTRIM(@IncentiveRate)) = '' THEN 0 ELSE CAST(@AnnualBudget AS NUMERIC(18, 6)) END
					   ,[intCommissionAccountId]		= @intCommissionAccount
					   ,[intRevenueAccountId]			= @intRevenueAccount
					   ,[strGoal]						= @Goal
					   ,[strCommissionType]				= CASE WHEN LOWER(@CommisionType) = 'hourly no hurdle'
																	THEN 'Hourly no hurdle' 
															   WHEN LOWER(@CommisionType) = 'hourly hurdle annual'
																	THEN 'Hourly hurdle annual' 
															   WHEN LOWER(@CommisionType) = 'hourly hurdle per period'
																	THEN 'Hourly hurdle per period' 
															   ELSE ''
														  END
					   ,[strRateType]					= CASE WHEN LOWER(@RateType) = 'flat amount'
																	THEN 'Flat amount' 
															   WHEN LOWER(@RateType) = 'percentage'
																	THEN 'Percentage' 
															   ELSE ''
														  END
					   ,[intCommissionRate]				= CASE WHEN @CommissionRate IS NULL OR LTRIM(RTRIM(@CommissionRate)) = '' THEN 0 ELSE CAST(@IncentiveRate AS NUMERIC(18, 6)) END
					   ,[intReportsToId]				= @intReportsToId
					   ,[intConcurrencyId]				= 1
					   ,[ysnActive]						= CASE WHEN @Active IS NULL OR LTRIM(RTRIM(@Active)) = '' THEN 1 ELSE @ysnActive END
					   ,[ysnCanViewOtherCoworker]		= CASE WHEN @ysnCanViewOtherCoworker IS NULL OR LTRIM(RTRIM(@ysnCanViewOtherCoworker)) = '' THEN 0 ELSE @ysnCanViewOtherCoworker END

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

GO