CREATE PROCEDURE [dbo].[uspPRPopulateEmployeeChangeLog]
AS
BEGIN

/* Placeholder for extracted Audit Log entries*/
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpExtractedAuditLog')) DROP TABLE #tmpExtractedAuditLog
CREATE TABLE #tmpExtractedAuditLog (
		intExtractedAuditLogId INT IDENTITY (1, 1)
		,intAuditLogId	INT
		,strJsonString	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	)

/* Temp Table for Employees Audit Log */
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAuditLog')) DROP TABLE #tmpAuditLog
SELECT
	intAuditLogId
	,AUD.intEntityId
	,dtmDate
	,strJsonData = strJsonData COLLATE Latin1_General_CI_AS
INTO #tmpAuditLog
FROM
	tblSMAuditLog AUD
	INNER JOIN tblEMEntity EM
		ON EM.intEntityId = CAST(AUD.strRecordNo AS INT)
WHERE strActionType = 'Updated'
	AND strTransactionType = 'Payroll.view.EntityEmployee'
	AND EM.intEntityId IN (SELECT intEntityId FROM tblPREmployee)
	AND PATINDEX('%"changeDescription":%', strJsonData) > 0
	AND (PATINDEX('%"hidden":true%', strJsonData) > 0 
		OR PATINDEX('%"hidden":false%', strJsonData) > 0)
	AND (PATINDEX('%"change":"str%","from":%', strJsonData) > 0
		OR PATINDEX('%"change":"dbl%","from":%', strJsonData) > 0
		OR PATINDEX('%"change":"int%","from":%', strJsonData) > 0
		OR PATINDEX('%"change":"dtm%","from":%', strJsonData) > 0
		OR PATINDEX('%"change":"ysn%","from":%', strJsonData) > 0)

/* Loop each Audit Log entry to extract field changes */
DECLARE @intAuditLogId INT
DECLARE @intInsertedId INT

WHILE EXISTS (SELECT TOP 1 1 FROM #tmpAuditLog)
BEGIN
	SELECT TOP 1 @intAuditLogId = intAuditLogId FROM #tmpAuditLog

	/* Loop each data to extract child field changes */
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpAuditLog WHERE intAuditLogId = @intAuditLogId
					AND PATINDEX('%,"hidden":false%', strJsonData) > 0
					AND (PATINDEX('%"change":"str%","from":%', strJsonData) > 0
						OR PATINDEX('%"change":"dbl%","from":%', strJsonData) > 0
						OR PATINDEX('%"change":"int%","from":%', strJsonData) > 0
						OR PATINDEX('%"change":"dtm%","from":%', strJsonData) > 0
						OR PATINDEX('%"change":"ysn%","from":%', strJsonData) > 0))
			BEGIN
				/* Remove hidden fields */
				WHILE EXISTS(SELECT TOP 1 1 FROM #tmpAuditLog 
							WHERE intAuditLogId = @intAuditLogId AND PATINDEX('%,"hidden":true%', strJsonData) > 0
							AND PATINDEX('%,"hidden":false%', SUBSTRING(strJsonData, 0, PATINDEX('%,"hidden":true%', strJsonData))) = 0)
				BEGIN
					UPDATE #tmpAuditLog
						SET strJsonData = SUBSTRING(strJsonData, PATINDEX('%,"hidden":true%', strJsonData) + 14, LEN(strJsonData))
					WHERE intAuditLogId = @intAuditLogId
				END

				/* Insert extracted change log to temporary table */
				INSERT INTO #tmpExtractedAuditLog
					(intAuditLogId
					,strJsonString)
				SELECT
					intAuditLogId
					,strJsonData = CASE 
							WHEN (PATINDEX('%"change":"dbl%","from":%', strJsonData) > 0) THEN
								SUBSTRING(strJsonData, PATINDEX('%"change":"dbl%","from":%', strJsonData), PATINDEX('%,"hidden":false%', strJsonData) - PATINDEX('%"change":"dbl%', strJsonData) + 15)
							WHEN (PATINDEX('%"change":"int%","from":%', strJsonData) > 0) THEN
								SUBSTRING(strJsonData, PATINDEX('%"change":"int%","from":%', strJsonData), PATINDEX('%,"hidden":false%', strJsonData) - PATINDEX('%"change":"int%', strJsonData) + 15)
							WHEN (PATINDEX('%"change":"dtm%","from":%', strJsonData) > 0) THEN
								SUBSTRING(strJsonData, PATINDEX('%"change":"dtm%","from":%', strJsonData), PATINDEX('%,"hidden":false%', strJsonData) - PATINDEX('%"change":"dtm%', strJsonData) + 15)
							WHEN (PATINDEX('%"change":"ysn%","from":%', strJsonData) > 0) THEN
								SUBSTRING(strJsonData, PATINDEX('%"change":"ysn%","from":%', strJsonData), PATINDEX('%,"hidden":false%', strJsonData) - PATINDEX('%"change":"ysn%', strJsonData) + 15)
							WHEN (PATINDEX('%"change":"str%","from":%', strJsonData) > 0) THEN
								SUBSTRING(strJsonData, PATINDEX('%"change":"str%","from":%', strJsonData), PATINDEX('%,"hidden":false%', strJsonData) - PATINDEX('%"change":"str%', strJsonData) + 15)
							ELSE '' END
				FROM #tmpAuditLog WHERE intAuditLogId = @intAuditLogId
					AND (PATINDEX('%"change":"str%","from":%', strJsonData) > 0
						OR PATINDEX('%"change":"dbl%","from":%', strJsonData) > 0
						OR PATINDEX('%"change":"int%","from":%', strJsonData) > 0
						OR PATINDEX('%"change":"dtm%","from":%', strJsonData) > 0
						OR PATINDEX('%"change":"ysn%","from":%', strJsonData) > 0)

				SET @intInsertedId = SCOPE_IDENTITY()

				/* Cut off part of the jsonString extracted */
				IF (@intInsertedId IS NOT NULL)
					UPDATE #tmpAuditLog
						SET strJsonData = REPLACE(strJsonData, EAL.strJsonString, '')
					FROM #tmpAuditLog AL
						LEFT JOIN #tmpExtractedAuditLog EAL
						ON EAL.intAuditLogId = AL.intAuditLogId
					WHERE AL.intAuditLogId = @intAuditLogId
					AND EAL.intExtractedAuditLogId = @intInsertedId
				ELSE
					DELETE FROM #tmpAuditLog WHERE intAuditLogId = @intAuditLogId

				/* If delete entry if no more unhidden fields */
				DELETE FROM #tmpAuditLog WHERE intAuditLogId = @intAuditLogId 
					AND PATINDEX('%,"hidden":false%', strJsonData) = 0
			END

	/* Loop control */
	DELETE FROM #tmpAuditLog WHERE intAuditLogId = @intAuditLogId
END

/*Clear and Update Employee Change Log data */
DELETE FROM tblPREmployeeChangeLog
INSERT INTO tblPREmployeeChangeLog (
	intAuditLogId
	,intEntityEmployeeId
	,strEntityNo
	,strName
	,intEntityChangedId
	,strChangedBy
	,dtmChangedOn
	,strTableName
	,strFieldName
	,strKeyValue
	,strFrom
	,strTo)
SELECT
	intAuditLogId
	,intEntityEmployeeId
	,strEntityNo
	,strName
	,intEntityChangedId
	,strChangedBy
	,dtmChangedOn
	,strTableName = CASE WHEN (strTableName <> '') THEN
						RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
						(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
						SUBSTRING(strTableName, 6, 100) COLLATE Latin1_General_CS_AI, 
						'A',' A'),'B',' B'),'C',' C'),'D', ' D'),'E',' E'), 'F',' F'), 'G',' G'),'H',' H'),'I',' I'),'J',' J'),'K',' K'),'L', ' L'),'M',' M'), 
						'N',' N'),'O',' O'),'P',' P'),'Q',' Q'),'R',' R'),'S',' S'),'T', ' T'),'U',' U'), 'V',' V'), 'W',' W'),'X',' X'),'Y',' Y'),'Z',' Z')))
					ELSE
						'Employee'
					END
	,strFieldName
	,strKeyValue = CASE WHEN (strTableName = 'tblPREmployeeTaxes') THEN 
							ISNULL((SELECT strTax FROM tblPRTypeTax WHERE intTypeTaxId = (SELECT intTypeTaxId FROM tblPREmployeeTax WHERE intEmployeeTaxId = CAST(strKeyValue AS INT))), '')
					    WHEN (strTableName = 'tblPREmployeeEarnings') THEN 
							ISNULL((SELECT strEarning FROM tblPRTypeEarning WHERE intTypeEarningId = (SELECT intTypeEarningId FROM tblPREmployeeEarning WHERE intEmployeeEarningId = CAST(strKeyValue AS INT))), '')
						WHEN (strTableName = 'tblPREmployeeDeductions') THEN 
							ISNULL((SELECT strDeduction FROM tblPRTypeDeduction WHERE intTypeDeductionId = (SELECT intTypeDeductionId FROM tblPREmployeeDeduction WHERE intEmployeeDeductionId = CAST(strKeyValue AS INT))), '')
						WHEN (strTableName = 'tblPREmployeeTimeOffs') THEN 
							ISNULL((SELECT strTimeOff FROM tblPRTypeTimeOff WHERE intTypeTimeOffId = (SELECT intTypeTimeOffId FROM tblPREmployeeTimeOff WHERE intEmployeeTimeOffId = CAST(strKeyValue AS INT))), '')
						ELSE '' END
	,strFrom = CASE WHEN (strFrom = 'null') THEN '(empty)' 
					WHEN (strDataType = 'Boolean') THEN
						CASE WHEN (strFrom = 'true') THEN 'Yes' ELSE 'No' END
					WHEN (strDataType = 'DateTime') THEN 
						CONVERT(NVARCHAR(30), CAST(SUBSTRING(strFrom, 5, 12) AS DATETIME),101)
					ELSE strFrom END
	,strTo = CASE WHEN (strTo = 'null') THEN '(empty)' 
					WHEN (strDataType = 'Boolean') THEN
						CASE WHEN (strTo = 'true') THEN 'Yes' ELSE 'No' END
					WHEN (strDataType = 'DateTime') THEN 
						CONVERT(NVARCHAR(30), CAST(SUBSTRING(strTo, 5, 12) AS DATETIME),101)
					ELSE strTo END
FROM
	(SELECT 
		intAuditLogId = AUD.intAuditLogId
		,intEntityEmployeeId = EM.intEntityId
		,strEntityNo = EM.strEntityNo
		,strName = EM.strName
		,intEntityChangedId = AUD.intEntityId
		,strChangedBy = CASE WHEN (SEC.strFullName = '') THEN strUserName ELSE SEC.strFullName END
		,dtmChangedOn = AUD.dtmDate
		,strDataType = CASE WHEN (PATINDEX('%"change":"dbl%","from":%', strJsonData) > 0) THEN 'Numeric'
							WHEN (PATINDEX('%"change":"int%","from":%', strJsonData) > 0) THEN 'Integer'
							WHEN (PATINDEX('%"change":"dtm%","from":%', strJsonData) > 0) THEN 'DateTime'
							WHEN (PATINDEX('%"change":"ysn%","from":%', strJsonData) > 0) THEN 'Boolean'
							WHEN (PATINDEX('%"change":"str%","from":%', strJsonData) > 0) THEN 'String'
							ELSE '' END
		,strTableName = CASE WHEN (PATINDEX('%"associationKey":%', strJsonString) > 0) THEN
							REPLACE(SUBSTRING(strJsonString, PATINDEX('%"associationKey":%', strJsonString) + 17, PATINDEX('%,"changeDescription":%', strJsonString) - PATINDEX('%"associationKey":%', strJsonString) - 17), '"', '')
						ELSE '' END
		,strFieldName = CASE WHEN (PATINDEX('%"changeDescription":%', strJsonString) > 0) THEN
							REPLACE(SUBSTRING(strJsonString, PATINDEX('%"changeDescription":%', strJsonString) + 20, PATINDEX('%,"hidden":false%', strJsonString) - PATINDEX('%"changeDescription":%', strJsonString) - 20), '"', '')
						ELSE '' END
		,strKeyValue = CASE WHEN (PATINDEX('%"keyValue":%', strJsonString) > 0) THEN
							REPLACE(SUBSTRING(strJsonString, PATINDEX('%"keyValue":%', strJsonString) + 11, PATINDEX('%,"associationKey":%', strJsonString) - PATINDEX('%"keyValue":%', strJsonString) - 11), '"', '')
						ELSE '' END	
		,strFrom = CASE WHEN (PATINDEX('%","from":%', strJsonString) > 0) THEN
							REPLACE(SUBSTRING(strJsonString, PATINDEX('%","from":%', strJsonString) + 9, PATINDEX('%,"to":%', strJsonString) - PATINDEX('%","from":%', strJsonString) - 9), '"', '')
						ELSE '' END			
		,strTo = CASE WHEN (PATINDEX('%,"to":%', strJsonString) > 0) THEN
							REPLACE(SUBSTRING(strJsonString, PATINDEX('%,"to":%', strJsonString) + 6, PATINDEX('%,"leaf"%', strJsonString) - PATINDEX('%,"to":%', strJsonString) - 6), '"', '')
						ELSE '' END	
	FROM
		tblSMAuditLog AUD
		INNER JOIN tblEMEntity EM
			ON EM.intEntityId = CAST(AUD.strRecordNo AS INT)
		LEFT JOIN tblSMUserSecurity SEC
			ON AUD.intEntityId = SEC.intEntityId
		INNER JOIN #tmpExtractedAuditLog EAL
			ON EAL.intAuditLogId = AUD.intAuditLogId
	WHERE 
		PATINDEX('%"change":"strOriRowState","from":%', strJsonString) <= 0
		AND PATINDEX('%,"to":%', strJsonString) - PATINDEX('%","from"%', strJsonString) > 0
		AND REPLACE(SUBSTRING(strJsonString, PATINDEX('%","from":%', strJsonString) + 9, PATINDEX('%,"to":%', strJsonString) - PATINDEX('%","from":%', strJsonString) - 9), '"', '') <> ''
		AND REPLACE(SUBSTRING(strJsonString, PATINDEX('%,"to":%', strJsonString) + 6, PATINDEX('%,"leaf"%', strJsonString) - PATINDEX('%,"to":%', strJsonString) - 6), '"', '') <> ''
		AND PATINDEX('%,"hidden":true%', strJsonString) = 0
	) EC
ORDER BY 
	dtmChangedOn DESC

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAuditLog')) DROP TABLE #tmpAuditLog
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpExtractedAuditLog')) DROP TABLE #tmpExtractedAuditLog

END