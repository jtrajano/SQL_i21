CREATE PROCEDURE [testi21Database].[test uspICUnpostCosting for posted Inventory Receipt]
AS
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake posted transactions - Add Stock];
	END 

--BEGIN
--	-- Arrange 
--	BEGIN 
--		EXEC [testi21Database].[Fake posted transactions for testing the unposting];

--		-- Declare the variables for grains (item)
--		DECLARE @WetGrains AS INT = 1
--				,@StickyGrains AS INT = 2
--				,@PremiumGrains AS INT = 3
--				,@ColdGrains AS INT = 4
--				,@HotGrains AS INT = 5
--				,@InvalidItem AS INT = -1

--		-- Declare the variables for location
--		DECLARE @Default_Location AS INT = 1
--				,@NewHaven AS INT = 2
--				,@BetterHaven AS INT = 3
--				,@InvalidLocation AS INT = -1
				
--		-- Declare the variables for the currencies
--		DECLARE @USD AS INT = 1;

--		-- Create the expected and actual tables. 
--		CREATE TABLE expectedGLDetail (
--			[dtmDate]                    DATETIME         NOT NULL
--			,[strBatchId]                NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL
--			,[intAccountId]              INT              NULL
--			,[dblDebit]                  NUMERIC (18, 6)  NULL
--			,[dblCredit]                 NUMERIC (18, 6)  NULL
--			,[dblDebitUnit]              NUMERIC (18, 6)  NULL
--			,[dblCreditUnit]             NUMERIC (18, 6)  NULL
--			,[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
--			,[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL    
--			,[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
--			,[intCurrencyId]             INT              NULL
--			,[dblExchangeRate]           NUMERIC (38, 20) NOT NULL
--			,[dtmTransactionDate]        DATETIME         NULL
--			,[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL
--			,[intJournalLineNo]			 INT              NULL
--			,[ysnIsUnposted]             BIT              NOT NULL    
--			,[intUserId]                 INT              NULL
--			,[intEntityId]				 INT              NULL
--			,[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL
--			,[intTransactionId]          INT              NULL
--			,[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
--			,[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
--			,[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
--			,[intConcurrencyId]          INT              DEFAULT 1 NOT NULL		
--		)

--		CREATE TABLE actualGLDetail (
--			[dtmDate]                    DATETIME         NOT NULL
--			,[strBatchId]                NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL
--			,[intAccountId]              INT              NULL
--			,[dblDebit]                  NUMERIC (18, 6)  NULL
--			,[dblCredit]                 NUMERIC (18, 6)  NULL
--			,[dblDebitUnit]              NUMERIC (18, 6)  NULL
--			,[dblCreditUnit]             NUMERIC (18, 6)  NULL
--			,[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
--			,[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL    
--			,[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
--			,[intCurrencyId]             INT              NULL
--			,[dblExchangeRate]           NUMERIC (38, 20) NOT NULL
--			,[dtmTransactionDate]        DATETIME         NULL
--			,[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL
--			,[intJournalLineNo]			 INT              NULL
--			,[ysnIsUnposted]             BIT              NOT NULL    
--			,[intUserId]                 INT              NULL
--			,[intEntityId]				 INT              NULL
--			,[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL
--			,[intTransactionId]          INT              NULL
--			,[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
--			,[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
--			,[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
--			,[intConcurrencyId]          INT              DEFAULT 1 NOT NULL		
--		)

--		CREATE TABLE expectedInventoryTransaction (
--			[intItemId]								INT NOT NULL
--			,[intLocationId]						INT NOT NULL
--			,[dtmDate]								DATETIME NOT NULL
--			,[dblUnitQty]							NUMERIC(18, 6) NOT NULL DEFAULT 0 
--			,[dblCost]								NUMERIC(18, 6) NOT NULL DEFAULT 0 
--			,[dblValue]								NUMERIC(18, 6) NULL 
--			,[dblSalesPrice]						NUMERIC(18, 6) NOT NULL DEFAULT 0 
--			,[intCurrencyId]						INT NULL
--			,[dblExchangeRate]						DECIMAL (38, 20) DEFAULT 1 NOT NULL
--			,[intTransactionId]						INT NOT NULL 
--			,[strTransactionId]						NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL 
--			,[strBatchId]							NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL 
--			,[intTransactionTypeId]					INT NOT NULL 
--			,[intLotId]								INT NULL 
--			,[ysnIsUnposted]						BIT NULL
--			,[intRelatedInventoryTransactionId]		INT NULL
--			,[intRelatedTransactionId]				INT NULL
--			,[strRelatedTransactionId]				NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
--			,[strTransactionForm]					NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL
--			,[dtmCreated]							DATETIME NULL 
--			,[intCreatedUserId]						INT NULL 
--			,[intConcurrencyId]						INT NOT NULL DEFAULT 1 		
--		)

--		CREATE TABLE actualInventoryTransaction (
--			[intItemId]								INT NOT NULL
--			,[intLocationId]						INT NOT NULL
--			,[dtmDate]								DATETIME NOT NULL
--			,[dblUnitQty]							NUMERIC(18, 6) NOT NULL DEFAULT 0 
--			,[dblCost]								NUMERIC(18, 6) NOT NULL DEFAULT 0 
--			,[dblValue]								NUMERIC(18, 6) NULL 
--			,[dblSalesPrice]						NUMERIC(18, 6) NOT NULL DEFAULT 0 
--			,[intCurrencyId]						INT NULL
--			,[dblExchangeRate]						DECIMAL (38, 20) DEFAULT 1 NOT NULL
--			,[intTransactionId]						INT NOT NULL 
--			,[strTransactionId]						NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL 
--			,[strBatchId]							NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL 
--			,[intTransactionTypeId]					INT NOT NULL 
--			,[intLotId]								INT NULL 
--			,[ysnIsUnposted]						BIT NULL
--			,[intRelatedInventoryTransactionId]		INT NULL
--			,[intRelatedTransactionId]				INT NULL
--			,[strRelatedTransactionId]				NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
--			,[strTransactionForm]					NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL
--			,[dtmCreated]							DATETIME NULL 
--			,[intCreatedUserId]						INT NULL 
--			,[intConcurrencyId]						INT NOT NULL DEFAULT 1 	
--		)
--	END 
	
--	-- Act 
--	BEGIN 
--		DECLARE @strBatchId AS NVARCHAR(20) = 'BATCH-200001'
--				,@intTransactionId AS INT = 1
--				,@strTransactionId AS NVARCHAR(40) = 'PURCHASE-100000'
--				,@intUserId AS INT = 1

--		DECLARE @GLDetail AS dbo.RecapTableType

--		INSERT INTO @GLDetail
--		EXEC dbo.uspICUnpostCosting
--			@intTransactionId
--			,@strTransactionId
--			,@strBatchId
--			,@intUserId
			
--		INSERT INTO actualGLDetail (
--				[dtmDate]                    
--				,[strBatchId]                
--				,[intAccountId]              
--				,[dblDebit]                  
--				,[dblCredit]                 
--				,[dblDebitUnit]              
--				,[dblCreditUnit]             
--				,[strDescription]            
--				,[strCode]                   
--				,[strReference]              
--				,[intCurrencyId]             
--				,[dblExchangeRate]           
--				,[dtmTransactionDate]        
--				,[strJournalLineDescription] 
--				,[intJournalLineNo]			 
--				,[ysnIsUnposted]             
--				,[intUserId]                 
--				,[intEntityId]				 
--				,[strTransactionId]          
--				,[intTransactionId]          
--				,[strTransactionType]        
--				,[strTransactionForm]        
--				,[strModuleName]             
--				,[intConcurrencyId]          	
--		)
--		SELECT	[dtmDate]                    
--				,[strBatchId]                
--				,[intAccountId]              
--				,[dblDebit]                  
--				,[dblCredit]                 
--				,[dblDebitUnit]              
--				,[dblCreditUnit]             
--				,[strDescription]            
--				,[strCode]                   
--				,[strReference]              
--				,[intCurrencyId]             
--				,[dblExchangeRate]           
--				,[dtmTransactionDate]        
--				,[strJournalLineDescription] 
--				,[intJournalLineNo]			 
--				,[ysnIsUnposted]             
--				,[intUserId]                 
--				,[intEntityId]				 
--				,[strTransactionId]          
--				,[intTransactionId]          
--				,[strTransactionType]        
--				,[strTransactionForm]        
--				,[strModuleName]             
--				,[intConcurrencyId]          	
--		FROM @GLDetail
		
--	END 
	
--	-- Assert
--	BEGIN
--		EXEC tSQLt.AssertEqualsTable 'expectedGLDetail', 'actualGLDetail';
--		EXEC tSQLt.AssertEqualsTable 'expectedInventoryTransaction', 'actualInventoryTransaction';
--	END 

--	-- Clean-up: remove the tables used in the unit test
--	IF OBJECT_ID('expectedGLDetail') IS NOT NULL 
--		DROP TABLE expectedGLDetail

--	IF OBJECT_ID('actualGLDetail') IS NOT NULL 
--		DROP TABLE dbo.actualGLDetail

--	IF OBJECT_ID('expectedInventoryTransaction') IS NOT NULL 
--		DROP TABLE expectedInventoryTransaction

--	IF OBJECT_ID('actualInventoryTransaction') IS NOT NULL 
--		DROP TABLE dbo.actualInventoryTransaction
--END 