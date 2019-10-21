CREATE TABLE [dbo].[tblCTItemContractDetail] (
    [intItemContractDetailId]				[int] IDENTITY(1,1) NOT NULL,
    [intItemContractHeaderId]				[int] NOT NULL,	

    [intLineNo]								[int] NULL,	
	[intItemId]								[int] NULL,	
    [strItemDescription]					[nvarchar](250)	COLLATE Latin1_General_CI_AS NULL,
	
    [dtmDeliveryDate]						[datetime] NULL,
	[dtmLastDeliveryDate]					[datetime] NULL,	

	[dblContracted]							[numeric](18, 6) NULL,
	[dblScheduled]							[numeric](18, 6) NULL,
	[dblAvailable]							[numeric](18, 6) NULL,
	[dblApplied]							[numeric](18, 6) NULL,
	[dblBalance]							[numeric](18, 6) NULL,
	[dblTax]								[numeric](18, 6) NULL,
	[dblPrice]								[numeric](18, 6) NULL,
	[dblTotal]								[numeric](18, 6) NULL,

	[intContractStatusId]					[int] NULL,
	[intItemUOMId]							[int] NULL,		
	[intTaxGroupId]							[int] NULL,

    [intConcurrencyId]						[int] CONSTRAINT [DF_tblCTItemContractDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,

    CONSTRAINT [PK_tblCTItemContractDetail_intInvoiceDetailId] PRIMARY KEY CLUSTERED ([intItemContractDetailId] ASC),
    CONSTRAINT [FK_tblCTItemContractDetail_tblCTItemContractHeader] FOREIGN KEY ([intItemContractHeaderId]) REFERENCES [dbo].[tblCTItemContractHeader] ([intItemContractHeaderId]) ON DELETE CASCADE	
);

GO
CREATE NONCLUSTERED INDEX [PIndex]
    ON [dbo].[tblCTItemContractDetail]([intItemContractHeaderId] ASC, [intItemId] ASC, [strItemDescription] ASC, [dblContracted] ASC, [dblScheduled] ASC, [dblAvailable] ASC, [dblTotal] ASC);
