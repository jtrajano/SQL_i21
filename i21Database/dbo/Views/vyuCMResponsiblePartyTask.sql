CREATE VIEW vyuCMResponsiblePartyTask        
AS        
SELECT         
   S.intBankStatementImportId,        
   S.strBankStatementImportId,        
   S.strBankDescription,        
   S.dblAmount,        
   S.dtmDate,        
   S.strPayee,        
   S.strReferenceNo,        
   S.dtmCreated,        
   T.intResponsibleBankAccountId,        
   E.strName strResponsibleEntity,        
   S.strBankAccountNo strResponsibleBankAccount,        
   T.strTransactionId strRelatedTransaction,        
   S.intBankAccountId,        
   S.strRTN,        
   S.dblDepositAmount,        
   S.dblWithdrawalAmount,        
   S.intImportStatus,        
   S.strDebitCredit,        
   T.intEntityId,        
   T.intTaskId,        
   T.strTaskId,    
   T.intConcurrencyId,      
   BFr.strBankAccountNo strBankAccountFrom,     
   BFr.intBankAccountId intBankAccountFrom,  
   BT.ysnPosted,  
   CASE WHEN UnPostedDetail.Amount = T.dblAmount AND BT.ysnPosted = 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END  ysnStatus
FROM tblCMResponsiblePartyTask T        
JOIN tblCMBankStatementImport S ON S.intBankStatementImportId = T.intBankStatementImportId        
JOIN tblEMEntity E on E.intEntityId = T.intEntityId        
JOIN tblCMBankTransfer BT on BT.strTransactionId = T.strTransactionId      
JOIN vyuCMBankAccount BFr on BT.intBankAccountIdFrom = BFr.intBankAccountId
OUTER APPLY(
	SELECT sum(dblAmount) Amount  FROM vyuCMResponsiblePartyTaskDetail WHERE ysnPosted = 0 AND intTaskId = T.intTaskId
)UnPostedDetail