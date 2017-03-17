CREATE VIEW [dbo].[vyuPRMonthlyTaxTotal]
AS
SELECT	
	Months.intYear
	,Months.intQuarter
	,Months.intMonth
	,dblFIT = ISNULL(FIT.dblTotal, 0)
	,dblLiabilitySS = ISNULL(LiabilitySS.dblTotal, 0)
	,dblLiabilityMed = ISNULL(LiabilityMed.dblTotal, 0)
	,dblTaxTotalSS = ISNULL(TaxTotalSS.dblTotal, 0)
	,dblTaxTotalMed = ISNULL(TaxTotalMed.dblTotal, 0)
	,dblTaxTotalAddMed = ISNULL(TaxTotalMed.dblAddMedTotal, 0)
	,dblMonthTotal = ISNULL(LiabilitySS.dblTotal, 0) 
					+ ISNULL(LiabilityMed.dblTotal, 0) 
					+ ISNULL(TaxTotalSS.dblTotal, 0) 
					+ ISNULL(TaxTotalMed.dblTotal, 0)
					+ ISNULL(TaxTotalMed.dblAddMedTotal, 0)
					+ ISNULL(FIT.dblTotal, 0)
FROM 
	(SELECT 
		DISTINCT
		intYear		= DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(Q, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
		FROM vyuPRPaycheckTax WHERE ysnVoid = 0
	) Months
	LEFT JOIN
	(SELECT 
		intYear		= DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(Q, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
		,dblTotal	= SUM(vyuPRPaycheckTax.dblTotal)
	 FROM vyuPRPaycheckTax
	 WHERE vyuPRPaycheckTax.strCalculationType = 'USA Social Security'
			AND vyuPRPaycheckTax.strPaidBy = 'Company'
			AND vyuPRPaycheckTax.ysnVoid = 0
	 GROUP BY 
		DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(Q, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
	) AS LiabilitySS
	ON Months.intMonth = LiabilitySS.intMonth 
		AND Months.intQuarter = LiabilitySS.intQuarter
		AND Months.intYear = LiabilitySS.intYear
	LEFT JOIN
	(SELECT 
		intYear		= DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(Q, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
		,dblTotal	= SUM(vyuPRPaycheckTax.dblTotal)
	 FROM vyuPRPaycheckTax
	 WHERE vyuPRPaycheckTax.strCalculationType = 'USA Medicare'
			AND vyuPRPaycheckTax.strPaidBy = 'Company'
			AND vyuPRPaycheckTax.ysnVoid = 0
	 GROUP BY 
		DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(Q, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
	) AS LiabilityMed
	ON Months.intMonth = LiabilityMed.intMonth 
		AND Months.intQuarter = LiabilityMed.intQuarter
		AND Months.intYear = LiabilityMed.intYear
	LEFT JOIN
	(SELECT	
		intYear		= DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(Q, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
		,dblTotal	= SUM(vyuPRPaycheckTax.dblTotal)
	 FROM vyuPRPaycheckTax
	 WHERE vyuPRPaycheckTax.strCalculationType = 'USA Social Security'
			AND vyuPRPaycheckTax.strPaidBy = 'Employee'
			AND vyuPRPaycheckTax.ysnVoid = 0
	GROUP BY
		DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(Q, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
	) AS TaxTotalSS
	ON Months.intMonth = TaxTotalSS.intMonth 
		AND Months.intQuarter = TaxTotalSS.intQuarter
		AND Months.intYear = TaxTotalSS.intYear
	LEFT JOIN
	(SELECT 
		intYear		= DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(Q, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
		,dblTotal	= SUM(vyuPRPaycheckTax.dblTotal)
		,dblAddMedTotal = SUM(vyuPRPaycheckTax.dblAdditionalMed)
	 FROM vyuPRPaycheckTax
	 WHERE vyuPRPaycheckTax.strCalculationType = 'USA Medicare'
			AND vyuPRPaycheckTax.strPaidBy = 'Employee'
			AND vyuPRPaycheckTax.ysnVoid = 0
	 GROUP BY 
		DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(Q, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
	) AS TaxTotalMed
	ON Months.intMonth = TaxTotalMed.intMonth 
		AND Months.intQuarter = TaxTotalMed.intQuarter
		AND Months.intYear = TaxTotalMed.intYear
	LEFT JOIN
	(SELECT	
		intYear		= DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(Q, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
		,dblTotal	= SUM(vyuPRPaycheckTax.dblTotal)
	 FROM vyuPRPaycheckTax
	 WHERE vyuPRPaycheckTax.strCalculationType = 'USA Federal Tax'
		AND vyuPRPaycheckTax.ysnVoid = 0
	GROUP BY
		DATEPART(YEAR, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(Q, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(M, vyuPRPaycheckTax.dtmPayDate)
	) AS FIT
	ON Months.intMonth = FIT.intMonth 
		AND Months.intQuarter = FIT.intQuarter
		AND Months.intYear = FIT.intYear