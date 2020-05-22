CREATE TABLE [dbo].[tblLGLoad]
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
[strBookingReference] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intEquipmentTypeId] INT NULL,
[intEntityId] INT NULL,
[intEntityLocationId] INT NULL,
[intContractDetailId] INT NULL,
[strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
[strBOLInstructions] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
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

[strCarNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strEmbargoNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strEmbargoPermitNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,

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
[strFreightInfo] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strPackingDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strMVessel] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strMVoyageNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strFVessel] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strFVoyageNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strIMONumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intForwardingAgentEntityId] INT NULL,
[strForwardingAgentRef] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intInsurerEntityId] INT NULL,
[strInsurancePolicyRefNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[dblInsuranceValue] NUMERIC(18, 6) NULL,
[dblInsurancePremiumPercentage] NUMERIC(18, 6) NULL,
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
[dtmStuffingDate] DATETIME NULL,
[dtmStartDate] DATETIME NULL,
[dtmEndDate] DATETIME NULL,
[dtmPlannedAvailabilityDate] DATETIME NULL,
[ysnArrivedInPort] [bit] NULL,
[ysnDocumentsApproved] [bit] NULL,
[ysnCustomsReleased] [bit] NULL,
[dtmArrivedInPort] DATETIME NULL,
[dtmDocumentsApproved] DATETIME NULL,
[dtmCustomsReleased] DATETIME NULL,

[strVessel1] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strOriginPort1] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strDestinationPort1] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[dtmETSPOL1] DATETIME NULL,
[dtmETAPOD1] DATETIME NULL,
[strVessel2] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strOriginPort2] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strDestinationPort2] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[dtmETSPOL2] DATETIME NULL,
[dtmETAPOD2] DATETIME NULL,
[strVessel3] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strOriginPort3] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strDestinationPort3] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[dtmETSPOL3] DATETIME NULL,
[dtmETAPOD3] DATETIME NULL,
[strVessel4] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strOriginPort4] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[strDestinationPort4] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
[dtmETSPOL4] DATETIME NULL,
[dtmETAPOD4] DATETIME NULL,

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
[strExternalShipmentNumber]  NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,

[ysn4cRegistration] [bit] NULL,
[ysnInvoice] [bit] NULL,
[ysnProvisionalInvoice] [bit] NULL,
[strCourierTrackingNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[str4CLicenseNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strExternalERPReferenceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,

[ysnQuantityFinal] [bit] NULL,
[ysnCancelled] [bit] NULL,
[intShippingModeId] INT NULL,
[intETAPOLReasonCodeId] INT NULL,
[intETSPOLReasonCodeId] INT NULL,
[intETAPODReasonCodeId] INT NULL,
[intFreightTermId] INT NULL,
[intCurrencyId] INT NULL,
[intCreatedById] INT NULL,
[dtmCreatedOn] DATETIME NULL,
[intLastUpdateById] INT NULL,
[dtmLastUpdateOn] DATETIME NULL,
[strBatchId]  NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
[strGenerateLoadEquipmentType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strGenerateLoadHauler] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[ysnDocumentsReceived] [bit] NULL,
[ysnSubCurrency] [bit] NULL,
[intCompanyId] INT NULL,
[intBookId] INT NULL,
[intSubBookId] INT NULL,
[intLoadRefId] INT NULL,
[ysnLoadBased] BIT NULL DEFAULT ((0)),
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
CONSTRAINT [FK_tblLGLoad_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]),
CONSTRAINT [FK_tblLGLoad_tblEMEntity_intDriverEntityId] FOREIGN KEY ([intDriverEntityId]) REFERENCES tblEMEntity([intEntityId]),
CONSTRAINT [FK_tblLGLoad_tblSMUserSecurity_intDispatcherId] FOREIGN KEY ([intDispatcherId]) REFERENCES [tblSMUserSecurity]([intEntityId]),
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
CONSTRAINT [FK_tblLGLoad_tblICUnitMeasure_intDischargeUnitMeasureId_intUnitMeasureId] FOREIGN KEY ([intDischargeUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),

CONSTRAINT [FK_tblLGLoad_tblLGShippingMode_intShippingModeId_intShippingModeId] FOREIGN KEY ([intShippingModeId]) REFERENCES [tblLGShippingMode]([intShippingModeId]),
CONSTRAINT [FK_tblLGLoad_tblLGReasonCode_intETAPOLReasonCodeId_intReasonCodeId] FOREIGN KEY ([intETAPOLReasonCodeId]) REFERENCES [tblLGReasonCode]([intReasonCodeId]),
CONSTRAINT [FK_tblLGLoad_tblLGReasonCode_intETSPOLReasonCodeId_intReasonCodeId] FOREIGN KEY ([intETSPOLReasonCodeId]) REFERENCES [tblLGReasonCode]([intReasonCodeId]),
CONSTRAINT [FK_tblLGLoad_tblLGReasonCode_intETAPODReasonCodeId_intReasonCodeId] FOREIGN KEY ([intETAPODReasonCodeId]) REFERENCES [tblLGReasonCode]([intReasonCodeId]),
CONSTRAINT [FK_tblLGLoad_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
CONSTRAINT [FK_tblLGLoad_tblCTSubBook_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId])
)

go

--CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoad_207_2053178660__K97_K1_K48_K3_K44_42_45_51_52_53_54_71_72_73_78] ON [dbo].[tblLGLoad]
--(
--	[intShipmentType] ASC,
--	[intLoadId] ASC,
--	[intShippingLineEntityId] ASC,
--	[strLoadNumber] ASC,
--	[strOriginPort] ASC
--)
--INCLUDE ( 	[strBLNumber],
--	[strDestinationPort],
--	[strMVessel],
--	[strMVoyageNumber],
--	[strFVessel],
--	[strFVoyageNumber],
--	[dtmETAPOL],
--	[dtmETSPOL],
--	[dtmETAPOD],
--	[dtmStuffingDate]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
--go

--CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoad_207_2053178660__K97_K1] ON [dbo].[tblLGLoad]
--(
--	[intShipmentType] ASC,
--	[intLoadId] ASC
--)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
--go

CREATE STATISTICS [_dta_stat_2053178660_3_44] ON [dbo].[tblLGLoad]([strLoadNumber], [strOriginPort])
go

CREATE STATISTICS [_dta_stat_2053178660_1_97] ON [dbo].[tblLGLoad]([intLoadId], [intShipmentType])
go

CREATE STATISTICS [_dta_stat_2053178660_48_97] ON [dbo].[tblLGLoad]([intShippingLineEntityId], [intShipmentType])
go

CREATE STATISTICS [_dta_stat_2053178660_1_48_97_3_44] ON [dbo].[tblLGLoad]([intLoadId], [intShippingLineEntityId], [intShipmentType], [strLoadNumber], [strOriginPort])
go

CREATE NONCLUSTERED INDEX [IX_tblLGLoad_intLoadId] ON [dbo].[tblLGLoad]
(
	[intLoadId] ASC
)
INCLUDE ( 	
	[intShipmentType]
	,[intShippingLineEntityId]
	,[strLoadNumber]
	,[strOriginPort]
	,[strBLNumber]
	,[strDestinationPort]
	,[strMVessel]
	,[strMVoyageNumber]
	,[strFVessel]
	,[strFVoyageNumber]
	,[dtmETAPOL]
	,[dtmETSPOL]
	,[dtmETAPOD]
	,[dtmStuffingDate]
) 
GO

CREATE STATISTICS [_dta_stat_1172915250_94_93] ON [dbo].[tblLGLoad]([ysnPosted], [intShipmentStatus])
GO

CREATE STATISTICS [_dta_stat_1172915250_1_93] ON [dbo].[tblLGLoad]([intLoadId], [intShipmentStatus])
GO

CREATE STATISTICS [_dta_stat_1172915250_5_3_93] ON [dbo].[tblLGLoad]([intPurchaseSale], [strLoadNumber], [intShipmentStatus])
GO

CREATE STATISTICS [_dta_stat_1172915250_5_93_94] ON [dbo].[tblLGLoad]([intPurchaseSale], [intShipmentStatus], [ysnPosted])
GO

CREATE STATISTICS [_dta_stat_1172915250_3_94_93_5] ON [dbo].[tblLGLoad]([strLoadNumber], [ysnPosted], [intShipmentStatus], [intPurchaseSale])
GO

CREATE STATISTICS [_dta_stat_1172915250_1_3_94_93] ON [dbo].[tblLGLoad]([intLoadId], [strLoadNumber], [ysnPosted], [intShipmentStatus])
GO

CREATE STATISTICS [_dta_stat_1172915250_1_94_93_5_3] ON [dbo].[tblLGLoad]([intLoadId], [ysnPosted], [intShipmentStatus], [intPurchaseSale], [strLoadNumber])
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoad_197_1172915250__K5_K1] ON [dbo].[tblLGLoad]
(
	[intPurchaseSale] ASC,
	[intLoadId] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoad_197_1172915250__K1_K5] ON [dbo].[tblLGLoad]
(
	[intLoadId] ASC,
	[intPurchaseSale] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_1172915250_103_5_1] ON [dbo].[tblLGLoad]([ysnQuantityFinal], [intPurchaseSale], [intLoadId])
