CREATE TABLE [dbo].[tblAPDeferredPaymentInterest]
(
	[intDeferredPaymentInterestId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [intCompanyId] INT NULL,
    [dtmCalculationDate] DATETIME NULL, 
    [dtmPaymentPostDate] DATETIME NULL, 
    [dtmPaymentInvoiceDate] DATETIME NULL, 
    [dtmPaymentDueDateOverride] DATETIME NULL, 
    [strTerm] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strCheckComment] NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL, 
    [dblMinimum] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[intConcurrencyId] INT NOT NULL DEFAULT 0
)
