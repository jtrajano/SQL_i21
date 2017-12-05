CREATE TABLE [dbo].[tblARPricingHistory]
(
	[intPricingHistoryId]			INT             IDENTITY (1, 1)					NOT NULL,
	[intSourceTransactionId]		INT												NULL DEFAULT 1,
	[intTransactionId]				INT												NULL,
	[intTransactionDetailId]		INT												NULL,
	[intEntityCustomerId]			INT												NULL,
	[intItemId]						INT												NULL,
	[intOriginalItemId]				INT												NULL,
	[dblPrice]						NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblOriginalPrice]				NUMERIC(18, 6)									NULL,
	[strPricing]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[strOriginalPricing]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[dtmDate]						DATETIME										NOT NULL,
	[ysnApplied]					BIT												NOT NULL	CONSTRAINT [DF_tblARPricingHistory_ysnApplied] DEFAULT ((0)),		
	[ysnDeleted]					BIT												NOT NULL	CONSTRAINT [DF_tblARPricingHistory_ysnDeleted] DEFAULT ((0)),		
	[intEntityId]					INT												NOT NULL,
	[intConcurrencyId]				INT												NOT NULL	CONSTRAINT [DF_tblARPricingHistory_intConcurrencyId] DEFAULT ((0)),
    CONSTRAINT [PK_tblARPricingHistory_intPricingId] PRIMARY KEY CLUSTERED ([intPricingHistoryId] ASC),
    CONSTRAINT [FK_tblARPricingHistory_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
    CONSTRAINT [FK_tblARPricingHistory_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES tblICItem([intItemId]),
	CONSTRAINT [FK_tblARPricingHistory_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId])
)
