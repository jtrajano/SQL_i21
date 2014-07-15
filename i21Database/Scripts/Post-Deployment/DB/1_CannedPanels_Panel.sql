
/*******************  BEGIN UPDATING canned panels on table Panel *******************/
print('/*******************  BEGIN UPDATING canned panels  *******************/')

IF OBJECT_ID('tempdb..#TempCannedPanels') IS NOT NULL
    DROP TABLE #TempCannedPanels

print('/*******************  CREATE TEMPORARY table for canned panels  *******************/')
Create TABLE #TempCannedPanels 
(
	[intPanelId]            INT             NOT NULL,
    [intRowsReturned]       INT             NOT NULL,
    [intRowsVisible]        SMALLINT        NOT NULL,
    [intChartZoom]          SMALLINT        NOT NULL,
    [intChartHeight]        SMALLINT        NOT NULL,
    [intUserId]             INT             NOT NULL,
    [intDefaultColumn]      SMALLINT        NULL,
    [intDefaultRow]         SMALLINT        NULL,
    [intDefaultWidth]       SMALLINT        NULL,
    [intSourcePanelId]      INT             NOT NULL,
    [intConnectionId]       INT             NOT NULL,
    [intDrillDownPanel]     INT             NOT NULL,
    [strClass]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strPanelName]          NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strStyle]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strAccessType]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCaption]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strChart]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strChartPosition]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strChartColor]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strConnectionName]     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDateCondition]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDateCondition2]     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDateFieldName]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDateFieldName2]     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDataSource]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDataSource2]        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDateVariable]       NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDateVariable2]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDefaultTab]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPanelNameDuplicate] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPanelType]          NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strQBCriteriaOptions]  NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strFilterCondition]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFilterVariable]     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFilterFieldName]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFilterVariable2]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFilterFieldName2]   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strGroupFields]        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFilters]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,	
	[strConfigurator]       NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,    
    [ysnChartLegend]        BIT             DEFAULT ((0)) NOT NULL,
	[ysnShowInGroups]       BIT             DEFAULT ((0)) NOT NULL,
    [imgLayoutGrid]         VARBINARY (MAX) NULL,
    [imgLayoutPivotGrid]    VARBINARY (MAX) NULL,
    [strPanelVersion]       NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS DEFAULT ((14.2)) NOT NULL,    
	[intFilterId]			INT				NULL,
	[intConcurrencyId ]		INT				NOT NULL DEFAULT ((1)),           
	[intCannedPanelId]		INT				NOT NULL DEFAULT ((0)),
	[strSortValue]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
)

print('/*******************  BEGIN INSERTING canned panels on temporary panel table  *******************/')
INSERT INTO #TempCannedPanels VALUES (2, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely AG - Inventory Overview Detail', N'Grid', N'', N'iRely AG - Inventory Overview Detail', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agitmmst.agitm_class, agitmmst.agitm_no, agitmmst.agitm_loc_no, agitmmst.agitm_desc, agitmmst.agitm_un_desc, agitmmst.agitm_avg_un_cost, agitmmst.agitm_un_on_hand, agitmmst.agitm_last_un_cost, agitmmst.agitm_pak_desc, agitmmst.agitm_phys_inv_ynbo From agitmmst Where agitmmst.agitm_phys_inv_ynbo = ''Y'' Order By agitm_un_on_hand', N'', N'', N'', N'', N'', N'iRely AG - Inventory Overview Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 45, NULL)
INSERT INTO #TempCannedPanels VALUES (3, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely Grain - Grain Postion Detail ', N'Grid', N'', N'iRely Grain - Grain Position Detail', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select gacommst.gacom_desc, gaposmst.gapos_loc_no, gaposmst.gapos_in_house, gaposmst.gapos_offsite, gaposmst.gapos_sls_in_transit From gaposmst Left Join gacommst On gaposmst.gapos_com_cd = gacommst.gacom_com_cd', N'', N'', N'', N'', N'', N'iRely Grain - Grain Postion Detail ', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 19, NULL)
INSERT INTO #TempCannedPanels VALUES (4, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely Petro - Invoice Margins Below 0 - Detail', N'Grid', N'', N'iRely Petro - Invoice Margins Below 0 - Detail', N'', N'', N'', N'i21 PT - Berry Oil ', N'All Dates', N'All Dates', N'ptstmmst.ptstm_rev_dt', N'', N'Select ptstmmst.ptstm_bill_to_cus, ptstm_ivc_no, ptstmmst.ptstm_ship_rev_dt, ptstmmst.ptstm_itm_no, ptstmmst.ptstm_loc_no, ptstmmst.ptstm_class, ptstmmst.ptstm_un, ptstmmst.ptstm_un_prc, ptstmmst.ptstm_net, ptstmmst.ptstm_cgs, ptstmmst.ptstm_slsmn_id, ptstmmst.ptstm_pak_desc, ptstmmst.ptstm_un_desc, ptstmmst.ptstm_net - ptstmmst.ptstm_cgs As ''Profit Amount'', (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net*100 As ''Profit Percent'' From ptstmmst Where (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net Is Not Null And @DATE@ And ptstmmst.ptstm_net <> 0 And (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net*100 < ''0'' Order By (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net', N'', N'@DATE@', N'', N'', N'', N'iRely Petro - Invoice Margins Below 0 - Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 57, NULL)
INSERT INTO #TempCannedPanels VALUES (5, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely Petro - Inventory Overview Detail', N'Grid', N'', N'iRely Petro - Inventory Overview Detail', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'Select ptitmmst.ptitm_itm_no, ptitmmst.ptitm_desc, ptitmmst.ptitm_loc_no, ptitmmst.ptitm_class, ptitmmst.ptitm_unit, ptitmmst.ptitm_cost1, ptitmmst.ptitm_avg_cost, ptitmmst.ptitm_std_cost, ptitmmst.ptitm_on_hand, ptitmmst.ptitm_std_cost From ptitmmst Where ptitmmst.ptitm_phys_inv_yno = ''Y''', N'', N'', N'', N'', N'', N'iRely Petro - Inventory Overview Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 63, NULL)
INSERT INTO #TempCannedPanels VALUES (6, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely AG - Open Contracts Detail', N'Grid', N'', N'iRely AG - Open Contracts Detail', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agcntmst.agcnt_cus_no, agcusmst.agcus_last_name, agcusmst.agcus_first_name, agcntmst.agcnt_loc_no, agcntmst.agcnt_cnt_no, agcntmst.agcnt_cnt_rev_dt, agcntmst.agcnt_due_rev_dt, agcntmst.agcnt_itm_or_cls, agcntmst.agcnt_prc_lvl, agcntmst.agcnt_ppd_yndm, agcntmst.agcnt_un_orig, agcntmst.agcnt_un_prc, agcntmst.agcnt_un_bal, agcntmst.agcnt_slsmn_id From agcntmst Left Join agcusmst ON agcntmst.agcnt_cus_no = agcusmst.agcus_key Where (agcntmst.agcnt_itm_or_cls <> ''*'' And agcntmst.agcnt_un_bal > 0.0)', N'', N'', N'', N'', N'', N'iRely AG - Open Contracts Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 50, NULL)
INSERT INTO #TempCannedPanels VALUES (8, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely AG - Inventory Available for Sale Detail', N'Grid', N'', N'iRely AG - Inventory Available for Sale Detail', N'', N'', N'', N'i21 AG - Demo Test', N'None', N'', N'', N'', N'Select agitmmst.agitm_no, agitmmst.agitm_loc_no, agitmmst.agitm_desc, agitmmst.agitm_class, agitmmst.agitm_un_desc, agitmmst.agitm_un_on_hand, agitmmst.agitm_un_pend_ivcs, agitmmst.agitm_un_on_order, agitmmst.agitm_un_mfg_in_prs, agitmmst.agitm_un_fert_committed, agitmmst.agitm_un_ord_committed, agitmmst.agitm_un_cnt_committed,  agitmmst.agitm_un_on_hand-agitmmst.agitm_un_pend_ivcs+agitmmst.agitm_un_on_order+agitmmst.agitm_un_mfg_in_prs-agitmmst.agitm_un_fert_committed-agitmmst.agitm_un_cnt_committed-agitmmst.agitm_un_ord_committed As [Available] From agitmmst', N'', N'', N'', N'', N'', N'iRely AG - Inventory Available for Sale Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.2.2', NULL, 1, 53, NULL)


INSERT INTO #TempCannedPanels VALUES (1, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely AG - Invoice Margins Below 0 - Detail', N'Grid', N'', N'iRely AG - Invoice Margins Below 0 - Detail', N'', N'', N'', N'FortBooks', N'All Dates', N'All Dates', N'agstmmst.agstm_ship_rev_dt', N'', N'Select agstmmst.agstm_bill_to_cus, agstmmst.agstm_ivc_no, agstmmst.agstm_ship_rev_dt, agstmmst.agstm_itm_no, agstmmst.agstm_loc_no, agstmmst.agstm_class, agstmmst.agstm_un, agstmmst.agstm_un_prc, agstmmst.agstm_sls, agstmmst.agstm_un_cost, agstmmst.agstm_cgs, agstmmst.agstm_slsmn_id, agstmmst.agstm_pak_desc, agstmmst.agstm_un_desc, agstmmst.agstm_un_prc - agstmmst.agstm_un_cost As ''unit margins'', agstmmst.agstm_sls - agstmmst.agstm_cgs As ''Profit Amount'', (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls*100 As ''Profit Percent'' From agstmmst Where agstmmst.agstm_itm_no Is Not Null And agstmmst.agstm_sls <> 0 And (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls Is Not Null And @DATE@ And (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls*100 <''0'' Order By (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls', N'', N'@DATE@', N'', N'', N'', N'iRely AG - Invoice Margins Below 0 - Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.2.3', NULL, 1, 49, NULL)
INSERT INTO #TempCannedPanels VALUES (7, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely GL - General Ledger History Detail', N'Grid', N'', N'iRely GL - General Ledger History Detail', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhstmst.glhst_trans_dt', N'', N'Select glhstmst.glhst_acct1_8, glhstmst.glhst_acct9_16, glhstmst.glhst_period, glhstmst.glhst_trans_dt, glhstmst.glhst_src_id, glhstmst.glhst_src_seq, glhstmst.glhst_dr_cr_ind, glhstmst.glhst_jrnl_no, glhstmst.glhst_ref, glhstmst.glhst_doc, Case When glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End As Amount, glhstmst.glhst_units, glhstmst.glhst_date From glhstmst Where @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely GL - General Ledger History Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.2.2', NULL, 1, 26, NULL)
INSERT INTO #TempCannedPanels VALUES (9, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - A/R Customers 120 Days Past Due', N'Grid', N'', N'iRely AG - A/R Customers 120 Days Past Due **MUST REAGE DAILY TO BE ACCURATELY UPDATED**', N'', N'', N'', N'i21 AG - Demo Test', N'None', N'', N'', N'', N'select agcusmst.agcus_last_name, agcusmst.agcus_first_name, agcusmst.agcus_key,
agcusmst.agcus_ar_per5 as ''Amount''
from agcusmst where (agcusmst.agcus_ar_per5>0)', N'', N'', N'', N'', N'', N'iRely AG - A/R Customers 120 Days Past Due', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 44, NULL)
INSERT INTO #TempCannedPanels VALUES (10, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - A/R Summary', N'Grid', N'', N'iRely AG - A/R Summary **MUST REAGE DAILY TO BE ACCURATELY UPDATED**', N'', N'', N'', N'i21 AG - Demo Test', N'None', N'', N'', N'', N'select sum(agcusmst.agcus_ar_future) as ''Future'', sum(agcusmst.agcus_ar_per1) as ''Current'', sum(agcusmst.agcus_ar_per2) as ''30days'', sum(agcusmst.agcus_ar_per3) as ''60days'', sum(agcusmst.agcus_ar_per4) as ''90days'', sum(agcusmst.agcus_ar_per5) as ''120days''
from agcusmst
', N'', N'', N'', N'', N'', N'iRely AG - A/R Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1.1', NULL, 1, 47, NULL)
INSERT INTO #TempCannedPanels VALUES (11, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Bank Account Balances', N'Grid', N'', N'iRely AP - Bank Account Balances', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'SELECT apcbkmst.apcbk_desc, apcbkmst.apcbk_no, apcbkmst.apcbk_bal From apcbkmst', N'', N'', N'', N'', N'', N'iRely AP - Bank Account Balances', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1.1', NULL, 1, 37, NULL)
INSERT INTO #TempCannedPanels VALUES (12, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Customers Over Credit Limit', N'Grid', N'', N'iRely AG - Customers Over Credit Limit', N'', N'', N'', N'i21 AG - Demo Test', N'None', N'', N'', N'', N'Select agcusmst.agcus_key, agcusmst.agcus_last_name, agcusmst.agcus_first_name, agcusmst.agcus_cred_limit, 
agcusmst.agcus_ar_future+agcusmst.agcus_ar_per1+agcusmst.agcus_ar_per3+agcusmst.agcus_ar_per2+agcusmst.agcus_ar_per4+agcusmst.agcus_ar_per5-agcusmst.agcus_cred_reg-agcusmst.agcus_cred_ppd As ''Total Balance'', agcusmst.agcus_cred_limit-(agcusmst.agcus_ar_future+agcusmst.agcus_ar_per1+agcusmst.agcus_ar_per3+agcusmst.agcus_ar_per2+agcusmst.agcus_ar_per4+agcusmst.agcus_ar_per5-agcusmst.agcus_cred_reg-agcusmst.agcus_cred_ppd) As ''Overage'' From agcusmst Where agcusmst.agcus_active_yn = ''Y'' And agcusmst.agcus_last_stmt_bal <> 0 And agcusmst.agcus_cred_limit-(agcusmst.agcus_ar_future+agcusmst.agcus_ar_per1+agcusmst.agcus_ar_per3+agcusmst.agcus_ar_per2+agcusmst.agcus_ar_per4+agcusmst.agcus_ar_per5-agcusmst.agcus_cred_reg-agcusmst.agcus_cred_ppd) < 0', N'', N'', N'', N'', N'', N'iRely AG - Customers Over Credit Limit', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1.3', NULL, 1, 1, NULL)
INSERT INTO #TempCannedPanels VALUES (13, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Check History', N'Grid', N'', N'iRely AP - Check History', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'apchk_rev_dt', N'', N'select apchkmst.apchk_cbk_no, apchkmst.apchk_rev_dt, apchkmst.apchk_vnd_no, apchkmst.apchk_name, apchkmst.apchk_chk_amt, apchkmst.apchk_disc_amt, apchkmst.apchk_gl_rev_dt, apchkmst.apchk_cleared_ind, apchkmst.apchk_clear_rev_dt, apchkmst.apchk_src_sys, apchkmst.apchk_rev_dt
From apchkmst Where @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely AP - Check History', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.2', NULL, 1, 36, NULL)
INSERT INTO #TempCannedPanels VALUES (14, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Open Payables', N'Grid', N'', N'iRely AP - Open Payables', N'', N'', N'', N'Fort Books TE', N'None', N'', N'', N'', N'Select apivcmst.apivc_ivc_no, apivcmst.apivc_ivc_rev_dt, apivcmst.apivc_status_ind, apivcmst.apivc_vnd_no, apivcmst.apivc_due_rev_dt, Case When apivcmst.apivc_trans_type = ''C'' Or apivcmst.apivc_trans_type = ''A'' Then apivcmst.apivc_net_amt * -1 Else apivcmst.apivc_net_amt End As ''amounts'', ssvndmst.ssvnd_name From apivcmst Left Join ssvndmst On apivcmst.apivc_vnd_no = ssvndmst.ssvnd_vnd_no Where apivcmst.apivc_status_ind = ''U''', N'', N'', N'', N'', N'', N'iRely AP - Open Payables', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.2', NULL, 1, 73, NULL)
INSERT INTO #TempCannedPanels VALUES (15, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Outstanding Checks', N'Grid', N'', N'iRely AP - Outstanding Checks', N'', N'', N'', N'i21 PT - Berry Oil ', N'This Year', N'This Year', N'apchk_rev_dt', N'', N'Select apchkmst.apchk_rev_dt, apchkmst.apchk_name, apchkmst.apchk_chk_amt, apchkmst.apchk_cleared_ind From apchkmst Where apchkmst.apchk_cleared_ind Is Null And @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely AP - Outstanding Checks', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.2', NULL, 1, 35, NULL)
INSERT INTO #TempCannedPanels VALUES (16, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Paid Payables History', N'Grid', N'', N'iRely AP - Paid Payables History', N'', N'', N'', N'i21 PT - Berry Oil ', N'This Year', N'', N'apivc_ivc_rev_dt', N'', N'Select apivcmst.apivc_ivc_no, apivcmst.apivc_ivc_rev_dt, apivcmst.apivc_status_ind, apivcmst.apivc_vnd_no, apivcmst.apivc_due_rev_dt, Case When apivcmst.apivc_trans_type = ''C'' Or apivcmst.apivc_trans_type = ''A'' Then apivcmst.apivc_net_amt * -1 Else apivcmst.apivc_net_amt End As ''amounts'', ssvndmst.ssvnd_name From apivcmst Left Join ssvndmst On apivcmst.apivc_vnd_no = ssvndmst.ssvnd_vnd_no Where apivcmst.apivc_status_ind = ''U'' And @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely AP - Paid Payables History', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1.1', NULL, 1, 38, NULL)
INSERT INTO #TempCannedPanels VALUES (17, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Revenue vs Costs Monthly', N'Chart', N'', N'iRely AG - Revenue vs Costs Monthly', N'Column', N'outside', N'', N'i21 AG - Demo Test', N'This Year', N'This Year', N'agstmmst.agstm_ship_rev_dt', N'agstmmst.agstm_ship_rev_dt', N'Select Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112)) As ''Month'', Sum(agstmmst.agstm_sls) As ''Sales'' From agstmmst Where @DATE@
Group By Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112)) 
Order By Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112))', N'Select Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112)) As ''Month'', Sum(agstmmst.agstm_cgs) As ''Costs'' From agstmmst Where @DATE@
Group By Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112)) 
Order By Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112))', N'@DATE@', N'@DATE@', N'', N'', N'iRely AG - Revenue vs Costs Monthly', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 65, NULL)
INSERT INTO #TempCannedPanels VALUES (18, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Sales by Customer', N'Grid', N'', N'iRely AG - Sales by Customer', N'', N'', N'', N'i21 AG - Demo Test', N'Last Month', N'All Dates', N'agstmmst.agstm_ship_rev_dt', N'', N'SELECT agcusmst.agcus_last_name AS ''Customer Last Name'', agcusmst.agcus_first_name AS ''First Name'', agcusmst.agcus_key AS ''Customer Code'', Sum(agstmmst.agstm_sls) AS ''Sales'', Sum(agstmmst.agstm_un) as ''Units''
FROM agstmmst 
Left Join agcusmst On agstmmst.agstm_bill_to_cus = agcusmst.agcus_key
Where @DATE@
GROUP BY agcusmst.agcus_last_name, agcusmst.agcus_first_name, agcusmst.agcus_key 
ORDER BY Sum(agstmmst.agstm_sls) DESC', N'', N'@DATE@', N'', N'', N'', N'iRely AG - Sales by Customer', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 69, NULL)
INSERT INTO #TempCannedPanels VALUES (19, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Sales by Item/Product', N'Grid', N'', N'iRely AG - Sales by Item/Product', N'', N'', N'', N'i21 AG - Demo Test', N'Last Month', N'', N'agstmmst.agstm_ship_rev_dt', N'', N'Select agstmmst.agstm_itm_no, agitmmst.agitm_desc, Sum(agstmmst.agstm_sls) As ''Sales'', Sum(agstmmst.agstm_un) As ''Units'' From agstmmst Left Join agitmmst On agstmmst.agstm_itm_no = agitmmst.agitm_no And agstmmst.agstm_loc_no = agitmmst.agitm_loc_no Where @DATE@ And agstmmst.agstm_sls <> 0 Group By agstmmst.agstm_itm_no, agitmmst.agitm_desc Order By Sum(agstmmst.agstm_sls) Desc', N'', N'@DATE@', N'', N'', N'', N'iRely AG - Sales by Item/Product', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 70, NULL)
INSERT INTO #TempCannedPanels VALUES (20, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Sales by Location ', N'Chart', N'', N'iRely AG - Sales by Location ', N'Bar', N'outside', N'Category5', N'FortBooks', N'This Year', N'This Year', N'agstmmst.agstm_ship_rev_dt', N'agstmmst.agstm_ship_rev_dt', N'Select agstmmst.agstm_key_loc_no, Sum(agstmmst.agstm_sls) As ''Sales'' From agstmmst Where @DATE@ Group By agstmmst.agstm_key_loc_no', N'Select agstmmst.agstm_key_loc_no, Sum(agstmmst.agstm_cgs) As ''Costs'' From agstmmst Where @DATE@ Group By agstmmst.agstm_key_loc_no', N'@DATE@', N'@DATE@', N'', N'', N'iRely AG - Sales by Location ', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 46, NULL)
INSERT INTO #TempCannedPanels VALUES (21, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Slow Moving Inventory', N'Grid', N'', N'iRely AG - Slow Moving Inventory', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agitmmst.agitm_no, agitmmst.agitm_loc_no, agitmmst.agitm_desc, agitmmst.agitm_un_on_hand, agitmmst.agitm_last_sale_rev_dt, agitmmst.agitm_phys_inv_ynbo, agitmmst.agitm_un_desc From agitmmst Where agitmmst.agitm_phys_inv_ynbo = ''Y'' and agitmmst.agitm_last_sale_rev_dt <>''0''
 Order By agitmmst.agitm_last_sale_rev_dt', N'', N'', N'', N'', N'', N'iRely AG - Slow Moving Inventory', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 72, NULL)
INSERT INTO #TempCannedPanels VALUES (22, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Orders', N'Grid', N'', N'iRely AG - Orders', N'', N'', N'', N'i21 AG - Demo Test', N'None', N'', N'', N'', N'Select agordmst.agord_cus_no, agordmst.agord_ord_no, agordmst.agord_loc_no, agordmst.agord_ord_rev_dt, agordmst.agord_type, agordmst.agord_itm_no, agordmst.agord_pkg_sold From agordmst Where agordmst.agord_type = ''O'' ', N'', N'', N'', N'', N'', N'iRely AG - Orders', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 52, NULL)
INSERT INTO #TempCannedPanels VALUES (23, 0, 25, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Pivot Table', N'Pivot Grid', N'', N'i21 General Ledger - Pivot Table', N'', N'', N'', N'Fort Books TE', N'Last Month', N'Last Month', N'dtmDate', N'', N'Select tblGLDetail.*,
  tblGLAccount.*,
  tblGLAccountGroup.*
from tblGLDetail
left join tblGLAccount on tblGLDetail.intAccountId = tblGLAccount.intAccountId
            left join tblGLAccountGroup on tblGLAccount.intAccountGroupId = tblGLAccountGroup.intAccountGroupId
            WHERE ysnIsUnposted = 0 And @DATE@ ', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Pivot Table', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'{"aggregate":[],"leftAxis":[],"topAxis":[]}', 0, 0, NULL, NULL, N'14.1.7', NULL, 1, 74, NULL)
INSERT INTO #TempCannedPanels VALUES (24, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - GL History Detail', N'Grid', N'', N'i21 General Ledger - GL History Detail', N'', N'', N'', N'Fort Books TE', N'Last Month', N'Last Month', N'dtmDate', N'', N'Select tblGLAccount.strAccountId,
tblGLAccount.strDescription,
tblGLDetail.dtmDate,  
tblGLDetail.strTransactionId,
tblGLDetail.strReference,
tblGLAccountGroup.strAccountGroup,
tblGLDetail.dblDebit,
  tblGLDetail.dblCredit,
  dblDebit-dblCredit As Balance
from tblGLDetail
           left join tblGLAccount on tblGLDetail.intAccountId = tblGLAccount.intAccountId
            left join tblGLAccountGroup on tblGLAccount.intAccountGroupId = tblGLAccountGroup.intAccountGroupId
            WHERE ysnIsUnposted = 0 And @DATE@
Order By 
tblGLAccount.strAccountId
, tblGLAccount.strDescription', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - GL History Detail', N'', N'', N'', N'', N'', N'', N'', N'strAccountID', NULL, N'', 0, 0, NULL, NULL, N'14.1.9', NULL, 1, 75, NULL)
INSERT INTO #TempCannedPanels VALUES (25, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - GL Summary', N'Grid', N'', N'i21 General Ledger - GL Summary   ***Drill Down***', N'', N'', N'', N'Fort Books TE', N'Last Month', N'All Dates', N'dtmDate', N'', N'Select tblGLAccount.strAccountId
,tblGLAccount.strDescription
,Sum(dblDebit-dblCredit) As Balance
from tblGLDetail
           left join tblGLAccount on tblGLDetail.intAccountId = tblGLAccount.intAccountId
            left join tblGLAccountGroup on tblGLAccount.intAccountGroupId = tblGLAccountGroup.intAccountGroupId
            WHERE ysnIsUnposted = 0 and @DATE@
Group By 
tblGLAccount.strAccountId
, tblGLAccount.strDescription
Order By 
tblGLAccount.strAccountId
, tblGLAccount.strDescription', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - GL Summary', N'', N'', N'', N'', N'', N'', N'', N'', N'', N'', 0, 0, NULL, NULL, N'14.1.47', NULL, 1, 76, NULL)
INSERT INTO #TempCannedPanels VALUES (26, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Asset Breakdown', N'Grid', N'', N'i21 General Ledger - Asset Breakdown', N'', N'', N'', N'Fort Books TE', N'Last Month', N'All Dates', N'dtmDate', N'', N'select strAccountId, strDescription, SUM(Amount) as Amount
FROM
      (
            select B.strAccountId, B.strDescription, (A.dblDebit - A.dblCredit) as Amount  from tblGLDetail A
            left join tblGLAccount B on A.intAccountId = B.intAccountId
            left join tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
            WHERE A.ysnIsUnposted = 0 and C.strAccountType = ''Asset'' and @DATE@
      ) tblGL 
GROUP BY strAccountId, strDescription
', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Asset Breakdown', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.1.2', NULL, 1, 77, NULL)
INSERT INTO #TempCannedPanels VALUES (27, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Liability Breakdown', N'Grid', N'', N'i21 General Ledger - Liability Breakdown', N'', N'', N'', N'Fort Books TE', N'Last Month', N'', N'dtmDate', N'', N'select strAccountId, strDescription, SUM(Amount) as Amount
FROM
      (
            select B.strAccountId, B.strDescription, (A.dblDebit - A.dblCredit) as Amount  from tblGLDetail A
            left join tblGLAccount B on A.intAccountId = B.intAccountId
            left join tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
            WHERE A.ysnIsUnposted = 0 and C.strAccountType = ''Liability'' and @DATE@
      ) tblGL 
GROUP BY strAccountId, strDescription
', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Liability Breakdown', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.1.4', NULL, 1, 78, NULL)
INSERT INTO #TempCannedPanels VALUES (28, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Revenue Breakdown', N'Grid', N'', N'i21 General Ledger - Revenue Breakdown', N'', N'', N'', N'Fort Books TE', N'Last Month', N'Last Month', N'dtmDate', N'', N'select strAccountId, strDescription, SUM(Amount) as Amount
FROM
      (
            select B.strAccountId, B.strDescription, (A.dblDebit - A.dblCredit) as Amount  from tblGLDetail A
            left join tblGLAccount B on A.intAccountId = B.intAccountId
            left join tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
            WHERE A.ysnIsUnposted = 0 and C.strAccountType = ''Sales'' and @DATE@ 
      ) tblGL 
GROUP BY strAccountId, strDescription
', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Revenue Breakdown', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.1.6', NULL, 1, 79, NULL)
INSERT INTO #TempCannedPanels VALUES (29, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Expenses/COGS Breakdown', N'Grid', N'', N'i21 General Ledger - Expenses/COGS Breakdown', N'', N'', N'', N'Fort Books TE', N'Last Month', N'Last Month', N'dtmDate', N'', N'select strAccountId, strDescription, SUM(Amount) as Amount
FROM
      (
            select B.strAccountId, B.strDescription, (A.dblDebit - A.dblCredit) as Amount  from tblGLDetail A
            left join tblGLAccount B on A.intAccountId = B.intAccountId
            left join tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
            WHERE A.ysnIsUnposted = 0 and C.strAccountType = ''Expense'' and @DATE@ or A.ysnIsUnposted = 0 and C.strAccountType = ''Cost of Goods Sold'' and @DATE@ 
      ) tblGL 
GROUP BY strAccountId, strDescription', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Expenses/COGS Breakdown', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.1.12', NULL, 1, 80, NULL)
INSERT INTO #TempCannedPanels VALUES (30, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Credits on Interface File', N'Grid', N'', N'iRely GL - Credits on Interface File ', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select glijemst.glije_date, glijemst.glije_src_sys, glijemst.glije_ref, glijemst.glije_doc, glijemst.glije_dr_cr_ind, glijemst.glije_amt, glijemst.glije_acct_no From glijemst Where glijemst.glije_dr_cr_ind = ''C''', N'', N'', N'', N'', N'', N'iRely GL - Credits on Interface File', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 28, NULL)
INSERT INTO #TempCannedPanels VALUES (31, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Debits on Interface File', N'Grid', N'', N'iRely GL - Debits on Interface File ', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select glijemst.glije_date, glijemst.glije_src_sys, glijemst.glije_ref, glijemst.glije_doc, glijemst.glije_dr_cr_ind, glijemst.glije_amt, glijemst.glije_acct_no From glijemst Where glijemst.glije_dr_cr_ind = ''D''', N'', N'', N'', N'', N'', N'iRely GL - Debits on Interface File', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 29, NULL)
INSERT INTO #TempCannedPanels VALUES (32, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Motor Fuel Tax - Sales', N'Grid', N'', N'iRely Motor Fuel Tax - Sales', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'pxrpt_trans_rev_dt', N'', N'SELECT pxrptmst.pxrpt_trans_type, pxrptmst.pxrpt_trans_rev_dt, pxrptmst.pxrpt_src_sys, pxrptmst.pxrpt_ord_no, pxrptmst.pxrpt_car_name, pxrptmst.pxrpt_cus_name, pxrptmst.pxrpt_cus_state, pxrptmst.pxrpt_itm_desc, pxrptmst.pxrpt_itm_loc_no, pxrptmst.pxrpt_vnd_name, pxrptmst.pxrpt_vnd_state, pxrptmst.pxrpt_sls_trans_gals, pxrptmst.pxrpt_sls_fet_amt, pxrptmst.pxrpt_sls_set_amt, pxrptmst.pxrpt_sls_lc1_amt, pxrptmst.pxrpt_sls_lc2_amt, pxrptmst.pxrpt_sls_lc3_amt, pxrptmst.pxrpt_sls_lc4_amt, pxrpt_itm_dyed_yn, pxrpt_cus_acct_stat
FROM pxrptmst
WHERE @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely Motor Fuel Tax - Sales', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 25, NULL)
INSERT INTO #TempCannedPanels VALUES (33, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Expiring Conrtacts ', N'Grid', N'', N'iRely Grain - Expiring Contracts', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select gacntmst.gacnt_pur_sls_ind, gacntmst.gacnt_cus_no, agcusmst.agcus_last_name, agcusmst.agcus_first_name, gacntmst.gacnt_com_cd, gacntmst.gacnt_cnt_no, gacntmst.gacnt_seq_no, gacntmst.gacnt_cnt_rev_dt, gacntmst.gacnt_beg_ship_rev_dt, gacntmst.gacnt_due_rev_dt, gacntmst.gacnt_pbhcu_ind, gacntmst.gacnt_no_un, gacntmst.gacnt_un_bal, gacntmst.gacnt_mkt_zone, gacntmst.gacnt_loc_no From gacntmst Left Join agcusmst On gacntmst.gacnt_cus_no = agcusmst.agcus_key Where gacntmst.gacnt_un_bal > 0 Order By gacntmst.gacnt_due_rev_dt', N'', N'', N'', N'', N'', N'iRely Grain - Expiring Conrtacts ', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 17, NULL)
INSERT INTO #TempCannedPanels VALUES (34, 0, 15, 0, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Assets Monthly', N'Chart', N'', N'i21 General Ledger - Assets Monthly', N'Column Stacked', N'insideEnd', N'', N'Fort Books TE', N'This Year', N'This Year', N'dtmDate', N'dtmDate', N'SELECT 
    SUM(TotalBalance) as TotalBalance
    ,Period
FROM
    (
          SELECT
              (A.dblDebit - A.dblCredit) as TotalBalance
              ,CAST(convert(varchar(10),MONTH(dtmDate)) + ''/01/'' + convert(varchar(10),YEAR(dtmDate)) AS DATETIME) as Period  
          FROM tblGLDetail A
          LEFT JOIN tblGLAccount B on A.intAccountId = B.intAccountId
          LEFT JOIN tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
          WHERE A.ysnIsUnposted = 0 AND C.strAccountType = ''Asset'' AND @DATE@
    ) 
      tblGL 
GROUP BY Period
ORDER BY Period
', N'', N'@DATE@', N'@DATE@', N'', N'', N'i21 General Ledger - Assets Monthly', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 1, 0, NULL, NULL, N'14.1.16', NULL, 1, 81, NULL)
INSERT INTO #TempCannedPanels VALUES (35, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Liability Monthly', N'Chart', N'', N'i21 General Ledger - Liability Monthly', N'Column Stacked', N'insideEnd', N'Red', N'Fort Books TE', N'This Year', N'This Year', N'dtmDate', N'', N'SELECT 
    SUM(TotalBalance) as TotalBalance
    ,Period
FROM
    (
          SELECT
              (A.dblDebit - A.dblCredit) as TotalBalance
              ,CAST(convert(varchar(10),MONTH(dtmDate)) + ''/01/'' + convert(varchar(10),YEAR(dtmDate)) AS DATETIME) as Period  
          FROM tblGLDetail A
          LEFT JOIN tblGLAccount B on A.intAccountId = B.intAccountId
          LEFT JOIN tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
          WHERE A.ysnIsUnposted = 0 AND C.strAccountType = ''Liability'' AND @DATE@
    ) 
      tblGL 
GROUP BY Period
ORDER BY Period', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Liability Monthly', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 1, 0, NULL, NULL, N'14.1.5', NULL, 1, 82, NULL)
INSERT INTO #TempCannedPanels VALUES (36, 0, 15, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Revenue Monthly', N'Chart', N'', N'i21 General Ledger - Revenue Monthly', N'Column Stacked', N'insideEnd', N'Purple', N'Fort Books TE', N'This Year', N'This Year', N'dtmDate', N' ', N'SELECT 
    SUM(Revenue) as Revenue
    ,Period
FROM
    (
          SELECT
              (A.dblDebit - A.dblCredit) as Revenue
              ,CAST(convert(varchar(10),MONTH(dtmDate)) + ''/01/'' + convert(varchar(10),YEAR(dtmDate)) AS DATETIME) as Period  
          FROM tblGLDetail A
          LEFT JOIN tblGLAccount B on A.intAccountId = B.intAccountId
          LEFT JOIN tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
          WHERE A.ysnIsUnposted = 0 AND C.strAccountType = ''Sales'' AND @DATE@
    ) 
      tblGL 
GROUP BY Period
ORDER BY Period', N'', N'@DATE@', N' ', N'', N'', N'i21 General Ledger - Revenue Monthly', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 1, 0, NULL, NULL, N'14.1.5', NULL, 1, 83, NULL)
INSERT INTO #TempCannedPanels VALUES (37, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Open Hedges', N'Grid', N'', N'iRely Grain - Open Hedges', N'', N'', N'', N'i21 AG - Demo Test', N'All Dates', N'All Dates', N'gahdg_rev_dt', N'', N'Select gahdgmst.gahdg_com_cd, gahdgmst.gahdg_broker_no, gahdgmst.gahdg_rev_dt, gahdgmst.gahdg_ref, gahdgmst.gahdg_loc_no, gahdgmst.gahdg_bot_prc, gahdgmst.gahdg_bot_basis, gahdgmst.gahdg_bot, gahdgmst.gahdg_bot_option, gahdgmst.gahdg_long_short_ind, gahdgmst.gahdg_un_hdg_bal, gahdgmst.gahdg_offset_yn, gahdg_hedge_yyyymm From gahdgmst Where gahdgmst.gahdg_offset_yn = ''N'' and @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely Grain - Open Hedges', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 21, NULL)
INSERT INTO #TempCannedPanels VALUES (38, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Open Storage', N'Grid', N'', N'iRely Grain - Open Storage', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select gastrmst.gastr_pur_sls_ind, gastrmst.gastr_com_cd, gastrmst.gastr_stor_type, gastrmst.gastr_cus_no, gastrmst.gastr_un_bal From gastrmst', N'', N'', N'', N'', N'', N'iRely Grain - Open Storage', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 22, NULL)
INSERT INTO #TempCannedPanels VALUES (39, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Expenses/COGS Monthly', N'Chart', N'', N'i21 General Ledger - Expenses/COGS Monthly', N'Column Stacked', N'insideStart', N'Sky', N'Fort Books TE', N'This Year', N'This Year', N'dtmDate', N'', N'SELECT 
    SUM(TotalBalance) as TotalBalance
    ,Period
FROM
    (
          SELECT
              (A.dblDebit - A.dblCredit) as TotalBalance
              ,CAST(convert(varchar(10),MONTH(dtmDate)) + ''/01/'' + convert(varchar(10),YEAR(dtmDate)) AS DATETIME) as Period  
          FROM tblGLDetail A
          LEFT JOIN tblGLAccount B on A.intAccountId = B.intAccountId
          LEFT JOIN tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
          WHERE A.ysnIsUnposted = 0 AND C.strAccountType = ''Expense'' AND @DATE@ or A.ysnIsUnposted = 0 and C.strAccountType = ''Cost of Goods Sold'' and @DATE@
    ) 
      tblGL 
GROUP BY Period
ORDER BY Period', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Expenses/COGS Monthly', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 1, 0, NULL, NULL, N'14.1.4', NULL, 1, 84, NULL)
INSERT INTO #TempCannedPanels VALUES (40, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Motor Fuel Tax - Purchases', N'Grid', N'', N'iRely Motor Fuel Tax - Purchases', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'pxrptmst.pxrpt_trans_rev_dt', N'', N'SELECT pxrptmst.pxrpt_trans_type, pxrptmst.pxrpt_trans_rev_dt, pxrptmst.pxrpt_src_sys,
pxrptmst.pxrpt_ord_no, pxrptmst.pxrpt_car_name, pxrptmst.pxrpt_cus_name, pxrptmst.pxrpt_cus_state, pxrptmst.pxrpt_itm_desc, pxrptmst.pxrpt_itm_loc_no, pxrptmst.pxrpt_vnd_name, pxrptmst.pxrpt_vnd_state, pxrptmst.pxrpt_pur_gross_un, pxrptmst.pxrpt_pur_net_un, pxrptmst.pxrpt_pur_fet_amt, pxrptmst.pxrpt_pur_set_amt, pxrptmst.pxrpt_pur_sst_amt, pxrptmst.pxrpt_pur_lc1_amt, pxrptmst.pxrpt_pur_lc2_amt, pxrptmst.pxrpt_pur_lc3_amt, pxrptmst.pxrpt_pur_lc4_amt, pxrptmst.pxrpt_pur_un_received, pxrpt_itm_dyed_yn, pxrpt_cus_acct_stat
FROM pxrptmst
WHERE @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely Motor Fuel Tax - Purchases', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 24, NULL)
INSERT INTO #TempCannedPanels VALUES (41, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Grain Flow - All Commodities', N'Chart', N'', N'iRely Grain - Grain Flow - All Commodities', N'Spline', N'rotate', N'', N'Ag SQL 13.1', N'This Year', N'This Year', N'gaphsmst.gaphs_dlvry_rev_dt', N'gaphsmst.gaphs_dlvry_rev_dt', N'Select Month(Convert(date,Convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112)) As ''Month'', Sum(gaphsmst.gaphs_net_un) As units From gaphsmst Where gaphsmst.gaphs_pur_sls_ind = ''P'' And @DATE@ Group By Month(Convert(date,Convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112)) Order By Month(Convert(date,Convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112))', N'Select Month(convert(date,convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112)) As ''Month'', Sum(gaphsmst.gaphs_net_un) As units From gaphsmst Where gaphsmst.gaphs_pur_sls_ind = ''S'' And @DATE@ 
Group By Month(convert(date,convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112))
Order By Month(convert(date,convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112))', N'@DATE@', N'@DATE@', N'', N'', N'iRely Grain - Grain Flow - All Commodities', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 16, NULL)
INSERT INTO #TempCannedPanels VALUES (42, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Production History', N'Grid', N'', N'iRely Grain - Production History', N'', N'', N'', N'Ag SQL 13.1', N'Last Month', N'Last Month', N'gaphsmst.gaphs_dlvry_rev_dt', N'', N'Select gaphsmst.gaphs_pur_sls_ind, gaphsmst.gaphs_cus_no, gaphsmst.gaphs_com_cd, gaphsmst.gaphs_dlvry_rev_dt, gaphsmst.gaphs_loc_no, gaphsmst.gaphs_tic_no, gaphsmst.gaphs_cus_ref_no, gaphsmst.gaphs_gross_wgt, gaphsmst.gaphs_tare_wgt, gaphsmst.gaphs_gross_un, gaphsmst.gaphs_wet_un, gaphsmst.gaphs_net_un, gaphsmst.gaphs_fees From gaphsmst Where @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely Grain - Production History', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 23, NULL)
INSERT INTO #TempCannedPanels VALUES (43, 100, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - In-Transit Sales', N'Grid', N'', N'iRely Grain - In-Transit Sales', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select gaitrmst.gaitr_pur_sls_ind, gaitrmst.gaitr_loc_no, gaitrmst.gaitr_cus_no, agcusmst.agcus_last_name, agcusmst.agcus_first_name, gacommst.gacom_desc, gaitrmst.gaitr_tic_no, gaitrmst.gaitr_ship_rev_dt, gaitrmst.gaitr_gross_wgt, gaitrmst.gaitr_tare_wgt, gaitrmst.gaitr_how_ship_ind, gaitrmst.gaitr_cnt_no, gaitrmst.gaitr_cnt_seq_no, gaitrmst.gaitr_cnt_loc_no, gaitrmst.gaitr_un_out From agcusmst, gacommst, gaitrmst Where gaitrmst.gaitr_cus_no = agcusmst.agcus_key And gaitrmst.gaitr_com_cd = gacommst.gacom_com_cd And (gaitrmst.gaitr_pur_sls_ind = ''S'')', N'', N'', N'', N'', N'', N'iRely Grain - In-Transit Sales', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 15, NULL)
INSERT INTO #TempCannedPanels VALUES (44, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Open Contracts', N'Grid', N'', N'iRely Grain - Open Contracts', N'', N'', N'', N'Ag SQL 13.1', N'This Year', N'This Year', N'gacnt_due_rev_dt', N'', N'Select gacntmst.gacnt_pur_sls_ind, gacntmst.gacnt_com_cd, Left(gacntmst.gacnt_bot_option, 3) As ''Option Month'', Right(gacntmst.gacnt_bot_option, 2) As ''Option Year'', gacntmst.gacnt_due_rev_dt, Sum(gacntmst.gacnt_un_bal) As Balance, Sum(gacntmst.gacnt_un_bot_prc) As Price, Sum(gacntmst.gacnt_un_bal * gacntmst.gacnt_un_bot_prc) As ''Extended Amount'', Sum(gacntmst.gacnt_un_bal * gacntmst.gacnt_un_bot_prc) / Sum(gacntmst.gacnt_un_bal) As WAP, Sum(gacntmst.gacnt_un_bal * gacntmst.gacnt_un_bot_basis) / Sum(gacntmst.gacnt_un_bal) As WAB, Sum(gacntmst.gacnt_un_bal * gacntmst.gacnt_un_frt_basis) / Sum(gacntmst.gacnt_un_bal) As WAF, gacntmst.gacnt_cnt_no From gacntmst Where @DATE@ Group By gacntmst.gacnt_pur_sls_ind, gacntmst.gacnt_com_cd, Left(gacntmst.gacnt_bot_option, 3), gacntmst.gacnt_cnt_no, Right(gacntmst.gacnt_bot_option, 2), gacntmst.gacnt_due_rev_dt Having Sum(gacntmst.gacnt_un_bal) > ''0.000'' Order By gacntmst.gacnt_com_cd, Left(gacntmst.gacnt_bot_option, 3), Right(gacntmst.gacnt_bot_option, 2), gacntmst.gacnt_due_rev_dt, gacntmst.gacnt_pur_sls_ind', N'', N'@DATE@', N'', N'', N'', N'iRely Grain - Open Contracts', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 18, NULL)
INSERT INTO #TempCannedPanels VALUES (45, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Orders', N'Grid', N'', N'iRely Petro - Orders', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'Select ptticmst.pttic_cus_no, ptcusmst.ptcus_last_name, ptcusmst.ptcus_first_name, ptticmst.pttic_tic_no, ptticmst.pttic_rev_dt, ptticmst.pttic_type, ptticmst.pttic_itm_no, ptticmst.pttic_qty_orig From ptticmst Left Join ptcusmst On ptticmst.pttic_cus_no = ptcusmst.ptcus_cus_no Where ptticmst.pttic_type = ''O'' Order By ptticmst.pttic_rev_dt', N'', N'', N'', N'', N'', N'iRely Petro - Orders', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 56, NULL)
INSERT INTO #TempCannedPanels VALUES (46, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - A/R Summary', N'Grid', N'', N'iRely Petro - A/R Summary **MUST REAGE DAILY TO BE ACCURATELY UPDATED**', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'SELECT Sum(ptcusmst.ptcus_ar_curr) AS ''Current'', Sum(ptcusmst.ptcus_ar_3160) AS ''31-60 Days'', Sum(ptcusmst.ptcus_ar_6190) AS ''61-90 Days'', Sum(ptcusmst.ptcus_ar_91120) AS ''91-120 Days'', Sum(ptcusmst.ptcus_ar_ov120) AS ''Over 120 Days''
FROM ptcusmst', N'', N'', N'', N'', N'', N'iRely Petro - A/R Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 67, NULL)
INSERT INTO #TempCannedPanels VALUES (47, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Customers Over 120 Days Past Due', N'Grid', N'', N'iRely Petro - Customers Over 120 Days Past Due **MUST REAGE DAILY TO BE ACCURATELY UPDATED**', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'SELECT ptcusmst.ptcus_cus_no, ptcusmst.ptcus_last_name, ptcusmst.ptcus_first_name, ptcusmst.ptcus_ar_ov120
FROM ptcusmst
WHERE (ptcusmst.ptcus_ar_ov120<>0)', N'', N'', N'', N'', N'', N'iRely Petro - Customers Over 120 Days Past Due', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 68, NULL)
INSERT INTO #TempCannedPanels VALUES (48, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Slow Moving Inventory', N'Grid', N'', N'iRely Petro - Slow Moving Inventory', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'SELECT ptitmmst.ptitm_itm_no, ptitmmst.ptitm_desc, ptitmmst.ptitm_unit, ptitmmst.ptitm_last_sale_rev_dt, ptitmmst.ptitm_on_hand, ptitmmst.ptitm_loc_no
FROM ptitmmst
Where ptitmmst.ptitm_phys_inv_yno=''Y'' And ptitmmst.ptitm_last_sale_rev_dt<>''0''
Order By ptitmmst.ptitm_last_sale_rev_dt', N'', N'', N'', N'', N'', N'iRely Petro - Slow Moving Inventory', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 71, NULL)
INSERT INTO #TempCannedPanels VALUES (49, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Sales by Item/Product ', N'Grid', N'', N'iRely Petro - Sales by Item/Product ', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'ptstmmst.ptstm_ship_rev_dt', N'', N'Select ptstmmst.ptstm_itm_no, ptitmmst.ptitm_desc, Sum(ptstmmst.ptstm_net) As ''Sales'', Sum(ptstmmst.ptstm_un) As ''Units'' From ptstmmst Left Join ptitmmst On ptstmmst.ptstm_itm_no = ptitmmst.ptitm_itm_no And ptstmmst.ptstm_key_loc_no = ptitmmst.ptitm_loc_no Where @DATE@ Group By ptstmmst.ptstm_itm_no, ptitmmst.ptitm_desc', N'', N'@DATE@', N'', N'', N'', N'iRely Petro - Sales by Item/Product ', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 58, NULL)
INSERT INTO #TempCannedPanels VALUES (50, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Sales by Location', N'Chart', N'', N'iRely Petro- Sales by Location', N'Column', N'outside', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'ptstmmst.ptstm_ship_rev_dt', N'', N'SELECT ptstmmst.ptstm_key_loc_no AS ''Location'', Sum(ptstmmst.ptstm_net) AS ''Sales''
FROM ptstmmst
Where @DATE@
GROUP BY ptstmmst.ptstm_key_loc_no
', N'', N'@DATE@', N'', N'', N'', N'iRely Petro - Sales by Location', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 59, NULL)
INSERT INTO #TempCannedPanels VALUES (51, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Revenue vs Costs Monthly', N'Chart', N'', N'iRely Petro - Revenue vs Costs Monthly', N'Column', N'outside', N'', N'i21 PT - Berry Oil ', N'This Year', N'This Year', N'ptstmmst.ptstm_rev_dt', N'ptstmmst.ptstm_rev_dt', N'Select Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112)) As ''Month'', 
Sum(ptstmmst.ptstm_net) As ''Sales'' From ptstmmst
Where @DATE@ 
Group By Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112)) 
Order By Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112))', N'Select Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112)) As ''Month'', 
Sum(ptstmmst.ptstm_cgs) As ''Costs'' From ptstmmst
Where @DATE@ 
Group By Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112)) 
Order By Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112))', N'@DATE@', N'@DATE@', N'', N'', N'iRely Petro - Revenue vs Costs Monthly', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 60, NULL)
INSERT INTO #TempCannedPanels VALUES (52, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Sales by Customer', N'Grid', N'', N'iRely Petro - Sales by Customer', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'ptstmmst.ptstm_ship_rev_dt', N'', N'SELECT ptcusmst.ptcus_last_name, ptcusmst.ptcus_first_name, ptcusmst.ptcus_cus_no, Sum(ptstmmst.ptstm_net) AS ''Sales'', Sum(ptstmmst.ptstm_un) AS ''Units''
FROM ptstmmst
Left join ptcusmst On ptstmmst.ptstm_bill_to_cus = ptcusmst.ptcus_cus_no
Where @DATE@
GROUP BY ptcusmst.ptcus_last_name, ptcusmst.ptcus_first_name, ptcusmst.ptcus_cus_no
Order By Sum(ptstmmst.ptstm_net) DESC', N'', N'@DATE@', N'', N'', N'', N'iRely Petro - Sales by Customer', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 62, NULL)
INSERT INTO #TempCannedPanels VALUES (53, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Customers Over Credit Limit', N'Grid', N'', N'iRely Petro - Customers Over Credit Limit', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'select ptcusmst.ptcus_cus_no, ptcusmst.ptcus_last_name, ptcusmst.ptcus_first_name, ptcusmst.ptcus_credit_limit, ptcusmst.ptcus_ar_curr+ptcusmst.ptcus_ar_3160+ptcusmst.ptcus_ar_6190+ptcusmst.ptcus_ar_91120+ptcusmst.ptcus_ar_ov120-ptcusmst.ptcus_cred_ppd-ptcusmst.ptcus_cred_reg as ''Total Balance'', ptcusmst.ptcus_credit_limit-(ptcusmst.ptcus_ar_curr+ptcusmst.ptcus_ar_3160+ptcusmst.ptcus_ar_6190+ptcusmst.ptcus_ar_91120+ptcusmst.ptcus_ar_ov120-ptcusmst.ptcus_cred_ppd-ptcusmst.ptcus_cred_reg) as ''overage''
from ptcusmst
where (ptcusmst.ptcus_last_stmnt_bal<>0) and (ptcusmst.ptcus_credit_limit-ptcusmst.ptcus_last_stmnt_bal<0) And ptcusmst.ptcus_active_yn=''Y'' And ptcusmst.ptcus_credit_limit-(ptcusmst.ptcus_ar_curr+ptcusmst.ptcus_ar_3160+ptcusmst.ptcus_ar_6190+ptcusmst.ptcus_ar_91120+ptcusmst.ptcus_ar_ov120-ptcusmst.ptcus_cred_ppd-ptcusmst.ptcus_cred_reg) <0
', N'', N'', N'', N'', N'', N'iRely Petro - Customers Over Credit Limit', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 64, NULL)
INSERT INTO #TempCannedPanels VALUES (54, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 3, N'Master', N'iRely Grain - Grain Position Summary', N'Grid', N'', N'iRely Grain - Grain Position Summary', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select gacommst.gacom_desc, Sum(gaposmst.gapos_in_house + gaposmst.gapos_offsite + gaposmst.gapos_sls_in_transit) As totals From gaposmst Left Join gacommst On gaposmst.gapos_com_cd = gacommst.gacom_com_cd Group By gacommst.gacom_desc', N'', N'', N'', N'', N'', N'iRely Grain - Grain Position Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 20, NULL)
INSERT INTO #TempCannedPanels VALUES (55, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Cash Flow - Monthly', N'Chart', N'', N'iRely AP - Cash Flow - Monthly', N'Column Stacked', N'insideEnd', N'Sky', N'i21 PT - Berry Oil ', N'This Year', N'This Year', N'apchkmst.apchk_rev_dt', N'', N'Select Month(Convert(date,Convert(char(8),apchkmst.apchk_rev_dt),112)) As CheckDate, Sum(apchkmst.apchk_chk_amt) As Amount From apchkmst Where @DATE@ Group By Month(Convert(date,Convert(char(8),apchkmst.apchk_rev_dt),112)) Order By Month(Convert(date,Convert(char(8),apchkmst.apchk_rev_dt),112))', N'', N'@DATE@', N'', N'', N'', N'iRely AP - Cash Flow - Monthly', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 39, NULL)
INSERT INTO #TempCannedPanels VALUES (56, 0, 25, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely CF - Card Fueling Transactions', N'Pivot Grid', N'', N'iRely CF - Card Fueling Transactions', N'', N'', N'', N'i21 PT - Berry Oil ', N'This Month', N'This Month', N'cftrx_rev_dt', N'', N'Select cftrxmst.cftrx_ar_cus_no, cftrxmst.cftrx_card_no, cfcusmst.cfcus_card_desc, cftrxmst.cftrx_rev_dt, cftrxmst.cftrx_qty, cftrxmst.cftrx_prc, cftrxmst.cftrx_calc_total, cftrxmst.cftrx_ar_itm_no, cftrxmst.cftrx_ar_itm_loc_no, cftrxmst.cftrx_sls_id, cftrxmst.cftrx_sell_prc, cftrxmst.cftrx_prc_per_un, cftrxmst.cftrx_site, cftrxmst.cftrx_time, cftrxmst.cftrx_odometer, cftrxmst.cftrx_site_state, cftrxmst.cftrx_site_county, cftrxmst.cftrx_site_city, cftrxmst.cftrx_selling_host_id, cftrxmst.cftrx_buying_host_id, cftrxmst.cftrx_po_no, cftrxmst.cftrx_ar_ivc_no, cftrxmst.cftrx_calc_fet_amt, cftrxmst.cftrx_calc_set_amt, cftrxmst.cftrx_calc_sst_amt, cftrxmst.cftrx_tax_cls_id, cftrxmst.cftrx_ivc_prtd_yn, cftrxmst.cftrx_vehl_no, cftrxmst.cftrx_calc_net_sell_prc, cftrxmst.cftrx_pump_no From cftrxmst Inner Join cfcusmst On cftrxmst.cftrx_card_no = cfcusmst.cfcus_card_no And cftrxmst.cftrx_ar_cus_no = cfcusmst.cfcus_ar_cus_no
  Where @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely CF - Card Fueling Transactions', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'{"aggregate":[],"leftAxis":[],"topAxis":[]}', 0, 0, NULL, NULL, N'14.1.1', NULL, 1, 85, NULL)
INSERT INTO #TempCannedPanels VALUES (57, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 8, N'Master', N'iRely AG - Inventory Available for Sale Summary', N'Grid', N'', N'iRely AG - Inventory Available for Sale Summary  ***Drill Down Available', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agitmmst.agitm_no, agitmmst.agitm_loc_no, agitmmst.agitm_desc, agitmmst.agitm_un_desc, agitmmst.agitm_un_on_hand, agitmmst.agitm_un_pend_ivcs, agitmmst.agitm_un_on_order, agitmmst.agitm_un_mfg_in_prs, agitmmst.agitm_un_fert_committed, agitmmst.agitm_un_ord_committed, agitmmst.agitm_un_cnt_committed,  agitmmst.agitm_un_on_hand-agitmmst.agitm_un_pend_ivcs+agitmmst.agitm_un_on_order+agitmmst.agitm_un_mfg_in_prs-agitmmst.agitm_un_fert_committed-agitmmst.agitm_un_cnt_committed-agitmmst.agitm_un_ord_committed As [Available] From agitmmst', N'', N'', N'', N'', N'', N'iRely AG - Inventory Available for Sale Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 54, NULL)
INSERT INTO #TempCannedPanels VALUES (58, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 2, N'Master', N'iRely AG - Inventory Overview Summary', N'Grid', N'', N'iRely AG - Inventory Overview Summary **Drill Down Available', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agitmmst.agitm_class, agitmmst.agitm_no, agitmmst.agitm_loc_no, agitmmst.agitm_desc, agitmmst.agitm_un_desc, agitmmst.agitm_avg_un_cost, agitmmst.agitm_un_on_hand, agitmmst.agitm_last_un_cost, agitmmst.agitm_pak_desc, agitmmst.agitm_phys_inv_ynbo From agitmmst Where agitmmst.agitm_phys_inv_ynbo = ''Y'' Order By agitm_un_on_hand', N'', N'', N'', N'', N'', N'iRely AG - Inventory Overview Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 51, NULL)
INSERT INTO #TempCannedPanels VALUES (59, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 4, N'Master', N'iRely AG - Invoice Margins Below 0 - Summary', N'Grid', N'', N'iRely AG - Invoice Margins Below 0 - Summary  **Drill Down Available', N'', N'', N'', N'i21 AG - Demo Test', N'All Dates', N'All Dates', N'agstmmst.agstm_ship_rev_dt', N'', N'Select agstmmst.agstm_ivc_no, (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls*100 As ''Profit Percent'', agstmmst.agstm_ship_rev_dt, agstmmst.agstm_bill_to_cus From agstmmst Where (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls Is Not Null And agstmmst.agstm_sls <> 0 And (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls*100 <''0'' And @DATE@ Order By (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls', N'', N'@DATE@', N'', N'', N'', N'iRely AG - Invoice Margins Below 0 - Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 43, NULL)
INSERT INTO #TempCannedPanels VALUES (60, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 2, N'Master', N'iRely AG - Negative Inventory', N'Grid', N'', N'iRely AG - Negative Inventory **Drill Down Available', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agitmmst.agitm_no, agitmmst.agitm_desc, agitmmst.agitm_loc_no, agitmmst.agitm_un_on_hand, agitmmst.agitm_phys_inv_ynbo From agitmmst Where agitmmst.agitm_un_on_hand < 0 And agitmmst.agitm_phys_inv_ynbo = ''Y'' Order By agitmmst.agitm_un_on_hand', N'', N'', N'', N'', N'', N'iRely AG - Negative Inventory', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 42, NULL)
INSERT INTO #TempCannedPanels VALUES (61, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 6, N'Master', N'iRely AG - Open Contracts Summary', N'Grid', N'', N'iRely AG - Open Contracts Summary ***Drill Down Available', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agcntmst.agcnt_cus_no, agcusmst.agcus_last_name, agcusmst.agcus_first_name, agcntmst.agcnt_loc_no, agcntmst.agcnt_cnt_no, agcntmst.agcnt_cnt_rev_dt, agcntmst.agcnt_due_rev_dt, agcntmst.agcnt_itm_or_cls, agcntmst.agcnt_prc_lvl, agcntmst.agcnt_ppd_yndm, agcntmst.agcnt_un_orig, agcntmst.agcnt_un_prc, agcntmst.agcnt_un_bal, agcntmst.agcnt_slsmn_id From agcntmst Left Join agcusmst ON agcntmst.agcnt_cus_no = agcusmst.agcus_key Where (agcntmst.agcnt_itm_or_cls <> ''*'' And agcntmst.agcnt_un_bal > 0.0)', N'', N'', N'', N'', N'', N'iRely AG - Open Contracts Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 48, NULL)
INSERT INTO #TempCannedPanels VALUES (62, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 5, N'Master', N'iRely Petro - Inventory Overview Summary', N'Grid', N'', N'iRely Petro - Inventory Overview Summary  **Drill Down Available', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'Select ptitmmst.ptitm_itm_no, ptitmmst.ptitm_desc, ptitmmst.ptitm_loc_no, ptitmmst.ptitm_on_hand From ptitmmst Where ptitmmst.ptitm_phys_inv_yno = ''Y''', N'', N'', N'', N'', N'', N'iRely Petro - Inventory Overview Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 55, NULL)
INSERT INTO #TempCannedPanels VALUES (63, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 4, N'Master', N'iRely Petro - Invoice Margins Below 0 - Summary', N'Grid', N'', N'iRely Petro - Invoice Margins Below 0 - Summary  **Drill Down Available', N'', N'', N'', N'i21 PT - Berry Oil ', N'All Dates', N'', N'ptstmmst.ptstm_rev_dt', N'', N'Select ptstmmst.ptstm_bill_to_cus, ptstm_ivc_no, ptstmmst.ptstm_ship_rev_dt, ptstmmst.ptstm_itm_no, ptstmmst.ptstm_loc_no, ptstmmst.ptstm_class, ptstmmst.ptstm_un, ptstmmst.ptstm_un_prc, ptstmmst.ptstm_net, ptstmmst.ptstm_cgs, ptstmmst.ptstm_slsmn_id, ptstmmst.ptstm_pak_desc, ptstmmst.ptstm_un_desc, ptstmmst.ptstm_net - ptstmmst.ptstm_cgs As ''Profit Amount'', (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net*100 As ''Profit Percent'' From ptstmmst Where (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net Is Not Null And @DATE@ And ptstmmst.ptstm_net <> 0 And (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net*100 < ''0'' Order By (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net', N'', N'@DATE@', N'', N'', N'', N'iRely Petro - Invoice Margins Below 0 - Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 61, NULL)
INSERT INTO #TempCannedPanels VALUES (64, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 5, N'Master', N'iRely Petro - Negative Inventory', N'Grid', N'', N'iRely Petro - Negative Inventory **Drill Down Available', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'Select ptitmmst.ptitm_itm_no, ptitmmst.ptitm_desc, ptitmmst.ptitm_loc_no, ptitmmst.ptitm_on_hand From ptitmmst Where ptitmmst.ptitm_on_hand < 0 And ptitmmst.ptitm_phys_inv_yno = ''Y'' Order By ptitmmst.ptitm_on_hand', N'', N'', N'', N'', N'', N'iRely Petro - Negative Inventory', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 66, NULL)
INSERT INTO #TempCannedPanels VALUES (65, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - General Ledger History Summary', N'Grid', N'', N'iRely GL - General Ledger History Summary    ***Drill Down Available**', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhst_trans_dt', N'', N'Select glhstmst.glhst_acct1_8, glhstmst.glhst_acct9_16, glactmst.glact_desc, Sum(Case When glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 Else glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst On glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where @DATE@ Group By glhstmst.glhst_acct1_8, glhstmst.glhst_acct9_16, glactmst.glact_desc Order By glhstmst.glhst_acct1_8, glhstmst.glhst_acct9_16', N'', N'@DATE@', N'', N'', N'', N'iRely GL - General Ledger History Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 27, NULL)
INSERT INTO #TempCannedPanels VALUES (66, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Chart of Accounts', N'Grid', N'', N'iRely GL - Chart of Accounts', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'Select glactmst.glact_acct1_8, glactmst.glact_acct9_16, glactmst.glact_desc From glactmst ', N'', N'', N'', N'', N'', N'iRely GL - Chart of Accounts', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 30, NULL)
INSERT INTO #TempCannedPanels VALUES (67, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Assets Breakdown', N'Grid', N'', N'iRely GL - Assets Breakdown', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhstmst.glhst_trans_dt', N'', N'Select glactmst.glact_desc, Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst On glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where @DATE@ And glactmst.glact_type = ''A'' Group By glactmst.glact_desc Order By glactmst.glact_desc', N'', N'@DATE@', N'', N'', N'', N'iRely GL - Assets Breakdown', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 31, NULL)
INSERT INTO #TempCannedPanels VALUES (68, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Liabilities Breakdown', N'Grid', N'', N'iRely GL - Liabilities Breakdown', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhstmst.glhst_trans_dt', N'', N'Select glactmst.glact_desc, Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst On glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where @DATE@ And glactmst.glact_type = ''L'' Group By glactmst.glact_desc Order By glactmst.glact_desc', N'', N'@DATE@', N'', N'', N'', N'iRely GL - Liabilities Breakdown', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 32, NULL)
INSERT INTO #TempCannedPanels VALUES (69, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Revenue Breakdown', N'Grid', N'', N'iRely GL - Revenue Breakdown', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhstmst.glhst_trans_dt', N'', N'Select glactmst.glact_desc, Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst On glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where @DATE@ And glactmst.glact_type = ''I'' Group By glactmst.glact_desc Order By glactmst.glact_desc', N'', N'@DATE@', N'', N'', N'', N'iRely GL - Revenue Breakdown', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 33, NULL)
INSERT INTO #TempCannedPanels VALUES (70, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Expense-COGS Breakdown', N'Grid', N'', N'iRely GL - Expense-COGS Breakdown', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhstmst.glhst_trans_dt', N'', N'Select glactmst.glact_desc, Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst On glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where (@DATE@ And glactmst.glact_type = ''E'') Or (@DATE@ And glactmst.glact_type = ''C'') Group By glactmst.glact_desc Order By glactmst.glact_desc', N'', N'@DATE@', N'', N'', N'', N'iRely GL - Expense-COGS Breakdown', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 34, NULL)
INSERT INTO #TempCannedPanels VALUES (71, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Revenue/Expense Chart - Monthly', N'Chart', N'', N'iRely GL - Revenue/Expense Chart - Monthly', N'Column', N'insideEnd', N'Base', N'i21 PT - Berry Oil ', N'This Year', N'This Year', N'glhstmst.glhst_trans_dt', N'glhstmst.glhst_trans_dt', N'SELECT 
Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) AS ''Month'', sum(case
when glactmst.glact_normal_value=''C'' and glhstmst.glhst_dr_cr_ind=''C'' then glhstmst.glhst_amt
when glactmst.glact_normal_value=''C'' and glhstmst.glhst_dr_cr_ind=''D'' then glhstmst.glhst_amt*-1
when glactmst.glact_normal_value=''D'' and glhstmst.glhst_dr_cr_ind=''C'' then glhstmst.glhst_amt*-1
when glactmst.glact_normal_value=''D'' and glhstmst.glhst_dr_cr_ind=''D'' then glhstmst.glhst_amt
end) AS Amount
FROM glhstmst Left Join glactmst ON glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 and glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where glactmst.glact_type=''I'' and @DATE@
group by Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112))
order by Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112))', N'Select Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) As Month, Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst ON glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where ((glactmst.glact_type = ''E'' And @DATE@) Or (glactmst.glact_type = ''C'' And @DATE@)) Group By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) Order By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112))', N'@DATE@', N'@DATE@', N'', N'', N'iRely GL - Revenue/Expense Chart - Monthly', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 40, NULL)
INSERT INTO #TempCannedPanels VALUES (72, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Assets/Liabilities Chart - Monthly', N'Chart', N'', N'iRely GL - Assets/Liabilities Chart - Monthly', N'Column', N'outside', N'Sky', N'i21 PT - Berry Oil ', N'This Year', N'This Year', N'glhstmst.glhst_trans_dt', N'glhstmst.glhst_trans_dt', N'Select Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) As ''Month'', Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst ON glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where (glactmst.glact_type = ''A'' And @DATE@) Group By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) Order By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112))', N'Select Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) As ''Month'', Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst ON glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where (glactmst.glact_type = ''L'' And @DATE@) Group By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) Order By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112))', N'@DATE@', N'@DATE@', N'', N'', N'iRely GL - Assets/Liabilities Chart - Monthly', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 41, NULL)

print('/*******************  END INSERTING canned panels on temporary panel table  *******************/')


print('/*******************  BEGIN DELETING deleted canned panels  on table Panel  *******************/')
--This are panels that are deleted on  canned panel server.
DELETE tblDBPanel WHERE intCannedPanelId in (2,3,4,5,6,7,8,9,10,11,12,13,14)
print('/*******************  END DELETING deleted canned panels on temporary panel table  *******************/')

print('/*******************  BEGIN UPDATING canned panels on table Panel  *******************/')
DECLARE @intCannedPanelId int
DECLARE @intDrillDownPanel int


DECLARE db_cursor CURSOR FOR  
SELECT intCannedPanelId FROM #TempCannedPanels
 

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @intCannedPanelId

WHILE @@FETCH_STATUS = 0   
BEGIN
	set @intDrillDownPanel = (SELECT intDrillDownPanel FROM #TempCannedPanels where intCannedPanelId = @intCannedPanelId)
	IF(@intDrillDownPanel <> 0)
		BEGIN
			set @intDrillDownPanel = (SELECT intPanelId FROM [dbo].[tblDBPanel] where intCannedPanelId = (SELECT intCannedPanelId FROM #TempCannedPanels where intPanelId = @intDrillDownPanel))
		END		
	
	--Check if Canned Panel Exist
	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[tblDBPanel] WHERE intCannedPanelId = @intCannedPanelId)		
		BEGIN
			

			UPDATE [dbo].[tblDBPanel]
			SET intRowsReturned = CannedPanels.intRowsReturned,
				intRowsVisible = CannedPanels.intRowsVisible,
				intChartZoom = CannedPanels.intChartZoom,
				intChartHeight = CannedPanels.intChartHeight,
				intUserId = CannedPanels.intUserId,	
				intDefaultColumn = CannedPanels.intDefaultColumn,
				intDefaultRow = CannedPanels.intDefaultRow,
				intDefaultWidth = CannedPanels.intDefaultWidth,
				intSourcePanelId = CannedPanels.intSourcePanelId,
				intConnectionId = CannedPanels.intConnectionId,
				intDrillDownPanel = @intDrillDownPanel,
				strClass = CannedPanels.strClass,
				strPanelName = CannedPanels.strPanelName,
				strStyle = CannedPanels.strStyle,
				strAccessType = CannedPanels.strAccessType,
				strCaption = CannedPanels.strCaption,
				strChart = CannedPanels.strChart,
				strChartPosition = CannedPanels.strChartPosition,
				strChartColor = CannedPanels.strChartColor,
				strConnectionName = CannedPanels.strConnectionName,
				strDateCondition = CannedPanels.strDateCondition,
				strDateCondition2 = CannedPanels.strDateCondition2,
				strDateFieldName = CannedPanels.strDateFieldName,
				strDateFieldName2 = CannedPanels.strDateFieldName2,
				strDataSource = CannedPanels.strDataSource,
				strDataSource2 = CannedPanels.strDataSource2,
				strDateVariable = CannedPanels.strDateVariable,
				strDateVariable2 = CannedPanels.strDateVariable2,
				strDefaultTab = CannedPanels.strDefaultTab,
				strDescription = CannedPanels.strDescription,
				strPanelNameDuplicate = CannedPanels.strPanelNameDuplicate,
				strPanelType = CannedPanels.strPanelType,
				strQBCriteriaOptions = CannedPanels.strQBCriteriaOptions,
				strFilterCondition = CannedPanels.strFilterCondition,
				strFilterVariable = CannedPanels.strFilterVariable,
				strFilterFieldName = CannedPanels.strFilterFieldName,
				strFilterVariable2 = CannedPanels.strFilterVariable2,
				strFilterFieldName2 = CannedPanels.strFilterFieldName2,
				strGroupFields = CannedPanels.strGroupFields,	
				strFilters = CannedPanels.strFilters,
				strConfigurator	= CannedPanels.strConfigurator,
				ysnChartLegend = CannedPanels.ysnChartLegend,
				ysnShowInGroups = CannedPanels.ysnShowInGroups,
				imgLayoutGrid = CannedPanels.imgLayoutGrid,
				imgLayoutPivotGrid = CannedPanels.imgLayoutPivotGrid,			
				strPanelVersion = CannedPanels.strPanelVersion,	
				intFilterId = CannedPanels.intFilterId,
				intConcurrencyId = CannedPanels.intConcurrencyId,
				strSortValue = CannedPanels.strSortValue			
			FROM (SELECT * FROM #TempCannedPanels where intCannedPanelId = @intCannedPanelId) AS CannedPanels
			WHERE [dbo].[tblDBPanel].[intCannedPanelId] = @intCannedPanelId;
		END	  
	ELSE --ADD NEW CANNED PANEL
		BEGIN 
		 INSERT INTO [dbo].[tblDBPanel] 
			   ([intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId], [intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition], [strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription], [strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2], [strGroupFields], [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId], [intConcurrencyId ], [intCannedPanelId], [strSortValue]) 
		 SELECT [intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId], [intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition], [strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription], [strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2], [strGroupFields], [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId], [intConcurrencyId ], [intCannedPanelId], [strSortValue]
		 FROM #TempCannedPanels 
		 WHERE intCannedPanelId = @intCannedPanelId

		 UPDATE [dbo].[tblDBPanel]
		 SET intDrillDownPanel =@intDrillDownPanel
		 WHERE intCannedPanelId = @intCannedPanelId

		END
	
FETCH NEXT FROM db_cursor INTO @intCannedPanelId
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

DROP TABLE #TempCannedPanels
print('/*******************  END UPDATING canned panels on table Panel  *******************/')
/*******************  BEGIN UPDATING canned panels on table Panel *******************/
GO