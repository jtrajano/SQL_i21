CREATE PROCEDURE [dbo].[uspGLImportRecurring]
AS
BEGIN

IF EXISTS(SELECT TOP 1 1 FROM tblGLJournal WHERE strJournalType = 'Imported Recurring')	RETURN

DECLARE @TEMP TABLE 
(
	RecurringID INT,
	JournalID INT,
	ImportedHeader BIT,
	ImportedDetail BIT
)
DECLARE @intRecurringId INT,@intStartingNumberId INT, @strPrefix NVARCHAR(10), @intNumber INT, @intJournalId INT

PRINT 'Begin Importing Recurring Transaction'

INSERT INTO @TEMP (RecurringID,ImportedHeader,ImportedDetail)
	SELECT intJournalRecurringId,0,0 from tblGLJournalRecurring
-- Importing the header
WHILE EXISTS (SELECT TOP 1 1 FROM @TEMP WHERE ImportedHeader = 0)
BEGIN
	SELECT TOP 1 @intRecurringId = RecurringID FROM @TEMP WHERE ImportedHeader = 0
	SELECT @intStartingNumberId = intStartingNumberId, @strPrefix = strPrefix ,@intNumber = intNumber + 1 FROM tblSMStartingNumber WHERE strTransactionType = 'General Journal'
	INSERT INTO [dbo].[tblGLJournal]
			   ([strDescription]
			   ,[dblExchangeRate]
			   ,[dtmReverseDate]
			   ,intCurrencyId
			   ,strTransactionType
			   ,strJournalType
			   ,strJournalId)
	SELECT 
	  [strRecurringPeriod] 
	  ,[dblExchangeRate]
	  ,[dtmReverseDate]
	  ,(SELECT TOP 1 intCurrencyId FROM tblGLJournalDetail where intJournalRecurringId = @intRecurringId)
	  ,'Recurring'
	  ,'Imported Recurring'
	  , @strPrefix + CONVERT(NVARCHAR(10),@intNumber)
  FROM [dbo].[tblGLJournalRecurring]
  WHERE intJournalRecurringId = @intRecurringId
  SELECT @intJournalId = @@IDENTITY
  UPDATE @TEMP SET ImportedHeader = 1, JournalID = @intJournalId WHERE RecurringID = @intRecurringId
  
  INSERT INTO [dbo].[tblSMRecurringTransaction]
           ([intTransactionId]
           ,[strTransactionNumber]
           ,[strTransactionType]
           ,[strReference]
           ,[strFrequency]
           ,[dtmNextProcess]
           ,dtmLastProcess
           ,[ysnDue]
           ,[strDayOfMonth]
           ,[dtmStartDate]
           ,[dtmEndDate]
           ,[ysnActive]
           ,[intIteration]
           ,[ysnAvailable]
           ,intUserId)
           
   SELECT  @intJournalId
		   ,@strPrefix + CONVERT(NVARCHAR(10),@intNumber)
		   ,'General Journal'
		   ,strReference
		   ,strRecurringPeriod
		   ,ISNULL(dtmNextDueDate,'01-01-1900')
		   ,ISNULL(dtmLastDueDate,'01-01-1900')
		   ,CASE WHEN DATEADD(DAY,-1, GETDATE()) <=  ISNULL(dtmNextDueDate,'01-01-1900') THEN 1 ELSE 0 END
		   ,strDays
		   ,dtmStartDate
		   ,dtmEndDate
		   ,1
		   ,intInterval
		   ,1 
		   ,0
	FROM tblGLJournalRecurring WHERE intJournalRecurringId = @intRecurringId
  
   UPDATE tblSMStartingNumber SET intNumber = @intNumber where intStartingNumberId = @intStartingNumberId
END

-- Importing the detail
WHILE EXISTS (SELECT TOP 1 1 FROM @TEMP WHERE ImportedDetail = 0)
BEGIN
	SELECT TOP 1 @intRecurringId = RecurringID, @intJournalId = JournalID  FROM @TEMP WHERE ImportedDetail = 0
	INSERT INTO [dbo].[tblGLJournalDetail]
			   ([intLineNo]
			   ,[dtmDate]
			   ,[intAccountId]
			   ,[dblDebit]
			   ,[dblDebitRate]
			   ,[dblCredit]
			   ,[dblCreditRate]
			   ,[dblDebitUnit]
			   ,[dblCreditUnit]
			   ,[strDescription]
			   ,[dblUnitsInLBS]
			   ,[strDocument]
			   ,[strComments]
			   ,[strReference]
			   ,intJournalId
			   )
	SELECT [intLineNo]
		  ,[dtmDate]
		  ,[intAccountId]
		  ,[dblDebit]
		  ,[dblDebitRate]
		  ,[dblCredit]
		  ,[dblCreditRate]
		  ,[dblDebitUnit]
		  ,[dblCreditUnit]
		  ,[strDescription]
		  ,[dblUnitsInLBS]
		  ,[strDocument]
		  ,[strComments]
		  ,[strReference]
		  ,@intJournalId
	  FROM [dbo].[tblGLJournalRecurringDetail]
	  WHERE intJournalRecurringId = @intRecurringId
	  UPDATE @TEMP SET ImportedDetail = 1 WHERE RecurringID = @intRecurringId
END
END
PRINT 'End Importing Recurring Transaction'








