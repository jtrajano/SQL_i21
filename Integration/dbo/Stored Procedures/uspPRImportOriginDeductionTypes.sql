IF EXISTS (select top 1 1 from sys.procedures where name = 'uspPRImportOriginDeductionTypes')
	DROP PROCEDURE [dbo].uspPRImportOriginDeductionTypes
GO

CREATE PROCEDURE dbo.uspPRImportOriginDeductionTypes(
    @ysnDoImport BIT = 0,
	@intRecordCount INT = 0 OUTPUT
)

AS

BEGIN
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpDeductions')) 
	DROP TABLE #tmpDeductions

	SELECT DISTINCT 
		 strDeduction			=	prded_code
		,strDescription			=	prded_desc
		,strCategory			=	''
		,strCheckLiteral		=	prded_literal
		,intAccountId			=	(SELECT TOP 1 intAccountId FROM tblGLAccount 
										WHERE strAccountId = CONVERT(varchar(10),CAST(prded_glbs_acct AS int))+ '-' +CONVERT(varchar(10),RIGHT(PARSENAME(prded_glbs_acct,1),3)))
		,intExpenseAccountId	=	(SELECT TOP 1 intAccountId FROM tblGLAccount 
										WHERE strAccountId = CONVERT(varchar(10),CAST(prded_glexp_acct AS int))+ '-' +CONVERT(varchar(10),RIGHT(PARSENAME(prded_glexp_acct,1),3)))
		,strDeductFrom			=	''
		,strCalculationType		=	prded_type
		,dblAmount				=	prded_glbs_acct
		,dblLimit				=	prded_annual_max
		,dblPaycheckMax			=	prded_cycle_earn_limit
		,strW2Code				=	''
		,strPaidBy				=	CASE WHEN prded_co_emp_cd = 'E'THEN 'Employee' ELSE 'Company' END
		,ysnCreatePayable		=	null
		,intVendorId			=	null
		,intSort				=	0
		,intConcurrencyId		=	1
	INTO #tmpDeductions
	FROM
		prdedmst
	WHERE
		prded_code COLLATE Latin1_General_CI_AS NOT IN (SELECT strDeduction FROM tblPRTypeDeduction)

	SELECT @intRecordCount = COUNT(1) FROM #tmpDeductions

	IF (@ysnDoImport = 1)
	BEGIN
		INSERT INTO tblPRTypeDeduction
			(strDeduction
			,strDescription
			,strCategory
			,strCheckLiteral
			,intAccountId
			,intExpenseAccountId
			,strDeductFrom
			--,strCalculationType
			,dblAmount
			,dblLimit
			,dblPaycheckMax
			,strW2Code
			,strPaidBy
			,ysnCreatePayable
			,intVendorId
			,intSort
			,intConcurrencyId)
		SELECT
			 strDeduction
			,strDescription
			,strCategory
			,strCheckLiteral
			,intAccountId
			,intExpenseAccountId
			,strDeductFrom
			--,strCalculationType
			,dblAmount
			,dblLimit
			,dblPaycheckMax
			,strW2Code
			,strPaidBy
			,ysnCreatePayable
			,intVendorId
			,intSort
			,intConcurrencyId
		FROM #tmpDeductions
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpDeductions')) 
	DROP TABLE #tmpDeductions
END

GO