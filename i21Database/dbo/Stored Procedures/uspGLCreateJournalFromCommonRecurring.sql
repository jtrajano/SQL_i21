-- =============================================
-- Author:		Trajano, Jeffrey
-- Create date: 03-05-2015
-- Description:	Creates journal from Common Info 
-- =============================================
CREATE PROCEDURE [dbo].[uspGLCreateJournalFromCommonRecurring] 
	@journalId  INT, 
	@journalDate DATETIME,
	@userId  INT,
	@strJournalId NVARCHAR(100) OUTPUT 
AS
BEGIN
	SET XACT_ABORT ON
	SET NOCOUNT ON
	DECLARE @entityid INT ,@smID varchar(20),@intJournalID INT
	DECLARE @dateNow DATE = CONVERT(DATE, GETDATE(),101)
	BEGIN TRY
		BEGIN TRANSACTION
			EXEC dbo.uspSMGetStartingNumber  2,@smID OUTPUT,NULL
			SELECT TOP 1 @entityid =[intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @userId
			INSERT INTO tblGLJournal(strDescription,intCurrencyId,dtmDate,dtmReverseDate,strJournalId,strJournalType,strTransactionType,strSourceType,intEntityId,ysnPosted,strRecurringStatus)
			SELECT strDescription,intCurrencyId,@journalDate,dtmReverseDate,@smID,'Recurring Journal','General Journal','GJ',@entityid,0,'Locked' FROM tblGLJournal
			WHERE intJournalId = @journalId
			SELECT  @intJournalID = SCOPE_IDENTITY() 
			INSERT INTO tblGLJournalDetail (intJournalId,intAccountId,intLineNo,dblCredit,dblCreditUnit,dblCreditRate,dblDebit,dblDebitUnit, dblDebitRate,strDescription,strReference,strComments,strDocument,dtmDate)
			SELECT @intJournalID,intAccountId,intLineNo,dblCredit,dblCreditUnit,dblCreditRate,dblDebit,dblDebitUnit,dblDebitRate,strDescription,strReference,strComments,strDocument,@journalDate
			FROM tblGLJournalDetail
			WHERE intJournalId = @journalId
		COMMIT TRANSACTION
		SET @strJournalId = @smID
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
END