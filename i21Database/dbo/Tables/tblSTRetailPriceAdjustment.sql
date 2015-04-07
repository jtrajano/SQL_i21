CREATE TABLE [dbo].[tblSTRetailPriceAdjustment]
(
	[intRetailPriceAdjustmentId] INT NOT NULL IDENTITY , 
    [dtmEffectiveDate] DATETIME NOT NULL, 
    [strDescription] NVARCHAR(120) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTRetailPriceAdjustment] PRIMARY KEY CLUSTERED ([intRetailPriceAdjustmentId] ASC), 
    CONSTRAINT [AK_tblSTRetailPriceAdjustment_dtmEffectiveDate] UNIQUE NONCLUSTERED ([dtmEffectiveDate]ASC), 
)
