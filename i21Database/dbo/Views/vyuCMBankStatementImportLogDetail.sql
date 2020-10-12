  
CREATE view [dbo].[vyuCMBankStatementImportLogDetail]  
as  
select  
A.intId,  
B.intImportBankStatementLogId,  
A.intLineNo,  
A.strTaskId,  
ysnError = case when strError is null then cast(0 as bit) else cast(1 as bit) end ,  
A.strError,
-- case when strError is null and  BS.intBankStatementImportId is not null and T.intBankStatementImportId is null and TX.strTransactionId is null then  'Imported' 
-- when strError is null and  BS.intBankStatementImportId is not null and T.intBankStatementImportId is not null and TX.strTransactionId is null then  'Task Created'
-- when strError is null and  BS.intBankStatementImportId is not null and T.intBankStatementImportId is not null and TX.strTransactionId is not null and isnull(TX.ysnPosted,0) = 0 then  'Task and Transaction created'
-- when strError is null and  BS.intBankStatementImportId is not null and T.intBankStatementImportId is not null and TX.strTransactionId is not null and isnull(TX.ysnPosted,0) = 1 then  'Task created and Transaction posted'
-- else A.strError
-- end,
BS.strBankDescription  
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
