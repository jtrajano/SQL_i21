/****** Object:  StoredProcedure [dbo].[uspGLImportRecurring]    Script Date: 07/01/2015 10:33:10 ******/
CREATE PROCEDURE [dbo].[uspGLImportRecurring]
AS
BEGIN

IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLJournalRecurring WHERE ISNULL(ysnImported,0) = 0) RETURN

DECLARE @TEMP TABLE 
(
	RecurringID INT,
	JournalID INT,
	ImportedHeader BIT,
	ImportedDetail BIT
)
DECLARE @intRecurringId INT,@intStartingNumberId INT, @strPrefix NVARCHAR(10), @intNumber INT, @intJournalId INT

BEGIN TRY
BEGIN TRANSACTION
		PRINT 'Begin Importing Recurring Transaction'

		INSERT INTO @TEMP (RecurringID,ImportedHeader,ImportedDetail)
			SELECT intJournalRecurringId,0,0 from tblGLJournalRecurring
		-- Importing the header
		WHILE EXISTS (SELECT TOP 1 1 FROM @TEMP WHERE ImportedHeader = 0)
		BEGIN
			SELECT TOP 1 @intRecurringId = RecurringID FROM @TEMP WHERE ImportedHeader = 0
			SELECT @intStartingNumberId = intStartingNumberId, @strPrefix = strPrefix ,@intNumber = intNumber FROM tblSMStartingNumber WHERE strTransactionType = 'General Journal'
			INSERT INTO [dbo].[tblGLJournal]
					   ([strDescription]
					   ,[dblExchangeRate]
					   ,[dtmReverseDate]
					   ,intCurrencyId
					   ,strTransactionType
					   ,strJournalType
					   ,strJournalId)
			SELECT 
			  CASE WHEN RTRIM(strReference) = '' OR ISNULL(strReference,'') = '' THEN [strRecurringPeriod] ELSE strReference END
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
		  UPDATE tblGLJournalRecurring SET intJournalId = @intJournalId WHERE intJournalRecurringId = @intRecurringId
		  UPDATE tblSMStartingNumber SET intNumber = @intNumber + 1 where intStartingNumberId = @intStartingNumberId
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
	PRINT 'End Importing Recurring Transaction'		
	COMMIT TRANSACTION


END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT 'Error importing recurring transaction : ' + ERROR_MESSAGE()
END CATCH
END