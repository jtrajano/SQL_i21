CREATE VIEW vyuCMBankStatementImportLog
AS
SELECT A.*,
ISNULL(Detail.intErrorCount, 0) intErrorCount,
B.strName
FROM tblCMBankStatementImportLog A
LEFT JOIN
tblEMEntity B on A.intEntityId = B.intEntityId
OUTER APPLY(
    SELECT intErrorCount = COUNT(*) FROM tblCMBankStatementImportLogDetail WHERE ISNULL(strError,'') <> ''
    AND intImportBankStatementLogId = A.intImportBankStatementLogId

)Detail
