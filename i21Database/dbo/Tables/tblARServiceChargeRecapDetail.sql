CREATE TABLE [dbo].[tblARServiceChargeRecapDetail]
(
	[intSCRecapDetailId]		INT IDENTITY (1, 1) NOT NULL,
    [intSCRecapId]				INT					NOT NULL,
	[intInvoiceId]				INT					NULL,
	[strInvoiceNumber]			NVARCHAR(50)		COLLATE Latin1_General_CI_AS	NULL,
	[strBudgetDescription]		NVARCHAR(100)		COLLATE Latin1_General_CI_AS	NULL,
	[dblAmount]					NUMERIC(18,6)		NULL,
	[intServiceChargeDays]		INT					NULL,
	[intConcurrencyId]			INT DEFAULT ((0))	NOT NULL
	CONSTRAINT [PK_tblARServiceChargeRecapDetail] PRIMARY KEY CLUSTERED ([intSCRecapDetailId] ASC),
	CONSTRAINT [FK_tblARServiceCHargeRecapDetail_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]),
	CONSTRAINT [FK_tblARServiceChargeRecapDetail_tblARServiceChargeRecap] FOREIGN KEY ([intSCRecapId]) REFERENCES [dbo].[tblARServiceChargeRecap] ([intSCRecapId]) ON DELETE CASCADE
)