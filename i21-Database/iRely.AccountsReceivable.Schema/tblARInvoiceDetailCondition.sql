CREATE TABLE [dbo].[tblARInvoiceDetailCondition](
	[intInvoiceDetailConditionId]	INT IDENTITY(1,1) NOT NULL,
	[intInvoiceDetailId]			INT NOT NULL,
	[intConditionId]				INT NOT NULL,
	[intCompanyId]					INT NULL,
	[intConcurrencyId]				INT CONSTRAINT [DF_tblARItemDetailCondition_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARInvoiceDetailCondition_intInvoiceDetailConditionId] PRIMARY KEY CLUSTERED (intInvoiceDetailConditionId ASC),
	CONSTRAINT [FK_tblARInvoiceDetailCondition_tblARInvoiceDetail] FOREIGN KEY ([intInvoiceDetailId]) REFERENCES [dbo].[tblARInvoiceDetail] ([intInvoiceDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoiceDetailCondition_tblCTCondition] FOREIGN KEY ([intConditionId]) REFERENCES [dbo].[tblCTCondition] ([intConditionId]) ON DELETE CASCADE
)