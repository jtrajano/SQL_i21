CREATE TABLE [dbo].[tblLGLoadDetailLot]
(
	[intLoadDetailLotId] INT IDENTITY(1,1) NOT NULL,
	[intLoadDetailId] INT NOT NULL,
	[intLotId] INT NULL,
	[dblLotQuantity] NUMERIC(38, 20) NULL,
	[intItemUOMId] INT,
	[dblGross] NUMERIC(38, 20) NULL,
	[dblTare] NUMERIC(38, 20) NULL,
	[dblNet] NUMERIC(38, 20) NULL,
	[intWeightUOMId] INT,
	[strWarehouseCargoNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intSort] INT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[intLoadDetailLotRefId] INT NULL,
	[strID1] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strID2] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strID3] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,

	CONSTRAINT [PK_tblLGLoadDetailLot_intLoadDetailLotId] PRIMARY KEY CLUSTERED ([intLoadDetailLotId] ASC),
	CONSTRAINT [FK_tblLGLoadDetailLot_tblICLoadDetail] FOREIGN KEY([intLoadDetailId]) REFERENCES [dbo].[tblLGLoadDetail] ([intLoadDetailId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblLGLoadDetailLot_tblICLot] FOREIGN KEY([intLotId]) REFERENCES [dbo].[tblICLot] ([intLotId]),
	CONSTRAINT [FK_tblLGLoadDetailLot_intItemUOMId] FOREIGN KEY([intItemUOMId]) REFERENCES [dbo].[tblICItemUOM] ([intItemUOMId]),
	CONSTRAINT [FK_tblLGLoadDetailLot_intWeightUOMId] FOREIGN KEY([intWeightUOMId]) REFERENCES [dbo].[tblICItemUOM] ([intItemUOMId]),
)
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetailLot_197_1540916561__K2_K4_3] ON [dbo].[tblLGLoadDetailLot]
(
	[intLoadDetailId] ASC,
	[dblLotQuantity] ASC
)
INCLUDE ( 	[intLotId]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetailLot_197_1540916561__K3_K2_K4] ON [dbo].[tblLGLoadDetailLot]
(
	[intLotId] ASC,
	[intLoadDetailId] ASC,
	[dblLotQuantity] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetailLot_197_1540916561__K2_K4] ON [dbo].[tblLGLoadDetailLot]
(
	[intLoadDetailId] ASC,
	[dblLotQuantity] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetailLot_197_1540916561__K2_K3_K4] ON [dbo].[tblLGLoadDetailLot]
(
	[intLoadDetailId] ASC,
	[intLotId] ASC,
	[dblLotQuantity] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
