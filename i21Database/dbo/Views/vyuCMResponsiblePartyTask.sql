 CREATE VIEW dbo.vyuCMResponsiblePartyTask
 AS
  WITH BT AS(
 SELECT ysnPosted, dblAmount, dtmDate, strTransactionId FROM tblCMBankTransaction union
 select ysnPosted, dblAmount, dtmDate, strTransactionId from tblCMBankTransfer
 )
 SELECT                 
    S.intBankStatementImportId,
    S.strBankStatementImportId,
    T.strNotes,
    ISNULL(BT.dblAmount, T.dblAmount) dblAmount,
	BT.dtmDate dtmTransactionDate,
    T.dtmDateCreated,
    E.strName strResponsibleEntity,
	T.strTransactionId strRelatedTransaction,
    T.intEntityId,
    T.intTaskId,
    T.strTaskId,
    T.intConcurrencyId,
    T.ysnStatus,
    T.intResponsibleBankAccountId,
    BA.strBankAccountNo strResponsibleBankAccountNo,
    BT.ysnPosted,
    T.intActionId,
    CASE WHEN T.intActionId = 0  then 'Ignore'
    when T.intActionId = 1 then 'Notify Only' 
    when T.intActionId = 2 then 'Clear Check' 
    when T.intActionId = 3 then 'Bank Transfer'
    when T.intActionId = 4 then 'Bank Deposit' 
    else ''END strActionType

 FROM tblCMResponsiblePartyTask T
 JOIN tblCMBankStatementImport S ON S.intBankStatementImportId = T.intBankStatementImportId
 JOIN tblEMEntity E on E.intEntityId = T.intEntityId
 LEFT JOIN BT on BT.strTransactionId = T.strTransactionId
 LEFT JOIN vyuCMBankAccount BA on BA.intBankAccountId = T.intResponsibleBankAccountId

 

   