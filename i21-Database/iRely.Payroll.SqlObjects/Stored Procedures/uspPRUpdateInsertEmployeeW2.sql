CREATE PROCEDURE [dbo].[uspPRUpdateInsertEmployeeW2]
	@intYear INT
	,@intEntityEmployeeId INT
	,@intEmployeeW2Id INT = NULL OUTPUT
AS

/* Get Box 12 Data */
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBox12Data')) DROP TABLE #tmpBox12Data
SELECT
	intRank = DENSE_RANK() OVER (PARTITION BY PD.intEntityEmployeeId, YEAR(PD.dtmPayDate) ORDER BY TD.strW2Code DESC)
	,intEntityEmployeeId = PD.intEntityEmployeeId
	,intYear = YEAR(PD.dtmPayDate)
	,strW2Code = TD.strW2Code
	,dblTotal = SUM(PD.dblTotal)
INTO #tmpBox12Data
FROM vyuPRPaycheckDeduction PD INNER JOIN tblPRTypeDeduction TD 
	ON PD.intTypeDeductionId = TD.intTypeDeductionId AND PD.strPaidBy = 'Employee' AND TD.strW2Code IS NOT NULL
WHERE intEntityEmployeeId = @intEntityEmployeeId AND YEAR(PD.dtmPayDate) = @intYear
GROUP BY PD.intEntityEmployeeId, YEAR(PD.dtmPayDate), TD.strW2Code

/* Check if Employee W-2 for the Year exists */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblPREmployeeW2 WHERE intYear = @intYear AND intEntityEmployeeId = @intEntityEmployeeId)
BEGIN

	INSERT INTO tblPREmployeeW2(
		intEntityEmployeeId
		,intYear
		,strControlNumber
		,dblAdjustedGross
		,dblFIT
		,dblTaxableSS
		,dblTaxableMed
		,dblTaxableSSTips
		,dblSSTax
		,dblMedTax
		,dblAllocatedTips
		,dblDependentCare
		,dblNonqualifiedPlans
		,strOther
		,strBox12a
		,strBox12b
		,strBox12c
		,strBox12d
		,dblBox12a
		,dblBox12b
		,dblBox12c
		,dblBox12d
		,strState
		,strLocality
		,strStateTaxID
		,dblTaxableState
		,dblStateTax
		,dblTaxableLocal
		,dblLocalTax
		,strState2
		,strLocality2
		,strStateTaxID2
		,dblTaxableState2
		,dblStateTax2
		,dblTaxableLocal2
		,dblLocalTax2
		,intConcurrencyId)
	SELECT
		@intEntityEmployeeId
		,@intYear
		,strControlNumber = ''
		,dblAdjustedGross = CASE WHEN (ISNULL(TXBLFIT.dblTotal, 0) - ISNULL(PRTXFIT.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLFIT.dblTotal, 0) - ISNULL(PRTXFIT.dblTotal, 0) END
		,dblFIT = ISNULL(FIT.dblTotal, 0)
		,dblTaxableSS = CASE WHEN (ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0) END
		,dblTaxableMed = CASE WHEN (ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRTXMED.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRTXMED.dblTotal, 0) END
		,dblTaxableSSTips = CASE WHEN (ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0) END
		,dblSSTax = ISNULL(SSTAX.dblTotal, 0)
		,dblMedTax = ISNULL(MEDTAX.dblTotal, 0)
		,dblAllocatedTips = 0
		,dblDependentCare = 0
		,dblNonqualifiedPlans = 0
		,strOther = ''
		,strBox12a = (SELECT ISNULL(strW2Code, '') FROM #tmpBox12Data WHERE intRank = 1)
		,strBox12b = (SELECT ISNULL(strW2Code, '') FROM #tmpBox12Data WHERE intRank = 2)
		,strBox12c = (SELECT ISNULL(strW2Code, '') FROM #tmpBox12Data WHERE intRank = 3)
		,strBox12d = (SELECT ISNULL(strW2Code, '') FROM #tmpBox12Data WHERE intRank = 4)
		,dblBox12a = (SELECT ISNULL(dblTotal, 0) FROM #tmpBox12Data WHERE intRank = 1)
		,dblBox12b = (SELECT ISNULL(dblTotal, 0) FROM #tmpBox12Data WHERE intRank = 2)
		,dblBox12c = (SELECT ISNULL(dblTotal, 0) FROM #tmpBox12Data WHERE intRank = 3)
		,dblBox12d = (SELECT ISNULL(dblTotal, 0) FROM #tmpBox12Data WHERE intRank = 4)
		,strState = ISNULL(STATETAX.strState, '')
		,strLocality = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(LOCALTAX.strLocal, '') 
							WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(SCHOOLTAX.strLocal, '')
							WHEN (ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(MUNITAX.strLocal, '') 
							ELSE '' END
		,strStateTaxID = CASE WHEN (ISNULL(LOCALTAX.strEmployerStateTaxID, '') <> '') THEN
								ISNULL(LOCALTAX.strEmployerStateTaxID, '')
							WHEN (ISNULL(STATETAX.strEmployerStateTaxID, '') <> '') THEN
								ISNULL(STATETAX.strEmployerStateTaxID, '')
							ELSE
								ISNULL((SELECT TOP 1 strStateTaxID FROM tblSMCompanySetup), '')
							END
		,dblTaxableState = CASE WHEN (ISNULL(TXBLSTATE.dblTotal, 0) - ISNULL(PRTXSTATE.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSTATE.dblTotal, 0) - ISNULL(PRTXSTATE.dblTotal, 0) END
		,dblStateTax = ISNULL(STATETAX.dblTotal, 0)
		,dblTaxableLocal = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN 
								CASE WHEN (ISNULL(TXBLLOCAL.dblTotal, 0) - ISNULL(PRTXLOCAL.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLLOCAL.dblTotal, 0) - ISNULL(PRTXLOCAL.dblTotal, 0) END
							WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN 
								CASE WHEN (ISNULL(TXBLSCHOOL.dblTotal, 0) - ISNULL(PRTXSCHOOL.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSCHOOL.dblTotal, 0) - ISNULL(PRTXSCHOOL.dblTotal, 0) END
							WHEN (ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN 
								CASE WHEN (ISNULL(TXBLMUNI.dblTotal, 0) - ISNULL(PRTXMUNI.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLMUNI.dblTotal, 0) - ISNULL(PRTXMUNI.dblTotal, 0) END
							ELSE 0 END
		,dblLocalTax = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(LOCALTAX.dblTotal, 0) 
							WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(SCHOOLTAX.dblTotal, 0)
							WHEN (ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(MUNITAX.dblTotal, 0) 
							ELSE 0 END
		,strState2 = ''
		,strLocality2 = CASE WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '') 
								AND ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(MUNITAX.strLocal, '')
							ELSE '' END
		,strStateTaxID2 = ''
		,dblTaxableState2 = 0
		,dblStateTax2 = 0
		,dblTaxableLocal2 = CASE WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '') 
								 AND ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN 
								CASE WHEN (ISNULL(TXBLMUNI.dblTotal, 0) - ISNULL(PRTXMUNI.dblTotal, 0)) <= 0 THEN 0 
								ELSE ISNULL(TXBLMUNI.dblTotal, 0) - ISNULL(PRTXMUNI.dblTotal, 0) END
							ELSE 0 END
		,dblLocalTax2 = CASE WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '') 
								 AND ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(MUNITAX.dblTotal, 0)
							ELSE 0 END
		,intConcurrencyId = 1
	FROM 
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnFITTaxable = 1 AND ysnVoid = 0) TXBLFIT OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strCalculationType <> 'Tip' AND ysnSSTaxable = 1 AND ysnVoid = 0) TXBLSS OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strCalculationType = 'Tip' AND ysnSSTaxable = 1 AND ysnVoid = 0) TXBLSSTIPS OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnMedTaxable = 1 AND ysnVoid = 0) TXBLMED OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnStateTaxable = 1 AND ysnVoid = 0) TXBLSTATE OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnLocalTaxable = 1 AND ysnVoid = 0) TXBLLOCAL OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnSchoolDistrictTaxable = 1 AND ysnVoid = 0) TXBLSCHOOL OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnMunicipalityTaxable = 1 AND ysnVoid = 0) TXBLMUNI OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnFITTaxable = 1 AND ysnVoid = 0) PRTXFIT OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnSSTaxable = 1 AND ysnVoid = 0) PRTXSS OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnMedTaxable = 1 AND ysnVoid = 0) PRTXMED OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnStateTaxable = 1 AND ysnVoid = 0) PRTXSTATE OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnLocalTaxable = 1 AND ysnVoid = 0) PRTXLOCAL OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnSchoolDistrictTaxable = 1 AND ysnVoid = 0) PRTXSCHOOL OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnMunicipalityTaxable = 1 AND ysnVoid = 0) PRTXMUNI OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strCalculationType = 'USA Federal Tax' AND ysnVoid = 0) FIT OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strCalculationType = 'USA Social Security' AND ysnVoid = 0) SSTAX OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strCalculationType = 'USA Medicare' AND ysnVoid = 0) MEDTAX OUTER APPLY
		(SELECT intRank = DENSE_RANK() OVER (ORDER BY st.strCode), strState = st.strCode, strEmployerStateTaxID, dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax 
				INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
				INNER JOIN tblPRTypeTax tt ON tax.intTypeTaxId = tt.intTypeTaxId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
				AND tax.strPaidBy = 'Employee' AND tax.strCalculationType = 'USA State' AND ysnVoid = 0 
				AND (tax.intTypeTaxStateId NOT IN (41, 45)
					OR ((tax.intTypeTaxStateId = 41 AND tax.strVal1 = 'None' AND tax.strVal2 = 'None')
					OR (tax.intTypeTaxStateId = 45 AND tax.strVal2 = 'None (None)' AND tax.strVal3 = 'None (None)'))) 
			GROUP BY st.strCode, strEmployerStateTaxID) STATETAX OUTER APPLY
		(SELECT intRank = DENSE_RANK() OVER (ORDER BY lc.strLocalName), strState = st.strCode, strLocal = lc.strLocalName, strEmployerStateTaxID, dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
				INNER JOIN tblPRTypeTax tt ON tax.intTypeTaxId = tt.intTypeTaxId
				LEFT JOIN tblPRTypeTaxLocal lc ON tax.intTypeTaxLocalId = lc.intTypeTaxLocalId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
			AND tax.strPaidBy = 'Employee' AND tax.strCalculationType = 'USA Local' AND ysnVoid = 0 GROUP BY st.strCode, strEmployerStateTaxID, lc.strLocalName) LOCALTAX OUTER APPLY
		(SELECT strState = st.strCode
				,strLocal = CASE WHEN (tax.intTypeTaxStateId = 41) THEN tax.strVal1
								 WHEN (tax.intTypeTaxStateId = 45) THEN 
									ISNULL((SELECT TOP 1 
												CASE WHEN (tax.strVal3 = 'None (None)') 
												THEN SUBSTRING(strPSDCode, 1, 4)
												ELSE strPSDCode END
											FROM tblPRTypeTaxStatePSDCode 
											WHERE strSchoolDistrict = tax.strVal2 AND strMunicipality IN (tax.strVal3, 'None (None)'))
									, tax.strVal2)
								 ELSE '' END
				,strEmployerStateTaxID, 
				dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
				INNER JOIN tblPRTypeTax tt ON tax.intTypeTaxId = tt.intTypeTaxId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
			AND tax.strPaidBy = 'Employee' AND tax.strCalculationType = 'USA State' AND ysnVoid = 0 
			AND ((tax.intTypeTaxStateId = 41 AND tax.strVal1 <> 'None')
				OR (tax.intTypeTaxStateId = 45 AND tax.strVal2 <> 'None (None)'))
			GROUP BY st.strCode, tax.intTypeTaxStateId, strEmployerStateTaxID, tax.strVal1, tax.strVal2, tax.strVal3) SCHOOLTAX OUTER APPLY
		(SELECT strState = st.strCode
		,strLocal = CASE WHEN (tax.intTypeTaxStateId = 41) THEN tax.strVal2
						 WHEN (tax.intTypeTaxStateId = 45) THEN 
							ISNULL((SELECT TOP 1 strPSDCode
										FROM tblPRTypeTaxStatePSDCode 
										WHERE strMunicipality = tax.strVal3)
								,tax.strVal3)
						 ELSE '' END
		,strEmployerStateTaxID
		,dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
				INNER JOIN tblPRTypeTax tt ON tax.intTypeTaxId = tt.intTypeTaxId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
			AND tax.strPaidBy = 'Employee' AND tax.strCalculationType = 'USA State' AND ysnVoid = 0 
			AND ((tax.intTypeTaxStateId = 41 AND tax.strVal2 <> 'None')
				OR (tax.intTypeTaxStateId = 45 AND tax.strVal2 = 'None (None)' AND tax.strVal3 <> 'None (None)'))
			GROUP BY st.strCode, tax.intTypeTaxStateId, strEmployerStateTaxID, tax.strVal2, tax.strVal3) MUNITAX OUTER APPLY
		(SELECT intEmployees = COUNT(DISTINCT intEntityEmployeeId),
				dblGrossSum = SUM(dblGross)
		FROM tblPRPaycheck 
		WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnPosted = 1 AND ysnVoid = 0) PCHK

		/* Get created Employee W-2 941 Id */
		SET @intEmployeeW2Id = SCOPE_IDENTITY()

END
ELSE /* If it exists, update the values */
BEGIN
	UPDATE tblPREmployeeW2
	SET dblAdjustedGross = CASE WHEN (ISNULL(TXBLFIT.dblTotal, 0) - ISNULL(PRTXFIT.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLFIT.dblTotal, 0) - ISNULL(PRTXFIT.dblTotal, 0) END
		,dblFIT = ISNULL(FIT.dblTotal, 0)
		,dblTaxableSS = CASE WHEN (ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0) END
		,dblTaxableMed = CASE WHEN (ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRTXMED.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRTXMED.dblTotal, 0) END
		,dblTaxableSSTips = CASE WHEN (ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRTXSS.dblTotal, 0) END
		,dblSSTax = ISNULL(SSTAX.dblTotal, 0)
		,dblMedTax = ISNULL(MEDTAX.dblTotal, 0)
		,strBox12a = (SELECT ISNULL(strW2Code, '') FROM #tmpBox12Data WHERE intRank = 1)
		,strBox12b = (SELECT ISNULL(strW2Code, '') FROM #tmpBox12Data WHERE intRank = 2)
		,strBox12c = (SELECT ISNULL(strW2Code, '') FROM #tmpBox12Data WHERE intRank = 3)
		,strBox12d = (SELECT ISNULL(strW2Code, '') FROM #tmpBox12Data WHERE intRank = 4)
		,dblBox12a = (SELECT ISNULL(dblTotal, 0) FROM #tmpBox12Data WHERE intRank = 1)
		,dblBox12b = (SELECT ISNULL(dblTotal, 0) FROM #tmpBox12Data WHERE intRank = 2)
		,dblBox12c = (SELECT ISNULL(dblTotal, 0) FROM #tmpBox12Data WHERE intRank = 3)
		,dblBox12d = (SELECT ISNULL(dblTotal, 0) FROM #tmpBox12Data WHERE intRank = 4)
		,strState = ISNULL(STATETAX.strState, '')
		,strLocality = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(LOCALTAX.strLocal, '') 
							WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(SCHOOLTAX.strLocal, '')
							WHEN (ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(MUNITAX.strLocal, '') 
							ELSE '' END
		,strStateTaxID = CASE WHEN (ISNULL(LOCALTAX.strEmployerStateTaxID, '') <> '') THEN
								ISNULL(LOCALTAX.strEmployerStateTaxID, '')
							WHEN (ISNULL(STATETAX.strEmployerStateTaxID, '') <> '') THEN
								ISNULL(STATETAX.strEmployerStateTaxID, '')
							ELSE
								ISNULL((SELECT TOP 1 strStateTaxID FROM tblSMCompanySetup), '')
							END
		,dblTaxableState = CASE WHEN (ISNULL(TXBLSTATE.dblTotal, 0) - ISNULL(PRTXSTATE.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSTATE.dblTotal, 0) - ISNULL(PRTXSTATE.dblTotal, 0) END
		,dblStateTax = ISNULL(STATETAX.dblTotal, 0)
		,dblTaxableLocal = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN 
								CASE WHEN (ISNULL(TXBLLOCAL.dblTotal, 0) - ISNULL(PRTXLOCAL.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLLOCAL.dblTotal, 0) - ISNULL(PRTXLOCAL.dblTotal, 0) END
							WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN 
								CASE WHEN (ISNULL(TXBLSCHOOL.dblTotal, 0) - ISNULL(PRTXSCHOOL.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSCHOOL.dblTotal, 0) - ISNULL(PRTXSCHOOL.dblTotal, 0) END
							WHEN (ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN 
								CASE WHEN (ISNULL(TXBLMUNI.dblTotal, 0) - ISNULL(PRTXMUNI.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLMUNI.dblTotal, 0) - ISNULL(PRTXMUNI.dblTotal, 0) END
							ELSE 0 END
		,dblLocalTax = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(LOCALTAX.dblTotal, 0) 
							WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(SCHOOLTAX.dblTotal, 0)
							WHEN (ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(MUNITAX.dblTotal, 0) 
							ELSE 0 END
		,strState2 = ''
		,strLocality2 = CASE WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '') 
								AND ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(MUNITAX.strLocal, '')
							ELSE '' END
		,strStateTaxID2 = ''
		,dblTaxableState2 = 0
		,dblStateTax2 = 0
		,dblTaxableLocal2 = CASE WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '') 
								 AND ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN 
								CASE WHEN (ISNULL(TXBLMUNI.dblTotal, 0) - ISNULL(PRTXMUNI.dblTotal, 0)) <= 0 THEN 0 
								ELSE ISNULL(TXBLMUNI.dblTotal, 0) - ISNULL(PRTXMUNI.dblTotal, 0) END
							ELSE 0 END
		,dblLocalTax2 = CASE WHEN (ISNULL(SCHOOLTAX.strState, '') = ISNULL(STATETAX.strState, '') 
								 AND ISNULL(MUNITAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(MUNITAX.dblTotal, 0)
							ELSE 0 END
		,intConcurrencyId = 1
	FROM 
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnFITTaxable = 1 AND ysnVoid = 0) TXBLFIT OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strCalculationType <> 'Tip' AND ysnSSTaxable = 1 AND ysnVoid = 0) TXBLSS OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strCalculationType = 'Tip' AND ysnSSTaxable = 1 AND ysnVoid = 0) TXBLSSTIPS OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnMedTaxable = 1 AND ysnVoid = 0) TXBLMED OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnStateTaxable = 1 AND ysnVoid = 0) TXBLSTATE OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnLocalTaxable = 1 AND ysnVoid = 0) TXBLLOCAL OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnSchoolDistrictTaxable = 1 AND ysnVoid = 0) TXBLSCHOOL OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckEarning 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnMunicipalityTaxable = 1 AND ysnVoid = 0) TXBLMUNI OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnFITTaxable = 1 AND ysnVoid = 0) PRTXFIT OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnSSTaxable = 1 AND ysnVoid = 0) PRTXSS OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnMedTaxable = 1 AND ysnVoid = 0) PRTXMED OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnStateTaxable = 1 AND ysnVoid = 0) PRTXSTATE OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnLocalTaxable = 1 AND ysnVoid = 0) PRTXLOCAL OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnSchoolDistrictTaxable = 1 AND ysnVoid = 0) PRTXSCHOOL OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strDeductFrom = 'Gross Pay' AND ysnMunicipalityTaxable = 1 AND ysnVoid = 0) PRTXMUNI OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strCalculationType = 'USA Federal Tax' AND ysnVoid = 0) FIT OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strCalculationType = 'USA Social Security' AND ysnVoid = 0) SSTAX OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strCalculationType = 'USA Medicare' AND ysnVoid = 0) MEDTAX OUTER APPLY
		(SELECT intRank = DENSE_RANK() OVER (ORDER BY st.strCode), strState = st.strCode, strEmployerStateTaxID, dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax 
				INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
				INNER JOIN tblPRTypeTax tt ON tax.intTypeTaxId = tt.intTypeTaxId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
				AND tax.strPaidBy = 'Employee' AND tax.strCalculationType = 'USA State' AND ysnVoid = 0 
				AND (tax.intTypeTaxStateId NOT IN (41, 45)
					OR ((tax.intTypeTaxStateId = 41 AND tax.strVal1 = 'None' AND tax.strVal2 = 'None')
					OR (tax.intTypeTaxStateId = 45 AND tax.strVal2 = 'None (None)' AND tax.strVal3 = 'None (None)'))) 
			GROUP BY st.strCode, strEmployerStateTaxID) STATETAX OUTER APPLY
		(SELECT intRank = DENSE_RANK() OVER (ORDER BY lc.strLocalName), strState = st.strCode, strLocal = lc.strLocalName, strEmployerStateTaxID, dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
				INNER JOIN tblPRTypeTax tt ON tax.intTypeTaxId = tt.intTypeTaxId
				LEFT JOIN tblPRTypeTaxLocal lc ON tax.intTypeTaxLocalId = lc.intTypeTaxLocalId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
			AND tax.strPaidBy = 'Employee' AND tax.strCalculationType = 'USA Local' AND ysnVoid = 0 GROUP BY st.strCode, strEmployerStateTaxID, lc.strLocalName) LOCALTAX OUTER APPLY
		(SELECT strState = st.strCode
				,strLocal = CASE WHEN (tax.intTypeTaxStateId = 41) THEN tax.strVal1
								 WHEN (tax.intTypeTaxStateId = 45) THEN 
									ISNULL((SELECT TOP 1 
												CASE WHEN (tax.strVal3 = 'None (None)') 
												THEN SUBSTRING(strPSDCode, 1, 4)
												ELSE strPSDCode END
											FROM tblPRTypeTaxStatePSDCode 
											WHERE strSchoolDistrict = tax.strVal2 AND strMunicipality IN (tax.strVal3, 'None (None)'))
									, tax.strVal2)
								 ELSE '' END
				,strEmployerStateTaxID, 
				dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
				INNER JOIN tblPRTypeTax tt ON tax.intTypeTaxId = tt.intTypeTaxId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
			AND tax.strPaidBy = 'Employee' AND tax.strCalculationType = 'USA State' AND ysnVoid = 0 
			AND ((tax.intTypeTaxStateId = 41 AND tax.strVal1 <> 'None')
				OR (tax.intTypeTaxStateId = 45 AND tax.strVal2 <> 'None (None)'))
			GROUP BY st.strCode, tax.intTypeTaxStateId, strEmployerStateTaxID, tax.strVal1, tax.strVal2, tax.strVal3) SCHOOLTAX OUTER APPLY
		(SELECT strState = st.strCode
		,strLocal = CASE WHEN (tax.intTypeTaxStateId = 41) THEN tax.strVal2
						 WHEN (tax.intTypeTaxStateId = 45) THEN 
							ISNULL((SELECT TOP 1 strPSDCode
										FROM tblPRTypeTaxStatePSDCode 
										WHERE strMunicipality = tax.strVal3)
								,tax.strVal3)
						 ELSE '' END
		,strEmployerStateTaxID
		,dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
				INNER JOIN tblPRTypeTax tt ON tax.intTypeTaxId = tt.intTypeTaxId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
			AND tax.strPaidBy = 'Employee' AND tax.strCalculationType = 'USA State' AND ysnVoid = 0 
			AND ((tax.intTypeTaxStateId = 41 AND tax.strVal2 <> 'None')
				OR (tax.intTypeTaxStateId = 45 AND tax.strVal2 = 'None (None)' AND tax.strVal3 <> 'None (None)'))
			GROUP BY st.strCode, tax.intTypeTaxStateId, strEmployerStateTaxID, tax.strVal2, tax.strVal3) MUNITAX OUTER APPLY
		(SELECT intEmployees = COUNT(DISTINCT intEntityEmployeeId),
				dblGrossSum = SUM(dblGross) 
		FROM tblPRPaycheck 
		WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnPosted = 1 AND ysnVoid = 0) PCHK
	WHERE intYear = @intYear AND intEntityEmployeeId = @intEntityEmployeeId

	/* Get the updated Employee W-2 941 Id */
	SELECT TOP 1 @intEmployeeW2Id = intEmployeeW2Id FROM tblPREmployeeW2 WHERE intYear = @intYear AND intEntityEmployeeId = @intEntityEmployeeId

END

/* Clean-up Codes */
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBox12Data')) DROP TABLE #tmpBox12Data

GO