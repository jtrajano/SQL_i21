IF EXISTS (select top 1 1 from sys.procedures where name = 'uspPRImportOriginEmployeeDeduction')
	DROP PROCEDURE [dbo].uspPRImportOriginEmployeeDeduction
GO

CREATE PROCEDURE dbo.uspPRImportOriginEmployeeDeduction(
    @ysnDoImport BIT = 0,
	@intRecordCount INT = 0 OUTPUT
)

AS

DECLARE @strEmployeeId AS NVARCHAR(50)
DECLARE @strDeduction AS NVARCHAR(50)
DECLARE @intEntityEmployeeId AS INT
DECLARE @intTypeDeductionId AS INT
DECLARE @strDeductFrom AS NVARCHAR(50)
DECLARE @strCalculationType AS NVARCHAR(50)
DECLARE @dblAmount AS FLOAT
DECLARE @dblLimit AS FLOAT
DECLARE @intAccountId AS INT
DECLARE @intExpenseAccountId AS INT
DECLARE @ysnUseLocationDistribution AS BIT
DECLARE @ysnUseLocationDistributionExpense AS BIT
DECLARE @strPaidBy AS NVARCHAR(50)
DECLARE @ysnDefault AS BIT

BEGIN

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'prempmst_ded_rows')
	BEGIN
		DROP TABLE [dbo].[prempmst_ded_rows]
	END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'prempmst_deductions_cv')
	BEGIN
		DROP TABLE [dbo].[prempmst_deductions_cv]
	END


	--Extracting data from prempmst
	SELECT premp_emp, premp_ded_code_col , premp_ded_data ,premp_ded_type_col, premp_ded_type, premp_ded_active_col ,premp_ded_active , premp_ded_calc_code_col , premp_ded_calc_code ,
	premp_ded_amt_pct_col, premp_ded_amt_pct,premp_ded_limit_col, premp_ded_limit  
	INTO prempmst_ded_rows
	FROM prempmst
	UNPIVOT
	(
		premp_ded_data
		FOR premp_ded_code_col in (premp_ded_code_1, premp_ded_code_2, premp_ded_code_3, premp_ded_code_4, premp_ded_code_5, premp_ded_code_6) 
	) unpiv 
	UNPIVOT
	(
		premp_ded_type
		FOR premp_ded_type_col in (premp_ded_type_1 , premp_ded_type_2 ,premp_ded_type_3, premp_ded_type_4 ,premp_ded_type_5, premp_ded_type_6)
	) unpiv
	UNPIVOT
	(
		premp_ded_active
		FOR premp_ded_active_col in (premp_ded_active_yn_1 ,premp_ded_active_yn_2 ,premp_ded_active_yn_3 ,premp_ded_active_yn_4 ,premp_ded_active_yn_5 ,premp_ded_active_yn_6 )
	) unpiv
	UNPIVOT 
	(
		premp_ded_calc_code
		for premp_ded_calc_code_col in (premp_ded_calc_code_1 ,premp_ded_calc_code_2 ,premp_ded_calc_code_3 ,premp_ded_calc_code_4 ,premp_ded_calc_code_5 ,premp_ded_calc_code_6 )
	)unpiv 
	UNPIVOT 
	(
		premp_ded_amt_pct
		for premp_ded_amt_pct_col in (premp_ded_amt_pct_1,premp_ded_amt_pct_2,premp_ded_amt_pct_3,premp_ded_amt_pct_4,premp_ded_amt_pct_5,premp_ded_amt_pct_6 )
	) unpiv
	UNPIVOT 
	( 
		premp_ded_limit 
		for premp_ded_limit_col in (premp_ded_limit_1,premp_ded_limit_2,premp_ded_limit_3,premp_ded_limit_4,premp_ded_limit_5,premp_ded_limit_6)
	)unpiv ; 


	--finalizing data
	SELECT 'E'+ premp_emp  AS premp_emp_code, * INTO prempmst_deductions_cv FROM prempmst_ded_rows WHERE (( premp_ded_code_col = 'premp_ded_code_1' and premp_ded_type_col = 'premp_ded_type_1' and premp_ded_active_col ='premp_ded_active_yn_1' and  premp_ded_calc_code_col = 'premp_ded_calc_code_1' and premp_ded_amt_pct_col = 'premp_ded_amt_pct_1' and premp_ded_limit_col = 'premp_ded_limit_1')
	OR ( premp_ded_code_col = 'premp_ded_code_2' and premp_ded_type_col = 'premp_ded_type_2' and premp_ded_active_col ='premp_ded_active_yn_2' and  premp_ded_calc_code_col = 'premp_ded_calc_code_2' and premp_ded_amt_pct_col = 'premp_ded_amt_pct_2' and premp_ded_limit_col = 'premp_ded_limit_2')
	OR ( premp_ded_code_col = 'premp_ded_code_3' and premp_ded_type_col = 'premp_ded_type_3' and premp_ded_active_col ='premp_ded_active_yn_3' and  premp_ded_calc_code_col = 'premp_ded_calc_code_3' and premp_ded_amt_pct_col = 'premp_ded_amt_pct_3' and premp_ded_limit_col = 'premp_ded_limit_3')
	OR ( premp_ded_code_col = 'premp_ded_code_4' and premp_ded_type_col = 'premp_ded_type_4' and premp_ded_active_col ='premp_ded_active_yn_4' and  premp_ded_calc_code_col = 'premp_ded_calc_code_4' and premp_ded_amt_pct_col = 'premp_ded_amt_pct_4' and premp_ded_limit_col = 'premp_ded_limit_4')
	OR ( premp_ded_code_col = 'premp_ded_code_5' and premp_ded_type_col = 'premp_ded_type_5' and premp_ded_active_col ='premp_ded_active_yn_5' and  premp_ded_calc_code_col = 'premp_ded_calc_code_5' and premp_ded_amt_pct_col = 'premp_ded_amt_pct_5' and premp_ded_limit_col = 'premp_ded_limit_5')
	OR ( premp_ded_code_col = 'premp_ded_code_6' and premp_ded_type_col = 'premp_ded_type_6' and premp_ded_active_col ='premp_ded_active_yn_6' and  premp_ded_calc_code_col = 'premp_ded_calc_code_6' and premp_ded_amt_pct_col = 'premp_ded_amt_pct_6' and premp_ded_limit_col = 'premp_ded_limit_6')
	)

	select @intRecordCount = COUNT(1) from prempmst_deductions_cv tded
	left join tblPRTypeDeduction mded
	on tded.premp_ded_data collate Latin1_General_CI_AS = mded.strDeduction
	left join tblPREmployee emp
	on emp.strEmployeeId = tded.premp_emp_code collate Latin1_General_CI_AS
	WHERE mded.strDeduction is not null
	AND emp.intEntityId is not null
	

	--SELECT @intRecordCount = COUNT(1) FROM prempmst_deductions_cv

	IF (@ysnDoImport = 1)
	BEGIN
		WHILE EXISTS(SELECT TOP 1 NULL FROM prempmst_deductions_cv)
		BEGIN
			SELECT TOP 1 
				 @intEntityEmployeeId				= ISNULL((SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = ded.premp_emp_code collate Latin1_General_CI_AS),0)
				,@intTypeDeductionId				= (SELECT TOP 1 intTypeDeductionId FROM tblPRTypeDeduction WHERE strDeduction = ded.premp_ded_data collate Latin1_General_CI_AS)
				,@strDeductFrom						= (SELECT TOP 1 strDeductFrom FROM tblPRTypeDeduction WHERE strDeduction = ded.premp_ded_data collate Latin1_General_CI_AS)
				,@strCalculationType				= (SELECT TOP 1 strCalculationType FROM tblPRTypeDeduction WHERE strDeduction = ded.premp_ded_data collate Latin1_General_CI_AS)
				,@dblAmount							= ded.premp_ded_amt_pct
				,@dblLimit							= ded.premp_ded_limit
				,@intAccountId						= (SELECT TOP 1 intAccountId FROM tblPRTypeDeduction WHERE strDeduction = ded.premp_ded_data collate Latin1_General_CI_AS)
				,@intExpenseAccountId				= (SELECT TOP 1 intExpenseAccountId FROM tblPRTypeDeduction WHERE strDeduction = ded.premp_ded_data collate Latin1_General_CI_AS)
				,@ysnUseLocationDistribution		= 0
				,@ysnUseLocationDistributionExpense = 0
				,@strPaidBy							= (SELECT TOP 1 strPaidBy FROM tblPRTypeDeduction WHERE strDeduction = ded.premp_ded_data collate Latin1_General_CI_AS)
				,@ysnDefault						= 1
				,@strEmployeeId						= ded.premp_emp_code
				,@strDeduction						= ded.premp_ded_data
				FROM prempmst_deductions_cv ded
			
			IF (@intEntityEmployeeId != 0)
			BEGIN
				IF EXISTS (SELECT TOP 1 * FROM tblPRTypeTax WHERE strTax = @strDeduction)
				BEGIN
					IF NOT EXISTS (SELECT * FROM tblPREmployeeDeductionTax where intEmployeeDeductionId = @intEntityEmployeeId 
									AND intTypeTaxId =  (SELECT TOP 1 intTypeTaxId FROM tblPRTypeTax WHERE strTax = @strDeduction))
					BEGIN
						INSERT INTO [dbo].[tblPREmployeeDeduction]
						   ([intEntityEmployeeId]
						   ,[intTypeDeductionId]
						   ,[strDeductFrom]
						   ,[strCalculationType]
						   ,[dblAmount]
						   ,[dblLimit]
						   ,[intAccountId]
						   ,[intExpenseAccountId]
						   ,[ysnUseLocationDistribution]
						   ,[ysnUseLocationDistributionExpense]
						   ,[strPaidBy]
						   ,[ysnDefault])
						VALUES
						(
							 @intEntityEmployeeId
							,@intTypeDeductionId
							,@strDeductFrom
							,@strCalculationType
							,@dblAmount
							,@dblLimit
							,@intAccountId
							,@intExpenseAccountId
							,@ysnUseLocationDistribution
							,@ysnUseLocationDistributionExpense
							,@strPaidBy
							,@ysnDefault
						)
					END
				
				END
			END


			DELETE FROM prempmst_deductions_cv 
				  WHERE premp_emp_code = @strEmployeeId
					AND premp_ded_data = @strDeduction

		END

	END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'prempmst_ded_rows')
	BEGIN
		DROP TABLE [dbo].[prempmst_ded_rows]
	END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'prempmst_deductions_cv')
	BEGIN
		DROP TABLE [dbo].[prempmst_deductions_cv]
	END
END


GO