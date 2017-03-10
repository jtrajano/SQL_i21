CREATE TABLE [dbo].[tblLGLoadWarehouse]
(
[intLoadWarehouseId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intLoadId] INT NOT NULL,
[strDeliveryNoticeNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
[dtmDeliveryNoticeDate] DATETIME NULL,
[intSubLocationId] INT NULL,
[intStorageLocationId] INT NULL,
[intHaulerEntityId] INT NULL,
[dtmPickupDate] DATETIME NULL,
[dtmDeliveryDate] DATETIME NULL,
[dtmLastFreeDate] DATETIME NULL,
[dtmStrippingReportReceivedDate] DATETIME NULL,
[dtmSampleAuthorizedDate] DATETIME NULL,
[strStrippingReportComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
[strFreightComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
[strSampleComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
[strOtherComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
[intWarehouseRateMatrixHeaderId] INT NULL,

CONSTRAINT [PK_tblLGLoadWarehouse] PRIMARY KEY ([intLoadWarehouseId]), 
CONSTRAINT [FK_tblLGLoadWarehouse_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGLoadWarehouse_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId_intSubLocationId] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
CONSTRAINT [FK_tblLGLoadWarehouse_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]),
CONSTRAINT [FK_tblLGLoadWarehouse_tblEMEntity_intHaulerEntityId] FOREIGN KEY ([intHaulerEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGLoadWarehouse_tblLGWarehouseRateMatrixHeader_intWarehouseRateMatrixHeaderId] FOREIGN KEY ([intWarehouseRateMatrixHeaderId]) REFERENCES [tblLGWarehouseRateMatrixHeader]([intWarehouseRateMatrixHeaderId])
)
