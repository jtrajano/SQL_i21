CREATE PROCEDURE uspCMCreateBankTransferDiffEntries
@strTransactionId NVARCHAR(40),
@dtmDate DATETIME,
@strBatchId NVARCHAR(40),
@intDefaultCurrencyId INT
AS

IF EXISTS (
SELECT 1 FROM tblCMBankTransfer
WHERE @intDefaultCurrencyId = intCurrencyIdAmountFrom AND @intDefaultCurrencyId = intCurrencyIdAmountTo 
AND strTransactionId =@strTransactionId)
RETURN -- EXIT WHEN CURRENCIES ARE FUNCTIONAL


DECLARE @intDiffAccountId INT
DECLARE @MissingAccountErrorMsg NVARCHAR(100)
DECLARE @accountDesc NVARCHAR(30)

IF EXISTS(SELECT 1 FROM tblCMBankTransfer WHERE strTransactionId = @strTransactionId AND intBankTransferTypeId = 1)
BEGIN    
	SELECT TOP 1 @intDiffAccountId= intCashManagementRealizedId FROM tblSMMultiCurrency
	SET @accountDesc = 'Realized Gain/Loss'
END ELSE
BEGIN 
	SELECT TOP 1 @intDiffAccountId= intBTForexDiffAccountId FROM tblCMCompanyPreferenceOption 
	SET @accountDesc = 'Forex Difference'
END
IF ISNULL(@intDiffAccountId,0)  = 0
BEGIN  
	SET @MissingAccountErrorMsg = 'Cash Management ' +  @accountDesc + ' was not set in Company Configuration screen.'
    RAISERROR (@MissingAccountErrorMsg,11,1)  
    RETURN
END  

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
        ,[intAccountId]          = @intDiffAccountId
        ,[dblDebit]              = CASE WHEN dblDifference < 0 THEN dblDifference * -1 ELSE 0 END
        ,[dblCredit]             = CASE WHEN dblDifference > 0 THEN dblDifference ELSE 0 END
        ,[dblDebitForeign]       = CASE WHEN dblDifference < 0 THEN dblDifference * -1 ELSE 0 END    
        ,[dblCreditForeign]      = CASE WHEN dblDifference > 0 THEN dblDifference ELSE 0 END
        ,[dblDebitUnit]          = 0    
        ,[dblCreditUnit]         = 0    
        ,[strDescription]        = A.strDescription    
        ,[strCode]               = 'BTFR'
        ,[strReference]          = A.strReferenceFrom    
        ,[intCurrencyId]         = @intDefaultCurrencyId
        ,[intCurrencyExchangeRateTypeId] =  NULL
        ,[dblExchangeRate]       = 1
        ,[dtmDateEntered]        = GETDATE()    
        ,[dtmTransactionDate]    = A.dtmDate    
        ,[strJournalLineDescription]  = @accountDesc    
        ,[ysnIsUnposted]         = 0     
        ,[intConcurrencyId]      = 1    
        ,[intUserId]             = intLastModifiedUserId    
        ,[strTransactionType]    = 'Bank Transfer'
        ,[strTransactionForm]    = 'Bank Transfer'
        ,[strModuleName]         = 'Cash Management'  
        ,[intEntityId]           = A.intEntityId    
    FROM [dbo].tblCMBankTransfer A CROSS APPLY(
        SELECT strDescription FROM [dbo].tblGLAccount WHERE @intDiffAccountId = intAccountId) GLAccnt 
    WHERE A.strTransactionId = @strTransactionId    
    AND dblDifference <> 0