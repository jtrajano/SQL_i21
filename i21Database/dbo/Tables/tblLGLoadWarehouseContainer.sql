CREATE TABLE [dbo].[tblLGLoadWarehouseContainer]
(
[intLoadWarehouseContainerId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intLoadWarehouseId] INT NOT NULL,
[intLoadContainerId] INT NOT NULL,
[strID1] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strID2] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strID3] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intLoadWarehouseContainerRefId] INT NULL,

CONSTRAINT [PK_tblLGLoadWarehouseContainer] PRIMARY KEY ([intLoadWarehouseContainerId]), 
CONSTRAINT [FK_tblLGLoadWarehouseContainer_tblLGLoadWarehouse_intLoadWarehouseId] FOREIGN KEY ([intLoadWarehouseId]) REFERENCES [tblLGLoadWarehouse]([intLoadWarehouseId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGLoadWarehouseContainer_tblLGLoadContainer_intLoadContainerId] FOREIGN KEY ([intLoadContainerId]) REFERENCES [tblLGLoadContainer]([intLoadContainerId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblLGLoadWarehouseContainer_intLoadContainerId] ON [dbo].[tblLGLoadWarehouseContainer]
(
	[intLoadContainerId] 
	,[intLoadWarehouseId]
)
GO