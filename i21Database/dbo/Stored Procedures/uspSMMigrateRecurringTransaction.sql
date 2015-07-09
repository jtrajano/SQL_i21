CREATE PROCEDURE [dbo].[uspSMMigrateRecurringTransaction]
AS
BEGIN

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

END
