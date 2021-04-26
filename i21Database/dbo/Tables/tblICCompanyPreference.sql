﻿CREATE TABLE [dbo].[tblICCompanyPreference]
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
    [strOriginLineOfBusiness] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strOriginLastTask] NVARCHAR(600) COLLATE Latin1_General_CI_AS NULL, 
    [strIRUnpostMode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 'Default', 
    [strReturnPostMode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT 'Default',
	[strReceiptReportFormat] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL DEFAULT 'Receipt Report Format - 1', 
	[strPickListReportFormat] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL DEFAULT 'Pick List Report Format - 1', 
	[strBOLReportFormat] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL DEFAULT 'BOL Report Format - 1', 
	[strTransferReportFormat] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL DEFAULT 'Transfer Report Format - 1', 
	[strCountSheetReportFormat] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL DEFAULT 'Count Sheet Report Format -1', 
    [dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL,
    [ysnIsCountSheetMultiFilter] BIT NULL DEFAULT(1),
	[ysnPriceFixWarningInReceipt] BIT NULL DEFAULT(0),
    [ysnValidateReceiptTotal] BIT NULL DEFAULT(0)
    CONSTRAINT [PK_tblICCompanyPreference] PRIMARY KEY ([intCompanyPreferenceId]) 
)
