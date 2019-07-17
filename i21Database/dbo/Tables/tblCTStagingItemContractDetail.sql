CREATE TABLE [dbo].[tblCTStagingItemContractDetail] (
    [intStagingItemDetailId]				[int] IDENTITY(1,1) NOT NULL,
    [intStagingItemId]						[int] NULL,

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

    CONSTRAINT PK_tblCTStagingItemContractDetail_intStagingItemDetailId PRIMARY KEY (intStagingItemDetailId)
);

GO