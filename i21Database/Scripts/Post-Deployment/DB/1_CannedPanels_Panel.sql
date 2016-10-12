﻿
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



print('/*******************  BEGIN INSERTING drill down canned panels on temporary panel table  *******************/')
INSERT INTO #TempCannedPanels VALUES (1, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely AG - Inventory Overview Detail', N'Grid', N'', N'iRely AG - Inventory Overview Detail', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agitmmst.agitm_class, agitmmst.agitm_no, agitmmst.agitm_loc_no, agitmmst.agitm_desc, agitmmst.agitm_un_desc, agitmmst.agitm_avg_un_cost, agitmmst.agitm_un_on_hand, agitmmst.agitm_last_un_cost, agitmmst.agitm_pak_desc, agitmmst.agitm_phys_inv_ynbo From agitmmst Where agitmmst.agitm_phys_inv_ynbo = ''Y'' Order By agitm_un_on_hand', N'', N'', N'', N'', N'', N'iRely AG - Inventory Overview Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 45, NULL)
INSERT INTO #TempCannedPanels VALUES (2, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely Grain - Grain Postion Detail ', N'Grid', N'', N'iRely Grain - Grain Position Detail', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select gacommst.gacom_desc, gaposmst.gapos_loc_no, gaposmst.gapos_in_house, gaposmst.gapos_offsite, gaposmst.gapos_sls_in_transit From gaposmst Left Join gacommst On gaposmst.gapos_com_cd = gacommst.gacom_com_cd', N'', N'', N'', N'', N'', N'iRely Grain - Grain Postion Detail ', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 19, NULL)
INSERT INTO #TempCannedPanels VALUES (3, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely Petro - Invoice Margins Below 0 - Detail', N'Grid', N'', N'iRely Petro - Invoice Margins Below 0 - Detail', N'', N'', N'', N'i21 PT - Berry Oil ', N'All Dates', N'All Dates', N'ptstmmst.ptstm_rev_dt', N'', N'Select ptstmmst.ptstm_bill_to_cus, ptstm_ivc_no, ptstmmst.ptstm_ship_rev_dt, ptstmmst.ptstm_itm_no, ptstmmst.ptstm_loc_no, ptstmmst.ptstm_class
, ptstmmst.ptstm_un, ptstmmst.ptstm_un_prc, ptstmmst.ptstm_net, ptstmmst.ptstm_cgs, ptstmmst.ptstm_slsmn_id, ptstmmst.ptstm_pak_desc
, ptstmmst.ptstm_un_desc, ptstmmst.ptstm_net - ptstmmst.ptstm_cgs As ''Profit Amount'', (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net*100 As ''Profit Percent''
,(ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net as ''Profit''
From ptstmmst Where (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net Is Not Null 
And @DATE@ 
And ptstmmst.ptstm_net <> 0 And (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net*100 < ''0'' Order By [Profit]', N'', N'@DATE@', N'', N'', N'', N'iRely Petro - Invoice Margins Below 0 - Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'15.4.2', NULL, 3, 57, NULL)
INSERT INTO #TempCannedPanels VALUES (4, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely Petro - Inventory Overview Detail', N'Grid', N'', N'iRely Petro - Inventory Overview Detail', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'Select ptitmmst.ptitm_itm_no, ptitmmst.ptitm_desc, ptitmmst.ptitm_loc_no, ptitmmst.ptitm_class, ptitmmst.ptitm_unit, ptitmmst.ptitm_cost1, ptitmmst.ptitm_avg_cost, ptitmmst.ptitm_std_cost, ptitmmst.ptitm_on_hand From ptitmmst Where ptitmmst.ptitm_phys_inv_yno = ''Y''', N'', N'', N'', N'', N'', N'iRely Petro - Inventory Overview Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'15.4', NULL, 2, 63, NULL)
INSERT INTO #TempCannedPanels VALUES (5, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely AG - Open Contracts Detail', N'Grid', N'', N'iRely AG - Open Contracts Detail', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agcntmst.agcnt_cus_no, agcusmst.agcus_last_name, agcusmst.agcus_first_name, agcntmst.agcnt_loc_no, agcntmst.agcnt_cnt_no, agcntmst.agcnt_cnt_rev_dt, agcntmst.agcnt_due_rev_dt, agcntmst.agcnt_itm_or_cls, agcntmst.agcnt_prc_lvl, agcntmst.agcnt_ppd_yndm, agcntmst.agcnt_un_orig, agcntmst.agcnt_un_prc, agcntmst.agcnt_un_bal, agcntmst.agcnt_slsmn_id From agcntmst Left Join agcusmst ON agcntmst.agcnt_cus_no = agcusmst.agcus_key Where (agcntmst.agcnt_itm_or_cls <> ''*'' And agcntmst.agcnt_un_bal > 0.0)', N'', N'', N'', N'', N'', N'iRely AG - Open Contracts Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 50, NULL)
INSERT INTO #TempCannedPanels VALUES (7, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely AG - Inventory Available for Sale Detail', N'Grid', N'', N'iRely AG - Inventory Available for Sale Detail', N'', N'', N'', N'i21 AG - Demo Test', N'None', N'', N'', N'', N'Select agitmmst.agitm_no, agitmmst.agitm_loc_no, agitmmst.agitm_desc, agitmmst.agitm_class, agitmmst.agitm_un_desc, agitmmst.agitm_un_on_hand, agitmmst.agitm_un_pend_ivcs, agitmmst.agitm_un_on_order, agitmmst.agitm_un_mfg_in_prs, agitmmst.agitm_un_fert_committed, agitmmst.agitm_un_ord_committed, agitmmst.agitm_un_cnt_committed,  agitmmst.agitm_un_on_hand-agitmmst.agitm_un_pend_ivcs+agitmmst.agitm_un_on_order+agitmmst.agitm_un_mfg_in_prs-agitmmst.agitm_un_fert_committed-agitmmst.agitm_un_cnt_committed-agitmmst.agitm_un_ord_committed As [Available] From agitmmst', N'', N'', N'', N'', N'', N'iRely AG - Inventory Available for Sale Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.2.2', NULL, 1, 53, NULL)
INSERT INTO #TempCannedPanels VALUES (4378, 0, 15, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'i21 Data Dictionary - Column List', N'Grid', N'', N'i21 Data Dictionary - Column List', N'Bar', N'outside', N'Chameleon', N'i21', N'None', N'None', N'', N'', N'SELECT  sys.tables.name, C.name AS ''COLUMN NAME'',  P.name AS ''DATA TYPE'',
	replace(cast(colDes.DESCRIPTION as nvarchar(max)), '','', ''|'') as ''DESCRIPTION'',
	C.column_id as ''Column ID''
FROM sys.tables
INNER JOIN sys.columns AS C ON sys.tables.object_id = C.object_id
INNER JOIN sys.types AS P ON C.system_type_id = P.system_type_id
left join vyuFRMColumnDescription colDes on sys.tables.name = colDes.TABLE_NAME and C.name = colDes.COLUMN_NAME 
WHERE sys.tables.type_desc = ''USER_TABLE''
ORDER BY name, [Column ID]', N'', N'', N'', NULL, NULL, NULL, NULL, N'', N'None', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.4', NULL, 3, 118, NULL)
INSERT INTO #TempCannedPanels VALUES (15560, 0, 20, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely Store - Sales by Store Detail', N'Grid', N'', N'iRely Store - Sales by Store Detail', N'Bar', N'outside', N'Chameleon', N'i21DEMO', N'None', N'None', N'', N'', N'select sthssmst.sthss_store_name as ''store name'', 
	sthssmst.sthss_key_deptno as ''dept #'',
	sthssmst.sthss_key_total_sales as ''total sales'', dept.stdpt_desc,
	sthss_rec_type, sthss_rev_dt
from sthssmst
inner join stdptmst dept on sthssmst.sthss_key_deptno = dept.stdpt_id_n and sthssmst.sthss_store_name = dept.stdpt_store_name
where @DATE@', N'', N'', N'', NULL, NULL, NULL, NULL, N'', N'None', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.4.6', NULL, 6, 130, NULL)
 
print('/*******************  END INSERTING drill down canned panels on temporary panel table  *******************/')

print('/*******************  BEGIN INSERTING canned panels on temporary panel table  *******************/')

INSERT INTO #TempCannedPanels VALUES (6, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely GL - General Ledger History Detail', N'Grid', N'', N'iRely GL - General Ledger History Detail', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhstmst.glhst_trans_dt', N'', N'Select glhstmst.glhst_acct1_8, glhstmst.glhst_acct9_16, glhstmst.glhst_period, glhstmst.glhst_trans_dt, glhstmst.glhst_src_id, glhstmst.glhst_src_seq, glhstmst.glhst_dr_cr_ind, glhstmst.glhst_jrnl_no, glhstmst.glhst_ref, glhstmst.glhst_doc, Case When glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End As Amount, glhstmst.glhst_units, glhstmst.glhst_date From glhstmst Where @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely GL - General Ledger History Detail', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.2.2', NULL, 1, 26, NULL)
 
INSERT INTO #TempCannedPanels VALUES (9, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - A/R Customers 120 Days Past Due', N'Grid', N'', N'iRely AG - A/R Customers 120 Days Past Due - MUST REAGE DAILY TO BE ACCURATELY UPDATED', N'', N'', N'', N'i21 AG - Demo Test', N'None', N'', N'', N'', N'select agcusmst.agcus_last_name, agcusmst.agcus_first_name, agcusmst.agcus_key,
agcusmst.agcus_ar_per5 as ''Amount''
from agcusmst where (agcusmst.agcus_ar_per5>0)', N'', N'', N'', N'', N'', N'iRely AG - A/R Customers 120 Days Past Due', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 44, NULL)
 
INSERT INTO #TempCannedPanels VALUES (10, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - A/R Summary', N'Grid', N'', N'iRely AG - A/R Summary - MUST REAGE DAILY TO BE ACCURATELY UPDATED', N'', N'', N'', N'i21 AG - Demo Test', N'None', N'', N'', N'', N'select sum(agcusmst.agcus_ar_future) as ''Future'', sum(agcusmst.agcus_ar_per1) as ''Current'', sum(agcusmst.agcus_ar_per2) as ''30days'', sum(agcusmst.agcus_ar_per3) as ''60days'', sum(agcusmst.agcus_ar_per4) as ''90days'', sum(agcusmst.agcus_ar_per5) as ''120days''
from agcusmst
', N'', N'', N'', N'', N'', N'iRely AG - A/R Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1.1', NULL, 1, 47, NULL)
 
INSERT INTO #TempCannedPanels VALUES (11, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Bank Account Balances', N'Grid', N'', N'iRely AP - Bank Account Balances', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'SELECT apcbkmst.apcbk_desc, apcbkmst.apcbk_no, apcbkmst.apcbk_bal From apcbkmst', N'', N'', N'', N'', N'', N'iRely AP - Bank Account Balances', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1.1', NULL, 1, 37, NULL)
 
INSERT INTO #TempCannedPanels VALUES (12, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Check History', N'Grid', N'', N'iRely AP - Check History', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'apchk_rev_dt', N'', N'select apchkmst.apchk_cbk_no, apchkmst.apchk_rev_dt, apchkmst.apchk_vnd_no, apchkmst.apchk_name, apchkmst.apchk_chk_amt, apchkmst.apchk_disc_amt, apchkmst.apchk_gl_rev_dt, apchkmst.apchk_cleared_ind, apchkmst.apchk_clear_rev_dt, apchkmst.apchk_src_sys
From apchkmst Where @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely AP - Check History', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'15.4.2', NULL, 3, 36, NULL)
 
INSERT INTO #TempCannedPanels VALUES (13, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Open Payables', N'Grid', N'', N'iRely AP - Open Payables', N'', N'', N'', N'Fort Books TE', N'None', N'', N'', N'', N'Select apivcmst.apivc_ivc_no, apivcmst.apivc_ivc_rev_dt, apivcmst.apivc_status_ind, apivcmst.apivc_vnd_no, apivcmst.apivc_due_rev_dt, Case When apivcmst.apivc_trans_type = ''C'' Or apivcmst.apivc_trans_type = ''A'' Then apivcmst.apivc_net_amt * -1 Else apivcmst.apivc_net_amt End As ''amounts'', ssvndmst.ssvnd_name From apivcmst Left Join ssvndmst On apivcmst.apivc_vnd_no = ssvndmst.ssvnd_vnd_no Where apivcmst.apivc_status_ind = ''U''', N'', N'', N'', N'', N'', N'iRely AP - Open Payables', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.2', NULL, 1, 73, NULL)
 
INSERT INTO #TempCannedPanels VALUES (14, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Outstanding Checks', N'Grid', N'', N'iRely AP - Outstanding Checks', N'', N'', N'', N'i21 PT - Berry Oil ', N'This Year', N'This Year', N'apchk_rev_dt', N'', N'Select apchkmst.apchk_rev_dt, apchkmst.apchk_name, apchkmst.apchk_chk_amt, apchkmst.apchk_cleared_ind From apchkmst Where apchkmst.apchk_cleared_ind Is Null And @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely AP - Outstanding Checks', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.2', NULL, 1, 35, NULL)
 
INSERT INTO #TempCannedPanels VALUES (15, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Paid Payables History', N'Grid', N'', N'iRely AP - Paid Payables History', N'', N'', N'', N'i21 PT - Berry Oil ', N'This Year', N'', N'apivc_ivc_rev_dt', N'', N'Select apivcmst.apivc_ivc_no, apivcmst.apivc_ivc_rev_dt, apivcmst.apivc_status_ind, apivcmst.apivc_vnd_no, apivcmst.apivc_due_rev_dt, Case When apivcmst.apivc_trans_type = ''C'' Or apivcmst.apivc_trans_type = ''A'' Then apivcmst.apivc_net_amt * -1 Else apivcmst.apivc_net_amt End As ''amounts'', ssvndmst.ssvnd_name From apivcmst Left Join ssvndmst On apivcmst.apivc_vnd_no = ssvndmst.ssvnd_vnd_no Where apivcmst.apivc_status_ind = ''U'' And @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely AP - Paid Payables History', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1.1', NULL, 1, 38, NULL)
 
INSERT INTO #TempCannedPanels VALUES (16, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Revenue vs Costs Monthly', N'Chart', N'', N'iRely AG - Revenue vs Costs Monthly', N'Column', N'outside', N'', N'i21 AG - Demo Test', N'This Year', N'This Year', N'agstmmst.agstm_ship_rev_dt', N'agstmmst.agstm_ship_rev_dt', N'Select Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112)) As ''Month'', Sum(agstmmst.agstm_sls) As ''Sales'' From agstmmst Where @DATE@
Group By Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112)) 
Order By Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112))', N'Select Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112)) As ''Month'', Sum(agstmmst.agstm_cgs) As ''Costs'' From agstmmst Where @DATE@
Group By Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112)) 
Order By Month(Convert(date,Convert(char(8),agstmmst.agstm_ship_rev_dt),112))', N'@DATE@', N'@DATE@', N'', N'', N'iRely AG - Revenue vs Costs Monthly', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 65, NULL)
 
INSERT INTO #TempCannedPanels VALUES (17, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Sales by Customer', N'Grid', N'', N'iRely AG - Sales by Customer', N'', N'', N'', N'i21 AG - Demo Test', N'Last Month', N'Last Month', N'agstmmst.agstm_ship_rev_dt', N'', N'SELECT agcusmst.agcus_last_name AS ''Customer Last Name'', agcusmst.agcus_first_name AS ''First Name'', agcusmst.agcus_key AS ''Customer Code'', Sum(agstmmst.agstm_sls) AS ''Sales'', Sum(agstmmst.agstm_un) as ''Units''
FROM agstmmst
Left Join agcusmst On agstmmst.agstm_bill_to_cus = agcusmst.agcus_key
Where @DATE@
GROUP BY agcusmst.agcus_last_name, agcusmst.agcus_first_name, agcusmst.agcus_key
ORDER BY [Sales] DESC', N'', N'@DATE@', N'', N'', N'', N'iRely AG - Sales by Customer', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'15.4.2', NULL, 3, 69, NULL)
 
INSERT INTO #TempCannedPanels VALUES (18, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Sales by Item/Product', N'Grid', N'', N'iRely AG - Sales by Item/Product', N'', N'', N'', N'i21 AG - Demo Test', N'Last Month', N'', N'agstmmst.agstm_ship_rev_dt', N'', N'Select agstmmst.agstm_itm_no, agitmmst.agitm_desc, Sum(agstmmst.agstm_sls) As ''Sales'', Sum(agstmmst.agstm_un) As ''Units'' From agstmmst Left Join agitmmst On agstmmst.agstm_itm_no = agitmmst.agitm_no And agstmmst.agstm_loc_no = agitmmst.agitm_loc_no Where @DATE@ And agstmmst.agstm_sls <> 0 Group By agstmmst.agstm_itm_no, agitmmst.agitm_desc Order By [Sales] Desc', N'', N'@DATE@', N'', N'', N'', N'iRely AG - Sales by Item/Product', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'15.4.3', NULL, 4, 70, NULL)
 
INSERT INTO #TempCannedPanels VALUES (19, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Sales by Location ', N'Chart', N'', N'iRely AG - Sales by Location ', N'Bar', N'outside', N'Category5', N'FortBooks', N'This Year', N'This Year', N'agstmmst.agstm_ship_rev_dt', N'agstmmst.agstm_ship_rev_dt', N'Select agstmmst.agstm_key_loc_no, Sum(agstmmst.agstm_sls) As ''Sales'' From agstmmst Where @DATE@ Group By agstmmst.agstm_key_loc_no', N'Select agstmmst.agstm_key_loc_no, Sum(agstmmst.agstm_cgs) As ''Costs'' From agstmmst Where @DATE@ Group By agstmmst.agstm_key_loc_no', N'@DATE@', N'@DATE@', N'', N'', N'iRely AG - Sales by Location ', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 46, NULL)
 
INSERT INTO #TempCannedPanels VALUES (20, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Slow Moving Inventory', N'Grid', N'', N'iRely AG - Slow Moving Inventory', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agitmmst.agitm_no, agitmmst.agitm_loc_no, agitmmst.agitm_desc, agitmmst.agitm_un_on_hand, agitmmst.agitm_last_sale_rev_dt, agitmmst.agitm_phys_inv_ynbo, agitmmst.agitm_un_desc From agitmmst Where agitmmst.agitm_phys_inv_ynbo = ''Y'' and agitmmst.agitm_last_sale_rev_dt <>''0''
 Order By agitmmst.agitm_last_sale_rev_dt', N'', N'', N'', N'', N'', N'iRely AG - Slow Moving Inventory', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 72, NULL)
 
INSERT INTO #TempCannedPanels VALUES (21, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Orders', N'Grid', N'', N'iRely AG - Orders', N'', N'', N'', N'i21 AG - Demo Test', N'None', N'', N'', N'', N'Select agordmst.agord_cus_no, agordmst.agord_ord_no, agordmst.agord_loc_no, agordmst.agord_ord_rev_dt, agordmst.agord_type, agordmst.agord_itm_no, agordmst.agord_pkg_sold From agordmst Where agordmst.agord_type = ''O'' ', N'', N'', N'', N'', N'', N'iRely AG - Orders', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 52, NULL)
 
INSERT INTO #TempCannedPanels VALUES (22, 0, 25, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Pivot Table', N'Pivot Grid', N'', N'i21 General Ledger - Pivot Table', N'', N'', N'', N'Fort Books TE', N'Last Month', N'Last Month', N'dtmDate', N'', N'Select tblGLDetail.*,
  tblGLAccount.*,
  tblGLAccountGroup.*
from tblGLDetail
left join tblGLAccount on tblGLDetail.intAccountId = tblGLAccount.intAccountId
            left join tblGLAccountGroup on tblGLAccount.intAccountGroupId = tblGLAccountGroup.intAccountGroupId
            WHERE ysnIsUnposted = 0 And @DATE@ ', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Pivot Table', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'{"aggregate":[],"leftAxis":[],"topAxis":[]}', 0, 0, NULL, NULL, N'14.1.7', NULL, 1, 74, NULL)
 
INSERT INTO #TempCannedPanels VALUES (23, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - GL Summary', N'Grid', N'', N'i21 General Ledger - GL Summary', N'', N'', N'', N'Fort Books TE', N'Last Month', N'Last Month', N'dtmDate', N'', N'Select tblGLAccount.strAccountId
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
strAccountId
, strDescription', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - GL Summary', N'', N'', N'', N'', N'', N'', N'', N'', N'', N'', 0, 0, NULL, NULL, N'15.4.5', NULL, 3, 76, NULL)
 
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
strAccountId
, strDescription', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - GL History Detail', N'', N'', N'', N'', N'', N'', N'', N'strAccountId', NULL, N'', 0, 1, NULL, NULL, N'15.4.3', NULL, 4, 75, NULL)
 
INSERT INTO #TempCannedPanels VALUES (25, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Asset Breakdown', N'Grid', N'', N'i21 General Ledger - Asset Breakdown', N'', N'', N'', N'Fort Books TE', N'Last Month', N'All Dates', N'dtmDate', N'', N'select strAccountId, strDescription, SUM(Amount) as Amount
FROM
      (
            select B.strAccountId, B.strDescription, (A.dblDebit - A.dblCredit) as Amount  from tblGLDetail A
            left join tblGLAccount B on A.intAccountId = B.intAccountId
            left join tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
            WHERE A.ysnIsUnposted = 0 and C.strAccountType = ''Asset'' and @DATE@
      ) tblGL 
GROUP BY strAccountId, strDescription
', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Asset Breakdown', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.1.2', NULL, 1, 77, NULL)
 
INSERT INTO #TempCannedPanels VALUES (26, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Liability Breakdown', N'Grid', N'', N'i21 General Ledger - Liability Breakdown', N'', N'', N'', N'Fort Books TE', N'Last Month', N'', N'dtmDate', N'', N'select strAccountId, strDescription, SUM(Amount) as Amount
FROM
      (
            select B.strAccountId, B.strDescription, (A.dblDebit - A.dblCredit) as Amount  from tblGLDetail A
            left join tblGLAccount B on A.intAccountId = B.intAccountId
            left join tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
            WHERE A.ysnIsUnposted = 0 and C.strAccountType = ''Liability'' and @DATE@
      ) tblGL 
GROUP BY strAccountId, strDescription
', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Liability Breakdown', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.1.4', NULL, 1, 78, NULL)
 
INSERT INTO #TempCannedPanels VALUES (27, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Revenue Breakdown', N'Grid', N'', N'i21 General Ledger - Revenue Breakdown', N'', N'', N'', N'Fort Books TE', N'Last Month', N'Last Month', N'dtmDate', N'', N'select strAccountId, strDescription, SUM(Amount) as Amount
FROM
      (
            select B.strAccountId, B.strDescription, (A.dblDebit - A.dblCredit) as Amount  from tblGLDetail A
            left join tblGLAccount B on A.intAccountId = B.intAccountId
            left join tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
            WHERE A.ysnIsUnposted = 0 and C.strAccountType = ''Sales'' and @DATE@ 
      ) tblGL 
GROUP BY strAccountId, strDescription
', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Revenue Breakdown', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.1.6', NULL, 1, 79, NULL)
 
INSERT INTO #TempCannedPanels VALUES (28, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Credits on Interface File', N'Grid', N'', N'iRely GL - Credits on Interface File ', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select glijemst.glije_date, glijemst.glije_src_sys, glijemst.glije_ref, glijemst.glije_doc, glijemst.glije_dr_cr_ind, glijemst.glije_amt, glijemst.glije_acct_no From glijemst Where glijemst.glije_dr_cr_ind = ''C''', N'', N'', N'', N'', N'', N'iRely GL - Credits on Interface File', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 28, NULL)
 
INSERT INTO #TempCannedPanels VALUES (29, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Expenses/COGS Breakdown', N'Grid', N'', N'i21 General Ledger - Expenses/COGS Breakdown', N'', N'', N'', N'Fort Books TE', N'Last Month', N'Last Month', N'dtmDate', N'', N'select strAccountId, strDescription, SUM(Amount) as Amount
FROM
      (
            select B.strAccountId, B.strDescription, (A.dblDebit - A.dblCredit) as Amount  from tblGLDetail A
            left join tblGLAccount B on A.intAccountId = B.intAccountId
            left join tblGLAccountGroup C on B.intAccountGroupId = C.intAccountGroupId
            WHERE A.ysnIsUnposted = 0 and C.strAccountType = ''Expense'' and @DATE@ or A.ysnIsUnposted = 0 and C.strAccountType = ''Cost of Goods Sold'' and @DATE@ 
      ) tblGL 
GROUP BY strAccountId, strDescription', N'', N'@DATE@', N'', N'', N'', N'i21 General Ledger - Expenses/COGS Breakdown', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.1.12', NULL, 1, 80, NULL)
 
INSERT INTO #TempCannedPanels VALUES (30, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Debits on Interface File', N'Grid', N'', N'iRely GL - Debits on Interface File ', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select glijemst.glije_date, glijemst.glije_src_sys, glijemst.glije_ref, glijemst.glije_doc, glijemst.glije_dr_cr_ind, glijemst.glije_amt, glijemst.glije_acct_no From glijemst Where glijemst.glije_dr_cr_ind = ''D''', N'', N'', N'', N'', N'', N'iRely GL - Debits on Interface File', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 29, NULL)
 
INSERT INTO #TempCannedPanels VALUES (31, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Motor Fuel Tax - Sales', N'Grid', N'', N'iRely Motor Fuel Tax - Sales', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'pxrpt_trans_rev_dt', N'', N'SELECT pxrptmst.pxrpt_trans_type, pxrptmst.pxrpt_trans_rev_dt, pxrptmst.pxrpt_src_sys, pxrptmst.pxrpt_ord_no, pxrptmst.pxrpt_car_name, pxrptmst.pxrpt_cus_name, pxrptmst.pxrpt_cus_state, pxrptmst.pxrpt_itm_desc, pxrptmst.pxrpt_itm_loc_no, pxrptmst.pxrpt_vnd_name, pxrptmst.pxrpt_vnd_state, pxrptmst.pxrpt_sls_trans_gals, pxrptmst.pxrpt_sls_fet_amt, pxrptmst.pxrpt_sls_set_amt, pxrptmst.pxrpt_sls_lc1_amt, pxrptmst.pxrpt_sls_lc2_amt, pxrptmst.pxrpt_sls_lc3_amt, pxrptmst.pxrpt_sls_lc4_amt, pxrpt_itm_dyed_yn, pxrpt_cus_acct_stat
FROM pxrptmst
WHERE @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely Motor Fuel Tax - Sales', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 25, NULL)
 
INSERT INTO #TempCannedPanels VALUES (32, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Expiring Contracts', N'Grid', N'', N'iRely Grain - Expiring Contracts', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select gacntmst.gacnt_pur_sls_ind, gacntmst.gacnt_cus_no, agcusmst.agcus_last_name, agcusmst.agcus_first_name, gacntmst.gacnt_com_cd, gacntmst.gacnt_cnt_no, gacntmst.gacnt_seq_no, gacntmst.gacnt_cnt_rev_dt, gacntmst.gacnt_beg_ship_rev_dt, gacntmst.gacnt_due_rev_dt, gacntmst.gacnt_pbhcu_ind, gacntmst.gacnt_no_un, gacntmst.gacnt_un_bal, gacntmst.gacnt_mkt_zone, gacntmst.gacnt_loc_no From gacntmst Left Join agcusmst On gacntmst.gacnt_cus_no = agcusmst.agcus_key Where gacntmst.gacnt_un_bal > 0 Order By gacntmst.gacnt_due_rev_dt', N'', N'', N'', N'', N'', N'iRely Grain - Expiring Conrtacts ', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 17, NULL)
 
INSERT INTO #TempCannedPanels VALUES (33, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Open Hedges', N'Grid', N'', N'iRely Grain - Open Hedges', N'', N'', N'', N'i21 AG - Demo Test', N'All Dates', N'All Dates', N'gahdg_rev_dt', N'', N'Select gahdgmst.gahdg_com_cd, gahdgmst.gahdg_broker_no, gahdgmst.gahdg_rev_dt, gahdgmst.gahdg_ref, gahdgmst.gahdg_loc_no, gahdgmst.gahdg_bot_prc, gahdgmst.gahdg_bot_basis, gahdgmst.gahdg_bot, gahdgmst.gahdg_bot_option, gahdgmst.gahdg_long_short_ind, gahdgmst.gahdg_un_hdg_bal, gahdgmst.gahdg_offset_yn, gahdg_hedge_yyyymm From gahdgmst Where gahdgmst.gahdg_offset_yn = ''N'' and @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely Grain - Open Hedges', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 21, NULL)
 
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
 
INSERT INTO #TempCannedPanels VALUES (37, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Open Storage', N'Grid', N'', N'iRely Grain - Open Storage', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select gastrmst.gastr_pur_sls_ind, gastrmst.gastr_com_cd, gastrmst.gastr_stor_type, gastrmst.gastr_cus_no, gastrmst.gastr_un_bal From gastrmst', N'', N'', N'', N'', N'', N'iRely Grain - Open Storage', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 22, NULL)
 
INSERT INTO #TempCannedPanels VALUES (38, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Production History', N'Grid', N'', N'iRely Grain - Production History', N'', N'', N'', N'Ag SQL 13.1', N'Last Month', N'Last Month', N'gaphsmst.gaphs_dlvry_rev_dt', N'', N'Select gaphsmst.gaphs_pur_sls_ind, gaphsmst.gaphs_cus_no, gaphsmst.gaphs_com_cd, gaphsmst.gaphs_dlvry_rev_dt, gaphsmst.gaphs_loc_no, gaphsmst.gaphs_tic_no, gaphsmst.gaphs_cus_ref_no, gaphsmst.gaphs_gross_wgt, gaphsmst.gaphs_tare_wgt, gaphsmst.gaphs_gross_un, gaphsmst.gaphs_wet_un, gaphsmst.gaphs_net_un, gaphsmst.gaphs_fees From gaphsmst Where @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely Grain - Production History', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 23, NULL)
 
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
 
INSERT INTO #TempCannedPanels VALUES (41, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Grain Flow - All Commodities', N'Chart', N'', N'iRely Grain - Grain Flow - All Commodities', N'Spline', N'rotate', N'', N'Ag SQL 13.1', N'This Year', N'This Year', N'gaphsmst.gaphs_dlvry_rev_dt', N'gaphsmst.gaphs_dlvry_rev_dt', N'Select Month(Convert(date,Convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112)) As ''Month'', Sum(gaphsmst.gaphs_net_un) As units 
From gaphsmst Where gaphsmst.gaphs_pur_sls_ind = ''P'' And @DATE@ 
Group By Month(Convert(date,Convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112)) 
,Year(Convert(date,Convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112)) 
Order By 
Year(Convert(date,Convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112)) 
,Month(Convert(date,Convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112))', N'Select Month(convert(date,convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112)) As ''Month'', Sum(gaphsmst.gaphs_net_un) As units From gaphsmst Where gaphsmst.gaphs_pur_sls_ind = ''S'' And @DATE@ 
Group By Month(convert(date,convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112))
Order By Month(convert(date,convert(char(8),gaphsmst.gaphs_dlvry_rev_dt),112))', N'@DATE@', N'@DATE@', N'', N'', N'iRely Grain - Grain Flow - All Commodities', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'15.4.4', NULL, 5, 16, NULL)
 
INSERT INTO #TempCannedPanels VALUES (42, 100, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - In-Transit Sales', N'Grid', N'', N'iRely Grain - In-Transit Sales', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select gaitrmst.gaitr_pur_sls_ind, gaitrmst.gaitr_loc_no, gaitrmst.gaitr_cus_no, agcusmst.agcus_last_name, agcusmst.agcus_first_name, gacommst.gacom_desc, gaitrmst.gaitr_tic_no, gaitrmst.gaitr_ship_rev_dt, gaitrmst.gaitr_gross_wgt, gaitrmst.gaitr_tare_wgt, gaitrmst.gaitr_how_ship_ind, gaitrmst.gaitr_cnt_no, gaitrmst.gaitr_cnt_seq_no, gaitrmst.gaitr_cnt_loc_no, gaitrmst.gaitr_un_out From agcusmst, gacommst, gaitrmst Where gaitrmst.gaitr_cus_no = agcusmst.agcus_key And gaitrmst.gaitr_com_cd = gacommst.gacom_com_cd And (gaitrmst.gaitr_pur_sls_ind = ''S'')', N'', N'', N'', N'', N'', N'iRely Grain - In-Transit Sales', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 15, NULL)
 
INSERT INTO #TempCannedPanels VALUES (43, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Open Contracts', N'Grid', N'', N'iRely Grain - Open Contracts', N'', N'', N'', N'Ag SQL 13.1', N'This Year', N'This Year', N'gacnt_due_rev_dt', N'', N'Select gacntmst.gacnt_pur_sls_ind, gacntmst.gacnt_com_cd, Left(gacntmst.gacnt_bot_option, 3) As ''Option Month'', Right(gacntmst.gacnt_bot_option, 2) As ''Option Year'', gacntmst.gacnt_due_rev_dt, Sum(gacntmst.gacnt_un_bal) As Balance, Sum(gacntmst.gacnt_un_bot_prc) As Price, Sum(gacntmst.gacnt_un_bal * gacntmst.gacnt_un_bot_prc) As ''Extended Amount'', Sum(gacntmst.gacnt_un_bal * gacntmst.gacnt_un_bot_prc) / Sum(gacntmst.gacnt_un_bal) As WAP, Sum(gacntmst.gacnt_un_bal * gacntmst.gacnt_un_bot_basis) / Sum(gacntmst.gacnt_un_bal) As WAB, Sum(gacntmst.gacnt_un_bal * gacntmst.gacnt_un_frt_basis) / Sum(gacntmst.gacnt_un_bal) As WAF, gacntmst.gacnt_cnt_no From gacntmst Where @DATE@ Group By gacntmst.gacnt_pur_sls_ind, gacntmst.gacnt_com_cd, Left(gacntmst.gacnt_bot_option, 3), gacntmst.gacnt_cnt_no, Right(gacntmst.gacnt_bot_option, 2), gacntmst.gacnt_due_rev_dt Having Sum(gacntmst.gacnt_un_bal) > ''0.000'' Order By gacnt_com_cd, [Option Month], [Option Year], gacnt_due_rev_dt, gacnt_pur_sls_ind', N'', N'@DATE@', N'', N'', N'', N'iRely Grain - Open Contracts', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'15.4', NULL, 2, 18, NULL)
 
INSERT INTO #TempCannedPanels VALUES (44, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Orders', N'Grid', N'', N'iRely Petro - Orders', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'Select ptticmst.pttic_cus_no, ptcusmst.ptcus_last_name, ptcusmst.ptcus_first_name, ptticmst.pttic_tic_no, ptticmst.pttic_rev_dt, ptticmst.pttic_type, ptticmst.pttic_itm_no, ptticmst.pttic_qty_orig From ptticmst Left Join ptcusmst On ptticmst.pttic_cus_no = ptcusmst.ptcus_cus_no Where ptticmst.pttic_type = ''O'' Order By ptticmst.pttic_rev_dt', N'', N'', N'', N'', N'', N'iRely Petro - Orders', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 56, NULL)
 
INSERT INTO #TempCannedPanels VALUES (45, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - A/R Summary', N'Grid', N'', N'iRely Petro - A/R Summary - MUST REAGE DAILY TO BE ACCURATELY UPDATED', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'SELECT Sum(ptcusmst.ptcus_ar_curr) AS ''Current'', Sum(ptcusmst.ptcus_ar_3160) AS ''31-60 Days'', Sum(ptcusmst.ptcus_ar_6190) AS ''61-90 Days'', Sum(ptcusmst.ptcus_ar_91120) AS ''91-120 Days'', Sum(ptcusmst.ptcus_ar_ov120) AS ''Over 120 Days''
FROM ptcusmst', N'', N'', N'', N'', N'', N'iRely Petro - A/R Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 67, NULL)
 
INSERT INTO #TempCannedPanels VALUES (46, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Customers Over 120 Days Past Due', N'Grid', N'', N'iRely Petro - Customers Over 120 Days Past Due - MUST REAGE DAILY TO BE ACCURATELY UPDATED', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'SELECT ptcusmst.ptcus_cus_no, ptcusmst.ptcus_last_name, ptcusmst.ptcus_first_name, ptcusmst.ptcus_ar_ov120
FROM ptcusmst
WHERE (ptcusmst.ptcus_ar_ov120<>0)', N'', N'', N'', N'', N'', N'iRely Petro - Customers Over 120 Days Past Due', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 68, NULL)
 
INSERT INTO #TempCannedPanels VALUES (47, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Slow Moving Inventory', N'Grid', N'', N'iRely Petro - Slow Moving Inventory', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'SELECT ptitmmst.ptitm_itm_no, ptitmmst.ptitm_desc, ptitmmst.ptitm_unit, ptitmmst.ptitm_last_sale_rev_dt, ptitmmst.ptitm_on_hand, ptitmmst.ptitm_loc_no
FROM ptitmmst
Where ptitmmst.ptitm_phys_inv_yno=''Y'' And ptitmmst.ptitm_last_sale_rev_dt<>''0''
Order By ptitmmst.ptitm_last_sale_rev_dt', N'', N'', N'', N'', N'', N'iRely Petro - Slow Moving Inventory', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 71, NULL)
 
INSERT INTO #TempCannedPanels VALUES (48, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Sales by Item/Product ', N'Grid', N'', N'iRely Petro - Sales by Item/Product ', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'ptstmmst.ptstm_ship_rev_dt', N'', N'Select ptstmmst.ptstm_itm_no, ptitmmst.ptitm_desc, Sum(ptstmmst.ptstm_net) As ''Sales'', Sum(ptstmmst.ptstm_un) As ''Units'' From ptstmmst Left Join ptitmmst On ptstmmst.ptstm_itm_no = ptitmmst.ptitm_itm_no And ptstmmst.ptstm_key_loc_no = ptitmmst.ptitm_loc_no Where @DATE@ Group By ptstmmst.ptstm_itm_no, ptitmmst.ptitm_desc', N'', N'@DATE@', N'', N'', N'', N'iRely Petro - Sales by Item/Product ', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 58, NULL)
 
INSERT INTO #TempCannedPanels VALUES (49, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Sales by Location', N'Chart', N'', N'iRely Petro- Sales by Location', N'Column', N'outside', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'ptstmmst.ptstm_ship_rev_dt', N'', N'SELECT ptstmmst.ptstm_key_loc_no AS ''Location'', Sum(ptstmmst.ptstm_net) AS ''Sales''
FROM ptstmmst
Where @DATE@
GROUP BY ptstmmst.ptstm_key_loc_no
', N'', N'@DATE@', N'', N'', N'', N'iRely Petro - Sales by Location', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 59, NULL)
 
INSERT INTO #TempCannedPanels VALUES (50, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Revenue vs Costs Monthly', N'Chart', N'', N'iRely Petro - Revenue vs Costs Monthly', N'Column', N'outside', N'', N'i21 PT - Berry Oil ', N'This Year', N'This Year', N'ptstmmst.ptstm_rev_dt', N'ptstmmst.ptstm_rev_dt', N'Select Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112)) As ''Month'', 
Sum(ptstmmst.ptstm_net) As ''Sales''
From ptstmmst
Where @DATE@ and 
ptstmmst.ptstm_ship_rev_dt != 0
Group By Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112)) 
Order By [Month]', N'Select Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112)) As ''Month'', 
Sum(ptstmmst.ptstm_cgs) As ''Costs'' From ptstmmst
Where ptstmmst.ptstm_ship_rev_dt != 0
and @DATE@ 
Group By Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112)) 
Order By Month(Convert(date,Convert(char(8),ptstmmst.ptstm_ship_rev_dt),112))', N'@DATE@', N'@DATE@', N'', N'', N'iRely Petro - Revenue vs Costs Monthly', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'15.4.2', NULL, 3, 60, NULL)
 
INSERT INTO #TempCannedPanels VALUES (51, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Sales by Customer', N'Grid', N'', N'iRely Petro - Sales by Customer', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'ptstmmst.ptstm_ship_rev_dt', N'', N'SELECT ptcusmst.ptcus_last_name, ptcusmst.ptcus_first_name, ptcusmst.ptcus_cus_no, Sum(ptstmmst.ptstm_net) AS ''Sales'', Sum(ptstmmst.ptstm_un) AS ''Units''
FROM ptstmmst
Left join ptcusmst On ptstmmst.ptstm_bill_to_cus = ptcusmst.ptcus_cus_no
Where @DATE@
GROUP BY ptcusmst.ptcus_last_name, ptcusmst.ptcus_first_name, ptcusmst.ptcus_cus_no
Order By [Sales] DESC', N'', N'@DATE@', N'', N'', N'', N'iRely Petro - Sales by Customer', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'15.4', NULL, 2, 62, NULL)
 
INSERT INTO #TempCannedPanels VALUES (52, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Petro - Customers Over Credit Limit', N'Grid', N'', N'iRely Petro - Customers Over Credit Limit', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'select ptcusmst.ptcus_cus_no, ptcusmst.ptcus_last_name, ptcusmst.ptcus_first_name, ptcusmst.ptcus_credit_limit, ptcusmst.ptcus_ar_curr+ptcusmst.ptcus_ar_3160+ptcusmst.ptcus_ar_6190+ptcusmst.ptcus_ar_91120+ptcusmst.ptcus_ar_ov120-ptcusmst.ptcus_cred_ppd-ptcusmst.ptcus_cred_reg as ''Total Balance'', ptcusmst.ptcus_credit_limit-(ptcusmst.ptcus_ar_curr+ptcusmst.ptcus_ar_3160+ptcusmst.ptcus_ar_6190+ptcusmst.ptcus_ar_91120+ptcusmst.ptcus_ar_ov120-ptcusmst.ptcus_cred_ppd-ptcusmst.ptcus_cred_reg) as ''overage''
from ptcusmst
where (ptcusmst.ptcus_last_stmnt_bal<>0) and (ptcusmst.ptcus_credit_limit-ptcusmst.ptcus_last_stmnt_bal<0) And ptcusmst.ptcus_active_yn=''Y'' And ptcusmst.ptcus_credit_limit-(ptcusmst.ptcus_ar_curr+ptcusmst.ptcus_ar_3160+ptcusmst.ptcus_ar_6190+ptcusmst.ptcus_ar_91120+ptcusmst.ptcus_ar_ov120-ptcusmst.ptcus_cred_ppd-ptcusmst.ptcus_cred_reg) <0
', N'', N'', N'', N'', N'', N'iRely Petro - Customers Over Credit Limit', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 64, NULL)
 
INSERT INTO #TempCannedPanels VALUES (53, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 2, N'Master', N'iRely Grain - Grain Position Summary', N'Grid', N'', N'iRely Grain - Grain Position Summary', N'', N'', N'', N'Ag SQL 13.1', N'None', N'', N'', N'', N'Select gacommst.gacom_desc, Sum(gaposmst.gapos_in_house + gaposmst.gapos_offsite + gaposmst.gapos_sls_in_transit) As totals From gaposmst Left Join gacommst On gaposmst.gapos_com_cd = gacommst.gacom_com_cd Group By gacommst.gacom_desc', N'', N'', N'', N'', N'', N'iRely Grain - Grain Position Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 20, NULL)
 
INSERT INTO #TempCannedPanels VALUES (54, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AP - Cash Flow - Monthly', N'Chart', N'', N'iRely AP - Cash Flow - Monthly', N'Column Stacked', N'insideEnd', N'Sky', N'i21 PT - Berry Oil ', N'This Year', N'This Year', N'apchkmst.apchk_rev_dt', N'', N'Select Month(Convert(date,Convert(char(8),apchkmst.apchk_rev_dt),112)) As CheckDate, Sum(apchkmst.apchk_chk_amt) As Amount From apchkmst Where @DATE@ Group By Month(Convert(date,Convert(char(8),apchkmst.apchk_rev_dt),112)) Order By Month(Convert(date,Convert(char(8),apchkmst.apchk_rev_dt),112))', N'', N'@DATE@', N'', N'', N'', N'iRely AP - Cash Flow - Monthly', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 39, NULL)
 
INSERT INTO #TempCannedPanels VALUES (55, 0, 25, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely CF - Card Fueling Transactions', N'Pivot Grid', N'', N'iRely CF - Card Fueling Transactions', N'', N'', N'', N'i21 PT - Berry Oil ', N'This Month', N'This Month', N'cftrx_rev_dt', N'', N'Select cftrxmst.cftrx_ar_cus_no, cftrxmst.cftrx_card_no, cfcusmst.cfcus_card_desc, cftrxmst.cftrx_rev_dt, cftrxmst.cftrx_qty, cftrxmst.cftrx_prc, cftrxmst.cftrx_calc_total, cftrxmst.cftrx_ar_itm_no, cftrxmst.cftrx_ar_itm_loc_no, cftrxmst.cftrx_sls_id, cftrxmst.cftrx_sell_prc, cftrxmst.cftrx_prc_per_un, cftrxmst.cftrx_site, cftrxmst.cftrx_time, cftrxmst.cftrx_odometer, cftrxmst.cftrx_site_state, cftrxmst.cftrx_site_county, cftrxmst.cftrx_site_city, cftrxmst.cftrx_selling_host_id, cftrxmst.cftrx_buying_host_id, cftrxmst.cftrx_po_no, cftrxmst.cftrx_ar_ivc_no, cftrxmst.cftrx_calc_fet_amt, cftrxmst.cftrx_calc_set_amt, cftrxmst.cftrx_calc_sst_amt, cftrxmst.cftrx_tax_cls_id, cftrxmst.cftrx_ivc_prtd_yn, cftrxmst.cftrx_vehl_no, cftrxmst.cftrx_calc_net_sell_prc, cftrxmst.cftrx_pump_no From cftrxmst Inner Join cfcusmst On cftrxmst.cftrx_card_no = cfcusmst.cfcus_card_no And cftrxmst.cftrx_ar_cus_no = cfcusmst.cfcus_ar_cus_no
  Where @DATE@', N'', N'@DATE@', N'', N'', N'', N'iRely CF - Card Fueling Transactions', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'{"aggregate":[],"leftAxis":[],"topAxis":[]}', 0, 0, NULL, NULL, N'14.1.1', NULL, 1, 85, NULL)
 
INSERT INTO #TempCannedPanels VALUES (56, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 7, N'Master', N'iRely AG - Inventory Available for Sale Summary', N'Grid', N'', N'iRely AG - Inventory Available for Sale Summary', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agitmmst.agitm_no, agitmmst.agitm_loc_no, agitmmst.agitm_desc, agitmmst.agitm_un_desc, agitmmst.agitm_un_on_hand, agitmmst.agitm_un_pend_ivcs, agitmmst.agitm_un_on_order, agitmmst.agitm_un_mfg_in_prs, agitmmst.agitm_un_fert_committed, agitmmst.agitm_un_ord_committed, agitmmst.agitm_un_cnt_committed,  agitmmst.agitm_un_on_hand-agitmmst.agitm_un_pend_ivcs+agitmmst.agitm_un_on_order+agitmmst.agitm_un_mfg_in_prs-agitmmst.agitm_un_fert_committed-agitmmst.agitm_un_cnt_committed-agitmmst.agitm_un_ord_committed As [Available] From agitmmst', N'', N'', N'', N'', N'', N'iRely AG - Inventory Available for Sale Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 54, NULL)
 
INSERT INTO #TempCannedPanels VALUES (57, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 1, N'Master', N'iRely AG - Inventory Overview Summary', N'Grid', N'', N'iRely AG - Inventory Overview Summary', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agitmmst.agitm_class, agitmmst.agitm_no, agitmmst.agitm_loc_no, agitmmst.agitm_desc, agitmmst.agitm_un_desc, agitmmst.agitm_avg_un_cost, agitmmst.agitm_un_on_hand, agitmmst.agitm_last_un_cost, agitmmst.agitm_pak_desc, agitmmst.agitm_phys_inv_ynbo From agitmmst Where agitmmst.agitm_phys_inv_ynbo = ''Y'' Order By agitm_un_on_hand', N'', N'', N'', N'', N'', N'iRely AG - Inventory Overview Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 51, NULL)
 
INSERT INTO #TempCannedPanels VALUES (58, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 3, N'Master', N'iRely AG - Invoice Margins Below 0 - Summary', N'Grid', N'', N'iRely AG - Invoice Margins Below 0 - Summary', N'', N'', N'', N'i21 AG - Demo Test', N'All Dates', N'All Dates', N'agstmmst.agstm_ship_rev_dt', N'', N'Select agstmmst.agstm_ivc_no, (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls*100 As ''Profit Percent''
, agstmmst.agstm_ship_rev_dt, agstmmst.agstm_bill_to_cus 
,(agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls as ''Profit''
From agstmmst 
Where (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls Is Not Null And agstmmst.agstm_sls <> 0 
And (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls*100 <''0'' And @DATE@ 
Order By [Profit]', N'', N'@DATE@', N'', N'', N'', N'iRely AG - Invoice Margins Below 0 - Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'15.4.3', NULL, 4, 43, NULL)
 
INSERT INTO #TempCannedPanels VALUES (59, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 1, N'Master', N'iRely AG - Negative Inventory', N'Grid', N'', N'iRely AG - Negative Inventory', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agitmmst.agitm_no, agitmmst.agitm_desc, agitmmst.agitm_loc_no, agitmmst.agitm_un_on_hand, agitmmst.agitm_phys_inv_ynbo From agitmmst Where agitmmst.agitm_un_on_hand < 0 And agitmmst.agitm_phys_inv_ynbo = ''Y'' Order By agitmmst.agitm_un_on_hand', N'', N'', N'', N'', N'', N'iRely AG - Negative Inventory', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 42, NULL)
 
INSERT INTO #TempCannedPanels VALUES (60, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 5, N'Master', N'iRely AG - Open Contracts Summary', N'Grid', N'', N'iRely AG - Open Contracts Summary', N'', N'', N'', N'FortBooks', N'None', N'', N'', N'', N'Select agcntmst.agcnt_cus_no, agcusmst.agcus_last_name, agcusmst.agcus_first_name, agcntmst.agcnt_loc_no, agcntmst.agcnt_cnt_no, agcntmst.agcnt_cnt_rev_dt, agcntmst.agcnt_due_rev_dt, agcntmst.agcnt_itm_or_cls, agcntmst.agcnt_prc_lvl, agcntmst.agcnt_ppd_yndm, agcntmst.agcnt_un_orig, agcntmst.agcnt_un_prc, agcntmst.agcnt_un_bal, agcntmst.agcnt_slsmn_id From agcntmst Left Join agcusmst ON agcntmst.agcnt_cus_no = agcusmst.agcus_key Where (agcntmst.agcnt_itm_or_cls <> ''*'' And agcntmst.agcnt_un_bal > 0.0)', N'', N'', N'', N'', N'', N'iRely AG - Open Contracts Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 48, NULL)
 
INSERT INTO #TempCannedPanels VALUES (61, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 4, N'Master', N'iRely Petro - Inventory Overview Summary', N'Grid', N'', N'iRely Petro - Inventory Overview Summary', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'Select ptitmmst.ptitm_itm_no, ptitmmst.ptitm_desc, ptitmmst.ptitm_loc_no, ptitmmst.ptitm_on_hand From ptitmmst Where ptitmmst.ptitm_phys_inv_yno = ''Y''', N'', N'', N'', N'', N'', N'iRely Petro - Inventory Overview Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 55, NULL)
 
INSERT INTO #TempCannedPanels VALUES (62, 0, 5, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Cash Over and Short Totals', N'Chart', N'', N'iRely Store - Cash Over and Short Totals', N'Column Stacked', N'insideEnd', N'', N'i21 Demo', N'All Dates', N'All Dates', N'sthssmst.sthss_rev_dt', N'', N'SELECT sthssmst.sthss_store_name AS ''Store'', 
	Sum(sthssmst.sthss_tot_cash_overshort) AS ''Cash Over / Short Amount'', 
	sthssmst.sthss_rec_type
FROM sthssmst
WHERE @DATE@
GROUP BY sthssmst.sthss_store_name, sthssmst.sthss_rec_type
HAVING (sthssmst.sthss_rec_type=''TOT'')', N'', N'@DATE@', N'', N'', N'Compare and view your total cash over/short for total time period.
-C-Store Module-', N'Store - Cash Over and Short Totals', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 1, 0, NULL, NULL, N'15.4', NULL, 2, 90, NULL)
 
INSERT INTO #TempCannedPanels VALUES (63, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 3, N'Master', N'iRely Petro - Invoice Margins Below 0 - Summary', N'Grid', N'', N'iRely Petro - Invoice Margins Below 0 - Summary', N'', N'', N'', N'i21 PT - Berry Oil ', N'All Dates', N'', N'ptstmmst.ptstm_rev_dt', N'', N'Select ptstmmst.ptstm_bill_to_cus, ptstm_ivc_no, ptstmmst.ptstm_ship_rev_dt, ptstmmst.ptstm_itm_no, ptstmmst.ptstm_loc_no, ptstmmst.ptstm_class
, ptstmmst.ptstm_un, ptstmmst.ptstm_un_prc, ptstmmst.ptstm_net, ptstmmst.ptstm_cgs, ptstmmst.ptstm_slsmn_id, ptstmmst.ptstm_pak_desc, ptstmmst.ptstm_un_desc
, ptstmmst.ptstm_net - ptstmmst.ptstm_cgs As ''Profit Amount'', (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net*100 As ''Profit Percent'',
(ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net as ''Profit'' 
From ptstmmst Where (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net Is Not Null 
And @DATE@ 
And ptstmmst.ptstm_net <> 0 And (ptstmmst.ptstm_net - ptstmmst.ptstm_cgs) / ptstmmst.ptstm_net*100 < ''0'' 
Order By [Profit]', N'', N'@DATE@', N'', N'', N'', N'iRely Petro - Invoice Margins Below 0 - Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'15.4.3', NULL, 4, 61, NULL)
 
INSERT INTO #TempCannedPanels VALUES (64, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 4, N'Master', N'iRely Petro - Negative Inventory', N'Grid', N'', N'iRely Petro - Negative Inventory', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'Select ptitmmst.ptitm_itm_no, ptitmmst.ptitm_desc, ptitmmst.ptitm_loc_no, ptitmmst.ptitm_on_hand From ptitmmst Where ptitmmst.ptitm_on_hand < 0 And ptitmmst.ptitm_phys_inv_yno = ''Y'' Order By ptitmmst.ptitm_on_hand', N'', N'', N'', N'', N'', N'iRely Petro - Negative Inventory', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 66, NULL)
 
INSERT INTO #TempCannedPanels VALUES (65, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - General Ledger History Summary', N'Grid', N'', N'iRely GL - General Ledger History Summary', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhst_trans_dt', N'', N'Select glhstmst.glhst_acct1_8, glhstmst.glhst_acct9_16, glactmst.glact_desc, Sum(Case When glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 Else glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst On glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where @DATE@ Group By glhstmst.glhst_acct1_8, glhstmst.glhst_acct9_16, glactmst.glact_desc Order By glhstmst.glhst_acct1_8, glhstmst.glhst_acct9_16', N'', N'@DATE@', N'', N'', N'', N'iRely GL - General Ledger History Summary', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 27, NULL)
 
INSERT INTO #TempCannedPanels VALUES (67, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Grain - Deposit Register', N'Grid', N'', N'Rely Grain - Deposit Register', N'', N'', N'', N'AG/Grain - Demo - i21', N'None', N'', N'', N'', N'select gaaudpay_pmt_audit_no, gaaud_pur_sls_ind, gaaud_trans_type, gaaud_in_type,
gaaud_key_filler1, gaaudpay_pmt_rev_dt, gaaudpay_chk_no, gaaudpay_stl_amt, 
gaaudstl_stl_amt, gaaudstl_ivc_no, gaaudpay_cus_ref_no from gaeodmst where gaaud_pur_sls_ind= ''S''
and gaaud_in_type <> ''D0'' and gaaud_in_type <> ''J0'' and gaaud_trans_type in (''OS'', ''PY'')
', N'', N'', N'', N'', N'', N'iRely Grain - Deposit Register', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.3', NULL, 1, 88, NULL)
 
INSERT INTO #TempCannedPanels VALUES (68, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Cash Over and Short', N'Grid', N'', N'iRely Store - Cash Over and Short', N'', N'', N'', N'i21 Demo', N'This Month', N'', N'sthss_rev_dt', N'', N'Select sthssmst.sthss_store_name, 
	sthssmst.sthss_rev_dt, 
	CONVERT(datetime, CAST(sthssmst.sthss_rev_dt AS CHAR(8)), 101) as FormattedDate, 
	sthssmst.sthss_tot_cash_overshort, 
	sthssmst.sthss_rec_type 
From sthssmst 
Where sthssmst.sthss_rec_type = ''TOT'' 
And @DATE@', N'', N'@DATE@', N'', N'', N'Track your daily Cash Over and Short for each store for any timeframe.    -C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.4', NULL, 1, 89, NULL)
 
INSERT INTO #TempCannedPanels VALUES (69, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Assets Breakdown', N'Grid', N'', N'iRely GL - Assets Breakdown', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhstmst.glhst_trans_dt', N'', N'Select glactmst.glact_desc, Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst On glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where @DATE@ And glactmst.glact_type = ''A'' Group By glactmst.glact_desc Order By glactmst.glact_desc', N'', N'@DATE@', N'', N'', N'', N'iRely GL - Assets Breakdown', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 31, NULL)
 
INSERT INTO #TempCannedPanels VALUES (70, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Liabilities Breakdown', N'Grid', N'', N'iRely GL - Liabilities Breakdown', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhstmst.glhst_trans_dt', N'', N'Select glactmst.glact_desc, Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst On glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where @DATE@ And glactmst.glact_type = ''L'' Group By glactmst.glact_desc Order By glactmst.glact_desc', N'', N'@DATE@', N'', N'', N'', N'iRely GL - Liabilities Breakdown', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 32, NULL)
 
INSERT INTO #TempCannedPanels VALUES (71, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Revenue Breakdown', N'Grid', N'', N'iRely GL - Revenue Breakdown', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhstmst.glhst_trans_dt', N'', N'Select glactmst.glact_desc, Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst On glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where @DATE@ And glactmst.glact_type = ''I'' Group By glactmst.glact_desc Order By glactmst.glact_desc', N'', N'@DATE@', N'', N'', N'', N'iRely GL - Revenue Breakdown', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 33, NULL)
 
INSERT INTO #TempCannedPanels VALUES (72, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Customer Count by Store', N'Grid', N'', N'iRely Store - Customer Count by Store', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'sthss_rev_dt', N'', N'select sthss_store_name as ''Store Name'', 
	sthss_rev_dt as ''Date'', 
	sum(sthss_key_cust_count) as ''Total Customers''
from sthssmst
where sthss_rec_type=''KEY'' 
and @DATE@
group by sthss_store_name, sthss_rev_dt', N'', N'@DATE@', N'', N'', N'Track your customer count by store for each individual day.
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.2', NULL, 1, 91, NULL)
 
INSERT INTO #TempCannedPanels VALUES (73, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Expense-COGS Breakdown', N'Grid', N'', N'iRely GL - Expense-COGS Breakdown', N'', N'', N'', N'i21 PT - Berry Oil ', N'Last Month', N'Last Month', N'glhstmst.glhst_trans_dt', N'', N'Select glactmst.glact_desc, Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst On glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where (@DATE@ And glactmst.glact_type = ''E'') Or (@DATE@ And glactmst.glact_type = ''C'') Group By glactmst.glact_desc Order By glactmst.glact_desc', N'', N'@DATE@', N'', N'', N'', N'iRely GL - Expense-COGS Breakdown', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 34, NULL)
 
INSERT INTO #TempCannedPanels VALUES (74, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Assets/Liabilities Chart - Monthly', N'Chart', N'', N'iRely GL - Assets/Liabilities Chart - Monthly', N'Column', N'outside', N'Sky', N'i21 PT - Berry Oil ', N'This Year', N'This Year', N'glhstmst.glhst_trans_dt', N'glhstmst.glhst_trans_dt', N'Select Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) As ''Month'', Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst ON glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where (glactmst.glact_type = ''A'' And @DATE@) Group By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) Order By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112))', N'Select Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) As ''Month'', Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst ON glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where (glactmst.glact_type = ''L'' And @DATE@) Group By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) Order By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112))', N'@DATE@', N'@DATE@', N'', N'', N'iRely GL - Assets/Liabilities Chart - Monthly', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 41, NULL)
 
INSERT INTO #TempCannedPanels VALUES (75, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Dept Sales by Individual Day', N'Grid', N'', N'Store - Dept Sales by Individual Day', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'sthssmst.sthss_rev_dt', N'', N'select sthssmst.sthss_store_name, 
	sthssmst.sthss_rev_dt, 
	sthssmst.sthss_key_deptno, 
	sthssmst.sthss_key_desc,  
	sthssmst.sthss_key_total_sales
from sthssmst
where @DATE@', N'', N'@DATE@', N'', N'', N'Display your each department sales for each day.
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.3', NULL, 1, 92, NULL)
 
INSERT INTO #TempCannedPanels VALUES (76, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Revenue/Expense Chart - Monthly', N'Chart', N'', N'iRely GL - Revenue/Expense Chart - Monthly', N'Column', N'insideEnd', N'Base', N'i21 PT - Berry Oil ', N'This Year', N'This Year', N'glhstmst.glhst_trans_dt', N'glhstmst.glhst_trans_dt', N'SELECT 
Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) AS ''Month'', sum(case
when glactmst.glact_normal_value=''C'' and glhstmst.glhst_dr_cr_ind=''C'' then glhstmst.glhst_amt
when glactmst.glact_normal_value=''C'' and glhstmst.glhst_dr_cr_ind=''D'' then glhstmst.glhst_amt*-1
when glactmst.glact_normal_value=''D'' and glhstmst.glhst_dr_cr_ind=''C'' then glhstmst.glhst_amt*-1
when glactmst.glact_normal_value=''D'' and glhstmst.glhst_dr_cr_ind=''D'' then glhstmst.glhst_amt
end) AS Amount
FROM glhstmst Left Join glactmst ON glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 and glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where glactmst.glact_type=''I'' and @DATE@
group by Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112))
order by Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112))', N'Select Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) As Month, Sum(Case When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt When glactmst.glact_normal_value = ''C'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''C'' Then glhstmst.glhst_amt * -1 When glactmst.glact_normal_value = ''D'' And glhstmst.glhst_dr_cr_ind = ''D'' Then glhstmst.glhst_amt End) As Amount From glhstmst Left Join glactmst ON glhstmst.glhst_acct1_8 = glactmst.glact_acct1_8 And glhstmst.glhst_acct9_16 = glactmst.glact_acct9_16 Where ((glactmst.glact_type = ''E'' And @DATE@) Or (glactmst.glact_type = ''C'' And @DATE@)) Group By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112)) Order By Month(Convert(date,Convert(char(8),glhstmst.glhst_trans_dt),112))', N'@DATE@', N'@DATE@', N'', N'', N'iRely GL - Revenue/Expense Chart - Monthly', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 1, 0, NULL, NULL, N'14.1', NULL, 1, 40, NULL)
 
INSERT INTO #TempCannedPanels VALUES (77, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Fuel Margins by Store', N'Grid', N'', N'iRely Store - Fuel Margins by Store', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'sthssmst.sthss_rev_dt', N'', N'SELECT sthssmst.sthss_store_name, 
	sthssmst.sthss_pmp_id, 
	sthssmst.sthss_pmp_prc - sthssmst.sthss_pmp_cost as ''c''
FROM sthssmst
WHERE sthssmst.sthss_rec_type=''PMP''
AND @DATE@', N'', N'@DATE@', N'', N'', N'See your fuel margins (price-costs) for each product at each store.
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.3', NULL, 1, 94, NULL)
 
INSERT INTO #TempCannedPanels VALUES (78, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Fuel Sales by Store and Product', N'Grid', N'', N'iRely Store - Fuel Sales by Store and Product', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'sthssmst.sthss_rev_dt', N'', N'SELECT sthssmst.sthss_store_name, 
	sthssmst.sthss_pmp_desc, 
	Sum(sthssmst.sthss_pmp_amt) as ''c''
FROM sthssmst
WHERE (sthssmst.sthss_pmp_amt>0.000) 
and @DATE@
GROUP BY sthssmst.sthss_store_name, sthssmst.sthss_pmp_desc', N'', N'@DATE@', N'', N'', N'See your total sales of fuel for each store and product.
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.3', NULL, 1, 95, NULL)
 
INSERT INTO #TempCannedPanels VALUES (79, 5000, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Gallons by Store', N'Grid', N'', N'iRely Store - Gallons by Store', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'sthssmst.sthss_rev_dt', N'', N'SELECT sthssmst.sthss_store_name, 
	sthssmst.sthss_pmp_id, 
	Sum(sthssmst.sthss_pmp_qty) as c, 
	sthssmst.sthss_rec_type
FROM sthssmst
WHERE @DATE@
GROUP BY sthssmst.sthss_store_name, sthssmst.sthss_pmp_id, sthssmst.sthss_rec_type
HAVING (sthssmst.sthss_rec_type=''PMP'')', N'', N'@DATE@', N'', N'', N'Track your gallons sold of each fuel product for any timeframe.  
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.4', NULL, 2, 96, NULL)
 
INSERT INTO #TempCannedPanels VALUES (81, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Gross Profit by Store', N'Grid', N'', N'iRely Store - Gross Profit by Store', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'sthssmst.sthss_rev_dt', N'', N'select sthss_store_name as ''Store Name'', 
	sthss_key_deptno as ''Dept #'', 
	sum((sthss_key_total_sales * sthss_key_gp_pct) / 100) as ''Gross Profit''
from sthssmst
where sthss_rec_type = ''KEY'' 
and @DATE@
group by sthss_store_name, sthss_key_deptno', N'', N'@DATE@', N'', N'', N'View and compare your gross profit by store.
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.2', NULL, 1, 97, NULL)
 
INSERT INTO #TempCannedPanels VALUES (82, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely Store - Inventory Re-Order', N'Grid', N'', N'Store - Inventory Re-Order', N'', N'', N'', N'i21 Demo', N'None', N'', N'', N'', N'SELECT stpbkmst.stpbk_store_name AS ''Store #'', 
	stpbkmst.stpbk_upcno AS ''UPC #'', 
	stpbkmst.stpbk_item_desc AS ''Item Desc'', 
	stpbkmst.stpbk_min_qty AS ''Min Qty'', 
	stpbkmst.stpbk_on_hnd_qty AS ''On-Hand Qty''
FROM stpbkmst', N'', N'', N'', N'', N'Track those products that need reordered.
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.2', NULL, 1, 99, NULL)
 
INSERT INTO #TempCannedPanels VALUES (83, 10000, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - No Sales Transactions', N'Grid', N'', N'iRely Store - No Sales Transactions', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'sthssmst.sthss_rev_dt', N'', N'SELECT sthssmst.sthss_store_name AS ''Store'', 
	sthssmst.sthss_rev_dt AS ''Date'', 
	sthssmst.sthss_tot_no_nosales AS ''No Sale Transactions''
FROM sthssmst
WHERE @DATE@', N'', N'@DATE@', N'', N'', N'Display only the NO Sales Transactions with this exception panel.
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.2', NULL, 1, 100, NULL)
 
INSERT INTO #TempCannedPanels VALUES (84, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - On Sale Items', N'Grid', N'', N'iRely Store - On Sale Items', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'stpbkmst.stpbk_sale_startdate', N'', N'SELECT stpbkmst.stpbk_store_name AS ''Store #'', 
	stpbkmst.stpbk_upcno AS ''UPC #'', 
	stpbkmst.stpbk_item_desc AS ''Item Desc'', 
	stpbkmst.stpbk_sale_startdate as ''Start Date'', 
	stpbkmst.stpbk_sale_enddate as ''End Date'', 
	stpbkmst.stpbk_sale_price as ''Sale Price''
from stpbkmst
WHERE stpbkmst.stpbk_sale_startdate > 0
and @DATE@
ORDER BY stpbkmst.stpbk_sale_startdate', N'', N'@DATE@', N'', N'', N'View your on-sale items marked in the iRely software  
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.4', NULL, 1, 101, NULL)
 
INSERT INTO #TempCannedPanels VALUES (85, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Fuel Inventory Levels', N'Grid', N'', N'iRely Store - Fuel Inventory Levels', N'', N'', N'', N'i21 Demo', N'None', N'', N'', N'', N'SELECT stpbkmst.stpbk_store_name AS ''Store #'', 
	stpbkmst.stpbk_upcno AS ''UPC #'', 
	stpbkmst.stpbk_item_desc AS ''Item Desc'', 
	stpbkmst.stpbk_vnd_id AS ''Vendor ID'', 
	stpbkmst.stpbk_deptno AS ''Dept #'', 
	stpbkmst.stpbk_family AS ''Family'', 
	stpbkmst.stpbk_class AS ''Class'', 
	stpbkmst.stpbk_casecost AS ''Case Cost'', 
	stpbkmst.stpbk_price AS ''Retail Price'', 
	stpbkmst.stpbk_last_price AS ''Last Price'', 
	stpbkmst.stpbk_min_qty AS ''Min Qty'', 
	stpbkmst.stpbk_sug_qty AS ''Sug Qty'', 
	stpbkmst.stpbk_min_ord_qty AS ''Min Order Qty'', 
	stpbkmst.stpbk_on_hnd_qty AS ''On-Hand Qty'', 
	stpbkmst.stpbk_on_ord_qty AS ''On Order Qty'', 
	stpbkmst.stpbk_qty_sold AS ''Qty Sold''
FROM stpbkmst
where stpbk_pumped_yn=''P''', N'', N'', N'', N'', N'iRely Store - Fuel Inventory Levels', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.4', NULL, 1, 93, NULL)
 
INSERT INTO #TempCannedPanels VALUES (86, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Item Movement Detail', N'Pivot Grid', N'', N'iRely Store - Item Movement Detail', N'', N'', N'', N'i21 Demo', N'Last Week', N'', N'stithmst.stith_trx_rev_dt', N'', N'Select stithmst.stith_upcno As ''UPC #'', 
	stithmst.stith_trx_rev_dt As ''Trans Dt'', 
	stithmst.stith_rec_type As ''Purchase / Sale'', 
	stithmst.stith_store_name As ''Store'', 
	stithmst.stith_ivc_no As ''Inv #'', 
	stithmst.stith_dpt_id As ''Department'', 
	stithmst.stith_trx_qty As ''Purchase Qty'', 
	stithmst.stith_cst_un As ''Units Cost'', 
	stithmst.stith_rtl_un As ''Retail Price'', 
	stithmst.stith_wtd_qty_sold As ''Qty Sold'', 
	stithmst.stith_wtd_amt_sold As ''Amount Sold'',
	Month(CONVERT(datetime, CAST(stithmst.stith_trx_rev_dt AS CHAR(8)), 101)) As ''Month'',  
	stpbkmst.stpbk_item_desc As ''UPC Desc'', 
	stpbkmst.stpbk_family As ''Family'', 
	stpbkmst.stpbk_class As ''Class'' 
From stithmst 
Inner Join stpbkmst On stithmst.stith_upcno = stpbkmst.stpbk_upcno 
	And stithmst.stith_store_name = stpbkmst.stpbk_store_name 
Where @DATE@', N'', N'@DATE@', N'', N'', N'iRely Store - Item Movement Detail', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.4', NULL, 1, 98, NULL)
 
INSERT INTO #TempCannedPanels VALUES (87, 0, 15, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Dept Refund Totals', N'Grid', N'', N'iRely Store - Dept Refund Totals', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'sthssmst.sthss_rev_dt', N'', N'SELECT sthssmst.sthss_store_name AS ''Store'', 
	sthssmst.sthss_rev_dt AS ''Date'', 
	sthssmst.sthss_key_refund_amt AS ''Refund Amount''
FROM  sthssmst
WHERE sthssmst.sthss_key_refund_amt <> 0
and @DATE@', N'', N'@DATE@', N'', N'', N'See only your department refund totals for each store.
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.4', NULL, 1, 103, NULL)
 
INSERT INTO #TempCannedPanels VALUES (88, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 15560, N'Master', N'iRely Store - Sales by Store', N'Grid', N'', N'iRely Store - Sales by Store', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'sthssmst.sthss_rev_dt', N'', N'select sthssmst.sthss_store_name as ''store name'', 
	sthssmst.sthss_key_deptno as ''dept #'', 
	sum(sthssmst.sthss_key_total_sales) as ''total sales'', dept.stdpt_desc
from sthssmst
inner join stdptmst dept on sthssmst.sthss_key_deptno = dept.stdpt_id_n and sthssmst.sthss_store_name = dept.stdpt_store_name
where @DATE@
group by sthssmst.sthss_store_name, sthssmst.sthss_key_deptno, dept.stdpt_desc
', N'', N'@DATE@', N'', N'', N'Track and compare each sales by store and  each department.
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.4.5', NULL, 6, 104, NULL)
 
INSERT INTO #TempCannedPanels VALUES (89, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Shift Physicals Overview', N'Grid', N'', N'iRely Store - Shift Physicals Overview', N'', N'', N'', N'i21 Demo', N'None', N'', N'', N'', N'Select stphymst.stphy_store_name, 
	stphymst.stphy_rev_dt, 
	stphymst.stphy_shift_no, 
	stphymst.stphy_itm_id, 
	stphymst.stphy_upc_modno, 
	stphymst.stphy_itm_desc, 
	stphymst.stphy_cnt_what_cd, 
	stphymst.stphy_beg_qty, 
	stphymst.stphy_pur_qty, 
	stphymst.stphy_sls_qty, 
	stphymst.stphy_end_qty, 
	stphymst.stphy_diff_qty, 
	stphymst.stphy_beg_ser_no, 
	stphymst.stphy_end_ser_no, 
	stphymst.stphy_stick_rdg, 
	stphymst.stphy_posted_yn, 
	stphymst.stphy_pending_qty, 
	stphymst.stphy_entered_qty, 
	stphymst.stphy_deptno, 
	stphymst.stphy_price, 
	stphymst.stphy_binloc 
From stphymst', N'', N'', N'', N'', N'', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.3', NULL, 1, 105, NULL)
 
INSERT INTO #TempCannedPanels VALUES (90, 100, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Subpanel', N'iRely Store - Pricebook Detail', N'Grid', N'', N'iRely Store - Pricebook Detail', N'', N'', N'', N'i21 Demo', N'None', N'', N'', N'', N'SELECT stpbkmst.stpbk_store_name AS ''Store #'', 
	stpbkmst.stpbk_upcno AS ''UPC #'', 
	stpbkmst.stpbk_item_desc AS ''Item Desc'', 
	stpbkmst.stpbk_vnd_id AS ''Vendor ID'', 
	stpbkmst.stpbk_deptno AS ''Dept #'', 
	stpbkmst.stpbk_family AS ''Family'', 
	stpbkmst.stpbk_class AS ''Class'', 
	stpbkmst.stpbk_casecost AS ''Case Cost'', 
	stpbkmst.stpbk_price AS ''Retail Price'', 
	stpbkmst.stpbk_last_price AS ''Last Price'', 
	stpbkmst.stpbk_min_qty AS ''Min Qty'', 
	stpbkmst.stpbk_sug_qty AS ''Sug Qty'', 
	stpbkmst.stpbk_min_ord_qty AS ''Min Order Qty'', 
	stpbkmst.stpbk_on_hnd_qty AS ''On-Hand Qty'', 
	stpbkmst.stpbk_on_ord_qty AS ''On Order Qty'', 
	stpbkmst.stpbk_qty_sold AS ''Qty Sold''
FROM stpbkmst', N'', N'', N'', N'', N'Display your pricebook information in this sortable, filterable grid.
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.3', NULL, 1, 102, NULL)
 
INSERT INTO #TempCannedPanels VALUES (91, 0, 5, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Item Movement Purchases Monthly', N'Chart', N'', N'iRely Store - Item Movement Purchases Monthly', N'Column Stacked', N'insideEnd', N'Base', N'i21 Demo', N'This Year', N'This Year', N'stithmst.stith_trx_rev_dt', N'', N'SELECT 
	Month(CONVERT(datetime, CAST(stithmst.stith_trx_rev_dt AS CHAR(8)), 101))  as ''Trans Dt'', 
	Sum(stithmst.stith_trx_qty) as ''Purchase Qty''
FROM stithmst
WHERE @DATE@
GROUP BY Month(CONVERT(datetime, CAST(stithmst.stith_trx_rev_dt AS CHAR(8)), 101)) 
ORDER BY Month(CONVERT(datetime, CAST(stithmst.stith_trx_rev_dt AS CHAR(8)), 101))', N'', N'@DATE@', N'', N'', N'iRely Store - Item Movement Purchases Monthly', N'Store - Item Movement Purchases Monthly', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 1, 0, NULL, NULL, N'14.3.2', NULL, 1, 109, NULL)
 
INSERT INTO #TempCannedPanels VALUES (92, 0, 5, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Item Movement Sales Monthly', N'Chart', N'', N'iRely Store - Item Movement Sales Monthly', N'Column Stacked', N'insideEnd', N'Base', N'i21 Demo', N'This Year', N'This Year', N'stithmst.stith_trx_rev_dt', N'', N'SELECT 
	Month(CONVERT(datetime, CAST(stithmst.stith_trx_rev_dt AS CHAR(8)), 101)) as ''Trans Dt'', 
	Sum(stithmst.stith_wtd_amt_sold) as ''Amount Sold''
FROM stithmst
WHERE @DATE@
GROUP BY Month(CONVERT(datetime, CAST(stithmst.stith_trx_rev_dt AS CHAR(8)), 101))
ORDER BY Month(CONVERT(datetime, CAST(stithmst.stith_trx_rev_dt AS CHAR(8)), 101))', N'', N'@DATE@', N'', N'', N'iRely Store - Item Movement Sales Monthly', N'Store - Item Movement Sales Monthly', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 1, 0, NULL, NULL, N'14.3.2', NULL, 1, 106, NULL)
 
INSERT INTO #TempCannedPanels VALUES (93, 0, 5, 0, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Monthly Sales', N'Chart', N'', N'iRely Store - Monthly Sales', N'Line', N'under', N'Base', N'i21 Demo', N'This Year', N'This Year', N'sthssmst.sthss_rev_dt', N'', N'select 
	Month(CONVERT(datetime, CAST(sthssmst.sthss_rev_dt AS CHAR(8)), 101)) as ''Month'', 
	Sum(sthssmst.sthss_key_total_sales) as ''Total Sales''
from sthssmst
where @DATE@
GROUP BY Month(CONVERT(datetime, CAST(sthssmst.sthss_rev_dt AS CHAR(8)), 101))
ORDER BY Month(CONVERT(datetime, CAST(sthssmst.sthss_rev_dt AS CHAR(8)), 101))', N'', N'@DATE@', N'', N'', N'Use this line graph to display your monthly sales for any or all stores.
-C-Store Module-', N'Store - Monthly Sales', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 1, 0, NULL, NULL, N'14.3.3', NULL, 1, 107, NULL)
 
INSERT INTO #TempCannedPanels VALUES (94, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 Dashboard - Active Panel Users', N'Grid', N'', N'i21 Dashboard - Active Panel Users', N'', N'', N'', N'AG/Grain - Demo - i21', N'None', N'', N'', N'', N'Select 
	tblDBPanel.strPanelName, 
	tblDBPanelUser.intUserId, 
	tblSMUserSecurity.intEntityUserSecurityId, 
	tblSMUserSecurity.strUserName,
	tblSMUserSecurity.strFullName
From tblDBPanel
Inner Join tblDBPanelUser on tblDBPanel.intPanelId = tblDBPanelUser.intPanelId
Inner Join tblSMUserSecurity on tblDBPanelUser.intUserId = tblSMUserSecurity.intEntityUserSecurityId', N'', N'', N'', N'', N'Lists Users of all i21 Dashboard Active Panels, by Panel Name', N'i21 Dashboard - Active Panel Users', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'14.3.7', NULL, 1, 108, NULL)
 
INSERT INTO #TempCannedPanels VALUES (95, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Customers Over Credit Limit', N'Grid', N'', N'iRely AG - Customers Over Credit Limit', N'', N'', N'', N'i21 AG - Demo Test', N'None', N'', N'', N'', N'Select agcusmst.agcus_key, agcusmst.agcus_last_name, agcusmst.agcus_first_name, agcusmst.agcus_cred_limit, 
agcusmst.agcus_ar_future+agcusmst.agcus_ar_per1+agcusmst.agcus_ar_per3+agcusmst.agcus_ar_per2+agcusmst.agcus_ar_per4+agcusmst.agcus_ar_per5-agcusmst.agcus_cred_reg-agcusmst.agcus_cred_ppd As ''Total Balance'', agcusmst.agcus_cred_limit-(agcusmst.agcus_ar_future+agcusmst.agcus_ar_per1+agcusmst.agcus_ar_per3+agcusmst.agcus_ar_per2+agcusmst.agcus_ar_per4+agcusmst.agcus_ar_per5-agcusmst.agcus_cred_reg-agcusmst.agcus_cred_ppd) As ''Overage'' From agcusmst Where agcusmst.agcus_active_yn = ''Y'' And agcusmst.agcus_last_stmt_bal <> 0 And agcusmst.agcus_cred_limit-(agcusmst.agcus_ar_future+agcusmst.agcus_ar_per1+agcusmst.agcus_ar_per3+agcusmst.agcus_ar_per2+agcusmst.agcus_ar_per4+agcusmst.agcus_ar_per5-agcusmst.agcus_cred_reg-agcusmst.agcus_cred_ppd) < 0', N'', N'', N'', N'', N'', N'iRely AG - Customers Over Credit Limit', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1.3', NULL, 1, 86, NULL)
 
INSERT INTO #TempCannedPanels VALUES (96, 0, 10, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 General Ledger - Chart of Accounts', N'Grid', N'', N'i21 General Ledger - Chart of Accounts', N'Line', N'', N'Chameleon', N'Fort Books - i21', N'None', N'None', N'', N'', N'select strAccountId, strDescription from tblGLAccount', N'', N'', N'', N'', N'', N'', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.1', NULL, 1, 112, NULL)
 
INSERT INTO #TempCannedPanels VALUES (97, 0, 5, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 AP - Unposted Payables', N'Grid', N'', N'i21 AP - Unposted Payables', N'Line', N'', N'Chameleon', N'Fort Books - i21', N'None', N'None', N'', N'', N'select tblEMEntityCredential.strUserName as Employee, strVendorId as Vendor, tblAPBill.dtmDate as GLDate, tblAPBill.dtmBillDate as BillDate, tblAPBill.dtmDueDate as DueDate, strVendorOrderNumber as InvoiceNumber, tblAPBillDetail.dblTotal as ItemTotal, 
tblAPBillDetail.strMiscDescription as Item, tblGLAccount.strAccountId as Account, 
tblGLAccount.strDescription as AccountDesc, dblAmountDue as Due from tblAPBillDetail
inner join tblAPBill on tblAPBillDetail.intBillId = tblAPBill.intBillId
inner join tblAPVendor on tblAPBill.intEntityVendorId = tblAPVendor.intEntityVendorId
inner join tblGLAccount on tblAPBillDetail.intAccountId = tblGLAccount.intAccountId
inner join tblEMEntityCredential on tblAPBill.intEntityId = tblEMEntityCredential.intEntityId
where ysnPosted = ''0''', N'', N'', N'', N'', N'', N'', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.4.2', NULL, 8, 111, NULL)
 
INSERT INTO #TempCannedPanels VALUES (139, 0, 10, 100, 250, 0, NULL, NULL, NULL, 0, 1, 0, N'Master', N'i21 Tank Mgt - Deliveries for Review', N'Grid', N'', N'i21 Tank Mgt - Deliveries for Review', N'Line', NULL, N'Chameleon', N'i21 Demo', N'None', N'None', NULL, NULL, N'SELECT 
	vwcusmst.vwcus_key as ''Cust Number'',
	CASE 
		WHEN vwcusmst.vwcus_co_per_ind_cp = ''C''
			THEN (RTRIM(ISNULL(vwcusmst.vwcus_last_name COLLATE SQL_Latin1_General_CP1_CS_AS,'''')) + RTRIM(ISNULL(vwcusmst.vwcus_first_name COLLATE SQL_Latin1_General_CP1_CS_AS,'''')) + RTRIM(ISNULL(vwcusmst.vwcus_mid_init COLLATE SQL_Latin1_General_CP1_CS_AS,'''')) + RTRIM(ISNULL(vwcusmst.vwcus_name_suffix COLLATE SQL_Latin1_General_CP1_CS_AS,'''')))
		ELSE
		    CASE 
				WHEN vwcusmst.vwcus_first_name IS NULL OR RTRIM(vwcusmst.vwcus_first_name) = ''''
					THEN RTRIM(vwcusmst.vwcus_last_name) + RTRIM(vwcusmst.vwcus_name_suffix)
				ELSE RTRIM(vwcusmst.vwcus_last_name) + RTRIM(vwcusmst.vwcus_name_suffix) + '', '' + RTRIM(vwcusmst.vwcus_first_name) + RTRIM(vwcusmst.vwcus_mid_init)
			END
		END as ''Cust Name'',
	tblTMSite.intSiteNumber as ''Site Number'',
	tblTMDeliveryHistory.strProductDelivered as ''Item'',
	tblTMDeliveryHistory.dtmMarkForReviewDate ''Date Marked As For Review'',
	tblTMDeliveryHistory.dblGallonsInTankAfterDelivery as ''Gallons'',
	CASE 
		WHEN tblTMDeliveryHistory.dblQuantityDelivered < 0 
			THEN ''C'' 
		ELSE ''I'' 
	END as ''Transaction Type''
FROM tblTMDeliveryHistory
	INNER JOIN tblTMSite ON tblTMDeliveryHistory.intSiteID = tblTMSite.intSiteID
	INNER JOIN tblTMCustomer ON tblTMSite.intCustomerID = tblTMCustomer.intCustomerID
	INNER JOIN vwcusmst ON tblTMCustomer.intCustomerNumber = vwcusmst.A4GLIdentity
WHERE tblTMDeliveryHistory.ysnForReview = 1', NULL, N'', N'', NULL, NULL, NULL, NULL, N'', N'None', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.4.2', NULL, 19, 113, NULL)
 
INSERT INTO #TempCannedPanels VALUES (1260, 0, 20, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 Tank Mgt - Lease Info', N'Grid', N'', N'i21 Tank Mgt - Lease Info', N'Bar', N'outside', N'Chameleon', N'i21', N'None', N'None', N'', N'', N'select vwcusmst.vwcus_key as ''Cus #''
	,vwcusmst.vwcus_last_name as ''Last Name''
	,vwcusmst.vwcus_first_name as ''First Name''
	,tblTMLease.strLeaseNumber as ''Lease Number''
	,tblTMDevice.strSerialNumber as ''Tank Serial #''
	,tblTMDevice.dblTankCapacity as ''Tank Capacity''
	,tblTMLease.strLeaseStatus as ''Lease Status''
	,tblTMLeaseCode.strDescription as ''Lease Code Desc''
	,tblTMLeaseCode.dblAmount as ''Lease Amount''
	,tblTMLease.intBillingMonth as ''Lease Billing Month''
	,tblTMLease.strBillingFrequency as ''Lease Frequency''
	,tblTMLease.dtmStartDate as ''Lease Start Date''
	,tblTMLease.dtmLastLeaseBillingDate as ''Last Lease Billing Date''
from tblTMLease
left join tblTMLeaseDevice on tblTMLease.intLeaseId = tblTMLeaseDevice.intLeaseId
left outer join tblTMDevice on tblTMLeaseDevice.intDeviceId = tblTMDevice.intDeviceId
left outer join tblTMLeaseCode on tblTMLease.intLeaseCodeId = tblTMLeaseCode.intLeaseCodeId
left outer join vwcusmst on tblTMLease.intBillToCustomerId = vwcusmst.A4GLIdentity', N'', N'', N'', NULL, NULL, NULL, NULL, N'', N'None', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.2', NULL, 1, 116, NULL)
 
INSERT INTO #TempCannedPanels VALUES (3364, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely GL - Chart of Accounts', N'Grid', N'', N'iRely GL - Chart of Accounts', N'', N'', N'', N'i21 PT - Berry Oil ', N'None', N'', N'', N'', N'Select glactmst.glact_acct1_8, glactmst.glact_acct9_16, glactmst.glact_desc From glactmst ', N'', N'', N'', N'', N'', N'iRely GL - Chart of Accounts', N'', N'', N'None', N'', N'', N'', N'', NULL, NULL, NULL, 0, 0, NULL, NULL, N'14.1', NULL, 1, 30, NULL)
 

 
INSERT INTO #TempCannedPanels VALUES (4379, 0, 15, 100, 250, 0, 0, 0, 0, 0, 1, 4378, N'Master', N'i21 Data Dictionary - Table List', N'Grid', N'', N'i21 Data Dictionary - Table List', N'Bar', N'outside', N'Chameleon', N'i21', N'None', N'None', N'', N'', N'SELECT sys.tables.name
FROM sys.tables
WHERE sys.tables.type_desc = ''USER_TABLE'' and sys.tables.name like ''tbl%''
ORDER BY name', N'', N'', N'', NULL, NULL, NULL, NULL, N'', N'None', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.4', NULL, 4, 117, NULL)
 
INSERT INTO #TempCannedPanels VALUES (4395, 0, 10, 100, 250, 0, NULL, NULL, NULL, 0, 1, 0, N'Master', N'i21 Tank Mgt - Tank Township Details for Property Tax', N'Grid', N'', N'i21 Tank Mgt - Tank Township Details for Property Tax', N'Line', NULL, N'Chameleon', N'Fort Books - i21', N'None', N'None', NULL, NULL, N'select 
	vwcusmst.vwcus_last_name, 
	vwcusmst.vwcus_first_name, 
	tblTMTankTownship.strTankTownship, 
	tblTMSite.strSiteAddress, 
	tblTMSite.strCity, 
	tblTMSite.strState, 
	tblTMDevice.strBulkPlant, 
	tblTMDevice.dblPurchasePrice, 
	tblTMDevice.dtmPurchaseDate, 
	tblTMDevice.dtmManufacturedDate,
	tblTMDevice.strManufacturerID, 
	tblTMDevice.dblTankCapacity, 
	tblTMDevice.strSerialNumber, 
	tblTMInventoryStatusType.strInventoryStatusType, 
	tblTMDevice.strOwnership, 
	tblTMTankType.strTankType, 
	tblTMDeviceType.strDeviceType
from tblTMDevice
	left outer join tblTMSiteDevice on tblTMDevice.intDeviceId = tblTMSiteDevice.intDeviceId
	left outer join tblTMSite on tblTMSiteDevice.intSiteID = tblTMSite.intSiteID
	left outer join tblTMCustomer on tblTMSite.intCustomerID = tblTMCustomer.intCustomerID
	left outer join vwcusmst on tblTMCustomer.intCustomerNumber = vwcusmst.A4GLIdentity
	left outer join tblTMTankTownship on tblTMTankTownship.intTankTownshipId = tblTMSite.intTankTownshipId
	left outer join tblTMInventoryStatusType on tblTMInventoryStatusType.intInventoryStatusTypeId = tblTMDevice.intInventoryStatusTypeId
	left outer join tblTMTankType on tblTMTankType.intTankTypeId = tblTMDevice.intTankTypeId
	left outer join tblTMDeviceType on tblTMDeviceType.intDeviceTypeId = tblTMDevice.intDeviceTypeId
where strOwnership = ''Company Owned''', NULL, N'', N'', NULL, NULL, NULL, NULL, N'', N'None', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.1', NULL, 13, 114, NULL)
 
INSERT INTO #TempCannedPanels VALUES (4396, 0, 15, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely AG - Invoices Below Margins Detail', N'Grid', N'', N'iRely AG - Invoices Below Margins Detail', N'Bar', N'outside', N'Chameleon', N'i21 Temp', N'This Month', N'This Month', N'agstm_ship_rev_dt', N'', N'Select agstmmst.agstm_bill_to_cus, agstmmst.agstm_ivc_no, agstmmst.agstm_ship_rev_dt, agstmmst.agstm_itm_no, agstmmst.agstm_loc_no, 
agstmmst.agstm_class, agstmmst.agstm_un, agstmmst.agstm_un_prc, agstmmst.agstm_sls, agstmmst.agstm_un_cost, agstmmst.agstm_cgs, 
agstmmst.agstm_slsmn_id, agstmmst.agstm_pak_desc, agstmmst.agstm_un_desc, agstmmst.agstm_un_prc - agstmmst.agstm_un_cost As ''unit margins'', 
agstmmst.agstm_sls - agstmmst.agstm_cgs As ''Profit Amount'', (agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls*100 As ''Profit Percent'' ,
(agstmmst.agstm_sls - agstmmst.agstm_cgs) / agstmmst.agstm_sls as ''Profit''
From agstmmst 
Where agstmmst.agstm_itm_no Is Not Null And agstmmst.agstm_sls <> 0 
And ''Profit'' Is Not Null 
And @DATE@ 
Order By [Profit]', N'', N'@DATE@', N'', NULL, NULL, NULL, NULL, N'', N'None', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'15.4.2', NULL, 3, 115, NULL)
 
 
print('/*******************  END INSERTING canned panels on temporary panel table  *******************/')

--PAYROLL
print('/*******************  BEGIN INSERTING payroll canned panels on temporary panel table  *******************/')

INSERT INTO #TempCannedPanels VALUES (15561, 0, 20, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 Payroll - Paycheck Tax', N'Grid', N'', N'Paycheck Tax', N'Bar', N'outside', N'Chameleon', N'i21', N'Last Week', N'Last Week', N'PayDate', N'',
N'Declare @cols nvarchar(max)
select @cols = stuff( ( select distinct  '',['' + Ltrim(rtrim(strTax)) +'']'' from tblPRTypeTax FOR XML PATH('''')),1,1,'''')
EXEC(''select * from 
(
 select distinct
 EmployeeName = strFirstName + '''' '''' + strMiddleName + '''' '''' + strLastName 
 , CheckNo = PCheck.strPaycheckId
 , PayDate = PCheck.dtmPayDate
 , TaxTotal = PTax.dblTotal
 , TaxCode = TType.strTax
 --, TaxDescription = TType.strDescription
 , CheckTotal = PCheck.dblGross
 , CheckNet = PCheck.dblNetPayTotal
 from 
 tblPRPaycheck PCheck
 inner join tblPRPaycheckTax PTax on PCheck.intPaycheckId = PTax.intPaycheckId
 inner join tblPRTypeTax TType on PTax.intTypeTaxId = TType.intTypeTaxId
 inner join tblPREmployee E on E.intEntityEmployeeId = PCheck.intEntityEmployeeId
) as s PIVOT
(
 SUM(TaxTotal)
 FOR TaxCode IN ('' + @cols + '')
)as pvt 
where @DATE@ '')',
N'', N'@DATE@', N'@DATE@', N'', N'', N'', N'', N'', N'None', N'', N'', N'', N'', N'', N'', N'', 0, 0, NULL, NULL, N'16.2', NULL, 2, 131, N'')

INSERT INTO #TempCannedPanels VALUES (15562, 50, 15, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 Payroll - Paycheck Earnings', N'Grid', N'', N'Paycheck Earnings', N'Bar', N'outside', N'Chameleon', N'i21', N'Last Week', N'Last Week', N'PayDate', N'',
N'Declare @cols nvarchar(max)
select @cols = stuff( ( select distinct  '',['' + Ltrim(rtrim(strEarning)) +'']'' from tblPRTypeEarning FOR XML PATH('''')),1,1,'''')
EXEC(N''select * from 
(
	select distinct
	EmployeeName = strFirstName + '''' '''' + strMiddleName + '''' '''' + strLastName 
	, CheckNo = PCheck.strPaycheckId
	, PayDate = PCheck.dtmPayDate
	, EarningTotal = PTax.dblTotal
	, EarningCode = TType.strEarning 
	, CheckTotal = PCheck.dblGross
	, CheckNet = PCheck.dblNetPayTotal
	from 
	tblPRPaycheck PCheck
	inner join tblPRPaycheckEarning PTax on PCheck.intPaycheckId = PTax.intPaycheckId
	inner join tblPRTypeEarning TType on PTax.intTypeEarningId = TType.intTypeEarningId
	inner join tblPREmployee E on E.intEntityEmployeeId = PCheck.intEntityEmployeeId
) as s
PIVOT
(	SUM(EarningTotal)
	FOR EarningCode IN ('' + @cols + '')
)as pvt
where @DATE@ '')' ,
N'', N'@DATE@', N'@DATE@', N'', N'', N'', N'', N'', N'None', N'', N'', N'', N'', N'', N'', N'', 0, 0, NULL, NULL, N'16.2', NULL, 1, 132, N'')



INSERT INTO #TempCannedPanels VALUES (15563, 50, 15, 100, 250, 0, 0, 0, 0, 0, 1, 0, N'Master', N'i21 Payroll - Paycheck Deductions', N'Grid', N'', N'Paycheck Deductions', N'Bar', N'outside', N'Chameleon', N'i21', N'Last Week', N'Last Week', N'PayDate', N'',
N'Declare @cols nvarchar(max)
select @cols = stuff( ( select distinct '',['' + Ltrim(rtrim(strDeduction)) +'']'' from tblPRTypeDeduction FOR XML PATH('''')),1,1,'''')
EXEC(N''select * from 
(
	select distinct
	EmployeeName = strFirstName + '''' '''' + strMiddleName + '''' '''' + strLastName 
	, CheckNo = PCheck.strPaycheckId
	, PayDate = PCheck.dtmPayDate
	, DeductionTotal = PTax.dblTotal
	, DeductionCode = TType.strDeduction 
	--, TaxDescription = TType.strDescription
	, CheckTotal = PCheck.dblGross
	, CheckNet = PCheck.dblNetPayTotal
	from 
	tblPRPaycheck PCheck
	inner join tblPRPaycheckDeduction PTax on PCheck.intPaycheckId = PTax.intPaycheckId
	inner join tblPRTypeDeduction TType on PTax.intTypeDeductionId = TType.intTypeDeductionId
	inner join tblPREmployee E on E.intEntityEmployeeId = PCheck.intEntityEmployeeId
) as s
PIVOT
(	SUM(DeductionTotal)
	FOR DeductionCode IN ('' + @cols + '')
)as pvt 
where @DATE@ '')' ,
N'', N'@DATE@', N'@DATE@', N'', N'', N'', N'', N'', N'None', N'', N'', N'', N'', N'', N'', N'', 0, 0, NULL, NULL, N'16.2', NULL, 1, 133, N'')


print('/*******************  END INSERTING payroll canned panels on temporary panel table  *******************/')


INSERT INTO #TempCannedPanels VALUES (15564, 0, 5, 100, 400, 0, 0, 0, 0, 0, 1, 0, N'Master', N'iRely Store - Gallons by Store Chart', N'Chart', N'', N'iRely Store - Gallons by Store Chart', N'', N'', N'', N'i21 Demo', N'Last Month', N'', N'sthssmst.sthss_rev_dt', N'', N'SELECT sthssmst.sthss_store_name, 
	sthssmst.sthss_pmp_id, 
	Sum(sthssmst.sthss_pmp_qty) as c, 
	sthssmst.sthss_rec_type
FROM sthssmst
WHERE @DATE@
GROUP BY sthssmst.sthss_store_name, sthssmst.sthss_pmp_id, sthssmst.sthss_rec_type
HAVING (sthssmst.sthss_rec_type=''PMP'')', N'', N'@DATE@', N'', N'', N'Track your gallons sold of each fuel product for any timeframe.  
-C-Store Module-', N'', N'', N'', N'', N'', N'', N'', N'', NULL, NULL, N'', 0, 0, NULL, NULL, N'16.3', NULL, 2, 134, NULL)



















print('/*******************  BEGIN DELETING deleted canned panels  on table Panel  *******************/')
--This are panels that are deleted on  canned panel server.
DELETE tblDBPanel WHERE intCannedPanelId in (1,2,3,4,5,6,7,8,9,10,11,12,13,14,49,87,110)
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

print('/*******************  START DELETING OF CUSTOM CANNED PANEL  *******************/')
DECLARE @intCannedPanelId_custom int
DECLARE @intPanelId_custom int

DECLARE db_cursor_custom_canned_panel CURSOR FOR SELECT intCannedPanelId, intPanelId FROM [dbo].[tblDBPanel]

OPEN db_cursor_custom_canned_panel
FETCH NEXT FROM db_cursor_custom_canned_panel INTO @intCannedPanelId_custom, @intPanelId_custom
WHILE @@FETCH_STATUS = 0   
BEGIN		
	IF NOT EXISTS (SELECT TOP 1 1 FROM #TempCannedPanels WHERE intCannedPanelId = @intCannedPanelId_custom) and @intCannedPanelId_custom <> 0
	BEGIN
		--delete activated custom canned panel
		DELETE FROM [dbo].[tblDBPanelAccess] WHERE intPanelId IN (SELECT f.intPanelId FROM [dbo].[tblDBPanel] f where f.intSourcePanelId = @intPanelId_custom)
		DELETE FROM [dbo].[tblDBPanelColumn] where intPanelId IN (SELECT f.intPanelId FROM [dbo].[tblDBPanel] f where f.intSourcePanelId = @intPanelId_custom)
		DELETE FROM [dbo].[tblDBPanelFormat] where intPanelId IN (SELECT f.intPanelId FROM [dbo].[tblDBPanel] f where f.intSourcePanelId = @intPanelId_custom)
		DELETE FROM [dbo].[tblDBPanelUser] WHERE intPanelId IN (SELECT f.intPanelId FROM [dbo].[tblDBPanel] f where f.intSourcePanelId = @intPanelId_custom)
		DELETE FROM [dbo].[tblDBPanel] where intPanelId IN (SELECT f.intPanelId FROM [dbo].[tblDBPanel] f where f.intSourcePanelId = @intPanelId_custom)

		--delete custom canned panel
		DELETE FROM [dbo].[tblDBPanelAccess] WHERE intPanelId IN (SELECT top 1 f.intPanelId FROM [dbo].[tblDBPanel] f where f.intCannedPanelId = @intCannedPanelId_custom)
		DELETE FROM [dbo].[tblDBPanelColumn] where intCannedPanelId = @intCannedPanelId_custom
		DELETE FROM [dbo].[tblDBPanelFormat] where intCannedPanelId = @intCannedPanelId_custom
		DELETE FROM [dbo].[tblDBPanelUser] WHERE intPanelId IN (SELECT top 1 f.intPanelId FROM [dbo].[tblDBPanel] f where f.intCannedPanelId = @intCannedPanelId_custom)
		DELETE FROM [dbo].[tblDBPanel] where intCannedPanelId = @intCannedPanelId_custom		

	END

	

FETCH NEXT FROM db_cursor_custom_canned_panel INTO @intCannedPanelId_custom, @intPanelId_custom
END

CLOSE db_cursor_custom_canned_panel
DEALLOCATE db_cursor_custom_canned_panel

print('/*******************  END DELETING OF CUSTOM CANNED PANEL  *******************/')

DROP TABLE #TempCannedPanels
print('/*******************  END UPDATING canned panels on table Panel  *******************/')
/*******************  BEGIN UPDATING canned panels on table Panel *******************/
GO