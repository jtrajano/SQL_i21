CREATE FUNCTION [dbo].[fnGRCreateGLEntriesForPercentDiscounts]
(
	@billIds NVARCHAR(MAX)
	,@ysnPost BIT
	,@intUserId INT
	,@strBatchId NVARCHAR(500)
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
	[intCurrencyExchangeRateTypeId] INT NULL,
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
	[strDocument]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[strComments]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblSourceUnitCredit]		NUMERIC(18, 9)	NULL,
	[dblSourceUnitDebit]		NUMERIC(18, 9)	NULL,
	[intCommodityId]			INT				NULL,
	[intSourceLocationId]		INT				NULL,
	[strSourceDocumentId]       NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN
	
	DECLARE @ids AS TABLE(
		intID int
	)

	INSERT INTO @ids
	SELECT intID 
	FROM [dbo].fnGetRowsFromDelimitedValues(@billIds)

	DECLARE @Bills AS TABLE(
		dblTotal DECIMAL(18,6)
		,dblRate DECIMAL(18,6)
		,intCurrencyExchangeRateTypeId INT
		,strCurrencyExchangeRateType NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,dblUnits DECIMAL(18,6)
		,strComment NVARCHAR(500) COLLATE Latin1_General_CI_AS
		,intBillDetailId INT
		,intAccountId INT
		,strMiscDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS
		,intBillId INT
		,intItemId INT
		,intItemLocationId INT
	)
	
	INSERT INTO @Bills
	SELECT * FROM (
	SELECT 
		(R.dblTotal + IRC.dblAmount) AS dblTotal, 
		R.dblRate AS dblRate, 
		exRates.intCurrencyExchangeRateTypeId, 
		exRates.strCurrencyExchangeRateType,
		dblUnits = R.dblQtyReceived,
		R.strComment,
		R.intBillDetailId,
		R.intAccountId,
		R.strMiscDescription,
		R.intBillId
		,R.intItemId
		,ITEM.intItemLocationId
	FROM dbo.tblAPBillDetail R
	INNER JOIN tblICItem item 
		ON item.intItemId = R.intItemId
	INNER JOIN tblGRSettleStorageBillDetail SBD
		ON SBD.intBillId = R.intBillId
	INNER JOIN tblGRSettleStorageTicket SST
		ON SST.intSettleStorageId = R.intSettleStorageId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = SST.intCustomerStorageId
	INNER JOIN tblQMTicketDiscount TD
		ON TD.intTicketFileId = CS.intCustomerStorageId
			AND TD.strSourceType = 'Storage'
			AND TD.strDiscountChargeType = 'Percent'
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = TD.intDiscountScheduleCodeId
			AND DSC.intItemId = item.intItemId
	INNER JOIN tblICInventoryReceiptCharge IRC
		ON IRC.intInventoryReceiptChargeId = R.intInventoryReceiptChargeId
	LEFT JOIN dbo.tblSMCurrencyExchangeRateType exRates ON R.intCurrencyExchangeRateTypeId = exRates.intCurrencyExchangeRateTypeId
	OUTER APPLY (
		SELECT TOP 1 IL.intItemLocationId
		FROM tblAPBillDetail A
		INNER JOIN tblICItem IC
			ON IC.intItemId = A.intItemId
				AND IC.strType = 'Inventory'
		INNER JOIN tblICItemLocation IL
			ON IL.intItemId = IC.intItemId
				AND IL.intLocationId = A.intLocationId
		WHERE intBillId = R.intBillId			
	) ITEM
	OUTER APPLY (
		SELECT TOP 1 stockUnit.*
		FROM tblICItemUOM stockUnit 
		WHERE 
			item.intItemId = stockUnit.intItemId 
		AND stockUnit.ysnStockUnit = 1
	) itemUOM
	) A WHERE dblTotal <> 0

	INSERT INTO @returntable
	 --AP Account
	 SELECT
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@strBatchId,
		[intAccountId]					=	[dbo].[fnGetItemGLAccount](Details.intItemId,Details.intItemLocationId,'Other Charge Expense'), ----A.intAccountId,
		[dblDebit]						=	CAST(Details.dblTotal AS DECIMAL(18,2)),
		[dblCredit]						=	0,
		[dblDebitUnit]					=	ISNULL(Details.dblUnits,0),--ISNULL(units.dblTotalUnits,0),
		[dblCreditUnit]					=	0,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	Details.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	ISNULL(NULLIF(Details.dblRate,0),1),
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	Details.strMiscDescription,
		[intJournalLineNo]				=	Details.intBillDetailId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	'Bill',
		[strTransactionForm]			=	'Bill',
		[strModuleName]					=	'Accounts Payable',
		[dblDebitForeign]				=	0,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	CAST(Details.dblTotal AS DECIMAL(18,2)),
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]                =   ISNULL(NULLIF(Details.dblRate, 0), 1),--CASE WHEN ForexRateCounter.ysnUniqueForex = 0 THEN ForexRate.dblRate ELSE 0 END,
		[strRateType]                   =   Details.strCurrencyExchangeRateType,
		[strDocument]					=	D.strName + ' - ' + A.strVendorOrderNumber,
		[strComments]					=	D.strName + ' - ' + Details.strComment,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	Details.dblUnits,
		[dblSourceUnitDebit]			=	0,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM tblAPBill A
	LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON D.intEntityId = C.intEntityId)
		ON A.intEntityVendorId = C.[intEntityId]
	OUTER APPLY @Bills Details
	WHERE A.intBillId IN (SELECT intID FROM @ids)
		AND Details.intBillId = A.intBillId
	UNION ALL
	--APC
	SELECT
		[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		[strBatchID]					=	@strBatchId,
		[intAccountId]					=	voucherDetails.intAccountId, --NO NEED TO GET THE ACCOUNT WHEN CREATING GL ENTRIES, ACCOUNT ON TRANSACTION DETAIL SHOULD BE THE ONE TO USE
		[dblDebit]						=	0,
		[dblCredit]						=	voucherDetails.dblTotal, -- Bill
		[dblDebitUnit]					=	0,
		[dblCreditUnit]					=	voucherDetails.dblUnits,
		[strDescription]				=	A.strReference,
		[strCode]						=	'AP',
		[strReference]					=	C.strVendorId,
		[intCurrencyId]					=	A.intCurrencyId,
		[intCurrencyExchangeRateTypeId] =	voucherDetails.intCurrencyExchangeRateTypeId,
		[dblExchangeRate]				=	voucherDetails.dblRate,
		[dtmDateEntered]				=	GETDATE(),
		[dtmTransactionDate]			=	A.dtmDate,
		[strJournalLineDescription]		=	voucherDetails.strMiscDescription,
		[intJournalLineNo]				=	voucherDetails.intBillDetailId,
		[ysnIsUnposted]					=	0,
		[intUserId]						=	@intUserId,
		[intEntityId]					=	@intUserId,
		[strTransactionId]				=	A.strBillId, 
		[intTransactionId]				=	A.intBillId, 
		[strTransactionType]			=	'Bill',
		[strTransactionForm]			=	'Bill',
		[strModuleName]					=	'Accounts Payable',
		[dblDebitForeign]				=	CAST(voucherDetails.dblTotal AS DECIMAL(18,2)),--voucherDetails.dblForeignTotal,      
		[dblDebitReport]				=	0,
		[dblCreditForeign]				=	0,
		[dblCreditReport]				=	0,
		[dblReportingRate]				=	0,
		[dblForeignRate]				=	ISNULL(NULLIF(voucherDetails.dblRate, 0), 1),
		[strRateType]					=	voucherDetails.strCurrencyExchangeRateType,
		[strDocument]					=	A.strVendorOrderNumber,
		[strComments]					=	E.strName,
		[intConcurrencyId]				=	1,
		[dblSourceUnitCredit]			=	0,
		[dblSourceUnitDebit]			=	voucherDetails.dblUnits,
		[intCommodityId]				=	A.intCommodityId,
		[intSourceLocationId]			=	A.intStoreLocationId,
		[strSourceDocumentId]			=	A.strVendorOrderNumber
	FROM tblAPBill A 
	CROSS APPLY @Bills voucherDetails	
	LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)
		ON A.intEntityVendorId = C.[intEntityId]
	WHERE A.intBillId IN (SELECT intID FROM @ids)
		AND voucherDetails.intBillDetailId IS NOT NULL	   
		AND voucherDetails.intBillId = A.intBillId

	UPDATE A
		SET A.strDescription = B.strDescription
	FROM @returntable A
	INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId

	RETURN;

END