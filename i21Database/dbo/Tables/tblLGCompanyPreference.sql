﻿CREATE TABLE [dbo].[tblLGCompanyPreference]
(
[intCompanyPreferenceId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intCommodityId] INT NULL,
[intWeightUOMId] INT NULL,
[ysnDropShip] [bit] NULL,
[ysnContainersRequired] [bit] NULL,
[intDefaultShipmentTransType] INT NULL,
[intDefaultShipmentSourceType] INT NULL,
[intDefaultTransportationMode] INT NULL,
[intDefaultPositionId] INT NULL,
[intDefaultLeastCostSourceType] INT NULL,
[strALKMapKey] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
[intTransUsedBy] INT NULL,
[strCarrierShipmentStandardText] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
[dblRouteHours] NUMERIC(18, 6) NULL,
[intHaulerEntityId] INT NULL,
[intDefaultShipmentType] INT NULL,
[strShippingInstructionText] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,

CONSTRAINT [PK_tblLGCompanyPreference] PRIMARY KEY ([intCompanyPreferenceId]), 
CONSTRAINT [FK_tblLGCompanyPreference_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
CONSTRAINT [FK_tblLGCompanyPreference_tblICUnitMeasure_intWeightUOMId] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGCompanyPreference_tblCTPosition_intDefaultPositionId] FOREIGN KEY ([intDefaultPositionId]) REFERENCES [tblCTPosition]([intPositionId]),
CONSTRAINT [FK_tblLGCompanyPreference_tblEMEntity_intEntityId] FOREIGN KEY ([intHaulerEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)
