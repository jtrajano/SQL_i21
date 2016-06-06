--=====================================================================================================================================
-- 	Normalize ysnSystem (default = false | 0)
--  Default Cash Flow to 'NONE'
---------------------------------------------------------------------------------------------------------------------------------------

GO	
	PRINT N'BEGIN Normalize ysnSystem and strCashFlow'
GO

UPDATE tblGLAccount SET ysnSystem = 0 WHERE ysnSystem is NULL
UPDATE tblGLAccount SET strCashFlow = 'None' WHERE  ISNULL(strCashFlow,'') NOT IN ('Finance','Investments','Operations','None')

GO	
	PRINT N'END Normalize ysnSystem and strCashFlow'
GO

--=====================================================================================================================================
-- 	Normalize strJournalType (rename Legacy to Origin)
---------------------------------------------------------------------------------------------------------------------------------------

GO	
	PRINT N'BEGIN Normalize strJournalType'
GO

UPDATE tblGLJournal SET strJournalType = 'Origin Journal' WHERE strJournalType = 'Legacy Journal'
UPDATE tblGLJournal SET strJournalType = 'Adjusted Origin Journal' WHERE strJournalType = 'Adjusted Legacy Journal'

GO	
	PRINT N'END Normalize strJournalType'
GO

--=====================================================================================================================================
-- 	Normalize tblGLDetail Fields (strModuleName, strTransactionType, intTransactionId)
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN Normalize tblGLDetail Fields'
GO

UPDATE tblGLDetail SET strModuleName = 'General Ledger' WHERE strTransactionForm = 'General Journal' AND strModuleName is NULL
UPDATE tblGLDetail SET strModuleName = 'General Ledger' WHERE strTransactionForm = 'Audit Adjustment' AND strModuleName is NULL

UPDATE detail SET strTransactionType = journal.strJournalType,intTransactionId = journal.intJournalId
	FROM tblGLDetail detail JOIN tblGLJournal journal ON detail.strTransactionId = journal.strJournalId
 	WHERE detail.strTransactionType IS NULL OR detail.intTransactionId IS NULL
	
UPDATE detail  SET strDescription = jdetail.strDescription
	FROM tblGLDetail detail JOIN  tblGLJournal journal on detail.strTransactionId = journal.strJournalId
	JOIN tblGLJournalDetail jdetail ON detail.intJournalLineNo = jdetail.intJournalDetailId AND jdetail.intJournalId = journal.intJournalId
	WHERE detail.strDescription IS NULL OR detail.strDescription = ''

UPDATE tblGLDetail SET dblDebitForeign =  0 WHERE dblDebitForeign IS NULL
UPDATE tblGLDetail SET dblCreditForeign =  0 WHERE dblCreditForeign IS NULL
UPDATE tblGLDetail SET dblDebitReport =  0 WHERE dblDebitReport IS NULL
UPDATE tblGLDetail SET dblCreditReport =  0 WHERE dblCreditReport IS NULL
UPDATE tblGLDetail SET dblReportingRate =  0 WHERE dblReportingRate IS NULL

GO
	PRINT N'END Normalize tblGLDetail Fields'
GO

--=====================================================================================================================================
-- 	Update Transaction Type to Recurring if strTransactionType is equal to Template  GL-1769
---------------------------------------------------------------------------------------------------------------------------------------

GO	
	PRINT N'BEGIN Update Transaction Type to Recurring if strTransactionType is equal to Template '
GO
  PRINT N'Begin Update tblGLDetail.strCode based on tblGLJournal.strSourceType'
GO
    UPDATE A
    SET A.strCode = RTRIM (B.strSourceType)
    FROM tblGLDetail A INNER JOIN tblGLJournal B ON A.strTransactionId = B.strJournalId
    WHERE A.strTransactionType IN( 'Origin Journal', 'Adjusted Origin Journal' )
    AND A.strCode <> B.strSourceType
GO
    PRINT N'End Update tblGLDetail.strCode based on tblGLJournal.strSourceType'
GO
	PRINT N'BEGIN Updating Transaction Type to Recurring if strTransactionType is equal to Template '
GO

	UPDATE tblGLJournal SET strTransactionType = 'Recurring' WHERE strTransactionType ='Template'

GO	
	PRINT N'END Updating Transaction Type to Recurring if strTransactionType is equal to Template '
GO

GO
	PRINT N'Begin updating fiscalyear/period id in tblGLJournal' -- USED BY General Journal Reversal
GO
	UPDATE j SET intFiscalPeriodId = f.intGLFiscalYearPeriodId, intFiscalYearId = f.intFiscalYearId
	FROM tblGLJournal j, tblGLFiscalYearPeriod f
	WHERE j.dtmDate >= f.dtmStartDate and j.dtmDate <= f.dtmEndDate
GO
	PRINT N'End updating fiscalyear/period id in tblGLJournal'
GO
	PRINT N'Begin Updating tblGLDetail.strCode based on tblGLJournal.strSourceType'
GO
	UPDATE A
    SET A.strCode = RTRIM (B.strSourceType)
	FROM tblGLDetail A INNER JOIN tblGLJournal B ON A.strTransactionId = B.strJournalId
	WHERE A.strTransactionType IN( 'Origin Journal', 'Adjusted Origin Journal' )
	AND A.strCode <> B.strSourceType
GO
	PRINT N'End Updating tblGLDetail.strCode based on tblGLJournal.strSourceType'
GO
 	PRINT N'Begin Deleting Categories not used in Inventory'
 	--GL-2016 & GL-2224
 GO
 	DELETE FROM tblGLAccountCategoryGroup
 	WHERE intAccountCategoryId IN(SELECT intAccountCategoryId
 							  FROM tblGLAccountCategory
 							  WHERE strAccountCategory IN('Broker Expense', 'Contract Equity', 'Contract Purchase Gain/Loss', 'Contract Sales Gain/Loss', 'Currency Equity', 'Currency Purchase Gain/Loss', 'Currency Sales Gain/Loss', 'DP Liability','DP Income', 'DP Income', 'Fee Expense', 'Fee Income', 'Freight Expenses', 'Interest Expense', 'Interest Income', 'Options Expense', 'Options Income', 'Purchase Account', 'Rail Freight', 'Storage Expense', 'Storage Income', 'Storage Receivable','Other Charge (Asset)', 'Begin Inventory','Discount Receivable','End Inventory','Variance Account')) AND 
 	  strAccountCategoryGroupCode = 'INV'
 GO
 	PRINT N'End Deleting Categories not used in Inventory'
 GO
 GO	
	PRINT N'BEGIN Trim Account Description in tblGLAccount'
 GO

	UPDATE tblGLAccount set  strDescription  = LTRIM(RTRIM(strDescription)) where intAccountId IN (select intAccountId from tblGLCOACrossReference)
 GO	
	PRINT N'End Trim Account Description in tblGLAccount'
 GO
	
	PRINT N'Begin Updating NULL intCurrencyID in tblGLAccount'
	--GL-2500
GO
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects Where object_id = object_id('tblGLAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.objects Where object_id = object_id('tblSMCompanyPreference'))
	BEGIN
		UPDATE tblGLAccount set intCurrencyID =  (select intDefaultCurrencyId from tblSMCompanyPreference) where intCurrencyID is NULL
	END
	
	PRINT N'End Updating NULL intCurrencyID in tblGLAccount'

GO

	PRINT N'Begin Updating NULL Foreign data columns  in tblGLDetail'
	--GL-2625
GO
	update tblGLDetail set dblCreditForeign = 0 where dblCreditForeign is NULL and dblExchangeRate = 1.00000000000000000000
	update tblGLDetail set dblDebitForeign = 0 where dblDebitForeign is NULL and dblExchangeRate = 1.00000000000000000000
	update tblGLDetail set dblCreditReport = 0 where dblCreditReport is NULL 
	update tblGLDetail set dblDebitReport = 0 where dblDebitReport is NULL 
	update tblGLDetail set dblReportingRate = 0 where dblReportingRate is NULL 
		
	PRINT N'End Updating NULL Foreign data columns  in tblGLDetail'

GO

