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
	,ETO.dblMaxBalance
	,ETO.dblMaxEarned
	,ETO.dtmLastAward
	,ETO.dblHoursEarned
	,ETO.dblHoursAccrued
	,ETO.intSort
	,ETO.dblPerPeriod
	,ETO.strPeriod
	,EMP.intRank
	,dblHoursUsed = ISNULL(TOYTD.dblHoursUsedYTD,0)
	,dblBalance = (ETO.dblHoursCarryover + ETO.dblHoursEarned) - ETO.dblHoursUsed - ISNULL(TOYTD.dblHoursUsedYTD,0)
	,ETO.dblHoursCarryover  
	,dblAdjustments =  ETO.dblHoursUsed 
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
										CASE WHEN PCTimeOff.intYear IS NOT NULL AND (T.strAwardPeriod = 'Anniversary Date') THEN 
													CASE WHEN (PCTimeOff.dtmDateFrom < DATEADD(YY, YEAR(GETDATE()) - YEAR(dtmDateHired), dtmDateHired)  
															AND PCTimeOff.dtmDateFrom > ISNULL(T.dtmLastAward, E.dtmDateHired)  
															) THEN dblHours
													ELSE 0

													END
											WHEN PCTimeOff.intYear IS NOT NULL AND (T.strAwardPeriod = 'End of Year') THEN 
													CASE WHEN (PCTimeOff.dtmDateFrom < DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1) 
															AND PCTimeOff.dtmDateFrom >= ISNULL(T.dtmLastAward, E.dtmDateHired)  
															) THEN dblHours
													ELSE 0

													END 
                                            WHEN TOR.intYear IS NOT NULL AND (T.strAwardPeriod = 'End of Year') THEN   
                                                CASE WHEN (  TOR.dtmDateFrom >= ISNULL(T.dtmLastAward, E.dtmDateHired)    
														AND (TOR.dtmDateFrom < DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1))  
														) THEN TOR.dblHoursTOR  
												ELSE   
													0	
												END  
											WHEN TOR.intYear IS NOT NULL  AND (T.strAwardPeriod = 'Start of Year') THEN
												CASE WHEN TOR.intYear = YEAR(GETDATE())
												THEN TOR.dblHoursTOR
												ELSE 0
												END
											ELSE 
												CASE WHEN PCTimeOff.intYear IS NOT NULL AND (PCTimeOff.intYear = YEAR(GETDATE())) THEN
														dblHours
													WHEN TOR.intYear IS NOT NULL AND (T.strAwardPeriod = 'Anniversary Date') THEN 
															CASE WHEN (
																		 TOR.dtmDateFrom >= ISNULL(T.dtmLastAward, E.dtmDateHired)  
																		 AND 
																		 (TOR.dtmDateFrom < DATEADD(YY, YEAR(GETDATE()) - YEAR(dtmDateHired), dtmDateHired)  OR YEAR(TOR.dtmDateFrom) =  YEAR(GETDATE()) )
																		) THEN TOR.dblHoursTOR
															ELSE 
															  0
															END
													WHEN TOR.intYear IS NOT NULL AND (TOR.intYear =  YEAR(dtmLastAward))
															THEN TOR.dblHoursTOR
													ELSE
														0
													END
											END
										)
 
			,T.intTypeTimeOffId
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
   
   			LEFT JOIN (	SELECT
						intYear  = YEAR(dtmDateFrom)
						,dtmDateFrom
						,intEntityEmployeeId
						,intTypeTimeOffId
						,dblHoursTOR = dblRequest
						FROM tblPRTimeOffRequest TOR
						WHERE ysnPostedToCalendar = 1
				)TOR
				ON E.intEntityId = TOR.intEntityEmployeeId
				AND T.intTypeTimeOffId = TOR.intTypeTimeOffId

   			GROUP BY 
			E.intEntityId
			,T.intTypeTimeOffId   
) TOYTD 
	ON ETO.intEntityEmployeeId = TOYTD.intEntityId 
		AND ETO.intTypeTimeOffId = TOYTD.intTypeTimeOffId
GO
