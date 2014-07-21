
--=====================================================================================================================================
-- 	Normalize strCode 
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN Normalize strCode'
GO

UPDATE tblGLDetail SET strCode = 'GJ' WHERE strTransactionForm = 'General Journal'

--=====================================================================================================================================
-- 	Normalize strModuleName
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'END Normalize strCode'
	PRINT N'BEGIN Normalize strModuleName'
GO

UPDATE tblGLDetail SET strModuleName = 'General Ledger' WHERE strTransactionForm = 'General Journal' AND strModuleName is NULL
UPDATE tblGLDetail SET strModuleName = 'General Ledger' WHERE strTransactionForm = 'Audit Adjustment' AND strModuleName is NULL

--=====================================================================================================================================
-- 	Normalize ysnSystem
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'END Normalize strModuleName'
	PRINT N'BEGIN Normalize ysnSystem'
GO

UPDATE tblGLAccount SET ysnSystem = 0 WHERE ysnSystem is NULL

--=====================================================================================================================================
-- 	Repopulate GL Summary
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'END Normalize ysnSystem'
	PRINT N'BEGIN Repopulate GL Summary'
GO

DELETE [dbo].[tblGLSummary]

INSERT INTO tblGLSummary
SELECT
	 intAccountId
	,dtmDate
	,SUM(ISNULL(dblDebit,0)) as dblDebit
	,SUM(ISNULL(dblCredit,0)) as dblCredit
	,SUM(ISNULL(dblDebitUnit,0)) as dblDebitUnit
	,SUM(ISNULL(dblCreditUnit,0)) as dblCreditUnit
	,strCode
	,0 as intConcurrencyId
FROM
	tblGLDetail
WHERE ysnIsUnposted = 0	
GROUP BY intAccountId, dtmDate, strCode

--=====================================================================================================================================
-- 	Normalize strJournalType 
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'END Repopulate GL Summary'
	PRINT N'BEGIN Normalize strJournalType'
GO

UPDATE tblGLJournal SET strJournalType = 'Origin Journal' WHERE strJournalType = 'Legacy Journal'
UPDATE tblGLJournal SET strJournalType = 'Adjusted Origin Journal' WHERE strJournalType = 'Adjusted Legacy Journal'

--=====================================================================================================================================
-- 	Move all Accounts Types (Sales & Cost Of Goods Sold) to Account Groups (Sales & Cost Of Goods Sold)
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'END Normalize strJournalType'
	PRINT N'BEGIN Move all Accounts Types (Sales & Cost Of Goods Sold) to Account Groups (Sales & Cost Of Goods Sold): ACCOUNT ID'
GO

UPDATE tblGLAccount SET intAccountGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = 'Sales' AND intParentGroupId > 0)
				WHERE intAccountGroupId IN (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = 'Sales')

UPDATE tblGLAccount SET intAccountGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = 'Cost Of Goods Sold' AND intParentGroupId > 0)
				WHERE intAccountGroupId IN (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = 'Cost Of Goods Sold')

GO
	PRINT N'END Move all Accounts Types (Sales & Cost Of Goods Sold) to Account Groups (Sales & Cost Of Goods Sold): ACCOUNT ID'
	PRINT N'BEGIN Move all Accounts Types (Sales & Cost Of Goods Sold) to Account Groups (Sales & Cost Of Goods Sold): ACCOUNT SEGMENT'
GO

UPDATE tblGLAccountSegment SET intAccountGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = 'Sales' AND intParentGroupId > 0)
				WHERE intAccountGroupId IN (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = 'Sales')
								
UPDATE tblGLAccountSegment SET intAccountGroupId = (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = 'Cost Of Goods Sold' AND intParentGroupId > 0)
				WHERE intAccountGroupId IN (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = 'Cost Of Goods Sold')	

GO
	PRINT N'END Move all Accounts Types (Sales & Cost Of Goods Sold) to Account Groups (Sales & Cost Of Goods Sold): ACCOUNT SEGMENT'
	PRINT N'BEGIN Move all Accounts Types (Sales & Cost Of Goods Sold) to Account Groups (Sales & Cost Of Goods Sold): ACCOUNT GROUP'
GO

UPDATE tblGLAccountGroup SET strAccountType = 'Revenue' WHERE strAccountType = 'Sales'
UPDATE tblGLAccountGroup SET strAccountType = 'Expense' WHERE strAccountType = 'Cost of Goods Sold'

UPDATE tblGLAccountGroup SET intParentGroupId = (select intAccountGroupId from tblGLAccountGroup where strAccountGroup = 'Sales' and intParentGroupId > 0)
				WHERE intParentGroupId = (select intAccountGroupId from tblGLAccountGroup where strAccountGroup = 'Sales' and intParentGroupId = 0)
UPDATE tblGLAccountGroup SET intParentGroupId = (select intAccountGroupId from tblGLAccountGroup where strAccountGroup = 'Cost of Goods Sold' and intParentGroupId > 0)
				WHERE intParentGroupId = (select intAccountGroupId from tblGLAccountGroup where strAccountGroup = 'Cost of Goods Sold' and intParentGroupId = 0)

DELETE tblGLAccountGroup WHERE strAccountGroup = 'Sales' AND intParentGroupId = 0
DELETE tblGLAccountGroup WHERE strAccountGroup = 'Cost Of Goods Sold' AND intParentGroupId = 0

GO
	PRINT N'END Move all Accounts Types (Sales & Cost Of Goods Sold) to Account Groups (Sales & Cost Of Goods Sold): ACCOUNT GROUP'
GO
