CREATE TABLE [dbo].[tblSCTicket]
(
	[intTicketId] INT NOT NULL IDENTITY, 
    [strTicketStatus] NVARCHAR COLLATE Latin1_General_CI_AS NOT NULL, 
    [intTicketNumber] INT NOT NULL, 
    [intScaleSetupId] INT NOT NULL, 
	[intTicketPoolId] INT NOT NULL,
    [intTicketLocationId] INT NOT NULL, 
    [intTicketType] INT NOT NULL, 
    [strInOutFlag] NVARCHAR COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmTicketDateTime] DATETIME NULL, 
    [dtmTicketTransferDateTime] DATETIME NULL, 
    [dtmTicketVoidDateTime] DATETIME NULL, 
    [intProcessingLocationId] INT NULL, 
    [strScaleOperatorUser] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intScaleOperatorId] INT NOT NULL, 
    [strPurchaseOrderNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [strTruckName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
    [strDriverName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
    [ysnDriverOff] BIT NULL, 
    [ysnSplitWeightTicket] BIT NULL, 
    [ysnGrossManual] BIT NULL, 
    [dblGrossWeight] DECIMAL(13, 3) NULL, 
    [dblGrossWeightOriginal] DECIMAL(13, 3) NULL, 
    [dblGrossWeightSplit1] DECIMAL(13, 3) NULL, 
    [dblGrossWeightSplit2] DECIMAL(13, 3) NULL, 
    [dtmGrossDateTime] DATETIME NULL, 
    [intGrossUserId] INT NULL, 
    [ysnTareManual] BIT NULL, 
    [dblTareWeight] DECIMAL(13, 3) NULL, 
    [dblTareWeightOriginal] DECIMAL(13, 3) NULL, 
    [dblTareWeightSplit1] DECIMAL(13, 3) NULL, 
    [dblTareWeightSplit2] DECIMAL(13, 3) NULL, 
    [dtmTareDateTime] DATETIME NULL, 
    [intTareUserId] INT NULL, 
    [dblGrossUnits] DECIMAL(13, 3) NULL, 
    [dblNetUnits] DECIMAL(13, 3) NULL, 
    [strItemNumber] NVARCHAR(13) COLLATE Latin1_General_CI_AS NULL, 
    [intCustomerId] INT NULL, 
    [intSplitId] INT NULL, 
    [intDistributionOption] INT NULL, 
    [intDiscountSchedule] INT NULL, 
    [strDiscountLocation] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL, 
    [dtmDeferDate] DATETIME NULL, 
    [strContractNumber] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [intContractSequence] INT NULL, 
    [strContractLocation] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL, 
    [dblUnitPrice] DECIMAL(9, 5) NULL, 
    [dblUnitBasis] DECIMAL(9, 5) NULL, 
    [dblTicketFees] DECIMAL(7, 2) NULL, 
    [intCurrencyId] INT NULL, 
    [dblCurrencyRate] DECIMAL(15, 8) NULL, 
    [strTicketComment] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL, 
    [strCustomerReference] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [ysnTicketPrinted] BIT NULL, 
    [ysnPlantTicketPrinted] BIT NULL, 
    [ysnGradingTagPrinted] BIT NULL, 
    [intFreightCarrierId] INT NULL, 
    [dblFreightRate] DECIMAL(9, 5) NULL, 
    [dblFreightAdjustment] DECIMAL(7, 2) NULL, 
    [intFreightCurrencyId] INT NULL, 
    [dblFreightCurrencyRate] DECIMAL(15, 8) NULL, 
    [strFreightCContractNumber] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [ysnFarmerPaysFreight] BIT NULL, 
    [strLoadNumber] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [intLoadLocationId] INT NULL, 
    [intAxleCount] INT NULL, 
    [strBinNumber] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
    [strPitNumber] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
    [intGradingFactor] INT NULL, 
    [strVarietyType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [strFarmNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [strFieldNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[strDiscountComment] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
	[intCommodityId] INT NULL,
	[intDiscountId] INT NULL,
	[intContractId] INT NULL,
    [intDiscountLocationId] INT NULL,
	[intItemId] INT NULL,
	[intEntityId] INT NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSCTicket_intTicketId] PRIMARY KEY ([intTicketId]), 
    CONSTRAINT [UK_tblSCTicket_intTicketPoolId_intTicketNumber] UNIQUE ([intTicketPoolId], [intTicketType], [strInOutFlag], [intTicketNumber]),
	CONSTRAINT [FK_tblSCScaleSetup_tblSMCompanyLocation_intTicketLocationId] FOREIGN KEY ([intTicketLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblSCScaleSetup_tblSMCompanyLocation_intProcessingLocationId] FOREIGN KEY ([intProcessingLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblSCTicket_tblSCTicketPool_intTicketPoolId] FOREIGN KEY ([intTicketPoolId]) REFERENCES [tblSCTicketPool]([intTicketPoolId]), 
    CONSTRAINT [FK_tblSCTicket_tblSCScaleSetup_intScaleSetupId] FOREIGN KEY ([intScaleSetupId]) REFERENCES [tblSCScaleSetup]([intScaleSetupId]), 
    CONSTRAINT [FK_tblSCTicket_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblSCTicket_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
    CONSTRAINT [FK_tblSCTicket_tblGRDiscountId_intDiscountId] FOREIGN KEY ([intDiscountId]) REFERENCES [tblGRDiscountId]([intDiscountId]),
	CONSTRAINT [FK_tblSCTicket_tblSMCompanyLocation_intDiscountLocationId] FOREIGN KEY ([intDiscountLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblSCTicket_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblSCTicket_tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEntity]([intEntityId])
)

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
    @level2name = N'intTicketNumber'
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
    @level2name = N'intScaleOperatorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purchase Order Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strPurchaseOrderNumber'
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
    @value = N'Item Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strItemNumber'
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
    @level2name = 'intDistributionOption'
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
    @value = N'Bin Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strBinNumber'
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
    @value = N'Commodity Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicket',
    @level2type = N'COLUMN',
    @level2name = N'strCommodityCode'
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