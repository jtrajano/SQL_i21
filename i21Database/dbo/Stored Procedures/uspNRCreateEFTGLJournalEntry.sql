CREATE PROCEDURE [dbo].[uspNRCreateEFTGLJournalEntry]
@intNoteId Int,
@SchdTransId Int,
@GenerateType nvarchar(50),
@dblTransAmt numeric(18,6) = 0
AS
BEGIN

	DECLARE @strJournalId nvarchar(50)
			,@intCurrencyId Int 
			,@strHeaderDesc nvarchar(255)
			,@strDetailDesc nvarchar(255)
			,@intUserId Int
			,@EntityId Int
			,@intJournalId Int
			,@intDebitAccountId Int
			,@strDebitAccountDesc nvarchar(255)
			,@intCreditAccountId Int
			,@strCreditAccountDesc nvarchar(255)	
			,@strNoteType nvarchar(50)
			,@strNoteNumber nvarchar(50)	
			,@dblFee numeric(18,6)	
			--,@dblTransAmt numeric(18,6)
			,@strReference nvarchar(max)
			,@dblPrincipal numeric(18,6)
			,@dblInterest numeric(18,6)
			--,@strJournalType nvarchar(50)
			--,@EntityId Int
	
	--SET @strJournalType = 'Notes Receivable'
	--Get Default Currency Id
	SET @intCurrencyId = (
				SELECT TOP 1 intCurrencyID FROM tblSMCurrency 
				WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') > 0 
                THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency')
                  ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD') END)
                  )
                  
	--Get fee amount
	SELECT @dblFee = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRFee'                  
     
    -- Get Header Description , note type             
	SELECT	@strHeaderDesc = strNoteNumber + ' - ' + D.strDescriptionName
			, @strNoteType = N.strNoteType 		
			, @strNoteNumber = N.strNoteNumber	
	FROM dbo.tblNRNote N
	JOIN dbo.tblNRNoteDescription D ON D.intDescriptionId = N.intDescriptionId 
	WHERE N.intNoteId = @intNoteId  
	
	-- Get Note Transaction user Id, trans amount
	Select * from dbo.tblSMUserSecurity Where strUserName like '%ADMIN%'
	SELECT @intUserId = intUserSecurityID, @EntityId = intEntityId FROM dbo.tblSMUserSecurity Where strUserName = 'SSIADMIN'              

	--Get Journal Id
	--	SET @strJournalId = 'F' + RIGHT('00' + CAST(DATEPART(MM,GETDATE()) as NVARCHAR(2)),2) + RIGHT('00' + CAST(DATEPART(DD,GETDATE()) as NVARCHAR(2)),2)
	EXEC [dbo].uspSMGetStartingNumber 2, @strJournalId OUTPUT

	
	-- Insert into header table 
	INSERT INTO [dbo].[tblGLJournal]
           ([dtmReverseDate],[strJournalId],[strTransactionType],[dtmDate],[strReverseLink],[intCurrencyId],[dblExchangeRate],[dtmPosted],[strDescription],[ysnPosted],[intConcurrencyId],[dtmDateEntered],[intUserId],[intEntityId],[strSourceId],[strJournalType],[strRecurringStatus],[strSourceType])
     VALUES
           (
            NULL -----------------dtmReverseDate
           ,@strJournalId --------strJournalId
           ,'General Journal' ----strTransactionType
           ,GETDATE() ------------dtmDate
           ,NULL -----------------strReverseLink
           ,@intCurrencyId -------intCurrencyId
           ,NULL -----------------dblExchangeRate
           ,GETDATE() ------------dtmPosted
           ,@strHeaderDesc ----------strDescription
           ,0 --------------------ysnPosted
           ,1 --------------------intConcurrencyId
           ,GETDATE() ------------dtmDateEntered
           ,@intUserId --------------intUserId
           ,@EntityId ------------intEntityId
           ,@intNoteId --------------strSourceId
           ,'Notes Receivable' ---strJournalType
           ,NULL  ----------------strRecurringStatus
           ,'NR' -----------------strSourceType
           )

	SET @intJournalId = @@IDENTITY
	
	--Insert into detail table
	IF @GenerateType = 'GenerateInvoice'
	BEGIN
	
		SELECT @dblPrincipal = dblPrincipal, @dblInterest = dblInterest FROM dbo.tblNRScheduleTransaction Where intScheduleTransId = @SchdTransId
		SET @strReference = 'GeneratedInvoice'
		
		SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
		
		INSERT INTO [dbo].[tblGLJournalDetail]
			   ([intLineNo],[intJournalId],[dtmDate],[intAccountId],[dblDebit],[dblDebitRate],[dblCredit],[dblCreditRate],[dblDebitUnit],[dblCreditUnit],[strDescription],[intConcurrencyId],[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],[strWorkArea])
		 VALUES
			   (1 ---------------------------------------intLineNo
			   ,@intJournalId ---------------------------intJournalId
			   ,GETDATE() -------------------------------dtmDate
			   ,@intCreditAccountId ---------------------intAccountId
			   ,0 ---------------------------------------dblDebit
			   ,0 ---------------------------------------dblDebitRate
			   ,@dblPrincipal ---------------------------dblCredit
			   ,0 ---------------------------------------dblCreditRate
			   ,0 ---------------------------------------dblDebitUnit
			   ,0 ---------------------------------------dblCreditUnit
			   ,@strDetailDesc --------------------------strDescription
			   ,1 ---------------------------------------intConcurrencyId
			   ,0 ---------------------------------------dblUnitsInLBS
			   ,@strNoteNumber --------------------------strDocument
			   ,'' --------------------------------------strComments
			   ,@strReference ---------------------------strReference
			   ,0 ---------------------------------------dblDebitUnitsInLBS
			   ,NULL ------------------------------------strCorrecting
			   ,NULL ------------------------------------strSourcePgm
			   ,NULL ------------------------------------strCheckBookNo
			   ,NULL ------------------------------------strWorkArea
			   )
		
		SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLInterestIncomeAccount'
		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
		
		INSERT INTO [dbo].[tblGLJournalDetail]
			   ([intLineNo],[intJournalId],[dtmDate],[intAccountId],[dblDebit],[dblDebitRate],[dblCredit],[dblCreditRate],[dblDebitUnit],[dblCreditUnit],[strDescription],[intConcurrencyId],[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],[strWorkArea])
		 VALUES
			   (1 ---------------------------------------intLineNo
			   ,@intJournalId ---------------------------intJournalId
			   ,GETDATE() -------------------------------dtmDate
			   ,@intCreditAccountId ---------------------intAccountId
			   ,0 ---------------------------------------dblDebit
			   ,0 ---------------------------------------dblDebitRate
			   ,@dblInterest ----------------------------dblCredit
			   ,0 ---------------------------------------dblCreditRate
			   ,0 ---------------------------------------dblDebitUnit
			   ,0 ---------------------------------------dblCreditUnit
			   ,@strDetailDesc --------------------------strDescription
			   ,1 ---------------------------------------intConcurrencyId
			   ,0 ---------------------------------------dblUnitsInLBS
			   ,@strNoteNumber --------------------------strDocument
			   ,'' --------------------------------------strComments
			   ,@strReference ---------------------------strReference
			   ,0 ---------------------------------------dblDebitUnitsInLBS
			   ,NULL ------------------------------------strCorrecting
			   ,NULL ------------------------------------strSourcePgm
			   ,NULL ------------------------------------strCheckBookNo
			   ,NULL ------------------------------------strWorkArea
			   )
		
		SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		SET @dblTransAmt = @dblPrincipal + @dblInterest
		
		INSERT INTO [dbo].[tblGLJournalDetail]
			   ([intLineNo],[intJournalId],[dtmDate],[intAccountId],[dblDebit],[dblDebitRate],[dblCredit],[dblCreditRate],[dblDebitUnit],[dblCreditUnit],[strDescription],[intConcurrencyId],[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],[strWorkArea])
		 VALUES
			   (2 ---------------------------------------intLineNo
			   ,@intJournalId ---------------------------intJournalId
			   ,GETDATE() -------------------------------dtmDate
			   ,@intDebitAccountId ----------------------intAccountId
			   ,@dblTransAmt ----------------------------dblDebit
			   ,0 ---------------------------------------dblDebitRate
			   ,0 ---------------------------------------dblCredit
			   ,0 ---------------------------------------dblCreditRate
			   ,0 ---------------------------------------dblDebitUnit
			   ,0 ---------------------------------------dblCreditUnit
			   ,@strDetailDesc --------------------------strDescription
			   ,1 ---------------------------------------intConcurrencyId
			   ,0 ---------------------------------------dblUnitsInLBS
			   ,@strNoteNumber --------------------------strDocument
			   ,'' --------------------------------------strComments
			   ,@strReference ---------------------------strReference
			   ,0 ---------------------------------------dblDebitUnitsInLBS
			   ,NULL ------------------------------------strCorrecting
			   ,NULL ------------------------------------strSourcePgm
			   ,NULL ------------------------------------strCheckBookNo
			   ,NULL ------------------------------------strWorkArea
		   )
		   
	END

	IF @GenerateType = 'GenerateLate'
	BEGIN
	
		SET @strReference = 'Scheduled Late Fee'
		
		SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRScheduledInvoiceLateFeeAccount'
		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
		
		INSERT INTO [dbo].[tblGLJournalDetail]
			   ([intLineNo],[intJournalId],[dtmDate],[intAccountId],[dblDebit],[dblDebitRate],[dblCredit],[dblCreditRate],[dblDebitUnit],[dblCreditUnit],[strDescription],[intConcurrencyId],[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],[strWorkArea])
		 VALUES
			   (1 ---------------------------------------intLineNo
			   ,@intJournalId ---------------------------intJournalId
			   ,GETDATE() -------------------------------dtmDate
			   ,@intCreditAccountId ---------------------intAccountId
			   ,0 ---------------------------------------dblDebit
			   ,0 ---------------------------------------dblDebitRate
			   ,@dblTransAmt ----------------------------dblCredit
			   ,0 ---------------------------------------dblCreditRate
			   ,0 ---------------------------------------dblDebitUnit
			   ,0 ---------------------------------------dblCreditUnit
			   ,@strDetailDesc --------------------------strDescription
			   ,1 ---------------------------------------intConcurrencyId
			   ,0 ---------------------------------------dblUnitsInLBS
			   ,@strNoteNumber --------------------------strDocument
			   ,'' --------------------------------------strComments
			   ,@strReference ---------------------------strReference
			   ,0 ---------------------------------------dblDebitUnitsInLBS
			   ,NULL ------------------------------------strCorrecting
			   ,NULL ------------------------------------strSourcePgm
			   ,NULL ------------------------------------strCheckBookNo
			   ,NULL ------------------------------------strWorkArea
			   )
		
		
		SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		SET @dblTransAmt = @dblPrincipal + @dblInterest
		
		INSERT INTO [dbo].[tblGLJournalDetail]
			   ([intLineNo],[intJournalId],[dtmDate],[intAccountId],[dblDebit],[dblDebitRate],[dblCredit],[dblCreditRate],[dblDebitUnit],[dblCreditUnit],[strDescription],[intConcurrencyId],[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],[strWorkArea])
		 VALUES
			   (2 ---------------------------------------intLineNo
			   ,@intJournalId ---------------------------intJournalId
			   ,GETDATE() -------------------------------dtmDate
			   ,@intDebitAccountId ----------------------intAccountId
			   ,@dblTransAmt ----------------------------dblDebit
			   ,0 ---------------------------------------dblDebitRate
			   ,0 ---------------------------------------dblCredit
			   ,0 ---------------------------------------dblCreditRate
			   ,0 ---------------------------------------dblDebitUnit
			   ,0 ---------------------------------------dblCreditUnit
			   ,@strDetailDesc --------------------------strDescription
			   ,1 ---------------------------------------intConcurrencyId
			   ,0 ---------------------------------------dblUnitsInLBS
			   ,@strNoteNumber --------------------------strDocument
			   ,'' --------------------------------------strComments
			   ,@strReference ---------------------------strReference
			   ,0 ---------------------------------------dblDebitUnitsInLBS
			   ,NULL ------------------------------------strCorrecting
			   ,NULL ------------------------------------strSourcePgm
			   ,NULL ------------------------------------strCheckBookNo
			   ,NULL ------------------------------------strWorkArea
		   )
		   
	END
	
	IF @GenerateType = 'GeneratePayment'
	BEGIN
	
		SELECT @dblTransAmt = dblExpectedPayAmt FROM dbo.tblNRScheduleTransaction Where intScheduleTransId = @SchdTransId
		SET @strReference = 'NREFTPayment'
		
		SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
		
		INSERT INTO [dbo].[tblGLJournalDetail]
			   ([intLineNo],[intJournalId],[dtmDate],[intAccountId],[dblDebit],[dblDebitRate],[dblCredit],[dblCreditRate],[dblDebitUnit],[dblCreditUnit],[strDescription],[intConcurrencyId],[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],[strWorkArea])
		 VALUES
			   (1 ---------------------------------------intLineNo
			   ,@intJournalId ---------------------------intJournalId
			   ,GETDATE() -------------------------------dtmDate
			   ,@intCreditAccountId ---------------------intAccountId
			   ,0 ---------------------------------------dblDebit
			   ,0 ---------------------------------------dblDebitRate
			   ,@dblTransAmt ----------------------------dblCredit
			   ,0 ---------------------------------------dblCreditRate
			   ,0 ---------------------------------------dblDebitUnit
			   ,0 ---------------------------------------dblCreditUnit
			   ,@strDetailDesc --------------------------strDescription
			   ,1 ---------------------------------------intConcurrencyId
			   ,0 ---------------------------------------dblUnitsInLBS
			   ,@strNoteNumber --------------------------strDocument
			   ,'' --------------------------------------strComments
			   ,@strReference ---------------------------strReference
			   ,0 ---------------------------------------dblDebitUnitsInLBS
			   ,NULL ------------------------------------strCorrecting
			   ,NULL ------------------------------------strSourcePgm
			   ,NULL ------------------------------------strCheckBookNo
			   ,NULL ------------------------------------strWorkArea
			   )
		
		
		--SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRCashAccount'
		--SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--SET @dblTransAmt = @dblPrincipal + @dblInterest
		
		--INSERT INTO [dbo].[tblGLJournalDetail]
		--	   ([intLineNo],[intJournalId],[dtmDate],[intAccountId],[dblDebit],[dblDebitRate],[dblCredit],[dblCreditRate],[dblDebitUnit],[dblCreditUnit],[strDescription],[intConcurrencyId],[dblUnitsInLBS],[strDocument],[strComments],[strReference],[dblDebitUnitsInLBS],[strCorrecting],[strSourcePgm],[strCheckBookNo],[strWorkArea])
		-- VALUES
		--	   (2 ---------------------------------------intLineNo
		--	   ,@intJournalId ---------------------------intJournalId
		--	   ,GETDATE() -------------------------------dtmDate
		--	   ,@intDebitAccountId ----------------------intAccountId
		--	   ,@dblTransAmt ----------------------------dblDebit
		--	   ,0 ---------------------------------------dblDebitRate
		--	   ,0 ---------------------------------------dblCredit
		--	   ,0 ---------------------------------------dblCreditRate
		--	   ,0 ---------------------------------------dblDebitUnit
		--	   ,0 ---------------------------------------dblCreditUnit
		--	   ,@strDetailDesc --------------------------strDescription
		--	   ,1 ---------------------------------------intConcurrencyId
		--	   ,0 ---------------------------------------dblUnitsInLBS
		--	   ,@strNoteNumber --------------------------strDocument
		--	   ,'' --------------------------------------strComments
		--	   ,@strReference ---------------------------strReference
		--	   ,0 ---------------------------------------dblDebitUnitsInLBS
		--	   ,NULL ------------------------------------strCorrecting
		--	   ,NULL ------------------------------------strSourcePgm
		--	   ,NULL ------------------------------------strCheckBookNo
		--	   ,NULL ------------------------------------strWorkArea
		--   )
		   
	END
	
	Declare @strBatchId nvarchar(50), @ParamVal nvarchar(MAX)
	EXEC [dbo].uspSMGetStartingNumber 3, @strBatchId OUTPUT
	SET @ParamVal = 'select intJournalId from tblGLJournal where intJournalId = ' + CAST(@intJournalId as nvarchar(20))
	
	DECLARE @intCount AS INT
	EXEC [dbo].[uspGLPostJournal]
				@Param   = @ParamVal ,					-- Journal ID to Post
				@ysnPost = 1,                           -- 1
				@ysnRecap = 0,                          -- 0
				@strBatchId = @strBatchId,              -- Batch ID
				@strJournalType = 'Notes Receivable',
				@intEntityId = 1,                       -- USER Id THAT INITIATES POSTING
				@successfulCount = @intCount OUTPUT     -- OUTPUT PARAMETER THAT RETURNS TOTAL NUMBER OF SUCCESSFUL RECORDS
	                 
	SELECT @intCount

END
