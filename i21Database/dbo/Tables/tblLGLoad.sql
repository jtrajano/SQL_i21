﻿CREATE TABLE [dbo].[tblLGLoad]
(
[intLoadId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intLoadNumber] INT NOT NULL, 
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
[strScheduleInfoMsg]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
[ysnUpdateScheduleInfo] [bit] NULL,
[ysnPrintScheduleInfo] [bit] NULL,
[strLoadDirectionMsg]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
[ysnUpdateLoadDirections] [bit] NULL,
[ysnPrintLoadDirections] [bit] NULL,

CONSTRAINT [PK_tblLGLoad] PRIMARY KEY ([intLoadId]), 
CONSTRAINT [UK_tblLGLoad_intLoadNumber_intPurchaseSale] UNIQUE ([intLoadNumber],[intPurchaseSale]),
CONSTRAINT [FK_tblLGLoad_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
CONSTRAINT [FK_tblLGLoad_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
CONSTRAINT [FK_tblLGLoad_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
CONSTRAINT [FK_tblLGLoad_tblLGEquipmentType_intEquipmentTypeId] FOREIGN KEY ([intEquipmentTypeId]) REFERENCES [tblLGEquipmentType]([intEquipmentTypeId]),
CONSTRAINT [FK_tblLGLoad_tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEntity]([intEntityId]),
CONSTRAINT [FK_tblLGLoad_tblEntityLocation_intEntityLocationId] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEntityLocation]([intEntityLocationId]),
CONSTRAINT [FK_tblLGLoad_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
CONSTRAINT [FK_tblLGLoad_tblEntity_intHaulerEntityId] FOREIGN KEY ([intHaulerEntityId]) REFERENCES [tblEntity]([intEntityId]),

CONSTRAINT [FK_tblLGLoad_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]), 
CONSTRAINT [FK_tblLGLoad_tblLGGenerateLoad_intGenerateLoadId] FOREIGN KEY ([intGenerateLoadId]) REFERENCES [tblLGGenerateLoad]([intGenerateLoadId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGLoad_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityUserSecurityId]),
CONSTRAINT [FK_tblLGLoad_tblTRTransportLoad_intTransportLoadId] FOREIGN KEY ([intTransportLoadId]) REFERENCES [tblTRTransportLoad]([intTransportLoadId]),
CONSTRAINT [FK_tblLGLoad_tblEntity_intDriverEntityId] FOREIGN KEY ([intDriverEntityId]) REFERENCES [tblEntity]([intEntityId]),
CONSTRAINT [FK_tblLGLoad_tblSMUserSecurity_intDispatcherId] FOREIGN KEY ([intDispatcherId]) REFERENCES [tblSMUserSecurity]([intEntityUserSecurityId]),
CONSTRAINT [FK_tblLGLoad_tblTRLoadHeader_intLoadHeaderId] FOREIGN KEY ([intLoadHeaderId]) REFERENCES [tblTRLoadHeader]([intLoadHeaderId])
)
