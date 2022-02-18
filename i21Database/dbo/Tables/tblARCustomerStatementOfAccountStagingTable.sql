CREATE TABLE [dbo].[tblARCustomerStatementOfAccountStagingTable] (
     [strCustomerName]			NVARCHAR(MAX)
	,[strAccountStatusCode]		NVARCHAR(5)
	,[strLocationName]			NVARCHAR(50)
	,[ysnPrintZeroBalance]		BIT
	,[ysnPrintCreditBalance]	BIT
	,[ysnIncludeBudget]			BIT
	,[ysnPrintOnlyPastDue]		BIT
	,[strStatementFormat]		NVARCHAR(100)	
	,[dtmDateFrom]				DATETIME
	,[dtmDateTo]				DATETIME
	,[intEntityUserId]			INT
	,[strReportLogId]			NVARCHAR(MAX)
	,[blbLogo]					VARBINARY(MAX)
);

