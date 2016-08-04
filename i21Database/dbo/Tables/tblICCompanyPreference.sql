CREATE TABLE [dbo].[tblICCompanyPreference]
(
	[intCompanyPreferenceId] INT IDENTITY, 
    [intInheritSetup] INT NULL DEFAULT ((1)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    [strLotCondition] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strReceiptType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intReceiptSourceType] INT NULL, 
    [intShipmentOrderType] INT NULL, 
    [intShipmentSourceType] INT NULL, 
    CONSTRAINT [PK_tblICCompanyPreference] PRIMARY KEY ([intCompanyPreferenceId]) 
)
