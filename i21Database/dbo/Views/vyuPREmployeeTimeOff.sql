﻿CREATE VIEW [dbo].[vyuPREmployeeTimeOff]  
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
 ,TOYTD.intYear  
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
  ,intYear  
     ,dblHoursUsedYTD = SUM(CASE WHEN U.intYear IS NOT NULL THEN ISNULL(U.dblHours, 0) ELSE 0 END)      
     ,T.intTypeTimeOffId      
   FROM tblPREmployee E INNER JOIN tblPREmployeeTimeOff T  ON E.intEntityId = T.intEntityEmployeeId        
         
   LEFT JOIN     
   (  
  SELECT * FROM   
  (  
   SELECT       
    intYear = YEAR(dtmDateFrom)  
    ,PC.intEntityEmployeeId      
    ,intTypeTimeOffId = PCE.intEmployeeTimeOffId      
    ,ET.strAwardPeriod  
    ,ET.dtmLastAward  
    ,ISNULL(ET.dtmLastAward, EMP.dtmDateHired) AS dtmLastAwardPC  
    ,dblHours =  
		CASE   
			WHEN YEAR(dtmDateFrom) IS NOT NULL AND (ET.strAwardPeriod = 'Anniversary Date') THEN   
				CASE WHEN (  
				(dtmDateFrom < DATEADD(YY, YEAR(GETDATE()) - YEAR(EMP.dtmDateHired), EMP.dtmDateHired)  OR YEAR(dtmDateFrom) =  YEAR(GETDATE())))   
					THEN dblHours  
			ELSE   
				CASE WHEN DATEADD(YY, YEAR(GETDATE()) - YEAR(dtmDateHired), dtmDateHired) > ET.dtmLastAward THEN 0 ELSE dblHours END   
			END  
			WHEN YEAR(dtmDateFrom) IS NOT NULL AND (ET.strAwardPeriod = 'End of Year') THEN   
				CASE WHEN (dtmDateFrom < DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1))   
					THEN dblHours  
			ELSE 
				CASE WHEN ET.dtmLastAward = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1) THEN 0 ELSE dblHours END 
			END  
			
			WHEN YEAR(dtmDateFrom) IS NOT NULL  AND (ET.strAwardPeriod = 'Start of Year') THEN  
				CASE WHEN YEAR(dtmDateFrom) = YEAR(GETDATE())  
					THEN dblHours  
			ELSE 
				CASE WHEN YEAR(ET.dtmLastAward) = YEAR(GETDATE()) THEN 0 ELSE dblHours END 
			END  

			WHEN YEAR(dtmDateFrom) IS NOT NULL THEN  
				CASE WHEN dtmDateFrom >= ISNULL(ET.dtmLastAward,EMP.dtmDateHired)   AND YEAR(dtmDateFrom) = YEAR(ISNULL(ET.dtmLastAward,EMP.dtmDateHired))
					THEN dblHours 
				ELSE
					CASE 
					WHEN ET.dtmLastAward = CAST(DATEADD(Q, DATEDIFF(Q, 0, GETDATE()), 0) AS DATE) AND ET.strAwardPeriod = 'Start of Quarter' 
						THEN 0 
					WHEN ET.dtmLastAward = CAST(DATEADD(D, -1, DATEADD(Q, DATEDIFF(Q, 0, GETDATE()) + 1, 0)) AS DATE) AND ET.strAwardPeriod = 'End of Quarter' 
						THEN 0 
					ELSE dblHours END 
				END

		
		ELSE   
			CASE WHEN YEAR(dtmDateFrom) IS NOT NULL AND (YEAR(dtmDateFrom) = YEAR(GETDATE())) THEN  
				dblHours  
			ELSE 
				CASE WHEN YEAR(ET.dtmLastAward) = YEAR(GETDATE()) THEN dblHours ELSE 0 END
			END  
		END  
    ,PCE.intTimeOffRequestId    
    ,PCE.intPaycheckId  
   FROM       
    tblPRPaycheckEarning PCE       
   INNER JOIN tblPRPaycheck PC      
    ON PCE.intPaycheckId = PC.intPaycheckId  
   LEFT JOIN tblPREmployee EMP  
    ON PC.intEntityEmployeeId = EMP.intEntityId  
   LEFT JOIN tblPREmployeeTimeOff ET  
    ON ET.intEntityEmployeeId = PC.intEntityEmployeeId  
    AND ET.intTypeTimeOffId = PCE.intEmployeeTimeOffId  
   WHERE       
    PCE.intEmployeeTimeOffId IS NOT NULL      
    AND ysnPosted = 1      
    AND ysnVoid = 0      
    AND dblHours <> 0   
    AND PC.dtmDateFrom >= ISNULL(ET.dtmLastAward,EMP.dtmDateHired)  

  UNION  
  
   SELECT      
    intYear  = YEAR(dtmDateFrom)     
    ,TOR.intEntityEmployeeId      
    ,TOR.intTypeTimeOffId    
    ,ET.strAwardPeriod  
    ,ET.dtmLastAward  
    ,ISNULL(ET.dtmLastAward, EMP.dtmDateHired) AS dtmLastAwardTOR  
    ,dblHoursTOR =   
		CASE   
			WHEN YEAR(dtmDateFrom) IS NOT NULL AND  (ET.strAwardPeriod = 'Anniversary Date') THEN   
				CASE WHEN (  
				(TOR.dtmDateFrom < DATEADD(YY, YEAR(GETDATE()) - YEAR(dtmDateHired), dtmDateHired)  OR YEAR(TOR.dtmDateFrom) =  YEAR(GETDATE()) )  
				) THEN dblRequest  
			ELSE   
				CASE WHEN DATEADD(YY, YEAR(GETDATE()) - YEAR(dtmDateHired), dtmDateHired) > ET.dtmLastAward THEN 0 ELSE dblRequest END 
			END  
  
			WHEN YEAR(dtmDateFrom) IS NOT NULL AND (ET.strAwardPeriod = 'End of Year') THEN     
				CASE WHEN ((TOR.dtmDateFrom < DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1)))   
					THEN dblRequest   
			ELSE    
				CASE WHEN ET.dtmLastAward = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1) THEN 0 ELSE dblRequest END
			END   
			WHEN YEAR(dtmDateFrom) IS NOT NULL  AND (ET.strAwardPeriod = 'Start of Year') THEN  
				CASE WHEN YEAR(dtmDateFrom) = YEAR(GETDATE())  
					THEN dblRequest  
			ELSE   
				CASE WHEN YEAR(ET.dtmLastAward) = YEAR(GETDATE()) THEN 0 ELSE dblRequest END
			END  

			WHEN YEAR(dtmDateFrom) IS NOT NULL THEN  
				CASE WHEN dtmDateFrom >= ISNULL(ET.dtmLastAward,EMP.dtmDateHired)   AND YEAR(dtmDateFrom) = YEAR(ISNULL(ET.dtmLastAward,EMP.dtmDateHired))
					THEN dblHours 
				ELSE
					CASE 
					WHEN ET.dtmLastAward = CAST(DATEADD(Q, DATEDIFF(Q, 0, GETDATE()), 0) AS DATE) AND ET.strAwardPeriod = 'Start of Quarter' 
						THEN 0 
					WHEN ET.dtmLastAward = CAST(DATEADD(D, -1, DATEADD(Q, DATEDIFF(Q, 0, GETDATE()) + 1, 0)) AS DATE) AND ET.strAwardPeriod = 'End of Quarter' 
						THEN 0 
					ELSE dblHours END 
				END
		ELSE   
			CASE WHEN YEAR(dtmDateFrom) IS NOT NULL AND (YEAR(dtmDateFrom) =  YEAR(dtmLastAward))  
				THEN dblRequest  
			ELSE  
				CASE WHEN YEAR(ET.dtmLastAward) = YEAR(GETDATE()) THEN dblRequest ELSE 0 END  
			END  
		END  
    ,TOR.intTimeOffRequestId  
    ,TOR.intPaycheckId    
   FROM   
    tblPRTimeOffRequest TOR    
   LEFT JOIN tblPREmployee EMP  
    on EMP.intEntityId = TOR.intEntityEmployeeId  
   LEFT JOIN tblPREmployeeTimeOff ET  
    on ET.intEntityEmployeeId = TOR.intEntityEmployeeId  
    and ET.intTypeTimeOffId = TOR.intTypeTimeOffId  
   LEFT JOIN tblPRPaycheckEarning PCE  
    on PCE.intTimeOffRequestId = TOR.intTypeTimeOffId  
   WHERE   
     ysnPostedToCalendar = 1    
    AND TOR.dtmDateFrom >= ISNULL(ET.dtmLastAward,EMP.dtmDateHired)  
  ) U  
   ) U  
     
 ON U.intEntityEmployeeId = E.intEntityId  
 and U.intTypeTimeOffId = T.intTypeTimeOffId  
  
 GROUP BY       
  E.intEntityId      
    ,T.intTypeTimeOffId       
    ,U.intYear  
) TOYTD       
 ON ETO.intEntityEmployeeId = TOYTD.intEntityId       
 AND ETO.intTypeTimeOffId = TOYTD.intTypeTimeOffId 
GO
