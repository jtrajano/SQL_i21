CREATE PROCEDURE [dbo].[uspSMMigrateRecurringTransaction]
AS
BEGIN
	/* ACCOUNTS PAYABLE */
	BEGIN TRY
		BEGIN TRANSACTION
		IF EXISTS ( SELECT  1
						FROM    INFORMATION_SCHEMA.TABLES
						WHERE   table_schema = 'dbo'
								AND TABLE_NAME = 'tblSMRecurringTransaction' )
		BEGIN
			DECLARE @COUNTSOURCE AS INT
			DECLARE @COUNTTARGET AS INT

			PRINT '------------------BEGIN tblSMRecurringTransaction------------------'

			SELECT @COUNTTARGET = COUNT(intRecurringId) FROM tblSMRecurringTransaction
			SELECT @COUNTSOURCE = COUNT(intRecurringId) FROM tblAPRecurringTransaction

			PRINT 'TARGET COUNT: ' + CAST(@COUNTTARGET AS VARCHAR(10)) + ', SOURCE COUNT: ' + CAST(@COUNTSOURCE AS VARCHAR(10))
	
			PRINT 'START INSERT >> - tblAPRecurringTransaction'
			INSERT INTO [dbo].[tblSMRecurringTransaction]
					 ([intTransactionId]
					 ,[strTransactionNumber]
					 ,[strTransactionType]
					 ,[strReference]
					 ,[strFrequency]
					 ,[dtmLastProcess]
					 ,[dtmNextProcess]
					 ,[ysnDue]
					 ,[strRecurringGroup]
					 ,[strDayOfMonth]
					 ,[dtmStartDate]
					 ,[dtmEndDate]
					 ,[ysnActive]
					 ,[intIteration]
					 ,[intUserId]           
					 ,[intConcurrencyId])
			 SELECT apRecur.intTransactionId
				  , apBill.strBillId strTransactionNumber
				  , CASE apRecur.intTransactionType
					  WHEN 1 THEN 'Bill'
					  WHEN 2 THEN 'Vendor Payment'
					  WHEN 3 THEN 'Debit Memo'
					  WHEN 4 THEN 'Payable'
					  WHEN 5 THEN 'Purchase Order'
					  WHEN 6 THEN 'Bill Template'
					  WHEN 7 THEN 'Bill Approval'
					END as strTransactionType
				  , isnull(apRecur.strReference, '') strReference
				  , case apRecur.intFrequencyId
					  WHEN 1 THEN 'Daily'
					  WHEN 2 THEN 'Weekly'
					  WHEN 3 THEN 'Bi-Weekly'
					  WHEN 4 THEN 'Semi-Monthly'
					  WHEN 5 THEN 'Monthly'
					  WHEN 6 THEN 'Bi-Monthly'
					  WHEN 7 THEN 'Quarterly'
					  WHEN 8 THEN 'Semi-Annual'
					  WHEN 9 THEN 'Annual'
					END strFrequencyId
				  , apRecur.dtmLastProcess
				  , apRecur.dtmNextProcess
				  , apRecur.ysnDue
				  , Null strRecurringGroup-- , apRecur.intGroupId -- ?
				  , CAST(apRecur.intDayofMonth AS VARCHAR) strDayofMonth
				  , apRecur.dtmStartDate
				  , apRecur.dtmEndDate
				  , apRecur.ysnActive
				  , apRecur.intIterations
				  , apRecur.intEntityId intUserId-- intUserId --?
				  , apRecur.intConcurrencyId
			FROM tblAPRecurringTransaction apRecur
			INNER JOIN tblAPBill apBill ON apRecur.intTransactionId = apBill.intBillId

			PRINT 'DELETE SOURCE >> tblAPRecurringTransaction'
			DELETE FROM tblAPRecurringTransaction

			SELECT @COUNTTARGET= COUNT(intRecurringId) FROM tblSMRecurringTransaction
			SELECT @COUNTSOURCE = COUNT(intRecurringId) FROM tblAPRecurringTransaction
	
			PRINT 'FINAL COUNT. TARGET COUNT: ' + CAST(@COUNTTARGET AS VARCHAR(10)) + ', SOURCE COUNT: ' + CAST(@COUNTSOURCE AS VARCHAR(10))
	
			PRINT '------------------END tblSMRecurringTransaction--------------------'
	
			PRINT '------------------BEGIN tblSMRecurringHistory------------------'
			SELECT @COUNTTARGET = COUNT(intRecurringHistoryId) FROM tblSMRecurringHistory
			SELECT @COUNTSOURCE = COUNT(intRecurringHistoryId) FROM tblAPRecurringHistory
	
			PRINT 'TARGET COUNT: ' + CAST(@COUNTTARGET AS VARCHAR(10)) + ', SOURCE COUNT: ' + CAST(@COUNTSOURCE AS VARCHAR(10))
	
			PRINT 'START INSERT >> tblAPRecurringHistory'
			INSERT INTO [dbo].[tblSMRecurringHistory]
					   ([strTransactionNumber]
					   ,[strTransactionCreated]
					   ,[dtmDateProcessed]
					   ,[strReference]
					   ,[dtmNextProcess]
					   ,[dtmLastProcess]
					   ,[strTransactionType]
					   ,[intConcurrencyId])
			SELECT [strTransactionId]
				  ,[strTransactionCreated]
				  ,[dtmDateProcessed]
				  ,[strReference]
				  ,[dtmNextProcess]
				  ,[dtmLastProcess]
				  ,CASE [intTransactionType]
					WHEN 1 THEN 'Bill'
					WHEN 2 THEN 'Vendor Payment'
					WHEN 3 THEN 'Debit Memo'
					WHEN 4 THEN 'Payable'
					WHEN 5 THEN 'Purchase Order'
					WHEN 6 THEN 'Bill Template'
					WHEN 7 THEN 'Bill Approval'
				   END as strTransactionType
				  ,[intConcurrencyId]
			FROM [dbo].[tblAPRecurringHistory]

			PRINT 'DELETE SOURCE >> tblAPRecurringHistory'
			DELETE FROM tblAPRecurringHistory
	
			SELECT @COUNTTARGET = COUNT(intRecurringHistoryId) FROM tblSMRecurringHistory
			SELECT @COUNTSOURCE = COUNT(intRecurringHistoryId) FROM tblAPRecurringHistory
	
			PRINT 'TARGET COUNT: ' + CAST(@COUNTTARGET AS VARCHAR(10)) + ', SOURCE COUNT: ' + CAST(@COUNTSOURCE AS VARCHAR(10))
		   
			PRINT '------------------END tblSMRecurringHistory--------------------'
		END
		ELSE
		BEGIN
			PRINT 'Table [tblSMRecurringTransaction] doesn''t exist'
		END

		--ROLLBACK TRANSACTION --TEST ONLY: REPLACE WITH 'BEGIN TRANSACTION'
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
	
		DECLARE @ErrorNumber INT = ERROR_NUMBER()
		DECLARE @ErrorLine INT = ERROR_LINE()

		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10))
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10))
	END CATCH
  
  
  	/* GENERAL JOURNAL */
	BEGIN TRY
		BEGIN TRANSACTION
		IF EXISTS ( SELECT  1
						FROM    INFORMATION_SCHEMA.TABLES
						WHERE   table_schema = 'dbo'
								AND TABLE_NAME = 'tblSMRecurringTransaction' )
		BEGIN			
			SELECT  main.strJournalRecurringId
				, b.intJournalId [intTransactionId]
				, b.strJournalId [strTransactionNumber]
				, 'General Journal' [strTransactionType]
				, main.strReference [strReference]
				, ISNULL(sec.strFullName, '') [strResponsibleUser]
				, 0 [intWarningDays]
				, CASE 
						WHEN main.strRecurringPeriod IS NULL THEN 'Monthly'
						WHEN main.strRecurringPeriod = 'Daily' THEN 'Daily'
						WHEN main.strRecurringPeriod = 'Weekly' THEN 'Weekly'
						WHEN main.strRecurringPeriod = 'MonthlyEnd' THEN 'Monthly'
				  END [strFrequency] 
				, ISNULL((SELECT TOP 1 dtmLastProcess from dbo.tblGLRecurringHistory history
					WHERE history.strJournalRecurringId = main.strJournalRecurringId
					ORDER BY dtmNextProcess DESC), b.dtmDateEntered) [dtmLastProcess]			
				, ISNULL((SELECT TOP 1 dtmNextProcess from dbo.tblGLRecurringHistory history
					WHERE history.strJournalRecurringId = main.strJournalRecurringId
					ORDER BY dtmNextProcess DESC),
					CASE 
						WHEN main.strRecurringPeriod IS NULL THEN DATEADD(MONTH, 1, b.dtmDateEntered)
						WHEN main.strRecurringPeriod = 'Daily' THEN DATEADD(DAY, 1, b.dtmDateEntered)
						WHEN main.strRecurringPeriod = 'Weekly' THEN DATEADD(WEEk, 1, b.dtmDateEntered)
						WHEN main.strRecurringPeriod = 'MonthlyEnd' THEN DATEADD(s,-1, DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0))
					END			
				  ) [dtmNExtProcess]
				, 0 [ysnDue]
				, CASE WHEN main.strRecurringPeriod = 'MonthlyEnd' THEN 'Last Day' ELSE NULL END [strDayOfMonth]
				, main.dtmStartDate [dtmStartDate]
				, main.dtmEndDate [dtmEndDate]
				, 1 [ysnActive]
				, 1 [intIteration]
				, CAST(case when ISNUMERIC(main.strUserMode) = 0 THEN '0' ELSE main.strUserMode END AS INT) [intUserId]
				, 1 [ysnAvailable]
				, b.intConcurrencyId
			INTO #tmp
			FROM dbo.tblGLJournalRecurring main
			INNER JOIN dbo.tblGLJournal b ON main.intJournalId = b.intJournalId
			LEFT JOIN dbo.tblSMUserSecurity sec ON CAST(case when ISNUMERIC(main.strUserMode) = 0 THEN '0' ELSE main.strUserMode END AS INT) = sec.[intEntityId]
			WHERE (1=1)
			-- removed to include all recurring with or without history
			-- AND main.strJournalRecurringId IN (SELECT DISTINCT strJournalRecurringId FROM dbo.tblGLRecurringHistory)
			AND ISNULL(main.ysnImported, 0) = 0

			PRINT '------------------BEGIN tblSMRecurringTransaction------------------'
			INSERT INTO dbo.tblSMRecurringTransaction
				( intTransactionId ,
				  strTransactionNumber ,
				  strTransactionType ,
				  strReference ,
				  strResponsibleUser ,
				  intWarningDays ,
				  strFrequency ,
				  dtmLastProcess ,
				  dtmNextProcess ,
				  ysnDue ,
				  strDayOfMonth ,
				  dtmStartDate ,
				  dtmEndDate ,
				  ysnActive ,
				  intIteration ,
				  intUserId ,
				  ysnAvailable ,
				  intConcurrencyId
				)
			SELECT intTransactionId
				, strTransactionNumber
				, strTransactionType
				, strReference
				, strResponsibleUser
				, intWarningDays
				, strFrequency
				, dtmLastProcess
				, dtmNExtProcess
				, ysnDue
				, strDayOfMonth
				, dtmStartDate
				, dtmEndDate
				, ysnActive
				, intIteration
				, intUserId
				, ysnAvailable
				, intConcurrencyId
			FROM #tmp
			PRINT '------------------END tblSMRecurringTransaction--------------------'
	
			PRINT '------------------BEGIN tblSMRecurringHistory------------------'
			INSERT INTO dbo.tblSMRecurringHistory
					( strTransactionNumber ,
					  strTransactionCreated ,
					  dtmDateProcessed ,
					  strReference ,
					  dtmNextProcess ,
					  dtmLastProcess ,
					  strTransactionType ,
					  intConcurrencyId
					)
			SELECT #tmp.strTransactionNumber
				, history.strJournalId
				, history.dtmProcessDate
				, history.strReference
				, history.dtmNextProcess
				, history.dtmLastProcess
				, history.strTransactionType
				, history.intConcurrencyId
			FROM dbo.tblGLRecurringHistory history
			INNER JOIN #tmp ON history.strJournalRecurringId = #tmp.strJournalRecurringId
			WHERE history.strJournalId NOT IN (SELECT strTransactionCreated FROM dbo.tblSMRecurringHistory)
			PRINT '------------------END tblSMRecurringHistory--------------------'

			-- UPDATE GJ RECURRING IF DONE IMPORTING
			UPDATE dbo.tblGLJournalRecurring
			SET ysnImported = 1
			FROM dbo.tblGLJournalRecurring gl
			INNER JOIN #tmp ON gl.strJournalRecurringId = #tmp.strJournalRecurringId

			DROP TABLE #tmp
		END
		ELSE
		BEGIN
			PRINT 'Table [tblSMRecurringTransaction] doesn''t exist'
		END

		--ROLLBACK TRANSACTION --TEST ONLY: REPLACE WITH 'BEGIN TRANSACTION'
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
	
		DECLARE @glErrorNumber INT = ERROR_NUMBER()
		DECLARE @glErrorLine INT = ERROR_LINE()

		PRINT 'Actual error number: ' + CAST(@glErrorNumber AS VARCHAR(10))
		PRINT 'Actual line number: ' + CAST(@glErrorLine AS VARCHAR(10))
	END CATCH    

END
