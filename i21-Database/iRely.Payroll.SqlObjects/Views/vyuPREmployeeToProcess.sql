CREATE VIEW [dbo].[vyuPREmployeeToProcess]
AS
SELECT
	ETP.intEntityEmployeeId,
	ETP.strEmployeeId,
	ETP.strFirstName,
	ETP.strLastName,
	ETP.intBankAccountId,
	ETP.dtmBeginDate,
	ETP.dtmEndDate,
	ETP.dtmPayDate,
	ETP.ysnExcludeDeductions,
	intPayGroupIds = LEFT(ETP.intPayGroupIds, LEN(ETP.intPayGroupIds)-1),
	strPayGroupIds = LEFT(ETP.strPayGroupIds, LEN(ETP.strPayGroupIds)-1),
	ETP.dblHours,
	ETP.dblTotal,
	ETP.intConcurrencyId
FROM
    (
        SELECT DISTINCT 
			PGD.intEntityEmployeeId,
			EMP.strEmployeeId,
			EMP.strFirstName,
			EMP.strLastName,
			PG2.intBankAccountId, 
			PG2.dtmPayDate,
			PG2.dtmBeginDate,
			PG2.dtmEndDate,
			PG2.ysnExcludeDeductions,
			intPayGroupIds = (
                SELECT 
					CONVERT(NVARCHAR(8), PG1.intPayGroupId) + ', ' AS [text()]
                FROM tblPRPayGroup PG1
                WHERE PG1.intBankAccountId = PG2.intBankAccountId
					AND PG1.dtmPayDate = PG2.dtmPayDate
					AND PG1.dtmBeginDate = PG2.dtmBeginDate
					AND PG1.dtmEndDate = PG2.dtmEndDate
                ORDER BY PG1.intPayGroupId
                FOR XML PATH ('')
            ),
            strPayGroupIds = (
                SELECT 
					PG1.strPayGroup + ', ' AS [text()]
                FROM tblPRPayGroup PG1
                WHERE PG1.intBankAccountId = PG2.intBankAccountId
					AND PG1.dtmPayDate = PG2.dtmPayDate
					AND PG1.dtmBeginDate = PG2.dtmBeginDate
					AND PG1.dtmEndDate = PG2.dtmEndDate
                ORDER BY PG1.intPayGroupId
                FOR XML PATH ('')
            ),
			dblHours = SUM(PGD.dblHoursToProcess),
			dblTotal = SUM(PGD.dblTotal),
			EMP.intConcurrencyId
        FROM 
			tblPRPayGroup PG2
			INNER JOIN tblPRPayGroupDetail PGD
				ON PG2.intPayGroupId = PGD.intPayGroupId
			INNER JOIN tblPREmployee EMP
				ON PGD.intEntityEmployeeId = EMP.[intEntityId]
		WHERE
			EMP.ysnActive = 1
		GROUP BY
			PGD.intEntityEmployeeId,
			EMP.strEmployeeId,
			EMP.strFirstName,
			EMP.strLastName,
			PG2.intBankAccountId, 
			PG2.dtmPayDate,
			PG2.dtmBeginDate,
			PG2.dtmEndDate,
			PG2.ysnExcludeDeductions,
			EMP.intConcurrencyId
    ) ETP
WHERE 
	ETP.intEntityEmployeeId IS NOT NULL
	AND ETP.intBankAccountId IS NOT NULL
	AND ETP.dtmBeginDate IS NOT NULL
	AND ETP.dtmEndDate IS NOT NULL
	AND ETP.dtmPayDate IS NOT NULL
	AND ETP.dblTotal > 0