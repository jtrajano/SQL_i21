﻿	CREATE TABLE [dbo].[tblMFOrderManifest] (
		 [intOrderManifestId] INT NOT NULL IDENTITY
		,[intConcurrencyId] INT NOT NULL
		,[intOrderDetailId] INT NOT NULL
		,[intOrderHeaderId] INT NOT NULL
		,[intLotId] INT NULL
		,[strManifestItemNote] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,[intLastUpdateId] INT
		,[dtmLastUpdateOn] DATETIME DEFAULT GETDATE()
		
		,CONSTRAINT [PK_tblMFOrderManifest_intOrderManifestId] PRIMARY KEY ([intOrderManifestId])
		,CONSTRAINT [FK_tblMFOrderManifest_tblMFOrderDetail_intOrderDetailId] FOREIGN KEY ([intOrderDetailId]) REFERENCES [tblMFOrderDetail]([intOrderDetailId]) ON DELETE CASCADE
		,CONSTRAINT [FK_tblMFOrderManifest_tblMFOrderHeader_intOrderHeaderId] FOREIGN KEY ([intOrderHeaderId]) REFERENCES [tblMFOrderHeader]([intOrderHeaderId])
		,CONSTRAINT [FK_tblMFOrderManifest_tblICLot_intLotId] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId])
		)
Go
CREATE NONCLUSTERED INDEX IX_tblMFOrderManifest_intOrderDetailId ON [dbo].[tblMFOrderManifest]
(
	[intOrderDetailId] ASC,
	[intLotId] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]