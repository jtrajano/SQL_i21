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
	DECLARE @id INT, @intNumber INT, @strPrefix VARCHAR(10),@smID varchar(10),@intJournalID INT
	DECLARE @dateNow DATE = CONVERT(DATE, GETDATE(),101)
	
	INSERT INTO @IntegerTable SELECT * FROM fnCreateTableFromDelimitedValues(@delimitedIds,@delimiter)	
	BEGIN TRY
		BEGIN TRANSACTION
		DECLARE cursor_id CURSOR FOR SELECT intValue FROM @IntegerTable
		OPEN cursor_id
		FETCH NEXT FROM cursor_id INTO @id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT  @intNumber = intNumber, @strPrefix = strPrefix FROM tblSMStartingNumber WHERE intStartingNumberId = 4
			SET @smID = @strPrefix + CONVERT(VARCHAR(5),@intNumber)
			UPDATE tblSMStartingNumber SET intNumber = @intNumber + 1 WHERE intStartingNumberId = 4
					
			INSERT INTO tblGLJournal(strDescription,intCurrencyId,dtmDate,dtmReverseDate,strJournalId,strJournalType,strTransactionType,strSourceType,intEntityId,ysnPosted,strRecurringStatus)
			SELECT strReference,intCurrencyId,@dateNow,dtmReverseDate,@smID,'Recurring Journal','General Journal','GJ',@entityid,0,strMode FROM tblGLJournalRecurring
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
