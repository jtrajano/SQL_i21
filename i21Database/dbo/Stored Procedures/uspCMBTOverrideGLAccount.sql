
CREATE PROCEDURE [dbo].[uspCMBTOverrideGLAccount]
(
	@intAccountId INT, -- Overriding Account
    @intBankTransferTypeId INT
)
AS
BEGIN
DECLARE @ysnOverrideLocation BIT , @ysnOverrideCompany BIT

SELECT TOP 1 @ysnOverrideLocation=ISNULL(
CASE WHEN @intBankTransferTypeId = 2 THEN ysnOverrideLocationSegment_InTransit
    WHEN @intBankTransferTypeId = 3 THEN ysnOverrideLocationSegment_Forward
    WHEN @intBankTransferTypeId IN (4,5) THEN ysnOverrideLocationSegment_Swap ELSE 0 END,0)
FROM tblCMCompanyPreferenceOption


SELECT TOP 1 @ysnOverrideCompany= ISNULL(
CASE WHEN @intBankTransferTypeId = 2 THEN ysnOverrideCompanySegment_InTransit
    WHEN @intBankTransferTypeId = 3 THEN ysnOverrideCompanySegment_Forward
    WHEN @intBankTransferTypeId IN (4,5) THEN ysnOverrideCompanySegment_Swap ELSE 0 END,0)
FROM tblCMCompanyPreferenceOption

DECLARE @GLEntries AS RecapTableType 

INSERT INTO @GLEntries(    
   [strTransactionId]    
   ,[intTransactionId]    
   ,[intAccountId]    
   ,[strDescription]    
   ,[strReference]     
   ,[dtmTransactionDate]    
   ,[dblDebit]    
   ,[dblCredit]    
   ,[dblDebitForeign]    
   ,[dblCreditForeign]    
   ,[dblDebitUnit]    
   ,[dblCreditUnit]    
   ,[dtmDate]    
   ,[ysnIsUnposted]    
   ,[intConcurrencyId]     
   ,[intCurrencyId]    
   ,[intCurrencyExchangeRateTypeId]    
   ,[dblExchangeRate]    
   ,[intUserId]    
   ,[intEntityId]       
   ,[dtmDateEntered]    
   ,[strBatchId]    
   ,[strCode]       
   ,[strJournalLineDescription]    
   ,[intJournalLineNo]    
   ,[strTransactionType]    
   ,[strTransactionForm]    
   ,[strModuleName]     
   )     
    SELECT    
      [strTransactionId]    
      ,[intTransactionId]    
      ,[intAccountId]    
      ,[strDescription]    
      ,[strReference]     
      ,[dtmTransactionDate]    
      ,[dblDebit]    
      ,[dblCredit]    
      ,[dblDebitForeign]    
      ,[dblCreditForeign]    
      ,[dblDebitUnit]    
      ,[dblCreditUnit]    
      ,[dtmDate]    
      ,[ysnIsUnposted]    
      ,[intConcurrencyId]     
      ,[intCurrencyId]    
      ,[intCurrencyExchangeRateTypeId]    
      ,[dblExchangeRate]    
      ,[intUserId]    
      ,[intEntityId]       
      ,[dtmDateEntered]    
      ,[strBatchId]    
      ,[strCode]       
      ,[strJournalLineDescription]    
      ,[intJournalLineNo]    
      ,[strTransactionType]    
      ,[strTransactionForm]    
      ,[strModuleName]      
    FROM #tmpGLDetail  

DECLARE @strAccountId NVARCHAR(30) ,@strAccountId1 NVARCHAR(30) , @msg NVARCHAR(100) = ''
SELECT @strAccountId = strAccountId from tblGLAccount where intAccountId = @intAccountId


DECLARE @intAccountIdLoop INT
DECLARE @intStart INT, @intEnd INT, @intLength INT, @intDividerCount INT
DECLARE @strSegment NVARCHAR(10) 
DECLARE @newAccountId INT
DECLARE @newStrAccountId NVARCHAR(40)

WHILE EXISTS (SELECT 1 FROM @GLEntries WHERE @intAccountId <> intAccountId)
BEGIN
    SELECT TOP 1 @strAccountId1 = strAccountId, @intAccountIdLoop = GL.intAccountId FROM @GLEntries G
    JOIN  tblGLAccount GL ON G.intAccountId = GL.intAccountId
    WHERE GL.intAccountId <> @intAccountId
    GROUP BY GL.intAccountId, strAccountId

    IF @ysnOverrideLocation = 1 
        SELECT @newStrAccountId= dbo.fnGetOverrideAccount(3,@strAccountId,@strAccountId1)
    
    IF @ysnOverrideCompany = 1
        SELECT @newStrAccountId= dbo.fnGetOverrideAccount(6,@strAccountId,@newStrAccountId)
        

    IF @newStrAccountId = ''
    BEGIN
	    SET @msg += '<li>Overriding ' + @strAccountId1 + ' encountered an unknow error.</li>'
    END
    ELSE
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccount WHERE strAccountId = @newStrAccountId)
    BEGIN
	    SET @msg += '<li>' + @newStrAccountId + ' is a  non-existing account for override.</li>' 
    END
    ELSE
    IF @newStrAccountId = @strAccountId
    BEGIN
        SET @msg += '<li>Overriding ' + @strAccountId1 + ' will result to the same account id.</li>'
    END
    ELSE
    BEGIN
        SELECT TOP 1 @newAccountId = intAccountId FROM tblGLAccount WHERE strAccountId = @newStrAccountId

        UPDATE A set intAccountId = @newAccountId from #tmpGLDetail A 
        WHERE A.intAccountId = @intAccountIdLoop
    END



    DELETE FROM @GLEntries WHERE intAccountId = @intAccountIdLoop


END

SELECT * FROM #tmpGLDetail

IF @msg <> ''
BEGIN
    SET @msg = '<ul>' + @msg + '</ul>'
	RAISERROR (@msg ,16,1)
END




END