CREATE VIEW [dbo].[vyuCMBankStatementImportLog]
AS
SELECT A.*,
B.strName
FROM tblCMBankStatementImportLog A 
LEFT JOIN 
tblEMEntity B on A.intEntityId = A.intEntityId

