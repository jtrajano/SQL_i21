CREATE VIEW [dbo].[vyuPRDailyTaxTotal]
AS
SELECT	
	Months.intYear
	,Months.intQuarter
	,Months.intMonth
	,Months.intDay
	,dblFIT = ISNULL(FIT.dblTotal, 0)
	,dblLiabilitySS = ISNULL(LiabilitySS.dblTotal, 0)
	,dblLiabilityMed = ISNULL(LiabilityMed.dblTotal, 0)
	,dblTaxTotalSS = ISNULL(TaxTotalSS.dblTotal, 0)
	,dblTaxTotalMed = ISNULL(TaxTotalMed.dblTotal, 0)
	,dblTaxTotalAddMed = ISNULL(TaxTotalMed.dblAddMedTotal, 0)
	,dblDayTotal = ISNULL(LiabilitySS.dblTotal, 0) 
					+ ISNULL(LiabilityMed.dblTotal, 0) 
					+ ISNULL(TaxTotalSS.dblTotal, 0) 
					+ ISNULL(TaxTotalMed.dblTotal, 0)
					+ ISNULL(TaxTotalMed.dblAddMedTotal, 0)
					+ ISNULL(FIT.dblTotal, 0)
FROM 
	(SELECT 
		DISTINCT
		intYear		= DATEPART(YY, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(MM, vyuPRPaycheckTax.dtmPayDate)
		,intDay		= DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
		FROM vyuPRPaycheckTax
		WHERE ysnVoid = 0
	) Months
	LEFT JOIN
	(SELECT 
		intYear		= DATEPART(YY, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(MM, vyuPRPaycheckTax.dtmPayDate)
		,intDay		= DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
		,dblTotal	= CONVERT(NUMERIC(18,2), SUM(vyuPRPaycheckTax.dblTotal))
	 FROM vyuPRPaycheckTax
	 WHERE vyuPRPaycheckTax.strCalculationType = 'USA Social Security'
			AND vyuPRPaycheckTax.strPaidBy = 'Company'
			AND vyuPRPaycheckTax.ysnVoid = 0
	 GROUP BY 
		DATEPART(YY, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(MM, vyuPRPaycheckTax.dtmPayDate),
		DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
	) AS LiabilitySS
	ON Months.intMonth = LiabilitySS.intMonth 
		AND Months.intQuarter = LiabilitySS.intQuarter
		AND Months.intYear = LiabilitySS.intYear
		AND Months.intDay = LiabilitySS.intDay
	LEFT JOIN
	(SELECT 
		intYear		= DATEPART(YY, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(MM, vyuPRPaycheckTax.dtmPayDate)
		,intDay		= DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
		,dblTotal	= CONVERT(NUMERIC(18,2), SUM(vyuPRPaycheckTax.dblTotal))
	 FROM vyuPRPaycheckTax
	 WHERE vyuPRPaycheckTax.strCalculationType = 'USA Medicare'
			AND vyuPRPaycheckTax.strPaidBy = 'Company'
			AND vyuPRPaycheckTax.ysnVoid = 0
	 GROUP BY 
		DATEPART(YY, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(MM, vyuPRPaycheckTax.dtmPayDate),
		DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
	) AS LiabilityMed
	ON Months.intMonth = LiabilityMed.intMonth 
		AND Months.intQuarter = LiabilityMed.intQuarter
		AND Months.intYear = LiabilityMed.intYear
		AND Months.intDay = LiabilityMed.intDay
	LEFT JOIN
	(SELECT	
		intYear		= DATEPART(YY, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(MM, vyuPRPaycheckTax.dtmPayDate)
		,intDay		= DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
		,dblTotal	= CONVERT(NUMERIC(18,2), SUM(vyuPRPaycheckTax.dblTotal))
	 FROM vyuPRPaycheckTax
	 WHERE vyuPRPaycheckTax.strCalculationType = 'USA Social Security'
			AND vyuPRPaycheckTax.strPaidBy = 'Employee'
			AND vyuPRPaycheckTax.ysnVoid = 0
	GROUP BY
		DATEPART(YY, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(MM, vyuPRPaycheckTax.dtmPayDate),
		DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
	) AS TaxTotalSS
	ON Months.intMonth = TaxTotalSS.intMonth 
		AND Months.intQuarter = TaxTotalSS.intQuarter
		AND Months.intYear = TaxTotalSS.intYear
		AND Months.intDay = TaxTotalSS.intDay
	LEFT JOIN
	(SELECT 
		intYear		= DATEPART(YY, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(MM, vyuPRPaycheckTax.dtmPayDate)
		,intDay		= DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
		,dblTotal	= CONVERT(NUMERIC(18,2), SUM(vyuPRPaycheckTax.dblTotal))
		,dblAddMedTotal	= CONVERT(NUMERIC(18,2), SUM(vyuPRPaycheckTax.dblAdditionalMed))
	 FROM vyuPRPaycheckTax
	 WHERE vyuPRPaycheckTax.strCalculationType = 'USA Medicare'
			AND vyuPRPaycheckTax.strPaidBy = 'Employee'
			AND vyuPRPaycheckTax.ysnVoid = 0
	 GROUP BY 
		DATEPART(YY, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(MM, vyuPRPaycheckTax.dtmPayDate),
		DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
	) AS TaxTotalMed
	ON Months.intMonth = TaxTotalMed.intMonth 
		AND Months.intQuarter = TaxTotalMed.intQuarter
		AND Months.intYear = TaxTotalMed.intYear
		AND Months.intDay = TaxTotalMed.intDay
	LEFT JOIN
	(SELECT	
		intYear		= DATEPART(YY, vyuPRPaycheckTax.dtmPayDate)
		,intQuarter = DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate)
		,intMonth	= DATEPART(MM, vyuPRPaycheckTax.dtmPayDate)
		,intDay		= DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
		,dblTotal	= CONVERT(NUMERIC(18,2), SUM(vyuPRPaycheckTax.dblTotal))
	 FROM vyuPRPaycheckTax
	 WHERE vyuPRPaycheckTax.strCalculationType = 'USA Federal Tax'
	 AND vyuPRPaycheckTax.ysnVoid = 0
	GROUP BY
		DATEPART(YY, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(QQ, vyuPRPaycheckTax.dtmPayDate), 
		DATEPART(MM, vyuPRPaycheckTax.dtmPayDate),
		DATEPART(DD, vyuPRPaycheckTax.dtmPayDate)
	) AS FIT
	ON Months.intMonth = FIT.intMonth 
		AND Months.intQuarter = FIT.intQuarter
		AND Months.intYear = FIT.intYear
		AND Months.intDay = FIT.intDay