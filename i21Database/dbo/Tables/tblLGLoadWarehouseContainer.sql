CREATE TABLE [dbo].[tblLGLoadWarehouseContainer]
(
[intLoadWarehouseContainerId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intLoadWarehouseId] INT NOT NULL,
[intLoadContainerId] INT NOT NULL,
[intLoadWarehouseContainerRefId] INT NULL,

CONSTRAINT [PK_tblLGLoadWarehouseContainer] PRIMARY KEY ([intLoadWarehouseContainerId]), 
CONSTRAINT [FK_tblLGLoadWarehouseContainer_tblLGLoadWarehouse_intLoadWarehouseId] FOREIGN KEY ([intLoadWarehouseId]) REFERENCES [tblLGLoadWarehouse]([intLoadWarehouseId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGLoadWarehouseContainer_tblLGLoadContainer_intLoadContainerId] FOREIGN KEY ([intLoadContainerId]) REFERENCES [tblLGLoadContainer]([intLoadContainerId])
)
