GO
IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()) = 1 and
    (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gasctmst') = 1
BEGIN
    PRINT 'BEGIN vyuSCTicketLVControlView '
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
                    WHEN gasct_dist_option = ''C'' THEN ''Contract''
                    WHEN gasct_dist_option = ''S'' THEN ''Spot Sale''
                    ELSE gasct_dist_option
                END) AS strDistributionOption
            ,gasct_pit_no AS strPitNumber
            ,gasct_tic_pool AS strTicketPool
            ,gasct_spl_no AS strSplitNumber
        from gasctmst
        ')
END
GO