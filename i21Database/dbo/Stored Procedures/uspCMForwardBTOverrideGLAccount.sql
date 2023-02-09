  
CREATE PROCEDURE [dbo].[uspCMForwardBTOverrideGLAccount](@intAccountId INT)  
AS  
BEGIN  
DECLARE @ysnOverrideLocation BIT = 0 , @ysnOverrideLOB BIT = 0, @ysnOverrideCompany BIT = 0, @msg NVARCHAR(MAX) = ''  
  
  
  
SELECT   
@ysnOverrideLocation= ysnOverrideLocationSegment_Forward,  
@ysnOverrideLOB=ysnOverrideLOBSegment_Forward,  
@ysnOverrideCompany=ysnOverrideCompanySegment_Forward  
FROM tblCMCompanyPreferenceOption  
  
IF NOT EXISTS(SELECT 1 FROM tblGLAccountStructure WHERE intStructureType =  3)  
    SET @ysnOverrideLocation = 0  
  
  
IF NOT EXISTS(SELECT 1 FROM tblGLAccountStructure WHERE intStructureType =  5)  
    SET @ysnOverrideLOB = 0  
  
  
IF NOT EXISTS(SELECT 1 FROM tblGLAccountStructure WHERE intStructureType =  6)  
    SET @ysnOverrideCompany = 0  
  
-- OVERRIDE BY Bank GL Account Id WITH CONTRACT ITEM LOB----  
-- GL-9908  
  
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
  
DECLARE @intLOBSegmentIdFromContract INT  
SELECT TOP 1 @intLOBSegmentIdFromContract = SM.intSegmentCodeId  
FROM tblRKFutOptTransaction der  
JOIN tblCMBankTransfer BT ON der.intFutOptTransactionId = BT.intFutOptTransactionId OR der.intFutOptTransactionHeaderId = BT.intFutOptTransactionHeaderId  
JOIN tblCTContractHeader CT on CT.intContractHeaderId = der.intContractHeaderId  
JOIN tblICCommodity IC ON IC.intCommodityId = CT.intCommodityId  
JOIN tblSMLineOfBusiness SM ON SM.intLineOfBusinessId = IC.intLineOfBusinessId   
JOIN #tmpGLDetail GL ON GL.strTransactionId = BT.strTransactionId  
  
 IF @intLOBSegmentIdFromContract IS NOT NULL  
        SET @ysnOverrideLOB = 0  
  
  
DECLARE @strAccountId NVARCHAR(30) ,@strAccountId1 NVARCHAR(30)   
SELECT @strAccountId = strAccountId from tblGLAccount where intAccountId = @intAccountId  
  
DECLARE @intAccountIdLoop INT  
DECLARE @intStart INT, @intEnd INT, @intLength INT, @intDividerCount INT  
DECLARE @strSegment NVARCHAR(10)   
DECLARE @newAccountId INT  
DECLARE @newStrAccountId NVARCHAR(40)  
DECLARE @strJournalLineDescription NVARCHAR(500)  
  
IF  @ysnOverrideLocation | @ysnOverrideLOB | @ysnOverrideCompany = 1  
BEGIN  
WHILE EXISTS (SELECT 1 FROM @GLEntries WHERE intAccountId <> @intAccountId)  
BEGIN  
  
    SELECT TOP 1 @strAccountId1 = strAccountId, @intAccountIdLoop = GL.intAccountId , @strJournalLineDescription = strJournalLineDescription  
    FROM @GLEntries G  
    JOIN  tblGLAccount GL ON G.intAccountId = GL.intAccountId  
    WHERE GL.intAccountId <> @intAccountId  
    GROUP BY GL.intAccountId, strAccountId, strJournalLineDescription  
    IF @strJournalLineDescription <> 'Bank Account Entries'   
    BEGIN  
        SET @newStrAccountId =''  
        SELECT @newStrAccountId = dbo.fnGLGetOverrideAccountByAccount( @intAccountId,@intAccountIdLoop, @ysnOverrideLocation,@ysnOverrideLOB,@ysnOverrideCompany)  
        IF @newStrAccountId = ''  
        BEGIN  
            SET @msg += '<li>Overriding ' + @strAccountId1 + ' encountered an unknow error.</li>'  
        END  
        ELSE  
        IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccount WHERE strAccountId = @newStrAccountId)  
        BEGIN  
            SET @msg += '<li>' + @newStrAccountId + ' is a  non-existing account for override</li>'   
        END  
        ELSE IF @newStrAccountId <> @strAccountId1  
        BEGIN  
            SELECT TOP 1 @newAccountId = intAccountId FROM tblGLAccount WHERE strAccountId = @newStrAccountId  
            UPDATE A set intAccountId = @newAccountId from #tmpGLDetail A   
            WHERE A.intAccountId = @intAccountIdLoop  
            AND strJournalLineDescription <> 'Bank Account Entries'  
        END  
    END  
    DELETE FROM @GLEntries WHERE intAccountId = @intAccountIdLoop  
END  
END  
  
DELETE FROM @GLEntries  
  
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
  
  
  
DECLARE @intAccountId1 INT  
DECLARE @strAccountId2 NVARCHAR(30)  
  
IF @intLOBSegmentIdFromContract IS NOT NULL  
BEGIN  
WHILE EXISTS (SELECT 1 FROM @GLEntries)  
BEGIN  
    SELECT TOP 1 @intAccountId = intAccountId , @strJournalLineDescription = strJournalLineDescription FROM @GLEntries  
    IF @strJournalLineDescription <> 'Bank Account Entries'  
    BEGIN  
        SELECT @strAccountId2 = dbo.fnGLGetOverrideAccountBySegment(@intAccountId,NULL,@intLOBSegmentIdFromContract,NULL)  
        IF @strAccountId2 IS NULL OR LEN(@strAccountId2) = 0  
            SET @msg += '<li>Building an override account encountered an error.</li>'  
        SET  @intAccountId1 = NULL  
        SELECT TOP 1 @intAccountId1 = intAccountId FROM tblGLAccount WHERE strAccountId = @strAccountId2  
        IF @intAccountId1 IS NULL  
            SET @msg += '<li>' + @strAccountId2 + ' is not an existing account id.</li>'  
  
        UPDATE A SET intAccountId = @intAccountId1  FROM #tmpGLDetail A  
        WHERE intAccountId = @intAccountId  
        AND strJournalLineDescription <> 'Bank Account Entries'  
    END  
  
    DELETE FROM @GLEntries WHERE @intAccountId = intAccountId  
END  
END  
  
  
IF @msg <> ''  
BEGIN  
    _RaiseError:  
    SET @msg = '<ul style="text-indent:-40px">' + @msg + '</ul>'  
 RAISERROR (@msg ,16,1)  
END  
  
END