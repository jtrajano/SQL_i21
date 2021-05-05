﻿-- =============================================
-- Author:		Trajano, Jeffrey
-- Create date: 12-11-2014
-- Description:	Creates recurring journal via delimited ids
-- =============================================
CREATE PROCEDURE [dbo].[uspGLCreateRecurringJournal] 
	@delimitedIds  varchar (max), 
	@delimiter nvarchar(1),
	@entityid  int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @journalIDS varchar(max)
	DECLARE	@IntegerTable TABLE (intID int ,intValue INT)
	DECLARE @id INT, @smID varchar(20),@intJournalID INT
	DECLARE @dateNow DATE = CONVERT(DATE, GETDATE(),101)
	
	INSERT INTO @IntegerTable SELECT * FROM fnCreateTableFromDelimitedValues(@delimitedIds,@delimiter)	
	BEGIN TRY
		BEGIN TRANSACTION
		DECLARE cursor_id CURSOR FOR SELECT intValue FROM @IntegerTable
		OPEN cursor_id
		FETCH NEXT FROM cursor_id INTO @id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC dbo.uspSMGetStartingNumber  2,@smID OUTPUT,NULL
			INSERT INTO tblGLJournal(
				strDescription,intCurrencyId,dtmDate,dtmReverseDate,strJournalId,strJournalType,strTransactionType,
				strSourceType,intEntityId,ysnPosted,strRecurringStatus,intFiscalYearId, intFiscalPeriodId
			
			)
			SELECT strReference,intCurrencyId,@dateNow,dtmReverseDate,@smID,'Recurring Journal','General Journal','GJ',@entityid,
				0,strMode, FY.intFiscalYearId, FY.intGLFiscalYearPeriodId FROM tblGLJournalRecurring
			OUTER APPLY(
				SELECT intFiscalYearId, intGLFiscalYearPeriodId FROM tblGLFiscalYearPeriod WHERE @dateNow BETWEEN dtmStartDate AND dtmEndDate
			)FY
			WHERE intJournalRecurringId = @id
			SELECT  @intJournalID = SCOPE_IDENTITY() 
			SET @journalIDS = CONVERT(VARCHAR(5), @intJournalID) + @delimiter
			
			INSERT INTO tblGLJournalDetail (intJournalId,intAccountId,intLineNo,dblCredit,dblCreditUnit,dblCreditRate,dblDebit,dblDebitUnit, dblDebitRate,strDescription,strReference,strComments,strDocument,dtmDate)
			SELECT @intJournalID,intAccountId,intLineNo,dblCredit,dblCreditUnit,dblCreditRate,dblDebit,dblDebitUnit,dblDebitRate,strDescription,strReference,strComments,strDocument,@dateNow
			FROM tblGLJournalRecurringDetail 
			WHERE intJournalRecurringId = @id
			 
			UPDATE tblGLJournalRecurring SET dtmLastDueDate = @dateNow WHERE intJournalRecurringId = @id
			
			INSERT INTO tblGLRecurringHistory (strJournalId,strJournalRecurringId,strTransactionType,strReference,dtmLastProcess,dtmNextProcess,dtmProcessDate)
			SELECT @smID,strJournalRecurringId,'General Journal',strReference,@dateNow,@dateNow,@dateNow FROM tblGLJournalRecurring WHERE intJournalRecurringId = @id
			FETCH NEXT FROM cursor_id INTO @id
		END
		CLOSE cursor_id
		DEALLOCATE cursor_id
		COMMIT TRANSACTION
		
		SELECT SUBSTRING(@journalIDS,0, LEN(@journalIDS))
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT ''
	END CATCH
END
