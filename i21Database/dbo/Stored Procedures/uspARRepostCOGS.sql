CREATE PROCEDURE uspARRepostCOGS
	@dtmOpenPeriod AS DATETIME 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the backup table. 
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tblICRepostCOGSGLEntriesBackup')
BEGIN 
	DROP TABLE tblICRepostCOGSGLEntriesBackup
END 

BEGIN 
	CREATE TABLE tblICRepostCOGSGLEntriesBackup (
		[intGLDetailId]		INT 
		,[dblDebit]			NUMERIC(18, 6) NULL
		,[dblCredit]		NUMERIC(18, 6) NULL
		,[strBatchId]		NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
		,[dtmDate]			DATETIME NULL
		,[intAccountId]		INT NULL
		,[strDescription]	NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL
		,[strReference]		NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL
		,[intCurrencyId]	INT NULL
		,[dblExchangeRate]	NUMERIC(38, 20) NULL
		,[dtmDateEntered]	DATETIME NULL
		,[dtmTransactionDate]	DATETIME NULL
		,[strJournalLineDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
		,[intJournalLineNo] INT NULL
		,[intUserId]		INT NULL
		,[intEntityId]		INT NULL
		,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,[intTransactionId]	INT NULL
		,[strTransactionType] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL
		,[strTransactionForm] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL
		,[strModuleName]	NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL
		,CONSTRAINT [PK_tblICRepostCOGSGLEntriesBackup] PRIMARY KEY ([intGLDetailId])
	)

	CREATE NONCLUSTERED INDEX [IX_tblICRepostCOGSGLEntriesBackup_intGLDetailId]
		ON [dbo].[tblICRepostCOGSGLEntriesBackup]([intGLDetailId] ASC);

	CREATE NONCLUSTERED INDEX [IX_tblICRepostCOGSGLEntriesBackup_strTransactionId]
		ON [dbo].[tblICRepostCOGSGLEntriesBackup]([strTransactionId] ASC);

	CREATE NONCLUSTERED INDEX [IX_tblICRepostCOGSGLEntriesBackup_intJournalLineNo]
		ON [dbo].[tblICRepostCOGSGLEntriesBackup]([intJournalLineNo] ASC);

END

-- Backup the GL entries 
BEGIN 	
	INSERT INTO tblICRepostCOGSGLEntriesBackup (
		intGLDetailId
		,dblDebit
		,dblCredit 
		,strBatchId
		,dtmDate
		,intAccountId
		,strDescription
		,strReference
		,intCurrencyId
		,dblExchangeRate
		,dtmDateEntered
		,dtmTransactionDate
		,strJournalLineDescription
		,intJournalLineNo
		,intUserId
		,intEntityId
		,strTransactionId
		,intTransactionId
		,strTransactionType
		,strTransactionForm
		,strModuleName
	)
	-- Backup the GL entries related to COGS. 
	SELECT 
		gd.intGLDetailId
		,gd.dblDebit
		,gd.dblCredit 
		,gd.strBatchId
		,gd.dtmDate
		,gd.intAccountId
		,gd.strDescription
		,gd.strReference
		,gd.intCurrencyId
		,gd.dblExchangeRate
		,gd.dtmDateEntered
		,gd.dtmTransactionDate
		,gd.strJournalLineDescription
		,gd.intJournalLineNo
		,gd.intUserId
		,gd.intEntityId
		,gd.strTransactionId
		,gd.intTransactionId
		,gd.strTransactionType
		,gd.strTransactionForm
		,gd.strModuleName
	FROM	tblARInvoice i INNER JOIN tblARInvoiceDetail id
				ON i.[intInvoiceId] = id.[intInvoiceId] 

			INNER JOIN (
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
					AND s.ysnPosted = 1 
			)
				ON id.intInventoryShipmentItemId = si.intInventoryShipmentItemId

			INNER JOIN tblICItemLocation il 
				ON il.intItemId = si.intItemId
				AND il.intLocationId = s.intShipFromLocationId 
		
			INNER JOIN tblGLDetail gd
				ON gd.strTransactionId = i.strInvoiceNumber
					AND gd.intJournalLineNo = id.intInvoiceDetailId
					AND gd.ysnIsUnposted = 0 	
					AND gd.intAccountId = dbo.fnGetItemGLAccount(si.intItemId, il.intItemLocationId, 'Cost of Goods') 
	WHERE	ISNULL(id.intInventoryShipmentItemId, 0) <> 0 
			AND i.ysnPosted = 1
	-- Backup the GL entries related to Inventory In-Transit. 
	UNION ALL 
	SELECT 
		gd.intGLDetailId
		,gd.dblDebit
		,gd.dblCredit 
		,gd.strBatchId
		,gd.dtmDate
		,gd.intAccountId
		,gd.strDescription
		,gd.strReference
		,gd.intCurrencyId
		,gd.dblExchangeRate
		,gd.dtmDateEntered
		,gd.dtmTransactionDate
		,gd.strJournalLineDescription
		,gd.intJournalLineNo
		,gd.intUserId
		,gd.intEntityId
		,gd.strTransactionId
		,gd.intTransactionId
		,gd.strTransactionType
		,gd.strTransactionForm
		,gd.strModuleName
	FROM	tblARInvoice i INNER JOIN tblARInvoiceDetail id
				ON i.[intInvoiceId] = id.[intInvoiceId] 

			INNER JOIN (
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
					AND s.ysnPosted = 1 
			)
				ON id.intInventoryShipmentItemId = si.intInventoryShipmentItemId

			INNER JOIN tblICItemLocation il 
				ON il.intItemId = si.intItemId
				AND il.intLocationId = s.intShipFromLocationId 
		
			INNER JOIN tblGLDetail gd
				ON gd.strTransactionId = i.strInvoiceNumber
					AND gd.intJournalLineNo = id.intInvoiceDetailId
					AND gd.ysnIsUnposted = 0 	
					AND gd.intAccountId = dbo.fnGetItemGLAccount(si.intItemId, il.intItemLocationId, 'Inventory In-Transit') 
	WHERE	ISNULL(id.intInventoryShipmentItemId, 0) <> 0 
		AND i.ysnPosted = 1
END 

-- Zero out the debits and credits
BEGIN 

	-- Zero out the debit and credit of all GL entries related to COGS. 
	UPDATE	gd
	SET		dblDebit = 0
			,dblCredit = 0
			,dblDebitUnit = 0
			,dblCreditUnit = 0 
	FROM	tblARInvoice i INNER JOIN tblARInvoiceDetail id
				ON i.[intInvoiceId] = id.[intInvoiceId] 

			INNER JOIN (
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
					AND s.ysnPosted = 1 
			)
				ON id.intInventoryShipmentItemId = si.intInventoryShipmentItemId

			INNER JOIN tblICItemLocation il 
				ON il.intItemId = si.intItemId
				AND il.intLocationId = s.intShipFromLocationId 
		
			INNER JOIN tblGLDetail gd
				ON gd.strTransactionId = i.strInvoiceNumber
					AND gd.intJournalLineNo = id.intInvoiceDetailId
					AND gd.ysnIsUnposted = 0 	
					AND gd.intAccountId = dbo.fnGetItemGLAccount(si.intItemId, il.intItemLocationId, 'Cost of Goods') 
	WHERE	ISNULL(id.intInventoryShipmentItemId, 0) <> 0 
			AND i.ysnPosted = 1

	-- Zero out the debit and credit of all GL entries related to Inventory In-Transit. 
	UPDATE	gd
	SET		dblDebit = 0
			,dblCredit = 0
			,dblDebitUnit = 0
			,dblCreditUnit = 0 
	FROM	tblARInvoice i INNER JOIN tblARInvoiceDetail id
				ON i.[intInvoiceId] = id.[intInvoiceId] 

			INNER JOIN (
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
					AND s.ysnPosted = 1 
			)
				ON id.intInventoryShipmentItemId = si.intInventoryShipmentItemId

			INNER JOIN tblICItemLocation il 
				ON il.intItemId = si.intItemId
				AND il.intLocationId = s.intShipFromLocationId 
		
			INNER JOIN tblGLDetail gd
				ON gd.strTransactionId = i.strInvoiceNumber
					AND gd.intJournalLineNo = id.intInvoiceDetailId
					AND gd.ysnIsUnposted = 0 	
					AND gd.intAccountId = dbo.fnGetItemGLAccount(si.intItemId, il.intItemLocationId, 'Inventory In-Transit') 
	WHERE	ISNULL(id.intInventoryShipmentItemId, 0) <> 0 
			AND i.ysnPosted = 1
END 

-- Update the GL entries from the closed period. 
BEGIN 
	UPDATE	gd
	SET		dblDebit = Debit.Value 
			,dblCredit = Credit.Value 
			,dblDebitUnit = DebitUnit.Value
			,dblCreditUnit = CreditUnit.Value
	FROM	tblARInvoice i INNER JOIN tblARInvoiceDetail id
				ON i.[intInvoiceId] = id.[intInvoiceId] 
			INNER JOIN (
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
					AND s.ysnPosted = 1 
			)
				ON id.intInventoryShipmentItemId = si.intInventoryShipmentItemId
			INNER JOIN tblICItemLocation il 
				ON il.intItemId = si.intItemId
				AND il.intLocationId = s.intShipFromLocationId 
		
			CROSS APPLY (
				SELECT	value = SUM(-ROUND(t.dblQty * t.dblCost + t.dblValue, 2))
						,unit = SUM(-ROUND(t.dblQty * t.dblUOMQty, 2))
				FROM	tblICInventoryTransaction t
				WHERE	t.strTransactionId = s.strShipmentNumber
						AND t.intTransactionDetailId = si.intInventoryShipmentItemId
						AND t.ysnIsUnposted = 0 
						AND 1 = 
							CASE	
									-- 1: When shipment date is on the open period and invoice date is greater than the open period. 
									WHEN	dbo.fnDateEquals(t.dtmDate, @dtmOpenPeriod) = 1
											AND dbo.fnDateGreaterThanEquals(i.dtmShipDate, @dtmOpenPeriod) = 1 THEN 1
									
									-- 2: When invoice date is equal or greater than shipment date. 
									WHEN	dbo.fnDateGreaterThanEquals(i.dtmShipDate, t.dtmDate) = 1 THEN 1

									-- 3: When shipment date is on the open period and shipment date is less than the open period. 
									-- There seems to be instances where the invoice is dated earlier than the shipment date. 
									WHEN	dbo.fnDateLessThan(t.dtmDate, @dtmOpenPeriod) = 1 
											AND dbo.fnDateLessThan(i.dtmShipDate, @dtmOpenPeriod) = 1 THEN 1

									-- Otherwise: do not include the ic transaction in the query. 
									ELSE	0
							END 

			) t
			CROSS APPLY (
				SELECT TOP 1 *
				FROM	tblGLDetail gd
				WHERE	gd.strTransactionId = i.strInvoiceNumber
						AND gd.intJournalLineNo = id.intInvoiceDetailId
						AND gd.ysnIsUnposted = 0 	
						AND gd.intAccountId = dbo.fnGetItemGLAccount(si.intItemId, il.intItemLocationId, 'Cost of Goods') 
			) tgd
			INNER JOIN tblGLDetail gd
				ON gd.intGLDetailId = tgd.intGLDetailId 
			CROSS APPLY dbo.fnGetDebit(t.value) Debit
			CROSS APPLY dbo.fnGetCredit(t.value) Credit
			CROSS APPLY dbo.fnGetDebit(t.unit) DebitUnit
			CROSS APPLY dbo.fnGetCredit(t.unit) CreditUnit
	WHERE	ISNULL(id.intInventoryShipmentItemId, 0) <> 0 
			AND i.ysnPosted = 1

	-- Update the GL amounts for the Inventory Transit 
	UPDATE	gd
	SET		dblDebit = Credit.Value 
			,dblCredit = Debit.Value 
			,dblDebitUnit = CreditUnit.Value
			,dblCreditUnit = DebitUnit.Value
	FROM	tblARInvoice i INNER JOIN tblARInvoiceDetail id
				ON i.[intInvoiceId] = id.[intInvoiceId] 
			INNER JOIN (
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
					AND s.ysnPosted = 1 
			)
				ON id.intInventoryShipmentItemId = si.intInventoryShipmentItemId
			INNER JOIN tblICItemLocation il 
				ON il.intItemId = si.intItemId
				AND il.intLocationId = s.intShipFromLocationId 
		
			CROSS APPLY (
				SELECT	value = SUM(-ROUND(t.dblQty * t.dblCost + t.dblValue, 2))
						,unit = SUM(-ROUND(t.dblQty * t.dblUOMQty, 2))
				FROM	tblICInventoryTransaction t
				WHERE	t.strTransactionId = s.strShipmentNumber
						AND t.intTransactionDetailId = si.intInventoryShipmentItemId
						AND t.ysnIsUnposted = 0 
						AND 1 = 
							CASE	
									-- 1: When shipment date is on the open period and invoice date is greater than the open period. 
									WHEN	dbo.fnDateEquals(t.dtmDate, @dtmOpenPeriod) = 1
											AND dbo.fnDateGreaterThanEquals(i.dtmShipDate, @dtmOpenPeriod) = 1 THEN 1
									
									-- 2: When invoice date is equal or greater than shipment date. 
									WHEN	dbo.fnDateGreaterThanEquals(i.dtmShipDate, t.dtmDate) = 1 THEN 1

									-- 3: When shipment date is on the open period and shipment date is less than the open period. 
									-- There seems to be instances where the invoice is dated earlier than the shipment date. 
									WHEN	dbo.fnDateLessThan(t.dtmDate, @dtmOpenPeriod) = 1 
											AND dbo.fnDateLessThan(i.dtmShipDate, @dtmOpenPeriod) = 1 THEN 1

									-- Otherwise: do not include the ic transaction in the query. 
									ELSE	0
							END 
			) t
			CROSS APPLY (
				SELECT TOP 1 *
				FROM	tblGLDetail gd
				WHERE	gd.strTransactionId = i.strInvoiceNumber
						AND gd.intJournalLineNo = id.intInvoiceDetailId
						AND gd.ysnIsUnposted = 0 	
						AND gd.intAccountId = dbo.fnGetItemGLAccount(si.intItemId, il.intItemLocationId, 'Inventory In-Transit')
			) tgd
			INNER JOIN tblGLDetail gd
				ON gd.intGLDetailId = tgd.intGLDetailId 
			CROSS APPLY dbo.fnGetDebit(t.value) Debit
			CROSS APPLY dbo.fnGetCredit(t.value) Credit
			CROSS APPLY dbo.fnGetDebit(t.unit) DebitUnit
			CROSS APPLY dbo.fnGetCredit(t.unit) CreditUnit
	WHERE	ISNULL(id.intInventoryShipmentItemId, 0) <> 0 
			AND i.ysnPosted = 1
END 

-- Insert new GL entries. Transfer g/l adjustments from the closed period to the open period
BEGIN 
	INSERT INTO [tblGLDetail](
		[dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted]
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblDebitForeign]
		,[dblDebitReport]
		,[dblCreditForeign]
		,[dblCreditReport]
		,[dblReportingRate]
		,[dblForeignRate]
	)
	-- GL entries for COGS
	SELECT	
			[dtmDate] = @dtmOpenPeriod
			,[strBatchId]	= gd_backup.strBatchId
			,[intAccountId]	= gd_backup.intAccountId
			,[dblDebit]		= Debit.Value
			,[dblCredit]	= Credit.Value
			,[dblDebitUnit]	= DebitUnit.Value
			,[dblCreditUnit]	= CreditUnit.Value
			,[strDescription]	= gd_backup.strDescription
			,[strCode]			= 'AR'
			,[strReference]		= gd_backup.strReference
			,[intCurrencyId]	= gd_backup.intCurrencyId
			,[dblExchangeRate]	= gd_backup.dblExchangeRate
			,[dtmDateEntered]	= GETDATE()
			,[dtmTransactionDate]	= gd_backup.dtmTransactionDate
			,[strJournalLineDescription]	= gd_backup.strJournalLineDescription
			,[intJournalLineNo]	= gd_backup.intJournalLineNo
			,[ysnIsUnposted]	= 0 
			,[intUserId]		= gd_backup.intUserId
			,[intEntityId]		= gd_backup.intEntityId
			,[strTransactionId]	= gd_backup.strTransactionId
			,[intTransactionId]	= gd_backup.intTransactionId
			,[strTransactionType] = gd_backup.strTransactionType
			,[strTransactionForm]	= gd_backup.strTransactionForm
			,[strModuleName]		= gd_backup.strModuleName
			,[intConcurrencyId]		= 1
			,[dblDebitForeign]		= 0.00
			,[dblDebitReport]		= 0.00
			,[dblCreditForeign]		= 0.00
			,[dblCreditReport]		= 0.00
			,[dblReportingRate]		= 0.00
			,[dblForeignRate]		= 0.00
	FROM	tblARInvoice i INNER JOIN tblARInvoiceDetail id
				ON i.[intInvoiceId] = id.[intInvoiceId] 
			INNER JOIN (
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
					AND s.ysnPosted = 1 
			)
				ON id.intInventoryShipmentItemId = si.intInventoryShipmentItemId
			INNER JOIN tblICItemLocation il 
				ON il.intItemId = si.intItemId
				AND il.intLocationId = s.intShipFromLocationId 
		
			CROSS APPLY (
				-- Get the valuation from the open period. 
				SELECT	value = SUM(-ROUND(t.dblQty * t.dblCost + t.dblValue, 2))
						,unit = SUM(-ROUND(t.dblQty * t.dblUOMQty, 2))
				FROM	tblICInventoryTransaction t
				WHERE	t.strTransactionId = s.strShipmentNumber
						AND t.intTransactionDetailId = si.intInventoryShipmentItemId
						AND t.ysnIsUnposted = 0 
						AND dbo.fnDateEquals(t.dtmDate, @dtmOpenPeriod) = 1
						AND dbo.fnDateNotEquals(t.dtmDate, s.dtmShipDate) = 1 -- T date is in the open period but was originally posted in the closed period. 
			) t
			CROSS APPLY (
				-- Get the backup and use as template to generate a new gl detail record.
				SELECT	TOP 1 *
				FROM	tblICRepostCOGSGLEntriesBackup gd_backup
				WHERE	gd_backup.strTransactionId = i.strInvoiceNumber
						AND gd_backup.intJournalLineNo = id.intInvoiceDetailId
						AND gd_backup.intAccountId = dbo.fnGetItemGLAccount(si.intItemId, il.intItemLocationId, 'Cost of Goods') 
			) gd_backup

			CROSS APPLY dbo.fnGetDebit(t.value) Debit
			CROSS APPLY dbo.fnGetCredit(t.value) Credit
			CROSS APPLY dbo.fnGetDebit(t.unit) DebitUnit
			CROSS APPLY dbo.fnGetCredit(t.unit) CreditUnit
			OUTER APPLY (
				SELECT	TOP 1 *
				FROM	tblGLDetail tgd
				WHERE	tgd.strTransactionId = i.strInvoiceNumber
						AND tgd.intJournalLineNo = id.intInvoiceDetailId
						AND tgd.ysnIsUnposted = 0 	
						AND tgd.intAccountId = dbo.fnGetItemGLAccount(si.intItemId, il.intItemLocationId, 'Cost of Goods') 
						AND dbo.fnDateEquals(tgd.dtmDate, @dtmOpenPeriod) = 1 
			) tgd

	WHERE	ISNULL(id.intInventoryShipmentItemId, 0) <> 0 
			AND i.ysnPosted = 1
			AND t.value IS NOT NULL 

	-- GL entries for Inventory In-Transit
	UNION ALL 
	SELECT	
			[dtmDate]		= @dtmOpenPeriod
			,[strBatchId]	= gd_backup.strBatchId
			,[intAccountId]	= gd_backup.intAccountId
			,[dblDebit]		= Credit.Value
			,[dblCredit]	= Debit.Value
			,[dblDebitUnit]	= CreditUnit.Value
			,[dblCreditUnit]	= DebitUnit.Value
			,[strDescription]	= gd_backup.strDescription
			,[strCode]			= 'AR'
			,[strReference]		= gd_backup.strReference
			,[intCurrencyId]	= gd_backup.intCurrencyId
			,[dblExchangeRate]	= gd_backup.dblExchangeRate
			,[dtmDateEntered]	= GETDATE()
			,[dtmTransactionDate]	= gd_backup.dtmTransactionDate
			,[strJournalLineDescription]	= gd_backup.strJournalLineDescription
			,[intJournalLineNo]	= gd_backup.intJournalLineNo
			,[ysnIsUnposted]	= 0 
			,[intUserId]		= gd_backup.intUserId
			,[intEntityId]		= gd_backup.intEntityId
			,[strTransactionId]	= gd_backup.strTransactionId
			,[intTransactionId]	= gd_backup.intTransactionId
			,[strTransactionType] = gd_backup.strTransactionType
			,[strTransactionForm]	= gd_backup.strTransactionForm
			,[strModuleName]		= gd_backup.strModuleName
			,[intConcurrencyId]		= 1
			,[dblDebitForeign]		= 0.00
			,[dblDebitReport]		= 0.00
			,[dblCreditForeign]		= 0.00
			,[dblCreditReport]		= 0.00
			,[dblReportingRate]		= 0.00
			,[dblForeignRate]		= 0.00
	FROM	tblARInvoice i INNER JOIN tblARInvoiceDetail id
				ON i.[intInvoiceId] = id.[intInvoiceId] 
			INNER JOIN (
				tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
					ON s.intInventoryShipmentId = si.intInventoryShipmentId
					AND s.ysnPosted = 1 
			)
				ON id.intInventoryShipmentItemId = si.intInventoryShipmentItemId
			INNER JOIN tblICItemLocation il 
				ON il.intItemId = si.intItemId
				AND il.intLocationId = s.intShipFromLocationId 
		
			CROSS APPLY (
				-- Get the valuation from the open period. 
				SELECT	value = SUM(-ROUND(t.dblQty * t.dblCost + t.dblValue, 2))
						,unit = SUM(-ROUND(t.dblQty * t.dblUOMQty, 2))
				FROM	tblICInventoryTransaction t
				WHERE	t.strTransactionId = s.strShipmentNumber
						AND t.intTransactionDetailId = si.intInventoryShipmentItemId
						AND t.ysnIsUnposted = 0 
						AND dbo.fnDateEquals(t.dtmDate, @dtmOpenPeriod) = 1
						AND dbo.fnDateNotEquals(t.dtmDate, s.dtmShipDate) = 1 -- T date is in the open period but was originally posted in the closed period. 

			) t
			CROSS APPLY (
				-- Get the backup and use as template to generate a new gl detail record.
				SELECT	TOP 1 *
				FROM	tblICRepostCOGSGLEntriesBackup gd_backup
				WHERE	gd_backup.strTransactionId = i.strInvoiceNumber
						AND gd_backup.intJournalLineNo = id.intInvoiceDetailId
						AND gd_backup.intAccountId = dbo.fnGetItemGLAccount(si.intItemId, il.intItemLocationId, 'Inventory In-Transit') 
			) gd_backup

			CROSS APPLY dbo.fnGetDebit(t.value) Debit
			CROSS APPLY dbo.fnGetCredit(t.value) Credit
			CROSS APPLY dbo.fnGetDebit(t.unit) DebitUnit
			CROSS APPLY dbo.fnGetCredit(t.unit) CreditUnit
			OUTER APPLY (
				SELECT	TOP 1 *
				FROM	tblGLDetail tgd
				WHERE	tgd.strTransactionId = i.strInvoiceNumber
						AND tgd.intJournalLineNo = id.intInvoiceDetailId
						AND tgd.ysnIsUnposted = 0 	
						AND tgd.intAccountId = dbo.fnGetItemGLAccount(si.intItemId, il.intItemLocationId, 'Inventory In-Transit') 
						AND dbo.fnDateEquals(tgd.dtmDate, @dtmOpenPeriod) = 1 
			) tgd

	WHERE	ISNULL(id.intInventoryShipmentItemId, 0) <> 0 
			AND i.ysnPosted = 1
			AND t.value IS NOT NULL 
END 

-- Delete the old GL Entries 
-- Those backup records that are still zero in debit and credit can be deleted. 
BEGIN 
	DELETE	gd 
	FROM	tblGLDetail gd 
			--INNER JOIN tblICRepostCOGSGLEntriesBackup gdBackup
			--	ON gd.intGLDetailId = gdBackup.intGLDetailId
	WHERE	gd.dblDebit = 0 
			AND gd.dblCredit = 0 
			AND gd.strCode IN ('IC', 'AR') 
END 

-- Rebuild the G/L Summary 
BEGIN 
	DELETE [dbo].[tblGLSummary]

	INSERT INTO tblGLSummary(
	intAccountId
	,dtmDate
	,dblDebit 
	,dblCredit
	,dblDebitUnit 
	,dblCreditUnit 
	,strCode
	,intConcurrencyId 
	)
	SELECT
			intAccountId
			,dtmDate
			,SUM(ISNULL(dblDebit,0)) as dblDebit
			,SUM(ISNULL(dblCredit,0)) as dblCredit
			,SUM(ISNULL(dblDebitUnit,0)) as dblDebitUnit
			,SUM(ISNULL(dblCreditUnit,0)) as dblCreditUnit
			,strCode
			,0 as intConcurrencyId
	FROM
		tblGLDetail
	WHERE ysnIsUnposted = 0	
	GROUP BY intAccountId, dtmDate, strCode
END