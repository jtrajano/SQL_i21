/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryReceipt]
	(
		[intInventoryReceiptId] [int] IDENTITY NOT NULL,
		[strReceiptType] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
		[intSourceType] INT NOT NULL DEFAULT ((0)),
		[intEntityVendorId] [int] NULL,
		[intTransferorId] [int] NULL,
		[intLocationId] [int] NULL,
		[strReceiptNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
		[dtmReceiptDate] [datetime] NOT NULL DEFAULT (getdate()),
		[intCurrencyId] [int] NULL,
		[intSubCurrencyCents] [int] NULL,
		[intBlanketRelease] [int] NULL,
		[strVendorRefNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[strBillOfLading] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[intShipViaId] [int] NULL,
		[intShipFromEntityId] [int] NULL, 
		[intShipFromId] [int] NULL,
		[intReceiverId] [int] NULL,
		[strVessel] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[intFreightTermId] [int] NULL,
		[intShiftNumber] [int] NULL,
		[dblInvoiceAmount] [numeric](18, 6) NULL DEFAULT ((0)),
		[ysnPrepaid] [bit] NULL DEFAULT ((0)),
		[ysnInvoicePaid] [bit] NULL DEFAULT ((0)),
		[intCheckNo] [int] NULL,
		[dtmCheckDate] [datetime] NULL,
		[intTrailerTypeId] [int] NULL,
		[dtmTrailerArrivalDate] [datetime] NULL,
		[dtmTrailerArrivalTime] [datetime] NULL,
		[strSealNo] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[strSealStatus] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[dtmReceiveTime] [datetime] NULL,
		[dblActualTempReading] [numeric](18, 6) NULL DEFAULT ((0)),
		[intShipmentId] INT NULL,
		[intTaxGroupId] INT NULL,
		[ysnPosted] [bit] NULL DEFAULT ((0)),
		[ysnCostOutdated] [bit] NULL DEFAULT ((0)),
		[intCreatedUserId] [int] NULL,
		[intEntityId] [int] NULL,
		[intConcurrencyId] [int] NULL DEFAULT ((0)),
		[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[strReceiptOriginId] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
		[strWarehouseRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[ysnOrigin] BIT NULL, 
		[intSourceInventoryReceiptId] [int] NULL,
		[dtmCreated] DATETIME NULL DEFAULT (GETDATE()),
		[dtmLastFreeWhseDate] DATETIME NULL,
		[intCompanyId] INT NULL, 
		[intBookId] INT NULL, 
		[intSubBookId] INT NULL, 
		[dblSubTotal] NUMERIC(38, 15) NOT NULL DEFAULT(0),
		[dblGrandTotal] NUMERIC(38, 15) NOT NULL DEFAULT(0),
		[dblTotalGross] NUMERIC(38, 15) NOT NULL DEFAULT(0),
		[dblTotalNet] NUMERIC(38, 15) NOT NULL DEFAULT(0),
		[dblTotalTax] NUMERIC(38, 15) NOT NULL DEFAULT(0),
		[dblTotalCharges] NUMERIC(38, 15) NOT NULL DEFAULT(0),
		[dtmLastCalculateTotals] DATETIME NULL,
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL,
		[strDataSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[strInternalComments] NVARCHAR(2000) COLLATE Latin1_General_CI_AS NULL,
		CONSTRAINT [PK_tblICInventoryReceipt] PRIMARY KEY ([intInventoryReceiptId]), 
		CONSTRAINT [AK_tblICInventoryReceipt_strReceiptNumber] UNIQUE ([strReceiptNumber]), 
		CONSTRAINT [FK_tblICInventoryReceipt_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]), 
		CONSTRAINT [FK_tblICInventoryReceipt_ShipFromEntity] FOREIGN KEY ([intShipFromEntityId]) REFERENCES [tblAPVendor]([intEntityId]), 
		CONSTRAINT [FK_tblICInventoryReceipt_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
		CONSTRAINT [FK_tblICInventoryReceipt_Transferor] FOREIGN KEY ([intTransferorId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
		CONSTRAINT [FK_tblICInventoryReceipt_tblSMFreightTerm] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]), 
		CONSTRAINT [FK_tblICInventoryReceipt_tblSMShipVia] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia]([intEntityId]), 
		CONSTRAINT [FK_tblICInventoryReceipt_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
		CONSTRAINT [FK_tblICInventoryReceipt_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]), 
		CONSTRAINT [FK_tblICInventoryReceipt_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceipt_intInventoryReceiptId]
		ON [dbo].[tblICInventoryReceipt]([intInventoryReceiptId] ASC)
		INCLUDE (strReceiptNumber, intEntityVendorId, strBillOfLading)

	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceipt_strReceiptNumber]
		ON [dbo].[tblICInventoryReceipt]([strReceiptNumber] ASC)
		INCLUDE (intInventoryReceiptId, intEntityVendorId, strBillOfLading)

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
		@level2name = N'intEntityVendorId'
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
		@value = N'Receiver',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceipt',
		@level2type = N'COLUMN',
		@level2name = 'intReceiverId'
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

	GO

	GO

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
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceipt',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
	GO
	
	GO
	
	GO
	
	GO
	
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
		@level2name = N'dtmCheckDate'
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
		@level2name = N'dtmTrailerArrivalDate'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Trailer Arrival Time',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceipt',
		@level2type = N'COLUMN',
		@level2name = N'dtmTrailerArrivalTime'
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
		@level2name = N'dtmReceiveTime'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Actual Temp Reading (Fahrenheit)',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceipt',
		@level2type = N'COLUMN',
		@level2name = N'dblActualTempReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shipment Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intShipmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Source Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceipt',
    @level2type = N'COLUMN',
    @level2name = N'intSourceType'
GO

CREATE TRIGGER [trgCustomJDESAPReceiptUpdateExportFlag]
ON tblICInventoryReceipt
FOR UPDATE
AS
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM tblIPSAPIDOCTag WHERE strTag ='UPDATE_RECEIPT_EXPORT_FLAG_ON_UNPOST' AND strValue = 'TRUE')
	BEGIN
		UPDATE	ri	
		SET		ysnExported = NULL 
		FROM	tblICInventoryReceiptItem ri INNER JOIN inserted i
					ON ri.intInventoryReceiptId = i.intInventoryReceiptId
		WHERE	ISNULL(i.ysnPosted, 0) = 0 
	END 
END
GO

CREATE TRIGGER trg_tblICInventoryReceipt 
   ON [dbo].[tblICInventoryReceipt]
   INSTEAD OF DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	DELETE FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM DELETED)
	DELETE FROM tblICInventoryReceiptCharge WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM DELETED)
	DELETE FROM tblICInventoryReceipt WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM DELETED)
END

GO