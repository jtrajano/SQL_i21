CREATE PROCEDURE uspSCCreateDirectInGLEntriesForAPAdjustment
	@TICKET_ID INT , --= 12192 --13194 	
	@USER_ID INT, --= 1
	@BILL_ID INT = NULL
AS
BEGIN
	SET NOCOUNT ON 


	DECLARE @ACCOUNT_CATEGORY_InventoryInTransitDirect NVARCHAR(50) = 'In-Transit Direct'
	DECLARE @ACCOUNT_CATEGORY_AP_Clearing NVARCHAR(50) = 'AP Clearing'
	DECLARE @ACCOUNT_CATEGORY_InventoryInTransit NVARCHAR(50) = 'General'
	DECLARE @intItemLocationId INT
	DECLARE @intAPClearingAccountId INT
	DECLARE @intInventoryInTransitAccountId INT
	DECLARE @intInventoryInTransitDirectAccountId INT
	DECLARE @intTicketProcessingLocation INT
	DECLARE @intTicketItemId INT
	DECLARE @strLocationName NVARCHAR(100)
	DECLARE @strItemNo NVARCHAR(100)
	DECLARE @GLEntries AS RecapTableType
	DECLARE @strBatchId NVARCHAR(50)
	DECLARE @strTicketNumber  NVARCHAR(50)
	DECLARE @GLDescription nvarchar(150) 


	DECLARE @GL_CODE NVARCHAR(50)
	DECLARE @GL_TRANSACTION_ID INT
	DECLARE @GL_TRANSACTION_STR NVARCHAR(100)
	DECLARE @GL_TRANSACTION_TYPE NVARCHAR(50)
	DECLARE @GL_MODULE NVARCHAR(100)
	DECLARE @GL_DATE NVARCHAR(100)

	SELECT TOP 1
				@intTicketProcessingLocation = intProcessingLocationId
				,@intTicketItemId = intItemId
				,@strTicketNumber = strTicketNumber
				,@GL_CODE = 'SCTKT'
				,@GL_TRANSACTION_ID = intTicketId
				,@GL_TRANSACTION_STR = strTicketNumber
				,@GL_TRANSACTION_TYPE = 'Scale Ticket'
				,@GL_MODULE = 'Scale'
				,@GL_DATE = dtmTicketDateTime
			FROM tblSCTicket
			WHERE intTicketId = @TICKET_ID 



	IF ISNULL(@BILL_ID, 0) > 0 
	SELECT
		@GL_CODE = 'AP',
		@GL_TRANSACTION_ID = intBillId,
		@GL_TRANSACTION_STR = strBillId,
		@GL_TRANSACTION_TYPE = 'Bill', 
		@GL_MODULE = 'Accounts Payable',
		@GL_DATE = dtmDate
	FROM tblAPBill
	WHERE intBillId = @BILL_ID


	-- Get Item Location Id
	SELECT TOP 1
		@intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intItemId = @intTicketItemId
		AND intLocationId = @intTicketProcessingLocation

	--Get Location Name
	SELECT TOP 1
		@strLocationName = strLocationName
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intTicketProcessingLocation

	--Get Item Name
	SELECt TOP 1
		@strItemNo = strItemNo
	FROM tblICItem
	WHERE intItemId = @intTicketItemId

	--Get the Accounts
	SELECT 
		@intAPClearingAccountId = dbo.fnGetItemGLAccount(@intTicketItemId, @intItemLocationId, @ACCOUNT_CATEGORY_AP_Clearing)                 
		,@intInventoryInTransitAccountId = dbo.fnGetItemGLAccount(@intTicketItemId, @intItemLocationId, @ACCOUNT_CATEGORY_InventoryInTransit) 
		,@intInventoryInTransitDirectAccountId = dbo.fnGetItemGLAccount(@intTicketItemId, @intItemLocationId, @ACCOUNT_CATEGORY_InventoryInTransitDirect) 
            

	EXEC uspSMGetStartingNumber 
		@intStartingNumberId = 3
		,@strID = @strBatchId OUT

	SET @GLDescription = 'Direct In Ticket Adjustment: ' + @strTicketNumber            
	-- Get the functional currency
	BEGIN 
		DECLARE @intFunctionalCurrencyId AS INT
		SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
	END 
	 -- General Account



	DECLARE @TICKET_ADJUSTMENT TABLE(
		id INT IDENTITY(1,1)
		, intTicketId INT
		, dblAmount NUMERIC(36, 18)
		, dblUnit NUMERIC(36, 18)
		, strAllocationType NVARCHAR(50)

	)

	INSERT INTO @TICKET_ADJUSTMENT (intTicketId, dblAmount, dblUnit, strAllocationType)
	SELECT 
		@TICKET_ID 
		, ROUND(ROUND(dbo.fnMultiply(BILL_DETAIL.dblCost, BILL_DETAIL.dblQtyReceived), 2) - ROUND(dbo.fnMultiply(ROUND((ISNULL(DISTRIBUTION_GL.dblFuture, 0)  + ISNULL(DISTRIBUTION_GL.dblBasis, 0)), 2), BILL_DETAIL.dblQtyReceived), 2), 2)
		, BILL_DETAIL.dblQtyReceived	
		, strAllocationType = CASE WHEN DISTRIBUTION_ALLOCATION.intSourceType = 1 THEN 'Contract'
											  WHEN DISTRIBUTION_ALLOCATION.intSourceType = 2 THEN 'Load'
											  WHEN DISTRIBUTION_ALLOCATION.intSourceType = 3 THEN 'Storage'
											  WHEN DISTRIBUTION_ALLOCATION.intSourceType = 4 THEN 'Spot'
										 END
	FROM tblSCTicketDistributionAllocation DISTRIBUTION_ALLOCATION
		JOIN tblAPBillDetail BILL_DETAIL
			ON DISTRIBUTION_ALLOCATION.intTicketDistributionAllocationId = BILL_DETAIL.intTicketDistributionAllocationId
		JOIN tblSCScaleDirectInDistributionAllocationForGL DISTRIBUTION_GL
			ON DISTRIBUTION_ALLOCATION.intTicketDistributionAllocationId = DISTRIBUTION_GL.intTicketDistributionAllocationId
	WHERE DISTRIBUTION_ALLOCATION.intTicketId = @TICKET_ID 


	IF EXISTS(SELECT TOP 1 1 FROM @TICKET_ADJUSTMENT WHERE dblAmount != 0)
	BEGIN

		INSERT INTO @GLEntries 
		(
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
		SELECT	
			dtmDate						= @GL_DATE
			,strBatchId					= @strBatchId
			,intAccountId				= ISNULL(@intInventoryInTransitDirectAccountId, @intInventoryInTransitAccountId)
			,dblDebit					= CASE WHEN B.dblAmount < 0 THEN 0 ELSE ABS(B.dblAmount) END
			,dblCredit					= CASE WHEN B.dblAmount < 0 THEN ABS(B.dblAmount) ELSE 0 END
			,dblDebitUnit				= CASE WHEN B.dblAmount < 0 THEN 0 ELSE ABS(B.dblUnit) END
			,dblCreditUnit				= CASE WHEN B.dblAmount < 0 THEN ABS(B.dblUnit) ELSE 0 END
			,strDescription				= GLAccount.strDescription + '. ' + @GLDescription + ' - ' + B.strAllocationType
			,strCode					= @GL_CODE
			,strReference				= '' 
			,intCurrencyId				= A.intCurrencyId
			,dblExchangeRate			= 1
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= @GL_DATE
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= 52
			,ysnIsUnposted				= 0
			,intUserId					= @USER_ID
			,intEntityId				= NULL 
			,strTransactionId			= @GL_TRANSACTION_STR
			,intTransactionId			= @GL_TRANSACTION_ID
			,strTransactionType			= @GL_TRANSACTION_TYPE
			,strTransactionForm			= @GL_TRANSACTION_TYPE
			,strModuleName				= @GL_MODULE
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN B.dblAmount < 0 THEN 0 ELSE ABS(B.dblAmount) END
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN B.dblAmount < 0 THEN ABS(B.dblAmount) ELSE 0 END
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= 1		
		FROM tblSCTicket A
		INNER JOIN @TICKET_ADJUSTMENT B
			ON A.intTicketId = B.intTicketId 
		OUTER APPLY (
			SELECT TOP 1
				strDescription
			FROM tblGLAccount
			WHERE intAccountId = ISNULL(@intInventoryInTransitDirectAccountId, @intInventoryInTransitAccountId)
		) GLAccount
		WHERE A.intTicketId = @TICKET_ID 
			AND B.dblAmount != 0

		-- AP Clearing 
		INSERT INTO @GLEntries 
		(
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
		SELECT	
			dtmDate						= A.dtmTicketDateTime
			,strBatchId					= @strBatchId
			,intAccountId				= @intAPClearingAccountId
			,dblDebit					= CASE WHEN B.dblAmount < 0 THEN ABS(B.dblAmount) ELSE 0 END
			,dblCredit					= CASE WHEN B.dblAmount < 0 THEN 0 ELSE ABS(B.dblAmount) END
			,dblDebitUnit				= CASE WHEN B.dblAmount < 0 THEN ABS(B.dblUnit)  ELSE 0 END
			,dblCreditUnit				= CASE WHEN B.dblAmount < 0 THEN 0 ELSE ABS(B.dblUnit)  END
			,strDescription				= GLAccount.strDescription + '. ' + @GLDescription + ' - ' + B.strAllocationType
			,strCode					= @GL_CODE
			,strReference				= '' 
			,intCurrencyId				= A.intCurrencyId
			,dblExchangeRate			= 1
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= @GL_DATE
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= 52
			,ysnIsUnposted				= 0
			,intUserId					= @USER_ID
			,intEntityId				= NULL 
			,strTransactionId			= @GL_TRANSACTION_STR
			,intTransactionId			= @GL_TRANSACTION_ID
			,strTransactionType			= @GL_TRANSACTION_TYPE
			,strTransactionForm			= @GL_TRANSACTION_TYPE
			,strModuleName				= @GL_MODULE
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN B.dblAmount < 0 THEN ABS(B.dblAmount) ELSE 0 END
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN B.dblAmount < 0 THEN 0 ELSE ABS(B.dblAmount) END
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= 1		
		FROM tblSCTicket A
		INNER JOIN @TICKET_ADJUSTMENT B
			ON A.intTicketId = B.intTicketId 
		OUTER APPLY (
			SELECT TOP 1
				strDescription
			FROM tblGLAccount
			WHERE intAccountId = @intAPClearingAccountId
		) GLAccount
		WHERE A.intTicketId = @TICKET_ID 
			AND B.dblAmount != 0
		
		IF EXISTS ( SELECT TOP 1 1 FROM @GLEntries)
			EXEC uspGLBookEntries @GLEntries, 1	

	END

END