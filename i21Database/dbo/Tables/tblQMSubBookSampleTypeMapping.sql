CREATE TABLE [dbo].[tblQMSubBookSampleTypeMapping]
(
	[intSubBookSampleTypeMappingId] INT NOT NULL IDENTITY,
    [intConcurrencyId] INT NOT NULL DEFAULT(0),
	[intSubBookId] INT NOT NULL,
	[intSampleTypeId] INT NOT NULL,
	CONSTRAINT [PK_SubBookSampleTypeMapping_intSubBookSampleTypeMappingId] PRIMARY KEY CLUSTERED ([intSubBookSampleTypeMappingId] ASC),
    CONSTRAINT [FK_SubBookSampleTypeMapping_tblCTSubBook] FOREIGN KEY ([intSubBookId]) REFERENCES [dbo].[tblCTSubBook] ([intSubBookId]),
    CONSTRAINT [FK_SubBookSampleTypeMapping_tblQMSampleType] FOREIGN KEY ([intSampleTypeId]) REFERENCES [dbo].[tblQMSampleType] ([intSampleTypeId])
)
GO