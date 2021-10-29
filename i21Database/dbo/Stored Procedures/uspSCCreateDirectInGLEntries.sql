﻿CREATE PROCEDURE [dbo].[uspSCCreateDirectInGLEntries]
	@intTicketId INT
    ,@ysnDistribute BIT
    ,@intUserId INT
AS
SET ANSI_WARNINGS ON
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

        DECLARE @ticketDistributionAllocation ScaleManualDistributionAllocation
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

            ----GET Ticket Distribution of Units
            BEGIN
                /*
                ---SPOT
                BEGIN
                    INSERT INTO @ticketDistributionAllocation (
                        [intAllocationType]
                        ,[dblQuantity] 
                        ,[intEntityId] 
                        ,[intContractDetailId]
                        ,[intLoadDetailId]  
                        ,[intStorageScheduleId]
                        ,[intStorageScheduleTypeId]
                        ,[dblFuture] 
                        ,[dblBasis] 
                    )
                    SELECT 
                         [intAllocationType] = 4
                        ,[dblQuantity] = B.dblQty
                        ,[intEntityId] = B.intEntityId
                        ,[intContractDetailId] = NULL
                        ,[intLoadDetailId] = NULL 
                        ,[intStorageScheduleId] = NULL
                        ,[intStorageScheduleTypeId] = NULL
                        ,[dblFuture] = ISNULL(B.dblUnitFuture,0)
                        ,[dblBasis] = ISNULL(B.dblUnitBasis,0)
                    FROM tblSCTicket A
                    INNER JOIN tblSCTicketSpotUsed B
                        ON A.intTicketId = B.intTicketId
                    WHERE A.intTicketId = @intTicketId 
                END

                ---CONTRACT
                BEGIN
                    --Priced Contract
                    INSERT INTO @ticketDistributionAllocation (
                        [intAllocationType]
                        ,[dblQuantity] 
                        ,[intEntityId] 
                        ,[intContractDetailId]
                        ,[intLoadDetailId]  
                        ,[intStorageScheduleId]
                        ,[intStorageScheduleTypeId]
                        ,[dblFuture] 
                        ,[dblBasis] 
                    )
                    SELECT 
                         [intAllocationType] = 1
                        ,[dblQuantity] = B.dblScheduleQty
                        ,[intEntityId] = B.intEntityId
                        ,[intContractDetailId] = B.intContractDetailId
                        ,[intLoadDetailId] = NULL 
                        ,[intStorageScheduleId] = NULL
                        ,[intStorageScheduleTypeId] = NULL
                        ,[dblFuture] = ISNULL(C.dblFutures,0)
                        ,[dblBasis] = ISNULL(C.dblBasis,0)
                    FROM tblSCTicket A
                    INNER JOIN tblSCTicketContractUsed B
                        ON A.intTicketId = B.intTicketId
                    INNER JOIN tblCTContractDetail C
                        ON B.intContractDetailId = C.intContractDetailId
                    WHERE A.intTicketId = @intTicketId 
                END

                ---LOAD
                BEGIN
                    --Priced Contract
                    INSERT INTO @ticketDistributionAllocation (
                        [intAllocationType]
                        ,[dblQuantity] 
                        ,[intEntityId] 
                        ,[intContractDetailId]
                        ,[intLoadDetailId]  
                        ,[intStorageScheduleId]
                        ,[intStorageScheduleTypeId]
                        ,[dblFuture] 
                        ,[dblBasis] 
                    )
                    SELECT 
                         [intAllocationType] = 2
                        ,[dblQuantity] = B.dblQty
                        ,[intEntityId] = B.intEntityId
                        ,[intContractDetailId] = D.intContractDetailId
                        ,[intLoadDetailId] = B.intLoadDetailId 
                        ,[intStorageScheduleId] = NULL
                        ,[intStorageScheduleTypeId] = NULL
                        ,[dblFuture] = ISNULL(D.dblFutures,0)
                        ,[dblBasis] = ISNULL(D.dblBasis,0)
                    FROM tblSCTicket A
                    INNER JOIN tblSCTicketLoadUsed B
                        ON A.intTicketId = B.intTicketId
                    INNER JOIN tblLGLoadDetail C
                        ON B.intLoadDetailId = C.intLoadDetailId
                    LEFT JOIN tblCTContractDetail D 
                        ON C.intPContractDetailId = D.intContractDetailId
                    LEFT JOIN tblCTContractHeader E
                        ON D.intContractHeaderId = E.intContractHeaderId
                    WHERE A.intTicketId = @intTicketId 
                        AND E.intPricingTypeId = 1
                END

                -- STORAGE(DP)
                BEGIN
                    INSERT INTO @ticketDistributionAllocation (
                        [intAllocationType]
                        ,[dblQuantity] 
                        ,[intEntityId] 
                        ,[intContractDetailId]
                        ,[intLoadDetailId]  
                        ,[intStorageScheduleId]
                        ,[intStorageScheduleTypeId]
                        ,[dblFuture] 
                        ,[dblBasis] 
                    )
                    SELECT 
                         [intAllocationType] = 3
                        ,[dblQuantity] = B.dblQty
                        ,[intEntityId] = B.intEntityId
                        ,[intContractDetailId] = B.intContractDetailId
                        ,[intLoadDetailId] = NULL 
                        ,[intStorageScheduleId] = B.intStorageScheduleId
                        ,[intStorageScheduleTypeId] = B.intStorageTypeId
                        ,[dblFuture] = ISNULL(C.dblFutures,0)
                        ,[dblBasis] = ISNULL(C.dblBasis,0)
                    FROM tblSCTicket A
                    INNER JOIN tblSCTicketStorageUsed B
                        ON A.intTicketId = B.intTicketId
                    LEFT JOIN tblCTContractDetail C
                        ON B.intContractDetailId = C.intContractDetailId
                    WHERE A.intTicketId = @intTicketId 
                END
                */
              
                INSERT INTO @ticketDistributionAllocation (
                    [intAllocationType]
                    ,[dblQuantity] 
                    ,[intEntityId] 
                    ,[intContractDetailId]
                    ,[intLoadDetailId]  
                    ,[intStorageScheduleId]
                    ,[intStorageScheduleTypeId]
                    ,[dblFuture] 
                    ,[dblBasis] 
                    ,intTicketDistributionAllocationId
                )
                EXEC uspSCGetTicketDistributionAllocation @intTicketId
          
            END

            SELECT   
                A.intTicketId  
                ,dblUnits = B.dblQuantity
                ,dblPrice = ROUND(ISNULL(B.dblBasis,0) + ISNULL(B.dblFuture,0),2)
                ,dblAmount = ROUND((B.dblQuantity * ROUND(ISNULL(dblBasis,0) + ISNULL(dblFuture,0),2)),2)
                ,B.intAllocationType
                ,strAllocationType = CASE WHEN B.intAllocationType = 1 THEN 'Contract'
                                          WHEN B.intAllocationType = 2 THEN 'Load'
                                          WHEN B.intAllocationType = 3 THEN 'Storage'
                                          WHEN B.intAllocationType = 4 THEN 'Spot'
                                     END
            INTO #tmpComputedTicketInfo
            FROM tblSCTicket A
            JOIN @ticketDistributionAllocation B
                ON 1 = 1
            WHERE intTicketId = @intTicketId 

            SET @GLDescription = 'Direct In Ticket: ' + @strTicketNumber


            /*
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
            */

            
            BEGIN
                -- General Account
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
                    ,dblDebitUnit				= B.dblUnits
                    ,dblCreditUnit				= 0
                    ,strDescription				= GLAccount.strDescription + '. ' + @GLDescription + ' - ' + B.strAllocationType
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
                    ,dblCreditUnit				= B.dblUnits
                    ,strDescription				= GLAccount.strDescription + '. ' + @GLDescription + ' - ' + B.strAllocationType
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