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
    [dblProcessXMLVersion] DECIMAL(18, 6) NULL, 
    [strStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strRegister] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strImportSapphireData] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intPeriod] INT NULL, 
    [intSet] INT NULL, 
    [dtmPollDate] DATETIME NULL, 
    [strHHMM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strAP] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnDepartmentTotals] BIT NULL, 
    [ysnPLUItemTotals] BIT NULL, 
    [ysnSummaryTotals] BIT NULL, 
    [ysnCashierTotals] BIT NULL, 
    [ysnDealTotals] BIT NULL, 
    [ysnFuelTotals] BIT NULL, 
    [ysnProprietaryCards] BIT NULL, 
    [ysnHourlyTotals] BIT NULL, 
    [ysnFuelTankTotals] BIT NULL, 
    [ysnTaxTotals] BIT NULL, 
    [ysnNetworkTotals] BIT NULL, 
    [ysnTransactionLog] BIT NULL, 
    [dblTotalToDeposit] DECIMAL(18, 6) NULL, 
    [dblTotalDeposits] DECIMAL(18, 6) NULL, 
    [dblTotalPaidOuts] DECIMAL(18, 6) NULL, 
    [dblEnteredPaidOuts] DECIMAL(18, 6) NULL, 
    [dblCustomerCharges] DECIMAL(18, 6) NULL, 
    [dblCustomerPayments] DECIMAL(18, 6) NULL, 
    [dblCashOverShort] DECIMAL(18, 6) NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutHeader] PRIMARY KEY CLUSTERED ([intCheckoutId] ASC), 
    CONSTRAINT [FK_tblSTCheckoutHeader_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]), 
    CONSTRAINT [AK_tblSTCheckoutHeader_intStoreId_dtmCheckoutDate_intShiftNo_strCheckoutType] UNIQUE ([intStoreId], [dtmCheckoutDate], [intShiftNo], [strCheckoutType]), 	
)
