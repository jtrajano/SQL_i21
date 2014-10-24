/*******************  BEGIN UPDATING canned panels on table Panel Column*******************/
print('/*******************  BEGIN UPDATING canned panels column *******************/')
GO
print('/*******************  CREATE TEMPORARY table for canned panels column *******************/')
IF OBJECT_ID('tempdb..#TempCannedPanelColumn') IS NOT NULL
    DROP TABLE #TempCannedPanelColumn

Create TABLE #TempCannedPanelColumn 
(
	[intPanelColumnId]   INT            NOT NULL,
    [intPanelId]         INT            NOT NULL,
    [strColumn]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCaption]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intWidth]           SMALLINT       DEFAULT ((30)) NOT NULL,
    [strAlignment]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strArea]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFooter]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFormat]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intSort]            SMALLINT       NOT NULL,
    [strFormatTrue]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFormatFalse]     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDrillDownColumn] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnVisible]         BIT            DEFAULT ((0)) NOT NULL,
    [strType]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strAxis]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strUserName]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intUserId]          INT            NOT NULL,
    [intDonut]           SMALLINT       NOT NULL,
    [intMinInterval]     SMALLINT       DEFAULT ((0)) NOT NULL,
    [intMaxInterval]     SMALLINT       DEFAULT ((0)) NOT NULL,
    [intStepInterval]    SMALLINT       DEFAULT ((0)) NOT NULL,
    [strIntervalFormat]  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnHiddenColumn]    BIT            DEFAULT ((0)) NOT NULL,
	[intConcurrencyId]	INT				NOT NULL,
    [intCannedPanelId] INT				NOT NULL DEFAULT ((0))		 	
)

print('/*******************  BEGIN INSERTING canned panels on temporary panel column table  *******************/')



 
INSERT INTO #TempCannedPanelColumn VALUES (1973, 30, N'glije_acct_no', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)
 
INSERT INTO #TempCannedPanelColumn VALUES (1974, 30, N'glije_date', N'Date', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)
 
INSERT INTO #TempCannedPanelColumn VALUES (1975, 30, N'glije_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)
 
INSERT INTO #TempCannedPanelColumn VALUES (1976, 30, N'glije_ref', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)
 
INSERT INTO #TempCannedPanelColumn VALUES (1977, 30, N'glije_doc', N'Document #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)
 
INSERT INTO #TempCannedPanelColumn VALUES (1978, 30, N'glije_amt', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)
 
INSERT INTO #TempCannedPanelColumn VALUES (1979, 31, N'glije_acct_no', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)
 
INSERT INTO #TempCannedPanelColumn VALUES (1980, 31, N'glije_date', N'Date', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)
 
INSERT INTO #TempCannedPanelColumn VALUES (1981, 31, N'glije_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)
 
INSERT INTO #TempCannedPanelColumn VALUES (1982, 31, N'glije_ref', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)
 
INSERT INTO #TempCannedPanelColumn VALUES (1983, 31, N'glije_doc', N'Document #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)
 
INSERT INTO #TempCannedPanelColumn VALUES (1984, 31, N'glije_amt', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)
 
INSERT INTO #TempCannedPanelColumn VALUES (1985, 33, N'gacnt_pur_sls_ind', N'P/S', 107, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1986, 33, N'gacnt_cus_no', N'Customer #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1987, 33, N'agcus_last_name', N'Last Name', 107, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1988, 33, N'agcus_first_name', N'First Name', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1989, 33, N'gacnt_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1990, 33, N'gacnt_com_cd', N'Com', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1991, 33, N'gacnt_cnt_no', N'Contact #', 106, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1992, 33, N'gacnt_seq_no', N'Seq', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1993, 33, N'gacnt_mkt_zone', N'Market Zone', 107, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1994, 33, N'gacnt_beg_ship_rev_dt', N'Beg Ship Date', 106, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1995, 33, N'gacnt_due_rev_dt', N'Due Date', 106, N'Right', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1996, 33, N'gacnt_pbhcu_ind', N'PBHU', 107, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1997, 33, N'gacnt_un_bal', N'Unit Balance', 106, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelColumn VALUES (1998, 41, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16)
 
INSERT INTO #TempCannedPanelColumn VALUES (1999, 41, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16)
 
INSERT INTO #TempCannedPanelColumn VALUES (2000, 41, N'units', N'Purchased Units', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16)
 
INSERT INTO #TempCannedPanelColumn VALUES (2001, 41, N'units', N'Sales Units', 0, N'Series2AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16)
 
INSERT INTO #TempCannedPanelColumn VALUES (2002, 37, N'gahdg_com_cd', N'Com', 107, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2003, 37, N'gahdg_broker_no', N'Broker #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2004, 37, N'gahdg_rev_dt', N'Date', 107, N'Right', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2005, 37, N'gahdg_ref', N'Ref#', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2006, 37, N'gahdg_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2007, 37, N'gahdg_bot_prc', N'BOT Price', 107, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2008, 37, N'gahdg_bot_basis', N'BOT Basis', 106, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2009, 37, N'gahdg_bot', N'BOT', 106, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2010, 37, N'gahdg_bot_option', N'BOT Option', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2011, 37, N'gahdg_long_short_ind', N'L / S', 106, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2012, 37, N'gahdg_un_hdg_bal', N'Balance', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2013, 37, N'gahdg_offset_yn', N'Offset?', 106, N'Left', N'', N'', N'Yes/No', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2014, 37, N'gahdg_hedge_yyyymm', N'Hedge', 107, N'Right', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)
 
INSERT INTO #TempCannedPanelColumn VALUES (2015, 38, N'gastr_pur_sls_ind', N'P or S', 278, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22)
 
INSERT INTO #TempCannedPanelColumn VALUES (2016, 38, N'gastr_com_cd', N'Com', 278, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22)
 
INSERT INTO #TempCannedPanelColumn VALUES (2017, 38, N'gastr_stor_type', N'Type', 277, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22)
 
INSERT INTO #TempCannedPanelColumn VALUES (2018, 38, N'gastr_cus_no', N'Customer #', 277, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22)
 
INSERT INTO #TempCannedPanelColumn VALUES (2019, 38, N'gastr_un_bal', N'Unit Balance', 277, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22)
 
INSERT INTO #TempCannedPanelColumn VALUES (2020, 42, N'gaphs_pur_sls_ind', N'P / S', 109, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2021, 42, N'gaphs_cus_no', N'Customer Code', 108, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2022, 42, N'gaphs_com_cd', N'Com', 108, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2023, 42, N'gaphs_loc_no', N'Loc', 108, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2024, 42, N'gaphs_tic_no', N'Ticket #', 107, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2025, 42, N'gaphs_cus_ref_no', N'Customer Ref', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2026, 42, N'gaphs_gross_wgt', N'Gross Weight', 105, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2027, 42, N'gaphs_tare_wgt', N'Tare Weight', 107, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2028, 42, N'gaphs_gross_un', N'Gross Units', 106, N'Right', N'', N'Sum', N'####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2029, 42, N'gaphs_wet_un', N'Wet Units', 105, N'Right', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2030, 42, N'gaphs_net_un', N'Net Units', 105, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2031, 42, N'gaphs_fees', N'Fees', 107, N'Right', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2032, 42, N'gaphs_dlvry_rev_dt', N'Delivery Date', 105, N'Right', N'', N'', N'', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)
 
INSERT INTO #TempCannedPanelColumn VALUES (2033, 43, N'gaitr_pur_sls_ind', N'P or S', 50, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)
 
INSERT INTO #TempCannedPanelColumn VALUES (2034, 43, N'gaitr_loc_no', N'Loc', 6, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)
 
INSERT INTO #TempCannedPanelColumn VALUES (2035, 43, N'gaitr_cus_no', N'Cust#', 148, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)
 
INSERT INTO #TempCannedPanelColumn VALUES (2036, 43, N'agcus_last_name', N'Customer Last Name', 246, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)
 
INSERT INTO #TempCannedPanelColumn VALUES (2037, 43, N'agcus_first_name', N'First Name', 246, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)
 
INSERT INTO #TempCannedPanelColumn VALUES (2038, 43, N'gacom_desc', N'Com', 147, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)
 
INSERT INTO #TempCannedPanelColumn VALUES (2039, 43, N'gaitr_tic_no', N'Ticket', 246, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)
 
INSERT INTO #TempCannedPanelColumn VALUES (2040, 43, N'gaitr_un_out', N'Units', 245, N'Right', N'', N'Sum', N'####.000', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)
 
INSERT INTO #TempCannedPanelColumn VALUES (2041, 44, N'gacnt_pur_sls_ind', N'P or S', 116, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2042, 44, N'gacnt_com_cd', N'Com', 116, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2043, 44, N'Option Month', N'Option Month', 116, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2044, 44, N'Option Year', N'Option Year', 116, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2045, 44, N'Balance', N'Balance', 115, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2046, 44, N'Price', N'Price', 116, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2047, 44, N'Extended Amount', N'Ext Amount', 115, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2048, 44, N'WAP', N'WAP', 115, N'Right', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2049, 44, N'WAB', N'WAB', 115, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2050, 44, N'WAF', N'WAF', 116, N'Right', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2051, 44, N'gacnt_due_rev_dt', N'Due Date', 115, N'Right', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2052, 44, N'gacnt_cnt_no', N'Contract #', 116, N'Right', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)
 
INSERT INTO #TempCannedPanelColumn VALUES (2053, 3, N'gacom_desc', N'Com', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19)
 
INSERT INTO #TempCannedPanelColumn VALUES (2054, 3, N'gapos_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19)
 
INSERT INTO #TempCannedPanelColumn VALUES (2055, 3, N'gapos_in_house', N'In House', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19)
 
INSERT INTO #TempCannedPanelColumn VALUES (2056, 3, N'gapos_offsite', N'Offsite', 25, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19)
 
INSERT INTO #TempCannedPanelColumn VALUES (2057, 3, N'gapos_sls_in_transit', N'In Transit', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19)
 
INSERT INTO #TempCannedPanelColumn VALUES (2058, 54, N'gacom_desc', N'Com', 25, N'Left', N'', N'', N'', 2, N'', N'', N'gacommst.gacom_desc', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 20)
 
INSERT INTO #TempCannedPanelColumn VALUES (2059, 54, N'totals', N'Totals', 25, N'Right', N'', N'Sum', N'####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 20)
 
INSERT INTO #TempCannedPanelColumn VALUES (2060, 45, N'pttic_cus_no', N'Customer#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)
 
INSERT INTO #TempCannedPanelColumn VALUES (2061, 45, N'ptcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)
 
INSERT INTO #TempCannedPanelColumn VALUES (2062, 45, N'ptcus_first_name', N'Customer Name', 25, N'Left', N'', N'', N' ', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)
 
INSERT INTO #TempCannedPanelColumn VALUES (2063, 45, N'pttic_itm_no', N'Item#', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)
 
INSERT INTO #TempCannedPanelColumn VALUES (2064, 45, N'pttic_qty_orig', N'Quantity', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)
 
INSERT INTO #TempCannedPanelColumn VALUES (2065, 45, N'pttic_tic_no', N'Ticket #', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)
 
INSERT INTO #TempCannedPanelColumn VALUES (2066, 45, N'pttic_rev_dt', N'Date', 25, N'Right', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)
 
INSERT INTO #TempCannedPanelColumn VALUES (2067, 46, N'Current', N'Current', 25, N'Center', N'', N'', N'$####.00', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67)
 
INSERT INTO #TempCannedPanelColumn VALUES (2068, 46, N'31-60 Days', N'31-60 Days', 25, N'Center', N'', N'', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67)
 
INSERT INTO #TempCannedPanelColumn VALUES (2069, 46, N'61-90 Days', N'61-90 Days', 25, N'Center', N'', N'', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67)
 
INSERT INTO #TempCannedPanelColumn VALUES (2070, 46, N'91-120 Days', N'91-120 Days', 25, N'Center', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67)
 
INSERT INTO #TempCannedPanelColumn VALUES (2071, 46, N'Over 120 Days', N'Over 120 Days', 25, N'Center', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67)
 
INSERT INTO #TempCannedPanelColumn VALUES (2072, 47, N'ptcus_cus_no', N'Customer Code', 347, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68)
 
INSERT INTO #TempCannedPanelColumn VALUES (2073, 47, N'ptcus_last_name', N'Last Name', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68)
 
INSERT INTO #TempCannedPanelColumn VALUES (2074, 47, N'ptcus_first_name', N'First Name', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68)
 
INSERT INTO #TempCannedPanelColumn VALUES (2075, 47, N'ptcus_ar_ov120', N'Amount', 346, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68)
 
INSERT INTO #TempCannedPanelColumn VALUES (2076, 48, N'ptitm_itm_no', N'Item #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)
 
INSERT INTO #TempCannedPanelColumn VALUES (2077, 48, N'ptitm_desc', N'Item/Product', 417, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)
 
INSERT INTO #TempCannedPanelColumn VALUES (2078, 48, N'ptitm_loc_no', N'Loc', 138, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)
 
INSERT INTO #TempCannedPanelColumn VALUES (2079, 48, N'ptitm_unit', N'Unit Desc', 138, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)
 
INSERT INTO #TempCannedPanelColumn VALUES (2080, 48, N'ptitm_on_hand', N'On Hand Qty', 231, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)
 
INSERT INTO #TempCannedPanelColumn VALUES (2081, 48, N'ptitm_last_sale_rev_dt', N'Last Sale Date', 231, N'Right', N'', N'', N'Date', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)
 
INSERT INTO #TempCannedPanelColumn VALUES (2082, 49, N'ptstm_itm_no', N'Item #', 287, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58)
 
INSERT INTO #TempCannedPanelColumn VALUES (2083, 49, N'ptitm_desc', N'Description', 287, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58)
 
INSERT INTO #TempCannedPanelColumn VALUES (2084, 49, N'Sales', N'Sales', 287, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58)
 
INSERT INTO #TempCannedPanelColumn VALUES (2085, 49, N'Units', N'Units', 286, N'Left', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58)
 
INSERT INTO #TempCannedPanelColumn VALUES (2086, 50, N'Location', N'Location', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 59)
 
INSERT INTO #TempCannedPanelColumn VALUES (2087, 50, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 59)
 
INSERT INTO #TempCannedPanelColumn VALUES (2088, 64, N'ptitm_itm_no', N'Item Code', 243, N'Left', N'', N'', N'', 2, N'', N'', N'ptitm_itm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66)
 
INSERT INTO #TempCannedPanelColumn VALUES (2089, 64, N'ptitm_desc', N'Item/Product', 437, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66)
 
INSERT INTO #TempCannedPanelColumn VALUES (2090, 64, N'ptitm_loc_no', N'Loc', 242, N'Left', N'', N'', N'', 4, N'', N'', N'ptitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66)
 
INSERT INTO #TempCannedPanelColumn VALUES (2091, 64, N'ptitm_on_hand', N'On Hand Quantity', 242, N'Right', N'', N'', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66)
 
INSERT INTO #TempCannedPanelColumn VALUES (2092, 52, N'ptcus_last_name', N'Customer Last Name', 282, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62)
 
INSERT INTO #TempCannedPanelColumn VALUES (2093, 52, N'ptcus_first_name', N'First Name', 282, N'Left', N'', N'', N' ', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62)
 
INSERT INTO #TempCannedPanelColumn VALUES (2094, 52, N'ptcus_cus_no', N'Customer Code', 280, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62)
 
INSERT INTO #TempCannedPanelColumn VALUES (2095, 52, N'Sales', N'Sales', 280, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62)
 
INSERT INTO #TempCannedPanelColumn VALUES (2096, 52, N'Units', N'Units', 280, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62)
 
INSERT INTO #TempCannedPanelColumn VALUES (2097, 51, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60)
 
INSERT INTO #TempCannedPanelColumn VALUES (2098, 51, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60)
 
INSERT INTO #TempCannedPanelColumn VALUES (2099, 51, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60)
 
INSERT INTO #TempCannedPanelColumn VALUES (2100, 51, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60)
 
INSERT INTO #TempCannedPanelColumn VALUES (2101, 53, N'ptcus_cus_no', N'Customer#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)
 
INSERT INTO #TempCannedPanelColumn VALUES (2102, 53, N'ptcus_last_name', N'Customer Last Name', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)
 
INSERT INTO #TempCannedPanelColumn VALUES (2103, 53, N'ptcus_first_name', N'First Name', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)
 
INSERT INTO #TempCannedPanelColumn VALUES (2104, 53, N'ptcus_credit_limit', N'Credit Limit', 231, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)
 
INSERT INTO #TempCannedPanelColumn VALUES (2105, 53, N'Total Balance', N'Total Balance', 231, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)
 
INSERT INTO #TempCannedPanelColumn VALUES (2106, 53, N'overage', N'Overage', 231, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)
 
INSERT INTO #TempCannedPanelColumn VALUES (2107, 4, N'ptstm_bill_to_cus', N'Bill To Cus', 94, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2108, 4, N'ptstm_ivc_no', N'Invoice #', 93, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2109, 4, N'ptstm_ship_rev_dt', N'Ship Date', 93, N'Right', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2110, 4, N'ptstm_itm_no', N'Item#', 93, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2111, 4, N'ptstm_loc_no', N'Loc', 93, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2112, 4, N'ptstm_class', N'Class Code', 93, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2113, 4, N'ptstm_un', N'Units Sold', 93, N'Right', N'', N'', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2114, 4, N'ptstm_un_prc', N'Unit Price', 92, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2115, 4, N'ptstm_net', N'Sales', 92, N'Right', N'', N'', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2116, 4, N'ptstm_cgs', N'Costs', 92, N'Right', N'', N'', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2117, 4, N'ptstm_slsmn_id', N'Salesperson', 92, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2118, 4, N'ptstm_pak_desc', N'Package Desc', 92, N'Left', N'', N'', N'', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2119, 4, N'ptstm_un_desc', N'Unit Desc', 92, N'Left', N'', N'', N'', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2120, 4, N'Profit Amount', N'Profit Amount', 92, N'Right', N'', N'', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2121, 4, N'Profit Percent', N'Profit Percentage', 91, N'Right', N'', N'', N'##.###%', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)
 
INSERT INTO #TempCannedPanelColumn VALUES (2122, 63, N'ptstm_bill_to_cus', N'Bill To Cus', 347, N'Left', N'', N'', N'', 2, N'', N'', N'ptstm_bill_to_cus', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61)
 
INSERT INTO #TempCannedPanelColumn VALUES (2123, 63, N'ptstm_ivc_no', N'Invoice #', 347, N'Left', N'', N'', N'', 3, N'', N'', N'ptstm_ivc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61)
 
INSERT INTO #TempCannedPanelColumn VALUES (2124, 63, N'ptstm_ship_rev_dt', N'Ship Date', 347, N'Left', N'', N'', N'Date', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61)
 
INSERT INTO #TempCannedPanelColumn VALUES (2125, 63, N'Profit Percent', N'Profit Percentage', 346, N'Right', N'', N'', N'##.###%', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61)
 
INSERT INTO #TempCannedPanelColumn VALUES (2126, 5, N'ptitm_itm_no', N'Item#', 155, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)
 
INSERT INTO #TempCannedPanelColumn VALUES (2127, 5, N'ptitm_desc', N'Item/Product', 278, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)
 
INSERT INTO #TempCannedPanelColumn VALUES (2128, 5, N'ptitm_loc_no', N'Loc', 92, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)
 
INSERT INTO #TempCannedPanelColumn VALUES (2129, 5, N'ptitm_class', N'Class', 154, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)
 
INSERT INTO #TempCannedPanelColumn VALUES (2130, 5, N'ptitm_unit', N'Unit Desc', 92, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)
 
INSERT INTO #TempCannedPanelColumn VALUES (2131, 5, N'ptitm_cost1', N'Last Costs', 154, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)
 
INSERT INTO #TempCannedPanelColumn VALUES (2132, 5, N'ptitm_avg_cost', N'Average Costs', 154, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)
 
INSERT INTO #TempCannedPanelColumn VALUES (2133, 5, N'ptitm_std_cost', N'Standard Costs', 154, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)
 
INSERT INTO #TempCannedPanelColumn VALUES (2134, 5, N'ptitm_on_hand', N'Units On Hand', 154, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)
 
INSERT INTO #TempCannedPanelColumn VALUES (2135, 62, N'ptitm_itm_no', N'Item Code', 347, N'Left', N'', N'', N'', 2, N'', N'', N'ptitm_itm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55)
 
INSERT INTO #TempCannedPanelColumn VALUES (2136, 62, N'ptitm_desc', N'Item/Product', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55)
 
INSERT INTO #TempCannedPanelColumn VALUES (2137, 62, N'ptitm_loc_no', N'Loc', 347, N'Left', N'', N'', N' ', 4, N'', N'', N'ptitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55)
 
INSERT INTO #TempCannedPanelColumn VALUES (2138, 62, N'ptitm_on_hand', N'On-Hand Quantity', 346, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55)
 
INSERT INTO #TempCannedPanelColumn VALUES (2139, 9, N'agcus_last_name', N'Customer Last Name', 347, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44)
 
INSERT INTO #TempCannedPanelColumn VALUES (2140, 9, N'Amount', N'Amount', 346, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44)
 
INSERT INTO #TempCannedPanelColumn VALUES (2141, 9, N'agcus_first_name', N'Customer First Name', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44)
 
INSERT INTO #TempCannedPanelColumn VALUES (2142, 9, N'agcus_key', N'Customer #', 347, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44)
 
INSERT INTO #TempCannedPanelColumn VALUES (2143, 10, N'Future', N'Future', 25, N'Left', N'', N'', N'$####.00', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)
 
INSERT INTO #TempCannedPanelColumn VALUES (2144, 10, N'Current', N'Current', 25, N'Left', N'', N'', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)
 
INSERT INTO #TempCannedPanelColumn VALUES (2145, 10, N'30days', N'31-60 Days', 25, N'Left', N'', N'', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)
 
INSERT INTO #TempCannedPanelColumn VALUES (2146, 10, N'60days', N'61-90 Days', 25, N'Left', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)
 
INSERT INTO #TempCannedPanelColumn VALUES (2147, 10, N'90days', N'91-120 Days', 25, N'Left', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)
 
INSERT INTO #TempCannedPanelColumn VALUES (2148, 10, N'120days', N'Over 120 Days', 25, N'Left', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)
 
INSERT INTO #TempCannedPanelColumn VALUES (2149, 12, N'agcus_key', N'Customer #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 1)
 
INSERT INTO #TempCannedPanelColumn VALUES (2150, 12, N'agcus_last_name', N'Customer Last Name', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 1)
 
INSERT INTO #TempCannedPanelColumn VALUES (2151, 12, N'agcus_first_name', N'First Name', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 1)
 
INSERT INTO #TempCannedPanelColumn VALUES (2152, 12, N'agcus_cred_limit', N'Credit Limit', 231, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 1)
 
INSERT INTO #TempCannedPanelColumn VALUES (2153, 12, N'Total Balance', N'Total Balance', 231, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 1)
 
INSERT INTO #TempCannedPanelColumn VALUES (2154, 12, N'Overage', N'Overage', 231, N'Right', N'', N'Sum', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 1)
 
INSERT INTO #TempCannedPanelColumn VALUES (2155, 2, N'agitm_no', N'Item#', 174, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)
 
INSERT INTO #TempCannedPanelColumn VALUES (2156, 2, N'agitm_desc', N'Item/Product', 174, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)
 
INSERT INTO #TempCannedPanelColumn VALUES (2157, 2, N'agitm_pak_desc', N'Package', 174, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)
 
INSERT INTO #TempCannedPanelColumn VALUES (2158, 2, N'agitm_class', N'Class', 173, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)
 
INSERT INTO #TempCannedPanelColumn VALUES (2159, 2, N'agitm_loc_no', N'Loc', 173, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)
 
INSERT INTO #TempCannedPanelColumn VALUES (2160, 2, N'agitm_last_un_cost', N'Last Unit Cost', 173, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)
 
INSERT INTO #TempCannedPanelColumn VALUES (2161, 2, N'agitm_avg_un_cost', N'Average Unit Cost', 173, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)
 
INSERT INTO #TempCannedPanelColumn VALUES (2162, 2, N'agitm_un_on_hand', N'Units On Hand Qty', 173, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)
 
INSERT INTO #TempCannedPanelColumn VALUES (2163, 58, N'agitm_no', N'Item#', 347, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51)
 
INSERT INTO #TempCannedPanelColumn VALUES (2164, 58, N'agitm_desc', N'Item/Product', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51)
 
INSERT INTO #TempCannedPanelColumn VALUES (2165, 58, N'agitm_loc_no', N'Loc', 347, N'Left', N'', N'', N'', 6, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51)
 
INSERT INTO #TempCannedPanelColumn VALUES (2166, 58, N'agitm_un_on_hand', N'Units On Hand Qty', 346, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51)
 
INSERT INTO #TempCannedPanelColumn VALUES (2167, 17, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65)
 
INSERT INTO #TempCannedPanelColumn VALUES (2168, 17, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65)
 
INSERT INTO #TempCannedPanelColumn VALUES (2169, 17, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65)
 
INSERT INTO #TempCannedPanelColumn VALUES (2170, 17, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65)
 
INSERT INTO #TempCannedPanelColumn VALUES (2171, 20, N'agcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46)
 
INSERT INTO #TempCannedPanelColumn VALUES (2172, 20, N'agstm_key_loc_no', N'Location', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46)
 
INSERT INTO #TempCannedPanelColumn VALUES (2173, 20, N'agstm_key_loc_no', N'Location', 0, N'Series2AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46)
 
INSERT INTO #TempCannedPanelColumn VALUES (2174, 20, N'Sales', N'Sales Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46)
 
INSERT INTO #TempCannedPanelColumn VALUES (2175, 20, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46)
 
INSERT INTO #TempCannedPanelColumn VALUES (2176, 19, N'agstm_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70)
 
INSERT INTO #TempCannedPanelColumn VALUES (2177, 19, N'agitm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70)
 
INSERT INTO #TempCannedPanelColumn VALUES (2178, 19, N'Sales', N'Sales', 25, N'Right', N'', N'Sum', N'$###0.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70)
 
INSERT INTO #TempCannedPanelColumn VALUES (2179, 19, N'Units', N'Units', 25, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70)
 
INSERT INTO #TempCannedPanelColumn VALUES (2180, 18, N'Customer Last Name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69)
 
INSERT INTO #TempCannedPanelColumn VALUES (2181, 18, N'First Name', N'First Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69)
 
INSERT INTO #TempCannedPanelColumn VALUES (2182, 18, N'Customer Code', N'Customer Code', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69)
 
INSERT INTO #TempCannedPanelColumn VALUES (2183, 18, N'Sales', N'Sales', 25, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69)
 
INSERT INTO #TempCannedPanelColumn VALUES (2184, 18, N'Units', N'Units', 25, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69)
 
INSERT INTO #TempCannedPanelColumn VALUES (2185, 21, N'agitm_no', N'Item #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)
 
INSERT INTO #TempCannedPanelColumn VALUES (2186, 21, N'agitm_desc', N'Item/Product', 417, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)
 
INSERT INTO #TempCannedPanelColumn VALUES (2187, 21, N'agitm_loc_no', N'Loc', 138, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)
 
INSERT INTO #TempCannedPanelColumn VALUES (2188, 21, N'agitm_un_desc', N'Unit Desc', 138, N'Left', N'', N'', N' ', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)
 
INSERT INTO #TempCannedPanelColumn VALUES (2189, 21, N'agitm_un_on_hand', N'On Hand Qty', 231, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)
 
INSERT INTO #TempCannedPanelColumn VALUES (2190, 21, N'agitm_last_sale_rev_dt', N'Last Sale Date', 231, N'Right', N'', N'', N'Date', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)
 
INSERT INTO #TempCannedPanelColumn VALUES (2191, 22, N'agord_cus_no', N'Customer#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)
 
INSERT INTO #TempCannedPanelColumn VALUES (2192, 22, N'agord_ord_no', N'Order#', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)
 
INSERT INTO #TempCannedPanelColumn VALUES (2193, 22, N'agord_loc_no', N'Loc', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)
 
INSERT INTO #TempCannedPanelColumn VALUES (2194, 22, N'agord_ord_rev_dt', N'Order Date', 231, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)
 
INSERT INTO #TempCannedPanelColumn VALUES (2195, 22, N'agord_itm_no', N'Item #', 231, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)
 
INSERT INTO #TempCannedPanelColumn VALUES (2196, 22, N'agord_pkg_sold', N'Packages Sold', 231, N'Left', N'', N'', N'####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)
 
INSERT INTO #TempCannedPanelColumn VALUES (2197, 6, N'agcnt_cus_no', N'Customer#', 108, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2198, 6, N'agcus_last_name', N'Customer Last Name', 108, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2199, 6, N'agcus_first_name', N'First Name', 108, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2200, 6, N'agcnt_slsmn_id', N'Salesperson ID', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2201, 6, N'agcnt_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2202, 6, N'agcnt_cnt_no', N'Contract #', 108, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2203, 6, N'agcnt_cnt_rev_dt', N'Contract Date', 105, N'Right', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2204, 6, N'agcnt_due_rev_dt', N'Due Date', 107, N'Right', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2205, 6, N'agcnt_itm_or_cls', N'Item or Class', 107, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2206, 6, N'agcnt_prc_lvl', N'Price Level', 105, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2207, 6, N'agcnt_ppd_yndm', N'Prepaid', 105, N'Left', N'', N'', N'Yes/No', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2208, 6, N'agcnt_un_orig', N'Original Units', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2209, 6, N'agcnt_un_bal', N'Unit Balance', 105, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)
 
INSERT INTO #TempCannedPanelColumn VALUES (2210, 61, N'agcnt_cus_no', N'Customer#', 199, N'Left', N'', N'', N'', 3, N'', N'', N'agcnt_cus_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)
 
INSERT INTO #TempCannedPanelColumn VALUES (2211, 61, N'agcus_last_name', N'Customer Last Name', 198, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)
 
INSERT INTO #TempCannedPanelColumn VALUES (2212, 61, N'agcus_first_name', N'First Name', 198, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)
 
INSERT INTO #TempCannedPanelColumn VALUES (2213, 61, N'agcnt_loc_no', N'Loc', 198, N'Left', N'', N'', N'', 7, N'', N'', N'agcnt_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)
 
INSERT INTO #TempCannedPanelColumn VALUES (2214, 61, N'agcnt_cnt_no', N'Contract #', 200, N'Left', N'', N'Count', N'', 2, N'', N'', N'agcnt_cnt_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)
 
INSERT INTO #TempCannedPanelColumn VALUES (2215, 61, N'agcnt_un_bal', N'Unit Balance', 196, N'Right', N'', N'Sum', N'####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)
 
INSERT INTO #TempCannedPanelColumn VALUES (2216, 61, N'agcnt_itm_or_cls', N'Item or Class', 198, N'Left', N'', N'', N'', 14, N'', N'', N'agcnt_itm_or_cls', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)
 
INSERT INTO #TempCannedPanelColumn VALUES (2217, 60, N'agitm_desc', N'Item/Product', 427, N'Left', N'', N'Count', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42)
 
INSERT INTO #TempCannedPanelColumn VALUES (2218, 60, N'agitm_loc_no', N'Loc', 371, N'Left', N'', N'', N'', 4, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42)
 
INSERT INTO #TempCannedPanelColumn VALUES (2219, 60, N'agitm_un_on_hand', N'On Hand Inventory', 369, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42)
 
INSERT INTO #TempCannedPanelColumn VALUES (2220, 60, N'agitm_no', N'Item #', 220, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42)
 
INSERT INTO #TempCannedPanelColumn VALUES (2221, 8, N'agitm_no', N'Item #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2222, 8, N'agitm_desc', N'Item Name', 107, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2223, 8, N'agitm_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2224, 8, N'agitm_un_desc', N'Unit Desc', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2225, 8, N'agitm_un_on_hand', N'On Hand', 107, N'Right', N'', N'Sum', N'####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2226, 8, N'agitm_un_pend_ivcs', N'Pending Invoices', 106, N'Right', N'', N'Sum', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2227, 8, N'agitm_un_on_order', N'On Order', 107, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2228, 8, N'agitm_un_mfg_in_prs', N'Mfg', 107, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2229, 8, N'agitm_un_fert_committed', N'Contracts Committed', 106, N'Right', N'', N'Sum', N'####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2230, 8, N'agitm_un_ord_committed', N'Orders Committed', 106, N'Right', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2231, 8, N'agitm_un_cnt_committed', N'Other Contracts Committed', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2232, 8, N'Available', N'Available', 106, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2233, 8, N'agitm_class', N'Class', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)
 
INSERT INTO #TempCannedPanelColumn VALUES (2234, 57, N'agitm_no', N'Item #', 347, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54)
 
INSERT INTO #TempCannedPanelColumn VALUES (2235, 57, N'agitm_desc', N'Item Name', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54)
 
INSERT INTO #TempCannedPanelColumn VALUES (2236, 57, N'agitm_loc_no', N'Loc', 347, N'Left', N'', N'', N'', 4, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54)
 
INSERT INTO #TempCannedPanelColumn VALUES (2237, 57, N'Available', N'Available', 346, N'Left', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54)
 
INSERT INTO #TempCannedPanelColumn VALUES (2238, 1, N'agstm_bill_to_cus', N'Bill To Customer', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2239, 1, N'agstm_ivc_no', N'Invoice #', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2240, 1, N'agstm_ship_rev_dt', N'Ship Date', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2241, 1, N'agstm_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2242, 1, N'agstm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2243, 1, N'agstm_class', N'Class Code', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2244, 1, N'agstm_un', N'Units Sold', 25, N'Right', N'', N'', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2245, 1, N'agstm_un_prc', N'Unit Price', 25, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2246, 1, N'agstm_sls', N'Sales Amount', 25, N'Right', N'', N'', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2247, 1, N'agstm_un_cost', N'Unit Costs', 25, N'Right', N'', N'', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2248, 1, N'agstm_cgs', N'Costs Amount', 25, N'Right', N'', N'', N'$####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2249, 1, N'agstm_slsmn_id', N'Salesperson', 25, N'Left', N'', N'', N'', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2250, 1, N'agstm_pak_desc', N'Package Desc', 25, N'Left', N'', N'', N'', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2251, 1, N'agstm_un_desc', N'Unit Desc', 25, N'Left', N'', N'', N'', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2252, 1, N'unit margins', N'Unit Margins', 25, N'Right', N'', N'Sum', N'$####.000', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2253, 1, N'Profit Amount', N'Profit Amount', 25, N'Right', N'', N'Sum', N'$###0.000', 17, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2254, 1, N'Profit Percent', N'Profit Percent', 25, N'Right', N'', N'', N'##.###%', 18, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)
 
INSERT INTO #TempCannedPanelColumn VALUES (2255, 40, N'pxrpt_trans_type', N'Trans Type', 26, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2256, 40, N'pxrpt_trans_rev_dt', N'Trans Date', 65, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2257, 40, N'pxrpt_ord_no', N'Order #', 76, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2258, 40, N'pxrpt_car_name', N'Carrier', 76, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2259, 40, N'pxrpt_cus_name', N'Customer', 76, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2260, 40, N'pxrpt_cus_state', N'Customer State', 76, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2261, 40, N'pxrpt_itm_desc', N'Item/Product', 76, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2262, 40, N'pxrpt_itm_loc_no', N'Loc', 76, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2263, 40, N'pxrpt_vnd_name', N'Vendor', 76, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2264, 40, N'pxrpt_vnd_state', N'Vendor State', 28, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2265, 40, N'pxrpt_pur_gross_un', N'Gross Units Purchased', 75, N'Left', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2266, 40, N'pxrpt_pur_net_un', N'Net Units Purchased', 75, N'Left', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2267, 40, N'pxrpt_pur_fet_amt', N'FET', 75, N'Left', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2268, 40, N'pxrpt_pur_set_amt', N'SET', 75, N'Left', N'', N'Sum', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2269, 40, N'pxrpt_pur_sst_amt', N'SST', 75, N'Left', N'', N'Sum', N'$####.00', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2270, 40, N'pxrpt_pur_lc1_amt', N'LC1', 75, N'Left', N'', N'Sum', N'$####.00', 17, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2271, 40, N'pxrpt_pur_lc2_amt', N'LC2', 75, N'Left', N'', N'Sum', N'$####.00', 18, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2272, 40, N'pxrpt_pur_lc3_amt', N'LC3', 25, N'Left', N'', N'Sum', N'$####.00', 19, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2273, 40, N'pxrpt_pur_lc4_amt', N'LC4', 25, N'Left', N'', N'Sum', N'$####.00', 20, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2274, 40, N'pxrpt_pur_un_received', N'Units Received', 76, N'Left', N'', N'Sum', N'####.00', 21, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2275, 40, N'pxrpt_src_sys', N'Source System', 76, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2276, 40, N'pxrpt_itm_dyed_yn', N'Dyed?', 25, N'Left', N'', N'', N'', 22, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)
 
INSERT INTO #TempCannedPanelColumn VALUES (2277, 32, N'pxrpt_trans_type', N'Trans Type', 82, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2278, 32, N'pxrpt_trans_rev_dt', N'Trans Date', 82, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2279, 32, N'pxrpt_src_sys', N'Source System', 79, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2280, 32, N'pxrpt_ord_no', N'Order #', 79, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2281, 32, N'pxrpt_car_name', N'Carrier', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2282, 32, N'pxrpt_cus_name', N'Customer', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2283, 32, N'pxrpt_cus_state', N'Customer State', 27, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2284, 32, N'pxrpt_itm_desc', N'Item/Product', 78, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2285, 32, N'pxrpt_itm_loc_no', N'Loc', 69, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2286, 32, N'pxrpt_vnd_name', N'Vendor ', 76, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2287, 32, N'pxrpt_vnd_state', N'Vendor State', 77, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2288, 32, N'pxrpt_sls_trans_gals', N'Sales Units', 77, N'Left', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2289, 32, N'pxrpt_sls_fet_amt', N'FET', 77, N'Left', N'', N'Sum', N'$####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2290, 32, N'pxrpt_sls_set_amt', N'SET', 77, N'Left', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2291, 32, N'pxrpt_sls_lc1_amt', N'LC1', 76, N'Left', N'', N'Sum', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2292, 32, N'pxrpt_sls_lc2_amt', N'LC2', 76, N'Left', N'', N'Sum', N'$####.00', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2293, 32, N'pxrpt_sls_lc3_amt', N'LC3', 76, N'Left', N'', N'Sum', N'$####.00', 17, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2294, 32, N'pxrpt_sls_lc4_amt', N'LC4', 76, N'Left', N'', N'Sum', N'$####.00', 18, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2295, 32, N'pxrpt_itm_dyed_yn', N'Dyed?', 77, N'Left', N'', N'', N'', 19, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2296, 32, N'pxrpt_cus_acct_stat', N'Cus  Acct Status ', 76, N'Left', N'', N'', N'', 20, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)
 
INSERT INTO #TempCannedPanelColumn VALUES (2297, 11, N'apcbk_desc', N'Checkbook Name', 25, N'Left', N'', N'', N' ', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37)
 
INSERT INTO #TempCannedPanelColumn VALUES (2298, 11, N'apcbk_no', N'Checkbook #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37)
 
INSERT INTO #TempCannedPanelColumn VALUES (2299, 11, N'apcbk_bal', N'Checkbook Balance', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37)
 
INSERT INTO #TempCannedPanelColumn VALUES (2300, 15, N'apchk_rev_dt', N'Date', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35)
 
INSERT INTO #TempCannedPanelColumn VALUES (2301, 15, N'apchk_name', N'Check Name', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35)
 
INSERT INTO #TempCannedPanelColumn VALUES (2302, 15, N'apchk_chk_amt', N'Check Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35)
 
INSERT INTO #TempCannedPanelColumn VALUES (2303, 14, N'apivc_ivc_no', N'Invoice#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)
 
INSERT INTO #TempCannedPanelColumn VALUES (2304, 14, N'apivc_ivc_rev_dt', N'Invoice Date', 231, N'Right', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)
 
INSERT INTO #TempCannedPanelColumn VALUES (2305, 14, N'apivc_vnd_no', N'Vendor #', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)
 
INSERT INTO #TempCannedPanelColumn VALUES (2306, 14, N'ssvnd_name', N'Vendor', 231, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)
 
INSERT INTO #TempCannedPanelColumn VALUES (2307, 14, N'amounts', N'Amount Due', 231, N'Right', N'', N'Sum', N'$###0.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)
 
INSERT INTO #TempCannedPanelColumn VALUES (2308, 14, N'apivc_due_rev_dt', N'Due Date', 231, N'Right', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)
 
INSERT INTO #TempCannedPanelColumn VALUES (2309, 13, N'apchk_cbk_no', N'Checkbook #', 139, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)
 
INSERT INTO #TempCannedPanelColumn VALUES (2310, 13, N'apchk_rev_dt', N'Date', 139, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)
 
INSERT INTO #TempCannedPanelColumn VALUES (2311, 13, N'apchk_vnd_no', N'Vendor #', 139, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)
 
INSERT INTO #TempCannedPanelColumn VALUES (2312, 13, N'apchk_name', N'Vendor Name', 139, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)
 
INSERT INTO #TempCannedPanelColumn VALUES (2313, 13, N'apchk_chk_amt', N'Check Amount', 139, N'Left', N'', N'Sum', N'$###0.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)
 
INSERT INTO #TempCannedPanelColumn VALUES (2314, 13, N'apchk_disc_amt', N'Discount Amount', 139, N'Left', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)
 
INSERT INTO #TempCannedPanelColumn VALUES (2315, 13, N'apchk_gl_rev_dt', N'GL Date', 139, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)
 
INSERT INTO #TempCannedPanelColumn VALUES (2316, 13, N'apchk_cleared_ind', N'Cleared?', 138, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)
 
INSERT INTO #TempCannedPanelColumn VALUES (2317, 13, N'apchk_clear_rev_dt', N'Cleared Date', 138, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)
 
INSERT INTO #TempCannedPanelColumn VALUES (2318, 13, N'apchk_src_sys', N'Source System', 138, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)
 
INSERT INTO #TempCannedPanelColumn VALUES (2319, 16, N'apivc_ivc_no', N'Invoice #', 127, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38)
 
INSERT INTO #TempCannedPanelColumn VALUES (2320, 16, N'apivc_ivc_rev_dt', N'Invoice Date', 315, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38)
 
INSERT INTO #TempCannedPanelColumn VALUES (2321, 16, N'apivc_vnd_no', N'Vendor #', 315, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38)
 
INSERT INTO #TempCannedPanelColumn VALUES (2322, 16, N'ssvnd_name', N'Vendor Name', 315, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38)
 
INSERT INTO #TempCannedPanelColumn VALUES (2323, 16, N'amounts', N'Amount', 315, N'Left', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38)
 
INSERT INTO #TempCannedPanelColumn VALUES (2324, 55, N'CheckDate', N'Check Date', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 39)
 
INSERT INTO #TempCannedPanelColumn VALUES (2325, 55, N'Amount', N'Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 39)
 
INSERT INTO #TempCannedPanelColumn VALUES (2326, 24, N'strDescription', N'Description', 154, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)
 
INSERT INTO #TempCannedPanelColumn VALUES (2327, 24, N'dblDebit', N'Debit ', 153, N'Left', N'', N'Sum', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)
 
INSERT INTO #TempCannedPanelColumn VALUES (2328, 24, N'dblCredit', N'Credit', 153, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)
 
INSERT INTO #TempCannedPanelColumn VALUES (2329, 24, N'Balance', N'Balance', 153, N'Left', N'', N'Sum', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)
 
INSERT INTO #TempCannedPanelColumn VALUES (2330, 24, N'strAccountId', N'AccountID', 159, N'Left', N'', N'Count', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)
 
INSERT INTO #TempCannedPanelColumn VALUES (2331, 24, N'dtmDate', N'Date', 154, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)
 
INSERT INTO #TempCannedPanelColumn VALUES (2332, 24, N'strTransactionId', N'Document', 154, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)
 
INSERT INTO #TempCannedPanelColumn VALUES (2333, 24, N'strReference', N'Reference', 154, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)
 
INSERT INTO #TempCannedPanelColumn VALUES (2334, 24, N'strAccountGroup', N'Account Group', 153, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)
 
INSERT INTO #TempCannedPanelColumn VALUES (2335, 25, N'strAccountId', N'Account ID', 463, N'Left', N'', N'Count', N'', 2, N'', N'', N'strAccountId', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 76)
 
INSERT INTO #TempCannedPanelColumn VALUES (2336, 25, N'strDescription', N'Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 76)
 
INSERT INTO #TempCannedPanelColumn VALUES (2337, 25, N'Balance', N'Balance', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 76)
 
INSERT INTO #TempCannedPanelColumn VALUES (2338, 26, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77)
 
INSERT INTO #TempCannedPanelColumn VALUES (2339, 26, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77)
 
INSERT INTO #TempCannedPanelColumn VALUES (2340, 26, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77)
 
INSERT INTO #TempCannedPanelColumn VALUES (2341, 27, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78)
 
INSERT INTO #TempCannedPanelColumn VALUES (2342, 27, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78)
 
INSERT INTO #TempCannedPanelColumn VALUES (2343, 27, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78)
 
INSERT INTO #TempCannedPanelColumn VALUES (2344, 34, N'Period', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81)
 
INSERT INTO #TempCannedPanelColumn VALUES (2345, 34, N'TotalBalance', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81)
 
INSERT INTO #TempCannedPanelColumn VALUES (2346, 34, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81)
 
INSERT INTO #TempCannedPanelColumn VALUES (2347, 34, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81)
 
INSERT INTO #TempCannedPanelColumn VALUES (2348, 35, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 82)
 
INSERT INTO #TempCannedPanelColumn VALUES (2349, 35, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 82)
 
INSERT INTO #TempCannedPanelColumn VALUES (2350, 28, N'strAccountId', N'Account ID', 459, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79)
 
INSERT INTO #TempCannedPanelColumn VALUES (2351, 28, N'strDescription', N'GL Description', 465, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79)
 
INSERT INTO #TempCannedPanelColumn VALUES (2352, 28, N'Amount', N'Amount', 463, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79)
 
INSERT INTO #TempCannedPanelColumn VALUES (2353, 36, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 83)
 
INSERT INTO #TempCannedPanelColumn VALUES (2354, 36, N'Revenue', N'Revenue', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 83)
 
INSERT INTO #TempCannedPanelColumn VALUES (2355, 29, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80)
 
INSERT INTO #TempCannedPanelColumn VALUES (2356, 29, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80)
 
INSERT INTO #TempCannedPanelColumn VALUES (2357, 29, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80)
 
INSERT INTO #TempCannedPanelColumn VALUES (2358, 39, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 84)
 
INSERT INTO #TempCannedPanelColumn VALUES (2359, 39, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 84)
 
INSERT INTO #TempCannedPanelColumn VALUES (2360, 23, N'intGLDetailId', N'GL Detail ID', 100, N'Left', N'Filter', N'', N'', 1, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2361, 23, N'dtmDate', N'Date', 100, N'Left', N'Filter', N'', N'Date', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2362, 23, N'strBatchId', N'Batch ', 100, N'Left', N'Filter', N'', N'', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2363, 23, N'intAccountId', N'Account ID', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2364, 23, N'strAccountGroup', N'Account Group', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2365, 23, N'dblDebit', N'Debit Amount', 100, N'Left', N'Filter', N'', N'$####.00', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2366, 23, N'dblCredit', N'Credit Amount', 100, N'Left', N'Filter', N'', N'$####.00', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2367, 23, N'dblDebitUnit', N'Debit Unit', 100, N'Left', N'Filter', N'', N'', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2368, 23, N'dblCreditUnit', N'Credit Unit', 100, N'Left', N'Filter', N'', N'', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2369, 23, N'strDescription', N'GL Description', 100, N'Left', N'Filter', N'', N'', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2370, 23, N'strCode', N'Code', 100, N'Left', N'Filter', N'', N'', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2371, 23, N'strTransactionId', N'Trans ID', 100, N'Left', N'Filter', N'', N'', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2372, 23, N'strReference', N'Reference', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2373, 23, N'strJobId', N'Job ID', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2374, 23, N'intCurrencyId', N'Currency ID', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2375, 23, N'dblExchangeRate', N'Exchange Rate', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2376, 23, N'dtmDateEntered', N'Date Entered', 100, N'Left', N'Filter', N'', N'', 17, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2377, 23, N'dtmTransactionDate', N'Trans Date', 100, N'Left', N'Filter', N'', N'', 18, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2378, 23, N'strProductId', N'Product ID', 100, N'Left', N'Filter', N'', N'', 19, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2379, 23, N'strWarehouseId', N'Warehouse ID', 100, N'Left', N'Filter', N'', N'', 20, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2380, 23, N'strNum', N'Num', 100, N'Left', N'Filter', N'', N'', 21, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2381, 23, N'strCompanyName', N'Company Name', 100, N'Left', N'Filter', N'', N'', 22, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2382, 23, N'strBillInvoiceNumber', N'Bill Invoice #', 100, N'Left', N'Filter', N'', N'', 23, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2383, 23, N'strJournalLineDescription', N'Journal Line Desc', 100, N'Left', N'Filter', N'', N'', 24, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2384, 23, N'ysnIsUnposted', N'Unposted?', 100, N'Left', N'Filter', N'', N'', 25, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2385, 23, N'intConcurrencyId', N'Concurrency ID', 100, N'Left', N'Filter', N'', N'', 26, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2386, 23, N'intUserID', N'User ID', 100, N'Left', N'Filter', N'', N'', 27, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2387, 23, N'strTransactionForm', N'Trans Form', 100, N'Left', N'Filter', N'', N'', 28, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2388, 23, N'strModuleName', N'Module Name', 100, N'Left', N'Filter', N'', N'', 29, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2389, 23, N'strUOMCode', N'UOM Code', 100, N'Left', N'Filter', N'', N'', 30, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2390, 23, N'intAccountId1', N'Account ID 1', 100, N'Left', N'Filter', N'', N'', 31, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2391, 23, N'strAccountId', N'Account ID', 100, N'Left', N'Filter', N'', N'', 32, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2392, 23, N'strDescription1', N'Description 1', 100, N'Left', N'Filter', N'', N'', 33, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2393, 23, N'strNote', N'Note', 100, N'Left', N'Filter', N'', N'', 34, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2394, 23, N'intAccountGroupId', N'Account Group ID', 100, N'Left', N'Filter', N'', N'', 35, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2395, 23, N'dblOpeningBalance', N'Opening Balance', 100, N'Left', N'Filter', N'', N'', 36, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2396, 23, N'ysnIsUsed', N'Is Used?', 100, N'Left', N'Filter', N'', N'', 37, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2397, 23, N'strComments', N'Comments', 100, N'Left', N'Filter', N'', N'', 40, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2398, 23, N'ysnActive', N'Active', 100, N'Left', N'Filter', N'', N'', 41, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2399, 23, N'ysnSystem', N'System', 100, N'Left', N'Filter', N'', N'', 42, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2400, 23, N'strCashFlow', N'Cash Flow', 100, N'Left', N'Filter', N'', N'', 43, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2401, 23, N'intAccountGroupId1', N'Account Group ID 1', 100, N'Left', N'Filter', N'', N'', 44, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2402, 23, N'strAccountGroup1', N'Account Group 1', 100, N'Left', N'Filter', N'', N'', 45, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2403, 23, N'strAccountType', N'Account Type', 100, N'Left', N'Filter', N'', N'', 46, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2404, 23, N'intParentGroupId', N'Parent Group ID', 100, N'Left', N'Filter', N'', N'', 47, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2405, 23, N'intGroup', N'Group', 100, N'Left', N'Filter', N'', N'', 48, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2406, 23, N'intSort', N'Sort', 100, N'Left', N'Filter', N'', N'', 49, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2407, 23, N'intConcurrencyId2', N'Concurrency ID 2', 100, N'Left', N'Filter', N'', N'', 50, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2408, 23, N'intAccountBegin', N'Account Begin', 100, N'Left', N'Filter', N'', N'', 51, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2409, 23, N'intAccountEnd', N'Account End', 100, N'Left', N'Filter', N'', N'', 52, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2410, 23, N'strAccountGroupNamespace', N'Account Group Name', 100, N'Left', N'Filter', N'', N'', 53, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)
 
INSERT INTO #TempCannedPanelColumn VALUES (2411, 56, N'cftrx_ar_cus_no', N'A/R Customer #', 100, N'Left', N'Filter', N'', N'', 1, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2412, 56, N'cftrx_card_no', N'Card #', 100, N'Left', N'Filter', N'', N'', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2413, 56, N'cfcus_card_desc', N'Card Desc', 100, N'Left', N'Filter', N'', N'', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2414, 56, N'cftrx_rev_dt', N'Date', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2415, 56, N'cftrx_qty', N'Quantity', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2416, 56, N'cftrx_prc', N'Price', 100, N'Left', N'Filter', N'', N'', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2417, 56, N'cftrx_calc_total', N'Calc Total', 100, N'Left', N'Filter', N'', N'', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2418, 56, N'cftrx_ar_itm_no', N'A/R Item #', 100, N'Left', N'Filter', N'', N'', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2419, 56, N'cftrx_ar_itm_loc_no', N'Loc ', 100, N'Left', N'Filter', N'', N'', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2420, 56, N'cftrx_sls_id', N'Salesperson ID', 100, N'Left', N'Filter', N'', N'', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2421, 56, N'cftrx_sell_prc', N'Sell Price', 100, N'Left', N'Filter', N'', N'', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2422, 56, N'cftrx_prc_per_un', N'Price per Unit', 100, N'Left', N'Filter', N'', N'', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2423, 56, N'cftrx_site', N'Site', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2424, 56, N'cftrx_time', N'Time', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2425, 56, N'cftrx_odometer', N'Odometer', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2426, 56, N'cftrx_site_state', N'Site State', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2427, 56, N'cftrx_site_county', N'Site County', 100, N'Left', N'Filter', N'', N'', 17, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2428, 56, N'cftrx_site_city', N'Site City', 100, N'Left', N'Filter', N'', N'', 18, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2429, 56, N'cftrx_selling_host_id', N'Selling Host ID', 100, N'Left', N'Filter', N'', N'', 19, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2430, 56, N'cftrx_buying_host_id', N'Buying Host ID', 100, N'Left', N'Filter', N'', N'', 20, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2431, 56, N'cftrx_po_no', N'PO #', 100, N'Left', N'Filter', N'', N'', 21, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2432, 56, N'cftrx_ar_ivc_no', N'A/R Invoice #', 100, N'Left', N'Filter', N'', N'', 22, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2433, 56, N'cftrx_calc_fet_amt', N'Calc FET Amount', 100, N'Left', N'Filter', N'', N'', 23, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2434, 56, N'cftrx_calc_set_amt', N'Calc SET Amount', 100, N'Left', N'Filter', N'', N'', 24, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2435, 56, N'cftrx_calc_sst_amt', N'Calc SST Amount', 100, N'Left', N'Filter', N'', N'', 25, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2436, 56, N'cftrx_tax_cls_id', N'Tax Class ID', 100, N'Left', N'Filter', N'', N'', 26, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2437, 56, N'cftrx_ivc_prtd_yn', N'Inv Printed ?', 100, N'Left', N'Filter', N'', N'', 27, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2438, 56, N'cftrx_vehl_no', N'Vehicle #', 100, N'Left', N'Filter', N'', N'', 28, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2439, 56, N'cftrx_calc_net_sell_prc', N'Calc Net Sell', 100, N'Left', N'Filter', N'', N'', 29, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2440, 56, N'cftrx_pump_no', N'Pump No', 100, N'Left', N'Filter', N'', N'', 30, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)
 
INSERT INTO #TempCannedPanelColumn VALUES (2441, 7, N'glhst_acct1_8', N'GL Acct', 125, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2442, 7, N'glhst_acct9_16', N'Profit Center', 122, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2443, 7, N'glhst_ref', N'Reference', 119, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2444, 7, N'glhst_period', N'Period', 81, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2445, 7, N'glhst_trans_dt', N'Transaction Date', 117, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2446, 7, N'glhst_src_id', N'Source ID', 117, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2447, 7, N'glhst_src_seq', N'Source Sequence', 118, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2448, 7, N'glhst_dr_cr_ind', N'Credit/Debit', 117, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2449, 7, N'glhst_jrnl_no', N'Journal #', 117, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2450, 7, N'glhst_doc', N'Document #', 117, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2451, 7, N'Amount', N'Amount', 120, N'Left', N'', N'Sum', N'$####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2452, 7, N'glhst_units', N'Units', 117, N'Left', N'', N'', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)
 
INSERT INTO #TempCannedPanelColumn VALUES (2453, 65, N'glhst_acct1_8', N'GL Acct', 347, N'Left', N'', N'', N'', 2, N'', N'', N'glhstmst.glhst_acct1_8', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27)
 
INSERT INTO #TempCannedPanelColumn VALUES (2454, 65, N'glhst_acct9_16', N'Profit Center', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27)
 
INSERT INTO #TempCannedPanelColumn VALUES (2455, 65, N'glact_desc', N'GL Desc', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27)
 
INSERT INTO #TempCannedPanelColumn VALUES (2456, 65, N'Amount', N'Amount', 346, N'Left', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27)
 
INSERT INTO #TempCannedPanelColumn VALUES (2457, 66, N'glact_acct1_8', N'GL Acct', 463, N'Left', N'', N'', N'', 2, N'', N'', N'glhst_acct1_8', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30)
 
INSERT INTO #TempCannedPanelColumn VALUES (2458, 66, N'glact_acct9_16', N'Profit Center', 462, N'Left', N'', N'', N'', 3, N'', N'', N'glhst_acct9_16', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30)
 
INSERT INTO #TempCannedPanelColumn VALUES (2459, 66, N'glact_desc', N'Description', 462, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30)
 
INSERT INTO #TempCannedPanelColumn VALUES (2460, 67, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 31)
 
INSERT INTO #TempCannedPanelColumn VALUES (2461, 67, N'Amount', N'Amount', 693, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 31)
 
INSERT INTO #TempCannedPanelColumn VALUES (2462, 68, N'glact_desc', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 32)
 
INSERT INTO #TempCannedPanelColumn VALUES (2463, 68, N'Amount', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 32)
 
INSERT INTO #TempCannedPanelColumn VALUES (2464, 69, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 33)
 
INSERT INTO #TempCannedPanelColumn VALUES (2465, 69, N'Amount', N'Amount', 693, N'Left', N'', N' ', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 33)
 
INSERT INTO #TempCannedPanelColumn VALUES (2466, 70, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 34)
 
INSERT INTO #TempCannedPanelColumn VALUES (2467, 70, N'Amount', N'Amount', 693, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 34)
 
INSERT INTO #TempCannedPanelColumn VALUES (2468, 71, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40)
 
INSERT INTO #TempCannedPanelColumn VALUES (2469, 71, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40)
 
INSERT INTO #TempCannedPanelColumn VALUES (2470, 71, N'Amount', N'Revenue Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40)
 
INSERT INTO #TempCannedPanelColumn VALUES (2471, 71, N'Amount', N'Expense Amount', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40)
 
INSERT INTO #TempCannedPanelColumn VALUES (2472, 72, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41)
 
INSERT INTO #TempCannedPanelColumn VALUES (2473, 72, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41)
 
INSERT INTO #TempCannedPanelColumn VALUES (2474, 72, N'Amount', N'Assets Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41)
 
INSERT INTO #TempCannedPanelColumn VALUES (2475, 72, N'Amount', N'Liabilities Amount', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41)
 
INSERT INTO #TempCannedPanelColumn VALUES (2476, 59, N'agstm_ivc_no', N'Invoice #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'agstm_ivc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43)
 
INSERT INTO #TempCannedPanelColumn VALUES (2477, 59, N'agstm_ship_rev_dt', N'Ship Date', 25, N'Right', N'', N'', N'Date', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43)
 
INSERT INTO #TempCannedPanelColumn VALUES (2478, 59, N'Profit Percent', N'Profit Percent', 25, N'Right', N'', N'', N'##.###%', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43)
 
INSERT INTO #TempCannedPanelColumn VALUES (2495, 166, N'TABLE_NAME', N'Table', 237, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)
 
INSERT INTO #TempCannedPanelColumn VALUES (2496, 166, N'COLUMN_NAME', N'Column', 234, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)
 
INSERT INTO #TempCannedPanelColumn VALUES (2497, 166, N'DATA_TYPE', N'Data Type', 156, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)
 
INSERT INTO #TempCannedPanelColumn VALUES (2498, 166, N'SIZE', N'Size', 155, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)
 
INSERT INTO #TempCannedPanelColumn VALUES (2499, 166, N'DESCRIPTION', N'Description', 622, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)
 
INSERT INTO #TempCannedPanelColumn VALUES (2563, 168, N'gaaudpay_pmt_audit_no', N'EOD Audit Number', 75, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 
INSERT INTO #TempCannedPanelColumn VALUES (2564, 168, N'gaaud_pur_sls_ind', N'Sales', 75, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 
INSERT INTO #TempCannedPanelColumn VALUES (2565, 168, N'gaaud_trans_type', N'Transaction Type', 75, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 
INSERT INTO #TempCannedPanelColumn VALUES (2566, 168, N'gaaud_in_type', N'', 75, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 
INSERT INTO #TempCannedPanelColumn VALUES (2567, 168, N'gaaud_key_filler1', N'Key Info', 75, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 
INSERT INTO #TempCannedPanelColumn VALUES (2568, 168, N'gaaudpay_pmt_rev_dt', N'Payment Date', 75, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 
INSERT INTO #TempCannedPanelColumn VALUES (2569, 168, N'gaaudpay_chk_no', N'Check Number', 75, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 
INSERT INTO #TempCannedPanelColumn VALUES (2570, 168, N'gaaudpay_stl_amt', N'Payment Amt', 75, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 
INSERT INTO #TempCannedPanelColumn VALUES (2571, 168, N'gaaudstl_ivc_no', N'Advance Invoice Number', 75, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 
INSERT INTO #TempCannedPanelColumn VALUES (2572, 168, N'gaaudpay_cus_ref_no', N'', 74, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 
INSERT INTO #TempCannedPanelColumn VALUES (2573, 168, N'gaaudstl_stl_amt', N'Advance Payment Amt', 75, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)
 

print('/*******************  END INSERTING canned panels on temporary panel column table  *******************/')

print('/*******************  BEGIN DELETE old panel column records  *******************/')

DELETE tblDBPanelColumn WHERE intCannedPanelId != 0

print('/*******************  END DELETE old panel column records  *******************/')


print('/*******************  BEGIN UPDATING canned panels on table Panel Column  *******************/')

DECLARE @intPanelColumnId int
DECLARE @intCannedPanelId int
DECLARE @intCurrentPanelId int

DECLARE db_cursor CURSOR FOR  
SELECT intPanelColumnId, intCannedPanelId FROM #TempCannedPanelColumn
 

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @intPanelColumnId, @intCannedPanelId

WHILE @@FETCH_STATUS = 0   
BEGIN
	SET @intCurrentPanelId = (SELECT TOP 1 intPanelId FROM tblDBPanel WHERE intCannedPanelId = @intCannedPanelId)
		
	INSERT INTO [dbo].[tblDBPanelColumn] 
	([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId])
	SELECT @intCurrentPanelId, [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId]
	FROM #TempCannedPanelColumn 
	WHERE intPanelColumnId = @intPanelColumnId

	
FETCH NEXT FROM db_cursor INTO @intPanelColumnId, @intCannedPanelId
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

DROP TABLE #TempCannedPanelColumn
print('/*******************  END UPDATING canned panels on table Panel Column  *******************/')
/*******************  END UPDATING canned panels on table Panel Column*******************/
GO