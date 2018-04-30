GO
IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblSMBuildNumber')
BEGIN
IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()) = 1 and
    (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gasctmst') = 1
	BEGIN
		PRINT 'Begin creating vyuSCTicketLVControlView '
		EXEC ('
			IF OBJECT_ID(''vyuSCTicketLVControlView'', ''V'') IS NOT NULL 
			DROP VIEW vyuSCTicketLVControlView
		')
		EXEC ('
			CREATE VIEW [dbo].[vyuSCTicketLVControlView]
			AS SELECT
				A4GLIdentity AS intTicketId 
				,gasct_tic_no COLLATE Latin1_General_CI_AS AS strTicketNumber
				,(CASE 
					WHEN gasct_tic_type = ''I'' THEN ''Load In''
					WHEN gasct_tic_type = ''O'' THEN ''Load Out''
					WHEN gasct_tic_type = ''M'' THEN ''Memo Weight''
					ELSE gasct_tic_type
				END) AS strTicketType
				,gasct_tic_type COLLATE Latin1_General_CI_AS AS strInOutFlag
				,(CASE 
					WHEN gasct_rev_dt > 1 THEN convert(datetime, convert(char(8), gasct_rev_dt))
					ELSE NULL
				END ) AS dtmTicketDateTime
				,gasct_open_close_ind as strTicketStatus
				,gasct_cus_no COLLATE Latin1_General_CI_AS AS strEntityNo
				,gasct_itm_no COLLATE Latin1_General_CI_AS AS strItemNo
				,gasct_loc_no COLLATE Latin1_General_CI_AS AS strLocationNumber
				,gasct_gross_wgt AS dblGrossWeight
				,(CASE 
					WHEN gasct_gross_rev_dt > 1 AND gasct_gross_time > 1 THEN DATEADD(second, gasct_gross_time, convert(datetime, convert(char(8), gasct_gross_rev_dt)))
					ELSE NULL
				END ) AS dtmGrossDateTime
				,gasct_tare_wgt AS dblTareWeight
				,(CASE 
					WHEN gasct_tare_rev_dt > 1 AND gasct_tare_time > 1 THEN DATEADD(second, gasct_tare_time, convert(datetime, convert(char(8), gasct_tare_rev_dt)))
					ELSE NULL
				END ) AS dtmTareDateTime
				,gasct_tic_comment AS strTicketComment
				,(CASE WHEN gasct_disc_schd_no > 0 
					THEN gasct_disc_schd_no 
					ELSE NULL
					END) AS strDiscountId
				,gasct_trkr_un_rt AS dblFreightRate
				,gasct_trkr_no COLLATE Latin1_General_CI_AS AS strHaulerName
				,gasct_fees AS dblTicketFees
				,CAST(
					CASE WHEN gasct_frt_deduct_yn = ''Y'' THEN 1
					ELSE 0 END
					AS BIT) AS ysnFarmerPaysFreight
				,gasct_currency COLLATE Latin1_General_CI_AS AS strCurrency
				,gasct_bin_no COLLATE Latin1_General_CI_AS AS strBinNumber
				,gasct_cnt_no COLLATE Latin1_General_CI_AS AS strContractNumber
				,gasct_cnt_seq AS intContractSequence
				,gasct_weigher COLLATE Latin1_General_CI_AS AS strScaleOperatorUser
				,gasct_truck_id COLLATE Latin1_General_CI_AS AS strTruckName
				,gasct_driver COLLATE Latin1_General_CI_AS AS strDriverName
				,gasct_cus_ref_no COLLATE Latin1_General_CI_AS AS strCustomerReference
				,CAST(gasct_axel_no AS INT) AS intAxleCount
				,CAST(
				CASE WHEN gasct_driver_on_yn = ''Y'' THEN 1
				ELSE 0 END
				AS BIT) AS ysnDriverOff
				,CAST(
				CASE WHEN gasct_gross_manual_yn = ''Y'' THEN 1
				ELSE 0 END
				AS BIT) AS ysnGrossManual
				,CAST(
				CASE WHEN gasct_tare_manual_yn = ''Y'' THEN 1
				ELSE 0 END
				AS BIT) AS ysnTareManual
				, (CASE 
						WHEN gasct_dist_option = ''C'' THEN ''CNT''
						WHEN gasct_dist_option = ''S'' THEN ''SPT''
						ELSE gasct_dist_option
				END) AS strDistributionOption
				, (CASE 
						WHEN gasct_dist_option = ''C'' THEN ''Contract''
						WHEN gasct_dist_option = ''S'' THEN ''Spot Sale''
						ELSE gasct_dist_option
				END) AS strDistributionDescription
				,gasct_pit_no COLLATE Latin1_General_CI_AS AS strPitNumber
				,gasct_tic_pool COLLATE Latin1_General_CI_AS AS strTicketPool
				,gasct_spl_no COLLATE Latin1_General_CI_AS AS strSplitNumber
				,gasct_scale_id COLLATE Latin1_General_CI_AS AS strStationShortDescription
			from gasctmst
		')
		PRINT 'End creating vyuSCTicketLVControlView table'

		PRINT 'Begin creating trigger'
		EXEC ('
			IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[dbo].[trigLVConrolInsert]''))
			BEGIN
				DROP TRIGGER [dbo].[trigLVConrolInsert]
			END
		')

		EXEC ('
			CREATE TRIGGER [dbo].[trigLVConrolInsert] ON [dbo].[gasctmst]
			AFTER INSERT
			AS
			BEGIN
				INSERT INTO tblSCTicketLVStaging 
				(
					[strTicketNumber]
					,[strTicketType]
					,[strInOutFlag]
					,[dtmTicketDateTime]
					,[strTicketStatus]
					,[intEntityId]
					,[strEntityNo]
					,[intItemId]
					,[strItemNo]
					,[intCompanyLocationId]
					,[strLocationNumber]
					,[dblGrossWeight]
					,[dtmGrossDateTime]
					,[dblTareWeight]
					,[dtmTareDateTime]
					,[strTicketComment]
					,[intDiscountId]
					,[strDiscountId]
					,[dblFreightRate]
					,[strHaulerName]
					,[dblTicketFees]
					,[ysnFarmerPaysFreight]
					,[strCurrency]
					,[strBinNumber]
					,[strContractNumber]
					,[intContractSequence]
					,[strScaleOperatorUser]
					,[strTruckName]
					,[strDriverName]
					,[strCustomerReference]
					,[intAxleCount]
					,[ysnDriverOff]
					,[ysnGrossManual]
					,[ysnTareManual]
					,[strDistributionOption]
					,[strPitNumber]
					,[intTicketPoolId]
					,[strTicketPool]
					,[strSplitNumber]
					,[intScaleSetupId]
					,[strStationShortDescription]
					,[ysnProcessedData]
					,[intOriginTicketId]
				)
				SELECT 
				LTRIM(RTRIM(SC.strTicketNumber))
				,LTRIM(RTRIM(SC.strTicketType))
				,LTRIM(RTRIM(SC.strInOutFlag))
				,SC.dtmTicketDateTime
				,LTRIM(RTRIM(SC.strTicketStatus))
				,AP.intEntityId
				,LTRIM(RTRIM(SC.strEntityNo))
				,IC.intItemId
				,LTRIM(RTRIM(SC.strItemNo))
				,SM.intCompanyLocationId
				,LTRIM(RTRIM(SC.strLocationNumber))
				,SC.dblGrossWeight
				,SC.dtmGrossDateTime
				,SC.dblTareWeight
				,SC.dtmTareDateTime
				,LTRIM(RTRIM(SC.strTicketComment))
				,GRDI.intDiscountId
				,LTRIM(RTRIM(SC.strDiscountId))
				,SC.dblFreightRate
				,LTRIM(RTRIM(SC.strHaulerName))
				,SC.dblTicketFees
				,SC.ysnFarmerPaysFreight
				,LTRIM(RTRIM(SC.strCurrency))
				,LTRIM(RTRIM(SC.strBinNumber))
				,LTRIM(RTRIM(SC.strContractNumber))
				,SC.intContractSequence
				,LTRIM(RTRIM(SC.strScaleOperatorUser))
				,LTRIM(RTRIM(SC.strTruckName))
				,LTRIM(RTRIM(SC.strDriverName))
				,LTRIM(RTRIM(SC.strCustomerReference))
				,SC.intAxleCount
				,SC.ysnDriverOff
				,SC.ysnGrossManual
				,SC.ysnTareManual
				,LTRIM(RTRIM(SC.strDistributionOption))
				,LTRIM(RTRIM(SC.strPitNumber))
				,SCTP.intTicketPoolId
				,LTRIM(RTRIM(SC.strTicketPool))
				,LTRIM(RTRIM(SC.strSplitNumber))
				,SCS.intScaleSetupId
				,SC.strStationShortDescription
				,0
				,SC.intTicketId
				FROM vyuSCTicketLVControlView SC 
				INNER JOIN INSERTED IR ON SC.intTicketId = IR.A4GLIdentity
				LEFT JOIN tblAPVendor AP ON AP.strVendorId = SC.strEntityNo
				LEFT JOIN tblICItem IC ON IC.strItemNo = SC.strItemNo
				LEFT JOIN tblSMCompanyLocation SM ON SM.strLocationNumber = SC.strLocationNumber
				LEFT JOIN tblGRDiscountId GRDI ON GRDI.strDiscountId = SC.strDiscountId
				LEFT JOIN tblSCScaleSetup SCS ON SCS.strStationShortDescription = SC.strStationShortDescription
				LEFT JOIN tblSCTicketPool SCTP ON SCTP.strTicketPool = SC.strTicketPool
			END
		')
		PRINT 'End creating trigger'
	END
END
GO