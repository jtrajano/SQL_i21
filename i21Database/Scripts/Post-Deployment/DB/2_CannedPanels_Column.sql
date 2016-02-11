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
    [intCannedPanelId] INT				NOT NULL DEFAULT ((0)),
	[strDataType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
)

print('/*******************  BEGIN INSERTING canned panels on temporary panel column table  *******************/')
 
INSERT INTO #TempCannedPanelColumn VALUES (74170, 41, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74171, 41, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74172, 41, N'units', N'Purchased Units', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74173, 41, N'units', N'Sales Units', 0, N'Series2AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74174, 33, N'gahdg_com_cd', N'Com', 107, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74175, 33, N'gahdg_broker_no', N'Broker #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74176, 33, N'gahdg_rev_dt', N'Date', 107, N'Right', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74177, 33, N'gahdg_ref', N'Ref#', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74178, 33, N'gahdg_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74179, 33, N'gahdg_bot_prc', N'BOT Price', 107, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74180, 33, N'gahdg_bot_basis', N'BOT Basis', 106, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74181, 33, N'gahdg_bot', N'BOT', 106, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74182, 33, N'gahdg_bot_option', N'BOT Option', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74183, 33, N'gahdg_long_short_ind', N'L / S', 106, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74184, 33, N'gahdg_un_hdg_bal', N'Balance', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74185, 33, N'gahdg_offset_yn', N'Offset?', 106, N'Left', N'', N'', N'Yes/No', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74186, 33, N'gahdg_hedge_yyyymm', N'Hedge', 107, N'Right', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74187, 37, N'gastr_pur_sls_ind', N'P or S', 278, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74188, 37, N'gastr_com_cd', N'Com', 278, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74189, 37, N'gastr_stor_type', N'Type', 277, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74190, 37, N'gastr_cus_no', N'Customer #', 277, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74191, 37, N'gastr_un_bal', N'Unit Balance', 277, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74192, 38, N'gaphs_pur_sls_ind', N'P / S', 109, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74193, 38, N'gaphs_cus_no', N'Customer Code', 108, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74194, 38, N'gaphs_com_cd', N'Com', 108, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74195, 38, N'gaphs_loc_no', N'Loc', 108, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74196, 38, N'gaphs_tic_no', N'Ticket #', 107, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74197, 38, N'gaphs_cus_ref_no', N'Customer Ref', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74198, 38, N'gaphs_gross_wgt', N'Gross Weight', 105, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74199, 38, N'gaphs_tare_wgt', N'Tare Weight', 107, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74200, 38, N'gaphs_gross_un', N'Gross Units', 106, N'Right', N'', N'Sum', N'####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74201, 38, N'gaphs_wet_un', N'Wet Units', 105, N'Right', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74202, 38, N'gaphs_net_un', N'Net Units', 105, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74203, 38, N'gaphs_fees', N'Fees', 107, N'Right', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74204, 38, N'gaphs_dlvry_rev_dt', N'Delivery Date', 105, N'Right', N'', N'', N'', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74205, 42, N'gaitr_pur_sls_ind', N'P or S', 50, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74206, 42, N'gaitr_loc_no', N'Loc', 6, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74207, 42, N'gaitr_cus_no', N'Cust#', 148, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74208, 42, N'agcus_last_name', N'Customer Last Name', 246, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74209, 42, N'agcus_first_name', N'First Name', 246, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74210, 42, N'gacom_desc', N'Com', 147, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74211, 42, N'gaitr_tic_no', N'Ticket', 246, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74212, 42, N'gaitr_un_out', N'Units', 245, N'Right', N'', N'Sum', N'####.000', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74213, 43, N'gacnt_pur_sls_ind', N'P or S', 116, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74214, 43, N'gacnt_com_cd', N'Com', 116, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74215, 43, N'Option Month', N'Option Month', 116, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74216, 43, N'Option Year', N'Option Year', 116, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74217, 43, N'Balance', N'Balance', 115, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74218, 43, N'Price', N'Price', 116, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74219, 43, N'Extended Amount', N'Ext Amount', 115, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74220, 43, N'WAP', N'WAP', 115, N'Right', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74221, 43, N'WAB', N'WAB', 115, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74222, 43, N'WAF', N'WAF', 116, N'Right', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74223, 43, N'gacnt_due_rev_dt', N'Due Date', 115, N'Right', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74224, 43, N'gacnt_cnt_no', N'Contract #', 116, N'Right', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74225, 53, N'gacom_desc', N'Com', 25, N'Left', N'', N'', N'', 2, N'', N'', N'gacommst.gacom_desc', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 20, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74226, 53, N'totals', N'Totals', 25, N'Right', N'', N'Sum', N'####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 20, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74227, 44, N'pttic_cus_no', N'Customer#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74228, 44, N'ptcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74229, 44, N'ptcus_first_name', N'Customer Name', 25, N'Left', N'', N'', N' ', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74230, 44, N'pttic_itm_no', N'Item#', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74231, 44, N'pttic_qty_orig', N'Quantity', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74232, 44, N'pttic_tic_no', N'Ticket #', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74233, 44, N'pttic_rev_dt', N'Date', 25, N'Right', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74234, 46, N'ptcus_cus_no', N'Customer Code', 347, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74235, 46, N'ptcus_last_name', N'Last Name', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74236, 46, N'ptcus_first_name', N'First Name', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74237, 46, N'ptcus_ar_ov120', N'Amount', 346, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74238, 47, N'ptitm_itm_no', N'Item #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74239, 47, N'ptitm_desc', N'Item/Product', 417, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74240, 47, N'ptitm_loc_no', N'Loc', 138, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74241, 47, N'ptitm_unit', N'Unit Desc', 138, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74242, 47, N'ptitm_on_hand', N'On Hand Qty', 231, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74243, 47, N'ptitm_last_sale_rev_dt', N'Last Sale Date', 231, N'Right', N'', N'', N'Date', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74244, 48, N'ptstm_itm_no', N'Item #', 287, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74245, 48, N'ptitm_desc', N'Description', 287, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74246, 48, N'Sales', N'Sales', 287, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74247, 48, N'Units', N'Units', 286, N'Left', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74248, 49, N'Location', N'Location', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 59, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74249, 49, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 59, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74250, 64, N'ptitm_itm_no', N'Item Code', 243, N'Left', N'', N'', N'', 2, N'', N'', N'ptitm_itm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74251, 64, N'ptitm_desc', N'Item/Product', 437, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74252, 64, N'ptitm_loc_no', N'Loc', 242, N'Left', N'', N'', N'', 4, N'', N'', N'ptitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74253, 64, N'ptitm_on_hand', N'On Hand Quantity', 242, N'Right', N'', N'', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74254, 51, N'ptcus_last_name', N'Customer Last Name', 282, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74255, 51, N'ptcus_first_name', N'First Name', 282, N'Left', N'', N'', N' ', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74256, 51, N'ptcus_cus_no', N'Customer Code', 280, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74257, 51, N'Sales', N'Sales', 280, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74258, 51, N'Units', N'Units', 280, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74259, 50, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74260, 50, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74261, 50, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74262, 50, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74263, 52, N'ptcus_cus_no', N'Customer#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74264, 52, N'ptcus_last_name', N'Customer Last Name', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74265, 52, N'ptcus_first_name', N'First Name', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74266, 52, N'ptcus_credit_limit', N'Credit Limit', 231, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74267, 52, N'Total Balance', N'Total Balance', 231, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74268, 52, N'overage', N'Overage', 231, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74269, 3, N'ptstm_bill_to_cus', N'Bill To Cus', 94, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74270, 3, N'ptstm_ivc_no', N'Invoice #', 93, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74271, 3, N'ptstm_ship_rev_dt', N'Ship Date', 93, N'Right', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74272, 3, N'ptstm_itm_no', N'Item#', 93, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74273, 3, N'ptstm_loc_no', N'Loc', 93, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74274, 3, N'ptstm_class', N'Class Code', 93, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74275, 3, N'ptstm_un', N'Units Sold', 93, N'Right', N'', N'', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74276, 3, N'ptstm_un_prc', N'Unit Price', 92, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74277, 3, N'ptstm_net', N'Sales', 92, N'Right', N'', N'', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74278, 3, N'ptstm_cgs', N'Costs', 92, N'Right', N'', N'', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74279, 3, N'ptstm_slsmn_id', N'Salesperson', 92, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74280, 3, N'ptstm_pak_desc', N'Package Desc', 92, N'Left', N'', N'', N'', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74281, 3, N'ptstm_un_desc', N'Unit Desc', 92, N'Left', N'', N'', N'', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74282, 3, N'Profit Amount', N'Profit Amount', 92, N'Right', N'', N'', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74283, 3, N'Profit Percent', N'Profit Percentage', 91, N'Right', N'', N'', N'##.###%', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74284, 63, N'ptstm_bill_to_cus', N'Bill To Cus', 347, N'Left', N'', N'', N'', 2, N'', N'', N'ptstm_bill_to_cus', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74285, 63, N'ptstm_ivc_no', N'Invoice #', 347, N'Left', N'', N'', N'', 3, N'', N'', N'ptstm_ivc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74286, 63, N'ptstm_ship_rev_dt', N'Ship Date', 347, N'Left', N'', N'', N'Date', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74287, 63, N'Profit Percent', N'Profit Percentage', 346, N'Right', N'', N'', N'##.###%', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74288, 4, N'ptitm_itm_no', N'Item#', 155, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74289, 4, N'ptitm_desc', N'Item/Product', 278, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74290, 4, N'ptitm_loc_no', N'Loc', 92, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74291, 4, N'ptitm_class', N'Class', 154, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74292, 4, N'ptitm_unit', N'Unit Desc', 92, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74293, 4, N'ptitm_cost1', N'Last Costs', 154, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74294, 4, N'ptitm_avg_cost', N'Average Costs', 154, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74295, 4, N'ptitm_std_cost', N'Standard Costs', 154, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74296, 4, N'ptitm_on_hand', N'Units On Hand', 154, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74297, 61, N'ptitm_itm_no', N'Item Code', 347, N'Left', N'', N'', N'', 2, N'', N'', N'ptitm_itm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74298, 61, N'ptitm_desc', N'Item/Product', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74299, 61, N'ptitm_loc_no', N'Loc', 347, N'Left', N'', N'', N' ', 4, N'', N'', N'ptitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74300, 61, N'ptitm_on_hand', N'On-Hand Quantity', 346, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74301, 9, N'agcus_last_name', N'Customer Last Name', 347, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74302, 9, N'Amount', N'Amount', 346, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74303, 9, N'agcus_first_name', N'Customer First Name', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74304, 9, N'agcus_key', N'Customer #', 347, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74305, 57, N'agitm_no', N'Item#', 347, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74306, 57, N'agitm_desc', N'Item/Product', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74307, 57, N'agitm_loc_no', N'Loc', 347, N'Left', N'', N'', N'', 6, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74308, 57, N'agitm_un_on_hand', N'Units On Hand Qty', 346, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74309, 16, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74310, 16, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74311, 16, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74312, 16, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74313, 19, N'agcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74314, 19, N'agstm_key_loc_no', N'Location', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74315, 19, N'agstm_key_loc_no', N'Location', 0, N'Series2AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74316, 19, N'Sales', N'Sales Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74317, 19, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74318, 20, N'agitm_no', N'Item #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74319, 20, N'agitm_desc', N'Item/Product', 417, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74320, 20, N'agitm_loc_no', N'Loc', 138, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74321, 20, N'agitm_un_desc', N'Unit Desc', 138, N'Left', N'', N'', N' ', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74322, 20, N'agitm_un_on_hand', N'On Hand Qty', 231, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74323, 20, N'agitm_last_sale_rev_dt', N'Last Sale Date', 231, N'Right', N'', N'', N'Date', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74324, 21, N'agord_cus_no', N'Customer#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74325, 21, N'agord_ord_no', N'Order#', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74326, 21, N'agord_loc_no', N'Loc', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74327, 21, N'agord_ord_rev_dt', N'Order Date', 231, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74328, 21, N'agord_itm_no', N'Item #', 231, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74329, 21, N'agord_pkg_sold', N'Packages Sold', 231, N'Left', N'', N'', N'####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74330, 5, N'agcnt_cus_no', N'Customer#', 108, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74331, 5, N'agcus_last_name', N'Customer Last Name', 108, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74332, 5, N'agcus_first_name', N'First Name', 108, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74333, 5, N'agcnt_slsmn_id', N'Salesperson ID', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74334, 5, N'agcnt_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74335, 5, N'agcnt_cnt_no', N'Contract #', 108, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74336, 5, N'agcnt_cnt_rev_dt', N'Contract Date', 105, N'Right', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74337, 5, N'agcnt_due_rev_dt', N'Due Date', 107, N'Right', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74338, 5, N'agcnt_itm_or_cls', N'Item or Class', 107, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74339, 5, N'agcnt_prc_lvl', N'Price Level', 105, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74340, 5, N'agcnt_ppd_yndm', N'Prepaid', 105, N'Left', N'', N'', N'Yes/No', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74341, 5, N'agcnt_un_orig', N'Original Units', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74342, 5, N'agcnt_un_bal', N'Unit Balance', 105, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74343, 60, N'agcnt_cus_no', N'Customer#', 199, N'Left', N'', N'', N'', 3, N'', N'', N'agcnt_cus_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74344, 60, N'agcus_last_name', N'Customer Last Name', 198, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74345, 60, N'agcus_first_name', N'First Name', 198, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74346, 60, N'agcnt_loc_no', N'Loc', 198, N'Left', N'', N'', N'', 7, N'', N'', N'agcnt_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74347, 60, N'agcnt_cnt_no', N'Contract #', 200, N'Left', N'', N'Count', N'', 2, N'', N'', N'agcnt_cnt_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74348, 60, N'agcnt_un_bal', N'Unit Balance', 196, N'Right', N'', N'Sum', N'####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74349, 60, N'agcnt_itm_or_cls', N'Item or Class', 198, N'Left', N'', N'', N'', 14, N'', N'', N'agcnt_itm_or_cls', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74350, 59, N'agitm_desc', N'Item/Product', 427, N'Left', N'', N'Count', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74351, 59, N'agitm_loc_no', N'Loc', 371, N'Left', N'', N'', N'', 4, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74352, 59, N'agitm_un_on_hand', N'On Hand Inventory', 369, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74353, 59, N'agitm_no', N'Item #', 220, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74354, 7, N'agitm_no', N'Item #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74355, 7, N'agitm_desc', N'Item Name', 107, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74356, 7, N'agitm_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74357, 7, N'agitm_un_desc', N'Unit Desc', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74358, 7, N'agitm_un_on_hand', N'On Hand', 107, N'Right', N'', N'Sum', N'####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74359, 7, N'agitm_un_pend_ivcs', N'Pending Invoices', 106, N'Right', N'', N'Sum', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74360, 7, N'agitm_un_on_order', N'On Order', 107, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74361, 7, N'agitm_un_mfg_in_prs', N'Mfg', 107, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74362, 7, N'agitm_un_fert_committed', N'Contracts Committed', 106, N'Right', N'', N'Sum', N'####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74363, 7, N'agitm_un_ord_committed', N'Orders Committed', 106, N'Right', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74364, 7, N'agitm_un_cnt_committed', N'Other Contracts Committed', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74365, 7, N'Available', N'Available', 106, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74366, 7, N'agitm_class', N'Class', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74367, 56, N'agitm_no', N'Item #', 347, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74368, 56, N'agitm_desc', N'Item Name', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74369, 56, N'agitm_loc_no', N'Loc', 347, N'Left', N'', N'', N'', 4, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74370, 56, N'Available', N'Available', 346, N'Left', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74371, 40, N'pxrpt_trans_type', N'Trans Type', 26, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74372, 40, N'pxrpt_trans_rev_dt', N'Trans Date', 65, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74373, 40, N'pxrpt_ord_no', N'Order #', 76, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74374, 40, N'pxrpt_car_name', N'Carrier', 76, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74375, 40, N'pxrpt_cus_name', N'Customer', 76, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74376, 40, N'pxrpt_cus_state', N'Customer State', 76, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74377, 40, N'pxrpt_itm_desc', N'Item/Product', 76, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74378, 40, N'pxrpt_itm_loc_no', N'Loc', 76, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74379, 40, N'pxrpt_vnd_name', N'Vendor', 76, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74380, 40, N'pxrpt_vnd_state', N'Vendor State', 28, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74381, 40, N'pxrpt_pur_gross_un', N'Gross Units Purchased', 75, N'Left', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74382, 40, N'pxrpt_pur_net_un', N'Net Units Purchased', 75, N'Left', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74383, 40, N'pxrpt_pur_fet_amt', N'FET', 75, N'Left', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74384, 40, N'pxrpt_pur_set_amt', N'SET', 75, N'Left', N'', N'Sum', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74385, 40, N'pxrpt_pur_sst_amt', N'SST', 75, N'Left', N'', N'Sum', N'$####.00', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74386, 40, N'pxrpt_pur_lc1_amt', N'LC1', 75, N'Left', N'', N'Sum', N'$####.00', 17, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74387, 40, N'pxrpt_pur_lc2_amt', N'LC2', 75, N'Left', N'', N'Sum', N'$####.00', 18, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74388, 40, N'pxrpt_pur_lc3_amt', N'LC3', 25, N'Left', N'', N'Sum', N'$####.00', 19, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74389, 40, N'pxrpt_pur_lc4_amt', N'LC4', 25, N'Left', N'', N'Sum', N'$####.00', 20, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74390, 40, N'pxrpt_pur_un_received', N'Units Received', 76, N'Left', N'', N'Sum', N'####.00', 21, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74391, 40, N'pxrpt_src_sys', N'Source System', 76, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74392, 40, N'pxrpt_itm_dyed_yn', N'Dyed?', 25, N'Left', N'', N'', N'', 22, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74393, 31, N'pxrpt_trans_type', N'Trans Type', 82, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74394, 31, N'pxrpt_trans_rev_dt', N'Trans Date', 82, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74395, 31, N'pxrpt_src_sys', N'Source System', 79, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74396, 31, N'pxrpt_ord_no', N'Order #', 79, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74397, 31, N'pxrpt_car_name', N'Carrier', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74398, 31, N'pxrpt_cus_name', N'Customer', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74399, 31, N'pxrpt_cus_state', N'Customer State', 27, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74400, 31, N'pxrpt_itm_desc', N'Item/Product', 78, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74401, 31, N'pxrpt_itm_loc_no', N'Loc', 69, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74402, 31, N'pxrpt_vnd_name', N'Vendor ', 76, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74403, 31, N'pxrpt_vnd_state', N'Vendor State', 77, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74404, 31, N'pxrpt_sls_trans_gals', N'Sales Units', 77, N'Left', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74405, 31, N'pxrpt_sls_fet_amt', N'FET', 77, N'Left', N'', N'Sum', N'$####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74406, 31, N'pxrpt_sls_set_amt', N'SET', 77, N'Left', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74407, 31, N'pxrpt_sls_lc1_amt', N'LC1', 76, N'Left', N'', N'Sum', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74408, 31, N'pxrpt_sls_lc2_amt', N'LC2', 76, N'Left', N'', N'Sum', N'$####.00', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74409, 31, N'pxrpt_sls_lc3_amt', N'LC3', 76, N'Left', N'', N'Sum', N'$####.00', 17, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74410, 31, N'pxrpt_sls_lc4_amt', N'LC4', 76, N'Left', N'', N'Sum', N'$####.00', 18, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74411, 31, N'pxrpt_itm_dyed_yn', N'Dyed?', 77, N'Left', N'', N'', N'', 19, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74412, 31, N'pxrpt_cus_acct_stat', N'Cus  Acct Status ', 76, N'Left', N'', N'', N'', 20, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74413, 11, N'apcbk_desc', N'Checkbook Name', 25, N'Left', N'', N'', N' ', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74414, 11, N'apcbk_no', N'Checkbook #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74415, 11, N'apcbk_bal', N'Checkbook Balance', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74416, 14, N'apchk_rev_dt', N'Date', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74417, 14, N'apchk_name', N'Check Name', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74418, 14, N'apchk_chk_amt', N'Check Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74419, 13, N'apivc_ivc_no', N'Invoice#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74420, 13, N'apivc_ivc_rev_dt', N'Invoice Date', 231, N'Right', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74421, 13, N'apivc_vnd_no', N'Vendor #', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74422, 13, N'ssvnd_name', N'Vendor', 231, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74423, 13, N'amounts', N'Amount Due', 231, N'Right', N'', N'Sum', N'$###0.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74424, 13, N'apivc_due_rev_dt', N'Due Date', 231, N'Right', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74425, 12, N'apchk_cbk_no', N'Checkbook #', 139, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74426, 12, N'apchk_rev_dt', N'Date', 139, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74427, 12, N'apchk_vnd_no', N'Vendor #', 139, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74428, 12, N'apchk_name', N'Vendor Name', 139, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74429, 12, N'apchk_chk_amt', N'Check Amount', 139, N'Left', N'', N'Sum', N'$###0.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74430, 12, N'apchk_disc_amt', N'Discount Amount', 139, N'Left', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74431, 12, N'apchk_gl_rev_dt', N'GL Date', 139, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74432, 12, N'apchk_cleared_ind', N'Cleared?', 138, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74433, 12, N'apchk_clear_rev_dt', N'Cleared Date', 138, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74434, 12, N'apchk_src_sys', N'Source System', 138, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74435, 15, N'apivc_ivc_no', N'Invoice #', 127, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74436, 15, N'apivc_ivc_rev_dt', N'Invoice Date', 315, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74437, 15, N'apivc_vnd_no', N'Vendor #', 315, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74438, 15, N'ssvnd_name', N'Vendor Name', 315, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74439, 15, N'amounts', N'Amount', 315, N'Left', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74440, 54, N'CheckDate', N'Check Date', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 39, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74441, 54, N'Amount', N'Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 39, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74442, 24, N'strDescription', N'Description', 154, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74443, 24, N'dblDebit', N'Debit ', 153, N'Left', N'', N'Sum', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74444, 24, N'dblCredit', N'Credit', 153, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74445, 24, N'Balance', N'Balance', 153, N'Left', N'', N'Sum', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74446, 24, N'strAccountId', N'AccountID', 159, N'Left', N'', N'Count', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74447, 24, N'dtmDate', N'Date', 154, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74448, 24, N'strTransactionId', N'Document', 154, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74449, 24, N'strReference', N'Reference', 154, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74450, 24, N'strAccountGroup', N'Account Group', 153, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74451, 23, N'strAccountId', N'Account ID', 463, N'Left', N'', N'Count', N'', 2, N'', N'', N'strAccountId', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 76, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74452, 23, N'strDescription', N'Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 76, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74453, 23, N'Balance', N'Balance', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 76, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74454, 26, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74455, 26, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74456, 26, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74457, 34, N'Period', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74458, 34, N'TotalBalance', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74459, 34, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74460, 34, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74461, 35, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 82, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74462, 35, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 82, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74463, 27, N'strAccountId', N'Account ID', 459, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74464, 27, N'strDescription', N'GL Description', 465, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74465, 27, N'Amount', N'Amount', 463, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74466, 36, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 83, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74467, 36, N'Revenue', N'Revenue', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 83, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74468, 29, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74469, 29, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74470, 29, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74471, 39, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 84, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74472, 39, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 84, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74473, 55, N'cftrx_ar_cus_no', N'A/R Customer #', 100, N'Left', N'Filter', N'', N'', 1, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74474, 55, N'cftrx_card_no', N'Card #', 100, N'Left', N'Filter', N'', N'', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74475, 55, N'cfcus_card_desc', N'Card Desc', 100, N'Left', N'Filter', N'', N'', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74476, 55, N'cftrx_rev_dt', N'Date', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74477, 55, N'cftrx_qty', N'Quantity', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74478, 55, N'cftrx_prc', N'Price', 100, N'Left', N'Filter', N'', N'', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74479, 55, N'cftrx_calc_total', N'Calc Total', 100, N'Left', N'Filter', N'', N'', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74480, 55, N'cftrx_ar_itm_no', N'A/R Item #', 100, N'Left', N'Filter', N'', N'', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74481, 55, N'cftrx_ar_itm_loc_no', N'Loc ', 100, N'Left', N'Filter', N'', N'', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74482, 55, N'cftrx_sls_id', N'Salesperson ID', 100, N'Left', N'Filter', N'', N'', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74483, 55, N'cftrx_sell_prc', N'Sell Price', 100, N'Left', N'Filter', N'', N'', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74484, 55, N'cftrx_prc_per_un', N'Price per Unit', 100, N'Left', N'Filter', N'', N'', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74485, 55, N'cftrx_site', N'Site', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74486, 55, N'cftrx_time', N'Time', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74487, 55, N'cftrx_odometer', N'Odometer', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74488, 55, N'cftrx_site_state', N'Site State', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74489, 55, N'cftrx_site_county', N'Site County', 100, N'Left', N'Filter', N'', N'', 17, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74490, 55, N'cftrx_site_city', N'Site City', 100, N'Left', N'Filter', N'', N'', 18, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74491, 55, N'cftrx_selling_host_id', N'Selling Host ID', 100, N'Left', N'Filter', N'', N'', 19, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74492, 55, N'cftrx_buying_host_id', N'Buying Host ID', 100, N'Left', N'Filter', N'', N'', 20, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74493, 55, N'cftrx_po_no', N'PO #', 100, N'Left', N'Filter', N'', N'', 21, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74494, 55, N'cftrx_ar_ivc_no', N'A/R Invoice #', 100, N'Left', N'Filter', N'', N'', 22, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74495, 55, N'cftrx_calc_fet_amt', N'Calc FET Amount', 100, N'Left', N'Filter', N'', N'', 23, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74496, 55, N'cftrx_calc_set_amt', N'Calc SET Amount', 100, N'Left', N'Filter', N'', N'', 24, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74497, 55, N'cftrx_calc_sst_amt', N'Calc SST Amount', 100, N'Left', N'Filter', N'', N'', 25, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74498, 55, N'cftrx_tax_cls_id', N'Tax Class ID', 100, N'Left', N'Filter', N'', N'', 26, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74499, 55, N'cftrx_ivc_prtd_yn', N'Inv Printed ?', 100, N'Left', N'Filter', N'', N'', 27, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74500, 55, N'cftrx_vehl_no', N'Vehicle #', 100, N'Left', N'Filter', N'', N'', 28, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74501, 55, N'cftrx_calc_net_sell_prc', N'Calc Net Sell', 100, N'Left', N'Filter', N'', N'', 29, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74502, 55, N'cftrx_pump_no', N'Pump No', 100, N'Left', N'Filter', N'', N'', 30, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74503, 6, N'glhst_acct1_8', N'GL Acct', 125, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74504, 6, N'glhst_acct9_16', N'Profit Center', 122, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74505, 6, N'glhst_ref', N'Reference', 119, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74506, 6, N'glhst_period', N'Period', 81, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74507, 6, N'glhst_trans_dt', N'Transaction Date', 117, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74508, 6, N'glhst_src_id', N'Source ID', 117, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74509, 6, N'glhst_src_seq', N'Source Sequence', 118, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74510, 6, N'glhst_dr_cr_ind', N'Credit/Debit', 117, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74511, 6, N'glhst_jrnl_no', N'Journal #', 117, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74512, 6, N'glhst_doc', N'Document #', 117, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74513, 6, N'Amount', N'Amount', 120, N'Left', N'', N'Sum', N'$####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74514, 6, N'glhst_units', N'Units', 117, N'Left', N'', N'', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74515, 65, N'glhst_acct1_8', N'GL Acct', 347, N'Left', N'', N'', N'', 2, N'', N'', N'glhstmst.glhst_acct1_8', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74516, 65, N'glhst_acct9_16', N'Profit Center', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74517, 65, N'glact_desc', N'GL Desc', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74518, 65, N'Amount', N'Amount', 346, N'Left', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74519, 3364, N'glact_acct1_8', N'GL Acct', 463, N'Left', N'', N'', N'', 2, N'', N'', N'glhst_acct1_8', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74520, 3364, N'glact_acct9_16', N'Profit Center', 462, N'Left', N'', N'', N'', 3, N'', N'', N'glhst_acct9_16', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74521, 3364, N'glact_desc', N'Description', 462, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74522, 69, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 31, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74523, 69, N'Amount', N'Amount', 693, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 31, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74524, 70, N'glact_desc', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 32, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74525, 70, N'Amount', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 32, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74526, 71, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 33, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74527, 71, N'Amount', N'Amount', 693, N'Left', N'', N' ', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 33, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74528, 73, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 34, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74529, 73, N'Amount', N'Amount', 693, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 34, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74530, 76, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74531, 76, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74532, 76, N'Amount', N'Revenue Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74533, 76, N'Amount', N'Expense Amount', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74534, 74, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74535, 74, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74536, 74, N'Amount', N'Assets Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74537, 74, N'Amount', N'Liabilities Amount', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74538, 58, N'agstm_ivc_no', N'Invoice #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'agstm_ivc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74539, 58, N'agstm_ship_rev_dt', N'Ship Date', 25, N'Right', N'', N'', N'Date', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74540, 58, N'Profit Percent', N'Profit Percent', 25, N'Right', N'', N'', N'##.###%', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74541, 39, N'', N'', 0, N'Series2AxisX', NULL, NULL, N'', 2, NULL, NULL, NULL, 0, N'Chart', N'Series2AxisX', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 84, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74542, 39, N'', N'', 0, N'Series2AxisY', NULL, NULL, N'', 2, NULL, NULL, NULL, 0, N'Chart', N'Series2AxisY', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 84, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74543, 32, N'gacnt_pur_sls_ind', N'P/S', 107, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74544, 32, N'gacnt_cus_no', N'Customer #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74545, 32, N'agcus_last_name', N'Last Name', 107, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74546, 32, N'agcus_first_name', N'First Name', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74547, 32, N'gacnt_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74548, 32, N'gacnt_com_cd', N'Com', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74549, 32, N'gacnt_cnt_no', N'Contact #', 106, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74550, 32, N'gacnt_seq_no', N'Seq', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74551, 32, N'gacnt_mkt_zone', N'Market Zone', 107, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74552, 32, N'gacnt_beg_ship_rev_dt', N'Beg Ship Date', 106, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74553, 32, N'gacnt_due_rev_dt', N'Due Date', 106, N'Right', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74554, 32, N'gacnt_pbhcu_ind', N'PBHU', 107, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74555, 32, N'gacnt_un_bal', N'Unit Balance', 106, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74556, 2, N'gacom_desc', N'Com', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74557, 2, N'gapos_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74558, 2, N'gapos_in_house', N'In House', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74559, 2, N'gapos_offsite', N'Offsite', 25, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74560, 2, N'gapos_sls_in_transit', N'In Transit', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74561, 45, N'Current', N'Current', 25, N'Center', N'', N'', N'$####.00', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74562, 45, N'31-60 Days', N'31-60 Days', 25, N'Center', N'', N'', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74563, 45, N'61-90 Days', N'61-90 Days', 25, N'Center', N'', N'', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74564, 45, N'91-120 Days', N'91-120 Days', 25, N'Center', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74565, 45, N'Over 120 Days', N'Over 120 Days', 25, N'Center', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74566, 10, N'Future', N'Future', 25, N'Left', N'', N'', N'$####.00', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74567, 10, N'Current', N'Current', 25, N'Left', N'', N'', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74568, 10, N'30days', N'31-60 Days', 25, N'Left', N'', N'', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74569, 10, N'60days', N'61-90 Days', 25, N'Left', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74570, 10, N'90days', N'91-120 Days', 25, N'Left', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74571, 10, N'120days', N'Over 120 Days', 25, N'Left', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74572, 95, N'agcus_key', N'Customer #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74573, 95, N'agcus_last_name', N'Customer Last Name', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74574, 95, N'agcus_first_name', N'First Name', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74575, 95, N'agcus_cred_limit', N'Credit Limit', 231, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74576, 95, N'Total Balance', N'Total Balance', 231, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74577, 95, N'Overage', N'Overage', 231, N'Right', N'', N'Sum', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74578, 1, N'agitm_no', N'Item#', 174, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74579, 1, N'agitm_desc', N'Item/Product', 174, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74580, 1, N'agitm_pak_desc', N'Package', 174, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74581, 1, N'agitm_class', N'Class', 173, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74582, 1, N'agitm_loc_no', N'Loc', 173, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74583, 1, N'agitm_last_un_cost', N'Last Unit Cost', 173, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74584, 1, N'agitm_avg_un_cost', N'Average Unit Cost', 173, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74585, 1, N'agitm_un_on_hand', N'Units On Hand Qty', 173, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74586, 18, N'agstm_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74587, 18, N'agitm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74588, 18, N'Sales', N'Sales', 25, N'Right', N'', N'Sum', N'$###0.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74589, 18, N'Units', N'Units', 25, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74590, 17, N'Customer Last Name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74591, 17, N'First Name', N'First Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74592, 17, N'Customer Code', N'Customer Code', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74593, 17, N'Sales', N'Sales', 25, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74594, 17, N'Units', N'Units', 25, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74595, 25, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74596, 25, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74597, 25, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74598, 22, N'intGLDetailId', N'GL Detail ID', 100, N'Left', N'Filter', N'', N'', 1, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74599, 22, N'dtmDate', N'Date', 100, N'Left', N'Filter', N'', N'Date', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74600, 22, N'strBatchId', N'Batch ', 100, N'Left', N'Filter', N'', N'', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74601, 22, N'intAccountId', N'Account ID', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74602, 22, N'strAccountGroup', N'Account Group', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74603, 22, N'dblDebit', N'Debit Amount', 100, N'Left', N'Filter', N'', N'$####.00', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74604, 22, N'dblCredit', N'Credit Amount', 100, N'Left', N'Filter', N'', N'$####.00', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74605, 22, N'dblDebitUnit', N'Debit Unit', 100, N'Left', N'Filter', N'', N'', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74606, 22, N'dblCreditUnit', N'Credit Unit', 100, N'Left', N'Filter', N'', N'', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74607, 22, N'strDescription', N'GL Description', 100, N'Left', N'Filter', N'', N'', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74608, 22, N'strCode', N'Code', 100, N'Left', N'Filter', N'', N'', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74609, 22, N'strTransactionId', N'Trans ID', 100, N'Left', N'Filter', N'', N'', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74610, 22, N'strReference', N'Reference', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74611, 22, N'strJobId', N'Job ID', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74612, 22, N'intCurrencyId', N'Currency ID', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74613, 22, N'dblExchangeRate', N'Exchange Rate', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74614, 22, N'dtmDateEntered', N'Date Entered', 100, N'Left', N'Filter', N'', N'', 17, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74615, 22, N'dtmTransactionDate', N'Trans Date', 100, N'Left', N'Filter', N'', N'', 18, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74616, 22, N'strProductId', N'Product ID', 100, N'Left', N'Filter', N'', N'', 19, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74617, 22, N'strWarehouseId', N'Warehouse ID', 100, N'Left', N'Filter', N'', N'', 20, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74618, 22, N'strNum', N'Num', 100, N'Left', N'Filter', N'', N'', 21, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74619, 22, N'strCompanyName', N'Company Name', 100, N'Left', N'Filter', N'', N'', 22, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74620, 22, N'strBillInvoiceNumber', N'Bill Invoice #', 100, N'Left', N'Filter', N'', N'', 23, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74621, 22, N'strJournalLineDescription', N'Journal Line Desc', 100, N'Left', N'Filter', N'', N'', 24, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74622, 22, N'ysnIsUnposted', N'Unposted?', 100, N'Left', N'Filter', N'', N'', 25, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74623, 22, N'intConcurrencyId', N'Concurrency ID', 100, N'Left', N'Filter', N'', N'', 26, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74624, 22, N'intUserID', N'User ID', 100, N'Left', N'Filter', N'', N'', 27, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74625, 22, N'strTransactionForm', N'Trans Form', 100, N'Left', N'Filter', N'', N'', 28, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74626, 22, N'strModuleName', N'Module Name', 100, N'Left', N'Filter', N'', N'', 29, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74627, 22, N'strUOMCode', N'UOM Code', 100, N'Left', N'Filter', N'', N'', 30, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74628, 22, N'intAccountId1', N'Account ID 1', 100, N'Left', N'Filter', N'', N'', 31, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74629, 22, N'strAccountId', N'Account ID', 100, N'Left', N'Filter', N'', N'', 32, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74630, 22, N'strDescription1', N'Description 1', 100, N'Left', N'Filter', N'', N'', 33, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74631, 22, N'strNote', N'Note', 100, N'Left', N'Filter', N'', N'', 34, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74632, 22, N'intAccountGroupId', N'Account Group ID', 100, N'Left', N'Filter', N'', N'', 35, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74633, 22, N'dblOpeningBalance', N'Opening Balance', 100, N'Left', N'Filter', N'', N'', 36, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74634, 22, N'ysnIsUsed', N'Is Used?', 100, N'Left', N'Filter', N'', N'', 37, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74635, 22, N'strComments', N'Comments', 100, N'Left', N'Filter', N'', N'', 40, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74636, 22, N'ysnActive', N'Active', 100, N'Left', N'Filter', N'', N'', 41, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74637, 22, N'ysnSystem', N'System', 100, N'Left', N'Filter', N'', N'', 42, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74638, 22, N'strCashFlow', N'Cash Flow', 100, N'Left', N'Filter', N'', N'', 43, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74639, 22, N'intAccountGroupId1', N'Account Group ID 1', 100, N'Left', N'Filter', N'', N'', 44, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74640, 22, N'strAccountGroup1', N'Account Group 1', 100, N'Left', N'Filter', N'', N'', 45, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74641, 22, N'strAccountType', N'Account Type', 100, N'Left', N'Filter', N'', N'', 46, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74642, 22, N'intParentGroupId', N'Parent Group ID', 100, N'Left', N'Filter', N'', N'', 47, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74643, 22, N'intGroup', N'Group', 100, N'Left', N'Filter', N'', N'', 48, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74644, 22, N'intSort', N'Sort', 100, N'Left', N'Filter', N'', N'', 49, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74645, 22, N'intConcurrencyId2', N'Concurrency ID 2', 100, N'Left', N'Filter', N'', N'', 50, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74646, 22, N'intAccountBegin', N'Account Begin', 100, N'Left', N'Filter', N'', N'', 51, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74647, 22, N'intAccountEnd', N'Account End', 100, N'Left', N'Filter', N'', N'', 52, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74648, 22, N'strAccountGroupNamespace', N'Account Group Name', 100, N'Left', N'Filter', N'', N'', 53, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74649, 28, N'glije_acct_no', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74650, 28, N'glije_date', N'Date', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74651, 28, N'glije_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74652, 28, N'glije_ref', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74653, 28, N'glije_doc', N'Document #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74654, 28, N'glije_amt', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74655, 30, N'glije_acct_no', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74656, 30, N'glije_date', N'Date', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74657, 30, N'glije_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74658, 30, N'glije_ref', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74659, 30, N'glije_doc', N'Document #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74660, 30, N'glije_amt', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74661, 67, N'gaaudpay_pmt_audit_no', N'EOD Audit Number', 75, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74662, 67, N'gaaud_pur_sls_ind', N'Sales', 75, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74663, 67, N'gaaud_trans_type', N'Transaction Type', 75, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74664, 67, N'gaaud_in_type', N'', 75, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74665, 67, N'gaaud_key_filler1', N'Key Info', 75, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74666, 67, N'gaaudpay_pmt_rev_dt', N'Payment Date', 75, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74667, 67, N'gaaudpay_chk_no', N'Check Number', 75, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74668, 67, N'gaaudpay_stl_amt', N'Payment Amt', 75, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74669, 67, N'gaaudstl_ivc_no', N'Advance Invoice Number', 75, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74670, 67, N'gaaudpay_cus_ref_no', N'', 74, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74671, 67, N'gaaudstl_stl_amt', N'Advance Payment Amt', 75, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74672, 68, N'sthss_store_name', N'Store Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 89, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74673, 68, N'FormattedDate', N'Date', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 89, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74674, 68, N'sthss_tot_cash_overshort', N'Over / Short Amount', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 89, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74675, 72, N'Store Name', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 91, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74676, 72, N'Date', N'', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 91, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74677, 72, N'Total Customers', N'', 25, N'Right', N'', N'Sum', N'####', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 91, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74678, 75, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 92, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74679, 75, N'sthss_rev_dt', N'Date', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 92, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74680, 75, N'sthss_key_deptno', N'Dept. #', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 92, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74681, 75, N'sthss_key_desc', N'Description', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 92, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74682, 75, N'sthss_key_total_sales', N'Total Sales', 25, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 92, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74683, 85, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74684, 85, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74685, 85, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74686, 85, N'Retail Price', N'', 25, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74687, 85, N'Last Price', N'', 25, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74688, 85, N'On-Hand Qty', N'', 25, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74689, 85, N'On Order Qty', N'', 25, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74690, 77, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 94, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74691, 77, N'sthss_pmp_id', N'Fuel Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 94, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74692, 77, N'c', N'Fuel Margins', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 94, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74693, 78, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 95, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74694, 78, N'sthss_pmp_desc', N'Fuel Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 95, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74695, 78, N'c', N'Sales Amount', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 95, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74696, 79, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 96, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74697, 79, N'sthss_pmp_id', N'Fuel Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 96, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74698, 79, N'c', N'Gallons', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 96, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74699, 81, N'Store Name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 97, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74700, 81, N'Dept #', N'Department', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 97, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74701, 81, N'Gross Profit', N'Gross Profit', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 97, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74702, 86, N'UPC #', N'', 100, N'Left', N'Filter', N'', N'', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74703, 86, N'Trans Dt', N'', 100, N'Left', N'Filter', N'', N'Date', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74704, 86, N'Purchase / Sale', N'', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74705, 86, N'Store', N'', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74706, 86, N'Inv #', N'', 100, N'Left', N'Filter', N'', N'', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74707, 86, N'Department', N'', 100, N'Left', N'Filter', N'', N'', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74708, 86, N'Purchase Qty', N'', 100, N'Left', N'Filter', N'', N'####.00', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74709, 86, N'Units Cost', N'', 100, N'Left', N'Filter', N'', N'$####.00', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74710, 86, N'Retail Price', N'', 100, N'Left', N'Filter', N'', N'$####.00', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74711, 86, N'Qty Sold', N'', 100, N'Left', N'Filter', N'', N'####.00', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74712, 86, N'Amount Sold', N'', 100, N'Left', N'Filter', N'', N'$####.00', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74713, 86, N'Month', N'', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74714, 86, N'UPC Desc', N'', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74715, 86, N'Family', N'', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74716, 86, N'Class', N'', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74717, 82, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 99, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74718, 82, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 99, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74719, 82, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 99, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74720, 82, N'Min Qty', N'', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 99, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74721, 82, N'On-Hand Qty', N'', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 99, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74722, 83, N'Store', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 100, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74723, 83, N'Date', N'', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 100, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74724, 83, N'No Sale Transactions', N'', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 100, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74725, 84, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74726, 84, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74727, 84, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74728, 84, N'Start Date', N'', 25, N'Right', N'', N'', N'Date', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74729, 84, N'End Date', N'', 25, N'Right', N'', N'', N'Date', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74730, 84, N'Sale Price', N'', 25, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74731, 90, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74732, 90, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74733, 90, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74734, 90, N'Vendor ID', N'', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74735, 90, N'Dept #', N'', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74736, 90, N'Family', N'', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74737, 90, N'Class', N'', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74738, 90, N'Case Cost', N'', 25, N'Right', N'', N'Sum', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74739, 90, N'Retail Price', N'', 25, N'Right', N'', N'Sum', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74740, 90, N'Last Price', N'', 25, N'Right', N'', N'Sum', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74741, 90, N'Min Qty', N'', 25, N'Right', N'', N'Sum', N'####', 12, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74742, 90, N'Sug Qty', N'', 25, N'Right', N'', N'Sum', N'####', 13, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74743, 90, N'Min Order Qty', N'', 25, N'Right', N'', N'Sum', N'####', 14, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74744, 90, N'On-Hand Qty', N'', 25, N'Right', N'', N'Sum', N'####', 15, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74745, 90, N'On Order Qty', N'', 25, N'Right', N'', N'Sum', N'####', 16, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74746, 90, N'Qty Sold', N'', 25, N'Right', N'', N'Sum', N'####', 17, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74747, 87, N'Store', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 103, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74748, 87, N'Date', N'', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 103, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74749, 87, N'Refund Amount', N'', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 103, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74750, 88, N'store name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 104, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74751, 88, N'dept #', N'Dept. #', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 104, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74752, 88, N'total sales', N'Total Sales', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 104, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74753, 89, N'stphy_store_name', N'Store Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 105, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74754, 89, N'stphy_rev_dt', N'Date', 25, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 105, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74755, 89, N'stphy_shift_no', N'Shift #', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 105, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74756, 89, N'stphy_itm_desc', N'Item', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 105, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74757, 89, N'stphy_diff_qty', N'Diff Qty', 25, N'Left', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 105, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74758, 62, N'Store', N'Store', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 90, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74759, 62, N'Cash Over / Short Amount', N'Over / Short Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 90, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74760, 91, N'Trans Dt', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 109, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74761, 91, N'Purchase Qty', N'Purchase Qty', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 109, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74762, 92, N'Trans Dt', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 106, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74763, 92, N'Amount Sold', N'Amount Sold', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 106, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74764, 93, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 107, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74765, 93, N'Total Sales', N'Total Sales', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 107, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74766, 94, N'strPanelName', N'', 434, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 108, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74767, 94, N'strUserName', N'', 434, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 108, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74768, 94, N'strFullName', N'', 433, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 108, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (74769, 96, N'strAccountId', N'Account ID', 200, N'Left', NULL, NULL, NULL, 1, NULL, NULL, N'', 0, N'Grid', NULL, N'TRENNER', 0, 0, 0, 0, 0, NULL, 0, 1, 112, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74770, 96, N'strDescription', N'Description', 200, N'Left', NULL, NULL, NULL, 2, NULL, NULL, N'', 0, N'Grid', NULL, N'TRENNER', 0, 0, 0, 0, 0, NULL, 0, 1, 112, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74771, 97, N'Employee', N'', 45, N'Left', NULL, NULL, NULL, 1, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74772, 97, N'Vendor', N'', 91, N'Left', NULL, NULL, NULL, 2, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74773, 97, N'GLDate', N'', 91, N'Left', NULL, NULL, N'Date', 3, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (74774, 97, N'BillDate', N'', 91, N'Left', NULL, NULL, N'Date', 4, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 111, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (74775, 97, N'DueDate', N'', 91, N'Left', NULL, NULL, N'Date', 5, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (74776, 97, N'InvoiceNumber', N'', 115, N'Left', NULL, NULL, NULL, 6, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74777, 97, N'ItemTotal', N'', 105, N'Right', NULL, N'Sum', N'$####.00', 7, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74778, 97, N'Item', N'', 35, N'Left', NULL, NULL, NULL, 8, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74779, 97, N'Account', N'', 114, N'Left', NULL, NULL, NULL, 9, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74780, 97, N'AccountDesc', N'', 114, N'Left', NULL, NULL, NULL, 10, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74781, 97, N'Due', N'', 100, N'Left', NULL, NULL, N'$####.00', 11, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 111, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74782, 139, N'Cust Number', N'', 100, N'Left', NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74783, 139, N'Cust Name', N'', 100, N'Left', NULL, NULL, NULL, 2, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74784, 139, N'Site Number', N'', 100, N'Left', NULL, NULL, NULL, 3, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.Int32')
 
INSERT INTO #TempCannedPanelColumn VALUES (74785, 139, N'Item', N'', 100, N'Left', NULL, NULL, NULL, 4, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74786, 139, N'Date Marked As For Review', N'', 100, N'Left', NULL, NULL, NULL, 5, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (74787, 139, N'Gallons', N'', 100, N'Left', NULL, NULL, NULL, 6, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74788, 139, N'Transaction Type', N'', 100, N'Left', NULL, NULL, NULL, 7, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74789, 4395, N'vwcus_last_name', N'Last Name', 100, N'Left', NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74790, 4395, N'vwcus_first_name', N'First Name', 100, N'Left', NULL, NULL, NULL, 2, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74791, 4395, N'strTankTownship', N'Township', 100, N'Left', NULL, NULL, NULL, 3, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74792, 4395, N'strSiteAddress', N'Address', 100, N'Left', NULL, NULL, NULL, 4, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74793, 4395, N'strCity', N'City', 100, N'Left', NULL, NULL, NULL, 5, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74794, 4395, N'strState', N'State', 50, N'Left', NULL, NULL, NULL, 6, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74795, 4395, N'strBulkPlant', N'Bulk Plant', 50, N'Left', NULL, NULL, NULL, 7, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74796, 4395, N'dblPurchasePrice', N'Purchase Price', 50, N'Left', NULL, NULL, NULL, 8, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74797, 4395, N'dtmPurchaseDate', N'Purchase Date', 50, N'Left', NULL, NULL, N'Date', 9, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (74798, 4395, N'dtmManufacturedDate', N'Manufactured Date', 50, N'Left', NULL, NULL, N'Date', 10, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (74799, 4395, N'strManufacturerID', N'Manufactured ID', 50, N'Left', NULL, NULL, NULL, 11, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74800, 4395, N'dblTankCapacity', N'Tank Capacity', 100, N'Left', NULL, NULL, NULL, 12, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74801, 4395, N'strSerialNumber', N'Serial Number', 75, N'Left', NULL, NULL, NULL, 13, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74802, 4395, N'strInventoryStatusType', N'Inventory Status Type', 50, N'Left', NULL, NULL, NULL, 14, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74803, 4395, N'strOwnership', N'Ownership', 75, N'Left', NULL, NULL, NULL, 15, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74804, 4395, N'strTankType', N'Tank Type', 75, N'Left', NULL, NULL, NULL, 16, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74805, 4395, N'strDeviceType', N'Device Type', 75, N'Left', NULL, NULL, NULL, 17, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74806, 4396, N'agstm_bill_to_cus', N'Bill To Customer', 25, N'Left', NULL, N'', N'', 1, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74807, 4396, N'agstm_ivc_no', N'Invoice #', 25, N'Left', NULL, N'', N'', 2, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74808, 4396, N'agstm_ship_rev_dt', N'Ship Date', 25, N'Left', NULL, N'', N'', 3, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Int32')
 
INSERT INTO #TempCannedPanelColumn VALUES (74809, 4396, N'agstm_itm_no', N'Item #', 25, N'Left', NULL, N'', N'', 4, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74810, 4396, N'agstm_loc_no', N'Loc', 25, N'Left', NULL, N'', N'', 5, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74811, 4396, N'agstm_class', N'Class Code', 25, N'Left', NULL, N'', N'', 6, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74812, 4396, N'agstm_un', N'Units Sold', 25, N'Left', NULL, N'', N'', 7, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74813, 4396, N'agstm_un_prc', N'Unit Price', 25, N'Left', NULL, N'', N'', 8, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74814, 4396, N'agstm_sls', N'Sales Amount', 25, N'Left', NULL, N'', N'', 9, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74815, 4396, N'agstm_un_cost', N'Unit Cost', 25, N'Left', NULL, N'', N'', 10, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74816, 4396, N'agstm_cgs', N'Costs Amount', 25, N'Left', NULL, N'', N'', 11, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74817, 4396, N'agstm_slsmn_id', N'Salesperson', 25, N'Left', NULL, N'', N'', 12, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74818, 4396, N'agstm_pak_desc', N'Package Desc', 25, N'Left', NULL, N'', N'', 13, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74819, 4396, N'agstm_un_desc', N'Unit Desc', 25, N'Left', NULL, N'', N'', 14, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74820, 4396, N'unit margins', N'Unit Margins', 25, N'Left', NULL, N'', N'', 15, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74821, 4396, N'Profit Amount', N'Profit Amount', 25, N'Left', NULL, N'', N'', 16, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74822, 4396, N'Profit Percent', N'Profit Percent', 25, N'Left', NULL, N'', N'', 17, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74823, 1260, N'Cus #', N'', 25, N'Left', NULL, N'', N'', 1, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74824, 1260, N'Last Name', N'', 25, N'Left', NULL, N'', N'', 2, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74825, 1260, N'First Name', N'', 25, N'Left', NULL, N'', N'', 3, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74826, 1260, N'Lease Number', N'', 25, N'Left', NULL, N'', N'', 4, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74827, 1260, N'Tank Serial #', N'', 25, N'Left', NULL, N'', N'', 5, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74828, 1260, N'Tank Capacity', N'', 25, N'Left', NULL, N'', N'', 6, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74829, 1260, N'Lease Status', N'', 25, N'Left', NULL, N'', N'', 7, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74830, 1260, N'Lease Code Desc', N'', 25, N'Left', NULL, N'', N'', 8, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74831, 1260, N'Lease Amount', N'', 25, N'Left', NULL, N'', N'$####.00', 9, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (74832, 1260, N'Lease Billing Month', N'', 25, N'Left', NULL, N'', N'', 10, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.Int32')
 
INSERT INTO #TempCannedPanelColumn VALUES (74833, 1260, N'Lease Frequency', N'', 25, N'Left', NULL, N'', N'', 11, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74834, 1260, N'Lease Start Date', N'', 25, N'Left', NULL, N'', N'Date', 12, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (74835, 1260, N'Last Lease Billing Date', N'', 25, N'Left', NULL, N'', N'Date', 13, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (74836, 4379, N'name', N'', 75, N'Left', NULL, NULL, NULL, 1, NULL, NULL, N'sys.tables.name', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 117, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74837, 4378, N'name', N'', 116, N'Left', NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 118, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74838, 4378, N'COLUMN NAME', N'', 116, N'Left', NULL, NULL, NULL, 2, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 118, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74839, 4378, N'DATA TYPE', N'', 116, N'Left', NULL, NULL, NULL, 3, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 118, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (74840, 4378, N'DESCRIPTION', N'', 116, N'Left', NULL, NULL, NULL, 4, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 118, N'System.String')

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
	([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	SELECT @intCurrentPanelId, [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType]
	FROM #TempCannedPanelColumn 
	WHERE intPanelColumnId = @intPanelColumnId

	
FETCH NEXT FROM db_cursor INTO @intPanelColumnId, @intCannedPanelId
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

DROP TABLE #TempCannedPanelColumn
print('/*******************  END UPDATING canned panels on table Panel Column  *******************/')
/*******************  END UPDATING canned panels on table Panel Column*******************/


print('/***********************   BEGIN checking posible duplicate column  ****************/')
/*******************  BEGIN checking posible duplicate column *******************/
GO
DELETE FROM [dbo].[tblDBPanelColumn] WHERE intPanelColumnId NOT IN (SELECT MIN(intPanelColumnId) FROM [dbo].[tblDBPanelColumn] GROUP BY intPanelId,strColumn,strCaption,intWidth,strAlignment,strArea,strFooter,strFormat,intSort,strFormatTrue,strFormatFalse, strDrillDownColumn,ysnVisible,strType,strAxis,strUserName,intUserId,intDonut,intMinInterval,intMaxInterval,intStepInterval,strIntervalFormat,ysnHiddenColumn,[intConcurrencyId],strDataType)

print('/***********************   END checking posible duplicate column  ****************/')
/*******************  END checking posible duplicate column *******************/
GO