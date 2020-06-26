CREATE VIEW vyuCMBankStatementImportLog
AS
SELECT A.*,
T.dtmDate,
T.ysnPosted,
T.dblAmount
FROM tblCMBankStatementImportLog A 
LEFT JOIN
(
SELECT strTransactionId,dtmDate, dblAmount, ysnPosted from tblCMBankTransaction UNION ALL
SELECT strTransactionId,dtmDate, dblAmount, ysnPosted from tblCMBankTransfer 
) T
ON T.strTransactionId = A.strTransactionId
