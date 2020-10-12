  
CREATE view [dbo].[vyuCMBankStatementImportLogDetail]  
as  
select  
A.intId,  
B.intImportBankStatementLogId,  
A.intLineNo,  
A.strTaskId,  
ysnError = case when strError is null then cast(0 as bit) else cast(1 as bit) end ,  
strError =  
case when strError is null and  BS.intBankStatementImportId is not null and T.intBankStatementImportId is null then  'Imported' 
when strError is null and  BS.intBankStatementImportId is not null and T.intBankStatementImportId is not null then  'Task Created'
else A.strError
end,
BS.strBankDescription  
from tblCMBankStatementImportLogDetail A join tblCMBankStatementImportLog B on B.intImportBankStatementLogId = A.intImportBankStatementLogId  
left join  
tblCMBankStatementImport BS on BS.intBankStatementImportId = A.intBankStatementImportId
left join tblCMResponsiblePartyTask T on T.intBankStatementImportId = A.intBankStatementImportId