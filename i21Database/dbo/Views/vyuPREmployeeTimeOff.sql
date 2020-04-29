CREATE VIEW [dbo].[vyuPREmployeeTimeOff]
AS 

SELECT ETO.intEntityEmployeeId
	,ET.intEntityId
	,ETO.intEmployeeTimeOffId
	,ETO.intTypeTimeOffId
	,ET.strEntityNo
	,strEntityName = ET.strName
	,strTimeOffId = TTO.strTimeOff
	,strTimeOffDescription = TTO.strDescription
	,dblHoursLeft = ISNULL(dblHoursEarned,0) - ISNULL(dblHoursUsed,0)
	,ETO.dtmEligible
	,ETO.dblRate
	,ETO.strAwardPeriod
	,ETO.dblRateFactor
	,ETO.dblMaxCarryover
	,ETO.dblMaxEarned
	,ETO.dtmLastAward
	,ETO.dblHoursEarned
	,ETO.dblHoursAccrued
	,ETO.intSort
	,ETO.dblPerPeriod
	,ETO.strPeriod
	,EMP.intRank
	,dblHoursUsed = (ETO.dblHoursUsed + ISNULL(TOYTD.dblHoursUsedYTD,0))
	,dblBalance = (ETO.dblHoursCarryover + ETO.dblHoursEarned) - ETO.dblHoursUsed - ISNULL(TOYTD.dblHoursUsedYTD,0)
FROM tblPREmployeeTimeOff ETO
LEFT JOIN(
	SELECT intEntityId
		,strEntityNo
		,strName
	FROM tblEMEntity
) ET ON ETO.intEntityEmployeeId = ET.intEntityId
LEFT JOIN(
	SELECT intTypeTimeOffId
		,strTimeOff
		,strDescription
	FROM tblPRTypeTimeOff
) TTO ON ETO.intTypeTimeOffId = TTO.intTypeTimeOffId
LEFT JOIN(
	SELECT intEntityId 
		,intRank
	FROM tblPREmployee
) EMP ON ETO.intEntityEmployeeId = EMP.intEntityId


INNER JOIN(
	
		SELECT E.intEntityId  
			  ,dblHoursUsedYTD = SUM(
										CASE WHEN (T.strAwardPeriod = 'Anniversary Date') THEN 
													CASE WHEN (PCTimeOff.dtmDateFrom < DATEADD(YY, YEAR(GETDATE()) - YEAR(dtmDateHired), dtmDateHired)  
															AND PCTimeOff.dtmDateFrom > ISNULL(T.dtmLastAward, E.dtmDateHired)  
															) THEN dblHours
															ELSE 0
													END
											WHEN (T.strAwardPeriod = 'Start of Month') THEN 
													CASE WHEN (PCTimeOff.dtmDateFrom >= dtmLastAward 
															AND ( MONTH(PCTimeOff.dtmDateFrom) < MONTH(GETDATE()) 
															AND YEAR(PCTimeOff.dtmDateFrom) = YEAR(GETDATE())	)  
															) THEN
														
														dblHours
													ELSE
														0
													END
											ELSE 
												CASE WHEN (PCTimeOff.intYear = YEAR(GETDATE())) THEN
													dblHours
												ELSE
													0
												END
										END
										)
 
			,intTypeTimeOffId
			FROM tblPREmployee E INNER JOIN tblPREmployeeTimeOff T  ON E.intEntityId = T.intEntityEmployeeId  

			LEFT JOIN 
				(SELECT 
					intYear = YEAR(dtmPayDate)
					,dtmDateFrom
					,intEntityEmployeeId
					,intTypeTimeoffId = intEmployeeTimeOffId
					,dblHours
					,intPaycheckEarningId
				FROM 
					tblPRPaycheckEarning PCE 
					INNER JOIN tblPRPaycheck PC
						ON PCE.intPaycheckId = PC.intPaycheckId
				WHERE 
					intEmployeeTimeOffId IS NOT NULL
					AND ysnPosted = 1
					AND ysnVoid = 0
					AND dblHours <> 0
				)PCTimeOff
				ON PCTimeOff.intEntityEmployeeId = E.intEntityId 
				AND PCTimeOff.intTypeTimeoffId = T.intTypeTimeOffId
   
   			GROUP BY 
			E.intEntityId
			,intTypeTimeOffId   
) TOYTD 
	ON ETO.intEntityEmployeeId = TOYTD.intEntityId 
		AND ETO.intTypeTimeOffId = TOYTD.intTypeTimeOffId 		