﻿CREATE TABLE [dbo].[tblWHCompanyPreference]
(
	intCompanyPreferenceId INT NOT NULL IDENTITY,
	intCompanyLocationId INT,
	intAllowablePickDayRange INT,
	ysnAllowMoveAssignedTask BIT,
	ysnScanForkliftOnLogin BIT,
	strHandheldType NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
	strWarehouseType NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
	intContainerMinimumLength INT,
	intLocationMinLength INT,
	ysnNegativeQtyAllowed BIT,
	ysnPartialMoveAllowed BIT,
	ysnGTINCaseCodeMandatory BIT,
	ysnEnableMoveAndMergeSplit BIT,
	ysnTicketLabelToPrinter BIT,
	intNoOfCopiesToPrintforPalletSlip INT,
	strWebServiceServerURL NVARCHAR(256) COLLATE Latin1_General_CI_AS NULL, 
	strWMSStatus NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL, 
	dblPalletWeight NUMERIC(18,6),
	intNumberOfDecimalPlaces INT,
	ysnCreateLoadTasks BIT,
	intMaximumPalletsOnForklift INT
)