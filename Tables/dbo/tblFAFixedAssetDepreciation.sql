CREATE TABLE [dbo].[tblFAFixedAssetDepreciation] (
    [intAssetDepreciationId]	INT IDENTITY (1, 1) NOT NULL,
	
	[intAssetId]				INT NULL,
	[intDepreciationMethodId]	INT NULL,

	[dblBasis]					NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dtmDateInService]			DATETIME NULL,	
	[dtmDispositionDate]		DATETIME NULL,
	[dtmDepreciationToDate]		DATETIME NULL,
	[dblDepreciationToDate]		NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dblSalvageValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),
	[strTransaction]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strType]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strConvention]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,

    [intConcurrencyId]          INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFAFixedAssetDepreciation] PRIMARY KEY CLUSTERED ([intAssetDepreciationId] ASC),
    CONSTRAINT [FK_tblFAFixedAssetDepreciation_tblFAFixedAsset] FOREIGN KEY([intAssetId]) REFERENCES [dbo].[tblFAFixedAsset] ([intAssetId]) ON DELETE CASCADE
);

