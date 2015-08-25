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
	AND j.ysnPosted = 1
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
	--GL-2016
GO
	DELETE FROM tblGLAccountCategoryGroup
	WHERE intAccountCategoryId IN(SELECT intAccountCategoryId
							  FROM tblGLAccountCategory
							  WHERE strAccountCategory IN('Broker Expense', 'Contract Equity', 'Contract Purchase Gain/Loss', 'Contract Sales Gain/Loss', 'Currency Equity', 'Currency Purchase Gain/Loss', 'Currency Sales Gain/Loss', 'DP Liability','DP Income', 'DP Income', 'Fee Expense', 'Fee Income', 'Freight Expenses', 'Interest Expense', 'Interest Income', 'Options Expense', 'Options Income', 'Purchase Account', 'Rail Freight', 'Storage Expense', 'Storage Income', 'Storage Receivable','Other Charge (Asset)')) AND 
	  strAccountCategoryGroupCode = 'INV'
GO
	PRINT N'End Deleting Categories not used in Inventory'
GO



