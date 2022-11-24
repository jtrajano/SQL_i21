CREATE TABLE [dbo].[tblQMMarketZoneSampleTypeMapping]
(
	[intMarketZoneSampleTypeMappingId] INT NOT NULL IDENTITY,
    [intConcurrencyId] INT NOT NULL DEFAULT(0),
	[intMarketZoneId] INT NOT NULL,
	[intSampleTypeId] INT NOT NULL,
	CONSTRAINT [PK_tblMarketZoneSampleTypeMapping_intMarketZoneSampleTypeMappingId] PRIMARY KEY CLUSTERED ([intMarketZoneSampleTypeMappingId] ASC),
    CONSTRAINT [FK_tblMarketZoneSampleTypeMapping_tblARMarketZone] FOREIGN KEY ([intMarketZoneId]) REFERENCES [dbo].[tblARMarketZone] ([intMarketZoneId]),
    CONSTRAINT [FK_tblMarketZoneSampleTypeMapping_tblQMSampleType] FOREIGN KEY ([intSampleTypeId]) REFERENCES [dbo].[tblQMSampleType] ([intSampleTypeId])
)
GO