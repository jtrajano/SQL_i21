﻿CREATE TABLE [dbo].[tblLGShipment]
(
[intShipmentId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intTrackingNumber] INT NOT NULL,
[intPositionId] INT NULL,
[intVendorEntityId] INT NOT NULL,
[intWeightUnitMeasureId] INT NOT NULL,
[ysnDirectShipment] [bit] NULL,
[intCustomerEntityId] INT NULL,
[intShippingInstructionTypeId] INT NULL,
[intShippingInstructionId] INT NULL,
[strOriginPort] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL,
[strDestinationPort] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL,
[strDestinationCity] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL,
[intTerminalEntityId] INT NULL,
[intShippingLineEntityId] INT NULL,
[strPackingDescription] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL,
[strMVessel] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL,
[strMVoyageNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
[strFVessel] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL,
[strFVoyageNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
[intSubLocationId] INT NULL,
[strTruckNumber] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL,
[intForwardingAgentEntityId] INT NULL,
[strForwardingAgentRef] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL,
[dblInsuranceValue] NUMERIC(18, 6) NULL,
[intInsuranceCurrencyId] INT NULL,
[dtmDocsToBroker] DATETIME NULL,
[dtmShipmentDate] DATETIME NULL,
[ysnInventorized] [bit] NULL,
[dtmInventorizedDate] DATETIME NULL,
[dtmDocsReceivedDate] DATETIME NULL,
[dtmETAPOL] DATETIME NULL,
[dtmETSPOL] DATETIME NULL,
[dtmETAPOD] DATETIME NULL,
[dtmActualArrivalDate] DATETIME NULL,
[dtmActualDischargeDate] DATETIME NULL,
[strComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

[intDeliveryNoticeNumber] INT NULL,
[dtmDeliveryNoticeDate] DATETIME NULL,
[intTruckerEntityId] INT NULL,
[dtmPickupDate] DATETIME NULL,
[dtmDeliveryDate] DATETIME NULL,
[dtmLastFreeDate] DATETIME NULL,
[dtmStrippingReportReceivedDate] DATETIME NULL,
[dtmSampleAuthorizedDate] DATETIME NULL,

[strStrippingReportComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
[strFreightComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
[strSampleComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
[strOtherComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

[intCompanyLocationId] INT NOT NULL, 
[intCommodityId] INT NOT NULL, 

[intInsurerEntityId] INT NULL,

CONSTRAINT [PK_tblLGShipment_intShipmentId] PRIMARY KEY ([intShipmentId]), 
CONSTRAINT [UK_tblLGShipment_intTrackingNumber] UNIQUE ([intTrackingNumber]),

CONSTRAINT [FK_tblLGShipment_tblEMEntity_intVendorEntityId_intEntityId] FOREIGN KEY ([intVendorEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGShipment_tblICUnitMeasure_intWeightUnitMeasureId_intUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGShipment_tblEMEntity_intCustomerEntityId_intEntityId] FOREIGN KEY ([intCustomerEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGShipment_tblLGShippingInstruction_intShippingInstructionId] FOREIGN KEY ([intShippingInstructionId]) REFERENCES [tblLGShippingInstruction]([intShippingInstructionId]),
CONSTRAINT [FK_tblLGShipment_tblEMEntity_intTerminalEntityId] FOREIGN KEY ([intTerminalEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGShipment_tblEMEntity_intShippingLineEntityId_intEntityId] FOREIGN KEY ([intShippingLineEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGShipment_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId_intSubLocationId] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
CONSTRAINT [FK_tblLGShipment_tblEMEntity_intForwardingAgentEntityId_intEntityId] FOREIGN KEY ([intForwardingAgentEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGShipment_tblSMCurrency_intInsuranceCurrencyId_intCurrencyID] FOREIGN KEY ([intInsuranceCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
CONSTRAINT [FK_tblLGShipmentInStore_tblEMEntity_intTruckerEntityId] FOREIGN KEY ([intTruckerEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGShipment_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
CONSTRAINT [FK_tblLGShipment_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
CONSTRAINT [FK_tblLGShipment_tblEMEntity_intInsurerEntityId_intEntityId] FOREIGN KEY ([intInsurerEntityId]) REFERENCES tblEMEntity([intEntityId])
)
