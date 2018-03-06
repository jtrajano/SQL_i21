IF EXISTS (select top 1 1 from sys.procedures where name = 'uspPRImportOriginTaxTypes')
DROP PROCEDURE [dbo].uspPRImportOriginTaxTypes
GO

EXEC('
	CREATE PROCEDURE [dbo].[uspPRImportOriginTaxTypes]
		@ysnDoImport BIT = 0,
		@intRecordCount INT = 0 OUTPUT
	AS
	BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

		SELECT DISTINCT
			strTax = prtax_code COLLATE Latin1_General_CI_AS
			,strDescription = prtax_desc COLLATE Latin1_General_CI_AS
			,strCalculationType = CASE (prtax_tax_type)
									WHEN 1 THEN ''USA Social Security''
									WHEN 2 THEN ''USA Medicare''
									WHEN 3 THEN ''USA FUTA''
									WHEN 4 THEN ''USA SUTA''
									WHEN 5 THEN ''USA Federal Tax''
									WHEN 6 THEN ''USA State''
									WHEN 7 THEN ''USA Local''
									WHEN 8 THEN ''USA Local''
									WHEN 9 THEN ''USA State''
									ELSE ''Fixed Amount'' END
			,dblAmount = 0
			,ysnRoundToDollar = 0
			,dblLimit = CASE WHEN (prtax_tax_type IN (3, 4)) THEN prtax_wage_cutoff ELSE 0 END
			,strPaidBy = CASE WHEN (prtax_paid_by = ''C'') THEN ''Company'' ELSE ''Employee'' END
			,intTypeTaxStateId = NULL
			,intTypeTaxLocalId = NULL
			,intAccountId = dbo.fnGetGLAccountIdFromOriginToi21(prtax_gl_bs)
			,intExpenseAccountId = dbo.fnGetGLAccountIdFromOriginToi21(prtax_gl_exp)
			,intSupplementalCalc = 1
			,strCheckLiteral = ISNULL(prtax_literal, '''') COLLATE Latin1_General_CI_AS
			,intVendorId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = prtax_vendor COLLATE Latin1_General_CI_AS)
			,intSort = DENSE_RANK() OVER(PARTITION BY prtax_year ORDER BY A4GLIdentity)
			,intConcurrencyId = 1
		INTO #tmpTaxes
		FROM
			prtaxmst
		WHERE
			prtax_code COLLATE Latin1_General_CI_AS NOT IN (SELECT strTax FROM tblPRTypeTax)
			AND prtax_year = (SELECT MAX(prtax_year) FROM prtaxmst)

		SELECT @intRecordCount = COUNT(1) FROM #tmpTaxes

		IF (@ysnDoImport = 1)
		BEGIN
			INSERT INTO tblPRTypeTax
				(strTax
				,strDescription
				,strCalculationType
				,dblAmount
				,ysnRoundToDollar
				,dblLimit
				,strPaidBy
				,intTypeTaxStateId
				,intTypeTaxLocalId
				,intAccountId
				,intExpenseAccountId
				,intSupplementalCalc
				,strCheckLiteral
				,intVendorId
				,intSort
				,intConcurrencyId)
			SELECT
				strTax
				,strDescription
				,strCalculationType
				,dblAmount
				,ysnRoundToDollar
				,dblLimit
				,strPaidBy
				,intTypeTaxStateId
				,intTypeTaxLocalId
				,intAccountId
				,intExpenseAccountId
				,intSupplementalCalc
				,strCheckLiteral
				,intVendorId
				,intSort
				,intConcurrencyId
			FROM #tmpTaxes
		END
	END
')

GO