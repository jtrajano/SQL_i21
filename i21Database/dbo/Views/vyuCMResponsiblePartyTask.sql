 CREATE VIEW dbo.vyuCMResponsiblePartyTask
 AS
 WITH BT AS(
 SELECT ysnPosted, strTransactionId FROM tblCMBankTransaction union
 select ysnPosted, strTransactionId from tblCMBankTransfer
 )
 SELECT                 
    S.intBankStatementImportId,
    S.strBankStatementImportId,
    T.strNotes,
    S.strReferenceNo,
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
   