
--=====================================================================================================================================
-- 	Normalize ysnSystem (default = false | 0)
---------------------------------------------------------------------------------------------------------------------------------------

GO	
	PRINT N'BEGIN Normalize ysnSystem'
GO

UPDATE tblGLAccount SET ysnSystem = 0 WHERE ysnSystem is NULL

GO	
	PRINT N'END Normalize ysnSystem'
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

UPDATE tblGLDetail SET strTransactionType = X.strJournalType,
						 intTransactionId = X.intJournalId
	FROM (SELECT strJournalType, intJournalId, strJournalId FROM tblGLJournal) X 
	WHERE X.strJournalId = tblGLDetail.strTransactionId AND (strTransactionType IS NULL OR intTransactionId IS NULL)
	

UPDATE A SET strDescription = B.strDescription
	FROM tblGLDetail A INNER JOIN tblGLJournal B
	ON A.strTransactionId = B.strJournalId
	AND A.strModuleName = 'General Ledger'
	AND (A.strDescription IS NULL OR A.strDescription = '')

	PRINT N'END Normalize tblGLDetail Fields'
GO
