CREATE TABLE [dbo].[tblAP1099History]
(
	[int1099HistoryId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityVendorId] INT NOT NULL, 
    [intYear] INT NOT NULL DEFAULT 0, 
	[int1099Form] INT NOT NULL DEFAULT 0, 
    [ysnPrinted] BIT NOT NULL DEFAULT 0, 
    [ysnFiled] BIT NOT NULL DEFAULT 0, 
    [strComment] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
    [dblAmount] DECIMAL(18, 6) NULL, 
    [strVendorName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
	[strVendorId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dtmDatePrinted] DATETIME NULL, 
    [dtmDateFiled] DATETIME NULL
)

GO

CREATE NONCLUSTERED INDEX [IX_tblAP1099History_intEntityVendorId] ON [dbo].[tblAP1099History] ([intEntityVendorId], [intYear], [ysnPrinted])
