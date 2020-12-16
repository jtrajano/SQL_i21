CREATE PROCEDURE [dbo].uspICGetTransactionsLedgerAccounts (@identifier NVARCHAR(100))
AS

SELECT DISTINCT a.strAccountId, LTRIM(RTRIM(a.strDescription)) strAccountDescription
FROM tblGLDetail gl
INNER JOIN tblGLAccount a ON a.intAccountId = gl.intAccountId
INNER JOIN tblICTransactionNodes n ON n.strTransactionNo = gl.strTransactionId
INNER JOIN tblICStagingTransactionNode tn ON tn.strTransactionNo = n.strTransactionNo
	AND tn.strTransactionType = n.strTransactionType
WHERE tn.guiIdentifier = @identifier
	AND gl.ysnIsUnposted = 0

GO