﻿CREATE TABLE [dbo].[tblLGGenerateLoad]
(
[intGenerateLoadId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intReferenceNumber] INT NOT NULL, 
[dtmTransDate] DATETIME NOT NULL,
[intType] INT NOT NULL,

[intPContractDetailId] INT NULL,
[intPEntityId] INT NULL,
[strPVendorContract] NVARCHAR(60) COLLATE Latin1_General_CI_AS NULL,
[dtmPArrivalDate] DATETIME NULL,
[intPEquipmentTypeId] INT NULL,
[intPHaulerEntityId] INT NULL,
[intPEntityLocationId] INT NULL,

[intSContractDetailId] INT NULL, 
[strSCustomerContract] NVARCHAR(60) COLLATE Latin1_General_CI_AS NULL,
[dtmSShipToDate] DATETIME NULL,
[intSEquipmentTypeId] INT NULL,
[intSHaulerEntityId] INT NULL,
[intSEntityLocationId] INT NULL,

[intAllocationDetailId] INT NULL,

[dblQuantity] NUMERIC(18, 6) NOT NULL,
[intUnitMeasureId] INT NULL,
[dblUnitsPerLoad] NUMERIC(18, 6) NOT NULL,
[intNumberOfLoads] INT NOT NULL,
[strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,
[intSourceType] INT NULL,
[intTransportationMode] INT NULL,
[intPCompanyLocationId] INT NULL,
[intSCompanyLocationId] INT NULL,
[intTransUsedBy] INT NULL, 
[ysnLoadBased] BIT NULL DEFAULT ((0)),
[intCompanyId] INT NULL,

[intEquipmentTypeId] INT NULL,
[intHaulerEntityId] INT NULL,
[intItemId] INT NULL,
[dtmShipDate] DATETIME NULL,
[dtmEndDate] DATETIME NULL,
[dblFreightRate] NUMERIC(18, 6) NULL DEFAULT (0),
[intFreightCurrencyId] INT NULL,
[intFreightUOMId] INT NULL,
[dblSurchargeRate] NUMERIC(18, 6) NULL DEFAULT (0),

CONSTRAINT [PK_tblLGGenerateLoad] PRIMARY KEY ([intGenerateLoadId]), 
CONSTRAINT [UK_tblLGGenerateLoad_intReferenceNumber] UNIQUE ([intReferenceNumber]),

CONSTRAINT [FK_tblLGGenerateLoad_tblCTContractDetail_intPContractDetailId] FOREIGN KEY ([intPContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
CONSTRAINT [FK_tblLGGenerateLoad_tblLGEquipmentType_intPEquipmentTypeId] FOREIGN KEY ([intPEquipmentTypeId]) REFERENCES [tblLGEquipmentType]([intEquipmentTypeId]),
CONSTRAINT [FK_tblLGGenerateLoad_tblEMEntity_intPHaulerEntityId] FOREIGN KEY ([intPHaulerEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGGenerateLoad_tblEMEntityLocation_intPEntityLocationId] FOREIGN KEY ([intPEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),

CONSTRAINT [FK_tblLGGenerateLoad_tblCTContractDetail_intSContractDetailId] FOREIGN KEY ([intSContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
CONSTRAINT [FK_tblLGGenerateLoad_tblLGEquipmentType_intSEquipmentTypeId] FOREIGN KEY ([intSEquipmentTypeId]) REFERENCES [tblLGEquipmentType]([intEquipmentTypeId]),
CONSTRAINT [FK_tblLGGenerateLoad_tblEMEntity_intSHaulerEntityId] FOREIGN KEY ([intSHaulerEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGGenerateLoad_tblEMEntityLocation_intSEntityLocationId] FOREIGN KEY ([intSEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),

CONSTRAINT [FK_tblLGGenerateLoad_tblLGAllocationDetail_intAllocationDetailId] FOREIGN KEY ([intAllocationDetailId]) REFERENCES [tblLGAllocationDetail]([intAllocationDetailId]), 
CONSTRAINT [FK_tblLGGenerateLoad_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),

CONSTRAINT [FK_tblLGGenerateLoad_tblSMCompanyLocation_intPCompanyLocationId] FOREIGN KEY ([intPCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
CONSTRAINT [FK_tblLGGenerateLoad_tblSMCompanyLocation_intSCompanyLocationId] FOREIGN KEY ([intSCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),

CONSTRAINT [FK_tblLGGenerateLoad_tblEMEntity_intPEntityId] FOREIGN KEY([intPEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)
