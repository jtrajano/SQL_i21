CREATE TABLE [dbo].[tblPATCancelEquity]
(
	[intCancelId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [dtmCancelDate] DATETIME NULL, 
    [strCancelNo] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
    [strDescription] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
    [intFromCustomerId] INT NULL, 
    [intToCustomerId] INT NULL, 
    [intFiscalYearId] INT NULL, 
    [strCancelBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblCancelByAmount] NUMERIC(18, 6) NULL, 
    [dblCancelLessAmount] NUMERIC(18, 6) NULL, 
    [intIncludeEquityReserve] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0
)
