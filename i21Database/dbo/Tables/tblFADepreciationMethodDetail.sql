CREATE TABLE [dbo].[tblFADepreciationMethodDetail] (
    [intDepreciationMethodDetailId]	INT IDENTITY (1, 1) NOT NULL,
	
	[intDepreciationMethodId]		INT NULL,
	[intYear]						INT NULL,
	[dblPercentage]					NUMERIC (18, 6) NULL DEFAULT ((0)),	

    [intConcurrencyId]				INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFADepreciationMethodDetail] PRIMARY KEY CLUSTERED ([intDepreciationMethodDetailId] ASC),
    CONSTRAINT [FK_tblFADepreciationMethodDetail_tblFADepreciationMethod] FOREIGN KEY([intDepreciationMethodId]) REFERENCES [dbo].[tblFADepreciationMethod] ([intDepreciationMethodId]) ON DELETE CASCADE
);

