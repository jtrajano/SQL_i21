CREATE VIEW vyuCMResponsiblePartyTask
AS
SELECT 
   S.intBankStatementImportId,
   S.strBankStatementImportId,
   S.strBankDescription,
   S.dblAmount,
   S.dtmDate,
   T.ysnStatus,
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
   T.intConcurrencyId
FROM tblCMResponsiblePartyTask T
JOIN tblCMBankStatementImport S ON S.intBankStatementImportId = T.intBankStatementImportId
JOIN tblEMEntity E on E.intEntityId = T.intEntityId
