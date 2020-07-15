CREATE VIEW [dbo].[vyuFRUserReportRestriction] 
AS

WITH reports AS (
SELECT intEntityId , strReportName, strUserName,intUserRoleID,  intReportId
FROM tblFRReport A , tblSMUserSecurity C 
)
SELECT 
ROW_NUMBER() OVER (ORDER BY A.intReportId asc) rowId,
	A.intReportId,
	R.intRestrictionId,
	R.ysnRestriction,
	A.intEntityId,
	A.strUserName,
    A.strReportName,
    C.strName strRoleName,
    CASE 
        WHEN R.ysnRestriction = 1 THEN 'No Access' 
        WHEN R.ysnRestriction = 0 THEN 'Read-Only' 
        ELSE '' 
    END COLLATE Latin1_General_CI_AS as strRestriction,
	ISNULL(R.intConcurrencyId,0) intConcurrencyId,
	CASE WHEN intRestrictionId IS NOT null THEN CAST( 1 AS BIT) ELSE CAST( 0 AS BIT) END
	ysnRestricted

FROM 
reports A
LEFT JOIN tblFRUserReportRestriction R ON R.intReportId = A.intReportId
AND R.intEntityId = A.intEntityId
LEFT JOIN tblSMUserRole C ON C.intUserRoleID =  A.intUserRoleID
GO

