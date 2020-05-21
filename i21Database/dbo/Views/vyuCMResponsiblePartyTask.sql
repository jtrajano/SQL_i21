CREATE VIEW [dbo].[vyuCMResponsiblePartyTask] 
AS

WITH Transactions AS
(
   SELECT
      strTransactionId,
      intBankStatementImportId 
   FROM
      tblCMBankTransfer 
)
SELECT
   f.intBankStatementImportId,
   f.strBankStatementImportId,
   f.strBankDescription,
   f.dblAmount,
   f.intTaskStatus,
   f.dtmDate,
   CASE
      WHEN
         ISNULL(f.intTaskStatus , 0) = 0 
      THEN
         CAST(0 AS BIT)
      ELSE
         CAST(1 AS BIT)
   END ysnTaskStatus, 
   f.strPayee, 
   f.strReferenceNo, 
   f.dtmCreated, 
   f.intResponsibleBankAccountId, 
   e.strName strResponsibleEntity,
   d.strBankAccountNo  strResponsibleBankAccount,
   t.strTransactionId strRelatedTransaction,
   f.intConcurrencyId
FROM
   tblCMBankStatementImport f 
   JOIN
      vyuCMBankAccount d 
      ON f.intResponsibleBankAccountId = d.intBankAccountId 
   JOIN
      tblEMEntity e 
      ON d.intResponsibleEntityId = e.intEntityId 
    JOIN
      tblCMBankTransfer t 
      ON t.intBankStatementImportId = f.intBankStatementImportId 
WHERE
   f.intTaskStatus IS NULL
GO