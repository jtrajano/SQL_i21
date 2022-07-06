CREATE TABLE [dbo].[tblTFCountyLocation]
(
	[intCountyLocationId] INT IDENTITY NOT NULL,
	[intTaxAuthorityId] INT NULL,
	[strCounty] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[dblRate1] NUMERIC(18,6) NULL,
	[dblRate2] NUMERIC(18,6) NULL,
	[intMasterId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFCountyLocation] PRIMARY KEY ([intCountyLocationId]),
	CONSTRAINT [FK_tblTFCountyLocation_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [tblTFTaxAuthority]([intTaxAuthorityId]) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblTFCountyLocation_intMasterId] ON [dbo].[tblTFCountyLocation] ([intMasterId])
GO