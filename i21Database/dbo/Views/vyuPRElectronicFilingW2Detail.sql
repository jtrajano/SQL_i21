CREATE VIEW [dbo].[vyuPRElectronicFilingW2Detail]
AS
SELECT
	W2.intEmployeeW2Id
	,W2.intYear
	,W2.intEntityEmployeeId
	,strSSN = LEFT(dbo.fnAPRemoveSpecialChars(ISNULL(EMP.strSocialSecurity, '')), 9)
	,strFirstName = LEFT(ISNULL(EMP.strFirstName, ''), 15)
	,strMiddleName = LEFT(ISNULL(EMP.strMiddleName, ''), 15)
	,strLastName = LEFT(ISNULL(EMP.strLastName, ''), 20)
	,strSuffix = LEFT(ISNULL(EMP.strNameSuffix, ''), 4)
	,strEmployeeAddress = LEFT(REPLACE(REPLACE(ISNULL(ENL.strAddress, ''), CHAR(13), ''), CHAR(10), ''), 22)
	,strEmployeeDelivery = LEFT(REPLACE(REPLACE(ISNULL(ENL.strAddress, ''), CHAR(13), ''), CHAR(10), ''), 22)
	,strEmployeeCity = LEFT(ISNULL(ENL.strCity, ''), 22)
	,strEmployeeState = CASE WHEN (ISNULL(ENL.strCountry, '') <> 'United States') THEN '' 
							ELSE 
								CASE WHEN (ISNULL(ENL.strState, '') IN (SELECT strState FROM tblPRTypeTaxState WHERE strCode <> ''))
										THEN (SELECT TOP 1 strCode FROM tblPRTypeTaxState WHERE strState = ENL.strState)
									 WHEN (ISNULL(ENL.strState, '') IN (SELECT strCode FROM tblPRTypeTaxState WHERE strCode <> ''))
										THEN ISNULL(ENL.strState, '')
									 ELSE '' 
								END
							END
	,strEmployeeZipCode = CASE WHEN (ISNULL(ENL.strCountry, '') <> 'United States') 
								   THEN LEFT(REPLACE(ISNULL(ENL.strZipCode, ''), '-', ''), 15) 
								   ELSE LEFT(REPLACE(ISNULL(ENL.strZipCode, ''), '-', ''), 5) 
							  END
	,strEmployeeZipCodeExt = CASE WHEN (ISNULL(ENL.strCountry, '') <> 'United States') THEN '' 
								ELSE 
									CASE WHEN (LEN(REPLACE(ISNULL(ENL.strZipCode, ''), '-', '')) > 5)
										THEN SUBSTRING(ISNULL(ENL.strZipCode, ''), 5, 4) 
										ELSE '' 
									END 
								END
	,strEmployeeForeignState = CASE WHEN (ISNULL(ENL.strCountry, '') <> 'United States') THEN LEFT(ISNULL(ENL.strState, ''), 23) ELSE '' END
	,strEmployeeForeignPostal = CASE WHEN (ISNULL(ENL.strCountry, '') <> 'United States') THEN LEFT(ISNULL(ENL.strZipCode, ''), 15) ELSE '' END
	,strEmployeeForeignCountry = CASE WHEN (ISNULL(ENL.strCountry, '') <> 'United States') 
								THEN ISNULL((SELECT TOP 1 strCode FROM tblPRIRSCountryCode WHERE strCountry = ISNULL(ENL.strCountry, '')), '')
								ELSE '' END
	,dblWages = W2.dblAdjustedGross
	,dblFederalTax = W2.dblFIT
	,dblSSWages =  W2.dblTaxableSS
	,dblSSTax = W2.dblSSTax
	,dblMedWages = W2.dblTaxableMed
	,dblMedTax = W2.dblMedTax
	,dblSSTips = W2.dblTaxableSSTips
	,dblAllocatedTips = W2.dblAllocatedTips
	,dblDependentCare = W2.dblDependentCare
	,dblNonqualifiedPlans = W2.dblNonqualifiedPlans
	,dblCodeAB = CASE WHEN (strBox12a IN ('A', 'B')) THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b IN ('A', 'B')) THEN dblBox12b ELSE 0 END 
			   + CASE WHEN (strBox12c IN ('A', 'B')) THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d IN ('A', 'B')) THEN dblBox12d ELSE 0 END
	,dblCodeC = CASE WHEN (strBox12a = 'C') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'C') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'C') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'C') THEN dblBox12d ELSE 0 END
	,dblCodeD = CASE WHEN (strBox12a = 'D') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'D') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'D') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'D') THEN dblBox12d ELSE 0 END
	,dblCodeE = CASE WHEN (strBox12a = 'E') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'E') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'E') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'E') THEN dblBox12d ELSE 0 END
	,dblCodeF = CASE WHEN (strBox12a = 'F') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'F') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'F') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'F') THEN dblBox12d ELSE 0 END
	,dblCodeG = CASE WHEN (strBox12a = 'G') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'G') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'G') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'G') THEN dblBox12d ELSE 0 END
	,dblCodeH = CASE WHEN (strBox12a = 'H') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'H') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'H') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'H') THEN dblBox12d ELSE 0 END
	,dblCodeM = CASE WHEN (strBox12a = 'M') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'M') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'M') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'M') THEN dblBox12d ELSE 0 END
	,dblCodeN = CASE WHEN (strBox12a = 'N') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'N') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'N') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'N') THEN dblBox12d ELSE 0 END
	,dblCodeQ = CASE WHEN (strBox12a = 'Q') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'Q') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'Q') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'Q') THEN dblBox12d ELSE 0 END
	,dblCodeR = CASE WHEN (strBox12a = 'R') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'R') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'R') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'R') THEN dblBox12d ELSE 0 END
	,dblCodeS = CASE WHEN (strBox12a = 'S') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'S') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'S') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'S') THEN dblBox12d ELSE 0 END
	,dblCodeT = CASE WHEN (strBox12a = 'T') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'T') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'T') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'T') THEN dblBox12d ELSE 0 END
	,dblCodeV = CASE WHEN (strBox12a = 'V') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'V') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'V') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'V') THEN dblBox12d ELSE 0 END
	,dblCodeW = CASE WHEN (strBox12a = 'W') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'W') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'W') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'W') THEN dblBox12d ELSE 0 END
	,dblCodeY = CASE WHEN (strBox12a = 'Y') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'Y') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'Y') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'Y') THEN dblBox12d ELSE 0 END
	,dblCodeZ = CASE WHEN (strBox12a = 'Z') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'Z') THEN dblBox12b ELSE 0 END 
			  + CASE WHEN (strBox12c = 'Z') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'Z') THEN dblBox12d ELSE 0 END
	,dblCodeAA = CASE WHEN (strBox12a = 'AA') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'AA') THEN dblBox12b ELSE 0 END 
			   + CASE WHEN (strBox12c = 'AA') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'AA') THEN dblBox12d ELSE 0 END
	,dblCodeBB = CASE WHEN (strBox12a = 'BB') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'BB') THEN dblBox12b ELSE 0 END 
			   + CASE WHEN (strBox12c = 'BB') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'BB') THEN dblBox12d ELSE 0 END
	,dblCodeDD = CASE WHEN (strBox12a = 'DD') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'DD') THEN dblBox12b ELSE 0 END 
			   + CASE WHEN (strBox12c = 'DD') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'DD') THEN dblBox12d ELSE 0 END
	,dblCodeEE = CASE WHEN (strBox12a = 'EE') THEN dblBox12a ELSE 0 END + CASE WHEN (strBox12b = 'EE') THEN dblBox12b ELSE 0 END 
			   + CASE WHEN (strBox12c = 'EE') THEN dblBox12c ELSE 0 END + CASE WHEN (strBox12d = 'EE') THEN dblBox12d ELSE 0 END
	,EMP.ysnStatutoryEmployee
	,EMP.ysnRetirementPlan
	,EMP.ysnThirdPartySickPay
	,strStateCode = ISNULL((SELECT TOP 1 strFIPSCode FROM tblPRTypeTaxState WHERE strCode = W2.strState), '  ')
	,strTaxTypeCode = CASE WHEN (W2.strState IN ('OH', 'PN')) THEN 'E'
						   WHEN (W2.strState IN ('CO', 'DE', 'MO', 'NY')) THEN 'C'
						   WHEN (W2.strState = '') THEN ' '
						   WHEN (W2.strState NOT IN (SELECT strCode FROM tblPRTypeTaxState WHERE strCode <> '')) THEN 'F'
						   ELSE 'D' END
	,W2.strState
	,W2.strStateTaxID
	,W2.dblTaxableState
	,W2.dblStateTax
	,W2.dblTaxableLocal
	,W2.dblLocalTax
	,W2.strLocality
FROM
	tblPREmployeeW2 W2
	INNER JOIN tblPREmployee EMP ON W2.intEntityEmployeeId = EMP.[intEntityId]
	INNER JOIN tblEMEntity ENT ON ENT.intEntityId = EMP.[intEntityId]
	INNER JOIN tblEMEntityLocation ENL ON ENT.intEntityId = ENL.intEntityId AND ENL.ysnDefaultLocation = 1
GO