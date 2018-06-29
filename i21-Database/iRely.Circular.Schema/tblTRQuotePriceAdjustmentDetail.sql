CREATE TABLE [dbo].[tblTRQuotePriceAdjustmentDetail]
(
	[intQuotePriceAdjustmentDetailId] INT NOT NULL IDENTITY,
	[intQuotePriceAdjustmentHeaderId] INT NOT NULL,
	[intItemId] INT NULL,
	[intCategoryId] INT NULL,
	[dblAdjustment] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblTermsPerUnit] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblMiscPerUnit] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dtmFromEffectiveDateTime]  DATETIME        NULL,
	[dtmToEffectiveDateTime]    DATETIME        NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRQuotePriceAdjustmentDetail] PRIMARY KEY ([intQuotePriceAdjustmentDetailId]),
	
	CONSTRAINT [FK_tblTRQuotePriceAdjustmentDetail_tblTRQuotePriceAdjustmentHeader_intQuotePriceAdjustmentHeaderId] FOREIGN KEY ([intQuotePriceAdjustmentHeaderId]) REFERENCES [dbo].[tblTRQuotePriceAdjustmentHeader] ([intQuotePriceAdjustmentHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRQuotePriceAdjustmentDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblTRQuotePriceAdjustmentDetail_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId])
)
