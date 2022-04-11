﻿CREATE TABLE [dbo].[tblARInvoiceIntegrationLogDetail]
(
	[intIntegrationLogDetailId]			INT				IDENTITY						NOT NULL,
	[intIntegrationLogId]				INT												NOT NULL,
	[intInvoiceId]						INT												NULL,
	[intInvoiceDetailId]				INT												NULL,
	[intTemporaryDetailIdForTax]		INT												NULL,
	[intId]								INT												NULL,
	[strMessage]						NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL,
	[strPostingMessage]					NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL,
	[strTransactionType]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[strType]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
	[strSourceTransaction]				NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[intSourceId]						INT												NULL,
	[strSourceId]						NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[ysnPost]							BIT												NULL,
	[ysnRecap]							BIT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_ysnRecap] DEFAULT ((0)) NULL,
	[ysnInsert]							BIT												NULL,
	[ysnHeader]							BIT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_ysnHeader] DEFAULT ((0)) NOT NULL,
	[ysnSuccess]						BIT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_ysnSuccess] DEFAULT ((0)) NOT NULL,
	[ysnPosted]							BIT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_ysnPosted] DEFAULT ((0)) NULL,
	[ysnUnPosted]						BIT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_ysnUnPosted] DEFAULT ((0)) NULL,	
	[ysnAccrueLicense]					BIT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_ysnAccrueLicense] DEFAULT ((0)) NULL,	
	[ysnUpdateAvailableDiscount]		BIT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_ysnUpdateAvailableDiscountOnly] DEFAULT ((0)) NULL,	
	[strPostedTransactionId]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[strBatchId]						NVARCHAR(40)   COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]					INT CONSTRAINT [DF_tblARInvoiceIntegrationLogDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARInvoiceIntegrationLogDetail_intIntegrationLogDetailId] PRIMARY KEY CLUSTERED ([intIntegrationLogDetailId] ASC)
	--,CONSTRAINT [FK_tblARInvoiceIntegrationLogDetail_tblARInvoiceIntegrationLog] FOREIGN KEY ([intIntegrationLogId]) REFERENCES [dbo].[tblARInvoiceIntegrationLog] ([intIntegrationLogId]) ON DELETE CASCADE
)
GO
CREATE INDEX [idx_tblARInvoiceIntegrationLogDetail] ON [dbo].[tblARInvoiceIntegrationLogDetail] (intIntegrationLogId, intIntegrationLogDetailId)