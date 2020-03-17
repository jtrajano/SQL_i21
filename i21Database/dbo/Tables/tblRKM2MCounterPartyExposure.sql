CREATE TABLE [dbo].[tblRKM2MCounterPartyExposure]
(
	[intM2MCounterPartyExposureId] INT NOT NULL IDENTITY, 
    [intM2MHeaderId] INT NULL,	
    [intVendorId] INT  NULL, 
    [strRating] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [dblFixedPurchaseVolume] NUMERIC(18, 6) NULL,     
	[dblUnfixedPurchaseVolume] NUMERIC(18, 6) NULL,  
	[dblTotalCommittedVolume] NUMERIC(18, 6) NULL,  
	[dblFixedPurchaseValue] NUMERIC(18, 6) NULL,  
	[dblUnfixedPurchaseValue] NUMERIC(18, 6) NULL,  
	[dblTotalCommittedValue] NUMERIC(18, 6) NULL,  
	[dblTotalSpend] NUMERIC(18, 6) NULL,  
	[dblShareWithSupplier] NUMERIC(18, 6) NULL,   
	[dblMToM] NUMERIC(18, 6) NULL,  
	[dblPotentialAdditionalVolume] NUMERIC(18, 6) NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKM2MCounterPartyExposure] PRIMARY KEY ([intM2MCounterPartyExposureId]), 
    CONSTRAINT [FK_tblRKM2MCounterPartyExposure_tblRKM2MHeader] FOREIGN KEY ([intM2MHeaderId]) REFERENCES [tblRKM2MHeader]([intM2MHeaderId])
)
