GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glijemst]') AND type IN (N'U'))
BEGIN 

EXEC('IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLImportSubLedger'' and type = ''P'')
			DROP PROCEDURE [dbo].[uspGLImportSubLedger];')

EXEC('CREATE PROCEDURE [dbo].[uspGLImportSubLedger]
    	( @startingPeriod INT,@endingPeriod INT,@intCurrencyId INT, @intUserId INT, @version VARCHAR(20),@importLogId INT OUTPUT)
    	AS
    	BEGIN
    	SET NOCOUNT ON;
    	DECLARE @isCOAPresent BIT, @halt BIT  = 0
    	SELECT @isCOAPresent = 1,@importLogId = 0
    	IF NOT EXISTS (SELECT * FROM glijemst WHERE glije_period between @startingPeriod and @endingPeriod)
    	BEGIN
    		IF @importLogId = 0
    			EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'',@intUserId,@version ,@importLogId OUTPUT
			EXEC dbo.[uspGLCreateImportLogDetail]	@importLogId , ''No Data to import from the Origin on a given period.'' ,null ,null
			SET @halt = 1
    	END

		IF EXISTS(SELECT TOP 1 1 FROM vyuAPOriginCCDTransaction) -- AP-3144 check for non-imported Credit Card Reconciliation records
		BEGIN
			IF @importLogId = 0
    			EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'',@intUserId,@version ,@importLogId OUTPUT
			EXEC dbo.[uspGLCreateImportLogDetail]	@importLogId ,  ''Unable to Post because there is no cross reference between i21 and Origin.'' ,null ,null
			SET @halt = 1
		END

		IF @halt = 1 RETURN
		
    	IF NOT EXISTS( SELECT * FROM tblGLCOACrossReference)
    	BEGIN
    		IF @importLogId = 0
    			EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'',@intUserId,@version ,@importLogId OUTPUT
    		UPDATE tblGLCOAImportLog SET strEvent = ''Unable to Post because there is no cross reference between i21 and Origin.'' WHERE intImportLogId = @importLogId
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

			INSERT INTO  @tmpID (ID,glije_date,glije_acct_no,glije_period,glije_src_no)
    			SELECT A4GLIdentity,glije_date,glije_acct_no,glije_period,glije_src_no FROM glijemst 
				WITH (HOLDLOCK)
    			WHERE glije_period between @startingPeriod and @endingPeriod
    			

    		IF EXISTS (SELECT * FROM @tmpID WHERE glije_date = 0)
    		BEGIN
    			EXEC  dbo.uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId, @version,@importLogId OUTPUT
    			BEGIN
    			
    				INSERT INTO tblGLCOAImportLogDetail ([intImportLogId]
						  ,[strEventDescription]
						  ,[strPeriod]
						  ,[strSourceNumber]
						  ,[strSourceSystem]
						  ,[strFiscalYear]
						  ,[strFiscalYearPeriod]
						  ,[strExternalId]
						  ,[strLineNumber]
						  ,[strTransactionDate]
						  ,[strTransactionTime]
						  ,[strReference]
						  ,[strDocument]
						  ,[strComments]
						  ,[strDebitCredit]
						  ,[decAmount]
						  ,[decUnits]
						  ,[blnCorrection])
					SELECT @importLogId,
						''Invalid Date (glije_date) in Origin Table'',
						A.glije_period,
						A.glije_src_no,
						A.glije_src_sys,
						SUBSTRING(CAST(A.glije_period AS NCHAR(10)),1,4),
						SUBSTRING(CAST(A.glije_period AS NCHAR(10)),5,2),
						A.glije_acct_no,
						A.glije_line_no,
						A.glije_date,
   					    STUFF( STUFF(A.glije_time,3,0,'':''),6,0,'':'') ,
						A.glije_ref,
						A.glije_doc,
						A.glije_comments,
						A.glije_dr_cr_ind,
						A.glije_amt,
						A.glije_units,
						CASE WHEN UPPER(RTRIM(A.glije_correcting)) = ''Y'' THEN 1 ELSE 0 END
						FROM glijemst A JOIN @tmpID B 
    					ON A.A4GLIdentity = B.ID
    					WHERE B.glije_date = 0
    			END
    			RETURN
    		END

    		BEGIN TRY
    		BEGIN TRANSACTION
    		DECLARE @uid UNIQUEIDENTIFIER
    		SELECT @uid =NEWID()
    		

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
    				   ,@uid FROM glijemst a JOIN @tmpID b on a.A4GLIdentity = b.ID

    		DELETE a FROM glijemst a  JOIN @tmpID b on a.A4GLIdentity = b.ID 

    		DELETE FROM  @tmpID
    		-- CONVERTS glije_date to DATETIME for easy COMPARISON later

    		UPDATE tblGLIjemst
    		SET glije_dte = CONVERT(DATETIME, SUBSTRING (CONVERT(VARCHAR(10),glije_date),1,4) + ''/'' + SUBSTRING (CONVERT(VARCHAR(10),glije_date),5,2) + ''/'' + SUBSTRING (CONVERT(VARCHAR(10),glije_date),7,2))
    		WHERE glije_uid=@uid

    		--DEFAULTS THE POST DATE TO glije_date
			UPDATE tblGLIjemst SET glije_postdate = glije_dte WHERE glije_uid=@uid

    		DECLARE @id INT, @dte DATETIME, @glije_period INT,@intFiscalYearId INT,@glije_acct_no DECIMAL(16,8)
    		DECLARE @year NVARCHAR(4) ,@period NVARCHAR(4),@intFiscalPeriodId INT,@dateStart DATETIME, @dateEnd DATETIME ,@ysnStatus BIT

    		--DETERMINES THE glije_postdate VALUE . IF glije_date is not within the period then glije_postdate value is enddate
    		DECLARE cursor_tbl CURSOR FOR SELECT glije_dte,glije_period FROM tblGLIjemst WHERE glije_uid = @uid GROUP BY glije_period,glije_dte
    		OPEN cursor_tbl
    		FETCH NEXT FROM cursor_tbl INTO @dte,@glije_period
    		WHILE @@FETCH_STATUS = 0
    		BEGIN


				SELECT @year = SUBSTRING(CONVERT(NVARCHAR(10), @glije_period),1,4), @period = SUBSTRING(CONVERT(NVARCHAR(10), @glije_period),5,2)
    				SELECT TOP 1 @intFiscalYearId= intFiscalYearId,@ysnStatus = ysnStatus FROM tblGLFiscalYear WHERE strFiscalYear = @year
    		
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
    						END
    			FETCH NEXT FROM cursor_tbl INTO @dte,@glije_period
    		END
    		CLOSE cursor_tbl
    		DEALLOCATE cursor_tbl

    		DECLARE @postdate DATE,@intJournalId INT,@strJournalId VARCHAR(10),
    				@glije_date VARCHAR(20),@intAccountId INT, @strDescription VARCHAR(50),@headerDescription VARCHAR(50),@dtmDate DATE,
    				@glije_amt DECIMAL(12,2) ,@glije_units DECIMAL(16,4),@glije_dr_cr_ind CHAR(1),@glije_correcting CHAR(1),@debit DECIMAL(12,2),@credit DECIMAL(12,2),
    				@creditUnit DECIMAL(12,2),@debitUnit DECIMAL(12,2),@debitUnitInLBS DECIMAL(12,2),@creditUnitInLBS DECIMAL(12,2),
					--@totalDebit DECIMAL(18,2),
					--@totalCredit DECIMAL(18,2),
    				@glije_error_desc VARCHAR(100),@glije_src_sys CHAR(3),@glije_src_no CHAR(5),@isValid BIT,@journalCount INT = 0,
					@intCompanyId INT
			SELECT TOP 1 @intCompanyId = intCompanySetupID FROM tblSMCompanySetup

    		-- INSERTS INTO THE tblGLJournal GROUPED BY glije_postdate COLUMN in tblGLIjemst
    		DECLARE cursor_postdate CURSOR LOCAL FOR  SELECT glije_postdate,glije_src_sys,glije_src_no FROM tblGLIjemst WHERE glije_uid =@uid
    			GROUP BY glije_postdate,glije_src_sys,glije_src_no
    		OPEN cursor_postdate
    		FETCH NEXT FROM cursor_postdate INTO @postdate,@glije_src_sys,@glije_src_no
    		WHILE @@FETCH_STATUS =0
    		BEGIN

    			EXEC  dbo.uspGLGetNewID 2, @strJournalId  OUTPUT
				SET @headerDescription = ''Imported from '' + REPLACE(@glije_src_sys,'' '','''') +  '' '' + REPLACE(@glije_src_no,'' '' ,'''') + '' on '' + CONVERT (varchar(10), GETDATE(), 101) 
				INSERT INTO tblGLJournal(intCompanyId, strJournalId,dtmDate,strDescription,dtmPosted,intCurrencyId,intEntityId,strJournalType,strTransactionType,ysnPosted,
    			strSourceId, strSourceType)
    			SELECT @intCompanyId, @strJournalId,@postdate
    				,@headerDescription
    				,GETDATE(), @intCurrencyId,@intUserId, ''Origin Journal'',''General Journal'',0,@glije_src_no,@glije_src_sys

    			SELECT @intJournalId = @@IDENTITY
    			SET @journalCount = @journalCount +1
    			--select @totalCredit =0, @totalDebit = 0,
				SET @isValid =1

    			DECLARE cursor_gldetail CURSOR LOCAL FOR SELECT glije_id,glije_acct_no,CONVERT(VARCHAR(20),glije_date),
    			glije_amt,glije_units,UPPER(glije_dr_cr_ind),UPPER(glije_correcting),glije_error_desc,glije_period
    			 FROM tblGLIjemst WHERE glije_uid=@uid AND glije_postdate = @postdate and glije_src_sys = @glije_src_sys and glije_src_no= @glije_src_no
    			OPEN cursor_gldetail
    			FETCH NEXT FROM cursor_gldetail INTO @id,@glije_acct_no,@glije_date,@glije_amt,@glije_units,@glije_dr_cr_ind,
    			@glije_correcting,@glije_error_desc,@glije_period
    			WHILE @@FETCH_STATUS = 0
    			BEGIN
    				SELECT @debit = 0,@credit = 0,@debitUnit = 0,@creditUnit = 0, @creditUnitInLBS = 0 , @debitUnitInLBS = 0, @intAccountId = NULL
    				IF NOT EXISTS (
    					SELECT * FROM tblGLCOACrossReference WHERE @glije_acct_no = strExternalId)
    				BEGIN
    					IF @importLogId = 0
    						EXEC uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId, @version,@importLogId OUTPUT
    				INSERT INTO tblGLCOAImportLogDetail ([intImportLogId]
						  ,[strEventDescription]
						  ,[strPeriod]
						  ,[strSourceNumber]
						  ,[strSourceSystem]
						  ,[strFiscalYear]
						  ,[strFiscalYearPeriod]
						  ,[strExternalId]
						  ,[strLineNumber]
						  ,[strTransactionDate]
						  ,[strTransactionTime]
						  ,[strReference]
						  ,[strDocument]
						  ,[strComments]
						  ,[strDebitCredit]
						  ,[decAmount]
						  ,[decUnits]
						  ,[strJournalId]
						  ,[blnCorrection])
					SELECT @importLogId,
						''Unable to Post because Origin account id :'' + CAST ( glije_acct_no AS nvarchar (max)) + ''  ''+ '' is not in i21 Cross Reference table. '' + ''Please check GL Account Detail | Chart Of Accounts - External Id column to verify if the account exists.'',
						glije_period,
						glije_src_no,
						glije_src_sys,
						SUBSTRING(CAST(glije_period AS NCHAR(10)),1,4),
						SUBSTRING(CAST(glije_period AS NCHAR(10)),5,2),
						glije_acct_no,
						glije_line_no,
						glije_date,
						STUFF( STUFF(glije_time,3,0,'':''),6,0,'':'') ,
						glije_ref,
						glije_doc,
						glije_comments,
						glije_dr_cr_ind,
						glije_amt,
						glije_units,
						@strJournalId,
						CASE WHEN UPPER(RTRIM(glije_correcting)) = ''Y'' THEN 1 ELSE 0 END
						FROM tblGLIjemst 
    					WHERE glije_id = @id

    					SET @isValid = 0
    				END
    				SELECT @intAccountId= b.intAccountId FROM tblGLCOACrossReference a
    				JOIN tblGLAccount b ON a.inti21Id = b.intAccountId WHERE a.strExternalId = @glije_acct_no
					

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
    				
    				IF @glije_dr_cr_ind = ''D'' SELECT @debit += @glije_amt ELSE SELECT @credit += @glije_amt

					IF @glije_units < 0 SELECT @glije_units *= -1

    				IF @glije_dr_cr_ind = ''D''
    					SELECT @debitUnit +=@glije_units,@debitUnitInLBS += @glije_units,@creditUnit = 0,@creditUnitInLBS = 0
    				ELSE
    				    SELECT @creditUnit +=@glije_units,@creditUnitInLBS += @glije_units,@debitUnit = 0,@debitUnitInLBS = 0

    				--SELECT @totalCredit += @credit, @totalDebit +=@debit

    				INSERT INTO tblGLJournalDetail (intCompanyId, intAccountId,strDescription,dtmDate,intJournalId,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,dblDebitRate, dblCreditRate,
    				dblDebitUnitsInLBS,dblUnitsInLBS,strComments,strReference,strCheckBookNo,strCorrecting,strSourcePgm,strWorkArea,intLineNo,strDocument, strSourceKey)
    				SELECT @intCompanyId, @intAccountId,@headerDescription,@dtmDate,@intJournalId,ROUND(@debit,2),ROUND(@credit,2),@debitUnit,@creditUnit,1,1,
    				@debitUnitInLBS,@creditUnitInLBS,glije_comments,glije_ref,glije_cbk_no,glije_correcting,glije_source_pgm,glije_work_area,glije_line_no,glije_doc, A4GLIdentity
    				 FROM tblGLIjemst WHERE glije_id=@id

    				FETCH NEXT FROM cursor_gldetail INTO @id,@glije_acct_no,@glije_date,@glije_amt,@glije_units,@glije_dr_cr_ind,@glije_correcting,
    				@glije_error_desc,@glije_period
    			END
    			CLOSE cursor_gldetail
    			DEALLOCATE cursor_gldetail
    			IF @isCOAPresent = 0 SET @isValid = 0
    			IF @isValid = 1
    			BEGIN

    				DECLARE @RC int
    				DECLARE @Param nvarchar(max) =''SELECT intJournalId FROM tblGLJournal WHERE intJournalId = '' + CONVERT (VARCHAR(10), @intJournalId)
    				DECLARE @strBatchId nvarchar(100)
					DECLARE @successfulCount int
    				EXEC dbo.uspGLGetNewID 3, @strBatchId OUTPUT

    				EXECUTE [dbo].[uspGLPostJournal] @Param,1,0,@strBatchId,''Origin Journal'',@intUserId,1, @successfulCount OUTPUT

    				IF @successfulCount = @journalCount
    				BEGIN
    					UPDATE tblGLJournal SET strJournalType = ''Origin Journal'',strRecurringStatus = ''Locked'' , ysnPosted = 1 WHERE intJournalId = @intJournalId
    					IF @importLogId = 0
    						EXEC dbo.uspGLCreateImportLogHeader ''Successful Transaction'', @intUserId,@version ,@importLogId OUTPUT
    					INSERT INTO tblGLCOAImportLogDetail(strEventDescription,intImportLogId,dtePostDate,strPeriod,strSourceSystem,strSourceNumber,strJournalId,strFiscalYear,strFiscalYearPeriod)
    					SELECT strDescription,@importLogId,@postdate,@glije_period,@glije_src_sys,@glije_src_no,strTransactionId,SUBSTRING(CAST(@glije_period AS NCHAR(10)),1,4),SUBSTRING(CAST(@glije_period AS NCHAR(10)),5,2) from tblGLPostResult
    					WHERE strBatchId = @strBatchId and intEntityId = @intUserId
    					UPDATE tblGLCOAImportLog SET strEvent = ''Successful Transaction'' WHERE intImportLogId = @importLogId
    				END
    				ELSE
    				BEGIN
    					IF @importLogId = 0
    						EXEC dbo.uspGLCreateImportLogHeader ''Failed Transaction'', @intUserId,@version ,@importLogId OUTPUT
						INSERT INTO tblGLCOAImportLogDetail(strEventDescription,intImportLogId,dtePostDate,strPeriod,strSourceSystem,strSourceNumber,strJournalId,strFiscalYear,strFiscalYearPeriod)
    					SELECT strDescription,@importLogId,@postdate,@glije_period,@glije_src_sys,@glije_src_no,strTransactionId,SUBSTRING(CAST(@glije_period AS NCHAR(10)),1,4),SUBSTRING(CAST(@glije_period AS NCHAR(10)),5,2) from tblGLPostResult
    					WHERE strBatchId = @strBatchId and intEntityId = @intUserId
    					UPDATE tblGLCOAImportLog SET strEvent = ''Failed Transaction'' WHERE intImportLogId = @importLogId
    				END

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