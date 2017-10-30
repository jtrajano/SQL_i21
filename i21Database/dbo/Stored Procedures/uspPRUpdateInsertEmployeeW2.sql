CREATE PROCEDURE [dbo].[uspPRUpdateInsertEmployeeW2]
	@intYear INT
	,@intEntityEmployeeId INT
	,@intEmployeeW2Id INT = NULL OUTPUT
AS

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
		,intConcurrencyId)
	SELECT
		@intEntityEmployeeId
		,@intYear
		,strControlNumber = ''
		,dblAdjustedGross = ISNULL(PCHK.dblGrossSum, 0)
		,dblFIT = ISNULL(FIT.dblTotal, 0)
		,dblTaxableSS = CASE WHEN (ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0) END
		,dblTaxableMed = CASE WHEN (ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0) END
		,dblTaxableSSTips = CASE WHEN (ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0) END
		,dblSSTax = ISNULL(SSTAX.dblTotal, 0)
		,dblMedTax = ISNULL(MEDTAX.dblTotal, 0)
		,dblAllocatedTips = 0
		,dblDependentCare = 0
		,dblNonqualifiedPlans = 0
		,strOther = ''
		,strBox12a = ''
		,strBox12b = ''
		,strBox12c = ''
		,strBox12d = ''
		,dblBox12a = 0
		,dblBox12b = 0
		,dblBox12c = 0
		,dblBox12d = 0
		,strState = ISNULL(STATETAX.strState, '')
		,strLocality = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(LOCALTAX.strLocal, '') ELSE '' END
		,strStateTaxID = ISNULL((SELECT TOP 1 strStateTaxID FROM tblSMCompanySetup), '')
		,dblTaxableState = ISNULL(TXBLSTATE.dblTotal, 0)
		,dblStateTax = ISNULL(STATETAX.dblTotal, 0)
		,dblTaxableLocal = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(TXBLLOCAL.dblTotal, 0) ELSE 0 END
		,dblLocalTax = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(LOCALTAX.dblTotal, 0) ELSE 0 END
		,intConcurrencyId = 1
	FROM 
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
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strDeductFrom = 'Gross Pay' AND ysnVoid = 0) PRETAX OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strCalculationType = 'USA Federal Tax' AND ysnVoid = 0) FIT OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strCalculationType = 'USA Social Security' AND ysnVoid = 0) SSTAX OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strCalculationType = 'USA Medicare' AND ysnVoid = 0) MEDTAX OUTER APPLY
		(SELECT strState = st.strCode, dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
			AND strPaidBy = 'Employee' AND strCalculationType = 'USA State' AND ysnVoid = 0 GROUP BY st.strCode) STATETAX OUTER APPLY
		(SELECT strState = st.strCode, strLocal = lc.strLocalName, dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
				LEFT JOIN tblPRTypeTaxLocal lc ON tax.intTypeTaxLocalId = lc.intTypeTaxLocalId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
			AND strPaidBy = 'Employee' AND strCalculationType = 'USA Local' AND ysnVoid = 0 GROUP BY st.strCode, lc.strLocalName) LOCALTAX OUTER APPLY
		(SELECT intEmployees = COUNT(DISTINCT intEntityEmployeeId),
				dblGrossSum = SUM(dblGross) 
		FROM tblPRPaycheck 
		WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnPosted = 1 AND ysnVoid = 0) PCHK

		/* Get created Employee W-2 941 Id */
		SET @intEmployeeW2Id = SCOPE_IDENTITY()
END
ELSE
BEGIN
	/* If it exists, update the values */
	UPDATE tblPREmployeeW2
	SET dblAdjustedGross = ISNULL(PCHK.dblGrossSum, 0)
		,dblFIT = ISNULL(FIT.dblTotal, 0)
		,dblTaxableSS = CASE WHEN (ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSS.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0) END
		,dblTaxableMed = CASE WHEN (ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLMED.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0) END
		,dblTaxableSSTips = CASE WHEN (ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0)) <= 0 THEN 0 ELSE ISNULL(TXBLSSTIPS.dblTotal, 0) - ISNULL(PRETAX.dblTotal, 0) END
		,dblSSTax = ISNULL(SSTAX.dblTotal, 0)
		,dblMedTax = ISNULL(MEDTAX.dblTotal, 0)
		,strState = ISNULL(STATETAX.strState, '')
		,strLocality = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(LOCALTAX.strLocal, '') ELSE '' END
		,strStateTaxID = ISNULL((SELECT TOP 1 strStateTaxID FROM tblSMCompanySetup), '')
		,dblTaxableState = ISNULL(TXBLSTATE.dblTotal, 0)
		,dblStateTax = ISNULL(STATETAX.dblTotal, 0)
		,dblTaxableLocal = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(TXBLLOCAL.dblTotal, 0) ELSE 0 END
		,dblLocalTax = CASE WHEN (ISNULL(LOCALTAX.strState, '') = ISNULL(STATETAX.strState, '')) THEN ISNULL(LOCALTAX.dblTotal, 0) ELSE 0 END
		,intConcurrencyId = 1
	FROM 
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
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckDeduction 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strDeductFrom = 'Gross Pay' AND ysnVoid = 0) PRETAX OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax 
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strCalculationType = 'USA Federal Tax' AND ysnVoid = 0) FIT OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strCalculationType = 'USA Social Security' AND ysnVoid = 0) SSTAX OUTER APPLY
		(SELECT dblTotal = SUM(dblTotal) FROM vyuPRPaycheckTax
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND strPaidBy = 'Employee' AND strCalculationType = 'USA Medicare' AND ysnVoid = 0) MEDTAX OUTER APPLY
		(SELECT strState = st.strCode, dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
			AND strPaidBy = 'Employee' AND strCalculationType = 'USA State' AND ysnVoid = 0 GROUP BY st.strCode) STATETAX OUTER APPLY
		(SELECT strState = st.strCode, strLocal = lc.strLocalName, dblTotal = SUM(tax.dblTotal) 
			FROM vyuPRPaycheckTax tax INNER JOIN tblPRTypeTaxState st ON tax.intTypeTaxStateId = st.intTypeTaxStateId
				LEFT JOIN tblPRTypeTaxLocal lc ON tax.intTypeTaxLocalId = lc.intTypeTaxLocalId
			WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 
			AND strPaidBy = 'Employee' AND strCalculationType = 'USA Local' AND ysnVoid = 0 GROUP BY st.strCode, lc.strLocalName) LOCALTAX OUTER APPLY
		(SELECT intEmployees = COUNT(DISTINCT intEntityEmployeeId),
				dblGrossSum = SUM(dblGross) 
		FROM tblPRPaycheck 
		WHERE YEAR(dtmPayDate) = @intYear AND intEntityEmployeeId = @intEntityEmployeeId AND ysnPosted = 1 AND ysnVoid = 0) PCHK
	WHERE intYear = @intYear AND intEntityEmployeeId = @intEntityEmployeeId 

	/* Get the updated Employee W-2 941 Id */
	SELECT TOP 1 @intEmployeeW2Id = intEmployeeW2Id FROM tblPREmployeeW2 WHERE intYear = @intYear AND intEntityEmployeeId = @intEntityEmployeeId
END

GO