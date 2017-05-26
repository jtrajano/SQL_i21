CREATE PROCEDURE uspWHGetCompanyPreferenceValueList 
					@strCompanyLocationName NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @intCompanyLocationId INT

	SET @strCompanyLocationName = LTRIM(RTRIM(@strCompanyLocationName))

	IF (@strCompanyLocationName IS NOT NULL)
	BEGIN
		SELECT @intCompanyLocationId = intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE strLocationName = @strCompanyLocationName

		SELECT SettingName,SettingValue
		FROM (
			SELECT intCompanyPreferenceId, intCompanyLocationId, SettingName, CAST(SettingValue AS NVARCHAR(255)) SettingValue
			FROM (
				SELECT CAST(intCompanyPreferenceId AS NVARCHAR(255)) intCompanyPreferenceId, 
					   CAST(intCompanyLocationId AS NVARCHAR(255)) intCompanyLocationId, 
					   CAST(intAllowablePickDayRange AS NVARCHAR(255)) intAllowablePickDayRange, 
					   CAST(ysnAllowMoveAssignedTask AS NVARCHAR(255)) ysnAllowMoveAssignedTask, 
					   CAST(ysnScanForkliftOnLogin AS NVARCHAR(255)) ysnScanForkliftOnLogin, 
					   CAST(strHandheldType COLLATE DATABASE_DEFAULT AS NVARCHAR(255)) strHandheldType, 
					   CAST(strWarehouseType COLLATE DATABASE_DEFAULT AS NVARCHAR(255)) strWarehouseType, 
					   CAST(intContainerMinimumLength AS NVARCHAR(255)) intContainerMinimumLength, 
					   CAST(intLocationMinLength AS NVARCHAR(255)) intLocationMinLength, 
					   CAST(ysnNegativeQtyAllowed AS NVARCHAR(255)) ysnNegativeQtyAllowed, 
					   CAST(ysnPartialMoveAllowed AS NVARCHAR(255)) ysnPartialMoveAllowed, 
					   CAST(ysnGTINCaseCodeMandatory AS NVARCHAR(255)) ysnGTINCaseCodeMandatory, 
					   CAST(ysnEnableMoveAndMergeSplit AS NVARCHAR(255)) ysnEnableMoveAndMergeSplit, 
					   CAST(ysnTicketLabelToPrinter AS NVARCHAR(255)) ysnTicketLabelToPrinter, 
					   CAST(intNoOfCopiesToPrintforPalletSlip AS NVARCHAR(255)) intNoOfCopiesToPrintforPalletSlip, 
					   CAST(strWebServiceServerURL COLLATE DATABASE_DEFAULT AS NVARCHAR(255)) strWebServiceServerURL, 
					   CAST(strWMSStatus COLLATE DATABASE_DEFAULT AS NVARCHAR(255)) strWMSStatus, 
					   CAST(dblPalletWeight AS NVARCHAR(255)) dblPalletWeight, 
					   CAST(intNumberOfDecimalPlaces AS NVARCHAR(255)) intNumberOfDecimalPlaces, 
					   CAST(ysnCreateLoadTasks AS NVARCHAR(255)) ysnCreateLoadTasks, 
					   CAST(intMaximumPalletsOnForklift AS NVARCHAR(255)) intMaximumPalletsOnForklift,
					   CAST((SELECT ysnGenerateInvShipmentStagingOrder ysnGenerateInvShipmentStagingOrder FROM tblMFCompanyPreference) AS NVARCHAR(255)) ysnGenerateInvShipmentStagingOrder,
					   CAST((SELECT ysnSetDefaultQtyOnHandheld ysnSetDefaultQtyOnHandheld FROM tblMFCompanyPreference) AS NVARCHAR(255)) ysnSetDefaultQtyOnHandheld
				FROM tblWHCompanyPreference
				) p
			UNPIVOT(SettingValue FOR SettingName IN (
						intAllowablePickDayRange
						,ysnAllowMoveAssignedTask
						,ysnScanForkliftOnLogin
						,strHandheldType
						,strWarehouseType
						,intContainerMinimumLength
						,intLocationMinLength
						,ysnNegativeQtyAllowed
						,ysnPartialMoveAllowed
						,ysnGTINCaseCodeMandatory
						,ysnEnableMoveAndMergeSplit
						,ysnTicketLabelToPrinter
						,intNoOfCopiesToPrintforPalletSlip
						,strWebServiceServerURL
						,strWMSStatus
						,dblPalletWeight
						,intNumberOfDecimalPlaces
						,ysnCreateLoadTasks
						,intMaximumPalletsOnForklift
						,ysnGenerateInvShipmentStagingOrder
						,ysnSetDefaultQtyOnHandheld
						)) AS unpvt
			) tblCompanyPreference
		WHERE intCompanyLocationId = @intCompanyLocationId
	END
	ELSE
	BEGIN
		SELECT SettingName,SettingValue
		FROM (
			SELECT intCompanyPreferenceId, intCompanyLocationId, SettingName, CAST(SettingValue AS NVARCHAR(255)) SettingValue
			FROM (
					SELECT CAST(intCompanyPreferenceId AS NVARCHAR(255)) intCompanyPreferenceId, 
					   CAST(intCompanyLocationId AS NVARCHAR(255)) intCompanyLocationId, 
					   CAST(intAllowablePickDayRange AS NVARCHAR(255)) intAllowablePickDayRange, 
					   CAST(ysnAllowMoveAssignedTask AS NVARCHAR(255)) ysnAllowMoveAssignedTask, 
					   CAST(ysnScanForkliftOnLogin AS NVARCHAR(255)) ysnScanForkliftOnLogin, 
					   CAST(strHandheldType COLLATE DATABASE_DEFAULT AS NVARCHAR(255)) strHandheldType, 
					   CAST(strWarehouseType COLLATE DATABASE_DEFAULT AS NVARCHAR(255)) strWarehouseType, 
					   CAST(intContainerMinimumLength AS NVARCHAR(255)) intContainerMinimumLength, 
					   CAST(intLocationMinLength AS NVARCHAR(255)) intLocationMinLength, 
					   CAST(ysnNegativeQtyAllowed AS NVARCHAR(255)) ysnNegativeQtyAllowed, 
					   CAST(ysnPartialMoveAllowed AS NVARCHAR(255)) ysnPartialMoveAllowed, 
					   CAST(ysnGTINCaseCodeMandatory AS NVARCHAR(255)) ysnGTINCaseCodeMandatory, 
					   CAST(ysnEnableMoveAndMergeSplit AS NVARCHAR(255)) ysnEnableMoveAndMergeSplit, 
					   CAST(ysnTicketLabelToPrinter AS NVARCHAR(255)) ysnTicketLabelToPrinter, 
					   CAST(intNoOfCopiesToPrintforPalletSlip AS NVARCHAR(255)) intNoOfCopiesToPrintforPalletSlip, 
					   CAST(strWebServiceServerURL COLLATE DATABASE_DEFAULT AS NVARCHAR(255)) strWebServiceServerURL, 
					   CAST(strWMSStatus COLLATE DATABASE_DEFAULT AS NVARCHAR(255)) strWMSStatus, 
					   CAST(dblPalletWeight AS NVARCHAR(255)) dblPalletWeight, 
					   CAST(intNumberOfDecimalPlaces AS NVARCHAR(255)) intNumberOfDecimalPlaces, 
					   CAST(ysnCreateLoadTasks AS NVARCHAR(255)) ysnCreateLoadTasks, 
					   CAST(intMaximumPalletsOnForklift AS NVARCHAR(255)) intMaximumPalletsOnForklift,
					   CAST((SELECT ysnGenerateInvShipmentStagingOrder ysnGenerateInvShipmentStagingOrder FROM tblMFCompanyPreference) AS NVARCHAR(255)) ysnGenerateInvShipmentStagingOrder,
					   CAST((SELECT ysnSetDefaultQtyOnHandheld ysnSetDefaultQtyOnHandheld FROM tblMFCompanyPreference) AS NVARCHAR(255)) ysnSetDefaultQtyOnHandheld
				FROM tblWHCompanyPreference
			) p
		UNPIVOT(SettingValue FOR SettingName IN (
					intAllowablePickDayRange
					,ysnAllowMoveAssignedTask
					,ysnScanForkliftOnLogin
					,strHandheldType
					,strWarehouseType
					,intContainerMinimumLength
					,intLocationMinLength
					,ysnNegativeQtyAllowed
					,ysnPartialMoveAllowed
					,ysnGTINCaseCodeMandatory
					,ysnEnableMoveAndMergeSplit
					,ysnTicketLabelToPrinter
					,intNoOfCopiesToPrintforPalletSlip
					,strWebServiceServerURL
					,strWMSStatus
					,dblPalletWeight
					,intNumberOfDecimalPlaces
					,ysnCreateLoadTasks
					,intMaximumPalletsOnForklift
					,ysnGenerateInvShipmentStagingOrder
					,ysnSetDefaultQtyOnHandheld
					)) AS unpvt
				) tblCompanyPreference
	END
END