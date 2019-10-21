CREATE TABLE [dbo].[tblCTItemContractHistory] (
    [intItemContractHistoryId]				[int] IDENTITY(1,1) NOT NULL,

    [intItemContractHeaderId]				[int] NULL,	
	[intItemContractDetailId]				[int] NULL,	
    [intLineNo]								[int] NULL,	
	[intItemId]								[int] NULL,	
    [strItemDescription]					[nvarchar](250)	COLLATE Latin1_General_CI_AS NULL,

    [dtmDeliveryDate]						[datetime] NULL,
	[dtmOldLastDeliveryDate]				[datetime] NULL,	
	[dtmNewLastDeliveryDate]				[datetime] NULL,	

	[dblOldContracted]						[numeric](18, 6) NULL,
	[dblOldScheduled]						[numeric](18, 6) NULL,
	[dblOldAvailable]						[numeric](18, 6) NULL,
	[dblOldApplied]							[numeric](18, 6) NULL,
	[dblOldBalance]							[numeric](18, 6) NULL,
	[dblOldTax]								[numeric](18, 6) NULL,
	[dblOldPrice]							[numeric](18, 6) NULL,
	[dblOldTotal]							[numeric](18, 6) NULL,

	[dblNewContracted]						[numeric](18, 6) NULL,
	[dblNewScheduled]						[numeric](18, 6) NULL,
	[dblNewAvailable]						[numeric](18, 6) NULL,
	[dblNewApplied]							[numeric](18, 6) NULL,
	[dblNewBalance]							[numeric](18, 6) NULL,
	[dblNewTax]								[numeric](18, 6) NULL,
	[dblNewPrice]							[numeric](18, 6) NULL,
	[dblNewTotal]							[numeric](18, 6) NULL,

	[intOldContractStatusId]				[int] NULL,
	[intNewContractStatusId]				[int] NULL,

	[intItemUOMId]							[int] NULL,		
	[intTaxGroupId]							[int] NULL,

	[strTransactionId]						[nvarchar](250)	COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]						[int] NULL,
	[intTransactionDetailId]				[int] NULL,
	[intEntityId]							[int] NULL,
	[strTransactionType]					[nvarchar](250)	COLLATE Latin1_General_CI_AS NULL,
	[dtmTransactionDate]					[datetime] NULL,	

    [intConcurrencyId]						[int] CONSTRAINT [DF_tblCTItemContractHistory_intConcurrencyId] DEFAULT ((0)) NOT NULL,

    CONSTRAINT [PK_tblCTItemContractHistory_intItemContractHistoryId] PRIMARY KEY CLUSTERED ([intItemContractHistoryId] ASC)
);

GO
CREATE NONCLUSTERED INDEX [PIndex]
    ON [dbo].[tblCTItemContractHistory]([intItemContractHistoryId] ASC, [intItemContractHeaderId] ASC, [intItemContractDetailId] ASC, [intLineNo] ASC);
