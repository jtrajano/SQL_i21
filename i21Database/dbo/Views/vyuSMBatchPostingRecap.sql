CREATE VIEW [dbo].[vyuSMBatchPostingRecap]
AS
SELECT CAST (ROW_NUMBER() OVER (ORDER BY dtmDate DESC) AS INT) AS [intBatchPostingRecapId],
[intGLDetailId],
[dtmDate],
[strBatchId],
[intAccountId],
[strAccountId],
[strAccountGroup],
[dblDebit],
[dblCredit],
[dblDebitUnit],
[dblCreditUnit],
[strDescription],
[strCode],    
[strReference],
[intCurrencyId],
[dblExchangeRate],
[dtmDateEntered],
[dtmTransactionDate],
[strJournalLineDescription],
[intJournalLineNo],
[ysnIsUnposted],    
[intUserId],
[intEntityId],
[strTransactionId],
[intTransactionId],
[strTransactionType],
[strTransactionForm],
[strModuleName]
FROM
(
	SELECT [intGLDetailId], [dtmDate], [strBatchId], [intAccountId], [strAccountId], [strAccountGroup], [dblDebit], [dblCredit], [dblDebitUnit], [dblCreditUnit], [strDescription], [strCode], [strReference], [intCurrencyId], [dblExchangeRate], [dtmDateEntered], [dtmTransactionDate], [strJournalLineDescription], [intJournalLineNo], [ysnIsUnposted], [intUserId], [intEntityId], [strTransactionId], [intTransactionId], [strTransactionType], [strTransactionForm], [strModuleName]
	FROM tblGLPostRecap
) BatchPostingRecap
