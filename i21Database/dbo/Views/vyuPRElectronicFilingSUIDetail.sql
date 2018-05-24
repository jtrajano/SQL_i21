CREATE VIEW [dbo].[vyuPRElectronicFilingSUIDetail]
AS
SELECT DISTINCT
	intYear = SUI.intYear
	,intQuarter = SUI.intQuarter
	,intEntityId = SUI.intEntityId
	,strSSN = LEFT(dbo.fnAPRemoveSpecialChars(ISNULL(EMP.strSocialSecurity, '')), 9)
	,strFirstName = UPPER(LEFT(ISNULL(EMP.strFirstName, ''), 15))
	,strMiddleName = UPPER(LEFT(ISNULL(EMP.strMiddleName, ''), 15))
	,strLastName = UPPER(LEFT(ISNULL(EMP.strLastName, ''), 20))
	,strStateCode = ISNULL((SELECT TOP 1 strFIPSCode FROM tblPRTypeTaxState WHERE strCode = ESUI.strState), '')
	,dblWages = ISNULL(SUI.dblGross, 0)
	,dblGross = ISNULL(SUI.dblAdjustedGross, 0)
	,dblTaxableSUI = ISNULL(SUI.dblTaxable, 0)
	,dblExcess = ISNULL(SUI.dblAdjustedGross, 0) - ISNULL(SUI.dblTaxable, 0)
	,dblTaxable = ISNULL(SUI.dblTaxable, 0)
	,dblTaxableSDI = 0.000000
	,dblTips = ISNULL(TIP.dblTotal, 0)
	,intWeeks = CONVERT(INT, ISNULL(SUI.dblTotalHours, 0)) / 40
	,intHours = CONVERT(INT, ISNULL(SUI.dblTotalHours, 0))
	,strSUIAccount = ISNULL(LEFT(dbo.fnAPRemoveSpecialChars(ESUI.strSUIAccountNumber), 10), '')
	,strWorkSiteID = ISNULL(ESUI.strAuthorizationNumber, '')
	,dblTaxableState = ISNULL(ST.dblAdjustedGross, 0)
	,dblStateTax = ISNULL(ST.dblStateTotal, 0)
	,ysnOfficer = CAST(CASE WHEN (EMP.strEEOCCode IN ('1.1 - Executive/Senior Level Officials and Managers', '1.2 - First/Mid Level Officials & Managers')) THEN 1 ELSE 0 END AS BIT)
	,ysnMonth1Employed = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheck WHERE intEntityEmployeeId = SUI.intEntityId 
		AND DATEADD(DD, 12 -1, 
			DATEADD(MM, (CASE SUI.intQuarter WHEN 1 THEN 1 WHEN 2 THEN 4 WHEN 3 THEN 7 WHEN 4 THEN 10 END) - 1, 
			DATEADD(YY, SUI.intYear - 1900, 0))) BETWEEN dtmDateFrom AND dtmDateTo), 0) AS BIT)
	,ysnMonth2Employed = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheck WHERE intEntityEmployeeId = SUI.intEntityId 
		AND DATEADD(DD, 12 -1, 
			DATEADD(MM, (CASE SUI.intQuarter WHEN 1 THEN 2 WHEN 2 THEN 5 WHEN 3 THEN 8 WHEN 4 THEN 11 END) - 1, 
			DATEADD(YY, SUI.intYear - 1900, 0))) BETWEEN dtmDateFrom AND dtmDateTo), 0) AS BIT)
	,ysnMonth3Employed = CAST(ISNULL((SELECT TOP 1 1 FROM tblPRPaycheck WHERE intEntityEmployeeId = SUI.intEntityId 
		AND DATEADD(DD, 12 -1, 
			DATEADD(MM, (CASE SUI.intQuarter WHEN 1 THEN 3 WHEN 2 THEN 6 WHEN 3 THEN 9 WHEN 4 THEN 12 END) - 1, 
			DATEADD(YY, SUI.intYear - 1900, 0))) BETWEEN dtmDateFrom AND dtmDateTo), 0) AS BIT)
	,strQuarterYear = RIGHT('000000'+ CONVERT(nvarchar(10), CASE SUI.intQuarter WHEN 1 THEN 3 WHEN 2 THEN 6 WHEN 3 THEN 9 WHEN 4 THEN 12 END) + CONVERT(nvarchar(10), SUI.intYear), 6)
	,strMonthYearHired = ISNULL(RIGHT('000000'+ CONVERT(nvarchar(10), MONTH(EMP.dtmOriginalDateHired)) + CONVERT(nvarchar(10), YEAR(EMP.dtmOriginalDateHired)), 6), '')
	,strMonthYearTerminated = ISNULL(RIGHT('000000'+ CONVERT(nvarchar(10), MONTH(EMP.dtmTerminated)) + CONVERT(nvarchar(10), YEAR(EMP.dtmTerminated)), 6), '')
FROM
	vyuPRReportQuarterlySUI SUI
	LEFT JOIN tblPRElectronicFilingSUI ESUI 
		ON ESUI.intYear = SUI.intYear AND ESUI.intQuarter = SUI.intQuarter
	LEFT JOIN vyuPRReportQuarterlyStateTax ST 
		ON SUI.intEntityId = ST.intEntityId AND SUI.intYear = ST.intYear AND SUI.intQuarter = ST.intQuarter
	LEFT JOIN (SELECT 
					intEntityId = intEntityEmployeeId, 
					intYear = YEAR(dtmPayDate), 
					intQuarter = DATEPART(QQ, dtmPayDate), 
					dblTotal = SUM(dblTotal) 
				FROM vyuPRPaycheckEarning WHERE ysnVoid = 0 AND strCalculationType = 'Tip'
				GROUP BY
					intEntityEmployeeId, 
					YEAR(dtmPayDate), 
					DATEPART(QQ, dtmPayDate)) TIP
		ON SUI.intEntityId = TIP.intEntityId AND SUI.intYear = TIP.intYear AND SUI.intQuarter = TIP.intQuarter
	INNER JOIN tblPREmployee EMP ON SUI.intEntityId = EMP.[intEntityId]
	INNER JOIN tblEMEntity ENT ON ENT.intEntityId = EMP.[intEntityId]
	INNER JOIN tblEMEntityLocation ENL ON ENT.intEntityId = ENL.intEntityId AND ENL.ysnDefaultLocation = 1
GO