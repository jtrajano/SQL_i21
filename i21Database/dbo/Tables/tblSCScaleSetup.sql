CREATE TABLE [dbo].[tblSCScaleSetup]
(
	[intScaleSetupId] INT NOT NULL  IDENTITY, 
    [strStationShortDescription] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strStationDescription] NVARCHAR(60) COLLATE Latin1_General_CI_AS NULL, 
    [intStationType] INT NOT NULL, 
    [intTicketPoolId] INT NOT NULL, 
    [strAddress] NVARCHAR(60) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strZipCode] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCity] NVARCHAR(85) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strState] NVARCHAR(60) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCountry] NVARCHAR(75) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strPhone] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intLocationId] INT NOT NULL,
    [ysnAllowManualTicketNumber] BIT NULL, 
    [strScaleOperator] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [intScaleProcessing] INT NULL, 
    [intTransferDelayMinutes] INT NULL, 
    [intBatchTransferInterval] INT NULL, 
    [strLocalFilePath] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strServerPath] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strWebServicePath] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [intMinimumPurgeDays] INT NULL, 
    [dtmLastPurgeDate] DATETIME NULL, 
    [intLastPurgeUserId] INT NULL, 
    [intInScaleDeviceId] INT NOT NULL, 
    [ysnDisableInScale] BIT NULL, 
    [intOutScaleDeviceId] INT NOT NULL, 
    [ysnDisableOutScale] BIT NULL, 
    [ysnShowOutScale] BIT NULL, 
	[ysnAllowZeroWeights] BIT NULL,
    [strWeightDescription] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intGraderDeviceId] INT NULL, 
    [intAlternateGraderDeviceId] INT NULL, 
    [intLEDDeviceId] INT NULL, 
    [ysnCustomerFirst] BIT NOT NULL, 
    [intAllowOtherLocationContracts] INT NOT NULL, 
    [intTimerDelay] DECIMAL(2, 1) NOT NULL, 
    [intWeightDisplayDelay] DECIMAL(2, 1) NOT NULL, 
    [intTicketSelectionDelay] DECIMAL(2, 1) NOT NULL,
    [intFreightHaulerIDRequired] INT NOT NULL, 
    [intBinNumberRequired] INT NOT NULL, 
    [intDriverNameRequired] INT NOT NULL, 
    [intTruckIDRequired] INT NOT NULL, 
    [intTrackAxleCount] INT NOT NULL, 
    [intRequireSpotSalePrice] INT NOT NULL, 
    [ysnTicketCommentRequired] BIT NOT NULL, 
    [ysnAllowElectronicSpotPrice] BIT NOT NULL, 
    [ysnRefreshContractsOnOpen] BIT NOT NULL, 
    [ysnTrackVariety] BIT NOT NULL, 
    [ysnManualGrading] BIT NOT NULL, 
    [ysnLockStoredGrade] BIT NOT NULL, 
    [ysnAllowManualWeight] BIT NOT NULL, 
    [intStorePitInformation] INT NOT NULL, 
    [ysnReferenceNumberRequired] BIT NOT NULL, 
    [ysnDefaultDriverOffTruck] BIT NOT NULL, 
    [ysnAutomateTakeOutTicket] BIT NOT NULL, 
    [ysnDefaultDeductFreightFromFarmer] BIT NOT NULL, 
    [intAllowOptionalReadings] INT NOT NULL, 
    [intStoreScaleOperator] INT NOT NULL, 
    [intDefaultStorageTypeId] INT NULL, 
    [intGrainBankStorageTypeId] INT NULL, 
    [ysnRefreshLoadsOnOpen] BIT NOT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSCScaleSetup_intScaleSetupId] PRIMARY KEY ([intScaleSetupId]), 
    CONSTRAINT [FK_tblSCScaleSetup_tblSCTicketPool] FOREIGN KEY ([intTicketPoolId]) REFERENCES [tblSCTicketPool]([intTicketPoolId]), 
    CONSTRAINT [FK_tblSCScaleSetup_tblSCScaleDevice_intInScaleDeviceId] FOREIGN KEY ([intInScaleDeviceId]) REFERENCES [tblSCScaleDevice]([intScaleDeviceId]), 
    CONSTRAINT [FK_tblSCScaleSetup_tblSCScaleDevice_intOutScaleDeviceId] FOREIGN KEY ([intOutScaleDeviceId]) REFERENCES [tblSCScaleDevice]([intScaleDeviceId]),
    CONSTRAINT [FK_tblSCScaleSetup_tblSCScaleDevice_intGraderDeviceId] FOREIGN KEY ([intGraderDeviceId]) REFERENCES [tblSCScaleDevice]([intScaleDeviceId]),
	CONSTRAINT [FK_tblSCScaleSetup_tblSCScaleDevice_intAlternateGraderDeviceId] FOREIGN KEY ([intAlternateGraderDeviceId]) REFERENCES [tblSCScaleDevice]([intScaleDeviceId]),
    CONSTRAINT [FK_tblSCScaleSetup_tblSCScaleDevice_intLEDDeviceId] FOREIGN KEY ([intLEDDeviceId]) REFERENCES [tblSCScaleDevice]([intScaleDeviceId]), 
    CONSTRAINT [FK_tblSCScaleSetup_tblSCTicketStorageType_intDefaultStorageTypeId] FOREIGN KEY ([intDefaultStorageTypeId]) REFERENCES [tblSCTicketStorageType]([intTicketStorageTypeId]),
    CONSTRAINT [FK_tblSCScaleSetup_tblSCTicketStorageType_intGrainBankStorageTypeId] FOREIGN KEY ([intGrainBankStorageTypeId]) REFERENCES [tblSCTicketStorageType]([intTicketStorageTypeId]), 
    CONSTRAINT [UK_tblSCScaleSetup_strStationShortDescription] UNIQUE ([strStationShortDescription]),
	CONSTRAINT [FK_tblSCScaleSetup_tblSMCompanyLocation_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblSCScaleSetup_tblSMUserSecurity_intLastPurgeUserId] FOREIGN KEY ([intLastPurgeUserId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID])
	)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intScaleSetupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Station',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'strStationShortDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Station Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strStationDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Station Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intStationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Pool',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intTicketPoolId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ZipCode',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strZipCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strCity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Phone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Manual Tickets',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowManualTicketNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Operator',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strScaleOperator'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Processing',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intScaleProcessing'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Transfer Delay',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intTransferDelayMinutes'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Batch Transfer Interval',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intBatchTransferInterval'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Local File',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strLocalFilePath'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Server Path',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strServerPath'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Web Service Path',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strWebServicePath'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Minimum Purge Days',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intMinimumPurgeDays'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Purge Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastPurgeDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Purge User ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'intLastPurgeUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'In Scale Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'intInScaleDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Disable In Scale',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnDisableInScale'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Out Scale Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'intOutScaleDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Disable Out Scale',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnDisableOutScale'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Show Out Scale',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnShowOutScale'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'strWeightDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grader Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'intGraderDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Alternate Grader Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'intAlternateGraderDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'LED Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'intLEDDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer First',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnCustomerFirst'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Other Location Contract',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'intAllowOtherLocationContracts'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Timer Delay',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intTimerDelay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Display Delay',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intWeightDisplayDelay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Selection Delay',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intTicketSelectionDelay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Hauler Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intFreightHaulerIDRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bin Number Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intBinNumberRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Driver Name Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intDriverNameRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Truck ID Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intTruckIDRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Track Axle Count',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intTrackAxleCount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Require Spot Sale',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intRequireSpotSalePrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Comment Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnTicketCommentRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Electronic Spot Sale Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowElectronicSpotPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Refresh Contract on Open',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnRefreshContractsOnOpen'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Track Variety',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnTrackVariety'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manual Grading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnManualGrading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lock Stored Grade',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnLockStoredGrade'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Manual Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowManualWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Store Pit Information',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intStorePitInformation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Number Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnReferenceNumberRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Driver Off Truck',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefaultDriverOffTruck'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Automate TakeOut Ticket',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnAutomateTakeOutTicket'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduct Freight from Farmer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefaultDeductFreightFromFarmer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Optional Readings',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intAllowOptionalReadings'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Store Scale Operator',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intStoreScaleOperator'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Storage Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'intDefaultStorageTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grain Bank Storage Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'intGrainBankStorageTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Refresh Loads on Open',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnRefreshLoadsOnOpen'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Company Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Zero Weights',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleSetup',
    @level2type = N'COLUMN',
    @level2name = 'ysnAllowZeroWeights'