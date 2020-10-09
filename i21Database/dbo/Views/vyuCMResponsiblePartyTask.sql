 CREATE VIEW dbo.vyuCMResponsiblePartyTask
 AS
 WITH BT AS(
 SELECT ysnPosted, dblAmount, strTransactionId FROM tblCMBankTransaction union
 select ysnPosted, dblAmount, strTransactionId from tblCMBankTransfer
 )
 SELECT                 
    S.intBankStatementImportId,
    S.strBankStatementImportId,
    T.strNotes,
    BT.dblAmount,
    T.dtmDateCreated,
    E.strName strResponsibleEntity,
	T.strTransactionId strRelatedTransaction,
    T.intEntityId,
    T.intTaskId,
    T.strTaskId,
    T.intConcurrencyId,
    T.ysnStatus,
    BT.ysnPosted
 FROM tblCMResponsiblePartyTask T
 JOIN tblCMBankStatementImport S ON S.intBankStatementImportId = T.intBankStatementImportId
 JOIN tblEMEntity E on E.intEntityId = T.intEntityId
 LEFT JOIN BT on BT.strTransactionId = T.strTransactionId
   