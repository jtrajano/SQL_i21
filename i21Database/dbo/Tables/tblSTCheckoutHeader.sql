﻿CREATE TABLE [dbo].[tblSTCheckoutHeader]
(
    [intCheckoutId] INT NOT NULL IDENTITY,
    [intStoreId] INT NOT NULL,
    [dtmCheckoutDate] DATETIME NOT NULL,
    [intShiftNo] INT NOT NULL,
    [strCheckoutType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strManagersName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [strManagersPassword] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [dtmShiftDateForImport] DATETIME NULL,
    [dtmShiftClosedDate] DATETIME NULL,
    [strCheckoutCloseDate] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dblProcessXMLVersion] DECIMAL(18, 6) NULL,
    [strStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strRegister] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intPeriod] INT NULL,
    [intSet] INT NULL,
    [dtmPollDate] DATETIME NULL,
    [strHHMM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strAP] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblTotalToDeposit] DECIMAL(18, 6) NULL,
    [dblTotalDeposits] DECIMAL(18, 6) NULL,
    [dblTotalPaidOuts] DECIMAL(18, 6) NULL,
    [dblEnteredPaidOuts] DECIMAL(18, 6) NULL,
    [dblCustomerCharges] DECIMAL(18, 6) NULL,
    [dblCustomerPayments] DECIMAL(18, 6) NULL,
    [dblTotalSales] DECIMAL(18, 6) NULL,
    [dblTotalTax] DECIMAL(18, 6) NULL,
    [dblCustomerCount] DECIMAL(18, 6) NULL,
    [dblCashOverShort] DECIMAL(18, 6) NULL,
    [strCheckoutStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intTotalNoSalesCount] INT,
    [intFuelAdjustmentCount] INT,
    [dblFuelAdjustmentAmount] DECIMAL(18, 6) NULL,
    [intTotalRefundCount] INT,
    [dblTotalRefundAmount] DECIMAL(18, 6) NULL,

    [intCategoryId] INT NULL,
    [intCommodityId] INT NULL,
    [intCountGroupId] INT NULL,
    [dtmCountDate] DATETIME NULL,
    [strCountNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,    
    [intStorageLocationId] INT NULL,
    [intCompanyLocationSubLocationId] INT NULL,
    [intEntityId] INT NULL,
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [ysnIncludeZeroOnHand] BIT NOT NULL DEFAULT ((0)),
    [ysnIncludeOnHand] BIT NOT NULL DEFAULT ((0)),
    [ysnScannedCountEntry] BIT NOT NULL DEFAULT ((0)),
    [ysnCountByLots] BIT NOT NULL DEFAULT ((0)),
    [strCountBy]  NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT(('Item')),
    [ysnCountByPallets] BIT NOT NULL DEFAULT ((0)),
    [ysnRecountMismatch] BIT NOT NULL DEFAULT ((0)),
    [ysnExternal] BIT NOT NULL DEFAULT ((0)),
    [ysnRecount] BIT NOT NULL DEFAULT ((0)),
    [intRecountReferenceId] INT NULL,
    [intStatus] INT NULL DEFAULT ((1)),
    [ysnPosted] BIT NOT NULL DEFAULT ((0)),
    [dtmPosted] DATETIME NULL,
    [intImportFlagInternal] INT NULL,
    [intLockType] INT NULL,
    [intSort] INT NULL,
    [intInvoiceId] INT NULL,
	[strAllInvoiceIdList] NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSTCheckoutHeader] PRIMARY KEY CLUSTERED ([intCheckoutId] ASC),
    CONSTRAINT [FK_tblSTCheckoutHeader_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]),
    CONSTRAINT [FK_tblSTCheckoutHeader_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
    CONSTRAINT [FK_tblSTCheckoutHeader_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
    CONSTRAINT [FK_tblSTCheckoutHeader_tblICCountGroup] FOREIGN KEY ([intCountGroupId]) REFERENCES [tblICCountGroup]([intCountGroupId]),
    CONSTRAINT [FK_tblSTCheckoutHeader_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
    CONSTRAINT [FK_tblSTCheckoutHeader_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]),
    CONSTRAINT [FK_tblSTCheckoutHeader_tblSMUserSecurity] FOREIGN KEY ([intEntityId]) REFERENCES [tblSMUserSecurity]([intEntityId]),
	CONSTRAINT [FK_tblSTCheckoutHeader_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [tblARInvoice]([intInvoiceId]),
    CONSTRAINT [AK_tblSTCheckoutHeader_intStoreId_dtmCheckoutDate_intShiftNo_strCheckoutType] UNIQUE ([intStoreId], [dtmCheckoutDate], [intShiftNo], [strCheckoutType]),     
)
