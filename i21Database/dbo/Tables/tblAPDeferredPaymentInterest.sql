CREATE TABLE [dbo].[tblAPDeferredPaymentInterest]
(
	[intDeferredPaymentInterestId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [dtmCalculationDate] DATETIME NULL, 
    [dtmPaymentPostDate] DATETIME NULL, 
    [dtmPaymentInvoiceDate] DATETIME NULL, 
    [dtmPaymentDueDateOverride] DATETIME NULL, 
    [strTerm] NVARCHAR(100) NULL, 
    [dblMinimum] DECIMAL(18, 6) NOT NULL DEFAULT 0
)
