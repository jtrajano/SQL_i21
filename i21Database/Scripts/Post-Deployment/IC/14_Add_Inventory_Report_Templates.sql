-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory Cost Adjustment Types. 
-- --------------------------------------------------

print('/*******************  BEGIN Add Inventory Report Templates *******************/')
GO

UPDATE	tblICCompanyPreference
SET		strReceiptReportFormat = ISNULL(strReceiptReportFormat, 'Receipt Report Format - 1')
		,strPickListReportFormat = ISNULL(strPickListReportFormat, 'Pick List Report Format - 1')
		,strBOLReportFormat = ISNULL(strBOLReportFormat, 'BOL Report Format - 1')
		,strTransferReportFormat = ISNULL(strTransferReportFormat, 'Transfer Report Format - 1')
		,strCountSheetReportFormat = ISNULL(strCountSheetReportFormat, 'Count Sheet Report Format - 1')

GO
print('/*******************  END Add Inventory Report Templates *******************/')
GO 