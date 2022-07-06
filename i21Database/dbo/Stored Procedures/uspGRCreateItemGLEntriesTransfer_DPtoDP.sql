CREATE PROCEDURE [dbo].[uspGRCreateItemGLEntriesTransfer_DPtoDP]
	@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@intTransactionDetailId INT
	,@ysnTransferStorage INT = 0
	,@intSourceTransactionDetailId INT = NULL
	,@ysnUnpost BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
DECLARE @strTransactionForm NVARCHAR(255)
DECLARE @strBatchId2 AS NVARCHAR(40)

-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Grain';

-- Get the GL Account ids to use
DECLARE @GLAccounts AS dbo.ItemGLAccount; 
INSERT INTO @GLAccounts (
	intItemId 
	,intItemLocationId 
	,intInventoryId
	,intContraInventoryId --AP Clearing account only
	,intTransactionTypeId
)
SELECT	
	Query.intItemId
	,Query.intItemLocationId_TO
	,intInventoryId			= dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId_FROM, 'AP Clearing') --Source APC
	,intContraInventoryId	= dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId_TO, 'AP Clearing') --New APC
	,56
FROM (
	SELECT DISTINCT 
		CS_FROM.intItemId
		,intItemLocationId_TO	= IL_TO.intItemLocationId
		,intItemLocationId_FROM = IL_FROM.intItemLocationId
		,intTransactionTypeId = 56
	FROM tblGRTransferStorageReference TSR
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblICItemLocation IL_TO
		ON IL_TO.intItemId = CS_TO.intItemId
			AND IL_TO.intLocationId = CS_TO.intCompanyLocationId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblICItemLocation IL_FROM
		ON IL_FROM.intItemId = CS_FROM.intItemId
			AND IL_FROM.intLocationId = CS_FROM.intCompanyLocationId
	WHERE TSR.intTransferStorageReferenceId = @intTransactionDetailId
) Query

-- Validate the GL Accounts
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT 
DECLARE @strLocationName AS NVARCHAR(50)

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END

IF NOT EXISTS(SELECT 1 FROM tblGRTransferGLEntriesCTE WHERE intTransactionDetailId = @intTransactionDetailId) AND @ysnUnpost = 0
BEGIN
	INSERT INTO tblGRTransferGLEntriesCTE
	(
		dtmDate
		,intItemId
		,intItemLocationId
		,intSourceTransactionId
		,intSourceTransactionDetailId
		,strSourceTransactionId
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,dblQty
		,dblUOMQty
		,dblCost
		,dblValue
		,intCurrencyId
		,strItemNo
		,strRateType
		,strTransactionType
		,strBatchId
		,strCheck
	)
	/*==DELIVERY SHEET ONLY==*/
	--DP to DP transfer
	--needs to have AP clearing to offset in IR and new AP clearing for TRA
	--IR side
	SELECT	
		TSR.dtmProcessDate
		,IRI.intItemId
		,il.intItemLocationId
		,TS.intTransferStorageId
		,@intTransactionDetailId
		,TS.strTransferStorageTicket
		,SIR.intInventoryReceiptId
		,SIR.intInventoryReceiptItemId
		,IR.strReceiptNumber
		,ROUND(SIR.dblNetUnits,2)
		,UOM.dblUnitQty
		,CS_FROM.dblBasis + CS_FROM.dblSettlementPrice
		,SIR.dblUnits * (CS_FROM.dblBasis + CS_FROM.dblSettlementPrice)
		,CS_FROM.intCurrencyId
		,IC.strItemNo
		,strRateType = currencyRateType.strCurrencyExchangeRateType
		,strTransactionType = 'Source'
		,@strBatchId
		,'1'
	FROM tblGRStorageInventoryReceipt SIR
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId
	INNER JOIN tblGRTransferStorage TS
		ON TS.intTransferStorageId = TSR.intTransferStorageId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS_FROM.ysnTransferStorage = 0
	INNER JOIN tblICInventoryReceipt IR
		ON IR.intInventoryReceiptId = SIR.intInventoryReceiptId
	INNER JOIN tblICInventoryReceiptItem IRI
		ON IRI.intInventoryReceiptItemId = SIR.intInventoryReceiptItemId
	INNER JOIN tblICItem IC
		ON IC.intItemId = IRI.intItemId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemId = IC.intItemId
			AND UOM.ysnStockUnit = 1
	INNER JOIN tblICItemLocation il
		ON il.intItemId = IC.intItemId
			AND il.intLocationId = IR.intLocationId
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = IRI.intForexRateTypeId
	WHERE SIR.intTransferStorageReferenceId = @intTransactionDetailId

	UNION ALL

	--TRA side
	--ORIGINAL STORAGE: DP DS
	SELECT	
		TSR.dtmProcessDate
		,IRI.intItemId
		,il.intItemLocationId
		,TS.intTransferStorageId
		,@intTransactionDetailId
		,TS.strTransferStorageTicket
		,TS.intTransferStorageId
		,TSR.intTransferStorageReferenceId
		,TS.strTransferStorageTicket
		,ROUND(SIR.dblNetUnits,2)
		,UOM.dblUnitQty
		,CS_FROM.dblBasis + CS_FROM.dblSettlementPrice
		,SIR.dblUnits * (CS_FROM.dblBasis + CS_FROM.dblSettlementPrice)
		,CS_FROM.intCurrencyId
		,IC.strItemNo
		,strRateType = currencyRateType.strCurrencyExchangeRateType
		,strTransactionType = 'To'
		,@strBatchId
		,'2'
	FROM tblGRStorageInventoryReceipt SIR
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId
	INNER JOIN tblGRTransferStorage TS
		ON TS.intTransferStorageId = TSR.intTransferStorageId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS_FROM.ysnTransferStorage = 0
	INNER JOIN tblICInventoryReceipt IR
		ON IR.intInventoryReceiptId = SIR.intInventoryReceiptId
	INNER JOIN tblICInventoryReceiptItem IRI
		ON IRI.intInventoryReceiptItemId = SIR.intInventoryReceiptItemId
	INNER JOIN tblICItem IC
		ON IC.intItemId = IRI.intItemId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemId = IC.intItemId
			AND UOM.ysnStockUnit = 1
	INNER JOIN tblICItemLocation il
		ON il.intItemId = IC.intItemId
			AND il.intLocationId = IR.intLocationId
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = IRI.intForexRateTypeId
	WHERE SIR.intTransferStorageReferenceId = @intTransactionDetailId	

	UNION ALL
	/*START HERE: for DS and SC*/
	--ORIGINAL STORAGE: OS DS (DP transfer to DP)
	--APC is in TRA
	SELECT	
		TSR.dtmProcessDate
		,t.intItemId
		,t.intItemLocationId
		,TRA.intTransferStorageId
		,@intTransactionDetailId
		,TRA.strTransferStorageTicket
		,t.intTransactionId
		,t.intTransactionDetailId
		,t.strTransactionId
		,TRA.dblUnitQty
		,t.dblUOMQty
		,t.dblCost
		,dblValue	= TRA.dblUnitQty * t.dblCost
		,ISNULL(t.intCurrencyId, @DefaultCurrencyId) intCurrencyId
		,i.strItemNo
		,strRateType = currencyRateType.strCurrencyExchangeRateType
		,strTransactionType = 'Source'
		,@strBatchId
		,'3'
	FROM tblICInventoryTransaction t
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intTransferStorageReferenceId = t.intTransactionDetailId
	INNER JOIN tblGRTransferStorage TS
		ON TS.intTransferStorageId = TSR.intTransferStorageId
			AND TS.strTransferStorageTicket = t.strTransactionId
	INNER JOIN dbo.tblICInventoryTransactionType TransType
		ON t.intTransactionTypeId = TransType.intTransactionTypeId
	INNER JOIN tblICItem i
		ON i.intItemId = t.intItemId
	OUTER APPLY (
		SELECT B.dblUnitQty, B.intTransferStorageId,C.strTransferStorageTicket
		FROM tblGRTransferStorageReference B
		INNER JOIN tblGRTransferStorage C
			ON C.intTransferStorageId = B.intTransferStorageId
		WHERE B.intTransferStorageReferenceId = @intTransactionDetailId
	) TRA
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
	WHERE t.intTransactionDetailId = @intSourceTransactionDetailId

	UNION ALL

	SELECT	
		TSR.dtmProcessDate
		,t.intItemId
		,TRA.intItemLocationId
		,TRA.intTransferStorageId
		,@intTransactionDetailId
		,TRA.strTransferStorageTicket
		,TRA.intTransferStorageId
		,@intTransactionDetailId
		,TRA.strTransferStorageTicket
		,TRA.dblUnitQty
		,t.dblUOMQty
		,t.dblCost
		,dblValue	= TRA.dblUnitQty * t.dblCost
		,ISNULL(t.intCurrencyId, @DefaultCurrencyId) intCurrencyId
		,i.strItemNo
		,strRateType = currencyRateType.strCurrencyExchangeRateType
		,strTransactionType = 'To'
		,@strBatchId
		,'4'
	FROM tblICInventoryTransaction t
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intTransferStorageReferenceId = t.intTransactionDetailId
	INNER JOIN tblGRTransferStorage TS
		ON TS.intTransferStorageId = TSR.intTransferStorageId
			AND TS.strTransferStorageTicket = t.strTransactionId
	INNER JOIN dbo.tblICInventoryTransactionType TransType
		ON t.intTransactionTypeId = TransType.intTransactionTypeId
	OUTER APPLY (
		SELECT A.intTransferStorageId
			,A.strTransferStorageTicket
			,B.dblUnitQty
			,D.intItemLocationId
		FROM tblGRTransferStorage A
		INNER JOIN tblGRTransferStorageReference B
			ON B.intTransferStorageId = A.intTransferStorageId
				AND B.intTransferStorageReferenceId = @intTransactionDetailId
		INNER JOIN tblGRCustomerStorage C
			ON C.intCustomerStorageId = B.intToCustomerStorageId
		INNER JOIN tblICItemLocation D
			ON D.intItemId = C.intItemId
				AND D.intLocationId = C.intCompanyLocationId
	) TRA
	INNER JOIN tblICItem i
		ON i.intItemId = t.intItemId
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
	WHERE t.intTransactionDetailId = @intSourceTransactionDetailId

	UNION ALL
	
	--APC is in TRA but NO INVENTORY VALUATION
	SELECT	
		TSR.dtmProcessDate
		,CS_FROM.intItemId
		,IL.intItemLocationId
		,TRA.intTransferStorageId
		,@intTransactionDetailId
		,TRA.strTransferStorageTicket
		,TS.intTransferStorageId
		,TSR.intTransferStorageReferenceId
		,TS.strTransferStorageTicket
		,TRA.dblUnitQty
		,UOM.dblUnitQty
		,CS_FROM.dblBasis + CS_FROM.dblSettlementPrice
		,dblValue	= TRA.dblUnitQty * (CS_FROM.dblBasis + CS_FROM.dblSettlementPrice)
		,ISNULL(CS_FROM.intCurrencyId, @DefaultCurrencyId) intCurrencyId
		,I.strItemNo
		,NULL
		,strTransactionType = 'Source'
		,@strBatchId
		,'5'
	FROM tblGRTransferStorage TS
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intTransferStorageId = TS.intTransferStorageId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intSourceCustomerStorageId
	INNER JOIN tblGRStorageType ST_TO
		ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
			AND ST_TO.ysnDPOwnedType = 1
	INNER JOIN tblICItem I
		ON I.intItemId = CS_FROM.intItemId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemId = I.intItemId
			AND UOM.ysnStockUnit = 1
	INNER JOIN tblICItemLocation IL
		ON IL.intItemId = I.intItemId
			AND IL.intLocationId = CS_FROM.intCompanyLocationId
	OUTER APPLY (
		SELECT A.intTransferStorageId
			,A.strTransferStorageTicket
			,B.dblUnitQty
		FROM tblGRTransferStorage A
		INNER JOIN tblGRTransferStorageReference B
			ON B.intTransferStorageId = A.intTransferStorageId
				AND B.intTransferStorageReferenceId = @intTransactionDetailId
	) TRA
	WHERE TSR.intTransferStorageReferenceId = @intSourceTransactionDetailId

	UNION ALL

	SELECT	
		TSR.dtmProcessDate
		,CS_TO.intItemId
		,IL.intItemLocationId
		,TS.intTransferStorageId
		,TSR.intTransferStorageReferenceId
		,TS.strTransferStorageTicket
		,TS.intTransferStorageId
		,TSR.intTransferStorageReferenceId
		,TS.strTransferStorageTicket
		,TSR.dblUnitQty
		,UOM.dblUnitQty
		,CS_TO.dblBasis + CS_TO.dblSettlementPrice
		,dblValue	= TSR.dblUnitQty * (CS_TO.dblBasis + CS_TO.dblSettlementPrice)
		,ISNULL(CS_TO.intCurrencyId, @DefaultCurrencyId) intCurrencyId
		,I.strItemNo
		,NULL
		,strTransactionType = 'To'
		,@strBatchId
		,'6'
	FROM tblGRTransferStorage TS
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intTransferStorageId = TS.intTransferStorageId
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS_FROM.ysnTransferStorage = 1
	INNER JOIN tblGRStorageType ST_FROM
		ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
			AND ST_FROM.ysnDPOwnedType = 1
	INNER JOIN tblICItem I
		ON I.intItemId = CS_TO.intItemId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemId = I.intItemId
			AND UOM.ysnStockUnit = 1
	INNER JOIN tblICItemLocation IL
		ON IL.intItemId = I.intItemId
			AND IL.intLocationId = CS_TO.intCompanyLocationId
	OUTER APPLY (
		SELECT ysnExists = 1
		FROM tblICInventoryTransaction t
		INNER JOIN tblGRTransferStorageReference TSR
			ON TSR.intTransferStorageReferenceId = t.intTransactionDetailId
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = TSR.intTransferStorageId
				AND TS.strTransferStorageTicket = t.strTransactionId
		WHERE TSR.intTransferStorageReferenceId = @intSourceTransactionDetailId
	) TRA
	WHERE TSR.intTransferStorageReferenceId = @intTransactionDetailId
		AND TRA.ysnExists IS NULL
	/*END HERE: for DS and SC*/	

	UNION ALL

	/*==SCALE TICKETS ONLY==*/
	--IR
	SELECT	
		TSR.dtmProcessDate
		,IRI.intItemId
		,IL.intItemLocationId
		,TSR.intTransferStorageId
		,@intTransactionDetailId
		,TSR.strTransferStorageTicket
		,IR.intInventoryReceiptId
		,IRI.intInventoryReceiptItemId
		,IR.strReceiptNumber
		,ROUND(TSR.dblUnitQty,2)
		,UOM.dblUnitQty
		,ISNULL((CS_FROM.dblBasis + CS_FROM.dblSettlementPrice),IRI.dblUnitCost)
		,TSR.dblUnitQty * ISNULL((CS_FROM.dblBasis + CS_FROM.dblSettlementPrice),IRI.dblUnitCost)
		,CS_FROM.intCurrencyId
		,IC.strItemNo
		,strRateType = currencyRateType.strCurrencyExchangeRateType
		,strTransactionType = 'Source'
		,@strBatchId
		,'7'
	FROM tblICInventoryReceipt IR
	INNER JOIN tblICInventoryReceiptItem IRI
		ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
	INNER JOIN tblICItemLocation IL
		ON IL.intItemId = IRI.intItemId
			AND IL.intLocationId = IR.intLocationId
	INNER JOIN tblICItem IC
		ON IC.intItemId = IRI.intItemId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemId = IRI.intItemId
			AND UOM.ysnStockUnit = 1
	INNER JOIN tblGRStorageHistory SH
		ON SH.intInventoryReceiptId = IR.intInventoryReceiptId
			AND SH.intTransactionTypeId = 1
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = SH.intCustomerStorageId
	LEFT JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = IRI.intContractDetailId
	LEFT JOIN tblCTContractHeader CH 
		ON CH.intContractHeaderId = CD.intContractHeaderId  
	OUTER APPLY (
		SELECT dblUnitQty,dtmProcessDate,TS.strTransferStorageTicket,TS.intTransferStorageId 
		FROM tblGRTransferStorageReference A
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = A.intTransferStorageId
		WHERE A.intTransferStorageReferenceId = @intTransactionDetailId
	) TSR
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = IRI.intForexRateTypeId
	WHERE IR.intInventoryReceiptId = @intSourceTransactionDetailId
		AND ISNULL(CH.intPricingTypeId, -99) IN (5)
	UNION ALL

	--TRA side
	SELECT	
		TSR.dtmProcessDate
		,CS_TO.intItemId
		,IL.intItemLocationId
		,TSR.intTransferStorageId
		,@intTransactionDetailId
		,TS.strTransferStorageTicket
		,TSR.intTransferStorageId
		,TSR.intTransferStorageReferenceId
		,TS.strTransferStorageTicket
		,ROUND(TSR.dblUnitQty,2)
		,UOM.dblUnitQty
		,CS_TO.dblBasis + CS_TO.dblSettlementPrice
		,TSR.dblUnitQty * (CS_TO.dblBasis + CS_TO.dblSettlementPrice)
		,CS_TO.intCurrencyId
		,IC.strItemNo
		,NULL
		,strTransactionType = 'To'
		,@strBatchId
		,'8'
	FROM tblGRTransferStorageReference TSR
	INNER JOIN tblGRTransferStorage TS
		ON TS.intTransferStorageId = TSR.intTransferStorageId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
			AND CS_FROM.ysnTransferStorage = 0
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
			AND CS_TO.intTicketId IS NOT NULL
	INNER JOIN tblICItemLocation IL
		ON IL.intItemId = CS_TO.intItemId
			AND IL.intLocationId = CS_TO.intCompanyLocationId
	INNER JOIN tblICItem IC
		ON IC.intItemId = CS_TO.intItemId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemId = CS_TO.intItemId
			AND UOM.ysnStockUnit = 1
	WHERE TSR.intTransferStorageReferenceId = @intTransactionDetailId

	DELETE FROM tblGRTransferGLEntriesCTE WHERE dblValue = 0
END
ELSE
BEGIN
	SELECT TOP 1 @strBatchId2 = strBatchId FROM tblGRTransferGLEntriesCTE WHERE intSourceTransactionDetailId = @intTransactionDetailId
END
--select '@strBatchId2'=@strBatchId2
--SELECT 'tblGRTransferGLEntriesCTE',* FROM tblGRTransferGLEntriesCTE
;

-- Generate the G/L Entries here: 
WITH ForGLEntries_CTE (
	dtmDate
	,intItemId
	,intItemLocationId
	,intTransactionId
	,intTransactionDetailId
	,strTransactionId
	,dblQty
	,dblUOMQty
	,dblCost
	,dblValue
	,intCurrencyId
	,strItemNo
	,strRateType
	,strTransactionType
	,intSourceTransactionId
	,intSourceTransactionDetailId
	,strSourceTransactionId
)
AS
(
	SELECT
		dtmDate
		,intItemId
		,intItemLocationId
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,dblQty
		,dblUOMQty
		,dblCost
		,dblValue
		,intCurrencyId
		,strItemNo
		,strRateType
		,strTransactionType
		,intSourceTransactionId
		,intSourceTransactionDetailId
		,strSourceTransactionId
	FROM tblGRTransferGLEntriesCTE
	WHERE (strBatchId = @strBatchId AND @ysnUnpost = 0)
		OR (strBatchId = @strBatchId2 AND @ysnUnpost = 1)
		
)

------------------------------------------------------------------------------------------
--OFFSET IR side
-------------------------------------------------------------------------------------------
SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= CASE WHEN GL.dblDebit = 0 THEN Debit.Value ELSE 0 END
	,dblCredit					= CASE WHEN GL.dblCredit = 0 THEN Credit.Value ELSE 0 END
	,dblDebitUnit				= CASE WHEN GL.dblDebitUnit = 0 THEN DebitUnit.Value ELSE 0 END
	,dblCreditUnit				= CASE WHEN GL.dblCreditUnit = 0 THEN CreditUnit.Value ELSE 0 END
	,strDescription				= ISNULL(tblGLAccount.strDescription, '') + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, ForGLEntries_CTE.dblQty, ForGLEntries_CTE.dblCost, DEFAULT) --+ ' A'
	,strCode					= 'IC'
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= 1--GL.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intSourceTransactionDetailId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= GL.intEntityId 
	,strTransactionId			= ForGLEntries_CTE.strSourceTransactionId
	,intTransactionId			= ForGLEntries_CTE.intSourceTransactionId
	,strTransactionType			= 'Transfer Storage'
	,strTransactionForm			= 'Transfer Storage'
	,strModuleName				= @ModuleName
	,intConcurrencyId			= 1
	,dblDebitForeign			= DebitForeign.Value
	,dblDebitReport				= NULL--CASE WHEN GL.dblDebitReport = 0 THEN GL.dblCreditReport ELSE 0 END
	,dblCreditForeign			= CreditForeign.Value
	,dblCreditReport			= NULL--CASE WHEN GL.dblCreditReport = 0 THEN GL.dblDebitReport ELSE 0 END
	,dblReportingRate			= NULL--GL.dblReportingRate
	,dblForeignRate				= GL.dblForeignRate
	,strRateType				= ForGLEntries_CTE.strRateType 
FROM ForGLEntries_CTE
INNER JOIN tblICInventoryTransaction InventoryTransaction
	ON InventoryTransaction.intTransactionId = ForGLEntries_CTE.intTransactionId
		AND InventoryTransaction.intTransactionDetailId = ForGLEntries_CTE.intTransactionDetailId
		AND InventoryTransaction.strTransactionId = ForGLEntries_CTE.strTransactionId
		AND InventoryTransaction.ysnIsUnposted = 0
INNER JOIN @GLAccounts GLAccounts
	ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
	AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
INNER JOIN tblGLDetail GL
	ON GL.intTransactionId = ForGLEntries_CTE.intTransactionId
		AND GL.intAccountId = GLAccounts.intInventoryId
		AND GL.intJournalLineNo = InventoryTransaction.intInventoryTransactionId
		AND GL.ysnIsUnposted = 0
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0))) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0))) Credit
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblUOMQty, 1))) CreditUnit
CROSS APPLY dbo.fnGetDebitForeign(
	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)	
	,ForGLEntries_CTE.intCurrencyId
	,@intFunctionalCurrencyId
	,1--,ForGLEntries_CTE.dblForexRate
) DebitForeign
CROSS APPLY dbo.fnGetCreditForeign(
	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
	,ForGLEntries_CTE.intCurrencyId
	,@intFunctionalCurrencyId
	,1--,ForGLEntries_CTE.dblForexRate
) CreditForeign
WHERE ForGLEntries_CTE.strTransactionType = 'Source'

UNION ALL

--OFFSET TRA SIDE
SELECT DISTINCT
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= CASE WHEN @ysnUnpost = 0 THEN CASE WHEN GL.dblDebit = 0 THEN Debit.Value ELSE 0 END ELSE Debit.Value END
	,dblCredit					= CASE WHEN @ysnUnpost = 0 THEN CASE WHEN GL.dblCredit = 0 THEN Credit.Value ELSE 0 END ELSE Credit.Value END
	,dblDebitUnit				= CASE WHEN @ysnUnpost = 0 THEN CASE WHEN GL.dblDebitUnit = 0 THEN DebitUnit.Value ELSE 0 END ELSE DebitUnit.Value END
	,dblCreditUnit				= CASE WHEN @ysnUnpost = 0 THEN CASE WHEN GL.dblCreditUnit = 0 THEN CreditUnit.Value ELSE 0 END ELSE CreditUnit.Value END
	,strDescription				= ISNULL(tblGLAccount.strDescription, '') + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, ForGLEntries_CTE.dblQty, ForGLEntries_CTE.dblCost, DEFAULT) --+ ' B'
	,strCode					= 'IC'
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= 1--GL.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intSourceTransactionDetailId -- temporary workaround as source transaction and transaction fields are swapped in tblGRTransferGLEntriesCTE
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= GL.intEntityId 
	,strTransactionId			= ForGLEntries_CTE.strSourceTransactionId -- temporary workaround as source transaction and transaction fields are swapped in tblGRTransferGLEntriesCTE
	,intTransactionId			= ForGLEntries_CTE.intSourceTransactionId -- temporary workaround as source transaction and transaction fields are swapped in tblGRTransferGLEntriesCTE
	,strTransactionType			= 'Transfer Storage'
	,strTransactionForm			= 'Transfer Storage'
	,strModuleName				= @ModuleName
	,intConcurrencyId			= 1
	,dblDebitForeign			= DebitForeign.Value
	,dblDebitReport				= NULL--CASE WHEN GL.dblDebitReport = 0 THEN GL.dblCreditReport ELSE 0 END
	,dblCreditForeign			= CreditForeign.Value
	,dblCreditReport			= NULL--CASE WHEN GL.dblCreditReport = 0 THEN GL.dblDebitReport ELSE 0 END
	,dblReportingRate			= NULL--GL.dblReportingRate
	,dblForeignRate				= GL.dblForeignRate
	,strRateType				= ForGLEntries_CTE.strRateType 
FROM ForGLEntries_CTE
INNER JOIN @GLAccounts GLAccounts
	ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
	AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
INNER JOIN tblGLDetail GL
	ON GL.intTransactionId = ForGLEntries_CTE.intTransactionId
		AND GL.intAccountId = GLAccounts.intInventoryId
		AND GL.intJournalLineNo = ForGLEntries_CTE.intTransactionDetailId
		AND GL.strCode = 'IC'
		AND GL.ysnIsUnposted = 0
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0))) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0))) Credit
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblUOMQty, 1))) CreditUnit
CROSS APPLY dbo.fnGetDebitForeign(
	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)	
	,ForGLEntries_CTE.intCurrencyId
	,@intFunctionalCurrencyId
	,1--,ForGLEntries_CTE.dblForexRate
) DebitForeign
CROSS APPLY dbo.fnGetCreditForeign(
	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
	,ForGLEntries_CTE.intCurrencyId
	,@intFunctionalCurrencyId
	,1--,ForGLEntries_CTE.dblForexRate
) CreditForeign
WHERE (ForGLEntries_CTE.strTransactionType = 'Source' AND @ysnUnpost = 0)
	OR (ForGLEntries_CTE.strTransactionType = 'Source' AND @ysnUnpost = 1 AND GL.strBatchId = @strBatchId2)

UNION ALL

-------------------------------------------------------------------------------------------
--OPEN CLEARING FOR NEW DP STORAGE
-------------------------------------------------------------------------------------------
SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= Credit.Value
	,dblCredit					= Debit.Value
	,dblDebitUnit				= CreditUnit.Value
	,dblCreditUnit				= DebitUnit.Value
	,strDescription				= ISNULL(tblGLAccount.strDescription, '') + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, ForGLEntries_CTE.dblQty, ForGLEntries_CTE.dblCost, DEFAULT) --+ ' C'
	,strCode					= 'IC'
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= 1
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= @intTransactionDetailId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= NULL 
	,strTransactionId			= ForGLEntries_CTE.strTransactionId
	,intTransactionId			= ForGLEntries_CTE.intTransactionId
	,strTransactionType			= 'Transfer Storage'
	,strTransactionForm			= 'Transfer Storage'
	,strModuleName				= @ModuleName
	,intConcurrencyId			= 1
	,dblDebitForeign			= CreditForeign.Value
	,dblDebitReport				= NULL--CASE WHEN GL.dblDebitReport = 0 THEN GL.dblCreditReport ELSE 0 END
	,dblCreditForeign			= DebitForeign.Value
	,dblCreditReport			= NULL--CASE WHEN GL.dblCreditReport = 0 THEN GL.dblDebitReport ELSE 0 END
	,dblReportingRate			= NULL--GL.dblReportingRate
	,dblForeignRate				= 1
	,strRateType				= ForGLEntries_CTE.strRateType 
FROM ForGLEntries_CTE
INNER JOIN @GLAccounts GLAccounts
	ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
	AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0))) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0))) Credit
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblUOMQty, 1))) CreditUnit
CROSS APPLY dbo.fnGetDebitForeign(
	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)	
	,ForGLEntries_CTE.intCurrencyId
	,@intFunctionalCurrencyId
	,1--,ForGLEntries_CTE.dblForexRate
) DebitForeign
CROSS APPLY dbo.fnGetCreditForeign(
	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
	,ForGLEntries_CTE.intCurrencyId
	,@intFunctionalCurrencyId
	,1--,ForGLEntries_CTE.dblForexRate
) CreditForeign
WHERE ForGLEntries_CTE.strTransactionType = 'To'
;