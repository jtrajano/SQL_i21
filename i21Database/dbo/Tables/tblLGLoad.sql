﻿CREATE TABLE [dbo].[tblLGLoad]
(
[intLoadId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[strLoadNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
[intCompanyLocationId] INT NULL,
[intPurchaseSale] INT NOT NULL,
[intItemId] INT NULL,
[dblQuantity] NUMERIC(18, 6) NULL,
[intUnitMeasureId] INT NULL,
[dtmScheduledDate] DATETIME NULL,
[strCustomerReference] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intEquipmentTypeId] INT NULL,
[intEntityId] INT NULL,
[intEntityLocationId] INT NULL,
[intContractDetailId] INT NULL,
[strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,
[intHaulerEntityId] INT NULL,
[intTicketId] INT NULL,
[ysnInProgress] [bit] NULL,
[dblDeliveredQuantity] NUMERIC(18, 6) NULL,
[dtmDeliveredDate] DATETIME NULL,

[intGenerateLoadId] INT NULL, 
[intGenerateSequence] INT NULL, 

[strTruckNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strTrailerNo1] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strTrailerNo2] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strTrailerNo3] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intUserSecurityId] INT NULL, 	
[strExternalLoadNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intTransportLoadId] INT NULL,
[intDriverEntityId] INT NULL,
[ysnDispatched] [bit] NULL,
[dtmDispatchedDate] DATETIME NULL,
[intDispatcherId] INT NULL, 	
[ysnDispatchMailSent] [bit] NULL,
[dtmDispatchMailSent] DATETIME NULL,
[dtmCancelDispatchMailSent] DATETIME NULL,
[intLoadHeaderId] INT NULL,

[intSourceType] INT NULL,
[intPositionId] INT NULL,
[intWeightUnitMeasureId] INT NULL,
[strBLNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[dtmBLDate] DATETIME NULL,
[strOriginPort] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strDestinationPort] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strDestinationCity] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[intTerminalEntityId] INT NULL,
[intShippingLineEntityId] INT NULL,
[strServiceContractNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strPackingDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strMVessel] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strMVoyageNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strFVessel] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strFVoyageNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intForwardingAgentEntityId] INT NULL,
[strForwardingAgentRef] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intInsurerEntityId] INT NULL,
[dblInsuranceValue] NUMERIC(18, 6) NULL,
[intInsuranceCurrencyId] INT NULL,
[dtmDocsToBroker] DATETIME NULL,
[strMarks] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strMarkingInstructions] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strShippingMode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intNumberOfContainers] INT NULL,
[intContainerTypeId] INT NULL,
[intBLDraftToBeSentId] INT NULL,
[strBLDraftToBeSentType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strDocPresentationType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intDocPresentationId] INT NULL,
[dtmDocsReceivedDate] DATETIME NULL,
[dtmETAPOL] DATETIME NULL,
[dtmETSPOL] DATETIME NULL,
[dtmETAPOD] DATETIME NULL,
[dtmDeadlineCargo] DATETIME NULL,
[dtmDeadlineBL] DATETIME NULL,
[dtmISFReceivedDate] DATETIME NULL,
[dtmISFFiledDate] DATETIME NULL,

[dblDemurrage] NUMERIC(18, 6) NULL,
[intDemurrageCurrencyId] INT NULL,
[dblDespatch] NUMERIC(18, 6) NULL,
[intDespatchCurrencyId] INT NULL,
[dblLoadingRate] NUMERIC(18, 6) NULL,
[intLoadingUnitMeasureId] INT NULL,
[strLoadingPerUnit] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[dblDischargeRate] NUMERIC(18, 6) NULL,
[intDischargeUnitMeasureId] INT NULL,
[strDischargePerUnit] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,

[intTransportationMode] INT NULL,
[intShipmentStatus] INT NULL,
[ysnPosted] BIT NULL, 
[dtmPostedDate] DATETIME NULL,
[intTransUsedBy] INT NULL,
[intShipmentType] INT NULL,
[intLoadShippingInstructionId]  INT NULL,

CONSTRAINT [PK_tblLGLoad] PRIMARY KEY ([intLoadId]), 
CONSTRAINT [UK_tblLGLoad_intLoadNumber_intPurchaseSale] UNIQUE ([strLoadNumber],[intPurchaseSale]),
CONSTRAINT [FK_tblLGLoad_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
CONSTRAINT [FK_tblLGLoad_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
CONSTRAINT [FK_tblLGLoad_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGLoad_tblLGEquipmentType_intEquipmentTypeId] FOREIGN KEY ([intEquipmentTypeId]) REFERENCES [tblLGEquipmentType]([intEquipmentTypeId]),
CONSTRAINT [FK_tblLGLoad_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGLoad_tblEMEntityLocation_intEntityLocationId] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),
CONSTRAINT [FK_tblLGLoad_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
CONSTRAINT [FK_tblLGLoad_tblEMEntity_intHaulerEntityId] FOREIGN KEY ([intHaulerEntityId]) REFERENCES tblEMEntity([intEntityId]),

CONSTRAINT [FK_tblLGLoad_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]), 
CONSTRAINT [FK_tblLGLoad_tblLGGenerateLoad_intGenerateLoadId] FOREIGN KEY ([intGenerateLoadId]) REFERENCES [tblLGGenerateLoad]([intGenerateLoadId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGLoad_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityUserSecurityId]),
CONSTRAINT [FK_tblLGLoad_tblEMEntity_intDriverEntityId] FOREIGN KEY ([intDriverEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGLoad_tblSMUserSecurity_intDispatcherId] FOREIGN KEY ([intDispatcherId]) REFERENCES [tblSMUserSecurity]([intEntityUserSecurityId]),
CONSTRAINT [FK_tblLGLoad_tblTRLoadHeader_intLoadHeaderId] FOREIGN KEY ([intLoadHeaderId]) REFERENCES [tblTRLoadHeader]([intLoadHeaderId]),

CONSTRAINT [FK_tblLGLoad_tblICUnitMeasure_intWeightUnitMeasureId_intUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGLoad_tblEMEntity_intTerminalEntityId] FOREIGN KEY ([intTerminalEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGLoad_tblEMEntity_intShippingLineEntityId_intEntityId] FOREIGN KEY ([intShippingLineEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGLoad_tblEMEntity_intForwardingAgentEntityId_intEntityId] FOREIGN KEY ([intForwardingAgentEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGLoad_tblSMCurrency_intInsuranceCurrencyId_intCurrencyID] FOREIGN KEY ([intInsuranceCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
CONSTRAINT [FK_tblLGLoad_tblEMEntity_intInsurerEntityId_intEntityId] FOREIGN KEY ([intInsurerEntityId]) REFERENCES tblEMEntity([intEntityId]),

CONSTRAINT [FK_tblLGLoad_tblLGContainerType_intContainerTypeId] FOREIGN KEY ([intContainerTypeId]) REFERENCES [tblLGContainerType]([intContainerTypeId]),
CONSTRAINT [FK_tblLGLoad_tblSMCurrency_intDemurrageCurrencyId_intCurrencyID] FOREIGN KEY ([intDemurrageCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
CONSTRAINT [FK_tblLGLoad_tblSMCurrency_intDespatchCurrencyId_intCurrencyID] FOREIGN KEY ([intDespatchCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
CONSTRAINT [FK_tblLGLoad_tblICUnitMeasure_intLoadingUnitMeasureId_intUnitMeasureId] FOREIGN KEY ([intLoadingUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGLoad_tblICUnitMeasure_intDischargeUnitMeasureId_intUnitMeasureId] FOREIGN KEY ([intDischargeUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
