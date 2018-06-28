CREATE FUNCTION [dbo].[fnAPCreateVoucherPrepayGLEntries]
(
	@prepayReversalIds AS Id READONLY,
	@userId INT,
	@batchId NVARCHAR(50)
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
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL DEFAULT 'AP',    
	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]             INT              NULL,
	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
	[dtmDateEntered]            DATETIME         NOT NULL DEFAULT GETDATE(),
	[dtmTransactionDate]        DATETIME         NULL,
	[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL DEFAULT 'Posted Vendor Prepayment',
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL DEFAULT 0,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL DEFAULT 'Vendor Prepayment',
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL DEFAULT 'Bill',
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL DEFAULT 'Accounts Payable',
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

	
	INSERT INTO @returntable (
		[dtmDate]                   ,
		[strBatchId]				,
		[intAccountId]              ,
		[dblDebit]                  ,
		[dblCredit]                 ,
		[dblDebitUnit]              ,
		[dblCreditUnit]             ,
		[strDescription]            ,
		[strReference]              ,
		[intCurrencyId]             ,
		[dblExchangeRate]           ,
		[dtmTransactionDate]        ,
		[intJournalLineNo]			,
		[strJournalLineDescription]	,
		[strTransactionType]		,
		[intUserId]                 ,
		[intEntityId]				,
		[strTransactionId]          ,
		[intTransactionId]          ,
		[dblDebitForeign]           ,
		[dblDebitReport]            ,
		[dblCreditForeign]          ,
		[dblCreditReport]           ,
		[dblReportingRate]          ,
		[dblForeignRate]            ,
		[strRateType]				
	)
	SELECT
		[dtmDate]                   =	DATEADD(dd, DATEDIFF(dd, 0, voucher.dtmDate), 0),
		[strBatchId]				=	@batchId,
		[intAccountId]              =	voucher.intAccountId,
		[dblDebit]                  =	CAST(Details.dblTotal * ISNULL(NULLIF(Details.dblRate,0),1) AS DECIMAL(18,2)),
		[dblCredit]                 =	0,
		[dblDebitUnit]              =	0,
		[dblCreditUnit]             =	0,
		[strDescription]            =	voucher.strReference,
		[strReference]              =	vendor.strVendorId,
		[intCurrencyId]             =	voucher.intCurrencyId,
		[dblExchangeRate]           =	1,
		[dtmTransactionDate]        =	voucher.dtmDate,
		[intJournalLineNo]			=	1,
		[strJournalLineDescription]	=	CASE WHEN voucher.intTransactionType = 1 THEN 'Posted Vendor Prepayment' ELSE 'Posted Basis Advance' END,
		[strTransactionType]		=	CASE WHEN voucher.intTransactionType = 1 THEN 'Vendor Prepayment' ELSE 'Basis Advance' END,
		[intUserId]                 =	@userId,
		[intEntityId]				=	@userId,
		[strTransactionId]          =	voucher.strBillId,
		[intTransactionId]          =	voucher.intBillId,
		[dblDebitForeign]           =	(CASE WHEN ISNULL(NULLIF(Details.dblRate,0),1) != 1 THEN Details.dblTotal ELSE 0 END),
		[dblDebitReport]            =	0,
		[dblCreditForeign]          =	0,
		[dblCreditReport]           =	0,
		[dblReportingRate]          =	0,
		[dblForeignRate]            =	Details.dblRate,
		[strRateType]				=	Details.strCurrencyExchangeRateType
	FROM tblAPBill voucher
	INNER JOIN @prepayReversalIds prepaid ON voucher.intBillId = prepaid.intId
	INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
	OUTER APPLY
	(
		SELECT (voucherDetail.dblTotal + voucherDetail.dblTax) AS dblTotal , voucherDetail.dblRate AS dblRate, currencyExchange.strCurrencyExchangeRateType
		FROM dbo.tblAPBillDetail voucherDetail
		LEFT JOIN tblSMCurrencyExchangeRateType currencyExchange ON voucherDetail.intCurrencyExchangeRateTypeId = currencyExchange.intCurrencyExchangeRateTypeId
		WHERE voucherDetail.intBillId = voucher.intBillId
	) Details
	WHERE voucher.intTransactionType IN (2,12,13)
	UNION ALL
	SELECT
		[dtmDate]                   =	DATEADD(dd, DATEDIFF(dd, 0, voucher.dtmDate), 0),
		[strBatchId]				=	@batchId,
		[intAccountId]              =	Details.intAccountId,
		[dblDebit]                  =	0,
		[dblCredit]                 =	CAST(Details.dblTotal * ISNULL(NULLIF(Details.dblRate,0),1) AS DECIMAL(18,2)),
		[dblDebitUnit]              =	0,
		[dblCreditUnit]             =	0,
		[strDescription]            =	voucher.strReference,
		[strReference]              =	vendor.strVendorId,
		[intCurrencyId]             =	voucher.intCurrencyId,
		[dblExchangeRate]           =	1,
		[dtmTransactionDate]        =	voucher.dtmDate,
		[intJournalLineNo]			=	Details.intBillDetailId,
		[strJournalLineDescription]	=	CASE WHEN voucher.intTransactionType = 1 THEN 'Posted Vendor Prepayment' ELSE 'Posted Basis Advance' END,
		[strTransactionType]		=	CASE WHEN voucher.intTransactionType = 1 THEN 'Vendor Prepayment' ELSE 'Basis Advance' END,
		[intUserId]                 =	@userId,
		[intEntityId]				=	@userId,
		[strTransactionId]          =	voucher.strBillId,
		[intTransactionId]          =	voucher.intBillId,
		[dblDebitForeign]           =	0,
		[dblDebitReport]            =	0,
		[dblCreditForeign]          =	(CASE WHEN ISNULL(NULLIF(Details.dblRate,0),1) != 1 THEN Details.dblTotal ELSE 0 END),
		[dblCreditReport]           =	0,
		[dblReportingRate]          =	0,
		[dblForeignRate]            =	Details.dblRate,
		[strRateType]				=	Details.strCurrencyExchangeRateType
	FROM tblAPBill voucher
	INNER JOIN @prepayReversalIds prepaid ON voucher.intBillId = prepaid.intId
	INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
	OUTER APPLY
	(
		SELECT 
			voucherDetail.intBillDetailId,
			(voucherDetail.dblTotal + voucherDetail.dblTax) AS dblTotal,
			voucherDetail.dblRate AS dblRate, 
			currencyExchange.strCurrencyExchangeRateType, 
			voucherDetail.intAccountId
		FROM dbo.tblAPBillDetail voucherDetail
		LEFT JOIN tblSMCurrencyExchangeRateType currencyExchange ON voucherDetail.intCurrencyExchangeRateTypeId = currencyExchange.intCurrencyExchangeRateTypeId
		WHERE voucherDetail.intBillId = voucher.intBillId
	) Details
	WHERE voucher.intTransactionType IN (2,12,13)

	UPDATE A
		SET A.strDescription = B.strDescription
	FROM @returntable A
	INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId

RETURN;
END
