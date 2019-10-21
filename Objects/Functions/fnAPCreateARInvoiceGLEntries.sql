CREATE FUNCTION [dbo].[fnAPCreateARInvoiceGLEntries]
(
	@voucherIds AS	Id READONLY,
	@intUserId		INT,
	@batchId		NVARCHAR(50)
)
RETURNS @returntable TABLE
(
	[dtmDate]                   DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
	[dblDebitUnit]              NUMERIC (18, 6)  NULL,
	[dblCreditUnit]             NUMERIC (18, 6)  NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]             INT              NULL,
	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
	[dtmDateEntered]            DATETIME         NOT NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[dblDebitForeign]           NUMERIC (18, 6)	NULL,
    [dblDebitReport]            NUMERIC (18, 6) NULL,
    [dblCreditForeign]          NUMERIC (18, 6) NULL,
    [dblCreditReport]           NUMERIC (18, 6) NULL,
    [dblReportingRate]          NUMERIC (18, 6) NULL,
    [dblForeignRate]            NUMERIC (18, 6) NULL,
	[strRateType]				NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL
)
AS
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Bill'
	DECLARE @SYSTEM_CURRENCY NVARCHAR(25) = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference)

	INSERT INTO @returntable
	SELECT	
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@batchId,
		[intAccountId]					=	A.intAccountId,
		[dblDebit]						=	0,
		[dblCredit]						=	 
											--Subtract the payment on detail total using percentage
											(CASE WHEN A.intTransactionType IN (2, 3, 11) AND Details.dblTotal > 0 THEN Details.dblTotal * -1 
													 ELSE Details.dblTotal END) - ((ISNULL(A.dblPayment,0) / Details.dblTotal) * Details.dblTotal) * ISNULL(NULLIF(Details.dblRate,0),1),
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[dblExchangeRate]				=	ISNULL(NULLIF(Details.dblRate,0),1),
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	CASE WHEN intTransactionType = 1 THEN 'Posted Bill'
												WHEN intTransactionType = 2 THEN 'Posted Vendor Prepayment'
												WHEN intTransactionType = 3 THEN 'Posted Debit Memo'
											ELSE 'NONE' END,
		[intJournalLineNo]				=	1,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	CASE WHEN intTransactionType = 1 THEN 'Bill'
												WHEN intTransactionType = 2 THEN 'Vendor Prepayment'
												WHEN intTransactionType = 3 THEN 'Debit Memo'
											ELSE 'NONE' END,
		[strTransactionForm]			=	@SCREEN_NAME,
		[strModuleName]					=	@MODULE_NAME,
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	CAST(
											(CASE WHEN A.intTransactionType IN (2, 3, 11) AND Details.dblTotal > 0 THEN Details.dblTotal * -1 
												 ELSE Details.dblTotal END)
											AS DECIMAL(18,2)),
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(Details.dblRate,0),1),
		[strRateType]					=	Details.strCurrencyExchangeRateType,
		[intConcurrencyId]				=	1
	FROM	[dbo].tblAPBill A
			LEFT JOIN tblAPVendor C
				ON A.intEntityVendorId = C.[intEntityId]
			OUTER APPLY
			(
				SELECT (R.dblTotal + R.dblTax) AS dblTotal , R.dblRate  AS dblRate, exRates.intCurrencyExchangeRateTypeId, exRates.strCurrencyExchangeRateType
				FROM dbo.tblAPBillDetail R
				LEFT JOIN dbo.tblSMCurrencyExchangeRateType exRates ON R.intCurrencyExchangeRateTypeId = exRates.intCurrencyExchangeRateTypeId
				WHERE R.intBillId = A.intBillId
			) Details
			
	WHERE	A.intBillId IN (SELECT intId FROM @voucherIds)
	RETURN;
END