CREATE TABLE [dbo].[tblARCustomerStatementFormat]
(
    [intCustomerStatementFormatId]		INT NOT NULL PRIMARY KEY IDENTITY, 
	[strStatementFormat]			    NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnCustomFormat]			        BIT NOT NULL DEFAULT 0,
	[intConcurrencyId]					INT NOT NULL DEFAULT 1,
)
GO
CREATE NONCLUSTERED INDEX [NC_tblARCustomerStatementFormat_strStatementFormat] ON [dbo].[tblARCustomerStatementFormat] ([strStatementFormat])
GO