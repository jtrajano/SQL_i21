-- use to create initial (dummy) scale setup. see below JIRA issues
--http://jira.irelyserver.com/browse/IC-5933
--http://jira.irelyserver.com/browse/GRN-1270
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspGRImportCreateInitialScaleSetup')
	DROP PROCEDURE uspGRImportCreateInitialScaleSetup
GO
CREATE PROCEDURE uspGRImportCreateInitialScaleSetup
AS
BEGIN
--SELECT * FROM tblSMUserSecurity

	--DECLARE @intCurrencyId INT
	--SELECT @intCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

	DECLARE @IRelyAdminKey INT
	SELECT @IRelyAdminKey =intEntityId FROM tblSMUserSecurity WHERE strUserName='IRELYADMIN'

	DECLARE @intTicketPoolId INT
	DECLARE @intScaleDeviceId INT
	

	DECLARE @strUnitMeasure  NVARCHAR(20)
	DECLARE @intUnitMeasureId INT
	--DECLARE @strFreightItem NVARCHAR(50)
	--DECLARE @intFreightItemId INT

	SELECT TOP 1 @strUnitMeasure = strUnitMeasure , @intUnitMeasureId = intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitType = 'Weight'
	
	/**TICKET POOL**/
	/*********************************************************************************************/
	INSERT INTO tblSCTicketPool(strTicketPool,intNextTicketNumber,ysnActive,intConcurrencyId)
	SELECT strTicketPool = '10'
		  ,intNextTicketNumber = 1
		  ,ysnActive = 0
		  ,intConcurrencyId = 1
	
	SET @intTicketPoolId = @@IDENTITY
	/*********************************************************************************************/
  	
	/**SCALE DEVICE**/
	/*********************************************************************************************/

	INSERT INTO tblSCScaleDevice
				(
				 intPhysicalEquipmentId
				,strDeviceDescription
				,intDeviceTypeId
				,intConnectionMethod
				,strFilePath
				,strFileName
				------,strIPAddress   missing columns
				------,intIPPort
				------,intComPort
				------,intBaudRate
				------,intDataBits
				------,intStopBits
				------,intParityBits
				------,intFlowControl
				,intGraderModel
				,ysnVerifyCommodityCode
				,ysnVerifyDateTime
				,ysnDateTimeCheck
				,ysnDateTimeFixedLocation
				,intDateTimeStartingLocation
				,intDateTimeLength
				,strDateTimeValidationString
				,ysnMotionDetection
				,ysnMotionFixedLocation
				,intMotionStartingLocation
				,intMotionLength
				,strMotionValidationString
				,intWeightStabilityCheck
				,ysnWeightFixedLocation
				,intWeightStartingLocation
				,intWeightLength
				,strNTEPCapacity
				,intConcurrencyId
				)
				SELECT 
				 intPhysicalEquipmentId					 = 1
				,strDeviceDescription					 = 'Scale 1'
				,intDeviceTypeId						 = 1
				,intConnectionMethod					 = 4
				,strFilePath							 = ''
				,strFileName							 = ''
				--,strIPAddress							 = ''
				--,intIPPort								 = 0
				--,intComPort								 = 1
				--,intBaudRate							 = 2400
				--,intDataBits							 = 1
				--,intStopBits							 = 1
				--,intParityBits							 = 1
				--,intFlowControl							 = 1
				,intGraderModel							 = 1
				,ysnVerifyCommodityCode					 = 0
				,ysnVerifyDateTime						 = 0
				,ysnDateTimeCheck						 = 0
				,ysnDateTimeFixedLocation				 = 0
				,intDateTimeStartingLocation    		 = 20
				,intDateTimeLength						 = 14
				,strDateTimeValidationString			 = ''
				,ysnMotionDetection						 = 1
				,ysnMotionFixedLocation					 = 0
				,intMotionStartingLocation				 = 13
				,intMotionLength						 = 1
				,strMotionValidationString				 = 0
				,intWeightStabilityCheck				 = 1
				,ysnWeightFixedLocation					 = 0
				,intWeightStartingLocation				 = 4
				,intWeightLength						 = 6
				,strNTEPCapacity						 = 220.000
				,intConcurrencyId                        = 1

	SET @intScaleDeviceId = @@IDENTITY
	/*********************************************************************************************/

	/** SCALE STATION **/
	
	    --IF NOT EXISTS(SELECT 1 FROM tblSCScaleSetup)
	    --BEGIN
	    	INSERT INTO  tblSCScaleSetup
			(
				 strStationShortDescription
				,strStationDescription
				,intStationType
				,intTicketPoolId
				,strAddress
				,strZipCode
				,strCity
				,strState
				,strCountry
				,strPhone
				,intLocationId
				,ysnAllowManualTicketNumber
				,strScaleOperator
				,intScaleProcessing
				,intTransferDelayMinutes
				,intBatchTransferInterval
				,strLocalFilePath
				,strServerPath
				,strWebServicePath
				,intMinimumPurgeDays
				,dtmLastPurgeDate
				,intLastPurgeUserId
				,intInScaleDeviceId
				,ysnDisableInScale
				,intOutScaleDeviceId
				,ysnDisableOutScale
				,ysnShowOutScale
				,ysnAllowZeroWeights
				,strWeightDescription
				,intUnitMeasureId
				,intGraderDeviceId
				,intAlternateGraderDeviceId
				,intLEDDeviceId
				,ysnCustomerFirst
				,intAllowOtherLocationContracts
				,intWeightDisplayDelay
				,intTicketSelectionDelay
				,intFreightHaulerIDRequired
				,intBinNumberRequired
				,intDriverNameRequired
				,intTruckIDRequired
				,intTrackAxleCount
				,intRequireSpotSalePrice
				,ysnTicketCommentRequired
				,ysnAllowElectronicSpotPrice
				,ysnRefreshContractsOnOpen
				,ysnTrackVariety
				,ysnManualGrading
				,ysnLockStoredGrade
				,ysnAllowManualWeight
				,intStorePitInformation
				,ysnReferenceNumberRequired
				,ysnDefaultDriverOffTruck
				,ysnAutomateTakeOutTicket
				,ysnDefaultDeductFreightFromFarmer
				,ysnDefaultDeductFeeFromCusVen
				,intStoreScaleOperator
				,intDefaultStorageTypeId
				,intGrainBankStorageTypeId
				,ysnRefreshLoadsOnOpen
				,ysnRequireContractForInTransitTicket
				,intDefaultFeeItemId
				,intFreightItemId
				,intEntityId
				,ysnActive
				,ysnMultipleWeights
				,intConcurrencyId
			)
			
    		SELECT 
	    		   strStationShortDescription				= 'DUMMY'--LTRIM(RTRIM(GT.gasct_loc_no)) + LTRIM(RTRIM(GT.gasct_scale_id))
				  ,strStationDescription					= 'DUMMY'--LTRIM(RTRIM(GT.gasct_loc_no)) + LTRIM(RTRIM(GT.gasct_scale_id))
				  ,intStationType							= 01
				  ,intTicketPoolId							= @intTicketPoolId
				  ,strAddress								= 1
				  ,strZipCode								= ''
				  ,strCity									= ''
				  ,strState									= ''
				  ,strCountry								= ''
				  ,strPhone									= ''
				  ,intLocationId							= (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation) --NULL--CL.intCompanyLocationId --MSA ??? 
				  ,ysnAllowManualTicketNumber				= 0
				  ,strScaleOperator							= 'iRely Admin'
				  ,intScaleProcessing						= 1
				  ,intTransferDelayMinutes					= 0
				  ,intBatchTransferInterval					= 0
				  ,strLocalFilePath							= ''
				  ,strServerPath							= ''
				  ,strWebServicePath						= ''
				  ,intMinimumPurgeDays						= 0
				  ,dtmLastPurgeDate							= NULL
				  ,intLastPurgeUserId						= @IRelyAdminKey
				  ,intInScaleDeviceId						= @intScaleDeviceId 
				  ,ysnDisableInScale						= 0
				  ,intOutScaleDeviceId						= @intScaleDeviceId 
				  ,ysnDisableOutScale						= 0
				  ,ysnShowOutScale							= 0
				  ,ysnAllowZeroWeights						= 1
				  ,strWeightDescription						= @strUnitMeasure --MSA ???? 'TON' <<<<
				  ,intUnitMeasureId							= @intUnitMeasureId --MSA ???
				  ,intGraderDeviceId						= NULL
				  ,intAlternateGraderDeviceId				= NULL
				  ,intLEDDeviceId							= NULL
				  ,ysnCustomerFirst							= 0
				  ,intAllowOtherLocationContracts			= 1
				  ,intWeightDisplayDelay					= 0.0
				  ,intTicketSelectionDelay					= 0.0
				  ,intFreightHaulerIDRequired				= 1
			
				  ,intBinNumberRequired						= 0
				  ,intDriverNameRequired					= 0
				  ,intTruckIDRequired						= 0
				  ,intTrackAxleCount						= 1
				  ,intRequireSpotSalePrice					= 1
				  ,ysnTicketCommentRequired					= 0
				  ,ysnAllowElectronicSpotPrice				= 0
				  ,ysnRefreshContractsOnOpen				= 0
				  ,ysnTrackVariety							= 0
				  ,ysnManualGrading							= 0
				  ,ysnLockStoredGrade						= 0
				  ,ysnAllowManualWeight						= 0
				  ,intStorePitInformation					= 1
				  ,ysnReferenceNumberRequired				= 0
				  ,ysnDefaultDriverOffTruck					= 1
				  ,ysnAutomateTakeOutTicket					= 0
				  ,ysnDefaultDeductFreightFromFarmer		= 0
				  ,ysnDefaultDeductFeeFromCusVen			= 0
				  ,intStoreScaleOperator					= 1
				  ,intDefaultStorageTypeId					= NULL
				  ,intGrainBankStorageTypeId				= NULL
				  ,ysnRefreshLoadsOnOpen					= 0
				  ,ysnRequireContractForInTransitTicket		= 0
				  ,intDefaultFeeItemId						= NULL
				  ,intFreightItemId							= NULL --@intFreightItemId --MSA ??
				  ,intEntityId								= @IRelyAdminKey
				  ,ysnActive								= 0
				  ,ysnMultipleWeights						= 0
				  ,intConcurrencyId							= 1
	    
	    --END 
	/*********************************************************************************************/
				
END
GO