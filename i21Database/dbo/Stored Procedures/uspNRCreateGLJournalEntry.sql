CREATE PROCEDURE [dbo].[uspNRCreateGLJournalEntry]
@intNoteId Int,
@TransactionTypeId Int,
@NoteTransId Int,
@EntityId Int,
@PayExtra Bit = 0,
@ExtraPayment numeric(18,6) = 0,
@LateCharge numeric(18,6) = 0,
@UseAdjustmentAcc nvarchar(50) = ''
AS
BEGIN
	
	DECLARE @strJournalId nvarchar(50)
			,@intCurrencyId Int 
			,@strHeaderDesc nvarchar(255)
			,@strDetailDesc nvarchar(255)
			,@intUserId Int
			,@intJournalId Int
			,@intDebitAccountId Int
			,@strDebitAccountDesc nvarchar(255)
			,@intCreditAccountId Int
			,@strCreditAccountDesc nvarchar(255)	
			,@strNoteType nvarchar(50)
			,@strNoteNumber nvarchar(50)	
			,@dblFee numeric(18,6)	
			,@dblTransAmt numeric(18,6)
			,@strReference nvarchar(max)
			,@intLocationId int
			,@intCashAccount Int
			,@dtmExpectedPayDate datetime
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
	SELECT @intUserId = intLastModifiedUserId, @dblTransAmt = dblTransAmount, @intLocationId = ISNULL(strLocation,0) 
	, @dtmExpectedPayDate = dtmNoteTranDate
	FROM dbo.tblNRNoteTransaction WHERE intNoteTransId = @NoteTransId                

	SELECT @intCashAccount = intCashAccount FROM dbo.tblSMCompanyLocation Where intCompanyLocationId = @intLocationId
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
	
	IF @strNoteType = 'Scheduled Invoice'
	BEGIN		
-- Scheduled Invoice Credit entry	
		IF @TransactionTypeId = 2
		BEGIN		
			SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLClearingAccount'
			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
			SET @strReference = 'Scheduled Invoice'
		END
		--IF @TransactionTypeId = 4
		--BEGIN
			
		--	IF @PayExtra = 0
		--	BEGIN
		--		SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
		--		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
		--		SET @strReference = 'NR Schd Payment'
		--	END
		--	ELSE
		--	BEGIN
		--		IF @ExtraPayment = 0
		--		BEGIN
		--			SELECT TOP 1 @dblTransAmt = dblExpectedPayAmt FROM dbo.tblNRScheduleTransaction Where intNoteId = @intNoteId --and dtmExpectedPayDate 
		--			SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
		--			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
		--			SET @strReference = 'NR Schd Payment'
		--		END
		--		ELSE
		--		BEGIN
		--			SET @dblTransAmt = @ExtraPayment
		--			SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
		--			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
		--			SET @strReference = 'NR Schd Payment'
		--		END				
		--	END	
		--	IF @LateCharge > 0
		--	BEGIN
		--		SET @dblTransAmt = @LateCharge
		--		SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
		--		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
		--		SET @strReference = 'ScheduledLateFee'
		--	END		
		--END
		IF @TransactionTypeId = 7
		BEGIN	
			If @PayExtra = 1
			BEGIN
				SET @dblTransAmt = @dblTransAmt * (-1)
				SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
			END	
			ELSE
			BEGIN
				If @UseAdjustmentAcc = 'Notes Write-off'			
					SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRNoteWriteOffAccount'
				Else If @UseAdjustmentAcc = 'Interest Income'
					SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLInterestIncomeAccount'
				Else If @UseAdjustmentAcc = 'Clearing Account'
					SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLClearingAccount'
			END				
			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
			SET @strReference = 'NR Adjustment Schd'
		END
		
	
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
		           
-- Scheduled Invoice Debit Entry		
		IF @TransactionTypeId = 2
		BEGIN
			SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
			SET @strReference = 'Scheduled Invoice'
		END
		--If @TransactionTypeId = 4
		--BEGIN
		--	IF @PayExtra = 0
		--	BEGIN
		--		SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRCashAccount'
		--		--SET @intDebitAccountId = @intCashAccount
		--		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--		SET @strReference = 'NR Schd Payment'
		--	END
		--	ELSE
		--	BEGIN
		--		IF @ExtraPayment = 0
		--		BEGIN
		--			SELECT TOP 1 @dblTransAmt = dblExpectedPayAmt FROM dbo.tblNRScheduleTransaction Where intNoteId = @intNoteId
		--			SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRCashAccount'
		--			--SET @intDebitAccountId = @intCashAccount
		--			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--			SET @strReference = 'NR Schd Payment'
		--		END
		--		ELSE
		--		BEGIN
		--			SET @dblTransAmt = @ExtraPayment
		--			SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRCashAccount'
		--			--SET @intDebitAccountId = @intCashAccount
		--			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--			SET @strReference = 'NR Schd Payment'
		--		END		
		--	END	
		--	IF @LateCharge > 0
		--	BEGIN
		--		SET @dblTransAmt = @LateCharge
		--		SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRCashAccount'
		--		--SET @intDebitAccountId = @intCashAccount
		--		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--		SET @strReference = 'ScheduledLateFee'
		--	END			
		--END
		
		--IF @TransactionTypeId = 6
		--BEGIN
		--	IF @PayExtra = 0
		--	BEGIN
		--		SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
		--		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--		SET @strReference = 'NR Schd Payment'
		--	END
		--	ELSE
		--	BEGIN
		--		IF @ExtraPayment = 0
		--		BEGIN
		--			SELECT TOP 1 @dblTransAmt = dblExpectedPayAmt FROM dbo.tblNRScheduleTransaction Where intNoteId = @intNoteId
		--			SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
		--			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--			SET @strReference = 'NR Schd Payment'
		--		END
		--		ELSE
		--		BEGIN
		--			SET @dblTransAmt = @ExtraPayment
		--			SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
		--			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--			SET @strReference = 'NR Schd Payment'
		--		END				
		--	END	
		--	IF @LateCharge > 0
		--	BEGIN
		--		SET @dblTransAmt = @LateCharge
		--		SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
		--		SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--		SET @strReference = 'ScheduledLateFee'
		--	END		
		--END
		
		IF @TransactionTypeId = 7
		BEGIN	
			If @PayExtra = 1
			BEGIN
				SET @dblTransAmt = @dblTransAmt * (-1)
				If @UseAdjustmentAcc = 'Notes Write-off'			
					SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRNoteWriteOffAccount'
				Else If @UseAdjustmentAcc = 'Interest Income'
					SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLInterestIncomeAccount'
				Else If @UseAdjustmentAcc = 'Clearing Account'
					SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLClearingAccount'
			END	
			ELSE
			BEGIN
				SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
			END				
			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
			SET @strReference = 'NR Adjustment Schd'
		END
		
			
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
	ELSE
	BEGIN
-- Non Schedule Credit Entry	
		IF @TransactionTypeId = 2	
		BEGIN		
			IF @dblFee > 0
			BEGIN 		
				SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLInterestIncomeAccount'
				SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
				SET @strReference = 'Fee for NR'
			END
		END	
		--If @TransactionTypeId = 4
		--BEGIN
		--	SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
		--	SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
		--	SET @strReference = 'NR Payment'
		--END
		--If @TransactionTypeId = 6
		--BEGIN
		--	SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRCashAccount'
		--	--SET @intDebitAccountId = @intCashAccount
		--	SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
		--	SET @strReference = 'NR Payment'
		--END	
		IF @TransactionTypeId = 7
		BEGIN	
			If @PayExtra = 1
			BEGIN
				SET @dblTransAmt = @dblTransAmt * (-1)
				SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
			END	
			ELSE
			BEGIN
				If @UseAdjustmentAcc = 'Notes Write-off'			
					SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRNoteWriteOffAccount'
				Else If @UseAdjustmentAcc = 'Interest Income'
					SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLInterestIncomeAccount'
				Else If @UseAdjustmentAcc = 'Clearing Account'
					SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLClearingAccount'
			END				
			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
			SET @strReference = 'NR Adjustment'
		END
		If @TransactionTypeId = 3
		BEGIN
			SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLInterestIncomeAccount'
			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
			SET @strReference = 'NR Interest'
		END
		
		
		
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
				   
				   
-- Non Schedule Debit Entry         
		IF @TransactionTypeId = 2	
		BEGIN		
			IF @dblFee > 0
			BEGIN 		
				SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
				SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
				SET @strReference = 'Fee for NR'
			END
		END	
		--If @TransactionTypeId = 4
		--BEGIN
		--	SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRCashAccount'
		--	--SET @intDebitAccountId = @intCashAccount
		--	SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--	SET @strReference = 'NR Payment'
		--END	
		--If @TransactionTypeId = 6
		--BEGIN
		--	SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
		--	SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
		--	SET @strReference = 'NR Payment'
		--END
		IF @TransactionTypeId = 7
		BEGIN	
			If @PayExtra = 1
			BEGIN
				SET @dblTransAmt = @dblTransAmt * (-1)
				If @UseAdjustmentAcc = 'Notes Write-off'			
					SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRNoteWriteOffAccount'
				Else If @UseAdjustmentAcc = 'Interest Income'
					SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLInterestIncomeAccount'
				Else If @UseAdjustmentAcc = 'Clearing Account'
					SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLClearingAccount'
			END	
			ELSE
			BEGIN
				SELECT @intDebitAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLScheduledInvoiceAccount'
			END				
			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intDebitAccountId
			SET @strReference = 'NR Adjustment'
		END
		If @TransactionTypeId = 3
		BEGIN
			SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRGLNotesReceivableAccount'
			SELECT @strDetailDesc = strDescription FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
			SET @strReference = 'NR Interest'
		END		
			
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