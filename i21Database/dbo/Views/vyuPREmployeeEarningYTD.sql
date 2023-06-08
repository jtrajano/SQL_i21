CREATE VIEW [dbo].[vyuPREmployeeDeductionYTD]
AS
	SELECT 
		 intEntityEmployeeId	= PaycheckDeduction.intEntityEmployeeId
		,strDeduction			= PaycheckDeduction.strDeduction
		,strDescription			= PaycheckDeduction.strDescription
		,intYear				= DATEPART(YEAR, PaycheckDeduction.dtmPayDate)
		,dblTotal				= SUM(PaycheckDeduction.dblTotal)
	 FROM vyuPRPaycheckDeduction PaycheckDeduction
	 GROUP BY PaycheckDeduction.intEntityEmployeeId,
			  PaycheckDeduction.strDeduction,
			  PaycheckDeduction.strDescription,
			  DATEPART(YEAR, PaycheckDeduction.dtmPayDate)
 GO
