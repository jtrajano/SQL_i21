print('/*******************  BEGIN - Truncating all AR staging tables  *******************/')
GO

-- TRUNCATE TABLE tblARNSFStagingTable
-- TRUNCATE TABLE tblARNSFStagingTableDetail
TRUNCATE TABLE tblARInvoiceReportStagingTable
TRUNCATE TABLE tblARCustomerStatementStagingTable
TRUNCATE TABLE tblARCustomerAgingStagingTable
TRUNCATE TABLE tblARCustomerActivityStagingTable
TRUNCATE TABLE tblARTaxStagingTable
TRUNCATE TABLE tblARGLSummaryStagingTable
TRUNCATE TABLE tblARProductRecapStagingTable

GO
print('/*******************  END - Truncating all AR staging tables  *******************/')