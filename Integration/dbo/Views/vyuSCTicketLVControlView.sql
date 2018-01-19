GO
IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblSMBuildNumber')
BEGIN
IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()) = 1 and
    (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gasctmst') = 1
	BEGIN
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
				INSERT INTO tblSCTicketLVStaging SELECT TOP 1 
					LTRIM(RTRIM(SC.strTicketNumber))
					,LTRIM(RTRIM(SC.strTicketType))
					,LTRIM(RTRIM(SC.strInOutFlag))
					,SC.dtmTicketDateTime
					,LTRIM(RTRIM(SC.strTicketStatus))
					,LTRIM(RTRIM(SC.strItemNo))
					,LTRIM(RTRIM(SC.strLocationNumber))
					,LTRIM(RTRIM(SC.dblGrossWeight))
					,SC.dtmGrossDateTime
					,LTRIM(RTRIM(SC.dblTareWeight))
					,SC.dtmTareDateTime
					,LTRIM(RTRIM(SC.strTicketComment))
					,LTRIM(RTRIM(SC.strDiscountId))
					,LTRIM(RTRIM(SC.dblFreightRate))
					,LTRIM(RTRIM(SC.strHaulerName))
					,LTRIM(RTRIM(SC.dblTicketFees))
					,LTRIM(RTRIM(SC.ysnFarmerPaysFreight))
					,LTRIM(RTRIM(SC.strCurrency))
					,LTRIM(RTRIM(SC.strBinNumber))
					,LTRIM(RTRIM(SC.strContractNumber))
					,LTRIM(RTRIM(SC.intContractSequence))
					,LTRIM(RTRIM(SC.strScaleOperatorUser))
					,LTRIM(RTRIM(SC.strTruckName))
					,LTRIM(RTRIM(SC.strDriverName))
					,LTRIM(RTRIM(SC.strCustomerReference))
					,LTRIM(RTRIM(SC.intAxleCount))
					,LTRIM(RTRIM(SC.ysnDriverOff))
					,LTRIM(RTRIM(SC.ysnGrossManual))
					,LTRIM(RTRIM(SC.ysnTareManual))
					,LTRIM(RTRIM(SC.strDistributionOption))
					,LTRIM(RTRIM(SC.strPitNumber))
					,LTRIM(RTRIM(SC.strTicketPool))
					,LTRIM(RTRIM(SC.strSplitNumber))
					,0
				 FROM vyuSCTicketLVControlView SC 
				INNER JOIN INSERTED IR ON SC.strTicketNumber = IR.gasct_tic_no
			END
		')
		PRINT 'End creating trigger'

		PRINT 'Begin creating tblSCTicketLVStaging table'
		EXEC ('
			IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N''tblSCTicketLVStaging'')
				CREATE TABLE [dbo].[tblSCTicketLVStaging]
				(
					[intTicketId] INT NOT NULL IDENTITY, 
					[strTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
					[strTicketType] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
					[strInOutFlag] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL,
					[dtmTicketDateTime] DATETIME NULL, 
					[strTicketStatus] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
					[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
					[strLocationNumber] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
					[dblGrossWeight] DECIMAL(13, 3) NULL, 
					[dtmGrossDateTime] DATETIME NULL, 
					[dblTareWeight] DECIMAL(13, 3) NULL,
					[dtmTareDateTime] DATETIME NULL, 
					[strTicketComment] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL,
					[strDiscountId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
					[dblFreightRate] NUMERIC(38, 20) NULL, 
					[strHaulerName] NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
					[dblTicketFees]	NUMERIC(38, 20) NULL, 
					[ysnFarmerPaysFreight] BIT NULL, 
					[strCurrency] NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
					[strBinNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
					[strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
					[intContractSequence] INT NULL, 
					[strScaleOperatorUser] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
					[strTruckName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
					[strDriverName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
					[strCustomerReference] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
					[intAxleCount] INT NULL, 
					[ysnDriverOff] BIT NULL, 
					[ysnGrossManual] BIT NULL, 
					[ysnTareManual] BIT NULL, 
					[strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL, 
					[strPitNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
					[strTicketPool] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
					[strSplitNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,    
					[ysnProcessedData] BIT NULL DEFAULT((0)),
					CONSTRAINT [PK_tblSCTicketLVStaging_intTicketId] PRIMARY KEY ([intTicketId]), 
				)
		')
		PRINT 'End creating tblSCTicketLVStaging table'

		PRINT 'Begin creating vyuSCTicketLVControlView '
		EXEC ('
			IF OBJECT_ID(''vyuSCTicketLVControlView'', ''V'') IS NOT NULL 
			DROP VIEW vyuSCTicketLVControlView
		')
		EXEC ('
			CREATE VIEW [dbo].[vyuSCTicketLVControlView]
			AS SELECT 
				gasct_tic_no AS strTicketNumber
				,(CASE 
					WHEN gasct_tic_type = ''I'' THEN ''Load In''
					WHEN gasct_tic_type = ''O'' THEN ''Load Out''
					WHEN gasct_tic_type = ''M'' THEN ''Memo Weight''
					ELSE gasct_tic_type
				END) AS strTicketType
				,gasct_tic_type AS strInOutFlag
				,(CASE 
					WHEN gasct_rev_dt > 1 THEN convert(datetime, convert(char(8), gasct_rev_dt))
					ELSE NULL
				END ) AS dtmTicketDateTime
				, gasct_open_close_ind as strTicketStatus
				,gasct_itm_no AS strItemNo
				,gasct_loc_no AS strLocationNumber
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
				,gasct_trkr_no AS strHaulerName
				,gasct_fees AS dblTicketFees
				,CAST(
					CASE WHEN gasct_frt_deduct_yn = ''Y'' THEN 1
					ELSE 0 END
					AS BIT) AS ysnFarmerPaysFreight
				,gasct_currency AS strCurrency
				,gasct_bin_no AS strBinNumber
				,gasct_cnt_no AS strContractNumber
				,gasct_cnt_seq AS intContractSequence
				,gasct_weigher AS strScaleOperatorUser
				,gasct_truck_id AS strTruckName
				,gasct_driver as strDriverName
				,gasct_cus_ref_no AS strCustomerReference
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
				,gasct_pit_no AS strPitNumber
				,gasct_tic_pool AS strTicketPool
				,gasct_spl_no AS strSplitNumber
			from gasctmst
		')
		PRINT 'End creating vyuSCTicketLVControlView table'
	END
END
GO