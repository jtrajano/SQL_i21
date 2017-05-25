CREATE TABLE [dbo].[tblARInvoiceIntegrationLogDetail]
(
	[intIntegrationLogDetailId]		INT				IDENTITY						NOT NULL,
	[intIntegrationLogId]			INT												NOT NULL,
	[intInvoiceId]					INT												NULL,
	[intInvoiceDetailId]			INT												NULL,
	[intTemporaryDetailIdForTax]	INT												NULL,
	[intId]							INT												NULL,
	[strErrorMessage]				NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL,
	[strTransactionType]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[strType]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
	[strSourceTransaction]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[intSourceId]					INT												NULL,
	[strSourceId]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[ysnPost]						BIT												NULL,
	[ysnInsert]						BIT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_ysnInsert] DEFAULT ((0)) NOT NULL,
	[ysnHeader]						BIT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_ysnHeader] DEFAULT ((0)) NOT NULL,
	[ysnSuccess]					BIT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_ysnSuccess] DEFAULT ((0)) NOT NULL,
	[intConcurrencyId]				INT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARInvoiceIntegrationLogDetail_intIntegrationLogDetailId] PRIMARY KEY CLUSTERED ([intIntegrationLogDetailId] ASC),
	CONSTRAINT [FK_tblARInvoiceIntegrationLogDetail_tblARInvoiceIntegrationLog] FOREIGN KEY ([intIntegrationLogId]) REFERENCES [dbo].[tblARInvoiceIntegrationLog] ([intIntegrationLogId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoiceIntegrationLogDetail_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]),
	CONSTRAINT [FK_tblARInvoiceIntegrationLogDetail_tblARInvoiceDetail_intInvoiceDetailId] FOREIGN KEY ([intInvoiceDetailId]) REFERENCES [dbo].[tblARInvoiceDetail] ([intInvoiceDetailId])
)
