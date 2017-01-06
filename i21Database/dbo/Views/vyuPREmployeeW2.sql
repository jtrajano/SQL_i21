CREATE VIEW [dbo].[vyuPREmployeeW2]
AS
SELECT
	[W2].intEmployeeW2Id
	,[W2].intYear
	,[W2].intEntityEmployeeId
	,[EM].strEntityNo 
	,[EMP].strSocialSecurity	/* box a */
	,[COM].strEin				/* box b */
	,[COM].strCompanyName		/* box c */
	,strCompanyAddress =		/* box c_1 */
						CASE WHEN ISNULL (dbo.fnConvertToFullAddress ([COM].strAddress, [COM].strCity, [COM].strState, [COM].strZip), '') <> '' 
						THEN dbo.fnConvertToFullAddress ([COM].strAddress, [COM].strCity, [COM].strState, [COM].strZip) ELSE NULL END
	,[W2].strControlNumber		/* box d */
	,strFirstNameInitial =		/* box e */
						[EMP].strFirstName + ' ' + [EMP].strMiddleName 
	,[EMP].strLastName			/* box e_1 */
	,[EMP].strNameSuffix		/* box e_2 */
	,strEmployeeAddress =		/* box f */
						CASE WHEN ISNULL (dbo.fnConvertToFullAddress ([EML].strAddress, [EML].strCity, [EML].strState, [EML].strZipCode), '') <> '' 
						THEN dbo.fnConvertToFullAddress ([EML].strAddress, [EML].strCity, [EML].strState, [EML].strZipCode) ELSE NULL END
	,[W2].dblAdjustedGross		/* box 1 */
	,[W2].dblFIT				/* box 2 */
	,[W2].dblTaxableSS			/* box 3 */
	,[W2].dblSSTax				/* box 4 */
	,[W2].dblTaxableMed 		/* box 5 */
	,[W2].dblMedTax				/* box 6 */
	,[W2].dblTaxableSSTips 		/* box 7 */
	,[W2].dblAllocatedTips		/* box 8 */
	,[W2].dblDependentCare 		/* box 10 */
	,[W2].dblNonqualifiedPlans 	/* box 11 */
	,[W2].strBox12a			 	/* box 12a-code */
	,[W2].dblBox12a				/* box 12a */
	,[W2].strBox12b			 	/* box 12b-code */
	,[W2].dblBox12b				/* box 12b */
	,[W2].strBox12c			 	/* box 12c-code */
	,[W2].dblBox12c				/* box 12c */
	,[W2].strBox12d			 	/* box 12d-code */
	,[W2].dblBox12d				/* box 12d */
	,[EMP].ysnStatutoryEmployee /* box 13_1 */
	,[EMP].ysnRetirementPlan	/* box 13_2 */
	,[EMP].ysnThirdPartySickPay /* box 13_3 */
	,[W2].strOther				/* box 14 */
	,[W2].strState				/* box 15 */
	,[W2].strStateTaxID			/* box 15_1 */
	,[W2].dblTaxableState		/* box 16 */
	,[W2].dblStateTax			/* box 17 */
	,[W2].dblTaxableLocal		/* box 18 */
	,[W2].dblLocalTax			/* box 19 */
	,[W2].strLocality			/* box 20 */
FROM
	tblPREmployeeW2 [W2]
	INNER JOIN tblPREmployee [EMP] ON [W2].intEntityEmployeeId = [EMP].intEntityEmployeeId
	INNER JOIN tblEMEntity [EM] ON [EM].intEntityId = [EMP].intEntityEmployeeId
	INNER JOIN tblEMEntityLocation [EML] ON [EM].intEntityId = [EML].intEntityId AND [EML].ysnDefaultLocation = 1
	OUTER APPLY (SELECT TOP 1 * FROM tblSMCompanySetup) [COM]
GO