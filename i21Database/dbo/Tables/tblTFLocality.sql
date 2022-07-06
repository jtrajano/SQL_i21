CREATE TABLE [dbo].[tblTFLocality]
(
	[intLocalityId] INT IDENTITY (1,1) NOT NULL,
	[intTaxAuthorityId] INT NOT NULL,
	[strLocalityCode] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocalityZipCode] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocalityName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intMasterId] INT NULL,
    [intConcurrencyId] INT  DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblTFLocality] PRIMARY KEY CLUSTERED ([intLocalityId] ASC),
	CONSTRAINT [FK_tblTFLocality_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [dbo].[tblTFTaxAuthority] ([intTaxAuthorityId]) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblTFLocality_intMasterId] ON [dbo].[tblTFLocality] ([intMasterId])
GO