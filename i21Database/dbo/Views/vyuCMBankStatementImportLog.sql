CREATE VIEW vyuCMBankStatementImportLog    
AS    
SELECT A.*, 
B.strName    
FROM tblCMBankStatementImportLog A     
LEFT JOIN     
tblEMEntity B on A.intEntityId = B.intEntityId 