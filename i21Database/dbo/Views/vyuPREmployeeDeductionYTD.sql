CREATE VIEW [dbo].[vyuPREmployeeEarningYTD]
AS
	SELECT 
		 intEntityEmployeeId	= PaycheckEarning.intEntityEmployeeId
		,strEarning				= PaycheckEarning.strEarning
		,strDescription			= PaycheckEarning.strDescription
		,intYear				= DATEPART(YEAR, PaycheckEarning.dtmPayDate)
		,dblHours				= SUM(PaycheckEarning.dblHours)
		,dblTotal				= SUM(PaycheckEarning.dblTotal)
	 FROM vyuPRPaycheckEarning PaycheckEarning
	 GROUP BY PaycheckEarning.intEntityEmployeeId,
			  PaycheckEarning.strEarning,
			  PaycheckEarning.strDescription,
			  DATEPART(YEAR, PaycheckEarning.dtmPayDate)
 GO
