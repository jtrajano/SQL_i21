CREATE TABLE [dbo].[tblWHOrderManifest]
(
	[intOrderManifestId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[intOrderLineItemId] INT NOT NULL,
	[intOrderHeaderId] INT NOT NULL,
	[strManifestItemNote] NVARCHAR(128) COLLATE Latin1_General_CI_AS NULL,
	[intSKUId] INT NOT NULL,
	[intLotId] INT NULL,
	[strSSCCNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intLastUpdateId] INT,
	[dtmLastUpdateOn] DATETIME DEFAULT GETDATE(),

	CONSTRAINT [PK_tblWHOrderManifest_intOrderManifestId]  PRIMARY KEY ([intOrderManifestId]),	
	CONSTRAINT [FK_tblWHOrderManifest_tblWHOrderLineItem_intOrderLineItemId] FOREIGN KEY ([intOrderLineItemId]) REFERENCES [tblWHOrderLineItem]([intOrderLineItemId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblWHOrderManifest_tblWHOrderHeader_intOrderHeaderId] FOREIGN KEY ([intOrderHeaderId]) REFERENCES [tblWHOrderHeader]([intOrderHeaderId]),
	CONSTRAINT [FK_tblWHOrderManifest_tblWHSKU_intSKUId] FOREIGN KEY ([intSKUId]) REFERENCES [tblWHSKU]([intSKUId]),

)
