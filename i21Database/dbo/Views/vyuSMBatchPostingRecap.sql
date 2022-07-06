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
ISNULL([dblDebitUnit], 0.000000) as dblDebitUnit,
ISNULL([dblCreditUnit], 0.000000) as dblCreditUnit,
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
[strModuleName], 
ISNULL([dblDebitForeign], 0.000000) as dblDebitForeign, 
ISNULL([dblCreditForeign], 0.000000) as dblCreditForeign, 
[strCurrency],
[strCurrencyExchangeRateType]
FROM
(
	SELECT [intGLDetailId], [dtmDate], [strBatchId], [intAccountId], [strAccountId], [strAccountGroup], [dblDebit], [dblCredit], [dblDebitUnit], [dblCreditUnit], GLPR.[strDescription], [strCode], [strReference], [intCurrencyId], [dblExchangeRate], [dtmDateEntered], [dtmTransactionDate], [strJournalLineDescription], [intJournalLineNo], [ysnIsUnposted], [intUserId], [intEntityId], [strTransactionId], [intTransactionId], [strTransactionType], [strTransactionForm], [strModuleName]
	, [dblDebitForeign], [dblCreditForeign]
	, SMCur.strCurrency as strCurrency
	, SMCurExRateType.strCurrencyExchangeRateType as strCurrencyExchangeRateType
	FROM tblGLPostRecap GLPR
	INNER JOIN tblSMCurrency SMCur ON GLPR.intCurrencyId = SMCur.intCurrencyID
	LEFT OUTER JOIN tblSMCurrencyExchangeRateType SMCurExRateType on GLPR.intCurrencyExchangeRateTypeId = SMCurExRateType.intCurrencyExchangeRateTypeId

	UNION ALL
	SELECT A.[intGLDetailId], A.[dtmDate], A.[strBatchId], A.[intAccountId], A.[strTransactionId], C.[strAccountGroup], A.[dblDebit], A.[dblCredit], A.[dblDebitUnit], A.[dblCreditUnit], B.[strDescription], A.[strCode], A.[strReference], A.[intCurrencyId], A.[dblExchangeRate], A.[dtmDateEntered], [dtmTransactionDate], A.[strJournalLineDescription], A.[intJournalLineNo], A.[ysnIsUnposted], A.[intUserId], A.[intEntityId], A.[strTransactionId], A.[intTransactionId], A.[strTransactionType], A.[strTransactionForm], A.[strModuleName]
	, A.[dblDebitForeign], A.[dblCreditForeign], NULL
	, SMCur2.strCurrency as strCurrency
	FROM dbo.tblGLDetailRecap A
	INNER JOIN (SELECT [intAccountId], [intAccountGroupId], [strDescription] FROM dbo.tblGLAccount) B ON A.[intAccountId] = B.[intAccountId]
	INNER JOIN (SELECT [intAccountGroupId], [strAccountGroup] FROM dbo.tblGLAccountGroup) C
		ON B.[intAccountGroupId] = C.[intAccountGroupId]
	INNER JOIN tblSMCurrency SMCur2 ON A.intCurrencyId = SMCur2.intCurrencyID
	WHERE [strModuleName] NOT IN ('PAYROLL')

) BatchPostingRecap