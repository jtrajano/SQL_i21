CREATE TABLE [dbo].[tblAPPaymentIntegrationTransaction]
(
	[intId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intInvoiceId] INT NULL,
	[ysnReadyForPayment] BIT DEFAULT 0,
	[intConcurrencyId] INT NOT NULL DEFAULT 0

)

