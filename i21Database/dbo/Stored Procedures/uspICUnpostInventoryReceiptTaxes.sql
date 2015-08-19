CREATE PROCEDURE [dbo].[uspICUnpostInventoryReceiptTaxes]
	@intInventoryReceiptId AS INT 
	,@strBatchId AS NVARCHAR(20)
	,@intUserId AS INT
	,@intTransactionTypeId AS INT 
AS

-- Get the A/P Clearing account 
BEGIN 
	DECLARE @AccountCategory_APClearing AS NVARCHAR(30) = 'AP Clearing';
	DECLARE @GLAccounts AS dbo.ItemGLAccount; 
	INSERT INTO @GLAccounts (
		intItemId 
		,intItemLocationId 
		,intContraInventoryId 
		,intTransactionTypeId 
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_APClearing) 
			,@intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						ReceiptItem.intItemId
						,ItemLocation.intItemLocationId
				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
							ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = ReceiptItem.intItemId
							AND ItemLocation.intLocationId = Receipt.intLocationId
				WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
			) Query
END

-- Log the g/l account used in this batch. 
BEGIN 
	INSERT INTO dbo.tblICInventoryGLAccountUsedOnPostLog (
			intItemId
			,intItemLocationId
			,intContraInventoryId
			,intPurchaseTaxCodeId
			,strBatchId
	)
	SELECT	DISTINCT 
			intItemId
			,intItemLocationId
			,intContraInventoryId
			,NULL 
			,@strBatchId
	FROM	@GLAccounts
	UNION ALL 
	SELECT	DISTINCT 
			ReceiptItem.intItemId
			,ItemLocation.intItemLocationId
			,NULL
			,TaxCode.intPurchaseTaxAccountId
			,@strBatchId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = ReceiptItem.intItemId
				AND ItemLocation.intLocationId = Receipt.intLocationId							
			INNER JOIN dbo.tblICInventoryReceiptItemTax ReceiptTaxes
				ON ReceiptItem.intInventoryReceiptItemId = ReceiptTaxes.intInventoryReceiptItemId
			INNER JOIN dbo.tblSMTaxCode TaxCode
				ON TaxCode.intTaxCodeId = ReceiptTaxes.intTaxCodeId
			LEFT JOIN dbo.tblICInventoryTransactionType TransType
				ON TransType.intTransactionTypeId = @intTransactionTypeId
	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
	;

END 

-- Generate the G/L Entries here: 
BEGIN 
	DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory'
			,@strTransactionForm  AS NVARCHAR(50) = 'Inventory Receipt'
			,@strCode AS NVARCHAR(10) = 'IC';

	WITH ForGLEntries_CTE (
		dtmDate
		,intItemId
		,intItemLocationId
		,intTransactionId		
		,strTransactionId
		,intReceiptItemTaxId
		,dblTax
		,intTransactionTypeId
		,intCurrencyId
		,dblExchangeRate
		,strInventoryTransactionTypeName
		,strTransactionForm
		,intPurchaseTaxAccountId
	)
	AS 
	(
		SELECT	dtmDate								= Receipt.dtmReceiptDate
				,intItemId							= ReceiptItem.intItemId
				,intItemLocationId					= ItemLocation.intItemLocationId
				,intTransactionId					= Receipt.intInventoryReceiptId				
				,strTransactionId					= Receipt.strReceiptNumber
				,intReceiptItemTaxId				= ReceiptTaxes.intInventoryReceiptItemTaxId
				,dblTax								= ReceiptTaxes.dblTax
				,intTransactionTypeId				= @intTransactionTypeId
				,intCurrencyId						= Receipt.intCurrencyId
				,dblExchangeRate					= 1
				,strInventoryTransactionTypeName	= TransType.strName
				,strTransactionForm					= @strTransactionForm
				,intPurchaseTaxAccountId			= TaxCode.intPurchaseTaxAccountId
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId		
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ReceiptItem.intItemId
					AND ItemLocation.intLocationId = Receipt.intLocationId
				INNER JOIN dbo.tblICInventoryReceiptItemTax ReceiptTaxes
					ON ReceiptItem.intInventoryReceiptItemId = ReceiptTaxes.intInventoryReceiptItemId
				INNER JOIN dbo.tblSMTaxCode TaxCode
					ON TaxCode.intTaxCodeId = ReceiptTaxes.intTaxCodeId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId				
	)
	
	-------------------------------------------------------------------------------------------
	-- Dr...... Purchase Tax Id 
	-- Cr..................... A/P Clearing 
	-------------------------------------------------------------------------------------------
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intReceiptItemTaxId
			,ysnIsUnposted				= 0
			,intUserId					= @intUserId 
			,intEntityId				= @intUserId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
	FROM	ForGLEntries_CTE LEFT JOIN dbo.tblGLAccount GLAccount 
				ON GLAccount.intAccountId = ForGLEntries_CTE.intPurchaseTaxAccountId
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblTax) Debit
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblTax) Credit
	UNION ALL 
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intReceiptItemTaxId
			,ysnIsUnposted				= 0
			,intUserId					= @intUserId 
			,intEntityId				= @intUserId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
	FROM	ForGLEntries_CTE INNER JOIN @GLAccounts InventoryAccounts
				ON ForGLEntries_CTE.intItemId = InventoryAccounts.intItemId
				AND ForGLEntries_CTE.intItemLocationId = InventoryAccounts.intItemLocationId
			LEFT JOIN dbo.tblGLAccount GLAccount 
				ON GLAccount.intAccountId = InventoryAccounts.intContraInventoryId
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblTax) Debit
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblTax) Credit

	;
END

-- Exit point
_Exit: