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

	CONSTRAINT [PK_tblLGLoadDetailLot_intLoadDetailLotId] PRIMARY KEY CLUSTERED ([intLoadDetailLotId] ASC),
	CONSTRAINT [FK_tblLGLoadDetailLot_tblICLoadDetail] FOREIGN KEY([intLoadDetailId]) REFERENCES [dbo].[tblLGLoadDetail] ([intLoadDetailId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblLGLoadDetailLot_tblICLot] FOREIGN KEY([intLotId]) REFERENCES [dbo].[tblICLot] ([intLotId]),
	CONSTRAINT [FK_tblLGLoadDetailLot_intItemUOMId] FOREIGN KEY([intItemUOMId]) REFERENCES [dbo].[tblICItemUOM] ([intItemUOMId]),
	CONSTRAINT [FK_tblLGLoadDetailLot_intWeightUOMId] FOREIGN KEY([intWeightUOMId]) REFERENCES [dbo].[tblICItemUOM] ([intItemUOMId]),
)
