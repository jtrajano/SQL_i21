CREATE TABLE [dbo].[tblMFBlendProductionOutputDetail]
(
	[intBlendProductionOutputDetailId] INT NOT NULL IDENTITY(1,1),
	[intWorkOrderId] INT NULL,
	[strParentLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblQuantity] NUMERIC(38,20),
	[intItemUOMId] INT NULL,
	[intStorageLocationId] int NULL,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblMFBlendProductionOutputDetail_intBlendProductionOutputDetailId] PRIMARY KEY ([intBlendProductionOutputDetailId]),
	CONSTRAINT [FK_tblMFBlendProductionOutputDetail_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFBlendProductionOutputDetail_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT FK_tblMFBlendProductionOutputDetail_tblICStorageLocation_intStorageLocationId FOREIGN KEY(intStorageLocationId) REFERENCES dbo.tblICStorageLocation (intStorageLocationId)
)
