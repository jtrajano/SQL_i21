﻿CREATE TABLE [dbo].[tblSTRegister]
(
	[intRegisterId] INT NOT NULL IDENTITY, 
    [intStoreId] INT NOT NULL, 
    [strRegisterName] NVARCHAR(15) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strRegisterClass] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnRegisterDataLoad] BIT NULL, 
    [ysnCheckoutLoad] BIT NULL, 
    [ysnPricebookBuild] BIT NULL, 
    [ysnImportPricebook] BIT NULL, 
    [ysnComboBuild] BIT NULL, 
    [ysnMixMatchBuild] BIT NULL, 
    [ysnItemListBuild] BIT NULL, 
    [strRecieveDataPath] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strSendDataPath] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strRemoteDataPath] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strRegisterPassword] NVARCHAR(16) COLLATE Latin1_General_CI_AS NULL, 
    [strRubyPullType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [intPortNumber] INT NULL, 
    [intLineSpeed] INT NULL, 
    [intDataBits] INT NULL, 
    [intStopBits] INT NULL, 
    [strParity] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [intTimeOut] INT NULL, 
    [ysnUseModem] BIT NULL, 
    [strPhoneNumber] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [intNumberOfTerminals] INT NULL, 
    [ysnSupportComboSales] BIT NULL, 
    [ysnSupportMixMatchSales] BIT NULL, 
    [ysnDepartmentTotals] BIT NULL, 
    [ysnPluItemTotals] BIT NULL, 
    [ysnSummaryTotals] BIT NULL, 
    [ysnCashierTotals] BIT NULL, 
    [ysnElectronicJournal] BIT NULL, 
    [ysnLoyaltyTotals] BIT NULL, 
    [ysnProprietaryTotals] BIT NULL, 
    [ysnPromotionTotals] BIT NULL, 
    [ysnFuelTotals] BIT NULL, 
    [ysnPayrollTimeWorked] BIT NULL, 
    [ysnPaymentMethodTotals] BIT NULL, 
    [ysnFuelTankTotals] BIT NULL, 
    [ysnNetworkTotals] BIT NULL, 
    [intPeriodNo] INT NULL, 
    [intSetNo] INT NULL, 
    [strSapphirePullType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strSapphireIpAddress] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [ysnDealTotals] BIT NULL, 
    [ysnHourlyTotals] BIT NULL, 
    [ysnTaxTotals] BIT NULL, 
    [ysnTransctionLog] BIT NULL, 
    [ysnPostCashCardAsARDetail] BIT NULL, 
    [intClubChargesCreditCardId] INT NULL,
    [intFuelDriveOffMopId] INT NULL, 
    [strProgramPath] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strWayneRegisterType] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [intMaxSkus] INT NULL, 
    [intWayneDefaultReportChain] INT NULL, 
    [intDiscountMopId] INT NULL, 
    [strUpdateSalesFrom] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [intBaudRate] INT NULL, 
    [intWayneComPort] INT NULL, 
    [intPCIriqForComPort] INT NULL, 
    [strWaynePassWord] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
    [intWayneSequenceNo] INT NULL, 
    [dblXmlVersion] NUMERIC(4, 2) NULL, 
    [strRegisterInboxPath] NVARCHAR(60) COLLATE Latin1_General_CI_AS NULL, 
    [strRegisterOutboxPath] NVARCHAR(60) COLLATE Latin1_General_CI_AS NULL, 
    [strRegisterStoreId] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [intTaxStrategyIdForTax1] INT NULL, 
    [intTaxStrategyIdForTax2] INT NULL, 
    [intTaxStrategyIdForTax3] INT NULL, 
    [intTaxStrategyIdForTax4] INT NULL, 
    [intNonTaxableStrategyId] INT NULL, 
    [ysnSupportPropFleetCards] BIT NULL, 
    [intDebitCardMopId] INT NULL, 
    [intLotteryWinnersMopId] INT NULL, 
    [ysnCreateCfnAtImport] BIT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    [strFTPPath] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strFTPUserName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strFTPPassword] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblSTRegister] PRIMARY KEY CLUSTERED ([intRegisterId] ASC), 
    CONSTRAINT [AK_tblSTRegister_intStoreId_strRegisterName_strRegisterClass] UNIQUE NONCLUSTERED ([intStoreId],[strRegisterName],[strRegisterClass] ASC), 
    CONSTRAINT [FK_tblSTRegister_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]), 
	CONSTRAINT [FK_tblSTRegister_tblSTPaymentOption_intFuelDriveOffMopId] FOREIGN KEY ([intFuelDriveOffMopId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]), 
	CONSTRAINT [FK_tblSTRegister_tblSTPaymentOption_intDiscountMopId] FOREIGN KEY ([intDiscountMopId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]), 
	CONSTRAINT [FK_tblSTRegister_tblSTPaymentOption_intDebitCardMopId] FOREIGN KEY ([intDebitCardMopId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]), 
	CONSTRAINT [FK_tblSTRegister_tblSTPaymentOption_intLotteryWinnersMopId] FOREIGN KEY ([intLotteryWinnersMopId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]),
	CONSTRAINT [FK_tblSTRegister_tblSTPaymentOption_intClubChargesCreditCardId] FOREIGN KEY ([intClubChargesCreditCardId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId])
);
