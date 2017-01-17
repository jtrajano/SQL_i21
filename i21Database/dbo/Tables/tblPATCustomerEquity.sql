CREATE TABLE [dbo].[tblPATCustomerEquity]
(
	[intCustomerEquityId] INT NOT NULL IDENTITY, 
    [intCustomerId] INT NOT NULL, 
    [intFiscalYearId] INT NOT NULL, 
    [strEquityType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intRefundTypeId] INT NOT NULL, 
    [dblEquity] NUMERIC(18, 6) NOT NULL, 
	[dblEquityPaid] NUMERIC(18, 6) NULL DEFAULT 0,
    [intConcurrencyId] INT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblPATCustomerEquity] PRIMARY KEY ([intCustomerEquityId]) 
)