

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspGLImportSubLedger' and type = 'P') 
			DROP PROCEDURE [dbo].[uspGLImportSubLedger];
GO
	
EXEC('CREATE PROCEDURE uspGLImportSubLedger
	( @startingPeriod INT,@endingPeriod INT,@intCurrencyId INT, @intUserId INT, @version VARCHAR(20),@importLogId INT OUTPUT)
AS
BEGIN
	SET NOCOUNT ON;
			
DECLARE @isCOAPresent BIT 
SELECT @isCOAPresent = 1,@importLogId = 0
IF NOT EXISTS (SELECT * FROM glijemst WHERE glije_period between @startingPeriod and @endingPeriod)
BEGIN
	IF @importLogId = 0
		EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'',@intUserId,@version ,@importLogId OUTPUT
	UPDATE tblGLCOAImportLog SET strEvent = ''No Data to import from the Origin on a given period.'' WHERE intImportLogId = @importLogId
	RETURN
END


IF NOT EXISTS( SELECT * FROM tblGLCOACrossReference)
BEGIN
	IF @importLogId = 0
		EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'',@intUserId,@version ,@importLogId OUTPUT
	UPDATE tblGLCOAImportLog SET strEvent = ''Unable to Post because there is no cross reference between iRelySuite and Origin.'' WHERE intImportLogId = @importLogId
	SELECT @isCOAPresent = 0
END
						
	BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @uid UNIQUEIDENTIFIER
	SELECT @uid =NEWID()
	INSERT INTO tblGLIjemst(glije_period,glije_acct_no,glije_src_sys,glije_src_no, glije_line_no,glije_date,glije_time,glije_ref,glije_doc,glije_comments,
	glije_dr_cr_ind,glije_amt,glije_units,glije_correcting,glije_source_pgm,glije_work_area,glije_cbk_no,glije_user_id,glije_user_rev_dt,A4GLIdentity,glije_uid)
	SELECT ISNULL(glije_period, ''0'') 
                                   ,ISNULL(glije_acct_no, ''0'')
                                   ,ISNULL(glije_src_sys, '''')
                                   ,ISNULL(glije_src_no, '''') 
                                   ,ISNULL(glije_line_no, '''')
                                   ,ISNULL(glije_date, CONVERT(INT,REPLACE(CONVERT(DATE,GETDATE()),''-'','''')))
                                   ,ISNULL(glije_time, ''0'') 
                                   ,ISNULL(glije_ref, '''') 
                                   ,ISNULL(glije_doc, '''') 
                                   ,ISNULL(glije_comments, '''') 
                                   ,ISNULL(glije_dr_cr_ind, '''')
                                   ,ISNULL(glije_amt, ''0'') 
                                   ,ISNULL(glije_units, ''0'')
                                   ,ISNULL(glije_correcting, '''')
                                   ,ISNULL(glije_source_pgm, '''')
                                   ,ISNULL(glije_work_area, '''') 
                                   ,ISNULL(glije_cbk_no, '''') 
                                   ,ISNULL(glije_user_id, '''')
                                   ,ISNULL(glije_user_rev_dt, ''0'')
                                   ,ISNULL(A4GLIdentity, ''0'') 
                                   ,@uid
                              FROM glijemst where glije_period between @startingPeriod and @endingPeriod
	
    DELETE FROM glijemst WHERE glije_period between @startingPeriod and @endingPeriod
    
    -- CONVERTS glije_date to DATETIME for easy COMPARISON later
    UPDATE tblGLIjemst 
    SET glije_dte = CONVERT(DATETIME, SUBSTRING (CONVERT(VARCHAR(10),glije_date),1,4) + ''/'' + SUBSTRING (CONVERT(VARCHAR(10),glije_date),5,2) + ''/'' + SUBSTRING (CONVERT(VARCHAR(10),glije_date),7,2))
    WHERE glije_uid=@uid
    
    --DEFAULTS THE POST DATE TO glije_date
    UPDATE tblGLIjemst SET glije_postdate = glije_dte WHERE glije_uid=@uid
    
    DECLARE @id INT, @dte DATETIME, @glije_period INT,@intFiscalYearId INT,@glije_acct_no DECIMAL
    
    
    DECLARE @year NVARCHAR(4) ,@period NVARCHAR(4),@intFiscalPeriodId INT,@dateStart DATETIME, @dateEnd DATETIME ,@ysnStatus BIT
    
    --VALIDATES EVERY ROW AND SAVES THE ERROR IN tblGLIjemst glije_error_desc COLUMN FOR later use
    --DETERMINES THE glije_postdate VALUE . IF glije_date is not within the period then glije_postdate value is enddate
    DECLARE cursor_tbl CURSOR FOR SELECT glije_id,glije_dte,glije_period,glije_acct_no FROM tblGLIjemst WHERE glije_uid = @uid
    OPEN cursor_tbl
    FETCH NEXT FROM cursor_tbl INTO @id, @dte,@glije_period,@glije_acct_no
    WHILE @@FETCH_STATUS = 0
    BEGIN
		
		
		SELECT @year = SUBSTRING(CONVERT(NVARCHAR(10), @glije_period),1,4), @period = SUBSTRING(CONVERT(NVARCHAR(10), @glije_period),5,2)
		SELECT TOP 1 @intFiscalYearId= intFiscalYearId,@ysnStatus = ysnStatus FROM tblGLFiscalYear WHERE strFiscalYear = @year
		--NO FISCAL YEAR MATCHED IN IRELY
		IF @ysnStatus IS NULL
				UPDATE tblGLIjemst set glije_error_desc = ''Unable to Post because origin fiscal year is not in the scope of iRely fiscal year'' WHERE glije_id=@id
		ELSE
		
		IF @ysnStatus = 1
		BEGIN
			SELECT @intFiscalPeriodId = dbo.fnGeti21FiscalPeriodIdFromOriginPeriod(@intFiscalYearId,@period)
			
			IF @intFiscalPeriodId IS NOT NULL
				BEGIN
					
					SELECT @dateStart = dtmStartDate, @dateEnd = dtmEndDate, @ysnStatus = ysnOpen from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intFiscalPeriodId	
					IF @ysnStatus = 1
						BEGIN
						-- CHANGES THE POST DATE TO PERIOD ENDDATE IF THE glije_date IS NOT WITHIN THE FISCAL PERIOD
							IF  @dte < @dateStart OR @dte > @dateEnd
								UPDATE tblGLIjemst SET glije_postdate = @dateEnd  WHERE glije_id=@id
						END
					ELSE
						UPDATE tblGLIjemst set glije_error_desc = ''Unable to Post because iRely fiscal period is closed.'' WHERE glije_id=@id
				END
			-- NO MATCHED PERIOD WITHIN THE FISCAL YEAR
			ELSE
				UPDATE tblGLIjemst set glije_error_desc = ''Unable to Post because origin fiscal year is not in the scope of iRely fiscal year.'' WHERE glije_id=@id
		END
		-- FISCAL YEAR IS NOT OPEN
		ELSE 
			UPDATE tblGLIjemst set glije_error_desc = ''Unable to Post because iRely fiscal year is closed.'' WHERE glije_id=@id
		Cont:
		FETCH NEXT FROM cursor_tbl INTO @id, @dte,@glije_period,@glije_acct_no
    END
    CLOSE cursor_tbl
    DEALLOCATE cursor_tbl
    
    DECLARE @postdate DATE,@intJournalId INT,@strJournalId VARCHAR(10),
			@glije_date VARCHAR(20),@intAccountId INT,@intAccountId1 INT, @strDescription VARCHAR(50),@strDescription1 VARCHAR(50),@dtmDate DATE,
			@glije_amt DECIMAL ,@glije_units DECIMAL,@glije_dr_cr_ind CHAR(1),@glije_correcting CHAR(1),@debit DECIMAL,@credit DECIMAL,@creditUnit DECIMAL,
			@debitUnit DECIMAL,@debitUnitInLBS DECIMAL,@creditUnitInLBS DECIMAL,@totalDebit DECIMAL,@totalCredit DECIMAL,@glije_error_desc VARCHAR(100),
			@glije_src_sys CHAR(3),@glije_src_no CHAR(5),@isValid BIT
	
	-- INSERTS INTO THE tblGLJournal GROUPED BY glije_postdate COLUMN in tblGLIjemst
    DECLARE cursor_postdate CURSOR FOR  SELECT glije_postdate FROM tblGLIjemst WHERE glije_uid =@uid GROUP BY glije_postdate
    OPEN cursor_postdate
    FETCH NEXT FROM cursor_postdate INTO @postdate
    WHILE @@FETCH_STATUS =0
    BEGIN
		
		EXEC  dbo.uspGLGetNewID 2, @strJournalId  OUTPUT
		
		INSERT INTO tblGLJournal(strJournalId,dtmDate,strDescription,dtmPosted,intCurrencyId,intEntityId,strJournalType,strTransactionType,ysnPosted)
		SELECT @strJournalId,@postdate, ''Imported from SubLedger'' ,GETDATE(), @intCurrencyId,@intUserId, ''Origin Journal'',''General Journal'',0
		
	 
		SELECT @intJournalId = @@IDENTITY
		select @totalCredit =0, @totalDebit = 0,@isValid =1
		
		--INSERTS INTO THE tblGLJournalDetail then logs all the error to tblGLCOAImportLog INCLUDING THE ERROR COLLECTED ABOVE
		--TALLY THE DEBIT /CREDIT
		DECLARE cursor_gldetail CURSOR FOR SELECT glije_id,glije_acct_no,CONVERT(VARCHAR(20),glije_date),
		glije_amt,glije_units,UPPER(glije_dr_cr_ind),UPPER(glije_correcting),glije_error_desc,glije_period,glije_src_sys,glije_src_no
		 FROM tblGLIjemst WHERE glije_uid=@uid AND glije_postdate = @postdate
		OPEN cursor_gldetail
		FETCH NEXT FROM cursor_gldetail INTO @id,@glije_acct_no,@glije_date,@glije_amt,@glije_units,@glije_dr_cr_ind,
		@glije_correcting,@glije_error_desc,@glije_period,@glije_src_sys,@glije_src_no
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @debit = 0,@credit = 0,@debitUnit = 0,@creditUnit = 0, @creditUnitInLBS = 0 , @debitUnitInLBS = 0
			IF NOT EXISTS (SELECT * FROM tblGLCOACrossReference WHERE REPLACE(CONVERT(VARCHAR(50),@glije_acct_no),''.'','''') = REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(strExternalId,'' '',''''),''-'',''''),''.'',''''),''_'',''''),'','',''''),'';'',''''),''+'',''''),''/'',''''),''|'',''''))
			BEGIN
				IF @importLogId = 0
					EXEC uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId, @version,@importLogId OUTPUT
				EXEC uspGLCreateImportLogDetail @importLogId,''Unable to Post because account id in origin is not on iRely Suite Crossreference.'',
				@postdate,@strJournalId,@glije_period,@glije_src_sys,@glije_src_no
				SET @isValid = 0	
			END
			
			SELECT @intAccountId= b.intAccountId, @strDescription=b.strDescription FROM tblGLCOACrossReference a 
			JOIN tblGLAccount b ON a.inti21Id = b.intAccountId WHERE a.strExternalId = @glije_acct_no
			IF @intAccountId IS NULL
				SELECT @strDescription1 =REPLACE(@glije_acct_no,''.'',''''),@intAccountId1 = NULL
			ELSE
				SELECT @strDescription1 = @strDescription,@intAccountId1 =@intAccountId
			
			
			SELECT @dtmDate =CONVERT(DATE, SUBSTRING(@glije_date,1,4) + ''/'' + SUBSTRING(@glije_date,5,2) + ''/'' + SUBSTRING(@glije_date,7,2))
			IF @glije_correcting = ''Y'' 
			BEGIN
				SELECT @glije_amt *= -1
				IF 	@glije_dr_cr_ind = ''D'' SELECT @glije_dr_cr_ind =''C'' ELSE SELECT @glije_dr_cr_ind =''C''
			END
			IF @glije_amt < 0
			BEGIN
				SELECT @glije_amt *= -1
				IF 	@glije_dr_cr_ind = ''D'' SELECT @glije_dr_cr_ind =''C'' ELSE SELECT @glije_dr_cr_ind =''C''
			END
			IF @glije_amt >= 0
				IF @glije_dr_cr_ind = ''D'' SELECT @debit += @glije_amt ELSE SELECT @credit += @glije_amt
			
			IF @glije_units < 0
			BEGIN
				SELECT @glije_units *= -1
				SELECT @debitUnit +=@glije_units,@debitUnitInLBS += @glije_units,@creditUnit = 0,@creditUnitInLBS = 0
			END
			ELSE
			BEGIN
				SELECT @creditUnit +=@glije_units,@creditUnitInLBS += @glije_units,@debitUnit = 0,@debitUnitInLBS = 0
			END
				
			SELECT @totalCredit += @credit, @totalDebit +=@debit
			
			INSERT INTO tblGLJournalDetail (intAccountId,strDescription,dtmDate,intJournalId,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,
			dblDebitUnitsInLBS,dblUnitsInLBS,strComments,strReference,strCheckBookNo,strCorrecting,strSourcePgm,strWorkArea,intLineNo)
			SELECT @intAccountId1,@strDescription1,@dtmDate,@intJournalId,@debit,@credit,@debitUnit,@creditUnit,
			@debitUnitInLBS,@creditUnitInLBS,glije_comments,glije_ref,glije_cbk_no,glije_correcting,glije_source_pgm,glije_work_area,glije_line_no
			 FROM tblGLIjemst WHERE glije_id=@id
			 
			IF @glije_error_desc IS NOT NULL
			BEGIN
				IF @importLogId = 0
					EXEC uspGLCreateImportLogHeader ''Failed Transaction'',@intUserId, @version, @importLogId OUTPUT
				EXEC uspGLCreateImportLogDetail @importLogId,@glije_error_desc,@postdate,@strJournalId,@glije_period,@glije_src_sys,@glije_src_no
				
				SET @isValid = 0
			END
				
			
			
			
			
			FETCH NEXT FROM cursor_gldetail INTO @id,@glije_acct_no,@glije_date,@glije_amt,@glije_units,@glije_dr_cr_ind,@glije_correcting,
			@glije_error_desc,@glije_period,@glije_src_sys,@glije_src_no
		END
		CLOSE cursor_gldetail
		DEALLOCATE cursor_gldetail
		
		
		IF @totalCredit <> @totalDebit
		BEGIN
			IF @importLogId = 0
				EXEC  dbo.uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId, @version,@importLogId OUTPUT
			EXEC dbo.uspGLCreateImportLogDetail @importLogId,''Unable to Post because transaction is out of balance.'', @postdate,@strJournalId,@glije_period
			SET @isValid = 0
		END	
		IF @isCOAPresent = 0 SET @isValid = 0
		IF @isValid = 1
		BEGIN
		
			DECLARE @RC int
			DECLARE @Param nvarchar(max) =''SELECT intJournalId FROM tblGLJournal WHERE intJournalId = '' + CONVERT (VARCHAR(10), @intJournalId)
			DECLARE @strBatchId nvarchar(100)
			
			DECLARE @successfulCount int
			EXEC dbo.uspGLGetNewID 3, @strBatchId OUTPUT
			-- TODO: Set parameter values here.

			EXECUTE [dbo].[uspGLPostJournal] @Param,1,0,@strBatchId,''Origin Journal'',@intUserId,@successfulCount OUTPUT
			
			
			IF @successfulCount > 0
			BEGIN
				UPDATE tblGLJournal SET strJournalType = ''Origin Journal'',strRecurringStatus = ''Locked'' , ysnPosted = 1 WHERE intJournalId = @intJournalId
				IF @importLogId = 0
					EXEC dbo.uspGLCreateImportLogHeader ''Successful Transaction'', @intUserId,@version ,@importLogId OUTPUT
				EXEC dbo.uspGLCreateImportLogDetail @importLogId,''Posted'',@postdate,@strJournalId,@glije_period
				
				UPDATE tblGLCOAImportLog SET strEvent = ''Successful Transaction'' WHERE intImportLogId = @importLogId
			END
			ELSE
			BEGIN
				IF @importLogId = 0
					EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId,@version ,@importLogId OUTPUT
				EXEC dbo.uspGLCreateImportLogDetail @importLogId,@strBatchId,@postdate,@strJournalId,@glije_period
				
				UPDATE tblGLCOAImportLog SET strEvent = ''Failed Transaction'' WHERE intImportLogId = @importLogId
			END

		END			
		ELSE
			BEGIN
				IF @importLogId = 0
					EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'',@intUserId,@version ,@importLogId OUTPUT
				UPDATE tblGLCOAImportLog SET strEvent = ''Failed Transaction'' WHERE intImportLogId = @importLogId
			END
			
		
		 
		FETCH NEXT FROM cursor_postdate INTO @postdate
    END
	CLOSE cursor_postdate
	DEALLOCATE cursor_postdate
	
	COMMIT TRANSACTION
	
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		IF @importLogId = 0
				EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId,@version,@importLogId OUTPUT
			DECLARE @errorMsg VARCHAR(MAX)
			SELECT @errorMsg = ERROR_MESSAGE()
			UPDATE tblGLCOAImportLog SET strEvent = @errorMsg WHERE intImportLogId = @importLogId
			
		
	END CATCH
	
	
END
')

