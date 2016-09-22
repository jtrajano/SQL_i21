CREATE TABLE [dbo].[tblQMCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMCompanyPreference_intConcurrencyId] DEFAULT 0,
    [intNumberofDecimalPlaces] INT NOT NULL,
	[ysnEnableParentLot] BIT NOT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnEnableParentLot] DEFAULT 0,
	[ysnIsSamplePrintEnable] BIT NOT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnIsSamplePrintEnable] DEFAULT 0,
	[intApproveLotStatus] INT,
	[intRejectLotStatus] INT,
	[ysnChangeLotStatusOnApproveforPreSanitizeLot] BIT NOT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnChangeLotStatusOnApproveforPreSanitizeLot] DEFAULT 0,

    CONSTRAINT [PK_tblQMCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]),
	CONSTRAINT [FK_tblQMCompanyPreference_tblICLotStatus_intApproveLotStatus] FOREIGN KEY ([intApproveLotStatus]) REFERENCES [tblICLotStatus]([intLotStatusId]),
	CONSTRAINT [FK_tblQMCompanyPreference_tblICLotStatus_intRejectLotStatus] FOREIGN KEY ([intRejectLotStatus]) REFERENCES [tblICLotStatus]([intLotStatusId])
)
