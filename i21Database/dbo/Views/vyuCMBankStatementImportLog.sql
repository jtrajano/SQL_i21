CREATE VIEW vyuCMBankStatementImportLog
AS
SELECT A.*,
Detail.intErrorCount,
B.strName
FROM tblCMBankStatementImportLog A
LEFT JOIN
tblEMEntity B on A.intEntityId = B.intEntityId
OUTER APPLY(
    SELECT intErrorCount = COUNT(*) FROM tblCMBankStatementImportLogDetail WHERE ISNULL(strError,'') <> ''

)Detail