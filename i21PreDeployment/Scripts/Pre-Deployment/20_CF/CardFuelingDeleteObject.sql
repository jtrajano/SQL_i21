




GO
IF EXISTS (SELECT 1 FROM sys.views WHERE Name='vyuCFSearchTransaction')
BEGIN
	EXEC ('DROP VIEW vyuCFSearchTransaction')
END

GO
IF EXISTS (SELECT 1 FROM sys.views WHERE Name='vyuCFTransactionItemCostPotentialIssue')
BEGIN
	EXEC ('DROP VIEW vyuCFTransactionItemCostPotentialIssue')
END

GO