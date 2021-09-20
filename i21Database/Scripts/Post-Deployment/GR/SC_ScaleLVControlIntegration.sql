IF NOT EXISTS(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gasctmst')
BEGIN
	--any modification in below table definition should also update the column definition in the service 
	-- use this formula in excel =CONCATENATE("new column_definition(""", A2, """,", D2, "),")
	-- purpose is to avoid string will be truncated error 
	EXEC('

	CREATE TABLE [dbo].[gasctmst](
	[gasct_loc_no] [char](3) NOT NULL,
	[gasct_scale_id] [char](1) NOT NULL,
	[gasct_in_out_ind] [char](1) NOT NULL,
	[gasct_tic_no] [char](10) NOT NULL,
	[gasct_open_close_ind] [char](1) NOT NULL,
	[gasct_tic_type] [char](1) NULL,
	[gasct_orig_tic_type] [char](1) NULL,
	[gasct_void_yn] [char](1) NULL,
	[gasct_rev_dt] [int] NULL,
	[gasct_weigher] [char](12) NULL,
	[gasct_truck_id] [char](16) NULL,
	[gasct_driver] [char](12) NULL,
	[gasct_driver_on_yn] [char](1) NULL,
	[gasct_gross_manual_yn] [char](1) NULL,
	[gasct_gross_wgt] [decimal](13, 3) NULL,
	[gasct_gross_rev_dt] [int] NULL,
	[gasct_gross_time] [int] NULL,
	[gasct_gross_un] [decimal](11, 3) NULL,
	[gasct_tare_manual_yn] [char](1) NULL,
	[gasct_tare_wgt] [decimal](13, 3) NULL,
	[gasct_tare_rev_dt] [int] NULL,
	[gasct_tare_time] [int] NULL,
	[gasct_net_un] [decimal](11, 3) NULL,
	[gasct_com_cd] [char](3) NULL,
	[gasct_cus_no] [char](10) NULL,
	[gasct_spl_no] [char](4) NULL,
	[gasct_fees] [decimal](7, 2) NULL,
	[gasct_dist_option] [char](1) NULL,
	[gasct_defer_rev_dt] [int] NULL,
	[gasct_disc_schd_no] [tinyint] NULL,
	[gasct_disc_cd_1] [char](2) NULL,
	[gasct_disc_cd_2] [char](2) NULL,
	[gasct_disc_cd_3] [char](2) NULL,
	[gasct_disc_cd_4] [char](2) NULL,
	[gasct_disc_cd_5] [char](2) NULL,
	[gasct_disc_cd_6] [char](2) NULL,
	[gasct_disc_cd_7] [char](2) NULL,
	[gasct_disc_cd_8] [char](2) NULL,
	[gasct_disc_cd_9] [char](2) NULL,
	[gasct_disc_cd_10] [char](2) NULL,
	[gasct_disc_cd_11] [char](2) NULL,
	[gasct_disc_cd_12] [char](2) NULL,
	[gasct_reading_1] [decimal](7, 3) NULL,
	[gasct_reading_2] [decimal](7, 3) NULL,
	[gasct_reading_3] [decimal](7, 3) NULL,
	[gasct_reading_4] [decimal](7, 3) NULL,
	[gasct_reading_5] [decimal](7, 3) NULL,
	[gasct_reading_6] [decimal](7, 3) NULL,
	[gasct_reading_7] [decimal](7, 3) NULL,
	[gasct_reading_8] [decimal](7, 3) NULL,
	[gasct_reading_9] [decimal](7, 3) NULL,
	[gasct_reading_10] [decimal](7, 3) NULL,
	[gasct_reading_11] [decimal](7, 3) NULL,
	[gasct_reading_12] [decimal](7, 3) NULL,
	[gasct_disc_calc_1] [char](1) NULL,
	[gasct_disc_calc_2] [char](1) NULL,
	[gasct_disc_calc_3] [char](1) NULL,
	[gasct_disc_calc_4] [char](1) NULL,
	[gasct_disc_calc_5] [char](1) NULL,
	[gasct_disc_calc_6] [char](1) NULL,
	[gasct_disc_calc_7] [char](1) NULL,
	[gasct_disc_calc_8] [char](1) NULL,
	[gasct_disc_calc_9] [char](1) NULL,
	[gasct_disc_calc_10] [char](1) NULL,
	[gasct_disc_calc_11] [char](1) NULL,
	[gasct_disc_calc_12] [char](1) NULL,
	[gasct_un_disc_amt_1] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_2] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_3] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_4] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_5] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_6] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_7] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_8] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_9] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_10] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_11] [decimal](9, 6) NULL,
	[gasct_un_disc_amt_12] [decimal](9, 6) NULL,
	[gasct_shrk_what_1] [char](1) NULL,
	[gasct_shrk_what_2] [char](1) NULL,
	[gasct_shrk_what_3] [char](1) NULL,
	[gasct_shrk_what_4] [char](1) NULL,
	[gasct_shrk_what_5] [char](1) NULL,
	[gasct_shrk_what_6] [char](1) NULL,
	[gasct_shrk_what_7] [char](1) NULL,
	[gasct_shrk_what_8] [char](1) NULL,
	[gasct_shrk_what_9] [char](1) NULL,
	[gasct_shrk_what_10] [char](1) NULL,
	[gasct_shrk_what_11] [char](1) NULL,
	[gasct_shrk_what_12] [char](1) NULL,
	[gasct_shrk_pct_1] [decimal](7, 4) NULL,
	[gasct_shrk_pct_2] [decimal](7, 4) NULL,
	[gasct_shrk_pct_3] [decimal](7, 4) NULL,
	[gasct_shrk_pct_4] [decimal](7, 4) NULL,
	[gasct_shrk_pct_5] [decimal](7, 4) NULL,
	[gasct_shrk_pct_6] [decimal](7, 4) NULL,
	[gasct_shrk_pct_7] [decimal](7, 4) NULL,
	[gasct_shrk_pct_8] [decimal](7, 4) NULL,
	[gasct_shrk_pct_9] [decimal](7, 4) NULL,
	[gasct_shrk_pct_10] [decimal](7, 4) NULL,
	[gasct_shrk_pct_11] [decimal](7, 4) NULL,
	[gasct_shrk_pct_12] [decimal](7, 4) NULL,
	[gasct_comment] [char](60) NULL,
	[gasct_times_printed] [smallint] NULL,
	[gasct_spl_pct_1] [decimal](7, 3) NULL,
	[gasct_spl_pct_2] [decimal](7, 3) NULL,
	[gasct_spl_pct_3] [decimal](7, 3) NULL,
	[gasct_spl_pct_4] [decimal](7, 3) NULL,
	[gasct_spl_pct_5] [decimal](7, 3) NULL,
	[gasct_spl_pct_6] [decimal](7, 3) NULL,
	[gasct_spl_pct_7] [decimal](7, 3) NULL,
	[gasct_spl_pct_8] [decimal](7, 3) NULL,
	[gasct_spl_pct_9] [decimal](7, 3) NULL,
	[gasct_spl_pct_10] [decimal](7, 3) NULL,
	[gasct_spl_pct_11] [decimal](7, 3) NULL,
	[gasct_spl_pct_12] [decimal](7, 3) NULL,
	[gasct_spl_option_1] [char](1) NULL,
	[gasct_spl_option_2] [char](1) NULL,
	[gasct_spl_option_3] [char](1) NULL,
	[gasct_spl_option_4] [char](1) NULL,
	[gasct_spl_option_5] [char](1) NULL,
	[gasct_spl_option_6] [char](1) NULL,
	[gasct_spl_option_7] [char](1) NULL,
	[gasct_spl_option_8] [char](1) NULL,
	[gasct_spl_option_9] [char](1) NULL,
	[gasct_spl_option_10] [char](1) NULL,
	[gasct_spl_option_11] [char](1) NULL,
	[gasct_spl_option_12] [char](1) NULL,
	[gasct_plant_prt_ind] [char](1) NULL,
	[gasct_grade_prt_ind] [char](1) NULL,
	[gasct_tic_comment] [char](30) NULL,
	[gasct_un_prc] [decimal](9, 5) NULL,
	[gasct_trkr_no] [char](10) NULL,
	[gasct_trkr_un_rt] [decimal](9, 5) NULL,
	[gasct_cus_ref_no] [char](15) NULL,
	[gasct_frt_deduct_yn] [char](1) NULL,
	[gasct_split_wgt_yn] [char](1) NULL,
	[gasct_spl_gross_wgt1] [decimal](13, 3) NULL,
	[gasct_spl_gross_wgt2] [decimal](13, 3) NULL,
	[gasct_spl_tare_wgt1] [decimal](13, 3) NULL,
	[gasct_spl_tare_wgt2] [decimal](13, 3) NULL,
	[gasct_currency] [char](3) NULL,
	[gasct_currency_rt] [decimal](15, 8) NULL,
	[gasct_currency_cnt] [char](8) NULL,
	[gasct_bin_no] [char](5) NULL,
	[gasct_zeelan_loc] [char](3) NULL,
	[gasct_zeelan_bin] [char](2) NULL,
	[gasct_cnt_no] [char](8) NULL,
	[gasct_cnt_seq] [smallint] NULL,
	[gasct_cnt_sub] [smallint] NULL,
	[gasct_cnt_loc] [char](3) NULL,
	[gasct_xfr_to_loc] [char](3) NULL,
	[gasct_itm_no] [char](13) NULL,
	[gasct_ivc_no] [char](8) NULL,
	[gasct_load_loc_no] [char](3) NULL,
	[gasct_load_no] [char](8) NULL,
	[gasct_orig_gross_wgt] [decimal](13, 3) NULL,
	[gasct_orig_tare_wgt] [decimal](13, 3) NULL,
	[gasct_graph_tab_tic_hit] [char](1) NULL,
	[gasct_graph_tab_gra_hit] [char](1) NULL,
	[gasct_graph_tab_cus_hit] [char](1) NULL,
	[gasct_graph_tab_wgt_hit] [char](1) NULL,
	[gasct_graph_tab_oth_hit] [char](1) NULL,
	[gasct_graph_grades_hit_1] [char](1) NULL,
	[gasct_graph_grades_hit_2] [char](1) NULL,
	[gasct_graph_grades_hit_3] [char](1) NULL,
	[gasct_graph_grades_hit_4] [char](1) NULL,
	[gasct_graph_grades_hit_5] [char](1) NULL,
	[gasct_graph_grades_hit_6] [char](1) NULL,
	[gasct_graph_grades_hit_7] [char](1) NULL,
	[gasct_graph_grades_hit_8] [char](1) NULL,
	[gasct_graph_grades_hit_9] [char](1) NULL,
	[gasct_graph_grades_hit_10] [char](1) NULL,
	[gasct_graph_grades_hit_11] [char](1) NULL,
	[gasct_graph_grades_hit_12] [char](1) NULL,
	[gasct_axel_no] [char](1) NULL,
	[gasct_void_dt] [int] NULL,
	[gasct_variety] [char](10) NULL,
	[gasct_grade] [tinyint] NULL,
	[gasct_pit_no] [char](5) NULL,
	[gasct_tic_pool] [char](4) NOT NULL,
	[gasct_user_id] [char](16) NULL,
	[gasct_user_rev_dt] [int] NULL,
	[A4GLIdentity] [numeric](9, 0) IDENTITY(1,1) NOT NULL,
	[gasct_frt_currency] [char](3) NULL,
	[gasct_frt_currency_rt] [decimal](15, 8) NULL,
	[gasct_frt_currency_cnt] [char](8) NULL,
 CONSTRAINT [k_gasctmst] PRIMARY KEY NONCLUSTERED 
(
	[gasct_loc_no] ASC,
	[gasct_scale_id] ASC,
	[gasct_in_out_ind] ASC,
	[gasct_tic_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]


	')
END



GO

IF (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gasctmst') = 1
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
				,case when isnumeric(gasct_tic_no) = 1 then cast(cast(gasct_tic_no as int) as nvarchar) else gasct_tic_no end COLLATE Latin1_General_CI_AS AS strTicketNumber
				,(CASE 
					WHEN gasct_tic_type = ''I'' THEN ''Load In''
					WHEN gasct_tic_type = ''O'' THEN ''Load Out''
					WHEN gasct_tic_type = ''M'' THEN ''Memo Weight''
					ELSE gasct_tic_type
				END) COLLATE Latin1_General_CI_AS AS strTicketType
				,gasct_tic_type COLLATE Latin1_General_CI_AS AS strInOutFlag
				,(CASE 
					WHEN gasct_rev_dt > 1 THEN convert(datetime, convert(char(8), gasct_rev_dt))
					ELSE NULL
				END ) AS dtmTicketDateTime
				,ISNULL(nullif(gasct_open_close_ind, ''''), ''O'')  COLLATE Latin1_General_CI_AS  as strTicketStatus
				,gasct_cus_no COLLATE Latin1_General_CI_AS AS strEntityNo
				,gasct_com_cd COLLATE Latin1_General_CI_AS AS strItemNo
				,gasct_loc_no COLLATE Latin1_General_CI_AS AS strLocationNumber
				,gasct_gross_wgt AS dblGrossWeight
				,(CASE 
					WHEN gasct_gross_rev_dt > 1 AND gasct_gross_time > 1 THEN  
					convert(
						datetime, 
							convert(char(8), gasct_gross_rev_dt) + '' '' 
							+ substring(right(''000000'' + convert(nvarchar,gasct_gross_time), 6), 1, 2) + '':'' 
							+ substring(right(''000000'' + convert(nvarchar,gasct_gross_time), 6), 3, 2) + '':'' 
							+ substring(right(''000000'' + convert(nvarchar,gasct_gross_time), 6), 5, 2)
					 )
					ELSE NULL
				END ) AS dtmGrossDateTime
				,gasct_tare_wgt AS dblTareWeight
				,(CASE 
					WHEN gasct_tare_rev_dt > 1 AND gasct_tare_time > 1 THEN 
					convert(
						datetime, 
							convert(char(8), gasct_tare_rev_dt) + '' '' 
							+ substring(right(''000000'' + convert(nvarchar,gasct_tare_time), 6), 1, 2) + '':'' 
							+ substring(right(''000000'' + convert(nvarchar,gasct_tare_time), 6), 3, 2) + '':'' 
							+ substring(right(''000000'' + convert(nvarchar,gasct_tare_time), 6), 5, 2)
					)
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
						WHEN isnull(gasct_load_no, '''') <> '''' THEN ''LOD''

						ELSE gasct_dist_option
				END) COLLATE Latin1_General_CI_AS AS strDistributionOption
				, (CASE 
						WHEN gasct_dist_option = ''C'' THEN ''Contract''
						WHEN gasct_dist_option = ''S'' THEN ''Spot Sale''
						WHEN	ltrim(rtrim(isnull(gasct_load_no, ''''))) <> '''' THEN ''Load''
						ELSE gasct_dist_option
				END) COLLATE Latin1_General_CI_AS  AS strDistributionDescription
				,gasct_pit_no COLLATE Latin1_General_CI_AS AS strPitNumber
				,gasct_tic_pool COLLATE Latin1_General_CI_AS AS strTicketPool
				,gasct_spl_no COLLATE Latin1_General_CI_AS AS strSplitNumber
				,coalesce(lb.strStationShortDescription, a.gasct_tic_pool, (a.gasct_loc_no + '''' + a.gasct_scale_id) )  COLLATE Latin1_General_CI_AS  AS strStationShortDescription
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
				,''LS-'' + replace(gasct_load_no,''S '', '''') COLLATE Latin1_General_CI_AS as strLoadNumber
				, CASE WHEN gasct_in_out_ind = ''I'' THEN 1 ELSE 2 END AS intLoadPurchaseSale
			from gasctmst a
				left join (
						select a.strLinkStationShortDescription, b.strStationShortDescription from tblSCScaleSetupOriginLink a 
							join tblSCScaleSetup b
								on a.intScaleSetupId = b.intScaleSetupId
						
				) as lb
					on isnull(a.gasct_tic_pool, (a.gasct_loc_no + '''' + a.gasct_scale_id)) COLLATE Latin1_General_CI_AS = lb.strLinkStationShortDescription  COLLATE Latin1_General_CI_AS
		')
		PRINT 'End creating vyuSCTicketLVControlView table'


		PRINT 'Begin creating fnSCValidateTicketStagingTable '
		exec ('
			if object_id(''fnSCValidateTicketStagingTable'') is not null
			begin
				exec(''drop function fnSCValidateTicketStagingTable'')
			end

		')
		exec('
			CREATE FUNCTION [dbo].[fnSCValidateTicketStagingTable]
			(
				@intTicketLVStagingId int
			)
			RETURNS NVARCHAR(MAX)
			AS
			BEGIN
				DECLARE @error_message nvarchar(max)

				declare @msg table(
					strMessage nvarchar(100)
				)

				declare 
						@strDistributionOption			NVARCHAR(30)
						,@intLoadDetailId				INT
						,@intTicketType					INT
						,@intContractId					INT
						,@intEntityId					INT
						,@intCurrencyId					INT
						,@strScaleOperatorUser			NVARCHAR(100)
						,@strInOutFlag					NVARCHAR(100)
						,@ysnFarmerPaysFreight			BIT
						,@intHaulerEntityId				INT
						,@strTicketType					NVARCHAR(100)
						,@dblFreightRate				NUMERIC(38, 20)
						,@intSubLocationId				INT
						,@strBinNumber					NVARCHAR(100)
						,@intStorageLocationId			INT
						,@intAxleCount					INT
						,@strDriverName					NVARCHAR(100)
						,@strTruckName					NVARCHAR(100)
						,@strTicketComment				NVARCHAR(100)
						,@strCustomerReference			NVARCHAR(100)
						,@strPitNumber					NVARCHAR(100)
						,@intCompanyLocationId			INT
						,@intCommodityId				INT
						,@intItemId						INT
						,@intDiscountId					INT 
						,@dblConvertedUOMQty			NUMERIC(38, 20)
						,@dblGrossWeight				NUMERIC(38, 20)
						,@dblGrossWeight1				NUMERIC(38, 20)
						,@dblGrossWeight2				NUMERIC(38, 20)
						,@dblTareWeight					NUMERIC(38, 20)
						,@dblTareWeight1				NUMERIC(38, 20)
						,@dblTareWeight2				NUMERIC(38, 20)
						,@intSplitId					INT
						,@intRequireSpotSalePrice		INT
						,@dblUnitPrice					NUMERIC(38, 20)
						,@intScaleSetupId				INT
						,@strEntityNo					NVARCHAR(100)
						,@intOriginTicketId				INT
						,@strTicketNumber 			NVARCHAR(40)


				SELECT 

					@strDistributionOption		= strDistributionOption
					,@intLoadDetailId			= intLoadDetailId
					,@intTicketType				= intTicketType
					,@intContractId				= intContractId
					,@intEntityId				= intEntityId
					,@intCurrencyId				= intCurrencyId
					,@strScaleOperatorUser		= strScaleOperatorUser
					,@strInOutFlag				= strInOutFlag
					,@ysnFarmerPaysFreight		= ysnFarmerPaysFreight
					--,@intHaulerEntityId			= intHaulerEntityId
					,@strTicketType				= strTicketType
					,@dblFreightRate			= dblFreightRate
					,@strBinNumber				= strBinNumber
					--,@intStorageLocationId		= intStorageLocationId
					,@intAxleCount				= intAxleCount
					,@strDriverName				= strDriverName
					,@strTruckName				= strTruckName
					,@strTicketComment			= strTicketComment
					,@strCustomerReference		= strCustomerReference
					,@strPitNumber				= strPitNumber
					,@intCompanyLocationId		= intCompanyLocationId
					,@intCommodityId			= intCommodityId
					,@intItemId					= intItemId
					,@intDiscountId				= intDiscountId
					,@dblConvertedUOMQty		= dblConvertedUOMQty
					,@dblGrossWeight			= dblGrossWeight
					--,@dblGrossWeight1			= dblGrossWeight1
					--,@dblGrossWeight2			= dblGrossWeight2
					,@dblTareWeight				= dblTareWeight
					--,@dblTareWeight1			= dblTareWeight1
					--,@dblTareWeight2			= dblTareWeight2
					,@intSplitId				= intSplitId
					,@dblUnitPrice				= dblUnitPrice
					,@intScaleSetupId			= intScaleSetupId
					,@intOriginTicketId			= intOriginTicketId
					,@strTicketNumber 			= strTicketNumber
					from tblSCTicketLVStaging
						where intTicketLVStagingId = @intTicketLVStagingId
				
				select @strEntityNo = strEntityNo from vyuSCTicketLVControlView where intTicketId = @intOriginTicketId	
				SET @strEntityNo = ISNULL(@strEntityNo, '''')

				if isnull(@intScaleSetupId, 0) = 0
					return ''No scale station selected''


				if exists(select top 1 1 from tblSCTicket where intScaleSetupId = @intScaleSetupId and strTicketNumber = @strTicketNumber)
				begin
					insert into @msg(strMessage)
						select ''Duplicate Ticket number(''+ @strTicketNumber + '').''
				end


				declare @intStoreScaleOperator			INT
						,@intFreightHaulerIDRequired	INT
						,@intBinNumberRequired			INT
						,@intTrackAxleCount				INT
						,@intDriverNameRequired			INT
						,@intTruckIDRequired			INT
						,@ysnTicketCommentRequired		BIT
						,@ysnReferenceNumberRequired	BIT
						,@intStorePitInformation		INT
						,@ysnAllowZeroWeights			BIT

				SELECT 
					@intStoreScaleOperator			= intStoreScaleOperator 
					,@intFreightHaulerIDRequired	= intFreightHaulerIDRequired
					,@intBinNumberRequired			= intBinNumberRequired
					,@intTrackAxleCount				= intTrackAxleCount
					,@intTruckIDRequired			= intTruckIDRequired
					,@ysnTicketCommentRequired		= ysnTicketCommentRequired
					,@ysnReferenceNumberRequired	= ysnReferenceNumberRequired
					,@intStorePitInformation		= intStorePitInformation
					,@ysnAllowZeroWeights			= ysnAllowZeroWeights
					,@intRequireSpotSalePrice		= intRequireSpotSalePrice
					from tblSCScaleSetup 
						where intScaleSetupId = @intScaleSetupId

			

				if @strDistributionOption = ''LOD'' and isnull(@intLoadDetailId, 0) = 0
					insert into @msg(strMessage)
						select ''No selected Load Schedule''
				
				if @intTicketType = 6 and @strDistributionOption = ''CNT'' and ( isnull(@intContractId, 0) = 0)
					insert into @msg(strMessage)
						select ''No selected Contract''

				if isnull(@intTicketType, 0) = 0
					insert into @msg(strMessage)
						select ''Ticket Type cannot be blank''

				if isnull(@intEntityId, 0) = 0 and @intTicketType not in (2, 3)
						insert into @msg(strMessage)
						select ''Invalid Entity ('' +  @strEntityNo  + '')''
				else
					if isnull(@intCurrencyId, 0) = 0
						insert into @msg(strMessage)
						select ''Currency must be entered on Entity''
						

				if @intStoreScaleOperator = 1 and LTRIM(RTRIM(@strScaleOperatorUser)) = ''''
						insert into @msg(strMessage)
						select ''Invalid Scale Operator''

				--if @strInOutFlag = ''I'' and @ysnFarmerPaysFreight = 1 and @intHaulerEntityId = @intEntityId
				--        insert into @msg(strMessage)
				--		select ''Same vendor and hauler is not allowed if the deduct from vendor is checked''


				--if @intContractId is null and @intFreightHaulerIDRequired = 1 or @strTicketType = ''Transfer In''
				--           ( @dblFreightRate > 0 and isnull(intHaulerEntityId, 0) ) or ( isnull(intHaulerEntityId, 0)  and strTicketType = ''Transfer In'' )
				--               ''Invalid Hauler''


				if @intBinNumberRequired = 1 and  isnull(@intSubLocationId, 0) = 0
						insert into @msg(strMessage)
						select ''Invalid Storage Location''
				else if @intBinNumberRequired = 4
				begin
					if isnull(@intSubLocationId, 0) > 0 and isnull(@strBinNumber, '''') = ''''
						insert into @msg(strMessage)
						select ''Invalid Storage Storage Unit'' 
					--isnull(intStorageLocationId , 0)
					--    ''Invalid Storage Location''
				end
				--else
				--begin
				--    if isnull(@intSubLocationId, 0) = 0  and isnull(@intSubLocationId, 0)
				--        insert into @msg(strMessage)
				--		select ''Invalid Storage Location''
				--end


				if @intTrackAxleCount = 1 and isnull(@intAxleCount, 0) < 2
						insert into @msg(strMessage)
						select ''Invalid Axles''


				if @intDriverNameRequired = 1 and isnull(@strDriverName, '''') = ''''
						insert into @msg(strMessage)
						select ''Invalid Driver''


				if @intTruckIDRequired = 1 and isnull(@strTruckName, '''') = ''''
						insert into @msg(strMessage)
						select ''Invalid Truck ID''

				if @ysnTicketCommentRequired = 1 and isnull(@strTicketComment, '''') = ''''
						insert into @msg(strMessage)
						select ''Invalid Comment''


				if @ysnReferenceNumberRequired = 1 and isnull(@strCustomerReference, '''') = ''''
					insert into @msg(strMessage)
					select ''Invalid Reference''
			
				if @intStorePitInformation = 4
				begin
					if @intTicketType = 6 and @strInOutFlag = ''O''
						insert into @msg(strMessage)
						select ''Invalid Storage Unit''  
					else if isnull(@strPitNumber, '''') = ''''
						insert into @msg(strMessage)
						select ''Invalid Pit''
				end           


				--if isnull(@intCompanyLocationId, 0) = 0
				--	insert into @msg(strMessage)
				--	select ''Invalid Location''
			
				if @intTicketType <> 3 and (isnull(@intCommodityId, 0) = 0 or isnull(@intItemId, 0) = 0)
					insert into @msg(strMessage)
					select ''Invalid item''

				if @intTicketType <> 5
				begin
					if @intDiscountId > 0 and isnull(@dblConvertedUOMQty, 0) <= 0
						insert into @msg(strMessage)
						select ''Invalid default item unit of measure''
					else if (@intCommodityId > 0 or @intItemId > 0 ) and isnull(@intDiscountId, 0) = 0
						insert into @msg(strMessage)
						select ''Invalid Discount Schedule''
				end
					


				if isnull(@dblGrossWeight, 0) = 0
					insert into @msg(strMessage)
					select ''Invalid Gross Weight''


				if @ysnAllowZeroWeights = 0 and (isnull(@dblTareWeight, 0) = 0)
					insert into @msg(strMessage)
					select ''Invalid Tare Weight''
							--ysnMultipleWeights = 1
							--    (dblGrossWeight2 > 0 and isnull(dblTareWeight2, 0) = 0) or 
							--    (dblGrossWeight1 > 0 and isnull(dblTareWeight1, 0) = 0)
							--        ''Invalid Tare Weight''


				if (isnull(@dblGrossWeight, 0) - isnull(@dblTareWeight, 0)) <= 0
					insert into @msg(strMessage)
					select ''Invalid Net Weight''  



				--if @intTicketType not in (5, 2) and isnull(@strDistributionOption, '''') = '''' and isnull(@intSplitId, 0) = 0
				--	insert into @msg(strMessage)
				--	select ''Invalid Distribution''



				if @intRequireSpotSalePrice = 1 and isnull(@dblUnitPrice, 0) = 0 and @strDistributionOption = ''SPT''
					insert into @msg(strMessage)
					select ''Invalid Unit Price''



						--intTicketTypeId <> 5 and isnull(dblConvertedUOMQty, 0) = 0
						--    ''Invalid Gross, Shrink and Net''

				set @error_message = ''''
				select @error_message = @error_message + strMessage + '','' from @msg
				return @error_message

			END

		')

		PRINT 'End creating fnSCValidateTicketStagingTable table'
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

			--begin try

				if exists(select top 1 1 from tblGRCompanyPreference where ysnLVControlIntegration = 1)
				begin
					declare @intScaleOperatorId int
					declare @newLVTicket int
					declare @IrelyAdminId int
					declare @ysnUseItemCommodityDiscountOriginImport bit = 0

					select @ysnUseItemCommodityDiscountOriginImport = ysnUseItemCommodityDiscountOriginImport 
						from tblGRCompanyPreference 

					select @IrelyAdminId = intEntityId from tblEMEntityCredential where strUserName = ''irelyadmin''

					declare @scaleOperator nvarchar(20)
					set @scaleOperator = ''One Weigh''
					select @intScaleOperatorId = intScaleOperatorId from tblSCScaleOperator where strName = @scaleOperator
					if isnull(@intScaleOperatorId, 0) = 0
						set @scaleOperator = ''iRely Admin''
					

					if not exists ( select top 1 1 from tblSCTicketLVStaging where strTicketNumber  COLLATE Latin1_General_CI_AS = (select top 1 gasct_tic_no COLLATE Latin1_General_CI_AS from INSERTED))
					begin
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
							,[strLoadNumber]
							,intLoadId
							,intLoadDetailId
							,intContractId
							,strContractLocation
						)
						SELECT 
							[strTicketNumber]				= LTRIM(RTRIM(SC.strTicketNumber))
							,[intTicketType]				= SC.intTicketType
							,[intTicketTypeId]				= SCL.intTicketTypeId
							,[strTicketType]				= LTRIM(RTRIM(SC.strTicketType))
							,[strInOutFlag]					= LTRIM(RTRIM(SC.strInOutFlag))
							,[dtmTicketDateTime]			= SC.dtmTicketDateTime
							,[strTicketStatus]				= LTRIM(RTRIM(SC.strTicketStatus))
							,[intEntityId]					= EM.intEntityId
							,[intItemId]					= IC.intItemId
							,[intCommodityId]				= ICC.intCommodityId
							,[intCompanyLocationId]			= ISNULL(SM.intCompanyLocationId, SCS.intLocationId)
							,[dblGrossWeight] 				= SC.dblGrossWeight
							,[dtmGrossDateTime]				= SC.dtmGrossDateTime
							,[dblTareWeight]				= SC.dblTareWeight
							,[dtmTareDateTime]				= SC.dtmTareDateTime
							,[strTicketComment]				= LTRIM(RTRIM(SC.strTicketComment))
							,[intDiscountId]				= case when @ysnUseItemCommodityDiscountOriginImport = 1 then 
																ICC.intScheduleDiscountId
															else
																ISNULL(GRDI.intDiscountId, ICC.intScheduleDiscountId)
															end
							,[intDiscountScheduleId]		= case when @ysnUseItemCommodityDiscountOriginImport = 1 then 
																ICC_GRD_CROSS_REF.intDiscountScheduleId
															else
																GRD_CROSS_REF.intDiscountScheduleId 
															end -- consider review for redundancy. 
							,[dblFreightRate]				= SC.dblFreightRate
							,[dblTicketFees]				= SC.dblTicketFees
							,[ysnFarmerPaysFreight]			= SC.ysnFarmerPaysFreight
							,[intCurrencyId]				= SMCR.intCurrencyID
							,[strCurrency]					= LTRIM(RTRIM(SC.strCurrency))
							,[strBinNumber]					= LTRIM(RTRIM(SC.strBinNumber))
							,[strContractNumber]			= case when LG.intLoadId is not null then LG.strContractNumber else LTRIM(RTRIM(SC.strContractNumber)) end 
							,[intContractSequence]			= case when LG.intLoadId is not null then LG.intContractSeq else SC.intContractSequence end
							,[strScaleOperatorUser]			= LTRIM(RTRIM(isnull(nullif(SC.strScaleOperatorUser, ''''), @scaleOperator)))
							,[strTruckName]					= LTRIM(RTRIM(SC.strTruckName))
							,[strDriverName]				= case when SC.strDriverName is null or LTRIM(RTRIM(SC.strDriverName)) = '''' then SCS.strDriver else LTRIM(RTRIM(SC.strDriverName)) end
							,[strCustomerReference]			= LTRIM(RTRIM(SC.strCustomerReference))
							,[intAxleCount]					= SC.intAxleCount
							,[ysnDriverOff]					= SC.ysnDriverOff
							,[ysnGrossManual]				= SC.ysnGrossManual
							,[ysnTareManual]				= SC.ysnTareManual
							,[intStorageScheduleTypeId]		= GRS.intStorageScheduleTypeId
							,[strDistributionOption]		= LTRIM(RTRIM(SC.strDistributionOption))
							,[strPitNumber]					= LTRIM(RTRIM(SC.strPitNumber))
							,[intTicketPoolId]				= isnull(SCTP.intTicketPoolId, SCS.intTicketPoolId)
							,[strSplitNumber]				= LTRIM(RTRIM(SC.strSplitNumber))
							,[intScaleSetupId]				= SCS.intScaleSetupId
							,[dblGrossUnits]				= SC.dblGrossUnits
							,[dblNetUnits]					= SC.dblNetUnits
							,[dblUnitPrice]					= SC.dblUnitPrice
							,[dblUnitBasis]					= 0
							,[ysnProcessedData]				= 0
							,[intOriginTicketId]			= IR.A4GLIdentity
							,[dblConvertedUOMQty]			= QTYICUOM.dblUnitQty
							,[intItemUOMIdFrom]				= UOM.intItemUOMId
							,[intItemUOMIdTo]				= ICUOM.intItemUOMId
							,[strItemUOM]					= UM.strUnitMeasure
							,[strCostMethod]				= ''Per Unit''
							,[strDiscountComment]			= SC.strDiscountComment
							,[strSourceType]				= ''LV Control''	
							,SC.strLoadNumber
							,LG.intLoadId
							,LG.intLoadDetailId
							,LG.intContractDetailId		
							,strLocationName	
						FROM vyuSCTicketLVControlView SC 
						INNER JOIN INSERTED IR ON SC.intTicketId = IR.A4GLIdentity
						LEFT JOIN tblEMEntity EM ON EM.strEntityNo = SC.strEntityNo
						LEFT JOIN tblICItem IC ON IC.strShortName COLLATE Latin1_General_CI_AS =  IR.gasct_com_cd COLLATE Latin1_General_CI_AS
						LEFT JOIN tblICCommodity ICC ON ICC.intCommodityId = IC.intCommodityId
						LEFT JOIN tblSMCompanyLocation SM ON SM.strLocationNumber = SC.strLocationNumber
						LEFT JOIN tblGRDiscountId GRDI ON (ISNUMERIC(GRDI.strDiscountId) = 1 AND CAST(GRDI.strDiscountId AS INT) = SC.strDiscountId)
								OR  (ISNUMERIC(GRDI.strDiscountId) = 0 and (GRDI.strDiscountId =  SC.strDiscountId) )
						LEFT JOIN tblSCScaleSetup SCS ON SCS.strStationShortDescription = SC.strStationShortDescription
						LEFT JOIN tblSCTicketPool SCTP ON SCTP.strTicketPool = SC.strTicketPool
						LEFT JOIN tblGRStorageType GRS ON GRS.strStorageTypeCode = SC.strDistributionOption
						LEFT JOIN tblSMCurrency SMCR ON SMCR.strCurrency = SC.strCurrency
						LEFT JOIN tblICItemUOM ICUOM ON ICUOM.intItemId = IC.intItemId AND ICUOM.ysnStockUnit = 1
						LEFT JOIN tblICItemUOM QTYICUOM ON QTYICUOM.intItemId = IC.intItemId AND QTYICUOM.intUnitMeasureId = SCS.intUnitMeasureId
						LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = ICUOM.intUnitMeasureId
						LEFT JOIN tblICItemUOM UOM ON UOM.intUnitMeasureId = SCS.intUnitMeasureId AND UOM.intItemId = IC.intItemId
						LEFT JOIN tblSCListTicketTypes SCL ON SCL.strInOutIndicator = SC.strInOutFlag AND SCL.intTicketType = SC.intTicketType
						--LEFT JOIN tblGRDiscountSchedule GRDS ON GRDS.strDiscountDescription =  (IC.strDescription  + '' Discount'' COLLATE Latin1_General_CI_AS) 
						--left join tblGRDiscountCrossReference GRD_CROSS_REF on GRDI.intDiscountId = GRD_CROSS_REF.intDiscountId				
						left join (
							select 
								DCrossRef.intDiscountId 
								,DCrossRef.intDiscountScheduleId
								,DSchedule.intCommodityId
							from tblGRDiscountCrossReference DCrossRef
							join tblGRDiscountSchedule DSchedule
								on DCrossRef.intDiscountScheduleId = DSchedule.intDiscountScheduleId
						) GRD_CROSS_REF on ISNULL(GRDI.intDiscountId, ICC.intScheduleDiscountId) = GRD_CROSS_REF.intDiscountId
							and ICC.intCommodityId = GRD_CROSS_REF.intCommodityId
						left join (
							select 
								DCrossRef.intDiscountId 
								,DCrossRef.intDiscountScheduleId
								,DSchedule.intCommodityId
							from tblGRDiscountCrossReference DCrossRef
							join tblGRDiscountSchedule DSchedule
								on DCrossRef.intDiscountScheduleId = DSchedule.intDiscountScheduleId
						)ICC_GRD_CROSS_REF on ICC.intScheduleDiscountId = ICC_GRD_CROSS_REF.intDiscountId
							and ICC.intCommodityId = ICC_GRD_CROSS_REF.intCommodityId
						OUTER APPLY (
							SELECT TOP 1 intLoadId, intLoadDetailId,
								intContractDetailId = case 
														when intPurchaseSale = 1 then intPContractDetailId 
														else intSContractDetailId 
													end,
							
								strContractNumber = case 
														when intPurchaseSale = 1 then strPContractNumber 
														else strSContractNumber 
													end,

								intContractSeq		= case 
														when intPurchaseSale = 1 then intPContractSeq 
														else intSContractSeq 
													end,

								strLocation			= case 
														when intPurchaseSale = 1 then strPLocationName 
														else strSLocationName
													end
								FROM vyuLGLoadDetailView 
								where strLoadNumber COLLATE Latin1_General_CI_AS = SC.strLoadNumber COLLATE Latin1_General_CI_AS						
						) LG

						set @newLVTicket = SCOPE_IDENTITY()
					
						INSERT INTO tblSCTicketDiscountLVStaging (dblGradeReading, strShrinkWhat, dblShrinkPercent, intDiscountScheduleCodeId, intTicketId, strSourceType, strDiscountChargeType,intOriginTicketDiscountId, strCalcMethod)						
						SELECT 
						DISTINCT 
							gasct_reading AS dblGradeReading
							,ShrinkCalculationOption.strShrinkCalculationOption --gasct_shrk_what AS strShrinkWhat
							,gasct_shrk_pct AS dblShrinkPercent
							,c.intDiscountScheduleCodeId
							,intTicketId = k.intTicketLVStagingId
							,''Scale'' AS strSourceType
							,isnull(c.strDiscountChargeType, ''Dollar'') strDiscountChargeType 
							,b.A4GLIdentity
							,DCode.intShrinkCalculationOptionId
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
					
						INNER JOIN tblGRDiscountCrossReference GRD_CROSS_REF on GRD_CROSS_REF.intDiscountId = isnull(k.intDiscountId, ic.intScheduleDiscountId)
						--dapat di ka nababa dito
						INNER JOIN tblGRDiscountScheduleCode c ON c.intDiscountScheduleId = GRD_CROSS_REF.intDiscountScheduleId AND c.intStorageTypeId = -1
						INNER JOIN vyuGRDiscountScheduleCodeNotMapped DCode on DCode.intDiscountScheduleCodeId = c.intDiscountScheduleCodeId
						--INNER JOIN tblGRDiscountSchedule d ON d.strDiscountDescription =  (ic.strDescription  + '' Discount'' COLLATE Latin1_General_CI_AS) 
						--INNER JOIN tblGRDiscountScheduleCode c ON c.intDiscountScheduleId = d.intDiscountScheduleId AND c.intStorageTypeId = -1
						--INNER JOIN vyuGRDiscountScheduleCodeNotMapped DCode on DCode.intDiscountScheduleCodeId = c.intDiscountScheduleCodeId
						--
						join tblGRShrinkCalculationOption ShrinkCalculationOption
							on c.intShrinkCalculationOptionId = ShrinkCalculationOption.intShrinkCalculationOptionId	
						--

						INNER JOIN tblICItem i on i.intItemId = c.intItemId AND i.strShortName = b.gasct_disc_cd  COLLATE Latin1_General_CI_AS
						INNER JOIN INSERTED IR  ON k.intOriginTicketId= IR.A4GLIdentity
						WHERE b.gasct_disc_cd is not null 
							and k.strInOutFlag <> ''O''


						INSERT INTO tblSCTicketDiscountLVStaging (dblGradeReading, strShrinkWhat, dblShrinkPercent, intDiscountScheduleCodeId, intTicketId, strSourceType, strDiscountChargeType,intOriginTicketDiscountId, strCalcMethod)					
						select 
								DISTINCT
								isnull(gasct_reading, DiscountScheduleCode.dblDefaultValue) as dblGradeReading
								,ShrinkCalculationOption.strShrinkCalculationOption AS strShrinkWhat
								,isnull(gasct_shrk_pct, 0) AS dblShrinkPercent
								,DiscountScheduleCode.intDiscountScheduleCodeId
								,TicketStaging.intTicketLVStagingId
								,''Scale'' AS strSourceType
								,isnull(DiscountScheduleCode.strDiscountChargeType, ''Dollar'') strDiscountChargeType 
								,TicketStaging.intOriginTicketId
								,ShrinkCalculationOption.intShrinkCalculationOptionId
								
							from tblSCTicketLVStaging TicketStaging
								join tblGRDiscountScheduleCode DiscountScheduleCode
									on TicketStaging.intDiscountScheduleId = DiscountScheduleCode.intDiscountScheduleId
								join tblGRShrinkCalculationOption ShrinkCalculationOption
									on DiscountScheduleCode.intShrinkCalculationOptionId = ShrinkCalculationOption.intShrinkCalculationOptionId	
							
								INNER JOIN tblICCommodity ic ON ic.intCommodityId = TicketStaging.intCommodityId					
								INNER JOIN tblGRDiscountCrossReference GRD_CROSS_REF on GRD_CROSS_REF.intDiscountId = isnull(TicketStaging.intDiscountId, ic.intScheduleDiscountId)

								INNER JOIN INSERTED IR  ON TicketStaging.intOriginTicketId= IR.A4GLIdentity									
								INNER JOIN tblICItem i on i.intItemId = DiscountScheduleCode.intItemId
							
								
								left join
								(
								SELECT	
									gasct_disc_cd_1		gasct_disc_cd,
									gasct_reading_1		gasct_reading,
									gasct_disc_calc_1	gasct_disc_calc,
									gasct_un_disc_amt_1 gasct_un_disc_amt,
									gasct_shrk_what_1	gasct_shrk_what,
									gasct_shrk_pct_1	gasct_shrk_pct,
									A4GLIdentity		
									FROM INSERTED 
									WHERE gasct_disc_cd_1 IS NOT NULL

								UNION ALL
									SELECT gasct_disc_cd_2,gasct_reading_2,gasct_disc_calc_2,gasct_un_disc_amt_2,gasct_shrk_what_2,gasct_shrk_pct_2,A4GLIdentity      
									FROM INSERTED  WHERE gasct_disc_cd_2 IS NOT NULL
								UNION ALL
			
									SELECT gasct_disc_cd_3,gasct_reading_3,gasct_disc_calc_3,gasct_un_disc_amt_3,gasct_shrk_what_3,gasct_shrk_pct_3,A4GLIdentity
									FROM INSERTED  WHERE gasct_disc_cd_3 IS NOT NULL AND gasct_disc_cd_3 <> gasct_disc_cd_4 AND gasct_disc_cd_4 <>''TW''
								UNION ALL
									SELECT gasct_disc_cd_4,gasct_reading_4,gasct_disc_calc_4,gasct_un_disc_amt_4,gasct_shrk_what_4,gasct_shrk_pct_4,A4GLIdentity
									FROM INSERTED  WHERE gasct_disc_cd_4 IS NOT NULL AND gasct_disc_cd_3 <> gasct_disc_cd_4 AND gasct_disc_cd_4 <>''TW''
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
				 							FROM INSERTED
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
				 							FROM INSERTED
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
						on TicketStaging.intOriginTicketId =  b.A4GLIdentity AND (b.gasct_disc_cd is not null and b.gasct_disc_cd <> '''')
							 AND i.strShortName = b.gasct_disc_cd  COLLATE Latin1_General_CI_AS

								where TicketStaging.strInOutFlag = ''O''

					
						----- Calculating Discount information

						--Scale Station
						declare @is_multiple_weight bit
						--Ticket
						declare @scale_setup int
						declare @ticket_gross_w0 DECIMAL(24, 4) = 0
						declare @ticket_gross_w1 DECIMAL(24, 4) = 0
						declare @ticket_gross_w2 DECIMAL(24, 4) = 0
						declare @ticket_convert_uom DECIMAL(24, 10) = 0
						declare @ticket_delivery_sheet int
						declare @ticket_item_id int 

						--Getting Ticket Information
						select 
							--dblNetUnits	
							@scale_setup = intScaleSetupId
							,@ticket_gross_w0 = dblGrossWeight - dblTareWeight
							--,@ticket_gross_w1 = dblGrossWeight1 - dblTareWeight1
							--,@ticket_gross_w2 = dblGrossWeight2 - dblTareWeight2
							,@ticket_convert_uom = dblConvertedUOMQty
							,@ticket_delivery_sheet = intDeliverySheetId
							,@ticket_item_id  = intItemId
							--, dblShrink 

						from tblSCTicketLVStaging with(updlock)

						where intTicketLVStagingId = @newLVTicket

						select @is_multiple_weight = ysnMultipleWeights 
							from tblSCScaleSetup 
								where intScaleSetupId = @scale_setup

						declare @discount_calculation_success_message nvarchar(100) = ''Success''
						declare @discount_captured_message nvarchar(max) = ''''
						declare @discount_has_issue bit = 0

						declare @calculated_discount table (
								intExtendedKey int
								,dblFrom DECIMAL(24, 6)
								,dblTo DECIMAL(24, 6)
								,dblDiscountAmount DECIMAL(24, 6)
								,dblShrink DECIMAL(24, 6)
								,strMessage nvarchar(max)
								,intDiscountCalculatingOptionId int
								,strDiscountChargeType nvarchar(50)
								,strCalculationDiscountOption nvarchar(50)
								,intShrinkCalculationOptionId int
								,strCalculationShrinkOption nvarchar(50)
								,intDiscountUOMId int
							)

						
						declare @discounts_table as table(
							id int
							,intDiscountScheduleCodeId int
							,dblReading DECIMAL(24, 6)
						)
						insert into @discounts_table(id, intDiscountScheduleCodeId, dblReading)
						select intTicketDiscountLVStagingId, intDiscountScheduleCodeId, dblGradeReading 
							from tblSCTicketDiscountLVStaging with(updlock) 
							where intTicketId = @newLVTicket 
							
								and dblGradeReading <> 0



						declare @current_discount_id int
						declare @current_discount_schedule int
						declare @current_reading DECIMAL(24, 6)
						declare @current_discount_result DECIMAL(24, 6)
						declare @current_shrink_result DECIMAL(24, 6)
						declare @current_discount_message nvarchar(max)
						


						select @current_discount_id = min(id) from @discounts_table
						while @current_discount_id is not null
						begin
							select @current_discount_schedule = intDiscountScheduleCodeId
								,@current_reading = dblReading
							from @discounts_table
								where id = @current_discount_id 

							delete from @calculated_discount
							insert into @calculated_discount
							exec uspGRCalculateDiscountandShrink 
								@intDiscountScheduleCodeId = @current_discount_schedule
								, @dblReading = @current_reading
								, @intItemId = @ticket_item_id
								, @intItemUOMId = 0

							
							select @current_discount_result = case when lower(strDiscountChargeType) = ''dollar'' then dblDiscountAmount else dblDiscountAmount / 100 end 
								, @current_shrink_result = dblShrink
								, @current_discount_message = strMessage								
							from @calculated_discount

							if @current_discount_message <> @discount_calculation_success_message --and @discount_has_issue = 0
							begin
								select top 1 @current_discount_message = ''Discount('' + Item.strShortName + '')-'' +  @current_discount_message
									from tblGRDiscountScheduleCode DiscountSchedCode
										join tblICItem Item
											on DiscountSchedCode.intItemId = Item.intItemId
									where DiscountSchedCode.intDiscountScheduleCodeId = @current_discount_schedule
								

								select @discount_captured_message = @discount_captured_message + @current_discount_message + '','' 
									,@discount_has_issue = 1

							end

							update tblSCTicketDiscountLVStaging
								set dblShrinkPercent = @current_shrink_result
								,dblDiscountAmount = @current_discount_result

								where intTicketDiscountLVStagingId = @current_discount_id


							select @current_discount_id = min(id) 
								from @discounts_table where id > @current_discount_id

						end


						if @discount_captured_message <> ''''
						begin
							set @discount_captured_message = replace(@discount_captured_message, ''Invalid reading value entered'', ''Invalid reading value'')
							set @discount_captured_message = replace(@discount_captured_message, '' Minimum Reading'', ''Minimum'')
							set @discount_captured_message = replace(@discount_captured_message, ''Maximum Reading'', ''Maximum'')

						end
						--Discount
						--Wet Weight
						declare @discount_ww DECIMAL(24, 4) = 0
						--Net Weight
						declare @discount_nw DECIMAL(24, 4)  = 0
						--Gross Weight
						declare @discount_gw DECIMAL(24, 4)  = 0


						declare @gross_shrink_w DECIMAL(24, 4)
						declare @wet_shrink_w DECIMAL(24, 4)
						declare @net_shrink_w DECIMAL(24, 4)
						-- Final computation
						--Wet Weight
						declare @ww DECIMAL(24, 4) = 0
						declare @ws_ww DECIMAL(24, 4) = 0
						--Net Weight
						declare @nw DECIMAL(24, 4)  = 0
						--Gross Weight
						declare @gw DECIMAL(24, 4)  = 0



						declare @final_gross DECIMAL(24, 4)
						declare @final_shrink DECIMAL(24, 4)
						declare @final_net DECIMAL(24, 4)

						--Holder for the weight group
						declare @all_w table (
							--total per weight group
							total_w DECIMAL(24, 4)
							-- weight group header
							,what_w nvarchar(50)

						)
						--get the total shrink per group header
						insert into @all_w (total_w, what_w)
						select sum(dblShrinkPercent), strShrinkWhat 
							from tblSCTicketDiscountLVStaging 
								where intTicketId = @newLVTicket 
						group by strShrinkWhat

						--assign the right weight to the variable to be used later in the computation
						select @discount_ww = case when what_w = ''Wet Weight'' or what_w = ''W'' then @discount_ww + total_w else @discount_ww end
							, @discount_nw = case when what_w = ''Net Weight'' or what_w = ''N'' then @discount_nw + total_w else @discount_nw end
							, @discount_gw = case when what_w = ''Gross Weight'' or what_w = ''P'' then @discount_gw + total_w else @discount_gw end

							from @all_w 

						-- if the scale station is a multi weight add the gross 0, 1, 2
						if @is_multiple_weight = 1
						begin
							set @ticket_gross_w0 = @ticket_gross_w0 + @ticket_gross_w1 + @ticket_gross_w2
						end


						select @gross_shrink_w = ( @ticket_gross_w0 * @discount_gw ) / 100
						select @ww = @ticket_gross_w0 - @gross_shrink_w

						select @wet_shrink_w = (@ww * @discount_ww ) / 100
						select @ws_ww = @ww - @wet_shrink_w

						select @net_shrink_w = (@ws_ww * @discount_nw ) / 100


						select @final_gross = @ticket_gross_w0 * @ticket_convert_uom
						select @final_shrink = case when isnull(@ticket_delivery_sheet, 0) > 0 then 0 else (@gross_shrink_w + @wet_shrink_w + @net_shrink_w) * @ticket_convert_uom end
						select @final_net = @final_gross - @final_shrink

						
						update  tblSCTicketLVStaging
							set dblNetUnits = @final_net
								, dblGrossUnits = @final_gross
								, dblShrink = @final_shrink
						where intTicketLVStagingId = @newLVTicket



						----- End calculating discount information






						declare @ticket_number nvarchar(100)
						declare @inserted_ticket_number int
						declare @validation_message nvarchar(max)
						

						select @validation_message = dbo.fnSCValidateTicketStagingTable(@newLVTicket) + isnull(LTRIM(RTRIM(@discount_captured_message)), '''')
						--select @validation_message
						if @validation_message = ''''
						begin
							select @ticket_number = strTicketNumber from tblSCTicketLVStaging where intTicketLVStagingId = @newLVTicket

							begin try
						
							
								update tblSCTicketLVStaging set ysnProcessedData = 1 where intTicketLVStagingId = @newLVTicket
								if not exists(select top 1 1 from tblSCTicket where strTicketNumber = @ticket_number and strSourceType = ''LV Control'')	
									exec uspSCProcessLVControlToTicket @newLVTicket, 1, @IrelyAdminId

							end try
							begin catch
							
								update tblSCTicketLVStaging set ysnProcessedData = 0 where intTicketLVStagingId = @newLVTicket

								select @inserted_ticket_number = intTicketId 
									from tblSCTicket 
										where intTicketLVStagingId = @newLVTicket
							 
								update tblSCTicket 
										set ysnHasGeneratedTicketNumber = 0, dtmDateModifiedUtc = GETUTCDATE() 
											where intTicketLVStagingId = @newLVTicket

								delete from tblQMTicketDiscount 
									where intTicketId = @inserted_ticket_number
								delete from tblSCTicket 
									where intTicketId =  @inserted_ticket_number 
										and intTicketLVStagingId = @newLVTicket

							end catch
						end
						else 
						begin
							update tblSCTicketLVStaging set strImportFailedReason = @validation_message where intTicketLVStagingId = @newLVTicket
						end 
						delete from gasctmst where gasct_tic_no in (select gasct_tic_no from INSERTED)

					end 
					
				end
				

				--end try
				--begin catch
				--	--print ERROR_MESSAGE()
				--end catch
			END
		')
		PRINT 'End creating trigger'
	END
GO
