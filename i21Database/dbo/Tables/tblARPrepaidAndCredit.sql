﻿CREATE TABLE [dbo].[tblARPrepaidAndCredit]
(
	[intPrepaidAndCreditId]				INT				IDENTITY(1,1)	NOT NULL,
	[intInvoiceId]						INT								NOT NULL,
	[intInvoiceDetailId]				INT								NULL,
	[intPrepaymentId]					INT								NOT NULL,
	[intPrepaymentDetailId]				INT								NULL,
	[dblPostedAmount]					NUMERIC(18, 6)					NULL		DEFAULT 0,
	[dblBasePostedAmount]				NUMERIC(18, 6)					NULL		DEFAULT 0,
	[dblPostedDetailAmount]				NUMERIC(18, 6)					NULL		DEFAULT 0,
	[dblBasePostedDetailAmount]			NUMERIC(18, 6)					NULL		DEFAULT 0,
	[dblAppliedInvoiceAmount]			NUMERIC(18, 6)					NULL		DEFAULT 0,
	[dblBaseAppliedInvoiceAmount]		NUMERIC(18, 6)					NULL		DEFAULT 0,
	[dblAppliedInvoiceDetailAmount]		NUMERIC(18, 6)					NULL		DEFAULT 0,
	[dblBaseAppliedInvoiceDetailAmount]	NUMERIC(18, 6)					NULL		DEFAULT 0,
	[ysnApplied]						BIT								NULL		DEFAULT 0,
	[ysnPosted]							BIT								NULL		DEFAULT 0,
	[intRowNumber]						INT								NULL,
	[intConcurrencyId]					INT								NOT NULL	CONSTRAINT [DF_tblARPrepaidAndCredit_intConcurrencyId] DEFAULT ((0)),
	CONSTRAINT [PK_tblARPrepaidAndCredit_intPrepaidAndCreditId] PRIMARY KEY CLUSTERED ([intPrepaidAndCreditId] ASC),
	CONSTRAINT [FK_tblARPrepaidAndCredit_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice]([intInvoiceId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARPrepaidAndCredit_tblARInvoiceDetail_intInvoiceDetailId] FOREIGN KEY ([intInvoiceDetailId]) REFERENCES [dbo].[tblARInvoiceDetail]([intInvoiceDetailId]),
	CONSTRAINT [FK_tblARPrepaidAndCredit_tblARInvoice_intPrepaymentId] FOREIGN KEY ([intPrepaymentId]) REFERENCES [dbo].[tblARInvoice]([intInvoiceId]),
	CONSTRAINT [FK_tblARPrepaidAndCredit_tblARInvoiceDetail_intPrepaymentDetailId] FOREIGN KEY ([intPrepaymentDetailId]) REFERENCES [dbo].[tblARInvoiceDetail]([intInvoiceDetailId])
)
GO
CREATE NONCLUSTERED INDEX [IX_tblARPrepaidAndCredit_NonClustered] ON [dbo].[tblARPrepaidAndCredit] (
  [intInvoiceId], [intInvoiceDetailId], [intPrepaymentId], [intPrepaymentDetailId]
)
GO
