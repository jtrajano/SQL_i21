CREATE TABLE [dbo].[tblRKElectronicPricingPreferences]
(
	[intElectronicPricingControlId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [dtmLastPurgeDateTime] DATETIME NULL, 
    [ysnInterfaceContracts] BIT NOT NULL DEFAULT 1, 
    [ysnInterfaceTargetOrders] BIT NOT NULL DEFAULT 1, 
    [ysnInterfaceBasisPricing] BIT NOT NULL DEFAULT 1, 
    [ysnInterfaceCashPrices] BIT NOT NULL DEFAULT 1, 
    [ysnInterfaceM2M] BIT NOT NULL DEFAULT 1, 
    [ysnInterfacesc] BIT NOT NULL DEFAULT 1, 
    [strWebServiceURL] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strWebServiceID] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
    [strWebSericePassword] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
    [intUpdateDelayMinutes] INT NOT NULL DEFAULT 5, 
    [intHistorySaveInterval] INT NOT NULL DEFAULT 6, 
    [strHistoryStartTime] NVARCHAR(4) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 0800, 
    [strHisotryEndTime] NVARCHAR(4) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 1400, 
    [ysnHistoryByCloseDate] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblRKElectronicPricingPreferences_intElectronicPricingControlId] PRIMARY KEY ([intElectronicPricingControlId]) 
)
