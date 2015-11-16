CREATE TABLE [dbo].[tblWHCompanyPreference]
(
	intCompanyPreferenceId INT NOT NULL IDENTITY,
	intAllowablePickDayRange INT,
	ysnAllowMoveAssignedTask BIT,
	strHandheldType NVARCHAR(50),
	strWarehouseType NVARCHAR(50),
	intContainerMinimumLength INT,
	intLocationMinLength INT,
	ysnNegativeQtyAllowed BIT,
	ysnPartialMoveAllowed BIT,
	ysnGTINCaseCodeMandatory BIT,
	ysnEnableMoveAndMergeSplit BIT,
	ysnTicketLabelToPrinter BIT,
	intNoOfCopiesToPrintforPalletSlip INT,
	strWebServiceServerURL NVARCHAR(256),
	strWMSStatus NVARCHAR(100),
	dblPalletWeight NUMERIC(18,6),
	intNumberOfDecimalPlaces INT,
	ysnCreateLoadTasks BIT,
	intMaximumPalletsOnForklift INT
)
