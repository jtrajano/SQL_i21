﻿CREATE TABLE [dbo].[tblQMCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMCompanyPreference_intConcurrencyId] DEFAULT 0,
    [intNumberofDecimalPlaces] INT NOT NULL,
	[ysnEnableParentLot] BIT NOT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnEnableParentLot] DEFAULT 0,
	[ysnIsSamplePrintEnable] BIT NOT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnIsSamplePrintEnable] DEFAULT 0,
	[intApproveLotStatus] INT,
	[intRejectLotStatus] INT,
	ysnAllowReversalSampleEntry BIT CONSTRAINT [DF_tblQMCompanyPreference_ysnAllowReversalSampleEntry] DEFAULT 0,
	[ysnChangeLotStatusOnApproveforPreSanitizeLot] BIT NOT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnChangeLotStatusOnApproveforPreSanitizeLot] DEFAULT 0,
	[ysnRejectLGContainer] BIT NOT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnRejectLGContainer] DEFAULT 1,
	[intUserSampleApproval] INT,
	ysnFilterContractByERPPONumber BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnFilterContractByERPPONumber] DEFAULT 0,
	ysnEnableSampleTypeByUserRole BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnEnableSampleTypeByUserRole] DEFAULT 0,
	ysnShowSampleFromAllLocation BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnShowSampleFromAllLocation] DEFAULT 0,
	ysnValidateMultipleValuesInTestResult BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnValidateMultipleValuesInTestResult] DEFAULT 0,
	strTestReportComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strSampleImportDateTimeFormat NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	ysnCaptureItemInProperty BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnCaptureItemInProperty] DEFAULT 0,
	ysnEnableAssignContractsInSample BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnEnableAssignContractsInSample] DEFAULT 0,
	ysnShowItemDescriptionOnly BIT CONSTRAINT [DF_tblQMCompanyPreference_ysnShowItemDescriptionOnly] DEFAULT 0,
	ysnEnableContractSequencesTabInSampleSearchScreen BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnEnableContractSequencesTabInSampleSearchScreen] DEFAULT 0,
    strSampleInstructionReport NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intDefaultSampleStatusId INT DEFAULT(5),
	ysnSetDefaultReceivedDateInSampleScreen BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnSetDefaultReceivedDateInSampleScreen] DEFAULT 1,
	intCuppingSessionLimit INT DEFAULT(18),
	intSamplePrintEmailTemplate INT NULL DEFAULT 0,
	ysnAllowEditingAfterSampleApproveReject BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnAllowEditingAfterSampleApproveReject] DEFAULT 0,
	ysnAllowEditingTheItemNo BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnAllowEditingTheItemNo] DEFAULT 0,
	ysnAllowEditingTheOrigin BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnAllowEditingTheOrigin] DEFAULT 0,
	ysnSendPriceFeed BIT NULL CONSTRAINT [DF_tblQMCompanyPreference_ysnSendPriceFeed] DEFAULT 0,
	ysnValidateLotNo BIT NULL DEFAULT 0,
	ysnFilterSupplierByLocation BIT NULL DEFAULT 0,
	CONSTRAINT [PK_tblQMCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]),
	CONSTRAINT [FK_tblQMCompanyPreference_tblICLotStatus_intApproveLotStatus] FOREIGN KEY ([intApproveLotStatus]) REFERENCES [tblICLotStatus]([intLotStatusId]),
	CONSTRAINT [FK_tblQMCompanyPreference_tblICLotStatus_intRejectLotStatus] FOREIGN KEY ([intRejectLotStatus]) REFERENCES [tblICLotStatus]([intLotStatusId]),
	CONSTRAINT [FK_tblQMCompanyPreference_tblQMSampleStatus_intDefaultSampleStatusId] FOREIGN KEY ([intDefaultSampleStatusId]) REFERENCES [tblQMSampleStatus]([intSampleStatusId]),
)