CREATE PROCEDURE [dbo].[uspICCreateReversalGLEntriesForMissingLots]
	@strBatchId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN 
	-------------------------------------------------------------------------------------------
	-- Reverse the G/L entries for the missing lots
	-------------------------------------------------------------------------------------------
	SELECT	
			[dtmDate]					= GLEntries.dtmDate
			,[strBatchId]				= @strBatchId
			,[intAccountId]				= GLEntries.intAccountId
			,[dblDebit]					= GLEntries.dblCredit	-- Reverse the Debit with Credit 
			,[dblCredit]				= GLEntries.dblDebit	-- Reverse the Credit with Debit 
			,[dblDebitUnit]				= GLEntries.dblCreditUnit
			,[dblCreditUnit]			= GLEntries.dblDebitUnit
			,[strDescription]			= GLEntries.strDescription
			,[strCode]					= GLEntries.strCode
			,[strReference]				= GLEntries.strReference
			,[intCurrencyId]			= GLEntries.intCurrencyId
			,[dblExchangeRate]			= GLEntries.dblExchangeRate
			,[dtmDateEntered]			= GETDATE()
			,[dtmTransactionDate]		= GLEntries.dtmDate
			,[strJournalLineDescription] = GLEntries.strJournalLineDescription
			,[intJournalLineNo]			= GLEntries.intJournalLineNo
			,[ysnIsUnposted]			= 1
			,[intUserId]				= @intEntityUserSecurityId
			,[intEntityId]				= @intEntityUserSecurityId
			,[strTransactionId]			= GLEntries.strTransactionId
			,[intTransactionId]			= GLEntries.intTransactionId
			,[strTransactionType]		= GLEntries.strTransactionType
			,[strTransactionForm]		= GLEntries.strTransactionForm
			,[strModuleName]			= GLEntries.strModuleName
			,[intConcurrencyId]			= 1
			,[dblDebitForeign]			= GLEntries.dblCreditForeign
			,[dblDebitReport]			= GLEntries.dblCreditReport
			,[dblCreditForeign]			= GLEntries.dblDebitForeign
			,[dblCreditReport]			= GLEntries.dblDebitReport
			,[dblReportingRate]			= GLEntries.dblReportingRate
			,[dblForeignRate]			= GLEntries.dblForeignRate
			,[strRateType]				= currencyRateType.strCurrencyExchangeRateType
			,[intSourceEntityId]		= GLEntries.intSourceEntityId
			,[intCommodityId]			= GLEntries.intCommodityId
	FROM	tblGLDetail GLEntries INNER JOIN (
				tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId					
				INNER JOIN tblICItem i 
					ON ri.intItemId = i.intItemId
			)
				ON GLEntries.intJournalLineNo = ri.intInventoryReceiptItemId
				AND GLEntries.strTransactionId = r.strReceiptNumber
				AND GLEntries.intTransactionId = r.intInventoryReceiptId				

			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = ri.intForexRateTypeId
	WHERE	
		GLEntries.strTransactionId = @strTransactionId			
		AND GLEntries.strCode = 'ICM'
		AND ISNULL(GLEntries.ysnIsUnposted, 0) = 0
END
;

-- Update the Lot's Qty and Weights. 
BEGIN 
	UPDATE	Lot 
	SET		Lot.dblQty = 0
			,Lot.dblWeight = 0			
	FROM	dbo.tblICLot Lot INNER JOIN tblICInventoryReceiptItemLot ril
				ON Lot.intLotId = ril.intLotId
			INNER JOIN tblICInventoryReceiptItem ri
				ON ril.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
				AND Lot.intItemId = ri.intItemId
			INNER JOIN tblICInventoryReceipt r
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
	WHERE
			r.strReceiptNumber = @strTransactionId
			AND ril.strCondition = 'Missing'
			AND r.ysnPosted = 0

	UPDATE	Lot 
	SET		Lot.dblTare = 0
			,Lot.dblGrossWeight = 0
	FROM	dbo.tblICLot Lot INNER JOIN tblICInventoryReceiptItemLot ril
				ON Lot.intLotId = ril.intLotId
			INNER JOIN tblICInventoryReceiptItem ri
				ON ril.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
				AND Lot.intItemId = ri.intItemId
			INNER JOIN tblICInventoryReceipt r
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
	WHERE
			r.strReceiptNumber = @strTransactionId
			AND ril.strCondition = 'Missing'
			AND r.ysnPosted = 0
			AND ISNULL(Lot.dblTarePerQty, 0) <> 0 				
END 