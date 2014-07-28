CREATE TABLE [dbo].[tblSMCompanyLocation]
(
	[intCompanyLocationId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strLocationType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strAddress] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strZipPostalCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strStateProvince] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strCountry] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strPhone] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strFax] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strEmail] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strWebsite] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strInternalNotes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strUseLocationAddress] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strSkipSalesmanDefault] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL , 
	[ysnSkipTermsDefault] BIT NULL DEFAULT (1),
	[strOrderTypeDefault] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strPrintCashReceipts] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL , 
	[ysnPrintCashTendered] BIT NULL DEFAULT (1),
	[strSalesTaxByLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL , 
	[strDeliverPickupDefault] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strTaxState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strTaxAuthorityId1] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strTaxAuthorityId2] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[ysnOverridePatronage] BIT NULL DEFAULT (1),
	[strOutOfStockWarning] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL , 
	[strLotOverdrawnWarning] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL , 
	[strDefaultCarrier] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[ysnOrderSection2Required] BIT NULL DEFAULT (1),
	[strPrintonPO] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblMixerSize] NUMERIC(18, 6) NULL DEFAULT (0), 
	[ysnOverrideMixerSize] BIT NULL DEFAULT (1),
	[ysnEvenBatches] BIT NULL DEFAULT (1),
	[ysnDefaultCustomBlend] BIT NULL DEFAULT (1),
	[ysnAgroguideInterface] BIT NULL DEFAULT (1),
	[ysnLocationActive] BIT NULL DEFAULT (1),
	[intProfitCenter] INT NULL,
	[intCashAccount] INT NULL,
	[intDepositAccount] INT NULL,
	[intARAccount] INT NULL,
	[intAPAccount] INT NULL,
	[intSalesAdvAcct] INT NULL,
	[intPurchaseAdvAccount] INT NULL,
	[intFreightAPAccount] INT NULL,
	[intFreightExpenses] INT NULL,
	[intFreightIncome] INT NULL,
	[intServiceCharges] INT NULL,
	[intSalesDiscounts] INT NULL,
	[intCashOverShort] INT NULL,
	[intWriteOff] INT NULL,
	[intCreditCardFee] INT NULL,
	[intSalesAccount] INT NULL,
	[intCostofGoodsSold] INT NULL,
	[intInventory] INT NULL,
	[strInvoiceType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDefaultInvoicePrinter] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPickTicketType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDefaultTicketPrinter] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLastOrderNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLastInvoiceNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPrintonInvoice] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnPrintContractBalance] BIT NULL DEFAULT (1),
	[strJohnDeereMerchant] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceComments] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnUseOrderNumberforInvoiceNumber] BIT NULL DEFAULT (1),
	[ysnOverrideOrderInvoiceNumber] BIT NULL DEFAULT (1),
	[ysnPrintInvoiceMedTags] BIT NULL DEFAULT (1),
	[ysnPrintPickTicketMedTags] BIT NULL DEFAULT (1),
	[ysnSendtoEnergyTrac] BIT NULL DEFAULT (1),
	[strDiscountScheduleType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationDiscount] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationStorage] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMarketZone] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLastTicket] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnDirectShipLocation] BIT NULL DEFAULT (1),
	[ysnScaleInstalled] BIT NULL DEFAULT (1),
	[strDefaultScaleId] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL,
	[ysnActive] BIT NULL DEFAULT (1),
	[ysnUsingCashDrawer] BIT NULL DEFAULT (1),
	[strCashDrawerDeviceId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[ysnPrintRegisterTape] BIT NULL DEFAULT (1),
	[ysnUseUPConOrders] BIT NULL DEFAULT (1),
	[ysnUseUPConPhysical] BIT NULL DEFAULT (1),
	[ysnUseUPConPurchaseOrders] BIT NULL DEFAULT (1),
	[strUPCSearchSequence] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strBarCodePrinterName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strPriceLevel1] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPriceLevel2] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPriceLevel3] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPriceLevel4] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPriceLevel5] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnOverShortEntries] BIT NULL DEFAULT (1),
	[strOverShortCustomer] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strOverShortAccount] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[ysnAutomaticCashDepositEntries] BIT NULL DEFAULT (1), 
    [intConcurrencyId] INT NOT NULL DEFAULT (1)
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intCompanyLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strLocationName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Type. Could either be Office, Warehouse, Farm, or Plant',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strLocationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zip or Postal Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strZipPostalCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strCity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State or Province',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strStateProvince'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Phone Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fax Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strFax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strEmail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Website',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strWebsite'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Internal Notes for the Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strInternalNotes'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Use Location Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strUseLocationAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Skip Salesman Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strSkipSalesmanDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Skip Terms Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnSkipTermsDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Order Type Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strOrderTypeDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print Cash Receipts',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPrintCashReceipts'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print Cash Tendered',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrintCashTendered'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Tax by Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strSalesTaxByLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deliver/Pickup Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strDeliverPickupDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strTaxState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Authority 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strTaxAuthorityId1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Authority 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strTaxAuthorityId2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Override Patronage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnOverridePatronage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Out of Stock Warning',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strOutOfStockWarning'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lot Overdrawn Warning',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strLotOverdrawnWarning'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Carrier',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strDefaultCarrier'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Order Section to Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnOrderSection2Required'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print on PO',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPrintonPO'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mixer Size',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'dblMixerSize'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Override Mixer Size',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnOverrideMixerSize'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Even Batches',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnEvenBatches'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Custom Blend',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefaultCustomBlend'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Agroguide Interface',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnAgroguideInterface'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location is Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnLocationActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Profit Center Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intProfitCenter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cash Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intCashAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deposit Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intDepositAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'AR Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intARAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'AP Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intAPAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Advance Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intSalesAdvAcct'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purchase Advance Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intPurchaseAdvAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight AP Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intFreightAPAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Expense Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intFreightExpenses'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Income Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intFreightIncome'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Service Charge Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intServiceCharges'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Discount Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intSalesDiscounts'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cash Over/Short Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intCashOverShort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Write Off Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intWriteOff'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Credit Card Fee Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intCreditCardFee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intSalesAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cost of Goods Sold Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intCostofGoodsSold'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Default Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intInventory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strInvoiceType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Invoice Printer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strDefaultInvoicePrinter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pick Ticket Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPickTicketType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Pick Ticket Printer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strDefaultTicketPrinter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Order Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strLastOrderNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Invoice Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strLastInvoiceNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print on Invoice',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPrintonInvoice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print Contract Balance',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrintContractBalance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'John Deere Merchant',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strJohnDeereMerchant'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Comments',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strInvoiceComments'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Use Order Number for Invoice Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnUseOrderNumberforInvoiceNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Override Order/Invoice Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnOverrideOrderInvoiceNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print Invoice Med Tags',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrintInvoiceMedTags'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print Pick Ticket Med Tags',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrintPickTicketMedTags'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Send to Energy Trac',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnSendtoEnergyTrac'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Schedule Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strDiscountScheduleType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Discount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strLocationDiscount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Storage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strLocationStorage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Market Zone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strMarketZone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Ticket',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strLastTicket'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Direct Ship Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnDirectShipLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Installed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnScaleInstalled'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Scale Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strDefaultScaleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grain is Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Using Cash Drawer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnUsingCashDrawer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cash Drawer Device Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strCashDrawerDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Print Register Tape',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrintRegisterTape'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Use UPC on Orders',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnUseUPConOrders'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Use UPC on Physical',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnUseUPConPhysical'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Use UPC on Purchase Orders',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnUseUPConPurchaseOrders'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'UPC Search Sequence',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strUPCSearchSequence'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bar Code Printer Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strBarCodePrinterName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Level 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPriceLevel1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Level 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPriceLevel2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Level 3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPriceLevel3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Level 4',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPriceLevel4'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Level 5',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPriceLevel5'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Over/Short Entries',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnOverShortEntries'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Over/Short Customer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strOverShortCustomer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Over/Short Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'strOverShortAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Automatic Cash Deposit Entries',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnAutomaticCashDepositEntries'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCompanyLocation',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
