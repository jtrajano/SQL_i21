CREATE TABLE [dbo].[tblGRCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
	[strLicenseNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
    [strTransferUpdateOption] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [strProcessScaleTickets] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [dtmTicketDailyStopTime] DATETIME NULL, 
    [dtmTicketStopDate] DATETIME NULL, 
    [ysnAutoCalculateFreightSurcharge] BIT NULL DEFAULT 0, 
    [dblFreightSurchargeRate] NUMERIC(18, 6) NULL, 
    [ysnDPStorageContracts] BIT NULL DEFAULT 1, 
    [ysnUseDPMaxUnits] BIT NULL DEFAULT 0, 
    [strGrainBankinUnitsorPounds] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [ysnCalculateGrainBankonADB] BIT NULL DEFAULT 1, 
    [ysnAllowGrainBankOverdraw] BIT NULL,
	[ysnCanadianPrimaryElevatorReceipt] BIT NULL DEFAULT 0,
	[intItemId] INT NULL, 
    CONSTRAINT [PK_tblGRCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC),
	CONSTRAINT [FK_tblGRCompanyPreference_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
