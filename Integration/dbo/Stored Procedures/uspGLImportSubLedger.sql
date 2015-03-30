﻿GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glijemst]') AND type IN (N'U'))
BEGIN 

	EXEC('
		IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLImportSubLedger'' and type = ''P'')
			DROP PROCEDURE [dbo].[uspGLImportSubLedger];
	')

EXEC('CREATE PROCEDURE [dbo].[uspGLImportSubLedger]
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
    	ELSE
    	BEGIN
    		IF EXISTS(SELECT * FROM tblGLCOACrossReference WHERE stri21IdNumber IS NULL)
    			UPDATE tblGLCOACrossReference SET stri21IdNumber =
    				REPLACE(REPLACE (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(strExternalId,'' '',''''),''-'',''''),''.'',''''),''_'',''''),'','',''''),'';'',''''),''+'',''''),''/'',''''),''|'','''')
    				WHERE stri21IdNumber is NULL
    	END

    	DECLARE @tmpID TABLE(
    			ID int,
    			glije_date int,
    			glije_acct_no decimal(16,8),
    			glije_period int,
    			glije_src_no char(5)
    		)



    		IF EXISTS (SELECT * FROM @tmpID WHERE glije_date = 0)
    		BEGIN
    			EXEC  dbo.uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId, @version,@importLogId OUTPUT
    			DECLARE @a int,@b decimal(16,8),@c char(5),@d int
    			WHILE EXISTS (SELECT * FROM @tmpID WHERE glije_date = 0)
    			BEGIN
    				SELECT TOP 1 @a = ID, @b= glije_acct_no,@c = glije_src_no,@d=glije_period FROM @tmpID WHERE glije_date = 0  ORDER BY ID
    				INSERT INTO tblGLCOAImportLogDetail (strEventDescription,strPeriod,strSourceNumber,strJournalId,intImportLogId)
    					VALUES(''Invalid Date (glije_date) in Origin Table'',@d,@c,@b,@importLogId)
    				DELETE FROM @tmpID where ID = @a
    			END
    			RETURN
    		END

    		BEGIN TRY
    		BEGIN TRANSACTION
    		DECLARE @uid UNIQUEIDENTIFIER
    		SELECT @uid =NEWID()
    		INSERT INTO  @tmpID (ID,glije_date,glije_acct_no,glije_period,glije_src_no)
    			SELECT A4GLIdentity,glije_date,glije_acct_no,glije_period,glije_src_no FROM glijemst WITH (HOLDLOCK)
    			WHERE glije_period between @startingPeriod and @endingPeriod

			INSERT INTO tblGLIjemst(glije_period,glije_acct_no,glije_src_sys,glije_src_no, glije_line_no,glije_date,glije_time,glije_ref,glije_doc,glije_comments,
    		glije_dr_cr_ind,glije_amt,glije_units,glije_correcting,glije_source_pgm,glije_work_area,glije_cbk_no,glije_user_id,glije_user_rev_dt,A4GLIdentity,glije_uid)
    		SELECT ISNULL(a.glije_period, ''0'')
    				   ,ISNULL(a.glije_acct_no, ''0'')
    				   ,ISNULL(glije_src_sys, '''')
    				   ,ISNULL(a.glije_src_no, '''')
    				   ,ISNULL(glije_line_no, '''')
    				   ,ISNULL(a.glije_date, CONVERT(INT,REPLACE(CONVERT(DATE,GETDATE()),''-'','''')))
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
    								  FROM glijemst a JOIN
    								  @tmpID b on a.A4GLIdentity = b.ID
    								   --where glije_period between @startingPeriod and @endingPeriod

    		DELETE a FROM glijemst a  JOIN @tmpID b on a.A4GLIdentity = b.ID --  WHERE glije_period between @startingPeriod and @endingPeriod

    		DELETE FROM  @tmpID
    		-- CONVERTS glije_date to DATETIME for easy COMPARISON later

    		UPDATE tblGLIjemst
    		SET glije_dte = CONVERT(DATETIME, SUBSTRING (CONVERT(VARCHAR(10),glije_date),1,4) + ''/'' + SUBSTRING (CONVERT(VARCHAR(10),glije_date),5,2) + ''/'' + SUBSTRING (CONVERT(VARCHAR(10),glije_date),7,2))
    		WHERE glije_uid=@uid

    		--DEFAULTS THE POST DATE TO glije_date
    		UPDATE tblGLIjemst SET glije_postdate = glije_dte WHERE glije_uid=@uid

    		DECLARE @id INT, @dte DATETIME, @glije_period INT,@intFiscalYearId INT,@glije_acct_no DECIMAL(16,8)
    		DECLARE @year NVARCHAR(4) ,@period NVARCHAR(4),@intFiscalPeriodId INT,@dateStart DATETIME, @dateEnd DATETIME ,@ysnStatus BIT

    		--VALIDATES EVERY ROW AND SAVES THE ERROR IN tblGLIjemst glije_error_desc COLUMN FOR later use
    		--DETERMINES THE glije_postdate VALUE . IF glije_date is not within the period then glije_postdate value is enddate
    		DECLARE cursor_tbl CURSOR FOR SELECT glije_dte,glije_period FROM tblGLIjemst WHERE glije_uid = @uid GROUP BY glije_period,glije_dte
    		OPEN cursor_tbl
    		FETCH NEXT FROM cursor_tbl INTO @dte,@glije_period
    		WHILE @@FETCH_STATUS = 0
    		BEGIN


    			SELECT @year = SUBSTRING(CONVERT(NVARCHAR(10), @glije_period),1,4), @period = SUBSTRING(CONVERT(NVARCHAR(10), @glije_period),5,2)
    			SELECT TOP 1 @intFiscalYearId= intFiscalYearId,@ysnStatus = ysnStatus FROM tblGLFiscalYear WHERE strFiscalYear = @year
    			--NO FISCAL YEAR MATCHED IN IRELY
    			IF @ysnStatus IS NULL
    					UPDATE tblGLIjemst set glije_error_desc = ''Unable to Post because origin fiscal year is not in the scope of iRely fiscal year'' WHERE glije_uid=@uid
    					and glije_period = @glije_period
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
    									UPDATE tblGLIjemst SET glije_postdate = @dateEnd  WHERE
    									glije_uid=@uid and glije_period = @period and glije_dte = @dte
    							END
    						ELSE
    							UPDATE tblGLIjemst set glije_error_desc = ''Unable to Post because iRely fiscal period is closed.'' WHERE
    							glije_uid=@uid and glije_period = @period and glije_dte = @dte
    					END
    				-- NO MATCHED PERIOD WITHIN THE FISCAL YEAR
    				ELSE
    					UPDATE tblGLIjemst set glije_error_desc = ''Unable to Post because origin fiscal year is not in the scope of iRely fiscal year.'' WHERE
    					glije_uid=@uid and glije_period = @period and glije_dte = @dte
    			END
    			-- FISCAL YEAR IS NOT OPEN
    			ELSE
    				UPDATE tblGLIjemst set glije_error_desc = ''Unable to Post because iRely fiscal year is closed.'' WHERE
    				glije_uid=@uid and glije_period = @period and glije_dte = @dte
    			Cont:
    			FETCH NEXT FROM cursor_tbl INTO @dte,@glije_period
    		END
    		CLOSE cursor_tbl
    		DEALLOCATE cursor_tbl

    		DECLARE @postdate DATE,@intJournalId INT,@strJournalId VARCHAR(10),
    				@glije_date VARCHAR(20),@intAccountId INT,@intAccountId1 INT, @strDescription VARCHAR(50),@strDescription1 VARCHAR(50),@dtmDate DATE,
    				@glije_amt DECIMAL(12,2) ,@glije_units DECIMAL(10,2),@glije_dr_cr_ind CHAR(1),@glije_correcting CHAR(1),@debit DECIMAL(12,2),@credit DECIMAL(12,2),
    				@creditUnit DECIMAL(12,2),@debitUnit DECIMAL(12,2),@debitUnitInLBS DECIMAL(12,2),@creditUnitInLBS DECIMAL(12,2),@totalDebit DECIMAL(18,2),@totalCredit DECIMAL(18,2),
    				@glije_error_desc VARCHAR(100),@glije_src_sys CHAR(3),@glije_src_no CHAR(5),@isValid BIT

    		-- INSERTS INTO THE tblGLJournal GROUPED BY glije_postdate COLUMN in tblGLIjemst
    		DECLARE cursor_postdate CURSOR LOCAL FOR  SELECT glije_postdate,glije_src_sys,glije_src_no FROM tblGLIjemst WHERE glije_uid =@uid
    			GROUP BY glije_postdate,glije_src_sys,glije_src_no
    		OPEN cursor_postdate
    		FETCH NEXT FROM cursor_postdate INTO @postdate,@glije_src_sys,@glije_src_no
    		WHILE @@FETCH_STATUS =0
    		BEGIN

    			EXEC  dbo.uspGLGetNewID 2, @strJournalId  OUTPUT

    			INSERT INTO tblGLJournal(strJournalId,dtmDate,strDescription,dtmPosted,intCurrencyId,intEntityId,strJournalType,strTransactionType,ysnPosted,
    			strSourceId, strSourceType)
    			SELECT @strJournalId,@postdate, ''Imported from SubLedger'' ,GETDATE(), @intCurrencyId,@intUserId, ''Origin Journal'',''General Journal'',0,
    				@glije_src_no,@glije_src_sys


    			SELECT @intJournalId = @@IDENTITY
    			select @totalCredit =0, @totalDebit = 0,@isValid =1

    			--INSERTS INTO THE tblGLJournalDetail then logs all the error to tblGLCOAImportLog INCLUDING THE ERROR COLLECTED ABOVE
    			----TALLY THE DEBIT /CREDIT
    			--SELECT glije_id,glije_acct_no,CONVERT(VARCHAR(20),glije_date),
    			--glije_amt,glije_units,UPPER(glije_dr_cr_ind),UPPER(glije_correcting),glije_error_desc,glije_period,glije_src_sys,glije_src_no
    			-- FROM tblGLIjemst WHERE glije_uid=@uid AND glije_postdate = @postdate and glije_src_sys = @glije_src_sys and glije_src_no= @glije_src_no


    			DECLARE cursor_gldetail CURSOR LOCAL FOR SELECT glije_id,glije_acct_no,CONVERT(VARCHAR(20),glije_date),
    			glije_amt,glije_units,UPPER(glije_dr_cr_ind),UPPER(glije_correcting),glije_error_desc,glije_period
    			 FROM tblGLIjemst WHERE glije_uid=@uid AND glije_postdate = @postdate and glije_src_sys = @glije_src_sys and glije_src_no= @glije_src_no
    			OPEN cursor_gldetail
    			FETCH NEXT FROM cursor_gldetail INTO @id,@glije_acct_no,@glije_date,@glije_amt,@glije_units,@glije_dr_cr_ind,
    			@glije_correcting,@glije_error_desc,@glije_period
    			WHILE @@FETCH_STATUS = 0
    			BEGIN

    				SELECT @debit = 0,@credit = 0,@debitUnit = 0,@creditUnit = 0, @creditUnitInLBS = 0 , @debitUnitInLBS = 0
    				IF NOT EXISTS (
    					SELECT * FROM tblGLCOACrossReference WHERE REPLACE(CONVERT(VARCHAR(50),@glije_acct_no),''.'','''') = stri21IdNumber)
    				BEGIN
    					IF @importLogId = 0
    						EXEC uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId, @version,@importLogId OUTPUT
    					EXEC uspGLCreateImportLogDetail @importLogId,''Unable to Post because account id in origin is not on iRely Suite Crossreference.'',
    					@postdate,@strJournalId,@glije_period,@glije_src_sys,@glije_src_no
    					SET @isValid = 0
    				END
    				SELECT @intAccountId = NULL
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
    					SELECT @glije_dr_cr_ind = CASE WHEN @glije_dr_cr_ind = ''D'' THEN ''C'' ELSE ''D'' END
    				END
    				IF @glije_amt < 0
    				BEGIN
    					SELECT @glije_amt *= -1
    					SELECT @glije_dr_cr_ind = CASE WHEN @glije_dr_cr_ind = ''D'' THEN ''C'' ELSE ''D'' END
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
    				dblDebitUnitsInLBS,dblUnitsInLBS,strComments,strReference,strCheckBookNo,strCorrecting,strSourcePgm,strWorkArea,intLineNo,strDocument)
    				SELECT @intAccountId1,@strDescription1,@dtmDate,@intJournalId,@debit,@credit,@debitUnit,@creditUnit,
    				@debitUnitInLBS,@creditUnitInLBS,glije_comments,glije_ref,glije_cbk_no,glije_correcting,glije_source_pgm,glije_work_area,glije_line_no,glije_doc
    				 FROM tblGLIjemst WHERE glije_id=@id

    				IF @glije_error_desc IS NOT NULL
    				BEGIN
    					IF @importLogId = 0
    						EXEC uspGLCreateImportLogHeader ''Failed Transaction'',@intUserId, @version, @importLogId OUTPUT
    					EXEC uspGLCreateImportLogDetail @importLogId,@glije_error_desc,@postdate,@strJournalId,@glije_period,@glije_src_sys,@glije_src_no

    					SET @isValid = 0
    				END

    				FETCH NEXT FROM cursor_gldetail INTO @id,@glije_acct_no,@glije_date,@glije_amt,@glije_units,@glije_dr_cr_ind,@glije_correcting,
    				@glije_error_desc,@glije_period
    			END
    			CLOSE cursor_gldetail
    			DEALLOCATE cursor_gldetail


    			IF @totalCredit <> @totalDebit
    			BEGIN
    				IF @importLogId = 0
    					EXEC  dbo.uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId, @version,@importLogId OUTPUT
    				--EXEC dbo.uspGLCreateImportLogDetail @importLogId,''Unable to Post because transaction is out of balance.'', @postdate,@strJournalId,@glije_period
    				EXEC uspGLCreateImportLogDetail @importLogId,''Unable to Post because transaction is out of balance.'',@postdate,@strJournalId,@glije_period,@glije_src_sys,@glije_src_no
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

    				EXECUTE [dbo].[uspGLPostJournal] @Param,1,0,@strBatchId,''Origin Journal'',@intUserId,@successfulCount OUTPUT

    				IF @successfulCount > 0
    				BEGIN
    					UPDATE tblGLJournal SET strJournalType = ''Origin Journal'',strRecurringStatus = ''Locked'' , ysnPosted = 1 WHERE intJournalId = @intJournalId
    					IF @importLogId = 0
    						EXEC dbo.uspGLCreateImportLogHeader ''Successful Transaction'', @intUserId,@version ,@importLogId OUTPUT
    					--EXEC dbo.uspGLCreateImportLogDetail @importLogId,''Posted'',@postdate,@strJournalId,@glije_period
						EXEC uspGLCreateImportLogDetail @importLogId,''Posted'',@postdate,@strJournalId,@glije_period,@glije_src_sys,@glije_src_no
    					UPDATE tblGLCOAImportLog SET strEvent = ''Successful Transaction'' WHERE intImportLogId = @importLogId
    				END
    				ELSE
    				BEGIN
    					IF @importLogId = 0
    						EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId,@version ,@importLogId OUTPUT
    					--EXEC dbo.uspGLCreateImportLogDetail @importLogId,@strBatchId,@postdate,@strJournalId,@glije_period
						EXEC uspGLCreateImportLogDetail @importLogId,@strBatchId,@postdate,@strJournalId,@glije_period,@glije_src_sys,@glije_src_no
    					UPDATE tblGLCOAImportLog SET strEvent = ''Failed Transaction'' WHERE intImportLogId = @importLogId
    				END

    			END
    			ELSE
    				BEGIN
    					IF @importLogId = 0
    						EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'',@intUserId,@version ,@importLogId OUTPUT
    					UPDATE tblGLCOAImportLog SET strEvent = ''Failed Transaction'' WHERE intImportLogId = @importLogId
    				END

    			FETCH NEXT FROM cursor_postdate INTO @postdate,@glije_src_sys,@glije_src_no
    			END
    			CLOSE cursor_postdate
				DEALLOCATE cursor_postdate

	    		COMMIT TRANSACTION
    		END TRY

    		BEGIN CATCH
    			ROLLBACK TRANSACTION
    				EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId,@version,@importLogId OUTPUT
    				DECLARE @errorMsg VARCHAR(MAX)
    				SELECT @errorMsg = ERROR_MESSAGE()
    				UPDATE tblGLCOAImportLog SET strEvent = @errorMsg WHERE intImportLogId = @importLogId
    		END CATCH
    	END')

END
