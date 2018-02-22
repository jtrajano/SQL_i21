IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportScaleStation')
	DROP PROCEDURE uspGRImportScaleStation
GO

CREATE PROCEDURE uspGRImportScaleStation 
	 @Checking BIT = 0
	,@UserId INT = 0
	,@Total INT = 0 OUTPUT
AS
BEGIN
	
	--================================================
	--     IMPORT Scale Station SetUps
	--================================================
	IF (@Checking = 1)
	BEGIN

		IF EXISTS(SELECT 1 FROM tblSCScaleSetup)
			SELECT @Total = 0
		ELSE
			SELECT @Total = COUNT(1)
			FROM gascimst SC
			JOIN tblSCTicketPool TP ON TP.strTicketPool collate Latin1_General_CI_AS = SC.gasci_scale_pool OR  TP.strTicketPool collate Latin1_General_CI_AS = SC.gasci_loc_no + SC.gasci_scale_station
			JOIN tblSMCompanyLocation CL ON CL.strLocationNumber collate Latin1_General_CI_AS  = SC.gasci_loc_no
			JOIN tblICUnitMeasure UM ON UM.strUnitMeasure collate Latin1_General_CI_AS = SC.gasci_wgt_desc OR UM.strUnitMeasure+ 'S' collate Latin1_General_CI_AS = gasci_wgt_desc
		
		RETURN @Total
	END
	
		DECLARE 
		@intDefaultStorageTypeId INT,
		@intGrainBankStorageTypeId INT,
		@ysnRequireContractForInTransitTicket BIT,
		@gactl_stor_desc_1 NVARCHAR(30),
		@gactl_roll_stor_type NVARCHAR(30),
		@sql nvarchar(max)

		SELECT	@gactl_stor_desc_1 = gactl_stor_desc_1,
				@gactl_roll_stor_type = gactl_roll_stor_type,
				@ysnRequireContractForInTransitTicket = dbo.fnCTConvertYNToBit(gac21_req_contract_for_in,1) 
		FROM	gactlmst WHERE gactl_key = 1
		SELECT	@sql = 'SELECT @intGrainBankStorageTypeId = intStorageScheduleTypeId from tblGRStorageType WHERE strStorageTypeDescription  collate Latin1_General_CI_AS= (SELECT gactl_stor_desc_'+@gactl_roll_stor_type+' FROM gactlmst WHERE gactl_key = 1)'

		exec sp_executesql @sql, N'@intGrainBankStorageTypeId INT OUTPUT',@intGrainBankStorageTypeId = @intGrainBankStorageTypeId output

		SELECT	@intDefaultStorageTypeId = intStorageScheduleTypeId from tblGRStorageType WHERE strStorageTypeDescription = @gactl_stor_desc_1

		INSERT INTO tblSCScaleSetup 
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
		 ,intStoreScaleOperator
		 ,intDefaultStorageTypeId
		 ,intGrainBankStorageTypeId
		 ,ysnRefreshLoadsOnOpen
		 ,ysnMultipleWeights
		 ,ysnRequireContractForInTransitTicket
		 ,intDefaultFeeItemId
		 ,intFreightItemId
		 ,intConcurrencyId
		 ,ysnDefaultDeductFeeFromCusVen
		 ,ysnActive
	    )

	   SELECT 
       strStationShortDescription			    = gasci_loc_no+gasci_scale_station
	  ,strStationDescription				    = gasci_scale_desc
	  ,intStationType						    = 1
	  ,intTicketPoolId							= TP.intTicketPoolId
	  ,strAddress							    = ISNULL(gasci_addr + gasci_addr2,'')
	  ,strZipCode							    = ISNULL(gasci_zip,'')
	  ,strCity									= ISNULL(gasci_city,'')
	  ,strState									= ISNULL(gasci_state,'')
	  ,strCountry								= ''
	  ,strPhone									= ''
	  ,intLocationId							= gasci_loc_no
	  ,ysnAllowManualTicketNumber				= dbo.fnCTConvertYNToBit(gasci_override_tic_yn,0)
	  ,strScaleOperator							= gasci_last_weigher
	  ,intScaleProcessing						= CASE WHEN gasci_remote_yn = 'Y' THEN 3 ELSE 1 END
	  ,intTransferDelayMinutes					= 0
	  ,intBatchTransferInterval					= 0
	  ,strLocalFilePath							= NULL
	  ,strServerPath							= NULL
	  ,strWebServicePath						= gasci_remote_path
	  ,intMinimumPurgeDays						= gasci_purge_days
	  ,dtmLastPurgeDate							= NULL
	  ,intLastPurgeUserId						= 1
	  ,intInScaleDeviceId						= NULL ----gasci_in_scale_id need to find
	  ,ysnDisableInScale						= dbo.fnCTConvertYNToBit(gasci_active_yn,0)
	  ,intOutScaleDeviceId						= NULL -- gasci_otb_scale_id need to find
	  ,ysnDisableOutScale						= dbo.fnCTConvertYNToBit(gasci_active_yn,0)
	  ,ysnShowOutScale							= NULL
	  ,ysnAllowZeroWeights						= dbo.fnCTConvertYNToBit(gasci_zero_wgt_yn,0)
	  ,strWeightDescription						= ''
	  ,intUnitMeasureId							= UM.intUnitMeasureId
	  ,intGraderDeviceId						= NULL -- NO Grading Equipment available
	  ,intAlternateGraderDeviceId				= NULL -- NO Grading Equipment available
	  ,intLEDDeviceId							= NULL
	  ,ysnCustomerFirst							= dbo.fnCTConvertYNToBit(gasci_ask_cus_bef_drv,0)
	  ,intAllowOtherLocationContracts		    = CASE WHEN gasci_use_contract_loc = 'A' THEN 1 ELSE 2 END
	  ,intWeightDisplayDelay				    = 0
	  ,intTicketSelectionDelay					= CAST(CASE WHEN ISNUMERIC(gasci_weight_thread_delay)=1 THEN gasci_weight_thread_delay ELSE 0.0 END AS DECIMAL(5,2))
	  
	  ,intFreightHaulerIDRequired			   = CASE	
														WHEN gasci_req_hauler_on_frt = 'Y' THEN 1
	  													WHEN gasci_req_hauler_on_frt = 'N' THEN 2
	  													WHEN gasci_req_hauler_on_frt = 'W' THEN 3
	  										     END
	  
	  ,intBinNumberRequired					   = CASE	
														WHEN gasci_req_bin_ynw = 'Y' THEN 1
	  												    WHEN gasci_req_bin_ynw = 'N' THEN 2
	  												    WHEN gasci_req_bin_ynw = 'W' THEN 3
	  										     END
	  
	  ,intDriverNameRequired				  =  CASE	
													   WHEN gasci_req_drv_id_ynr = 'R' THEN 1
	  												   WHEN gasci_req_drv_id_ynr = 'N' THEN 2
	  												   WHEN gasci_req_drv_id_ynr = 'B' THEN 3
	  										     END
	  
	  ,intTruckIDRequired					  = CASE	
													  WHEN gasci_req_trk_id_ynr = 'R' THEN 1
	  												  WHEN gasci_req_trk_id_ynr = 'N' THEN 2
	  												  WHEN gasci_req_trk_id_ynr = 'B' THEN 3
	  										    END
	  
	  ,intTrackAxleCount					  = CASE	
													  WHEN gasci_ask_no_axels_yn = 'Y' THEN 1
	  												  WHEN gasci_ask_no_axels_yn = 'N' THEN 2
	  												  WHEN gasci_ask_no_axels_yn = 'R' THEN 3
	  										    END
	  
	  ,intRequireSpotSalePrice			      = CASE	
													WHEN gasci_req_un_prc_on_spot_yn = 'Y' THEN 1
	  												WHEN gasci_req_un_prc_on_spot_yn = 'N' THEN 2
	  												WHEN gasci_req_un_prc_on_spot_yn = 'W' THEN 3
	  										    END
	  
	  ,ysnTicketCommentRequired				  = dbo.fnCTConvertYNToBit(gasci_req_cus_cmt_yn,0)
	  ,ysnAllowElectronicSpotPrice			  = dbo.fnCTConvertYNToBit(gasci_allow_ep_for_spot,0)
	  ,ysnRefreshContractsOnOpen			  = dbo.fnCTConvertYNToBit(gasci_ref_load_cnt_yn,0)
	  ,ysnTrackVariety					      = dbo.fnCTConvertYNToBit(gasci_track_variety_ynh,0)
	  ,ysnManualGrading					      = dbo.fnCTConvertYNToBit(gasci_track_grade_ynh,0)
	  ,ysnLockStoredGrade					  = 0
	  ,ysnAllowManualWeight				      = dbo.fnCTConvertYNToBit(gasci_allow_manual_wgt,0)
	  
	  ,intStorePitInformation				  = CASE	
													WHEN gasci_track_pit_ynh = 'Y' THEN 1
	  												WHEN gasci_track_pit_ynh = 'R' THEN 3
	  												WHEN gasci_track_pit_ynh = 'H' THEN 4
	  										    END
	  
	  ,ysnReferenceNumberRequired			  = dbo.fnCTConvertYNToBit(gasci_req_ref_no_yn,0)
	  
	  ,ysnDefaultDriverOffTruck			      = CASE	
													WHEN gasci_dflt_drv_on_yn = 'O' THEN 0
	  												WHEN gasci_dflt_drv_on_yn = 'F' THEN 1
	  										    END
	  ,ysnAutomateTakeOutTicket			      = 0
	  ,ysnDefaultDeductFreightFromFarmer	  = dbo.fnCTConvertYNToBit(gasci_ded_frt_yna,0)

	  ,intStoreScaleOperator				  = CASE	
													WHEN gasci_set_weigher = 'S' THEN 1
	  												WHEN gasci_set_weigher = 'M' THEN 2
	  												WHEN gasci_set_weigher = 'L' THEN 3
	  										     END
	  
	  ,intDefaultStorageTypeId				  = @intDefaultStorageTypeId
	  ,intGrainBankStorageTypeId			  = @intGrainBankStorageTypeId
	  ,ysnRefreshLoadsOnOpen				  = dbo.fnCTConvertYNToBit(gasci_ref_load_cnt_yn,0)
	  ,ysnMultipleWeights					  = dbo.fnCTConvertYNToBit(gasci_allow_spl_weighs_yn,0)
	  ,ysnRequireContractForInTransitTicket   = @ysnRequireContractForInTransitTicket
	  ,intDefaultFeeItemId					  = NULL
	  ,intFreightItemId						  = NULL
	  ,intConcurrencyId						  = 1
	  ,ysnDefaultDeductFeeFromCusVen		  = 0
	  ,ysnActive							  = 1
	  FROM gascimst SC
	  JOIN tblSCTicketPool TP ON TP.strTicketPool collate Latin1_General_CI_AS = SC.gasci_scale_pool OR  TP.strTicketPool collate Latin1_General_CI_AS = SC.gasci_loc_no + SC.gasci_scale_station
	  JOIN tblSMCompanyLocation CL ON CL.strLocationNumber collate Latin1_General_CI_AS  = SC.gasci_loc_no
	  JOIN tblICUnitMeasure UM ON UM.strUnitMeasure collate Latin1_General_CI_AS = SC.gasci_wgt_desc OR UM.strUnitMeasure+ 'S' collate Latin1_General_CI_AS = gasci_wgt_desc

END
GO