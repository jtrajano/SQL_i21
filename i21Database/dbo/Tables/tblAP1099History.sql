CREATE TABLE [dbo].[tblAP1099History]
(
	[int1099HistoryId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityVendorId] INT NOT NULL, 
    [intYear] INT NOT NULL DEFAULT 0, 
	[int1099Form] INT NOT NULL DEFAULT 0, 
    [ysnPrinted] BIT NOT NULL DEFAULT 0, 
    [ysnFiled] BIT NOT NULL DEFAULT 0, 
    [strComment] NVARCHAR(500) NULL, 
    [dblAmount] DECIMAL(18, 6) NULL, 
    [strVendorName] NVARCHAR(200) NULL, 
	[strVendorId] NVARCHAR(100) NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dtmDatePrinted] DATETIME NULL, 
    [dtmDateFiled] DATETIME NULL
)
