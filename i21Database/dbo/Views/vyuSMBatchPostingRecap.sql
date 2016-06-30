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
	UNION ALL
	SELECT A.[intGLDetailId], A.[dtmDate], A.[strBatchId], A.[intAccountId], A.[strTransactionId], C.[strAccountGroup], A.[dblDebit], A.[dblCredit], A.[dblDebitUnit], A.[dblCreditUnit], B.[strDescription], A.[strCode], A.[strReference], A.[intCurrencyId], A.[dblExchangeRate], A.[dtmDateEntered], [dtmTransactionDate], A.[strJournalLineDescription], A.[intJournalLineNo], A.[ysnIsUnposted], A.[intUserId], A.[intEntityId], A.[strTransactionId], A.[intTransactionId], A.[strTransactionType], A.[strTransactionForm], A.[strModuleName]
	FROM dbo.tblGLDetailRecap A
	INNER JOIN (SELECT [intAccountId], [intAccountGroupId], [strDescription] FROM dbo.tblGLAccount) B ON A.[intAccountId] = B.[intAccountId]
	INNER JOIN (SELECT [intAccountGroupId], [strAccountGroup] FROM dbo.tblGLAccountGroup) C
		ON B.[intAccountGroupId] = C.[intAccountGroupId]
) BatchPostingRecap