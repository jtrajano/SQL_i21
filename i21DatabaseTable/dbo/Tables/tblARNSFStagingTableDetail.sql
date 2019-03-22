CREATE TABLE [dbo].[tblARNSFStagingTableDetail]
(
	[intNSFTransactionDetailId]	INT				IDENTITY (1, 1) NOT NULL,
	[intNSFTransactionId]		INT				NOT NULL,
	[intPaymentId]				INT				NOT NULL,
	[intNSFAccountId]			INT				NULL,
	[dtmDate]					DATETIME		NULL,
	[dblNSFBankCharge]			NUMERIC(18, 6)	NULL DEFAULT 0,
	[ysnInvoiceToCustomer]		BIT				NOT NULL CONSTRAINT [DF_tblARNSFStagingTable_ysnInvoiceToCustomer] DEFAULT ((0)),
	[ysnProcessed]				BIT				NOT NULL CONSTRAINT [DF_tblARNSFStagingTable_ysnProcessed] DEFAULT ((0)),
	[intConcurrencyId]			INT				NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARNSFStagingTableDetail_intNSFTransactionDetailId] PRIMARY KEY CLUSTERED ([intNSFTransactionDetailId] ASC),
	CONSTRAINT [PK_tblARNSFStagingTableDetail_tblARNSFStagingTable_intNSFTransactionId] FOREIGN KEY ([intNSFTransactionId]) REFERENCES [dbo].[tblARNSFStagingTable] ([intNSFTransactionId]),
	CONSTRAINT [FK_tblARNSFStagingTableDetail_tblARPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblARPayment] ([intPaymentId]),
	CONSTRAINT [FK_tblARNSFStagingTableDetail_tblGLAccount_intNSFAccountId] FOREIGN KEY ([intNSFAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
)
