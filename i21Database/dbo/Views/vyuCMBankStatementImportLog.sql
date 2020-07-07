CREATE VIEW vyuCMBankStatementImportLog
AS
SELECT A.*,
ysnSuccess = CASE WHEN CHARINDEX('success', A.strDescription) > 0 THEN  cast( 1 as bit) ELSE cast( 0 as bit) END,
B.strName
FROM tblCMBankStatementImportLog A 
LEFT JOIN 
tblEMEntity B on A.intEntityId = B.intEntityId

