CREATE PROCEDURE [dbo].[uspGLReverseJournalEntry]
(
	@intJournalId INT,
	@intEntityId INT
)
AS
BEGIN

DECLARE @intReversedJournalId INT

SELECT @intReversedJournalId = intJournalId FROM tblGLJournal WHERE intJournalIdToReverse = @intJournalId

IF @intReversedJournalId IS NOT NULL
BEGIN
	SELECT @intReversedJournalId
	RETURN
END

SELECT @intReversedJournalId = intJournalIdToReverse FROM tblGLJournal WHERE intJournalId = @intJournalId

IF @intReversedJournalId IS NOT NULL
BEGIN
	SELECT @intReversedJournalId
	RETURN
END
	


DECLARE @intUserId INT, @intNumber INT, @strPrefix NVARCHAR(10),@intStartingNumberId INT
SELECT @intUserId =intUserSecurityID from tblSMUserSecurity WHERE intEntityId = @intEntityId
SELECT @intStartingNumberId = intStartingNumberId, @strPrefix = strPrefix ,@intNumber = intNumber + 1 FROM tblSMStartingNumber WHERE strTransactionType = 'General Journal Reversal'
INSERT INTO [tblGLJournal]
           ([strJournalId]
           ,[strTransactionType]
           ,[dtmDate]
           ,[strReverseLink]
           ,[intCurrencyId]
           ,[dblExchangeRate]
           ,[strDescription]
           ,[ysnPosted]
           ,[intConcurrencyId]
           ,[dtmDateEntered]
           ,[intUserId]
           ,[intEntityId]
           ,[strSourceId]
           ,[strJournalType]
           ,[strRecurringStatus]
           ,[strSourceType]
           ,[intFiscalPeriodId]
           ,[intFiscalYearId]
           ,[intJournalIdToReverse])
	SELECT @strPrefix + CONVERT(NVARCHAR(10), @intNumber)
           ,[strTransactionType]
           ,[dtmDate]
           ,[strReverseLink]
           ,[intCurrencyId]
           ,[dblExchangeRate]
           ,'Reversing transaction for ' + strJournalId
           ,0
           ,[intConcurrencyId]
           ,[dtmDateEntered]
           ,@intUserId
           ,@intEntityId
           ,[strSourceId]
           ,'Reversal Journal'
           ,[strRecurringStatus]
           ,[strSourceType]
           ,[intFiscalPeriodId]
           ,[intFiscalYearId]
           ,@intJournalId
           FROM tblGLJournal WHERE intJournalId = @intJournalId
DECLARE @newIntJournalId INT
SELECT @newIntJournalId = @@IDENTITY

UPDATE tblSMStartingNumber SET intNumber = @intNumber where intStartingNumberId = @intStartingNumberId

INSERT INTO [dbo].[tblGLJournalDetail]
           ([intLineNo]
           ,[intJournalId]
           ,[dtmDate]
           ,[intAccountId]
           ,[dblDebit]
           ,[dblDebitRate]
           ,[dblCredit]
           ,[dblCreditRate]
           ,[dblDebitUnit]
           ,[dblCreditUnit]
           ,[strDescription]
           ,[intConcurrencyId]
           ,[dblUnitsInLBS]
           ,[strDocument]
           ,[strComments]
           ,[strReference]
           ,[dblDebitUnitsInLBS]
           ,[strCorrecting]
           ,[strSourcePgm]
           ,[strCheckBookNo]
           ,[strWorkArea]
           ,[strSourceKey]
           ,[dblDebitForeign]
           ,[dblDebitReport]
           ,[dblCreditForeign]
           ,[dblCreditReport])
    select
           [intLineNo]
           ,@newIntJournalId
           ,[dtmDate]
           ,[intAccountId]
           ,[dblCredit]
           ,[dblCreditRate]
           ,[dblDebit]
           ,[dblDebitRate]
           ,[dblCreditUnit]
           ,[dblDebitUnit]
           ,[strDescription]
           ,[intConcurrencyId]
           ,[dblUnitsInLBS]
           ,[strDocument]
           ,[strComments]
           ,[strReference]
           ,[dblDebitUnitsInLBS]
           ,[strCorrecting]
           ,[strSourcePgm]
           ,[strCheckBookNo]
           ,[strWorkArea]
           ,[strSourceKey]
           ,[dblCreditForeign]
           ,[dblCreditReport]
           ,[dblDebitForeign]
           ,[dblDebitReport]
           FROM tblGLJournalDetail WHERE intJournalId = @intJournalId
      SELECT @newIntJournalId
END
