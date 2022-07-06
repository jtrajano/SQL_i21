CREATE TABLE [dbo].[tblSTRetailPriceAdjustment]
(
	[intRetailPriceAdjustmentId]		INT											NOT NULL	IDENTITY , 
	[strRetailPriceAdjustmentNumber]	NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL,
    [dtmEffectiveDate]					DATETIME									NULL, 
    [strDescription]					NVARCHAR(120) COLLATE Latin1_General_CI_AS	NULL, 
	[ysnOneTimeUse]						BIT											NOT NULL	DEFAULT 0,
	[dtmPostedDate]						DATETIME									NULL,
	[intEntityId]						INT											NULL,
	[ysnPosted]							BIT											NOT NULL	DEFAULT 0,
    [intConcurrencyId]					INT											NOT NULL, 
    CONSTRAINT [PK_tblSTRetailPriceAdjustment] PRIMARY KEY CLUSTERED ([intRetailPriceAdjustmentId] ASC),
	--CONSTRAINT [AK_tblSTRetailPriceAdjustment_strRetailPriceAdjustmentNumber] UNIQUE NONCLUSTERED ([strRetailPriceAdjustmentNumber]ASC),
    --CONSTRAINT [AK_tblSTRetailPriceAdjustment_dtmEffectiveDate] UNIQUE NONCLUSTERED ([dtmEffectiveDate]ASC), 
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UK_tblSTRetailPriceAdjustment_strRetailPriceAdjustmentNumber]
  ON dbo.tblSTRetailPriceAdjustment
  (
		strRetailPriceAdjustmentNumber
  )
  WHERE strRetailPriceAdjustmentNumber IS NOT NULL
	AND strRetailPriceAdjustmentNumber <> ''
