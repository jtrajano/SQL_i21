print('/*******************  BEGIN Required Inventory Data Fix *******************/')
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblICFixLog WHERE strFixName like '%Fix-1') 
BEGIN 
	INSERT INTO tblICFixLog (
		strFixName 
		,strFixDescription
		,dtmLog
	)
	SELECT	strFixName = 'Start Fix-1'
			,strFixDescription = 'Execute stored procedure [uspICFixStockQuantities] to correct the data in tblICItemStock and tblICItemStockUOM. You can also refer to JIRA key: IC-1012.'
			,dtmLog = GETDATE()

	-- Run the SP to fix the data. 
	EXEC dbo.uspICFixStockQuantities;

	INSERT INTO tblICFixLog (
		strFixName 
		,strFixDescription
		,dtmLog
	)
	SELECT	strFixName = 'End Fix-1'
			,strFixDescription = 'Execute stored procedure [uspICFixStockQuantities] to correct the data in tblICItemStock and tblICItemStockUOM. You can also refer to JIRA key: IC-1012.'
			,dtmLog = GETDATE()
END 

GO
print('/*******************  END Required Inventory Data Fix *******************/')