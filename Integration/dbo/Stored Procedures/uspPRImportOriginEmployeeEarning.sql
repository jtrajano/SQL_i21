IF EXISTS (select top 1 1 from sys.procedures where name = 'uspPRImportOriginEmployeeEarning')
	DROP PROCEDURE [dbo].uspPRImportOriginEmployeeEarning
GO

CREATE PROCEDURE dbo.uspPRImportOriginEmployeeEarning(
    @ysnDoImport BIT = 0,
	@intRecordCount INT = 0 OUTPUT
)

AS

DECLARE @EmployeeCount AS NVARCHAR(50)
DECLARE @EntityId AS INT
DECLARE @strEmployeeId AS NVARCHAR(50)
DECLARE @strEarning AS NVARCHAR(50)
DECLARE @intEntityEmployeeId AS NVARCHAR(50)
DECLARE @intTypeEarningId AS INT
DECLARE @strCalculationType AS NVARCHAR(50)
DECLARE @dblAmount AS FLOAT
DECLARE @intAccountId AS INT
DECLARE @ysnUseLocationDistribution AS BIT
DECLARE @ysnDefault AS BIT

BEGIN

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'prempmst_ern_rows')
	BEGIN
		DROP TABLE [dbo].[prempmst_ern_rows]
	END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'prempmst_earnings_cv')
	BEGIN
		DROP TABLE [dbo].[prempmst_earnings_cv]
	END

	select 
		 premp_emp
		,premp_ern_code_col
		,premp_ern_code
		,premp_ern_active_yn_col
		,premp_ern_active_yn
		,premp_ern_freq_col
		,premp_ern_freq
		,premp_ern_amount_col
		,premp_ern_amount 
	Into prempmst_ern_rows
	from prempmst
	unpivot
	(
	  premp_ern_code
	  for premp_ern_code_col in 
		(
			 premp_ern_code_1
			,premp_ern_code_2
			,premp_ern_code_3
			,premp_ern_code_4
			,premp_ern_code_5
			,premp_ern_code_6
			,premp_ern_code_7
			,premp_ern_code_8
			,premp_ern_code_9
			,premp_ern_code_10
		) 
	) unpiv 

	unpivot
	(
	  premp_ern_active_yn
	  for premp_ern_active_yn_col in 
		(
			 premp_ern_active_yn_1
			,premp_ern_active_yn_2
			,premp_ern_active_yn_3
			,premp_ern_active_yn_4
			,premp_ern_active_yn_5
			,premp_ern_active_yn_6
			,premp_ern_active_yn_7
			,premp_ern_active_yn_8
			,premp_ern_active_yn_9
			,premp_ern_active_yn_10
		) 
	) unpiv 

	unpivot
	(
	  premp_ern_freq
	  for premp_ern_freq_col in 
		(
			 premp_ern_freq_1
			,premp_ern_freq_2
			,premp_ern_freq_3
			,premp_ern_freq_4
			,premp_ern_freq_5
			,premp_ern_freq_6
			,premp_ern_freq_7
			,premp_ern_freq_8
			,premp_ern_freq_9
			,premp_ern_freq_10
		) 
	) unpiv 

	unpivot
	(
	  premp_ern_amount
	  for premp_ern_amount_col in 
		(
			 premp_ern_amount_1
			,premp_ern_amount_2
			,premp_ern_amount_3
			,premp_ern_amount_4
			,premp_ern_amount_5
			,premp_ern_amount_6
			,premp_ern_amount_7
			,premp_ern_amount_8
			,premp_ern_amount_9
			,premp_ern_amount_10
		) 
	) unpiv 

	Select 
		'E'+ premp_emp  AS premp_emp_code
		,* INTO prempmst_earnings_cv 
	FROM prempmst_ern_rows 
		WHERE (
		   ( premp_ern_code_col = 'premp_ern_code_1' and premp_ern_active_yn_col = 'premp_ern_active_yn_1' and premp_ern_freq_col ='premp_ern_freq_1' and  premp_ern_amount_col = 'premp_ern_amount_1')
		or ( premp_ern_code_col = 'premp_ern_code_2' and premp_ern_active_yn_col = 'premp_ern_active_yn_2' and premp_ern_freq_col ='premp_ern_freq_2' and  premp_ern_amount_col = 'premp_ern_amount_2')
		or ( premp_ern_code_col = 'premp_ern_code_3' and premp_ern_active_yn_col = 'premp_ern_active_yn_3' and premp_ern_freq_col ='premp_ern_freq_3' and  premp_ern_amount_col = 'premp_ern_amount_3')
		or ( premp_ern_code_col = 'premp_ern_code_4' and premp_ern_active_yn_col = 'premp_ern_active_yn_4' and premp_ern_freq_col ='premp_ern_freq_4' and  premp_ern_amount_col = 'premp_ern_amount_4')
		or ( premp_ern_code_col = 'premp_ern_code_5' and premp_ern_active_yn_col = 'premp_ern_active_yn_5' and premp_ern_freq_col ='premp_ern_freq_5' and  premp_ern_amount_col = 'premp_ern_amount_5')
		or ( premp_ern_code_col = 'premp_ern_code_6' and premp_ern_active_yn_col = 'premp_ern_active_yn_6' and premp_ern_freq_col ='premp_ern_freq_6' and  premp_ern_amount_col = 'premp_ern_amount_6')
		or ( premp_ern_code_col = 'premp_ern_code_7' and premp_ern_active_yn_col = 'premp_ern_active_yn_7' and premp_ern_freq_col ='premp_ern_freq_7' and  premp_ern_amount_col = 'premp_ern_amount_7')
		or ( premp_ern_code_col = 'premp_ern_code_8' and premp_ern_active_yn_col = 'premp_ern_active_yn_8' and premp_ern_freq_col ='premp_ern_freq_8' and  premp_ern_amount_col = 'premp_ern_amount_8')
		or ( premp_ern_code_col = 'premp_ern_code_9' and premp_ern_active_yn_col = 'premp_ern_active_yn_9' and premp_ern_freq_col ='premp_ern_freq_9' and  premp_ern_amount_col = 'premp_ern_amount_9')
		or ( premp_ern_code_col = 'premp_ern_code_10' and premp_ern_active_yn_col = 'premp_ern_active_yn_10' and premp_ern_freq_col ='premp_ern_freq_10' and  premp_ern_amount_col = 'premp_ern_amount_10')
		)


	select @intRecordCount = COUNT(*) from prempmst_earnings_cv mern
	left join tblPRTypeEarning tern
	on mern.premp_ern_code collate Latin1_General_CI_AS = tern.strEarning
	left join tblPREmployee emp
	on emp.strEmployeeId = mern.premp_emp_code collate Latin1_General_CI_AS
	WHERE tern.strEarning is not null
	AND emp.intEntityId is not null

	IF (@ysnDoImport = 1)
	BEGIN
		WHILE EXISTS(SELECT TOP 1 NULL FROM prempmst_earnings_cv)
		BEGIN
			SELECT TOP 1
				 @intEntityEmployeeId			=	ern.premp_emp_code collate Latin1_General_CI_AS
				,@intTypeEarningId				=	(SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strEarning = ern.premp_ern_code collate Latin1_General_CI_AS)
				,@strCalculationType			=	(SELECT TOP 1 strCalculationType FROM tblPRTypeEarning WHERE strEarning = ern.premp_ern_code collate Latin1_General_CI_AS)
				,@dblAmount						=	premp_ern_amount
				,@intAccountId					=	(SELECT TOP 1 intAccountId FROM tblPRTypeEarning WHERE strEarning = ern.premp_ern_code collate Latin1_General_CI_AS)
				,@ysnUseLocationDistribution	=	0
				,@ysnDefault					=	1
				,@strEmployeeId					= ern.premp_emp_code
				,@strEarning					= ern.premp_ern_code
			FROM prempmst_earnings_cv ern

			SELECT @EntityId = intEntityId FROM tblPREmployee WHERE strEmployeeId = @intEntityEmployeeId

			IF (@EntityId IS NOT NULL)
			BEGIN
				IF EXISTS (SELECT TOP 1 * FROM tblPRTypeEarning WHERE strEarning = @strEarning)
				BEGIN
					IF NOT EXISTS (SELECT * FROM tblPREmployeeEarning where intEntityEmployeeId = @EntityId 
						AND intTypeEarningId =  (SELECT TOP 1 intTypeEarningId FROM tblPRTypeEarning WHERE strEarning = @strEarning))
					BEGIN
						INSERT INTO [dbo].[tblPREmployeeEarning]
						   ([intEntityEmployeeId]
						   ,[intTypeEarningId]
						   ,[strCalculationType]
						   ,[dblAmount]
						   ,[intAccountId]
						   ,[ysnUseLocationDistribution]
						   ,[ysnDefault]
						   ,intPayGroupId)
						   
						VALUES
						(
							@EntityId
						   ,@intTypeEarningId
						   ,@strCalculationType
						   ,@dblAmount
						   ,@intAccountId
						   ,0
						   ,1
						   ,(SELECT TOP 1 intPayGroupId FROM tblPRPayGroup WHERE strPayGroup = 'Weekly')
						)
					END
				END
			END
			
			DELETE FROM prempmst_earnings_cv 
				  WHERE premp_emp_code = @strEmployeeId
					AND premp_ern_code = @strEarning
		END
	END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'prempmst_ern_rows')
	BEGIN
		DROP TABLE [dbo].[prempmst_ern_rows]
	END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'prempmst_earnings_cv')
	BEGIN
		DROP TABLE [dbo].[prempmst_earnings_cv]
	END


END

GO