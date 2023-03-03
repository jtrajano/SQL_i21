CREATE TABLE [dbo].[tblFAFixedAssetTaxJurisdiction]
(
	[intAssetTaxJurisdictionId]		INT IDENTITY (1, 1) NOT NULL,
	[strTaxJurisdiction]			NVARCHAR (255) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]				INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFAFixedAssetTaxJurisdiction] PRIMARY KEY CLUSTERED ([intAssetTaxJurisdictionId] ASC)
)
