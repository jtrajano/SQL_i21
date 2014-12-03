CREATE TABLE [dbo].[tblICInventoryReceipt]
(
	[intInventoryReceiptId] INT NOT NULL IDENTITY, 
    [strReceiptNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmReceiptDate] DATETIME NOT NULL, 
    [intVendorId] INT NOT NULL, 
    [strReceiptType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intSourceId] INT NULL, 
    [intBlanketRelease] INT NULL DEFAULT ((0)), 
    [intLocationId] INT NOT NULL, 
    [intWarehouseId] INT NULL, 
    [strVendorRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strBillOfLading] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intShipViaId] INT NULL, 
    [intReceiptSequenceNo] INT NULL, -- Changed to NULLable. Receipt sequence number should not be on the purchase order it is for integration with origin. Remove from screen. See http://inet.irelyserver.com/display/INV/Inventory+Receipt+%28Detail%29+Tab?focusedCommentId=37455559#comment-37455559
    [intBatchNo] INT NULL, 
    [intTermId] INT NOT NULL, 
    [intProductOrigin] INT NULL, 
    [strReceiver] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intCurrencyId] INT NOT NULL, 
    [strVessel] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strAPAccount] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strBillingStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strOrderNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intFreightTermId] INT NULL, 
    [strDeliveryPoint] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strAllocateFreight] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('No'), 
    [strFreightBilledBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('No'), 
    [intShiftNumber] INT NULL, 
    [strNotes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strCalculationBasis] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dblUnitWeightMile] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblFreightRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblFuelSurcharge] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblInvoiceAmount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnInvoicePaid] BIT NULL DEFAULT ((0)), 
    [intCheckNo] INT NULL, 
    [dteCheckDate] DATETIME NULL, 
    [intTrailerTypeId] INT NULL, 
    [dteTrailerArrivalDate] DATETIME NULL, 
    [dteTrailerArrivalTime] DATETIME NULL, 
    [strSealNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strSealStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dteReceiveTime] DATETIME NULL, 
    [dblActualTempReading] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryReceipt] PRIMARY KEY ([intInventoryReceiptId]), 
    CONSTRAINT [AK_tblICInventoryReceipt_strReceiptNumber] UNIQUE ([strReceiptNumber]), 
    CONSTRAINT [FK_tblICInventoryReceipt_tblAPVendor] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intVendorId]), 
    CONSTRAINT [FK_tblICInventoryReceipt_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICInventoryReceipt_tblSMFreightTerm] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]), 
    CONSTRAINT [FK_tblICInventoryReceipt_tblSMShipVia] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia]([intShipViaID]), 
    CONSTRAINT [FK_tblICInventoryReceipt_tblSMTerm] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID]), 
    CONSTRAINT [FK_tblICInventoryReceipt_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryReceiptId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receipt Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strReceiptNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receipt Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'dtmReceiptDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intVendorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receipt Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strReceiptType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Source Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intSourceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Blanket Release',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intBlanketRelease'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Warehouse Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intWarehouseId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor Reference Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strVendorRefNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bill of Lading Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strBillOfLading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ship Via Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intShipViaId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receipt Sequence Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intReceiptSequenceNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Batch Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intBatchNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Term Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intTermId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Product Origin',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intProductOrigin'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receiver',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strReceiver'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Currency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intCurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vessel',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strVessel'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'AP Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strAPAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Billing Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strBillingStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Order Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strOrderNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Terms',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intFreightTermId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Point',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strDeliveryPoint'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Point',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strAllocateFreight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Billed By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strFreightBilledBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shift Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intShiftNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Notes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strNotes'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Basis',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationBasis'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Units / Weight / Miles',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitWeightMile'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'dblFreightRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fuel Surcharge Percentage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'dblFuelSurcharge'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'dblInvoiceAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Paid',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'ysnInvoicePaid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Check No',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intCheckNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Check Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'dteCheckDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Trailer Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intTrailerTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Trailer Arrival Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'dteTrailerArrivalDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Trailer Arrival Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'dteTrailerArrivalTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Seal No',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strSealNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Seal Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'strSealStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receive Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'dteReceiveTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Actual Temp Reading (Fahrenheit)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'dblActualTempReading'