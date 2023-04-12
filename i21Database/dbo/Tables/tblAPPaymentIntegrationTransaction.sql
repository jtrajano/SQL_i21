CREATE TABLE [dbo].[tblAPPaymentIntegrationTransaction]
(
	[intId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intInvoiceId] INT NULL,
	[ysnReadyForPayment] BIT DEFAULT 0,
	[ysnRefundFromPayment] BIT DEFAULT 0,
	[dblNewPayment] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblTempDiscount] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblTempInterest] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblTempPayment] DECIMAL(18,	 6) NOT NULL DEFAULT 0,
	[intConcurrencyId] INT NOT NULL DEFAULT 0

)

