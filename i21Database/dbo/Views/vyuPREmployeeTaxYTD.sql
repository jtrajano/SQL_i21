CREATE VIEW [dbo].[vyuPREmployeeTaxYTD]
AS
	SELECT 
		 intEntityEmployeeId = PaycheckTax.intEntityEmployeeId
		,strTaxId			 = PaycheckTax.strTaxId
		,strDescription		 = PaycheckTax.strDescription
		,intYear			 = DATEPART(YEAR, PaycheckTax.dtmPayDate)
		,dblTotal			 = SUM(PaycheckTax.dblTotal)
		,dblTaxableAmount	 = SUM(PaycheckTax.dblTaxableAmount)
	 FROM vyuPRPaycheckTax PaycheckTax 
	 GROUP BY PaycheckTax.intEntityEmployeeId,
			  PaycheckTax.strTaxId,
			  PaycheckTax.strDescription,
			  DATEPART(YEAR, PaycheckTax.dtmPayDate)
 GO
