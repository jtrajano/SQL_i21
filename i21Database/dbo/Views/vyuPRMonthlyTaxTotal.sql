CREATE VIEW [dbo].[vyuPRMonthlyTaxTotal]
AS
SELECT	
	Liability.intYear
	,Liability.intQuarter
	,Liability.intMonth
	,dblLiabilityTotal = Liability.dblTotal
	,dblTaxTotal = Tax.dblTotal
	,dblMonthTotal = Liability.dblTotal + Tax.dblTotal
FROM 
	(SELECT 
		intYear		= DATEPART(YEAR, [tblPRPaycheck].[dtmPayDate])
		,intQuarter = DATEPART(Q, [tblPRPaycheck].[dtmPayDate])
		,intMonth	= DATEPART(M, [tblPRPaycheck].[dtmPayDate])
		,dblTotal	= CONVERT(NUMERIC(18,2), SUM(tblPRPaycheckTax.dblTotal))
	 FROM tblPRPaycheck INNER JOIN tblPRPaycheckTax 
		ON tblPRPaycheck.intPaycheckId = tblPRPaycheckTax.intPaycheckId
	 WHERE (((tblPRPaycheckTax.strCalculationType = 'USA Social Security' 
		OR tblPRPaycheckTax.strCalculationType = 'USA Medicare') 
		AND tblPRPaycheckTax.strPaidBy = 'Company')
		AND tblPRPaycheck.ysnPosted = 1
		AND tblPRPaycheck.ysnVoid = 0)
	 GROUP BY 
		DATEPART(YEAR, [tblPRPaycheck].[dtmPayDate]), 
		DATEPART(Q, [tblPRPaycheck].[dtmPayDate]), 
		DATEPART(M, [tblPRPaycheck].[dtmPayDate])
	) AS Liability 
	INNER JOIN 
	(SELECT	
		intYear		= DATEPART(YEAR, [tblPRPaycheck].[dtmPayDate])
		,intQuarter = DATEPART(Q, [tblPRPaycheck].[dtmPayDate])
		,intMonth	= DATEPART(M, [tblPRPaycheck].[dtmPayDate])
		,dblTotal	= CONVERT(NUMERIC(18,2), SUM(tblPRPaycheckTax.dblTotal))
	 FROM tblPRPaycheck INNER JOIN tblPRPaycheckTax 
	   ON tblPRPaycheck.intPaycheckId = tblPRPaycheckTax.intPaycheckId
	 WHERE ((tblPRPaycheckTax.strCalculationType = 'USA Federal Tax' 
		OR (tblPRPaycheckTax.strCalculationType = 'USA Social Security' 
			OR tblPRPaycheckTax.strCalculationType = 'USA Medicare') 
			AND tblPRPaycheckTax.strPaidBy = 'Employee') 
		AND tblPRPaycheck.ysnPosted = 1
		AND tblPRPaycheck.ysnVoid = 0)
	GROUP BY
		DATEPART(YEAR, [tblPRPaycheck].[dtmPayDate]), 
		DATEPART(Q, [tblPRPaycheck].[dtmPayDate]), 
		DATEPART(M, [tblPRPaycheck].[dtmPayDate])
	) AS Tax 
		ON Liability.intMonth = Tax.intMonth 
		AND Liability.intQuarter = Tax.intQuarter
		AND Liability.intYear = Tax.intYear