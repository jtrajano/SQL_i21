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
	DECLARE @reverseDate DATETIME,@strJournalId1 NVARCHAR(50),@dtmDate datetime
	BEGIN TRY
		BEGIN TRANSACTION
			EXEC dbo.uspSMGetStartingNumber  2,@smID OUTPUT,NULL
			SELECT TOP 1 @entityid =[intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @userId
			SELECT TOP 1 @dtmDate = dtmDate, @reverseDate= dtmReverseDate, @strJournalId1 = strJournalId FROM tblGLJournal WHERE intJournalId = @journalId
			IF @reverseDate IS NOT NULL 
			BEGIN
				SELECT @reverseDate = 
					CASE WHEN  SM.strFrequency = 'Daily' then DATEADD(DAY, datediff(day,@dtmDate , @journalDate), @reverseDate)
						 WHEN  SM.strFrequency = 'Weekly' then DATEADD(WEEK,DATEDIFF(WEEK,@dtmDate, @journalDate), @reverseDate)
						 WHEN  SM.strFrequency = 'Bi-Weekly' then DATEADD(WEEK,DATEDIFF(WEEK,@dtmDate, @journalDate), @reverseDate)
						 WHEN  SM.strFrequency = 'Semi-Monthly' then DATEADD(WEEK,DATEDIFF(WEEK,@dtmDate, @journalDate), @reverseDate)
						 WHEN  SM.strFrequency ='Monthly' then DATEADD(MONTH,DATEDIFF(MONTH,@dtmDate, @journalDate), @reverseDate)
						 WHEN  SM.strFrequency = 'Bi-Monthly' then DATEADD(WEEK,DATEDIFF(WEEK,@dtmDate, @journalDate), @reverseDate)
						 WHEN  SM.strFrequency = 'Quarterly' then DATEADD(MONTH,DATEDIFF(MONTH,@dtmDate, @journalDate), @reverseDate)
						 WHEN  SM.strFrequency = 'Semi-Annually' then DATEADD(MONTH,DATEDIFF(MONTH,@dtmDate, @journalDate), @reverseDate)
						 WHEN  SM.strFrequency = 'Annually' then DATEADD(YEAR,DATEDIFF(YEAR,@dtmDate, @journalDate), @reverseDate)
					END
				FROM 
				tblSMRecurringTransaction SM
				WHERE  strTransactionNumber= @strJournalId1 and strTransactionType  = 'General Journal'
			END
			INSERT INTO tblGLJournal(intCompanyId, strDescription,intCurrencyId,dtmDate,dtmReverseDate,strJournalId,strJournalType,strTransactionType,strSourceType,intEntityId,ysnPosted,strRecurringStatus)
			SELECT intCompanyId,strDescription,intCurrencyId,@journalDate,@reverseDate,@smID,'Recurring Journal','General Journal','GJ',@entityid,0,'Locked' FROM tblGLJournal
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

