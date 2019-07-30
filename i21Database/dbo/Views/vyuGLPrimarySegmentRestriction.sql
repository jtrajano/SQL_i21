CREATE VIEW vyuGLPrimarySegmentRestriction
AS
WITH segmentUser as(
SELECT  
S.strCode,
SM.intEntityId,
SM.strUserName,
SM.intUserRoleID
FROM vyuGLSegmentDetail S,
tblSMUserSecurity SM
WHERE strType = 'Primary'
)
SELECT 
ROW_NUMBER() OVER (ORDER BY S.intEntityId, S.strCode asc) rowId,
S.strCode,
S.intEntityId,
S.strUserName,
C.strName strRoleName,
PS.intRestrictionId ,
CASE WHEN PS.intRestrictionId IS NULL THEN cast( 0 AS BIT) ELSE CAST( 1 as BIT) END ysnRestricted,
isnull(PS.intConcurrencyId,0) intConcurrencyId
FROM segmentUser S
LEFT JOIN tblSMUserRole C ON C.intUserRoleID =  S.intUserRoleID
LEFT JOIN
tblGLPrimarySegmentRestriction PS
ON PS.intEntityId = S.intEntityId AND PS.strCode = S.strCode