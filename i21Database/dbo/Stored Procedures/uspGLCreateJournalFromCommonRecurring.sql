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
	SET NOCOUNT ON;
	DECLARE @entityid INT ,@intNumber INT, @strPrefix VARCHAR(10),@smID varchar(10),@intJournalID INT
	BEGIN TRY
		BEGIN TRANSACTION
			SELECT TOP 1 @entityid =intEntityId FROM tblSMUserSecurity WHERE intUserSecurityID = @userId
			SELECT  @intNumber = intNumber, @strPrefix = strPrefix FROM tblSMStartingNumber WHERE intStartingNumberId = 4
			SET @smID = @strPrefix + CONVERT(VARCHAR(5),@intNumber)
			UPDATE tblSMStartingNumber SET intNumber = @intNumber + 1 WHERE intStartingNumberId = 4
			INSERT INTO tblGLJournal(strDescription,intCurrencyId,dtmDate,dtmReverseDate,strJournalId,strJournalType,strTransactionType,strSourceType,intEntityId,ysnPosted,strRecurringStatus)
			SELECT strDescription,intCurrencyId,dtmDate,dtmReverseDate,@smID,'Common Recurring Journal','General Journal','GJ',@entityid,0,'Locked' FROM tblGLJournal
			WHERE intJournalId = @journalId
			SELECT  @intJournalID = SCOPE_IDENTITY() 
			INSERT INTO tblGLJournalDetail (intJournalId,intAccountId,intLineNo,dblCredit,dblCreditUnit,dblCreditRate,dblDebit,dblDebitUnit, dblDebitRate,strDescription,strReference,strComments,strDocument,dtmDate)
			SELECT @intJournalID,intAccountId,intLineNo,dblCredit,dblCreditUnit,dblCreditRate,dblDebit,dblDebitUnit,dblDebitRate,strDescription,strReference,strComments,strDocument,dtmDate
			FROM tblGLJournalDetail
			WHERE intJournalId = @journalId
		CLOSE cursor_id
		DEALLOCATE cursor_id
		COMMIT TRANSACTION
		SET @strJournalId = @smID
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	END CATCH
END