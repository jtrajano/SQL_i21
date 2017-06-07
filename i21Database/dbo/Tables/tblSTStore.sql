﻿CREATE TABLE [dbo].[tblSTStore]
(
	[intStoreId] INT NOT NULL IDENTITY, 
    [intStoreNo] INT NOT NULL, 
    [strDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [strRegion] NVARCHAR(6) COLLATE Latin1_General_CI_AS NULL, 
    [strDistrict] NVARCHAR(6) COLLATE Latin1_General_CI_AS NULL, 
    [strAddress] NVARCHAR(60) COLLATE Latin1_General_CI_AS NULL, 
    [strCity] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strState] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strCountry] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strZipCode] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [strPhone] NVARCHAR(13) COLLATE Latin1_General_CI_AS NULL, 
    [strFax] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strEmail] NVARCHAR(65) COLLATE Latin1_General_CI_AS NULL, 
    [strWebsite] NVARCHAR(65) COLLATE Latin1_General_CI_AS NULL, 
    [intProfitCenter] INT NULL, 
    [ysnStoreOnHost] BIT NULL, 
    [strPricebookAutomated] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [strHandheldCostBasis] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [intDefaultVendorId] INT NULL, 
    [intCompanyLocationId] INT NULL, 
    [strGLCoId] NVARCHAR(2) COLLATE Latin1_General_CI_AS NULL, 
    [strARCoId] NVARCHAR(2) COLLATE Latin1_General_CI_AS NULL, 
    [intNextOrderNo] INT NULL, 
    [ysnUsePricebook] BIT NULL, 
    [intMaxPlu] INT NULL, 
    [ysnUseLargePlu] BIT NULL, 
    [ysnUseCfn] BIT NULL, 
    [strCfnSiteId] NVARCHAR(6) COLLATE Latin1_General_CI_AS NULL, 
	[strManagersName] NVARCHAR(12) COLLATE Latin1_General_CI_AS NULL, 
	[strManagersPassword] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [ysnInterfaceChecksToCheckbook] BIT NULL, 
    [strCheckbook] NVARCHAR(6) COLLATE Latin1_General_CI_AS NULL, 
    [strQuickbookInterfaceClass] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [strBarcodePrinterName] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL, 
    [dblServiceChargeRate] NUMERIC(7, 3) NULL, 
    [ysnUseArStatements] BIT NULL, 
    [dtmLastShiftOpenDate] DATETIME NULL, 
    [intLastShiftNo] INT NULL, 
    [dtmLastPhysicalImportDate] DATETIME NULL, 
    [dtmLastStatementRollDate] DATETIME NULL, 
    [ysnShiftPhysicalQuantityRecieved] BIT NULL, 
    [ysnShiftPhysicalQuantitySold] BIT NULL, 
    [strHandheldDeviceModel] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [strDepositLookupType] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [intDefaultPaidoutId] INT NULL,
    [intCustomerChargeMopId] INT NULL, 
    [intCashTransctionMopId] INT NULL, 
    [ysnAllowMassPriceChanges] BIT NULL, 
    [ysnUsingTankMonitors] BIT NULL, 
    [strRegisterName] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [intMaxRegisterPlu] INT NULL, 
    [strReportDepartmentAtGrossOrNet] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [intLoyaltyDiscountMopId] INT NULL, 
    [intLoyaltyDiscountCategoryId] INT NULL, 
    [ysnBreakoutPropCardTotal] BIT NULL, 
    [intRemovePropCardMopId] INT NULL, 
    [intAddPropCardMopId] INT NULL, 
    [strPropNetworkCardName] NVARCHAR(16) COLLATE Latin1_General_CI_AS NULL, 
    [strAllowRegisterMarkUpDown] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [strRegisterCheckoutDataEntry] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [strReconcileFuels] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [ysnRecieveProductByDepartment] BIT NULL, 
    [ysnKeepArATStore] BIT NULL, 
    [ysnUsingCheckWriter] BIT NULL, 
    [ysnLoadFuelCost] BIT NULL, 
    [ysnUseSafeFunds] BIT NULL, 
    [ysnClearPricebookFieldsOnAdd] BIT NULL, 
    [intNumberOfShifts] INT NULL, 
    [ysnUpdatePriceFromReciept] BIT NULL, 
    [strGLSalesIndicator] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
	[ysnUpdateCaseCost] BIT NULL, 
    [dtmInvoiceCloseDate] DATETIME NULL, 
    [strTaxIdPassword] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [intRegisterId] INT  NULL, 
    [dtmRegisterPricebookUpdateDate] DATETIME NULL, 
    [dtmRegisterPricebookUpdateTime] DATETIME NULL, 
    [dtmRegisterItemListUpdateDate] DATETIME NULL, 
    [dtmRegisterItemListUpdateTime] DATETIME NULL, 
    [dtmRegisterComboUpdateDate] DATETIME NULL, 
    [dtmRegisterComboUpdateTime] DATETIME NULL, 
    [dtmRegisterMixMatchUpdateDate] DATETIME NULL, 
    [dtmRegisterMixMatchUpdateTime] DATETIME NULL, 
    [intPassportFileNumber] INT NULL, 
    [strFalconDataPath] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL, 
    [intFalconComPort] INT NULL, 
    [intFalconBaudRate] INT NULL, 
    [intInventoryCloseShiftNo] INT NULL, 
    [dtmInventoryCutoffDate] INT NULL, 
    [intInventoryCutoffShiftNo] INT NULL, 
    [dtmDepartmentLevelDate] DATETIME NULL, 
    [strStatementFooter1] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL, 
    [strStatementFooter2] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL, 
    [strStatementFooter3] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL, 
    [strStatementFooter4] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL, 
    [intScnBackupSeqNo] INT NULL, 
    [intIpiBackupSeqNo] INT NULL, 
    [intRtlBackupSeqNo] INT NULL, 
    [intPhyBackupSeqNo] INT NULL, 
    [intBegVendorNumberId] INT NULL, 
    [intEndVendorNumberId] INT NULL, 
    [dtmBegReceiptDate] DATETIME NULL, 
    [dtmEndReceiptDate] DATETIME NULL, 
    [strBegOrderNo] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [strEndOrderNo] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [ysnRecieptErrors] BIT NULL, 
    [dtmEndOfDayDate] DATETIME NULL, 
    [intEndOfDayShiftNo] INT NULL, 
	[intTaxGroupId] int NULL,
	[strDepartment] nvarchar(max),
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTStore] PRIMARY KEY CLUSTERED ([intStoreId] ASC),
    CONSTRAINT [AK_tblSTStore_intStoreNo] UNIQUE NONCLUSTERED ([intStoreNo] ASC), 
	CONSTRAINT [FK_tblSTStore_tblEMEntity_intDefaultVendorId] FOREIGN KEY ([intDefaultVendorId]) REFERENCES tblEMEntity([intEntityId]), 
	CONSTRAINT [FK_tblSTStore_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblSTStore_tblEMEntity_intBegVendorNumberId] FOREIGN KEY ([intBegVendorNumberId]) REFERENCES tblEMEntity([intEntityId]), 
    CONSTRAINT [FK_tblSTStore_tblEMEntity_intEndVendorNumberId] FOREIGN KEY ([intEndVendorNumberId]) REFERENCES tblEMEntity([intEntityId]), 
	CONSTRAINT [FK_tblSTStore_tblICCategory_intLoyaltyDiscountCategoryId] FOREIGN KEY ([intLoyaltyDiscountCategoryId]) REFERENCES [tblICCategory]([intCategoryId]), 
	CONSTRAINT [FK_tblSTStore_tblSTRegister] FOREIGN KEY ([intRegisterId]) REFERENCES [tblSTRegister]([intRegisterId]),
	CONSTRAINT [FK_tblSTStore_tblSTPaymentOption_intDefaultPaidoutId] FOREIGN KEY ([intDefaultPaidoutId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]), 
	CONSTRAINT [FK_tblSTStore_tblSTPaymentOption_intCustomerChargeMopId] FOREIGN KEY ([intCustomerChargeMopId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]), 
	CONSTRAINT [FK_tblSTStore_tblSTPaymentOption_intCashTransctionMopId] FOREIGN KEY ([intCashTransctionMopId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]), 
	CONSTRAINT [FK_tblSTStore_tblSTPaymentOption_intLoyaltyDiscountMopId] FOREIGN KEY ([intLoyaltyDiscountMopId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]), 
	CONSTRAINT [FK_tblSTStore_tblSTPaymentOption_intRemovePropCardMopId] FOREIGN KEY ([intRemovePropCardMopId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]), 
	CONSTRAINT [FK_tblSTStore_tblSTPaymentOption_intAddPropCardMopId] FOREIGN KEY ([intAddPropCardMopId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]),
	CONSTRAINT [FK_tblSTStore_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId])
   );