CREATE TABLE [dbo].[tblAPDeferredPaymentStaging]
(
	[intDeferredPaymentStagingId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
    [intBillId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0
)
