CREATE TABLE [dbo].[tblAGProductMixer]
(
    [intProductMixerId] INT NOT NULL IDENTITY,
    [intLocationId] INT NOT NULL,
    [strMixerNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription] NVARCHAR(45) COLLATE Latin1_General_CI_AS NOT NULL,
    [strType] NVARCHAR(45) COLLATE Latin1_General_CI_AS NOT NULL,
    [dblSize] NUMERIC(18, 6) NULL DEFAULT 0,
    [intSizeUOMId] INT NULL,
    [dblVolume] NUMERIC(18, 6) NULL DEFAULT 0,
    [intVolumeUOMId] INT NULL,
    [dblMaxBatchSize] NUMERIC(18, 6) NULL DEFAULT 0,
    [intMaxBatchSizeUOMId] INT NULL,
    [strRestrictedBatches] NVARCHAR(45) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL,
    CONSTRAINT [UK_tblAGProductMixer_strType] UNIQUE([strMixerNumber]),
    CONSTRAINT [PK_tblAGProductMixer_intProductMixerId] PRIMARY KEY ([intProductMixerId]), 
    CONSTRAINT [FK_tblAGProductMixer_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
)
GO
CREATE NONCLUSTERED INDEX [IX_tblAGProductMixer_intLocationId] ON [dbo].[tblAGProductMixer](
	[intLocationId] ASC
);
GO