  
CREATE view [dbo].[vyuCMBankStatementImportLogDetail]  
as  
select  
A.intId,  
B.intImportBankStatementLogId,  
A.intLineNo,  
A.strTaskId,  
ysnError = case when strError is null then cast(0 as bit) else cast(1 as bit) end ,  
A.strError,
BS.strBankDescription,
ysnMatched = CASE WHEN ISNULL(BS.intImportStatus,0) = 1 THEN 1 ELSE 0 END,
strTransactionMatched = '' COLLATE Latin1_General_CI_AS
from tblCMBankStatementImportLogDetail A join tblCMBankStatementImportLog B on B.intImportBankStatementLogId = A.intImportBankStatementLogId  
left join  
tblCMBankStatementImport BS on BS.intBankStatementImportId = A.intBankStatementImportId
-- left join tblCMResponsiblePartyTask T on T.intBankStatementImportId = A.intBankStatementImportId
-- outer apply (
--     SELECT strTransactionId,ysnPosted FROM (
--         select ysnPosted, strTransactionId from tblCMBankTransaction UNION ALL
--         select ysnPosted, strTransactionId from tblCMBankTransfer 
--     ) CM
--     WHERE  CM.strTransactionId = T.strTransactionId
-- ) TX
