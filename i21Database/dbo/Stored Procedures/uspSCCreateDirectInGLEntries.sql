CREATE PROCEDURE [dbo].[uspSCCreateDirectInGLEntries]
	@intTicketId INT
    ,@ysnDistribute BIT
    ,@intUserId INT
AS
BEGIN
    BEGIN TRY
        DECLARE @ErrMsg NVARCHAR(MAX)

        DECLARE @ACCOUNT_CATEGORY_InventoryInTransit NVARCHAR(50) = 'General'
        DECLARE @ACCOUNT_CATEGORY_AP_Clearing NVARCHAR(50) = 'AP Clearing'
        DECLARE @GLDescription nvarchar(150) 

        DECLARE @intTicketProcessingLocation INT
        DECLARE @intItemLocationId INT
        DECLARE @intAPClearingAccountId INT
        DECLARE @intInventoryInTransitAccountId INT
        DECLARE @strLocationName NVARCHAR(100)
        DECLARE @strItemNo NVARCHAR(100)
        DECLARE @strTicketNumber  NVARCHAR(50)
        DECLARE @intTicketItemId INT
        DECLARE @intAPClearingAccount INT
        DECLARE @strBatchId NVARCHAR(50)
        DECLARE @CurrentDate DATETIME 

        DECLARE @GLEntries AS RecapTableType
        DECLARE @ItemInTransitCostingTableType AS ItemInTransitCostingTableType
        
        
        IF(@ysnDistribute = 1)
        BEGIN
            --Get Ticket Details
            SELECT TOP 1
                @intTicketProcessingLocation = intProcessingLocationId
                ,@intTicketItemId = intItemId
                ,@strTicketNumber = strTicketNumber
            FROM tblSCTicket
            WHERE intTicketId = @intTicketId

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
                @intAPClearingAccountId = dbo.fnGetItemGLAccount(@intTicketItemId, @intTicketProcessingLocation, @ACCOUNT_CATEGORY_AP_Clearing) 
                ,@intInventoryInTransitAccountId = dbo.fnGetItemGLAccount(@intTicketItemId, @intTicketProcessingLocation, @ACCOUNT_CATEGORY_InventoryInTransit) 
            
            
            -- Get the functional currency
            BEGIN 
                DECLARE @intFunctionalCurrencyId AS INT
                SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
            END 


            ---------------------Validate Account ids
            BEGIN
                IF @intAPClearingAccountId IS NULL
                BEGIN
                    -- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
                    EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_AP_Clearing;
                    RETURN -1;
                END

                IF @intInventoryInTransitAccountId IS NULL
                BEGIN
                    -- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
                    EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_InventoryInTransit;
                    RETURN -1;
                END
            END
            ------------------------------------------------



            EXEC uspSMGetStartingNumber 
                @intStartingNumberId = 3
                ,@strID = @strBatchId OUT

            SELECT 
                intTicketId
                ,dblUnits = dblNetUnits
                ,dblPrice = ISNULL(dblUnitBasis,0) + ISNULL(dblUnitPrice,0)
                ,dblAmount = ROUND((dblNetUnits * (ISNULL(dblUnitBasis,0) + ISNULL(dblUnitPrice,0))),2)
            INTO #tmpComputedTicketInfo
            FROM tblSCTicket
            WHERE intTicketId = @intTicketId 

            SET @GLDescription = 'Direct In Ticket: ' + @strTicketNumber


            -- uspICPostInTransitCosting
            INSERT INTO @ItemInTransitCostingTableType(
                [intItemId] 
                ,[intItemLocationId]
                ,[intItemUOMId]
                ,[dtmDate]
                ,[dblQty] 
                ,[dblUOMQty] 
                ,[dblCost] 
                ,[intCurrencyId]
                ,[intTransactionId]
                ,[strTransactionId]
                ,[intTransactionTypeId]
                ,[intLotId]
                ,[intSourceTransactionId] 
                ,[strSourceTransactionId] 
                ,[intSourceEntityId] 
                ,[intInTransitSourceLocationId]
            )
            SELECT  
                 [intItemId] = A.intItemId
                ,[intItemLocationId] = ITML.intItemLocationId              
                ,[intItemUOMId]  = A.intItemUOMIdTo
                ,[dtmDate] = A.dtmTicketDateTime
                ,[dblQty] = B.dblUnits
                ,[dblUOMQty] =  IUOM.dblUnitQty
                ,[dblCost] = B.dblPrice
                ,[intCurrencyId] = A.intCurrencyId
                ,[intTransactionId] = A.intTicketId
                ,[strTransactionId] = A.strTicketNumber
                ,[intTransactionTypeId] = 52 --scale ticket
                ,[intLotId]  = NULL
                ,[intSourceTransactionId] = A.intTicketId
                ,[strSourceTransactionId] = A.strTicketNumber
                ,[intSourceEntityId] = A.intEntityId
                ,[intInTransitSourceLocationId] = ITML.intItemLocationId     
            FROM tblSCTicket A
            INNER JOIN #tmpComputedTicketInfo B
                ON A.intTicketId = B.intTicketId 
            INNER JOIN tblICItemLocation ITML
                ON A.intItemId = ITML.intItemId
                    AND A.intProcessingLocationId = ITML.intLocationId
            INNER JOIN tblICItemUOM IUOM
                ON A.intItemUOMIdFrom = IUOM.intItemUOMId


            
            EXEC uspICPostInTransitCosting @ItemInTransitCostingTableType, @strBatchId, 'AP Clearing', @intUserId, @GLDescription

            
            BEGIN
                -- Inventory In transit
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
                    ,intAccountId				= @intInventoryInTransitAccountId
                    ,dblDebit					= B.dblAmount
                    ,dblCredit					= 0
                    ,dblDebitUnit				= A.dblNetUnits 
                    ,dblCreditUnit				= 0
                    ,strDescription				= GLAccount.strDescription + '. ' + @GLDescription
                    ,strCode					= 'SCTKT'
                    ,strReference				= '' 
                    ,intCurrencyId				= A.intCurrencyId
                    ,dblExchangeRate			= 1
                    ,dtmDateEntered				= GETDATE()
                    ,dtmTransactionDate			= A.dtmTicketDateTime
                    ,strJournalLineDescription  = '' 
                    ,intJournalLineNo			= 52
                    ,ysnIsUnposted				= 0
                    ,intUserId					= @intUserId
                    ,intEntityId				= NULL 
                    ,strTransactionId			= A.strTicketNumber
                    ,intTransactionId			= A.intTicketId 
                    ,strTransactionType			= 'Scale Ticket'
                    ,strTransactionForm			= 'Scale Ticket'
                    ,strModuleName				= 'Scale'
                    ,intConcurrencyId			= 1
                    ,dblDebitForeign			= B.dblAmount 
                    ,dblDebitReport				= NULL 
                    ,dblCreditForeign			= 0
                    ,dblCreditReport			= NULL 
                    ,dblReportingRate			= NULL 
                    ,dblForeignRate				= 1		
                FROM tblSCTicket A
                INNER JOIN #tmpComputedTicketInfo B
                    ON A.intTicketId = B.intTicketId 
                OUTER APPLY (
                    SELECT TOP 1
                        strDescription
                    FROM tblGLAccount
                    WHERE intAccountId = @intInventoryInTransitAccountId
                ) GLAccount
                WHERE A.intTicketId = @intTicketId

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
                    ,dblDebit					= 0
                    ,dblCredit					= B.dblAmount
                    ,dblDebitUnit				= 0
                    ,dblCreditUnit				= A.dblNetUnits 
                    ,strDescription				= GLAccount.strDescription + '. ' + @GLDescription
                    ,strCode					= 'SCTKT'
                    ,strReference				= '' 
                    ,intCurrencyId				= A.intCurrencyId
                    ,dblExchangeRate			= 1
                    ,dtmDateEntered				= GETDATE()
                    ,dtmTransactionDate			= A.dtmTicketDateTime
                    ,strJournalLineDescription  = '' 
                    ,intJournalLineNo			= 52
                    ,ysnIsUnposted				= 0
                    ,intUserId					= @intUserId
                    ,intEntityId				= NULL 
                    ,strTransactionId			= A.strTicketNumber
                    ,intTransactionId			= A.intTicketId 
                    ,strTransactionType			= 'Scale Ticket'
                    ,strTransactionForm			= 'Scale Ticket'
                    ,strModuleName				= 'Scale'
                    ,intConcurrencyId			= 1
                    ,dblDebitForeign			= 0
                    ,dblDebitReport				= NULL 
                    ,dblCreditForeign			= B.dblAmount 
                    ,dblCreditReport			= NULL 
                    ,dblReportingRate			= NULL 
                    ,dblForeignRate				= 1		
                FROM tblSCTicket A
                INNER JOIN #tmpComputedTicketInfo B
                    ON A.intTicketId = B.intTicketId 
                OUTER APPLY (
                    SELECT TOP 1
                        strDescription
                    FROM tblGLAccount
                    WHERE intAccountId = @intAPClearingAccountId
                ) GLAccount
                WHERE A.intTicketId = @intTicketId

                IF EXISTS ( SELECT TOP 1 1 FROM @GLEntries)
                    EXEC uspGLBookEntries @GLEntries, 1	
            END
            
        END
        ELSE
        BEGIN
            SET @CurrentDate = GETDATE()
            IF EXISTS(SELECT TOP 1 1 FROM tblGLDetail 
                            WHERE intTransactionId = @intTicketId 
                                AND ysnIsUnposted = 0 
                                AND strCode = 'SCTKT' 
                                AND strTransactionType = 'Scale Ticket')
            BEGIN
            
                EXEC dbo.uspSMGetStartingNumber 3, @strBatchId OUTPUT

                EXEC uspGLInsertReverseGLEntry 
                    @strTransactionId = @intTicketId 
                    ,@intEntityId = @intUserId
                    ,@dtmDateReverse  = @CurrentDate
                    ,@strBatchId = @strBatchId
                    ,@strCode = 'SCTKT'
                    ,@ysnUseIntegerTransactionId = 1

                EXEC [dbo].[uspICUnpostCosting]
                    @intTransactionId = @intTicketId 
                    ,@strTransactionId = @strTicketNumber
                    ,@strBatchId = @strBatchId
                    ,@intEntityUserSecurityId = @intUserId
                    ,@ysnRecap = 0 
               
            END
        END
    END TRY

    BEGIN CATCH
        SET @ErrMsg = ERROR_MESSAGE()
        RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
    END CATCH
END