CREATE VIEW [dbo].[vyuPREmployeeTimeOffUsedYTD]
AS
SELECT intYear = YEAR(TOR.dtmDateTo)  
  ,TOR.intEntityEmployeeId  
  ,TOR.intTypeTimeOffId  
  ,dblHoursUsed = SUM(dblRequest)
FROM tblPRTimeOffRequest TOR
LEFT JOIN(SELECT intYear = YEAR(PC.dtmPayDate)
		,PC.intEntityEmployeeId  
		,intTypeTimeoffId = PCE.intEmployeeTimeOffId
		,D.dtmPayDate
	FROM tblPRPaycheckEarning PCE   
	INNER JOIN tblPRPaycheck PC
		ON PCE.intPaycheckId = PC.intPaycheckId
	OUTER APPLY(
		SELECT TOP 1 dtmPayDate
		FROM tblPRPaycheck P
		LEFT JOIN(SELECT intPaycheckId
				,intEmployeeTimeOffId
				,dblHours
			FROM tblPRPaycheckEarning
		)E ON P.intPaycheckId = E.intPaycheckId
		WHERE YEAR(dtmPayDate) = YEAR(PC.dtmPayDate)
			AND intEntityEmployeeId = PC.intEntityEmployeeId
			AND E.intEmployeeTimeOffId = PCE.intEmployeeTimeOffId
			AND E.intEmployeeTimeOffId IS NOT NULL  
			AND P.ysnPosted = 1  
			AND P.ysnVoid = 0  
			AND E.dblHours <> 0  
		ORDER BY dtmPayDate DESC
	) D
	WHERE PCE.intEmployeeTimeOffId IS NOT NULL  
		AND PC.ysnPosted = 1  
		AND PC.ysnVoid = 0  
		AND PCE.dblHours <> 0  
	GROUP BY PC.intEntityEmployeeId
		,PCE.intEmployeeTimeOffId
		,YEAR(PC.dtmPayDate)
		,D.dtmPayDate
)PAYCHECK ON TOR.intEntityEmployeeId = PAYCHECK.intEntityEmployeeId
	AND TOR.intTypeTimeOffId = PAYCHECK.intTypeTimeoffId
	AND PAYCHECK.intYear = YEAR(TOR.dtmDateTo)  
WHERE TOR.ysnPostedToCalendar = 1 
	--AND TOR.dtmDateTo <= PAYCHECK.dtmPayDate
GROUP BY YEAR(dtmDateTo)
	,TOR.intEntityEmployeeId
	,TOR.intTypeTimeOffId

GO