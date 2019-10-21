CREATE TABLE [dbo].[tblCTIndex]
(
	[intIndexId] INT IDENTITY NOT NULL,
	[strIndex] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strIndexType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intVendorId] INT,
	[intVendorLocationId] INT,
    [ysnActive] BIT NULL, 
	[intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblCTIndex_intIndexId] PRIMARY KEY CLUSTERED ([intIndexId] ASC),
	CONSTRAINT [FK_tblCTIndex_tblEMEntity_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblCTIndex_tblEMEntityLocation_intVendorLocationId] FOREIGN KEY ([intVendorLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId])
)
