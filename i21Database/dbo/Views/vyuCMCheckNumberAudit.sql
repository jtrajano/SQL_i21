CREATE VIEW vyuCMCheckNumberAudit  
AS  
SELECT 
ROW_NUMBER() OVER( PARTITION BY intBankAccountId ORDER BY strCheckNo )rowId 
, *  
from tblCMCheckNumberAudit