CREATE TABLE [dbo].[tblARInvoiceTransactionHistory]
(
	[intInvoiceTransactionHistoryId]				INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intInvoiceId]									INT NOT NULL,
	[intInvoiceDetailId]							INT NULL,
    --[strInvoiceNumber]								NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL,												  
    [dblQtyReceived]								NUMERIC(18, 6) CONSTRAINT [DF_tblARInvoiceTransactionHistory_dblQtyReceived] DEFAULT ((0)) NULL,
    [dblPrice]										NUMERIC(18, 6) CONSTRAINT [DF_tblARInvoiceTransactionHistory_dblPrice] DEFAULT ((0)) NULL,
    [dblCost]										NUMERIC(18, 6) CONSTRAINT [DF_tblARInvoiceTransactionHistory_dblCost] DEFAULT ((0)) NULL,
    [dblAmountDue]									NUMERIC(18, 6) CONSTRAINT [DF_tblARInvoiceTransactionHistory_dblAmountDue] DEFAULT ((0)) NULL,
	[dblInvoiceTotal]								NUMERIC(18, 6) CONSTRAINT [DF_tblARInvoiceTransactionHistory_dblInvoiceTotal] DEFAULT ((0)) NULL,
    [dblInvoicePayment]								NUMERIC(18, 6) CONSTRAINT [DF_tblARInvoiceTransactionHistory_dblInvoicePayment] DEFAULT ((0)) NULL,
    [dblInvoiceBalance]								NUMERIC(18, 6) CONSTRAINT [DF_tblARInvoiceTransactionHistory_dblInvoiceBalance] DEFAULT ((0)) NULL,
	[intItemId]										INT NULL,
	[intItemUOMId]									INT NULL,
	[intCompanyLocationId]							INT NULL,
	[intTicketId]									INT NULL,
	[intCommodityId] 								INT NULL,
	[dtmTicketDate]									DATETIME NULL,
	[dtmTransactionDate]							DATETIME NOT NULL DEFAULT(GETDATE()),
	[intCompanyId]									INT NULL,
	[intCurrencyId]									INT NULL,
	[intPaymentId]									INT NULL,
	[strRecordNumber]								NVARCHAR(25) COLLATE Latin1_General_CI_AS DEFAULT(('')),
	[ysnPost]										BIT NULL
	
    CONSTRAINT [FK_tblARInvoiceTransactionHistory_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]) ON DELETE CASCADE,
)
