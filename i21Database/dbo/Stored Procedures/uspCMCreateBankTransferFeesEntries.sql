CREATE PROCEDURE uspCMCreateBankTransferFeesEntries
@strTransactionId NVARCHAR(20),
@intBankGLAccountId INT,
@strDir NVARCHAR(5),
@dtmDate DATETIME,
@strBatchId NVARCHAR(40),
@intDefaultCurrencyId INT

AS

DECLARE @GL_DETAIL_CODE AS NVARCHAR(10)   = 'BTFR' -- String code used in GL Detail table.     
 ,@MODULE_NAME AS NVARCHAR(100)    = 'Cash Management' -- Module where this posting code belongs.    
 ,@TRANSACTION_FORM AS NVARCHAR(100)   = 'Bank Transfer'    
 ,@dblFees DECIMAL(18,6)
 ,@dblFeesForeign DECIMAL(18,6)
 ,@dblExchangeRate DECIMAL(18,6)
 ,@dblFeesRate DECIMAL(18,6)

SELECT @dblFees = 
case WHEN @strDir = 'From' THEN dblFeesFrom ELSE dblFeesTo END,
@dblFeesForeign = case WHEN @strDir = 'From' THEN dblFeesForeignFrom ELSE dblFeesForeignTo END,
@dblFeesRate =case WHEN @strDir = 'From' THEN dblRateFeesFrom ELSE dblRateFeesTo END
FROM tblCMBankTransfer 
WHERE strTransactionId =@strTransactionId

IF @dblFees > 0
BEGIN
IF @strDir = 'From'
BEGIN
    IF EXISTS(SELECT 1 FROM #tmpGLDetail WHERE intAccountId = @intBankGLAccountId)
    BEGIN
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
            SELECT [strTransactionId]  = strTransactionId    
            ,[intTransactionId]      = intTransactionId    
            ,[dtmDate]               = @dtmDate    
            ,[strBatchId]            = @strBatchId    
            ,[intAccountId]          = GLAccnt.intAccountId    
            ,[dblDebit]              = @dblFees --   CASE WHEN @ysnForeignToForeign =1 THEN ROUND(A.dblAmount * ISNULL(@dblRate,1),2)  WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  AmountFunctional.Val ELSE A.dblAmount END    
            ,[dblCredit]             = 0
            ,[dblDebitForeign]       = @dblFeesForeign
            ,[dblCreditForeign]      = 0
            ,[dblDebitUnit]          = 0    
            ,[dblCreditUnit]         = 0    
            ,[strDescription]        = A.strDescription    
            ,[strCode]               = @GL_DETAIL_CODE    
            ,[strReference]          = A.strReferenceFrom    
            ,[intCurrencyId]         = intCurrencyIdAmountFrom    
            ,[intCurrencyExchangeRateTypeId] =  CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN NULL ELSE  intRateTypeIdFeesFrom  END  
            ,[dblExchangeRate]       = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN 1 ELSE dblRateFeesFrom  END  
            ,[dtmDateEntered]        = GETDATE()    
            ,[dtmTransactionDate]    = @dtmDate    
            ,[strJournalLineDescription]  = 'Bank Transfer Fees'
            ,[ysnIsUnposted]         = 0     
            ,[intConcurrencyId]      = 1    
            ,[intUserId]             = intLastModifiedUserId    
            ,[strTransactionType]    = @TRANSACTION_FORM    
            ,[strTransactionForm]    = @TRANSACTION_FORM    
            ,[strModuleName]         = @MODULE_NAME    
            ,[intEntityId]           = A.intEntityId    
            FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt    
            ON 
            A.intGLAccountIdFeesFrom 
            = GLAccnt.intAccountId    
            WHERE A.strTransactionId = @strTransactionId  
            
            UPDATE A
			SET dblCredit = dblCredit + @dblFees ,
		    dblCreditForeign = dblCreditForeign + @dblFeesForeign
            from #tmpGLDetail A  
            WHERE intAccountId = @intBankGLAccountId  

			UPDATE A
			SET dblExchangeRate = dblCredit/dblCreditForeign
            from #tmpGLDetail A  
            WHERE intAccountId = @intBankGLAccountId

    END
    
END
ELSE
BEGIN

    IF EXISTS(SELECT 1 FROM #tmpGLDetail WHERE intAccountId = @intBankGLAccountId)
    BEGIN
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
            SELECT [strTransactionId]  = strTransactionId    
            ,[intTransactionId]      = intTransactionId    
            ,[dtmDate]               = @dtmDate    
            ,[strBatchId]            = @strBatchId    
            ,[intAccountId]          = GLAccnt.intAccountId    
            ,[dblDebit]              = @dblFees --   CASE WHEN @ysnForeignToForeign =1 THEN ROUND(A.dblAmount * ISNULL(@dblRate,1),2)  WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  AmountFunctional.Val ELSE A.dblAmount END    
            ,[dblCredit]             = 0
            ,[dblDebitForeign]       = @dblFeesForeign
            ,[dblCreditForeign]      = 0
            ,[dblDebitUnit]          = 0    
            ,[dblCreditUnit]         = 0    
            ,[strDescription]        = A.strDescription    
            ,[strCode]               = @GL_DETAIL_CODE    
            ,[strReference]          = A.strReferenceTo   
            ,[intCurrencyId]         = intCurrencyIdAmountTo  
            ,[intCurrencyExchangeRateTypeId] =  CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo THEN NULL ELSE  intRateTypeIdFeesTo  END  
            ,[dblExchangeRate]       = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo THEN 1 ELSE dblRateFeesTo  END  
            ,[dtmDateEntered]        = GETDATE()    
            ,[dtmTransactionDate]    = @dtmDate
            ,[strJournalLineDescription]  = 'Bank Transfer Fees'
            ,[ysnIsUnposted]         = 0     
            ,[intConcurrencyId]      = 1    
            ,[intUserId]             = intLastModifiedUserId    
            ,[strTransactionType]    = @TRANSACTION_FORM    
            ,[strTransactionForm]    = @TRANSACTION_FORM    
            ,[strModuleName]         = @MODULE_NAME    
            ,[intEntityId]           = A.intEntityId    
            FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt    
            ON 
            A.intGLAccountIdFeesTo
            = GLAccnt.intAccountId    
            WHERE A.strTransactionId = @strTransactionId    

            UPDATE A
			SET dblDebit = dblDebit - @dblFees ,
		    dblDebitForeign = dblDebitForeign - @dblFeesForeign
            from #tmpGLDetail A  
            WHERE intAccountId = @intBankGLAccountId  

			UPDATE A
			SET dblExchangeRate = dblDebit/dblDebitForeign
            from #tmpGLDetail A  
            WHERE intAccountId = @intBankGLAccountId
    END
        
END

END