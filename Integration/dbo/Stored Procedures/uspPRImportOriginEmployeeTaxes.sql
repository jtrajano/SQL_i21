IF EXISTS (select top 1 1 from sys.procedures where name = 'uspPRImportOriginEmployeeTaxes')
DROP PROCEDURE [dbo].uspPRImportOriginEmployeeTaxes
GO

EXEC('
	CREATE PROCEDURE [dbo].[uspPRImportOriginEmployeeTaxes]
		@ysnDoImport BIT = 0,
		@intRecordCount INT = 0 OUTPUT
	AS
	BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

		SELECT DISTINCT
			intEntityEmployeeId = iEMP.intEntityEmployeeId
			,intTypeTaxId = iTAX.intTypeTaxId
			,strCalculationType = iTAX.strCalculationType
			,strFilingStatus = CASE (oEMP.premp_tax_ms)
								WHEN ''M'' THEN ''Married''
								WHEN ''S'' THEN ''Single''
								ELSE iEMP.strMaritalStatus END
			,intTypeTaxStateId = iTAX.intTypeTaxStateId
			,intTypeTaxLocalId = iTAX.intTypeTaxLocalId
			,intSupplementalCalc = 1
			,dblAmount = 0
			,dblExtraWithholding = CASE (CAST(oEMT.premt_tax_type AS VARCHAR(2)) + oEMT.premt_code)
										WHEN premp_tax_id_1 THEN premp_tax_addl_pct_amt_1
										WHEN premp_tax_id_2 THEN premp_tax_addl_pct_amt_2
										WHEN premp_tax_id_3 THEN premp_tax_addl_pct_amt_3
										WHEN premp_tax_id_4 THEN premp_tax_addl_pct_amt_4
										WHEN premp_tax_id_5 THEN premp_tax_addl_pct_amt_5
										WHEN premp_tax_id_6 THEN premp_tax_addl_pct_amt_6
										WHEN premp_tax_id_7 THEN premp_tax_addl_pct_amt_7
										WHEN premp_tax_id_8 THEN premp_tax_addl_pct_amt_8
										WHEN premp_tax_id_9 THEN premp_tax_addl_pct_amt_9
										WHEN premp_tax_id_10 THEN premp_tax_addl_pct_amt_10
										WHEN premp_tax_id_11 THEN premp_tax_addl_pct_amt_11
										WHEN premp_tax_id_12 THEN premp_tax_addl_pct_amt_12
										WHEN premp_tax_id_13 THEN premp_tax_addl_pct_amt_13
										WHEN premp_tax_id_14 THEN premp_tax_addl_pct_amt_14
										WHEN premp_tax_id_15 THEN premp_tax_addl_pct_amt_15
										WHEN premp_tax_id_16 THEN premp_tax_addl_pct_amt_16
									ELSE 0 END
			,dblLimit = CASE WHEN (oTAX.prtax_tax_type IN (3, 4)) THEN prtax_wage_cutoff ELSE ISNULL(iTAX.dblLimit, 0) END
			,intAccountId = dbo.fnGetGLAccountIdFromOriginToi21(oTAX.prtax_gl_bs)
			,intExpenseAccountId = dbo.fnGetGLAccountIdFromOriginToi21(oTAX.prtax_gl_exp)
			,intAllowance = CASE (CAST(oEMT.premt_tax_type AS VARCHAR(2)) + oEMT.premt_code)
									WHEN premp_tax_id_1 THEN premp_tax_exempts_1
									WHEN premp_tax_id_2 THEN premp_tax_exempts_2
									WHEN premp_tax_id_3 THEN premp_tax_exempts_3
									WHEN premp_tax_id_4 THEN premp_tax_exempts_4
									WHEN premp_tax_id_5 THEN premp_tax_exempts_5
									WHEN premp_tax_id_6 THEN premp_tax_exempts_6
									WHEN premp_tax_id_7 THEN premp_tax_exempts_7
									WHEN premp_tax_id_8 THEN premp_tax_exempts_8
									WHEN premp_tax_id_9 THEN premp_tax_exempts_9
									WHEN premp_tax_id_10 THEN premp_tax_exempts_10
									WHEN premp_tax_id_11 THEN premp_tax_exempts_11
									WHEN premp_tax_id_12 THEN premp_tax_exempts_12
									WHEN premp_tax_id_13 THEN premp_tax_exempts_13
									WHEN premp_tax_id_14 THEN premp_tax_exempts_14
									WHEN premp_tax_id_15 THEN premp_tax_exempts_15
									WHEN premp_tax_id_16 THEN premp_tax_exempts_16
								ELSE 0 END
			,strPaidBy = iTAX.strPaidBy
			,strVal1 = NULL
			,strVal2 = NULL
			,strVal3 = NULL
			,strVal4 = NULL
			,strVal5 = NULL
			,strVal6 = NULL
			,ysnDefault = CASE (CAST(oEMT.premt_tax_type AS VARCHAR(2)) + oEMT.premt_code)
									WHEN premp_tax_id_1 THEN CASE premp_tax_active_yn_1 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_2 THEN CASE premp_tax_active_yn_2 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_3 THEN CASE premp_tax_active_yn_3 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_4 THEN CASE premp_tax_active_yn_4 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_5 THEN CASE premp_tax_active_yn_5 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_6 THEN CASE premp_tax_active_yn_6 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_7 THEN CASE premp_tax_active_yn_7 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_8 THEN CASE premp_tax_active_yn_8 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_9 THEN CASE premp_tax_active_yn_9 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_10 THEN CASE premp_tax_active_yn_10 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_11 THEN CASE premp_tax_active_yn_11 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_12 THEN CASE premp_tax_active_yn_12 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_13 THEN CASE premp_tax_active_yn_13 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_14 THEN CASE premp_tax_active_yn_14 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_15 THEN CASE premp_tax_active_yn_15 WHEN ''Y'' THEN 1 ELSE 0 END
									WHEN premp_tax_id_16 THEN CASE premp_tax_active_yn_16 WHEN ''Y'' THEN 1 ELSE 0 END
								ELSE 0 END
			,intSort = iTAX.intSort
			,intConcurrencyId = 1
		INTO
			#tmpEmployeeTaxes
		FROM
			(select premt_emp, premt_code, premt_tax_type from premtmst
				where premt_year = (select max(premt_year) from premtmst)) oEMT
			INNER JOIN prempmst oEMP
				ON oEMP.premp_emp = oEMT.premt_emp
			INNER JOIN (select distinct prtax_tax_type, prtax_code, prtax_gl_bs, 
							prtax_gl_exp, prtax_wage_cutoff from prtaxmst
						where prtax_year = (select max(prtax_year) from prtaxmst)) oTAX
				ON oEMT.premt_code = oTAX.prtax_code
			INNER JOIN (select intEntityEmployeeId = intEntityId, strEmployeeId, strMaritalStatus from tblPREmployee) iEMP
				ON iEMP.strEmployeeId = oEMT.premt_emp COLLATE Latin1_General_CI_AS
			INNER JOIN tblPRTypeTax iTAX
				ON iTAX.strTax = premt_code COLLATE Latin1_General_CI_AS
		WHERE NOT EXISTS (
				SELECT 1 FROM tblPREmployeeTax 
				WHERE intEntityEmployeeId = iEMP.intEntityEmployeeId 
				AND intTypeTaxId = iTAX.intTypeTaxId)

		SELECT @intRecordCount = COUNT(1) FROM #tmpEmployeeTaxes

		IF (@ysnDoImport = 1)
		BEGIN
			INSERT INTO tblPREmployeeTax
				(intEntityEmployeeId
				,intTypeTaxId
				,strCalculationType
				,strFilingStatus
				,intTypeTaxStateId
				,intTypeTaxLocalId
				,intSupplementalCalc
				,dblAmount
				,dblExtraWithholding
				,dblLimit
				,intAccountId
				,intExpenseAccountId
				,intAllowance
				,strPaidBy
				,strVal1
				,strVal2
				,strVal3
				,strVal4
				,strVal5
				,strVal6
				,ysnDefault
				,intSort
				,intConcurrencyId)
			SELECT
				intEntityEmployeeId
				,intTypeTaxId
				,strCalculationType
				,strFilingStatus
				,intTypeTaxStateId
				,intTypeTaxLocalId
				,intSupplementalCalc
				,dblAmount
				,dblExtraWithholding
				,dblLimit
				,intAccountId
				,intExpenseAccountId
				,intAllowance
				,strPaidBy
				,strVal1
				,strVal2
				,strVal3
				,strVal4
				,strVal5
				,strVal6
				,ysnDefault
				,intSort
				,intConcurrencyId
			FROM #tmpEmployeeTaxes
		END
	END
')

GO