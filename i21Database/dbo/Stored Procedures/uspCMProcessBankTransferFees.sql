CREATE PROCEDURE uspCMProcessBankTransferFees
@strTransactionId NVARCHAR(40),
@strBatchId  NVARCHAR(40),
@intDefaultCurrencyId INT
AS
-- AMOUNT FROM FEES
  INSERT INTO #tmpGLDetail (  
    [strTransactionId]  
    ,[intTransactionId]  
    ,[dtmDate]  
    ,[strBatchId]  
    ,[intAccountId]  
    ,[dblDebit]  
    ,[dblCredit]  
    ,[dblDebitForeign]   
    ,[dblCreditForeign]  
    ,[dblDebitUnit]  
    ,[dblCreditUnit]  
    ,[strDescription]  
    ,[strCode]  
    ,[strReference]  
    ,[intCurrencyId]  
    ,[intCurrencyExchangeRateTypeId]  
    ,[dblExchangeRate]  
    ,[dtmDateEntered]  
    ,[dtmTransactionDate]  
    ,[strJournalLineDescription]  
    ,[ysnIsUnposted]  
    ,[intConcurrencyId]  
    ,[intUserId]  
    ,[strTransactionType]  
    ,[strTransactionForm]  
    ,[strModuleName]  
    ,[intEntityId]  
  )  
  SELECT 
    [strTransactionId]                = A.strTransactionId  
    ,[intTransactionId]  		          = A.intTransactionId  
    ,[dtmDate]    					          = CASE WHEN intBankTransferTypeId = 3 THEN A.dtmAccrual ELSE A.dtmDate  END
    ,[strBatchId]   				          = @strBatchId  
    ,[intAccountId]   				        = GLAccnt.intAccountId  
    ,[dblDebit]   					          = 0
    ,[dblCredit]   					          = dblFeesFrom --   CASE WHEN @ysnForeignToForeign =1 THEN ROUND(A.dblAmount * ISNULL(@dblRate,1),2)  WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  AmountFunctional.Val ELSE A.dblAmount END  
    ,[dblDebitForeign]  			        = 0
    ,[dblCreditForeign]               = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom 
                                        THEN 0 ELSE dblFeesForeignFrom END  
    ,[dblDebitUnit]   				        = 0  
    ,[dblCreditUnit]  				        = 0  
    ,[strDescription]  			          = A.strDescription  
    ,[strCode]    					          = 'BTFR'
    ,[strReference]   				        = A.strReferenceFrom  
    ,[intCurrencyId]  				        = intCurrencyIdAmountFrom  
    ,[intCurrencyExchangeRateTypeId]  = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN NULL ELSE  intRateTypeIdFeesFrom  END
    ,[dblExchangeRate]  				      = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN 1 ELSE dblRateFeesFrom  END
    ,[dtmDateEntered]  				        = GETDATE()  
    ,[dtmTransactionDate] 			      = CASE WHEN intBankTransferTypeId = 3 THEN A.dtmAccrual ELSE A.dtmDate  END
    ,[strJournalLineDescription] 	    = 'Bank Transfer from fees'
    ,[ysnIsUnposted]  				        = 0   
    ,[intConcurrencyId]  			        = 1  
    ,[intUserId]   					          = intLastModifiedUserId  
    ,[strTransactionType] 			      = 'Bank Transfer'
    ,[strTransactionForm] 			      = 'Bank Transfer'  
    ,[strModuleName]  				        = 'Cash Management'  
    ,[intEntityId]   				          = A.intEntityId  
  FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt  
  ON A.intGLAccountIdFrom = GLAccnt.intAccountId  
  WHERE A.strTransactionId = @strTransactionId  
  AND A.dblFeesFrom > 0 AND ysnPostedInTransit = 1
  UNION ALL
  SELECT 
    [strTransactionId]                = A.strTransactionId  
    ,[intTransactionId]  		          = A.intTransactionId  
    ,[dtmDate]    					          = CASE WHEN intBankTransferTypeId = 3 THEN A.dtmAccrual ELSE A.dtmDate  END
    ,[strBatchId]   				          = @strBatchId  
    ,[intAccountId]   				        = GLAccnt.intAccountId  
    ,[dblDebit]   					          = dblFeesFrom --   CASE WHEN @ysnForeignToForeign =1 THEN ROUND(A.dblAmount * ISNULL(@dblRate,1),2)  WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  AmountFunctional.Val ELSE A.dblAmount END  
    ,[dblCredit]   					          = 0
    ,[dblDebitForeign]  			        = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom 
                                        THEN 0 ELSE dblFeesForeignFrom END  
    ,[dblCreditForeign]               = 0
    ,[dblDebitUnit]   				        = 0  
    ,[dblCreditUnit]  				        = 0  
    ,[strDescription]  			          = A.strDescription  
    ,[strCode]    					          = 'BTFR'
    ,[strReference]   				        = A.strReferenceFrom  
    ,[intCurrencyId]  				        = intCurrencyIdAmountFrom  
    ,[intCurrencyExchangeRateTypeId]  = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN NULL ELSE  intRateTypeIdFeesFrom  END
    ,[dblExchangeRate]  				      = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN 1 ELSE dblRateFeesFrom  END
    ,[dtmDateEntered]  				        = GETDATE()  
    ,[dtmTransactionDate] 			      = CASE WHEN intBankTransferTypeId = 3 THEN A.dtmAccrual ELSE A.dtmDate  END
    ,[strJournalLineDescription] 	    = 'Bank Transfer from fees'
    ,[ysnIsUnposted]  				        = 0   
    ,[intConcurrencyId]  			        = 1  
    ,[intUserId]   					          = intLastModifiedUserId  
    ,[strTransactionType] 			      = 'Bank Transfer'
    ,[strTransactionForm] 			      = 'Bank Transfer'  
    ,[strModuleName]  				        = 'Cash Management'  
    ,[intEntityId]   				          = A.intEntityId  
  FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt  
  ON A.intGLAccountIdFeesFrom = GLAccnt.intAccountId  
  WHERE A.strTransactionId = @strTransactionId  
  AND A.dblFeesFrom > 0 AND ysnPostedInTransit = 1


  -- AMOUNT TO FEES
  UNION ALL
  SELECT 
    [strTransactionId]                = A.strTransactionId  
    ,[intTransactionId]  		          = A.intTransactionId  
    ,[dtmDate]    					          = CASE WHEN A.intBankTransferTypeId = 2 THEN A.dtmInTransit  ELSE   A.dtmDate  END
    ,[strBatchId]   				          = @strBatchId  
    ,[intAccountId]   				        = GLAccnt.intAccountId  
    ,[dblDebit]   					          = dblFeesTo --   CASE WHEN @ysnForeignToForeign =1 THEN ROUND(A.dblAmount * ISNULL(@dblRate,1),2)  WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  AmountFunctional.Val ELSE A.dblAmount END  
    ,[dblCredit]   					          = 0
    ,[dblDebitForeign]  			        = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo 
                                        THEN 0 ELSE dblFeesForeignTo END  
    ,[dblCreditForeign]               = 0
    ,[dblDebitUnit]   				        = 0  
    ,[dblCreditUnit]  				        = 0  
    ,[strDescription]  			          = A.strDescription  
    ,[strCode]    					          = 'BTFR'
    ,[strReference]   				        = A.strReferenceTo  
    ,[intCurrencyId]  				        = intCurrencyIdAmountTo  
    ,[intCurrencyExchangeRateTypeId]  = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo THEN NULL ELSE  intRateTypeIdFeesTo  END
    ,[dblExchangeRate]  				      = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo THEN 1 ELSE dblRateFeesTo  END
    ,[dtmDateEntered]  				        = GETDATE()  
    ,[dtmTransactionDate] 			      = CASE WHEN A.intBankTransferTypeId = 2 THEN A.dtmInTransit  ELSE   A.dtmDate  END
    ,[strJournalLineDescription] 	    = 'Bank Transfer from fees'
    ,[ysnIsUnposted]  				        = 0   
    ,[intConcurrencyId]  			        = 1  
    ,[intUserId]   					          = intLastModifiedUserId  
    ,[strTransactionType] 			      = 'Bank Transfer'
    ,[strTransactionForm] 			      = 'Bank Transfer'  
    ,[strModuleName]  				        = 'Cash Management'  
    ,[intEntityId]   				          = A.intEntityId  
  FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt  
  ON A.intGLAccountIdTo = GLAccnt.intAccountId  
  WHERE A.strTransactionId = @strTransactionId  
  AND A.dblFeesTo > 0 AND ysnPostedInTransit = 1
  UNION ALL
  SELECT 
    [strTransactionId]                = A.strTransactionId  
    ,[intTransactionId]  		          = A.intTransactionId  
    ,[dtmDate]    					          = CASE WHEN A.intBankTransferTypeId = 2 THEN A.dtmInTransit  ELSE   A.dtmDate  END
    ,[strBatchId]   				          = @strBatchId  
    ,[intAccountId]   				        = GLAccnt.intAccountId  
    ,[dblDebit]   					          = 0
    ,[dblCredit]   					          = dblFeesTo --   CASE WHEN @ysnForeignToForeign =1 THEN ROUND(A.dblAmount * ISNULL(@dblRate,1),2)  WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  AmountFunctional.Val ELSE A.dblAmount END  
    ,[dblDebitForeign]  			        = 0
    ,[dblCreditForeign]               = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo
                                        THEN 0 ELSE dblFeesForeignTo END  
    ,[dblDebitUnit]   				        = 0  
    ,[dblCreditUnit]  				        = 0  
    ,[strDescription]  			          = A.strDescription  
    ,[strCode]    					          = 'BTFR'
    ,[strReference]   				        = A.strReferenceTo
    ,[intCurrencyId]  				        = intCurrencyIdAmountTo
    ,[intCurrencyExchangeRateTypeId]  = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo THEN NULL ELSE  intRateTypeIdFeesTo  END
    ,[dblExchangeRate]  				      = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo THEN 1 ELSE dblRateFeesTo  END
    ,[dtmDateEntered]  				        = GETDATE()  
    ,[dtmTransactionDate] 			      = CASE WHEN A.intBankTransferTypeId = 2 THEN A.dtmInTransit  ELSE   A.dtmDate  END
    ,[strJournalLineDescription] 	    = 'Bank Transfer from fees'
    ,[ysnIsUnposted]  				        = 0   
    ,[intConcurrencyId]  			        = 1  
    ,[intUserId]   					          = intLastModifiedUserId  
    ,[strTransactionType] 			      = 'Bank Transfer'
    ,[strTransactionForm] 			      = 'Bank Transfer'  
    ,[strModuleName]  				        = 'Cash Management'  
    ,[intEntityId]   				          = A.intEntityId  
  FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt  
  ON A.intGLAccountIdFeesTo = GLAccnt.intAccountId  
  WHERE A.strTransactionId = @strTransactionId  
  AND A.dblFeesTo > 0 AND ysnPostedInTransit = 1