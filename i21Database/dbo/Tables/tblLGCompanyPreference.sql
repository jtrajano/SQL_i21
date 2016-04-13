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

CONSTRAINT [PK_tblLGCompanyPreference] PRIMARY KEY ([intCompanyPreferenceId]), 
CONSTRAINT [FK_tblLGCompanyPreference_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
CONSTRAINT [FK_tblLGCompanyPreference_tblICUnitMeasure_intWeightUOMId] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGCompanyPreference_tblCTPosition_intDefaultPositionId] FOREIGN KEY ([intDefaultPositionId]) REFERENCES [tblCTPosition]([intPositionId])
)
