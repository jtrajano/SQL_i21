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
				,LTRIM(RTRIM(gasct_comment)) COLLATE Latin1_General_CI_AS AS strTicketComment
				,CAST((CASE WHEN gasct_disc_schd_no > 0 
					THEN gasct_disc_schd_no 
					ELSE NULL
					END
				) AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS AS strDiscountId
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
				END) COLLATE Latin1_General_CI_AS AS strDistributionOption
				, (CASE 
						WHEN gasct_dist_option = ''C'' THEN ''Contract''
						WHEN gasct_dist_option = ''S'' THEN ''Spot Sale''
						ELSE gasct_dist_option
				END) AS strDistributionDescription
				,gasct_pit_no COLLATE Latin1_General_CI_AS AS strPitNumber
				,gasct_tic_pool COLLATE Latin1_General_CI_AS AS strTicketPool
				,gasct_spl_no COLLATE Latin1_General_CI_AS AS strSplitNumber
				,gasct_scale_id COLLATE Latin1_General_CI_AS AS strStationShortDescription
				,CAST(
				CASE WHEN gasct_split_wgt_yn = ''Y'' THEN 1
				ELSE 0 END
				AS BIT) AS ysnSplitWeightTicket
				,gasct_un_prc AS dblUnitPrice
				,gasct_gross_un AS dblGrossUnits
				,gasct_net_un AS dblNetUnits
				,LTRIM(RTRIM(gasct_tic_comment)) COLLATE Latin1_General_CI_AS AS strDiscountComment
				,(CASE	
					WHEN gasct_tic_type IN (''I'',''O'')  THEN 1
					WHEN gasct_tic_type = (''X'')       THEN 2 
					WHEN gasct_tic_type = (''M'')       THEN 3
					WHEN gasct_tic_type = (''T'')       THEN 4
					ELSE 5
				END) AS intTicketType
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
					,[intTicketType]
					,[intTicketTypeId]
					,[strTicketType]
					,[strInOutFlag]
					,[dtmTicketDateTime]
					,[strTicketStatus]
					,[intEntityId]
					,[intItemId]
					,[intCommodityId]
					,[intCompanyLocationId]
					,[dblGrossWeight]
					,[dtmGrossDateTime]
					,[dblTareWeight]
					,[dtmTareDateTime]
					,[strTicketComment]
					,[intDiscountId]
					,[intDiscountScheduleId]
					,[dblFreightRate]
					,[dblTicketFees]
					,[ysnFarmerPaysFreight]
					,[intCurrencyId]
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
					,[intStorageScheduleTypeId]
					,[strDistributionOption]
					,[strPitNumber]
					,[intTicketPoolId]
					,[strSplitNumber]
					,[intScaleSetupId]
					,[dblGrossUnits]
					,[dblNetUnits]
					,[dblUnitPrice]
					,[dblUnitBasis]
					,[ysnProcessedData]
					,[intOriginTicketId]
					,[dblConvertedUOMQty]
					,[intItemUOMIdFrom]
					,[intItemUOMIdTo]
					,[strItemUOM]
					,[strCostMethod]
					,[strDiscountComment]
					,[strSourceType]
				)
				SELECT 
				LTRIM(RTRIM(SC.strTicketNumber))
				,SC.intTicketType
				,SCL.intTicketTypeId
				,LTRIM(RTRIM(SC.strTicketType))
				,LTRIM(RTRIM(SC.strInOutFlag))
				,SC.dtmTicketDateTime
				,LTRIM(RTRIM(SC.strTicketStatus))
				,EM.intEntityId
				,IC.intItemId
				,ICC.intCommodityId
				,SM.intCompanyLocationId
				,SC.dblGrossWeight
				,SC.dtmGrossDateTime
				,SC.dblTareWeight
				,SC.dtmTareDateTime
				,LTRIM(RTRIM(SC.strTicketComment))
				,GRDI.intDiscountId
				,GRDS.intDiscountScheduleId
				,SC.dblFreightRate
				,SC.dblTicketFees
				,SC.ysnFarmerPaysFreight
				,SMCR.intCurrencyID
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
				,GRS.intStorageScheduleTypeId
				,LTRIM(RTRIM(SC.strDistributionOption))
				,LTRIM(RTRIM(SC.strPitNumber))
				,SCTP.intTicketPoolId
				,LTRIM(RTRIM(SC.strSplitNumber))
				,SCS.intScaleSetupId
				,SC.dblGrossUnits
				,SC.dblNetUnits
				,SC.dblUnitPrice
				,0
				,0
				,SC.intTicketId
				,UOM.dblUnitQty
				,UOM.intItemUOMId
				,ICUOM.intItemUOMId
				,UM.strUnitMeasure
				,''Per Unit''
				,SC.strDiscountComment
				,''LV Control''
				FROM vyuSCTicketLVControlView SC 
				INNER JOIN INSERTED IR ON SC.intTicketId = IR.A4GLIdentity
				LEFT JOIN tblEMEntity EM ON EM.strEntityNo = SC.strEntityNo
				LEFT JOIN tblICItem IC ON IC.strItemNo = SC.strItemNo
				LEFT JOIN tblICCommodity ICC ON ICC.intCommodityId = IC.intCommodityId
				LEFT JOIN tblSMCompanyLocation SM ON SM.strLocationNumber = SC.strLocationNumber
				LEFT JOIN tblGRDiscountId GRDI ON GRDI.strDiscountId = SC.strDiscountId
				LEFT JOIN tblSCScaleSetup SCS ON SCS.strStationShortDescription = SC.strStationShortDescription
				LEFT JOIN tblSCTicketPool SCTP ON SCTP.strTicketPool = SC.strTicketPool
				LEFT JOIN tblGRStorageType GRS ON GRS.strStorageTypeCode = SC.strDistributionOption
				LEFT JOIN tblSMCurrency SMCR ON SMCR.strCurrency = SC.strCurrency
				LEFT JOIN tblICItemUOM ICUOM ON ICUOM.intItemId = IC.intItemId AND ICUOM.ysnStockUOM = 1
				LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = ICUOM.intUnitMeasureId
				LEFT JOIN tblICItemUOM UOM ON UOM.intUnitMeasureId = SCS.intUnitMeasureId AND UOM.intItemId = IC.intItemId
				LEFT JOIN tblSCListTicketTypes SCL ON SCL.strInOutIndicator = SC.strInOutFlag AND SCL.intTicketType = SC.intTicketType
				LEFT JOIN tblGRDiscountSchedule GRDS ON GRDS.strDiscountDescription =  (IC.strDescription  + '' Discount'' COLLATE Latin1_General_CI_AS) 

				INSERT INTO tblSCTicketDiscountLVStaging (dblGradeReading, strShrinkWhat, dblShrinkPercent, intDiscountScheduleCodeId, intTicketId, strSourceType, strDiscountChargeType,intOriginTicketDiscountId)	
				SELECT 
				DISTINCT 
					gasct_reading AS dblGradeReading
					,gasct_shrk_what AS strShrinkWhat
					,gasct_shrk_pct AS dblShrinkPercent
					,intDiscountScheduleCodeId
					,intOriginTicketId
					,''Scale'' AS strSourceType
					,''Dollar'' strDiscountChargeType 
					,b.A4GLIdentity
				FROM (
						SELECT	
							gasct_disc_cd_1		gasct_disc_cd,
							gasct_reading_1		gasct_reading,
							gasct_disc_calc_1	gasct_disc_calc,
							gasct_un_disc_amt_1 gasct_un_disc_amt,
							gasct_shrk_what_1	gasct_shrk_what,
							gasct_shrk_pct_1	gasct_shrk_pct,
							A4GLIdentity		
							FROM gasctmst 
							WHERE gasct_disc_cd_1 IS NOT NULL

						UNION ALL
							SELECT gasct_disc_cd_2,gasct_reading_2,gasct_disc_calc_2,gasct_un_disc_amt_2,gasct_shrk_what_2,gasct_shrk_pct_2,A4GLIdentity      
							FROM gasctmst  WHERE gasct_disc_cd_2 IS NOT NULL
						UNION ALL
			
							SELECT gasct_disc_cd_3,gasct_reading_3,gasct_disc_calc_3,gasct_un_disc_amt_3,gasct_shrk_what_3,gasct_shrk_pct_3,A4GLIdentity
							FROM gasctmst  WHERE gasct_disc_cd_3 IS NOT NULL AND gasct_disc_cd_3 <> gasct_disc_cd_4 AND gasct_disc_cd_4 <>''TW'' 
						UNION ALL
							SELECT gasct_disc_cd_4,gasct_reading_4,gasct_disc_calc_4,gasct_un_disc_amt_4,gasct_shrk_what_4,gasct_shrk_pct_4,A4GLIdentity
							FROM gasctmst  WHERE gasct_disc_cd_4 IS NOT NULL AND gasct_disc_cd_3 <> gasct_disc_cd_4 AND gasct_disc_cd_4 <>''TW''
						UNION ALL
							(
							 SELECT disc_cd
				 				,SUM(reading)
				 				,SUM(disc_calc)
				 				,SUM(un_disc)
				 				,shrk_what
				 				,SUM(gasct_shrk_pct)
				 				,A4GLIdentity
							 FROM (
				 					SELECT 
				 					 gasct_disc_cd_4 disc_cd
				 					,Convert(FLOAT, gasct_reading_4) reading
				 					,Convert(FLOAT, gasct_disc_calc_4) disc_calc
				 					,Convert(FLOAT, gasct_un_disc_amt_4) un_disc
				 					,gasct_shrk_what_4 shrk_what
				 					,Convert(FLOAT, gasct_shrk_pct_4) gasct_shrk_pct
				 					,A4GLIdentity
				 					FROM gasctmst
				 					WHERE gasct_disc_cd_4 IS NOT NULL
				 	    				AND gasct_disc_cd_3 IS NOT NULL
				 	    				AND gasct_disc_cd_3 = gasct_disc_cd_4
				 	    				AND gasct_disc_cd_4 = ''TW''
				 	
				 				UNION ALL
				 	
				 				SELECT 
				 					gasct_disc_cd_3
				 					,Convert(FLOAT, gasct_reading_3)
				 					,Convert(FLOAT, gasct_disc_calc_3)
				 					,Convert(FLOAT, gasct_un_disc_amt_3)
				 					,gasct_shrk_what_3
				 					,Convert(FLOAT, gasct_shrk_pct_3)
				 					,A4GLIdentity
				 					FROM gasctmst
				 					WHERE gasct_disc_cd_3 IS NOT NULL
				 	    				AND gasct_disc_cd_4 IS NOT NULL
				 	    				AND gasct_disc_cd_3 = gasct_disc_cd_4
				 	    				AND gasct_disc_cd_3 = ''TW''
				 				) t
							 GROUP BY disc_cd
				 				,shrk_what
				 				,A4GLIdentity
				 
							) 
						UNION ALL
							SELECT gasct_disc_cd_5,gasct_reading_5,gasct_disc_calc_5,gasct_un_disc_amt_5,gasct_shrk_what_5,gasct_shrk_pct_5,A4GLIdentity
							FROM gasctmst  WHERE gasct_disc_cd_5 IS NOT NULL 
						UNION ALL
							SELECT gasct_disc_cd_6,gasct_reading_6,gasct_disc_calc_6,gasct_un_disc_amt_6,gasct_shrk_what_6,gasct_shrk_pct_6,A4GLIdentity
							FROM gasctmst  WHERE gasct_disc_cd_6 IS NOT NULL
						UNION ALL
							SELECT gasct_disc_cd_7,gasct_reading_7,gasct_disc_calc_7,gasct_un_disc_amt_7,gasct_shrk_what_7,gasct_shrk_pct_7,A4GLIdentity
							FROM gasctmst  WHERE gasct_disc_cd_7 IS NOT NULL 
						UNION ALL
							SELECT gasct_disc_cd_8,gasct_reading_8,gasct_disc_calc_8,gasct_un_disc_amt_8,gasct_shrk_what_8,gasct_shrk_pct_8,A4GLIdentity
							FROM gasctmst  WHERE gasct_disc_cd_8 IS NOT NULL  
						UNION ALL
							SELECT gasct_disc_cd_9,gasct_reading_9,gasct_disc_calc_9,gasct_un_disc_amt_9,gasct_shrk_what_9,gasct_shrk_pct_9,A4GLIdentity
							FROM gasctmst  WHERE gasct_disc_cd_9 IS NOT NULL 
						UNION ALL
							SELECT gasct_disc_cd_10,gasct_reading_10,gasct_disc_calc_10,gasct_un_disc_amt_10,gasct_shrk_what_10,gasct_shrk_pct_10,A4GLIdentity
							FROM gasctmst  WHERE gasct_disc_cd_10 IS NOT NULL 
						UNION ALL
							SELECT gasct_disc_cd_11,gasct_reading_11,gasct_disc_calc_11,gasct_un_disc_amt_11,gasct_shrk_what_11,gasct_shrk_pct_11,A4GLIdentity
							FROM gasctmst  WHERE gasct_disc_cd_11 IS NOT NULL 
						UNION ALL
							SELECT gasct_disc_cd_12,gasct_reading_12,gasct_disc_calc_12,gasct_un_disc_amt_12,gasct_shrk_what_12,gasct_shrk_pct_12,A4GLIdentity
							FROM gasctmst  WHERE gasct_disc_cd_12 IS NOT NULL
				)b 
				INNER JOIN tblSCTicketLVStaging k ON k.intOriginTicketId = b.A4GLIdentity AND b.gasct_disc_cd is not null
				INNER JOIN tblICCommodity ic ON ic.intCommodityId = k.intCommodityId
				INNER JOIN tblGRDiscountSchedule d ON d.strDiscountDescription =  (ic.strDescription  + '' Discount'' COLLATE Latin1_General_CI_AS) 
				INNER JOIN tblGRDiscountScheduleCode c ON c.intDiscountScheduleId = d.intDiscountScheduleId AND c.intStorageTypeId = -1
				INNER JOIN tblICItem i on i.intItemId = c.intItemId AND i.strShortName = b.gasct_disc_cd  COLLATE Latin1_General_CI_AS
				WHERE b.gasct_disc_cd is not null
			END
		')
		PRINT 'End creating trigger'
	END
END
GO