  
CREATE view [dbo].[vyuCMBankStatementImportLogDetail]    
as    
select     
A.intId,   
B.intImportBankStatementLogId,    
A.intLineNo,  
T.strTaskId,  
ysnError = case when strError is null then cast(0 as bit) else cast(1 as bit) end ,  
strError =  isnull(strError, 'No error'),  
BS.strBankDescription  
from tblCMBankStatementImportLogDetail A join tblCMBankStatementImportLog B on B.intImportBankStatementLogId = A.intImportBankStatementLogId    
left join  
tblCMBankStatementImport BS on BS.intBankStatementImportId = A.intBankStatementImportId  
left join    
tblCMResponsiblePartyTask T on T.intTaskId = A.intResponsiblePartyTaskId    