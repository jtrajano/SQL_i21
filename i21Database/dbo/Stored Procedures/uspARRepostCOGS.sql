CREATE PROCEDURE uspARRepostCOGS
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18,6)
		,@LastInvoiceId INT

SET @ZeroDecimal = 0.000000

DECLARE @Invoice AS TABLE
([intInvoiceId]					INT
,[strInvoiceNumber]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS
,[ysnProcessed]					BIT
)
INSERT INTO @Invoice
([intInvoiceId]
,[strInvoiceNumber]
,[ysnProcessed]
)
SELECT DISTINCT --TOP 20 
	 ARI.[intInvoiceId]
	,ARI.[strInvoiceNumber]
	,0
FROM
	tblARInvoice ARI
INNER JOIN
	tblARInvoiceDetail ARID
		ON ARI.[intInvoiceId] = ARID.[intInvoiceId] 
WHERE
	ISNULL(ARID.[intInventoryShipmentItemId],0) <> @ZeroDecimal
	--AND ARI.[intInvoiceId] > @LastInvoiceId
	--AND strInvoiceNumber = 'SI-10325'
ORDER BY
	ARI.[intInvoiceId]
	
	
SELECT TOP 1 [intInvoiceId] FROM @Invoice ORDER BY [intInvoiceId] DESC
	
WHILE EXISTS (SELECT NULL FROM @Invoice)
BEGIN
	DECLARE @InvoiceId INT
			,@InvoiceNumber NVARCHAR(25)
			
	SELECT TOP 1
		 @InvoiceId		= [intInvoiceId]
		,@InvoiceNumber	= [strInvoiceNumber]
	FROM
		@Invoice
	ORDER BY
		[intInvoiceId]
		
		
	--Update GL Entries	- Debit(COGS)	
	DECLARE @GLDebit AS TABLE
	([intGLDetailId]	INT NULL
	,[dblDebit]			NUMERIC(18, 6) NULL
	,[ysnProcessed]		BIT NULL
	,[strBatchId]		NVARCHAR(20) NULL
	,[dtmDate]			DATETIME NULL
	,[intAccountId]		INT NULL
	,[strDescription]	NVARCHAR(255) NULL
	,[strReference]		NVARCHAR(255) NULL
	,[intCurrencyId]	INT NULL
	,[dblExchangeRate]	NUMERIC(38, 20) NULL
	,[dtmDateEntered]	DATETIME NULL
	,[dtmTransactionDate]	DATETIME NULL
	,[strJournalLineDescription] NVARCHAR(250) NULL
	,[intJournalLineNo] INT NULL
	,[intUserId]		INT NULL
	,[intEntityId]		INT NULL
	,[strTransactionId] NVARCHAR(40)
	,[intTransactionId]	INT NULL
	,[strTransactionType] NVARCHAR(255)
	,[strTransactionForm] NVARCHAR(255)
	,[strModuleName]	NVARCHAR(255)
	)
	
	DELETE FROM @GLDebit
	
	INSERT INTO @GLDebit
		([intGLDetailId]
		,[dblDebit]
		,[ysnProcessed]
		,[strBatchId]
		,[dtmDate]
		,[intAccountId]
		,[strDescription]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		)
	SELECT --TOP 1
		 GLD.[intGLDetailId]
		,GLD.[dblDebit]
		,0
		,GLD.[strBatchId]
		,GLD.[dtmDate]
		,GLD.[intAccountId]
		,GLD.[strDescription]
		,GLD.[strReference]
		,GLD.[intCurrencyId]
		,GLD.[dblExchangeRate]
		,GLD.[dtmDateEntered]
		,GLD.[dtmTransactionDate]
		,GLD.[strJournalLineDescription]
		,GLD.[intJournalLineNo]
		,GLD.[intUserId]
		,GLD.[intEntityId]
		,GLD.[strTransactionId]
		,GLD.[intTransactionId]
		,GLD.[strTransactionType]
		,GLD.[strTransactionForm]
		,GLD.[strModuleName]
	FROM
		tblGLDetail GLD
	INNER JOIN
		vyuGLAccountDetail GLAD
			ON GLD.[intAccountId] = GLAD.[intAccountId]
			AND GLAD.[strAccountCategory] = 'Cost of Goods'
	WHERE
		GLD.[ysnIsUnposted] = 0	
		AND GLD.[strTransactionId] = @InvoiceNumber
		AND GLD.[intTransactionId] = @InvoiceId	
	ORDER BY
		GLD.[intGLDetailId]			
		
	IF @@ERROR <> 0 GOTO GOTO_ERROR
			
	IF EXISTS (SELECT TOP 1 1 FROM @GLDebit)
	BEGIN 

		DECLARE @GLDebitEntries AS TABLE
		([intInvoiceDetailId]	INT
		,[intInvoiceId]			INT
		,[strInvoiceNumber]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS
		,[intAccountId]			INT
		,[dblDebit]				NUMERIC(18, 6)
		,[dblDebitUnit]			NUMERIC(18, 6)
		,[strDescription]		NVARCHAR(500) COLLATE Latin1_General_CI_AS
		,[strItemDescription]	NVARCHAR(500) COLLATE Latin1_General_CI_AS
		,[ysnProcessed]			BIT
		,[intInventoryShipmentItemId]			INT
		)
	
		DELETE FROM @GLDebitEntries
	
		INSERT INTO @GLDebitEntries
		([intInvoiceDetailId]
		,[intInvoiceId]
		,[strInvoiceNumber]
		,[intAccountId]
		,[dblDebit]
		,[dblDebitUnit]
		,[strDescription]
		,[strItemDescription]
		,[ysnProcessed]
		,[intInventoryShipmentItemId]
		)
		SELECT     
			 ARID.[intInvoiceDetailId]
			,ARI.[intInvoiceId]
			,ARI.[strInvoiceNumber]
			,[dbo].[fnGetItemGLAccount](ARID.[intItemId], ICGIS.[intItemLocationId], 'Cost of Goods') -- IST.[intCOGSAccountId]  
			,CASE WHEN ARI.[strTransactionType] = 'Invoice' THEN (ABS(ICT.[dblQty]) * ICT.[dblCost]) ELSE 0 END  
			,CASE WHEN ARI.[strTransactionType] = 'Invoice' THEN (ABS(ICT.[dblQty]) * ICT.[dblUOMQty]) ELSE 0 END  
			,ARI.[strComments]
			,ARID.[strItemDescription]
			,0
			,ISD.[intInventoryShipmentItemId]
		FROM
			tblICInventoryTransaction ICT  
		INNER JOIN  
			tblICInventoryShipmentItem ISD  
				ON ISD.[intInventoryShipmentItemId] = ICT.[intTransactionDetailId]  	
		INNER JOIN  
			tblICInventoryShipment ISH  
				ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]  
				AND ISH.[intInventoryShipmentId] = ICT.[intTransactionId] 
				AND ISH.[strShipmentNumber] = ICT.[strTransactionId]  
		INNER JOIN
			tblARInvoiceDetail ARID  
			ON ARID.[intInventoryShipmentItemId] = ISD.[intInventoryShipmentItemId] 
		INNER JOIN     
			tblARInvoice ARI   
				ON ARID.[intInvoiceId] = ARI.[intInvoiceId]  
				AND ISNULL(ARI.[intPeriodsToAccrue],0) <= 1  
		INNER JOIN  
			tblICItemUOM ItemUOM   
				ON ItemUOM.[intItemUOMId] = ARID.[intItemUOMId]
		LEFT OUTER JOIN
			vyuICGetItemStock ICGIS
					ON ARID.[intItemId] = ICGIS.[intItemId]
					AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId]
		WHERE  
			ARID.[dblTotal] <> @ZeroDecimal  
			AND ARID.[intInventoryShipmentItemId] IS NOT NULL AND ARID.[intInventoryShipmentItemId] <> 0  
			AND ARID.[intItemId] IS NOT NULL AND ARID.[intItemId] <> 0  
			AND ARI.[strType] <> 'Debit Memo' 
			AND ARI.[intInvoiceId] = @InvoiceId
			AND ISNULL(ICT.[ysnIsUnposted],0) = 0		
		
		DELETE FROM tblGLDetail
		WHERE
			[ysnIsUnposted] = 0
			AND [intGLDetailId] IN (SELECT [intGLDetailId] FROM @GLDebit)
			AND [strTransactionId] = @InvoiceNumber
			AND [intTransactionId] = @InvoiceId
		
		
		IF @@ERROR <> 0 GOTO GOTO_ERROR				
			
		INSERT INTO [tblGLDetail]
			   ([dtmDate]
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
			   ,[dblForeignRate])
		 SELECT
				(SELECT TOP 1 GLD.[dtmDate] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLD.[strBatchId] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,GLDE.[intAccountId] --(SELECT TOP 1 GLD.[intAccountId] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId]) 
			   ,ROUND(GLDE.[dblDebit],2)
			   ,@ZeroDecimal
			   ,ROUND(GLDE.[dblDebitUnit],2)
			   ,@ZeroDecimal
			   ,GLDE.[strDescription]
			   ,'AR'
			   ,(SELECT TOP 1 GLD.[strReference] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId]) 
			   ,(SELECT TOP 1 GLD.[intCurrencyId] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLD.[dblExchangeRate] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLD.[dtmDateEntered] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLD.[dtmTransactionDate] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 [strItemDescription] FROM tblARInvoiceDetail WHERE tblARInvoiceDetail.[intInvoiceDetailId] = GLDE.[intInvoiceDetailId])
			   ,(SELECT TOP 1 [intInvoiceDetailId] FROM tblARInvoiceDetail WHERE tblARInvoiceDetail.[intInvoiceDetailId] = GLDE.[intInvoiceDetailId])
			   ,0
			   ,(SELECT TOP 1 GLD.[intUserId] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLD.[intEntityId] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLD.[strTransactionId] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLD.[intTransactionId] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLD.[strTransactionType] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLD.[strTransactionForm] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLD.[strModuleName] FROM @GLDebit GLD WHERE GLD.[intTransactionId] = GLDE.[intInvoiceId])
			   ,1
			   ,@ZeroDecimal
			   ,@ZeroDecimal
			   ,@ZeroDecimal
			   ,@ZeroDecimal
			   ,@ZeroDecimal
			   ,@ZeroDecimal
		FROM
			@GLDebitEntries GLDE			
		WHERE
			GLDE.[strInvoiceNumber] = @InvoiceNumber
			AND GLDE.[intInvoiceId] = @InvoiceId									

		IF @@ERROR <> 0 GOTO GOTO_ERROR	
	
	
	
		------------------------------------------------------------------------------------------------------	
		
		--Update GL Entries	- Credit	
		DECLARE @GLCredit AS TABLE
		([intGLDetailId]	INT
		,[dblCredit]		NUMERIC(18, 6)
		,[ysnProcessed]		BIT
		,[strBatchId]		NVARCHAR(20) NULL
		,[dtmDate]			DATETIME NULL
		,[intAccountId]		INT NULL
		,[strDescription]	NVARCHAR(255) NULL
		,[strReference]		NVARCHAR(255) NULL
		,[intCurrencyId]	INT NULL
		,[dblExchangeRate]	NUMERIC(38, 20) NULL
		,[dtmDateEntered]	DATETIME NULL
		,[dtmTransactionDate]	DATETIME NULL
		,[strJournalLineDescription] NVARCHAR(250) NULL
		,[intJournalLineNo] INT NULL
		,[intUserId]		INT NULL
		,[intEntityId]		INT NULL
		,[strTransactionId] NVARCHAR(40)
		,[intTransactionId]	INT NULL
		,[strTransactionType] NVARCHAR(255)
		,[strTransactionForm] NVARCHAR(255)
		,[strModuleName]	NVARCHAR(255)
		)
	
		DELETE FROM @GLCredit
	
		INSERT INTO @GLCredit
			([intGLDetailId]
			,[dblCredit]
			,[ysnProcessed]
			,[strBatchId]
			,[dtmDate]
			,[intAccountId]
			,[strDescription]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			)
		SELECT --TOP 1
			 GLD.[intGLDetailId]
			,GLD.[dblCredit]
			,0
			,GLD.[strBatchId]
			,GLD.[dtmDate]
			,GLD.[intAccountId]
			,GLD.[strDescription]
			,GLD.[strReference]
			,GLD.[intCurrencyId]
			,GLD.[dblExchangeRate]
			,GLD.[dtmDateEntered]
			,GLD.[dtmTransactionDate]
			,GLD.[strJournalLineDescription]
			,GLD.[intJournalLineNo]
			,GLD.[intUserId]
			,GLD.[intEntityId]
			,GLD.[strTransactionId]
			,GLD.[intTransactionId]
			,GLD.[strTransactionType]
			,GLD.[strTransactionForm]
			,GLD.[strModuleName]
		FROM
			tblGLDetail GLD
		INNER JOIN
			vyuGLAccountDetail GLAD
				ON GLD.[intAccountId] = GLAD.[intAccountId]
				AND GLAD.[strAccountCategory] = 'Inventory In-Transit'
		WHERE
			GLD.[ysnIsUnposted] = 0
			AND GLD.[strTransactionId] = @InvoiceNumber
			AND GLD.[intTransactionId] = @InvoiceId	
		ORDER BY
			GLD.[intGLDetailId]
		
		IF @@ERROR <> 0 GOTO GOTO_ERROR				
		
		DECLARE @GLCreditEntries AS TABLE
		([intInvoiceDetailId]	INT
		,[intInvoiceId]			INT
		,[strInvoiceNumber]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS
		,[intAccountId]			INT
		,[dblCredit]			NUMERIC(18, 6)
		,[dblCreditUnit]		NUMERIC(18, 6)
		,[strDescription]		NVARCHAR(500) COLLATE Latin1_General_CI_AS
		,[strItemDescription]	NVARCHAR(500) COLLATE Latin1_General_CI_AS
		,[ysnProcessed]			BIT
		)
	
		DELETE FROM  @GLCreditEntries
	
		INSERT INTO @GLCreditEntries
		([intInvoiceDetailId]
		,[intInvoiceId]
		,[strInvoiceNumber]
		,[intAccountId]
		,[dblCredit]
		,[dblCreditUnit]
		,[strDescription]
		,[strItemDescription]
		,[ysnProcessed]
		)
		SELECT     
			 ARID.[intInvoiceDetailId]
			,ARI.[intInvoiceId]  
			,ARI.[strInvoiceNumber]  
			,[dbo].[fnGetItemGLAccount](ARID.[intItemId], ICGIS.[intItemLocationId], 'Inventory In-Transit') -- IST.[intInventoryInTransitAccountId]  
			,CASE WHEN ARI.[strTransactionType] = 'Invoice' THEN (ABS(ICT.[dblQty]) * ICT.[dblCost]) ELSE 0 END  
			,CASE WHEN ARI.[strTransactionType] = 'Invoice' THEN (ABS(ICT.[dblQty]) * ICT.[dblUOMQty]) ELSE 0 END  
			,ARI.[strComments]
			,ARID.[strItemDescription]
			,0
		FROM 
			tblICInventoryTransaction ICT  
		INNER JOIN  
			tblICInventoryShipmentItem ISD  
				ON ISD.[intInventoryShipmentItemId] = ICT.[intTransactionDetailId]  	
		INNER JOIN  
			tblICInventoryShipment ISH  
				ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId] 
				AND ISH.[intInventoryShipmentId] = ICT.[intTransactionId] 
				AND ISH.[strShipmentNumber] = ICT.[strTransactionId]  
		INNER JOIN						
			tblARInvoiceDetail ARID  
				ON ARID.[intInventoryShipmentItemId] = ISD.[intInventoryShipmentItemId]
		INNER JOIN     
			tblARInvoice ARI   
				ON ARID.[intInvoiceId] = ARI.[intInvoiceId]  
				AND ISNULL(ARI.[intPeriodsToAccrue],0) <= 1  
		INNER JOIN  
			tblICItemUOM ItemUOM   
				ON ItemUOM.[intItemUOMId] = ARID.[intItemUOMId]
		LEFT OUTER JOIN
			vyuICGetItemStock ICGIS
					ON ARID.[intItemId] = ICGIS.[intItemId]
					AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId]			              
		WHERE  
			ARID.[dblTotal] <> @ZeroDecimal  
			AND ARID.[intInventoryShipmentItemId] IS NOT NULL AND ARID.[intInventoryShipmentItemId] <> 0  
			AND ARID.[intItemId] IS NOT NULL AND ARID.[intItemId] <> 0  
			AND ARI.[strType] <> 'Debit Memo' 
			AND ARI.[intInvoiceId] = @InvoiceId 
			AND ISNULL(ICT.[ysnIsUnposted],0) = 0
		
		IF @@ERROR <> 0 GOTO GOTO_ERROR	
		
		
		DELETE FROM tblGLDetail
		WHERE
			[ysnIsUnposted] = 0
			AND [intGLDetailId] IN (SELECT [intGLDetailId] FROM @GLCredit)
			AND [strTransactionId] = @InvoiceNumber
			AND [intTransactionId] = @InvoiceId
		
		
		IF @@ERROR <> 0 GOTO GOTO_ERROR				
			
		INSERT INTO [tblGLDetail]
			   ([dtmDate]
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
			   ,[dblForeignRate])
		 SELECT
				(SELECT TOP 1 GLC.[dtmDate] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[strBatchId] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,GLDE.[intAccountId] --(SELECT TOP 1 GLC.[intAccountId]  FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,@ZeroDecimal
			   ,ROUND(GLDE.[dblCredit],2)
			   ,@ZeroDecimal
			   ,ROUND(GLDE.[dblCreditUnit],2)
			   ,GLDE.[strDescription]
			   ,'AR'
			   ,(SELECT TOP 1 GLC.[strReference] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[intCurrencyId] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[dblExchangeRate] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[dtmDateEntered] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[dtmTransactionDate] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 [strItemDescription] FROM tblARInvoiceDetail WHERE tblARInvoiceDetail.[intInvoiceDetailId] = GLDE.[intInvoiceDetailId])
			   ,(SELECT TOP 1 [intInvoiceDetailId] FROM tblARInvoiceDetail WHERE tblARInvoiceDetail.[intInvoiceDetailId] = GLDE.[intInvoiceDetailId])
			   ,0
			   ,(SELECT TOP 1 GLC.[intUserId] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[intEntityId] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[strTransactionId] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[intTransactionId] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[strTransactionType] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[strTransactionForm] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,(SELECT TOP 1 GLC.[strModuleName] FROM @GLCredit GLC WHERE GLC.[intTransactionId] = GLDE.[intInvoiceId])
			   ,1
			   ,@ZeroDecimal
			   ,@ZeroDecimal
			   ,@ZeroDecimal
			   ,@ZeroDecimal
			   ,@ZeroDecimal
			   ,@ZeroDecimal
		FROM
			@GLCreditEntries GLDE
		WHERE
			GLDE.[strInvoiceNumber] = @InvoiceNumber
			AND GLDE.[intInvoiceId] = @InvoiceId
						 	
							

		IF @@ERROR <> 0 GOTO GOTO_ERROR			

	END 
		
	--UPDATE @Invoice SET [ysnProcessed] = 1 WHERE [intInvoiceId] = @InvoiceId AND [strInvoiceNumber] = @InvoiceNumber
	DELETE FROM @Invoice WHERE [intInvoiceId] = @InvoiceId AND [strInvoiceNumber] = @InvoiceNumber
END
 

BEGIN 
 DELETE [dbo].[tblGLSummary]

 INSERT INTO tblGLSummary
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

GOTO GOTO_EXIT

GOTO_ERROR:
SELECT [@InvoiceNumber] = @InvoiceNumber, [@InvoiceId] = @InvoiceId

GOTO_EXIT:
