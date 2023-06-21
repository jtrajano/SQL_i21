﻿CREATE TABLE [dbo].[tblSCTicket]
(
	[intTicketId] INT IDENTITY (1, 1) NOT NULL , 
    [strTicketStatus] NVARCHAR COLLATE Latin1_General_CI_AS NOT NULL, 
    [strTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strOriginalTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '', 
    [intScaleSetupId] INT NOT NULL, 
	[intTicketPoolId] INT NOT NULL,
    [intTicketLocationId] INT NOT NULL, 
    [intTicketType] INT NOT NULL, 
    [strInOutFlag] NVARCHAR COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmTicketDateTime] DATETIME NULL, 
    [dtmTicketTransferDateTime] DATETIME NULL, 
    [dtmTicketVoidDateTime] DATETIME NULL, 
	[dtmTransactionDateTime] DATETIME NULL DEFAULT GETDATE(), 
    [intProcessingLocationId] INT NULL, 
	[intTransferLocationId] INT NULL,
    [strScaleOperatorUser] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intEntityScaleOperatorId] INT NULL, 
    [strTruckName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
    [strDriverName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
    [ysnDriverOff] BIT NULL, 
    [ysnSplitWeightTicket] BIT NULL, 
    [ysnGrossManual] BIT NULL, 
    [ysnGross1Manual] BIT NULL, 
    [ysnGross2Manual] BIT NULL, 
    [dblGrossWeight] DECIMAL(13, 3) NULL, 
    [dblGrossWeight1] DECIMAL(13, 3) NULL, 
    [dblGrossWeight2] DECIMAL(13, 3) NULL, 
    [dblGrossWeightOriginal] DECIMAL(13, 3) NULL, 
    [dblGrossWeightSplit1] DECIMAL(13, 3) NULL, 
    [dblGrossWeightSplit2] DECIMAL(13, 3) NULL, 
    [dtmGrossDateTime] DATETIME NULL, 
    [dtmGrossDateTime1] DATETIME NULL, 
    [dtmGrossDateTime2] DATETIME NULL, 
    [intGrossUserId] INT NULL, 
    [ysnTareManual] BIT NULL, 
    [ysnTare1Manual] BIT NULL, 
    [ysnTare2Manual] BIT NULL, 
    [dblTareWeight] DECIMAL(13, 3) NULL, 
    [dblTareWeight1] DECIMAL(13, 3) NULL, 
    [dblTareWeight2] DECIMAL(13, 3) NULL, 
    [dblTareWeightOriginal] DECIMAL(13, 3) NULL, 
    [dblTareWeightSplit1] DECIMAL(13, 3) NULL, 
    [dblTareWeightSplit2] DECIMAL(13, 3) NULL, 
    [dtmTareDateTime] DATETIME NULL, 
    [dtmTareDateTime1] DATETIME NULL, 
    [dtmTareDateTime2] DATETIME NULL, 
    [intTareUserId] INT NULL, 
    [dblGrossUnits] NUMERIC(38, 20) NULL, 
	[dblShrink] NUMERIC(38, 20) NULL,
    [dblNetUnits] NUMERIC(38, 20) NULL, 
	[strItemUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intCustomerId] INT NULL, 
    [intSplitId] INT NULL, 
    [strDistributionOption] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [intDiscountSchedule] INT NULL, 
    [strDiscountLocation] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL, 
    [dtmDeferDate] DATETIME NULL, 
    [strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intContractSequence] INT NULL, 
    [strContractLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblUnitPrice] NUMERIC(38, 20) NULL, 
    [dblUnitBasis] NUMERIC(38, 20) NULL, 
    [dblTicketFees] NUMERIC(38, 20) NULL, 
    [intCurrencyId] INT NULL, 
    [dblCurrencyRate] NUMERIC(38, 20) NULL, 
    [strTicketComment] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL, 
    [strCustomerReference] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [ysnTicketPrinted] BIT NULL, 
    [ysnPlantTicketPrinted] BIT NULL, 
    [ysnGradingTagPrinted] BIT NULL, 
	[intHaulerId] INT NULL, 
    [intFreightCarrierId] INT NULL, 
    [dblFreightRate] NUMERIC(38, 20) NULL, 
    [dblFreightAdjustment] DECIMAL(7, 2) NULL, 
    [intFreightCurrencyId] INT NULL, 
    [dblFreightCurrencyRate] NUMERIC(38, 20) NULL, 
    [strFreightCContractNumber] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [ysnFarmerPaysFreight] BIT NULL, 
    [ysnCusVenPaysFees] BIT NOT NULL, 
    [strLoadNumber] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [intLoadLocationId] INT NULL, 
    [intAxleCount] INT NULL, 
    [intAxleCount1] INT NULL, 
    [intAxleCount2] INT NULL, 
    [strPitNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intGradingFactor] INT NULL, 
    [strVarietyType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [strFarmNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [strFieldNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[strDiscountComment] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[intCommodityId] INT NULL,
	[intDiscountId] INT NULL,
	[intContractId] INT NULL,
	[intContractCostId] INT NULL,
    [intDiscountLocationId] INT NULL,
	[intItemId] INT NULL,
	[intEntityId] INT NULL,
	[intLoadId] INT NULL,
	[intMatchTicketId] INT NULL,
	[intSubLocationId] INT NULL,
	[intStorageLocationId] INT NULL,
	[intSubLocationToId] INT NULL,
	[intStorageLocationToId] INT NULL,
	[intFarmFieldId] INT NULL,
	[intDistributionMethod] INT NULL, 
	[intSplitInvoiceOption] INT NULL, 
	[intDriverEntityId] INT NULL,
	[intStorageScheduleId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT((1)),  
	[dblNetWeightDestination] NUMERIC(38, 20) NULL, 
    [ysnHasGeneratedTicketNumber] BIT NULL, 
    [intInventoryTransferId] INT NULL, 
    [intInventoryReceiptId] INT NULL, 
    [intInventoryShipmentId] INT NULL, 
    [intInventoryAdjustmentId] INT NULL, 
	[dblScheduleQty] DECIMAL(13, 6) NULL,
	[dblConvertedUOMQty] NUMERIC(38, 20) NULL,
	[dblContractCostConvertedUOM] NUMERIC(38, 20) NULL,
	[intItemUOMIdFrom] INT NULL, 
	[intItemUOMIdTo] INT NULL,
	[intTicketTypeId] INT NULL,
	[intStorageScheduleTypeId] INT NULL,
	[strFreightSettlement]  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCostMethod]  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intGradeId] INT NULL,
	[intWeightId] INT NULL,
	[intDeliverySheetId] INT NULL,
	[intCommodityAttributeId] INT NULL,
	[strElevatorReceiptNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnRailCar] BIT DEFAULT 0 NOT NULL,
    [ysnDeliverySheetPost] BIT NOT NULL DEFAULT 0, 
    [intLotId] INT NULL, 
    [strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT '',
	[intSalesOrderId] INT NULL, 
	[intTicketLVStagingId] INT NULL, 
	[intBillId] INT NULL,
	[intInvoiceId] INT NULL,
	[intCompanyId] INT NULL,
	[intEntityContactId] INT NULL,
	[strPlateNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[blbPlateNumber] VARBINARY(MAX) NULL,
	[ysnDestinationWeightGradePost] BIT NOT NULL DEFAULT 0, 
	[strSourceType] NVARCHAR (15) COLLATE Latin1_General_CI_AS NULL,
	[ysnReadyToTransfer] BIT NOT NULL DEFAULT 0, 
	[ysnExport] BIT NOT NULL DEFAULT 0, 
	[dtmImportedDate] DATETIME NULL, 
    [strUberStatusCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
    [intEntityShipViaTrailerId] INT NULL, 
    [intLoadDetailId] INT NULL, 
    [intCropYearId] INT NULL, 
    [ysnHasSpecialDiscount] BIT NOT NULL DEFAULT 0, 
    [ysnSpecialGradePosted] BIT NOT NULL DEFAULT 0, 
	[intItemContractDetailId] INT NULL,
    [ysnCertOfAnalysisPosted] BIT NOT NULL DEFAULT 0,
    [ysnExportRailXML] BIT NOT NULL DEFAULT 0,
    [strTrailerId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intTransferWeight] INT NOT NULL DEFAULT 1, 
    [intAGWorkOrderId] INT NULL, 
    [ysnMultipleTicket] BIT NOT NULL DEFAULT 0,
    [strGrainReceiptNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intShipToLocationId] INT NULL, 
    [dblDWGOriginalNetUnits] NUMERIC(38, 20) NULL, 
	[dtmDateCreatedUtc] DATETIME2 NULL,
	[dtmDateModifiedUtc] DATETIME2 NULL,
	[dtmDateLastUpdatedUtc] AS COALESCE(dtmDateModifiedUtc, dtmDateCreatedUtc),
    [dblDWGSpotPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [intFreightCostUOMId] INT NULL, 
    [ysnApplyOverageToSpot] BIT NOT NULL DEFAULT 0,
    [intDecimalAdjustment] INT NOT NULL DEFAULT 4, 
    [ysnFixRounding] BIT NOT NULL DEFAULT 1, 
    [ysnTicketInTransit] BIT NOT NULL DEFAULT 0, 
    [ysnTicketApplied] BIT NOT NULL DEFAULT 0, 
    [dblInTransitQuantity] NUMERIC(38, 20) NOT NULL DEFAULT 0, 

    [intOverrideFreightItemId] INT NULL, 


    CONSTRAINT [PK_tblSCTicket_intTicketId] PRIMARY KEY CLUSTERED ([intTicketId] ASC),
    CONSTRAINT [UK_tblSCTicket_intTicketPoolId_strTicketNumber] UNIQUE ([intTicketPoolId], [intTicketType], [strInOutFlag], [strTicketNumber],[intEntityId],[intProcessingLocationId]),
	CONSTRAINT [FK_tblSCScaleSetup_tblSMCompanyLocation_intTicketLocationId] FOREIGN KEY ([intTicketLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblSCScaleSetup_tblSMCompanyLocation_intProcessingLocationId] FOREIGN KEY ([intProcessingLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblSCTicket_tblSCTicketPool_intTicketPoolId] FOREIGN KEY ([intTicketPoolId]) REFERENCES [tblSCTicketPool]([intTicketPoolId]), 
    CONSTRAINT [FK_tblSCTicket_tblSCScaleSetup_intScaleSetupId] FOREIGN KEY ([intScaleSetupId]) REFERENCES [tblSCScaleSetup]([intScaleSetupId]), 
    CONSTRAINT [FK_tblSCTicket_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblSCTicket_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
    CONSTRAINT [FK_tblSCTicket_tblGRDiscountId_intDiscountId] FOREIGN KEY ([intDiscountId]) REFERENCES [tblGRDiscountId]([intDiscountId]),
	CONSTRAINT [FK_tblSCTicket_tblSMCompanyLocation_intDiscountLocationId] FOREIGN KEY ([intDiscountLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblSCTicket_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblSCTicket_tblICItem_intOverrideFreightItemId] FOREIGN KEY ([intOverrideFreightItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblSCTicket_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblSCTicket_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]),
	CONSTRAINT [FK_tblSCTicket_tblCTContractDetail_intContractId] FOREIGN KEY ([intContractId]) REFERENCES [tblCTContractDetail],
	CONSTRAINT [FK_tblSCTicket_tblSMCompanyLocationSubLocation_intSubLocationId] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation],
	CONSTRAINT [FK_tblSCTicket_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation],
	CONSTRAINT [FK_tblSCTicket_intMatchTicketId] FOREIGN KEY ([intMatchTicketId]) REFERENCES [tblSCTicket],
	CONSTRAINT [FK_tblSCTicket_tblEMEntity_intDriverEntityId] FOREIGN KEY ([intDriverEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblSCTicket_tblGRStorageScheduleRule_intStorageScheduleId] FOREIGN KEY ([intStorageScheduleId]) REFERENCES [dbo].[tblGRStorageScheduleRule] ([intStorageScheduleRuleId]),
	CONSTRAINT [FK_tblSCTicket_tblICItemUOM_intItemUOMIdFrom] FOREIGN KEY (intItemUOMIdFrom) REFERENCES [tblICItemUOM](intItemUOMId),
	CONSTRAINT [FK_tblSCTicket_tblICItemUOM_intItemUOMIdTo] FOREIGN KEY (intItemUOMIdTo) REFERENCES [tblICItemUOM](intItemUOMId),
	CONSTRAINT [FK_tblSCTicket_tblSCListTicketTypes_intTicketTypeId] FOREIGN KEY (intTicketTypeId) REFERENCES [tblSCListTicketTypes](intTicketTypeId),
	CONSTRAINT [FK_tblSCTicket_tblSCDeliverySheet_intDeliverySheetId] FOREIGN KEY (intDeliverySheetId) REFERENCES [tblSCDeliverySheet](intDeliverySheetId),
	CONSTRAINT [FK_tblSCTicket_tblICCommodityAttribute_intCommodityAttributeId] FOREIGN KEY (intCommodityAttributeId) REFERENCES [tblICCommodityAttribute](intCommodityAttributeId),
	CONSTRAINT [FK_tblSCTicket_tblICLot_intLotId] FOREIGN KEY (intLotId) REFERENCES [tblICLot](intLotId),
	CONSTRAINT [FK_tblSCTicket_tblAPBill_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [tblAPBill]([intBillId]),
	CONSTRAINT [FK_tblSCTicket_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [tblARInvoice]([intInvoiceId]),
	CONSTRAINT [FK_tblSCTicket_tblSOSalesOrder_intSalesOrderId] FOREIGN KEY ([intSalesOrderId]) REFERENCES [tblSOSalesOrder],
    CONSTRAINT [FK_tblSCTicket_tblEMEntitySplit_intSplitId] FOREIGN KEY ([intSplitId]) REFERENCES [dbo].[tblEMEntitySplit] ([intSplitId]),
	CONSTRAINT [FK_tblSCTicket_tblSMShipViaTrailer_intEntityShipViaTrailerId]FOREIGN KEY ([intEntityShipViaTrailerId]) REFERENCES [dbo].[tblSMShipViaTrailer] ([intEntityShipViaTrailerId])
)
GO
CREATE NONCLUSTERED INDEX [IX_tblSCTicket_intDeliverySheetId] ON [dbo].[tblSCTicket](
	[intDeliverySheetId] ASC
);
GO
CREATE NONCLUSTERED INDEX [IX_tblSCTicket_intDeliverySheetId_strTicketStatus] ON [dbo].[tblSCTicket]([strTicketStatus]) INCLUDE([intDeliverySheetId]);
GO
CREATE NONCLUSTERED INDEX [IX_tblSCTicket_strTicketStatus]
	ON [dbo].[tblSCTicket] ([strTicketStatus],[strDistributionOption])
	INCLUDE ([strTicketNumber],[strInOutFlag],[dtmTicketDateTime],[intProcessingLocationId],[strTruckName],[strDriverName],[dblNetUnits],[strCustomerReference],[intItemId],[intEntityId],[intDeliverySheetId])

GO
CREATE NONCLUSTERED INDEX [IX_tblSCTicket_dtmTicketDateTime] ON [dbo].[tblSCTicket](
	[dtmTicketDateTime] ASC
);
GO
CREATE NONCLUSTERED INDEX [IX_tblSCTicket_6_2143072608__K2_K1_K99_K93_K14_K15_K91_K150_K134_K98_K149_K94_K126_K125_K71_K108_3_4_5_6_7_8_9_10_11_] ON [dbo].[tblSCTicket]
(
	[strTicketStatus] ASC,
	[intTicketId] ASC,
	[intMatchTicketId] ASC,
	[intContractId] ASC,
	[intProcessingLocationId] ASC,
	[intTransferLocationId] ASC,
	[intCommodityId] ASC,
	[intCropYearId] ASC,
	[intSalesOrderId] ASC,
	[intLoadId] ASC,
	[intLoadDetailId] ASC,
	[intContractCostId] ASC,
	[intWeightId] ASC,
	[intGradeId] ASC,
	[intHaulerId] ASC,
	[intStorageScheduleId] ASC
)
INCLUDE([strTicketNumber],[strOriginalTicketNumber],[intScaleSetupId],[intTicketPoolId],[intTicketLocationId],[intTicketType],[strInOutFlag],[dtmTicketDateTime],[dtmTicketTransferDateTime],[dtmTicketVoidDateTime],[strScaleOperatorUser],[intEntityScaleOperatorId],[strTruckName],[strDriverName],[ysnDriverOff],[ysnSplitWeightTicket],[ysnGrossManual],[ysnGross1Manual],[ysnGross2Manual],[dblGrossWeight],[dblGrossWeight1],[dblGrossWeight2],[dblGrossWeightOriginal],[dblGrossWeightSplit1],[dblGrossWeightSplit2],[dtmGrossDateTime],[dtmGrossDateTime1],[dtmGrossDateTime2],[intGrossUserId],[ysnTareManual],[ysnTare1Manual],[ysnTare2Manual],[dblTareWeight],[dblTareWeight1],[dblTareWeight2],[dblTareWeightOriginal],[dblTareWeightSplit1],[dblTareWeightSplit2],[dtmTareDateTime],[dtmTareDateTime1],[dtmTareDateTime2],[intTareUserId],[dblGrossUnits],[dblShrink],[dblNetUnits],[strItemUOM],[intCustomerId],[intSplitId],[strDistributionOption],[intDiscountSchedule],[strDiscountLocation],[dtmDeferDate],[strContractNumber],[intContractSequence],[strContractLocation],[dblUnitPrice],[dblUnitBasis],[dblTicketFees],[intCurrencyId],[dblCurrencyRate],[strTicketComment],[strCustomerReference],[ysnTicketPrinted],[ysnPlantTicketPrinted],[ysnGradingTagPrinted],[intFreightCarrierId],[dblFreightRate],[dblFreightAdjustment],[intFreightCurrencyId],[dblFreightCurrencyRate],[strFreightCContractNumber],[ysnFarmerPaysFreight],[ysnCusVenPaysFees],[strLoadNumber],[intLoadLocationId],[intAxleCount],[intAxleCount1],[intAxleCount2],[strPitNumber],[intGradingFactor],[strVarietyType],[strFarmNumber],[strFieldNumber],[strDiscountComment],[intDiscountId],[intDiscountLocationId],[intItemId],[intEntityId],[intSubLocationId],[intStorageLocationId],[intSubLocationToId],[intStorageLocationToId],[intFarmFieldId],[intDistributionMethod],[intSplitInvoiceOption],[intDriverEntityId],[intConcurrencyId],[dblNetWeightDestination],[ysnHasGeneratedTicketNumber],[dblScheduleQty],[dblConvertedUOMQty],[dblContractCostConvertedUOM],[intItemUOMIdFrom],[intItemUOMIdTo],[intTicketTypeId],[intStorageScheduleTypeId],[strFreightSettlement],[strCostMethod],[intDeliverySheetId],[intCommodityAttributeId],[strElevatorReceiptNumber],[ysnRailCar],[ysnDeliverySheetPost],[intLotId],[strLotNumber],[strPlateNumber],[blbPlateNumber],[ysnDestinationWeightGradePost],[ysnReadyToTransfer],[ysnExport],[ysnHasSpecialDiscount],[ysnSpecialGradePosted],[intItemContractDetailId],[ysnCertOfAnalysisPosted],[ysnExportRailXML],[strTrailerId],[intTransferWeight])
GO

CREATE NONCLUSTERED INDEX [IX_tblSCTicket_intLoadDetailId]
ON [dbo].[tblSCTicket] ([intLoadDetailId])
GO

CREATE NONCLUSTERED INDEX [IX_tblSCTicket_intInvoiceId]
ON [dbo].[tblSCTicket] ([intInvoiceId])
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strTicketStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = 'strTicketNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Setup ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intScaleSetupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = 'intTicketType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'In Out Flag',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strInOutFlag'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Date and Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmTicketDateTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Transfer Date and Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmTicketTransferDateTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Void Date and Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmTicketVoidDateTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Operator',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strScaleOperatorUser'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Processing Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intProcessingLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Operator ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intEntityScaleOperatorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Truck Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strTruckName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Driver Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strDriverName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Driver On/Off',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'ysnDriverOff'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Split Weight Ticket',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'ysnSplitWeightTicket'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manual Gross Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'ysnGrossManual'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblGrossWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Original Gross Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblGrossWeightOriginal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross Weight Split 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblGrossWeightSplit1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross Weight Split 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblGrossWeightSplit2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross Date and Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmGrossDateTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross User Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intGrossUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manual Tare Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'ysnTareManual'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tare Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblTareWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Original Tare Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblTareWeightOriginal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tare Weight Split 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblTareWeightSplit1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tare Weight Split 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblTareWeightSplit2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tare Date and Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmTareDateTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tare User Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTareUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross Units',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblGrossUnits'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Net Units',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblNetUnits'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Split Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = 'intSplitId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Distribution Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = 'strDistributionOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Schedule',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountSchedule'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = 'strDiscountLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Defer Data and Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmDeferDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strContractNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = 'strContractLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract Sequence',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intContractSequence'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Basis',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitBasis'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Fees',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblTicketFees'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Currency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = 'intCurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Currency Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblCurrencyRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Comment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strTicketComment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Reference',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strCustomerReference'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Printed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'ysnTicketPrinted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Plant Ticket Printed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'ysnPlantTicketPrinted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grading Tag Printed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'ysnGradingTagPrinted'
	GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Carrier Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intHaulerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Carrier Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intFreightCarrierId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblFreightRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Adjustment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblFreightAdjustment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Currency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intFreightCurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Currency Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblFreightCurrencyRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Contract Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strFreightCContractNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Farmer Pays Freight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'ysnFarmerPaysFreight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Load Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strLoadNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Load Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intLoadLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Axle Count',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = 'intAxleCount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pit Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strPitNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grading Factor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intGradingFactor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Variety Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strVarietyType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Farm Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strFarmNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Field Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strFieldNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Pool ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketPoolId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Comment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strDiscountComment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commodity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ContractId',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intContractId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Load Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intLoadId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Match Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intMatchTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sub Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intSubLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intStorageLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Farm Field Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intFarmFieldId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Distribution Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intDistributionMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Split Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intSplitInvoiceOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Driver Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intDriverEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Schedule Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intStorageScheduleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Item UOM Id From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intItemUOMIdFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Item UOM Id To',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intItemUOMIdTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Settlement',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strFreightSettlement'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Settlement Cost Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strCostMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight converted units in contract cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblContractCostConvertedUOM'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract cost id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intContractCostId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Sheet Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intDeliverySheetId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commodity Grade Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityAttributeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Canadian Combined+Primary Elevator Receipt',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strElevatorReceiptNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rail Car',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'ysnRailCar'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Flag for delivery sheet posted',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'ysnDeliverySheetPost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Driver entity id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'intEntityContactId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Plate number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strPlateNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Plate number image',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'blbPlateNumber'
GO

	
