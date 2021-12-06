CREATE PROCEDURE dbo.uspPRImportOriginEarningTypes(
    @ysnDoImport BIT = 0,
	@intRecordCount INT = 0 OUTPUT
)

AS

BEGIN
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEarnings')) 
	DROP TABLE #tmpEarnings

	SELECT DISTINCT 
		 strEarning					=	prern_code
		,strDescription				=	prern_description
		,strCheckLiteral			=	prern_literal
		,strCalculationType			=	''
		,dblAmount					=	prern_rate_factor
		,dblDefaultHours			=	0
		,strW2Code					=	''
		,intAccountId				=	(SELECT TOP 1 intAccountId FROM tblGLAccount 
										WHERE strAccountId = CONVERT(varchar(10),CAST(prern_glexp_acct AS int))+ '-' +CONVERT(varchar(10),RIGHT(PARSENAME(prern_glexp_acct,1),3)))
		,intTaxCalculationType		=	0
		,intSort					=	1
		,intConcurrencyId			=	1
	INTO #tmpEarnings
	FROM
		prernmst
	WHERE
		prern_code COLLATE Latin1_General_CI_AS NOT IN (SELECT strEarning FROM tblPRTypeEarning)

	SELECT @intRecordCount = COUNT(1) FROM #tmpEarnings

	IF (@ysnDoImport = 1)
	BEGIN
		INSERT INTO tblPRTypeEarning
			(
				 strEarning
				,strDescription
				,strCheckLiteral
				,strCalculationType
				,dblAmount
				,dblDefaultHours
				,strW2Code
				,intAccountId
				,intTaxCalculationType
				,intSort
				,intConcurrencyId
			)
		SELECT
			 strEarning
			,strDescription
			,strCheckLiteral
			,strCalculationType
			,dblAmount
			,dblDefaultHours
			,strW2Code	
			,intAccountId
			,intTaxCalculationType
			,intSort
			,intConcurrencyId
		FROM #tmpEarnings
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpEarnings')) 
	DROP TABLE #tmpEarnings
END

GO