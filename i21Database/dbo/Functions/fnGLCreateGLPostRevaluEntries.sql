CREATE FUNCTION fnGLCreateGLPostRevaluEntries
(
    @intConsolidationId   INT,
    @strPeriod NVARCHAR(20),
    @dateNow DATETIME,
    @strPostBatchId NVARCHAR(40),
    @defaultType NVARCHAR(20),
    @intEntityId INT
)
RETURNS TABLE   
AS RETURN(
          WITH cte as(  
                    SELECT   
                    [strTransactionId]  = B.strConsolidationNumber  
                    ,[intTransactionId]  = B.intConsolidationId  
                    ,[strDescription]  = A.strTransactionId   
                    ,[dtmTransactionDate] = B.dtmDate  
                    ,[dblDebit]    = ISNULL(CASE WHEN dblUnrealizedGain < 0 THEN ABS(dblUnrealizedGain)  
                            WHEN dblUnrealizedLoss < 0 THEN 0  
                            ELSE dblUnrealizedLoss END,0)  
                    ,[dblCredit]   = ISNULL(CASE WHEN dblUnrealizedLoss < 0 THEN ABS(dblUnrealizedLoss)  
                            WHEN dblUnrealizedGain < 0 THEN 0  
                            ELSE dblUnrealizedGain END,0)
                    ,[dblExchangeRate] = dblNewForexRate
                    
                    ,[dtmDate]    = ISNULL(B.[dtmDate], GETDATE())  
                    ,[ysnIsUnposted]  = 0   
                    ,[intConcurrencyId]  = 1  
                    ,B.intFunctionalCurrencyId
                    ,[intCurrencyId]  = A.intCurrencyId
                    ,[intUserId]   = 0  
                    ,[intEntityId]   = @intEntityId    
                    ,[dtmDateEntered]  = @dateNow  
                    ,[strBatchId]   = @strPostBatchId  
                    ,[strCode]    = 'REVAL'  
                    ,[intJournalLineNo]  = A.[intConsolidationDetailId]     
                    ,[strTransactionType] = 'Revalue Currency'  
                    ,[strTransactionForm] = 'Revalue Currency'  
                    ,B.dtmReverseDate  
                    ,strModule = B.strTransactionType  
                    ,A.strType  
                    ,Offset = 0  
                    ,A.intAccountIdOverride  
                    ,A.intLocationSegmentOverrideId  
                    ,A.intLOBSegmentOverrideId  
                    ,A.intCompanySegmentOverrideId
                    FROM [dbo].tblGLRevalueDetails A RIGHT JOIN [dbo].tblGLRevalue B   
                    ON A.intConsolidationId = B.intConsolidationId  
                    WHERE B.intConsolidationId = @intConsolidationId  
          ),cte1 AS  
          (  
                    SELECT   
                        [strTransactionId]    
                        ,[intTransactionId]    
                        ,[strDescription]= 'Revalue GL '  + @strPeriod 
                        ,[dtmTransactionDate]   
                        ,[dblDebit]   
                        ,[dblCredit]
                        ,[dblExchangeRate] = 1
                        ,[dblDebitForeign] = [dblCredit]  
                        ,[dblCreditForeign]= [dblDebit]
                        ,[dtmDate]      
                        ,[ysnIsUnposted]    
                        ,[intConcurrencyId]    
                        ,intCurrencyId = intFunctionalCurrencyId  --functional gain/loss
                        ,[intUserId]     
                        ,[intEntityId]     
                        ,[dtmDateEntered]    
                        ,strBatchId  
                        ,[strCode]      
                        ,[strJournalLineDescription] = 'Revalue GL '  + @strPeriod   
                        ,[intJournalLineNo]    
                        ,[strTransactionType]
                        ,[strTransactionForm]
                        ,strModule
                        ,OffSet = 0
                        ,strType = ISNULL(strType,@defaultType)  
                        ,intAccountIdOverride  -- source account
                        ,intLocationSegmentOverrideId  
                        ,intLOBSegmentOverrideId  
                        ,intCompanySegmentOverrideId
                    FROM  
                    cte   
                    UNION ALL  
                    SELECT   
                        [strTransactionId]    
                        ,[intTransactionId]    
                        ,[strDescription] = 'Offset Revalue GL '  + @strPeriod      
                        ,[dtmTransactionDate]   
                        ,[dblDebit]    = dblCredit      
                        ,[dblCredit]   = dblDebit  
                        ,[dblExchangeRate]    = 0 
                        ,[dblDebitForeign]    = 0    
                        ,[dblCreditForeign]   = 0
                        ,[dtmDate]  
                        ,[ysnIsUnposted]    
                        ,[intConcurrencyId]   
                        ,intCurrencyId -- offset is in source currency 
                        ,[intUserId]     
                        ,[intEntityId]     
                        ,[dtmDateEntered]   
                        ,strBatchId   
                        ,[strCode]      
                        ,[strJournalLineDescription] = 'Offset Revalue GL '  + @strPeriod   
                        ,[intJournalLineNo]
                        ,[strTransactionType]
                        ,[strTransactionForm]
                        ,strModule
                        ,OffSet = 1
                        ,strType = ISNULL(strType,@defaultType)  
                        ,intAccountIdOverride   -- source account
                        ,intLocationSegmentOverrideId  
                        ,intLOBSegmentOverrideId  
                        ,intCompanySegmentOverrideId
                    FROM cte   
          )
          SELECT   
          [strTransactionId]    
          ,[intTransactionId]    
          ,intAccountId =  dbo.fnGLGetRevalueAccountTableForGL(v.intAccountCategoryId, intAccountIdOverride, A.OffSet )
          ,strDescription = A.[strDescription]     
          ,[dtmTransactionDate]   
          ,[dblDebit]      
          ,[dblCredit]
          ,[dblExchangeRate] 
          ,[dblDebitForeign]      
          ,[dblCreditForeign]
          ,[dtmDate]      
          ,[ysnIsUnposted]    
          ,A.[intConcurrencyId]    
          ,[intCurrencyId]
          ,[intUserId]     
          ,[intEntityId]     
          ,[dtmDateEntered]    
          ,[strBatchId]   
          ,A.[strCode]      
          ,[strJournalLineDescription] 
          ,[intJournalLineNo]    
          ,[strTransactionType]   
          ,[strTransactionForm]  
          ,strModuleName = 'General Ledger'  
          ,intAccountIdOverride  
          ,intLocationSegmentOverrideId  
          ,intLOBSegmentOverrideId  
          ,intCompanySegmentOverrideId
          FROM cte1 A  LEFT JOIN
          vyuGLAccountDetail v on v.intAccountId = A.intAccountIdOverride  
)