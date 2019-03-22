CREATE TABLE [dbo].[tblFADepreciationMethod] (
    [intDepreciationMethodId]	INT IDENTITY (1, 1) NOT NULL,
	
	[strDepreciationMethodId]	NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDepreciationType]		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[intServiceYear]			INT NULL,
	[intMonth]					INT NULL,
	[dblSalvageValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),
	[strConvention]				NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,	
	[dtmServiceDate]			DATETIME NULL,	

    [intConcurrencyId]          INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFADepreciationMethod] PRIMARY KEY CLUSTERED ([intDepreciationMethodId] ASC)
);

