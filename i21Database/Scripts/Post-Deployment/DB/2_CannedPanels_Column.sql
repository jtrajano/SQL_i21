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
 
INSERT INTO #TempCannedPanelColumn VALUES (76439, 41, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76440, 41, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76441, 41, N'units', N'Purchased Units', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76442, 41, N'units', N'Sales Units', 0, N'Series2AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76443, 33, N'gahdg_com_cd', N'Com', 107, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76444, 33, N'gahdg_broker_no', N'Broker #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76445, 33, N'gahdg_rev_dt', N'Date', 107, N'Right', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76446, 33, N'gahdg_ref', N'Ref#', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76447, 33, N'gahdg_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76448, 33, N'gahdg_bot_prc', N'BOT Price', 107, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76449, 33, N'gahdg_bot_basis', N'BOT Basis', 106, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76450, 33, N'gahdg_bot', N'BOT', 106, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76451, 33, N'gahdg_bot_option', N'BOT Option', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76452, 33, N'gahdg_long_short_ind', N'L / S', 106, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76453, 33, N'gahdg_un_hdg_bal', N'Balance', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76454, 33, N'gahdg_offset_yn', N'Offset?', 106, N'Left', N'', N'', N'Yes/No', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76455, 33, N'gahdg_hedge_yyyymm', N'Hedge', 107, N'Right', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76456, 37, N'gastr_pur_sls_ind', N'P or S', 278, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76457, 37, N'gastr_com_cd', N'Com', 278, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76458, 37, N'gastr_stor_type', N'Type', 277, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76459, 37, N'gastr_cus_no', N'Customer #', 277, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76460, 37, N'gastr_un_bal', N'Unit Balance', 277, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76461, 38, N'gaphs_pur_sls_ind', N'P / S', 109, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76462, 38, N'gaphs_cus_no', N'Customer Code', 108, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76463, 38, N'gaphs_com_cd', N'Com', 108, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76464, 38, N'gaphs_loc_no', N'Loc', 108, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76465, 38, N'gaphs_tic_no', N'Ticket #', 107, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76466, 38, N'gaphs_cus_ref_no', N'Customer Ref', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76467, 38, N'gaphs_gross_wgt', N'Gross Weight', 105, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76468, 38, N'gaphs_tare_wgt', N'Tare Weight', 107, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76469, 38, N'gaphs_gross_un', N'Gross Units', 106, N'Right', N'', N'Sum', N'####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76470, 38, N'gaphs_wet_un', N'Wet Units', 105, N'Right', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76471, 38, N'gaphs_net_un', N'Net Units', 105, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76472, 38, N'gaphs_fees', N'Fees', 107, N'Right', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76473, 38, N'gaphs_dlvry_rev_dt', N'Delivery Date', 105, N'Right', N'', N'', N'', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76474, 42, N'gaitr_pur_sls_ind', N'P or S', 50, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76475, 42, N'gaitr_loc_no', N'Loc', 6, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76476, 42, N'gaitr_cus_no', N'Cust#', 148, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76477, 42, N'agcus_last_name', N'Customer Last Name', 246, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76478, 42, N'agcus_first_name', N'First Name', 246, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76479, 42, N'gacom_desc', N'Com', 147, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76480, 42, N'gaitr_tic_no', N'Ticket', 246, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76481, 42, N'gaitr_un_out', N'Units', 245, N'Right', N'', N'Sum', N'####.000', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76482, 43, N'gacnt_pur_sls_ind', N'P or S', 116, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76483, 43, N'gacnt_com_cd', N'Com', 116, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76484, 43, N'Option Month', N'Option Month', 116, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76485, 43, N'Option Year', N'Option Year', 116, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76486, 43, N'Balance', N'Balance', 115, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76487, 43, N'Price', N'Price', 116, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76488, 43, N'Extended Amount', N'Ext Amount', 115, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76489, 43, N'WAP', N'WAP', 115, N'Right', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76490, 43, N'WAB', N'WAB', 115, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76491, 43, N'WAF', N'WAF', 116, N'Right', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76492, 43, N'gacnt_due_rev_dt', N'Due Date', 115, N'Right', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76493, 43, N'gacnt_cnt_no', N'Contract #', 116, N'Right', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76494, 53, N'gacom_desc', N'Com', 25, N'Left', N'', N'', N'', 2, N'', N'', N'gacommst.gacom_desc', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 20, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76495, 53, N'totals', N'Totals', 25, N'Right', N'', N'Sum', N'####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 20, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76496, 44, N'pttic_cus_no', N'Customer#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76497, 44, N'ptcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76498, 44, N'ptcus_first_name', N'Customer Name', 25, N'Left', N'', N'', N' ', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76499, 44, N'pttic_itm_no', N'Item#', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76500, 44, N'pttic_qty_orig', N'Quantity', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76501, 44, N'pttic_tic_no', N'Ticket #', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76502, 44, N'pttic_rev_dt', N'Date', 25, N'Right', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76503, 46, N'ptcus_cus_no', N'Customer Code', 347, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76504, 46, N'ptcus_last_name', N'Last Name', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76505, 46, N'ptcus_first_name', N'First Name', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76506, 46, N'ptcus_ar_ov120', N'Amount', 346, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76507, 47, N'ptitm_itm_no', N'Item #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76508, 47, N'ptitm_desc', N'Item/Product', 417, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76509, 47, N'ptitm_loc_no', N'Loc', 138, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76510, 47, N'ptitm_unit', N'Unit Desc', 138, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76511, 47, N'ptitm_on_hand', N'On Hand Qty', 231, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76512, 47, N'ptitm_last_sale_rev_dt', N'Last Sale Date', 231, N'Right', N'', N'', N'Date', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76513, 48, N'ptstm_itm_no', N'Item #', 287, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76514, 48, N'ptitm_desc', N'Description', 287, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76515, 48, N'Sales', N'Sales', 287, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76516, 48, N'Units', N'Units', 286, N'Left', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76517, 49, N'Location', N'Location', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 59, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76518, 49, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 59, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76519, 64, N'ptitm_itm_no', N'Item Code', 243, N'Left', N'', N'', N'', 2, N'', N'', N'ptitm_itm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76520, 64, N'ptitm_desc', N'Item/Product', 437, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76521, 64, N'ptitm_loc_no', N'Loc', 242, N'Left', N'', N'', N'', 4, N'', N'', N'ptitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76522, 64, N'ptitm_on_hand', N'On Hand Quantity', 242, N'Right', N'', N'', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76523, 51, N'ptcus_last_name', N'Customer Last Name', 282, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76524, 51, N'ptcus_first_name', N'First Name', 282, N'Left', N'', N'', N' ', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76525, 51, N'ptcus_cus_no', N'Customer Code', 280, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76526, 51, N'Sales', N'Sales', 280, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76527, 51, N'Units', N'Units', 280, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76528, 50, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76529, 50, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76530, 50, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76531, 50, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76532, 52, N'ptcus_cus_no', N'Customer#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76533, 52, N'ptcus_last_name', N'Customer Last Name', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76534, 52, N'ptcus_first_name', N'First Name', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76535, 52, N'ptcus_credit_limit', N'Credit Limit', 231, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76536, 52, N'Total Balance', N'Total Balance', 231, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76537, 52, N'overage', N'Overage', 231, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76538, 3, N'ptstm_bill_to_cus', N'Bill To Cus', 94, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76539, 3, N'ptstm_ivc_no', N'Invoice #', 93, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76540, 3, N'ptstm_ship_rev_dt', N'Ship Date', 93, N'Right', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76541, 3, N'ptstm_itm_no', N'Item#', 93, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76542, 3, N'ptstm_loc_no', N'Loc', 93, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76543, 3, N'ptstm_class', N'Class Code', 93, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76544, 3, N'ptstm_un', N'Units Sold', 93, N'Right', N'', N'', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76545, 3, N'ptstm_un_prc', N'Unit Price', 92, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76546, 3, N'ptstm_net', N'Sales', 92, N'Right', N'', N'', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76547, 3, N'ptstm_cgs', N'Costs', 92, N'Right', N'', N'', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76548, 3, N'ptstm_slsmn_id', N'Salesperson', 92, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76549, 3, N'ptstm_pak_desc', N'Package Desc', 92, N'Left', N'', N'', N'', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76550, 3, N'ptstm_un_desc', N'Unit Desc', 92, N'Left', N'', N'', N'', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76551, 3, N'Profit Amount', N'Profit Amount', 92, N'Right', N'', N'', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76552, 3, N'Profit Percent', N'Profit Percentage', 91, N'Right', N'', N'', N'##.###%', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76553, 63, N'ptstm_bill_to_cus', N'Bill To Cus', 347, N'Left', N'', N'', N'', 2, N'', N'', N'ptstm_bill_to_cus', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76554, 63, N'ptstm_ivc_no', N'Invoice #', 347, N'Left', N'', N'', N'', 3, N'', N'', N'ptstm_ivc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76555, 63, N'ptstm_ship_rev_dt', N'Ship Date', 347, N'Left', N'', N'', N'Date', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76556, 63, N'Profit Percent', N'Profit Percentage', 346, N'Right', N'', N'', N'##.###%', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76557, 4, N'ptitm_itm_no', N'Item#', 155, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76558, 4, N'ptitm_desc', N'Item/Product', 278, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76559, 4, N'ptitm_loc_no', N'Loc', 92, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76560, 4, N'ptitm_class', N'Class', 154, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76561, 4, N'ptitm_unit', N'Unit Desc', 92, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76562, 4, N'ptitm_cost1', N'Last Costs', 154, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76563, 4, N'ptitm_avg_cost', N'Average Costs', 154, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76564, 4, N'ptitm_std_cost', N'Standard Costs', 154, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76565, 4, N'ptitm_on_hand', N'Units On Hand', 154, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76566, 61, N'ptitm_itm_no', N'Item Code', 347, N'Left', N'', N'', N'', 2, N'', N'', N'ptitm_itm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76567, 61, N'ptitm_desc', N'Item/Product', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76568, 61, N'ptitm_loc_no', N'Loc', 347, N'Left', N'', N'', N' ', 4, N'', N'', N'ptitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76569, 61, N'ptitm_on_hand', N'On-Hand Quantity', 346, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76570, 9, N'agcus_last_name', N'Customer Last Name', 347, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76571, 9, N'Amount', N'Amount', 346, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76572, 9, N'agcus_first_name', N'Customer First Name', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76573, 9, N'agcus_key', N'Customer #', 347, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76574, 57, N'agitm_no', N'Item#', 347, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76575, 57, N'agitm_desc', N'Item/Product', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76576, 57, N'agitm_loc_no', N'Loc', 347, N'Left', N'', N'', N'', 6, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76577, 57, N'agitm_un_on_hand', N'Units On Hand Qty', 346, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76578, 16, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76579, 16, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76580, 16, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76581, 16, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76582, 19, N'agcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76583, 19, N'agstm_key_loc_no', N'Location', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76584, 19, N'agstm_key_loc_no', N'Location', 0, N'Series2AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76585, 19, N'Sales', N'Sales Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76586, 19, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76587, 20, N'agitm_no', N'Item #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76588, 20, N'agitm_desc', N'Item/Product', 417, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76589, 20, N'agitm_loc_no', N'Loc', 138, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76590, 20, N'agitm_un_desc', N'Unit Desc', 138, N'Left', N'', N'', N' ', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76591, 20, N'agitm_un_on_hand', N'On Hand Qty', 231, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76592, 20, N'agitm_last_sale_rev_dt', N'Last Sale Date', 231, N'Right', N'', N'', N'Date', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76593, 21, N'agord_cus_no', N'Customer#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76594, 21, N'agord_ord_no', N'Order#', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76595, 21, N'agord_loc_no', N'Loc', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76596, 21, N'agord_ord_rev_dt', N'Order Date', 231, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76597, 21, N'agord_itm_no', N'Item #', 231, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76598, 21, N'agord_pkg_sold', N'Packages Sold', 231, N'Left', N'', N'', N'####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76599, 5, N'agcnt_cus_no', N'Customer#', 108, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76600, 5, N'agcus_last_name', N'Customer Last Name', 108, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76601, 5, N'agcus_first_name', N'First Name', 108, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76602, 5, N'agcnt_slsmn_id', N'Salesperson ID', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76603, 5, N'agcnt_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76604, 5, N'agcnt_cnt_no', N'Contract #', 108, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76605, 5, N'agcnt_cnt_rev_dt', N'Contract Date', 105, N'Right', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76606, 5, N'agcnt_due_rev_dt', N'Due Date', 107, N'Right', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76607, 5, N'agcnt_itm_or_cls', N'Item or Class', 107, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76608, 5, N'agcnt_prc_lvl', N'Price Level', 105, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76609, 5, N'agcnt_ppd_yndm', N'Prepaid', 105, N'Left', N'', N'', N'Yes/No', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76610, 5, N'agcnt_un_orig', N'Original Units', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76611, 5, N'agcnt_un_bal', N'Unit Balance', 105, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76612, 60, N'agcnt_cus_no', N'Customer#', 199, N'Left', N'', N'', N'', 3, N'', N'', N'agcnt_cus_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76613, 60, N'agcus_last_name', N'Customer Last Name', 198, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76614, 60, N'agcus_first_name', N'First Name', 198, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76615, 60, N'agcnt_loc_no', N'Loc', 198, N'Left', N'', N'', N'', 7, N'', N'', N'agcnt_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76616, 60, N'agcnt_cnt_no', N'Contract #', 200, N'Left', N'', N'Count', N'', 2, N'', N'', N'agcnt_cnt_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76617, 60, N'agcnt_un_bal', N'Unit Balance', 196, N'Right', N'', N'Sum', N'####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76618, 60, N'agcnt_itm_or_cls', N'Item or Class', 198, N'Left', N'', N'', N'', 14, N'', N'', N'agcnt_itm_or_cls', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76619, 59, N'agitm_desc', N'Item/Product', 427, N'Left', N'', N'Count', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76620, 59, N'agitm_loc_no', N'Loc', 371, N'Left', N'', N'', N'', 4, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76621, 59, N'agitm_un_on_hand', N'On Hand Inventory', 369, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76622, 59, N'agitm_no', N'Item #', 220, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76623, 7, N'agitm_no', N'Item #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76624, 7, N'agitm_desc', N'Item Name', 107, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76625, 7, N'agitm_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76626, 7, N'agitm_un_desc', N'Unit Desc', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76627, 7, N'agitm_un_on_hand', N'On Hand', 107, N'Right', N'', N'Sum', N'####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76628, 7, N'agitm_un_pend_ivcs', N'Pending Invoices', 106, N'Right', N'', N'Sum', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76629, 7, N'agitm_un_on_order', N'On Order', 107, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76630, 7, N'agitm_un_mfg_in_prs', N'Mfg', 107, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76631, 7, N'agitm_un_fert_committed', N'Contracts Committed', 106, N'Right', N'', N'Sum', N'####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76632, 7, N'agitm_un_ord_committed', N'Orders Committed', 106, N'Right', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76633, 7, N'agitm_un_cnt_committed', N'Other Contracts Committed', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76634, 7, N'Available', N'Available', 106, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76635, 7, N'agitm_class', N'Class', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76636, 56, N'agitm_no', N'Item #', 347, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76637, 56, N'agitm_desc', N'Item Name', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76638, 56, N'agitm_loc_no', N'Loc', 347, N'Left', N'', N'', N'', 4, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76639, 56, N'Available', N'Available', 346, N'Left', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76640, 40, N'pxrpt_trans_type', N'Trans Type', 26, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76641, 40, N'pxrpt_trans_rev_dt', N'Trans Date', 65, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76642, 40, N'pxrpt_ord_no', N'Order #', 76, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76643, 40, N'pxrpt_car_name', N'Carrier', 76, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76644, 40, N'pxrpt_cus_name', N'Customer', 76, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76645, 40, N'pxrpt_cus_state', N'Customer State', 76, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76646, 40, N'pxrpt_itm_desc', N'Item/Product', 76, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76647, 40, N'pxrpt_itm_loc_no', N'Loc', 76, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76648, 40, N'pxrpt_vnd_name', N'Vendor', 76, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76649, 40, N'pxrpt_vnd_state', N'Vendor State', 28, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76650, 40, N'pxrpt_pur_gross_un', N'Gross Units Purchased', 75, N'Left', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76651, 40, N'pxrpt_pur_net_un', N'Net Units Purchased', 75, N'Left', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76652, 40, N'pxrpt_pur_fet_amt', N'FET', 75, N'Left', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76653, 40, N'pxrpt_pur_set_amt', N'SET', 75, N'Left', N'', N'Sum', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76654, 40, N'pxrpt_pur_sst_amt', N'SST', 75, N'Left', N'', N'Sum', N'$####.00', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76655, 40, N'pxrpt_pur_lc1_amt', N'LC1', 75, N'Left', N'', N'Sum', N'$####.00', 17, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76656, 40, N'pxrpt_pur_lc2_amt', N'LC2', 75, N'Left', N'', N'Sum', N'$####.00', 18, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76657, 40, N'pxrpt_pur_lc3_amt', N'LC3', 25, N'Left', N'', N'Sum', N'$####.00', 19, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76658, 40, N'pxrpt_pur_lc4_amt', N'LC4', 25, N'Left', N'', N'Sum', N'$####.00', 20, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76659, 40, N'pxrpt_pur_un_received', N'Units Received', 76, N'Left', N'', N'Sum', N'####.00', 21, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76660, 40, N'pxrpt_src_sys', N'Source System', 76, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76661, 40, N'pxrpt_itm_dyed_yn', N'Dyed?', 25, N'Left', N'', N'', N'', 22, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76662, 31, N'pxrpt_trans_type', N'Trans Type', 82, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76663, 31, N'pxrpt_trans_rev_dt', N'Trans Date', 82, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76664, 31, N'pxrpt_src_sys', N'Source System', 79, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76665, 31, N'pxrpt_ord_no', N'Order #', 79, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76666, 31, N'pxrpt_car_name', N'Carrier', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76667, 31, N'pxrpt_cus_name', N'Customer', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76668, 31, N'pxrpt_cus_state', N'Customer State', 27, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76669, 31, N'pxrpt_itm_desc', N'Item/Product', 78, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76670, 31, N'pxrpt_itm_loc_no', N'Loc', 69, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76671, 31, N'pxrpt_vnd_name', N'Vendor ', 76, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76672, 31, N'pxrpt_vnd_state', N'Vendor State', 77, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76673, 31, N'pxrpt_sls_trans_gals', N'Sales Units', 77, N'Left', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76674, 31, N'pxrpt_sls_fet_amt', N'FET', 77, N'Left', N'', N'Sum', N'$####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76675, 31, N'pxrpt_sls_set_amt', N'SET', 77, N'Left', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76676, 31, N'pxrpt_sls_lc1_amt', N'LC1', 76, N'Left', N'', N'Sum', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76677, 31, N'pxrpt_sls_lc2_amt', N'LC2', 76, N'Left', N'', N'Sum', N'$####.00', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76678, 31, N'pxrpt_sls_lc3_amt', N'LC3', 76, N'Left', N'', N'Sum', N'$####.00', 17, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76679, 31, N'pxrpt_sls_lc4_amt', N'LC4', 76, N'Left', N'', N'Sum', N'$####.00', 18, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76680, 31, N'pxrpt_itm_dyed_yn', N'Dyed?', 77, N'Left', N'', N'', N'', 19, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76681, 31, N'pxrpt_cus_acct_stat', N'Cus  Acct Status ', 76, N'Left', N'', N'', N'', 20, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76682, 11, N'apcbk_desc', N'Checkbook Name', 25, N'Left', N'', N'', N' ', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76683, 11, N'apcbk_no', N'Checkbook #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76684, 11, N'apcbk_bal', N'Checkbook Balance', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76685, 14, N'apchk_rev_dt', N'Date', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76686, 14, N'apchk_name', N'Check Name', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76687, 14, N'apchk_chk_amt', N'Check Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76688, 13, N'apivc_ivc_no', N'Invoice#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76689, 13, N'apivc_ivc_rev_dt', N'Invoice Date', 231, N'Right', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76690, 13, N'apivc_vnd_no', N'Vendor #', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76691, 13, N'ssvnd_name', N'Vendor', 231, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76692, 13, N'amounts', N'Amount Due', 231, N'Right', N'', N'Sum', N'$###0.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76693, 13, N'apivc_due_rev_dt', N'Due Date', 231, N'Right', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76694, 12, N'apchk_cbk_no', N'Checkbook #', 139, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76695, 12, N'apchk_rev_dt', N'Date', 139, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76696, 12, N'apchk_vnd_no', N'Vendor #', 139, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76697, 12, N'apchk_name', N'Vendor Name', 139, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76698, 12, N'apchk_chk_amt', N'Check Amount', 139, N'Left', N'', N'Sum', N'$###0.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76699, 12, N'apchk_disc_amt', N'Discount Amount', 139, N'Left', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76700, 12, N'apchk_gl_rev_dt', N'GL Date', 139, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76701, 12, N'apchk_cleared_ind', N'Cleared?', 138, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76702, 12, N'apchk_clear_rev_dt', N'Cleared Date', 138, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76703, 12, N'apchk_src_sys', N'Source System', 138, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76704, 15, N'apivc_ivc_no', N'Invoice #', 127, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76705, 15, N'apivc_ivc_rev_dt', N'Invoice Date', 315, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76706, 15, N'apivc_vnd_no', N'Vendor #', 315, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76707, 15, N'ssvnd_name', N'Vendor Name', 315, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76708, 15, N'amounts', N'Amount', 315, N'Left', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76709, 54, N'CheckDate', N'Check Date', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 39, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76710, 54, N'Amount', N'Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 39, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76723, 26, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76724, 26, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76725, 26, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76726, 34, N'Period', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76727, 34, N'TotalBalance', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76728, 34, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76729, 34, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76730, 35, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 82, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76731, 35, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 82, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76732, 27, N'strAccountId', N'Account ID', 459, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76733, 27, N'strDescription', N'GL Description', 465, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76734, 27, N'Amount', N'Amount', 463, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76735, 36, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 83, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76736, 36, N'Revenue', N'Revenue', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 83, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76737, 29, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76738, 29, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76739, 29, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76740, 39, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 84, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76741, 39, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 84, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76742, 55, N'cftrx_ar_cus_no', N'A/R Customer #', 100, N'Left', N'Filter', N'', N'', 1, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76743, 55, N'cftrx_card_no', N'Card #', 100, N'Left', N'Filter', N'', N'', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76744, 55, N'cfcus_card_desc', N'Card Desc', 100, N'Left', N'Filter', N'', N'', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76745, 55, N'cftrx_rev_dt', N'Date', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76746, 55, N'cftrx_qty', N'Quantity', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76747, 55, N'cftrx_prc', N'Price', 100, N'Left', N'Filter', N'', N'', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76748, 55, N'cftrx_calc_total', N'Calc Total', 100, N'Left', N'Filter', N'', N'', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76749, 55, N'cftrx_ar_itm_no', N'A/R Item #', 100, N'Left', N'Filter', N'', N'', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76750, 55, N'cftrx_ar_itm_loc_no', N'Loc ', 100, N'Left', N'Filter', N'', N'', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76751, 55, N'cftrx_sls_id', N'Salesperson ID', 100, N'Left', N'Filter', N'', N'', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76752, 55, N'cftrx_sell_prc', N'Sell Price', 100, N'Left', N'Filter', N'', N'', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76753, 55, N'cftrx_prc_per_un', N'Price per Unit', 100, N'Left', N'Filter', N'', N'', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76754, 55, N'cftrx_site', N'Site', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76755, 55, N'cftrx_time', N'Time', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76756, 55, N'cftrx_odometer', N'Odometer', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76757, 55, N'cftrx_site_state', N'Site State', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76758, 55, N'cftrx_site_county', N'Site County', 100, N'Left', N'Filter', N'', N'', 17, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76759, 55, N'cftrx_site_city', N'Site City', 100, N'Left', N'Filter', N'', N'', 18, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76760, 55, N'cftrx_selling_host_id', N'Selling Host ID', 100, N'Left', N'Filter', N'', N'', 19, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76761, 55, N'cftrx_buying_host_id', N'Buying Host ID', 100, N'Left', N'Filter', N'', N'', 20, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76762, 55, N'cftrx_po_no', N'PO #', 100, N'Left', N'Filter', N'', N'', 21, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76763, 55, N'cftrx_ar_ivc_no', N'A/R Invoice #', 100, N'Left', N'Filter', N'', N'', 22, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76764, 55, N'cftrx_calc_fet_amt', N'Calc FET Amount', 100, N'Left', N'Filter', N'', N'', 23, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76765, 55, N'cftrx_calc_set_amt', N'Calc SET Amount', 100, N'Left', N'Filter', N'', N'', 24, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76766, 55, N'cftrx_calc_sst_amt', N'Calc SST Amount', 100, N'Left', N'Filter', N'', N'', 25, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76767, 55, N'cftrx_tax_cls_id', N'Tax Class ID', 100, N'Left', N'Filter', N'', N'', 26, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76768, 55, N'cftrx_ivc_prtd_yn', N'Inv Printed ?', 100, N'Left', N'Filter', N'', N'', 27, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76769, 55, N'cftrx_vehl_no', N'Vehicle #', 100, N'Left', N'Filter', N'', N'', 28, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76770, 55, N'cftrx_calc_net_sell_prc', N'Calc Net Sell', 100, N'Left', N'Filter', N'', N'', 29, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76771, 55, N'cftrx_pump_no', N'Pump No', 100, N'Left', N'Filter', N'', N'', 30, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76772, 6, N'glhst_acct1_8', N'GL Acct', 125, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76773, 6, N'glhst_acct9_16', N'Profit Center', 122, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76774, 6, N'glhst_ref', N'Reference', 119, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76775, 6, N'glhst_period', N'Period', 81, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76776, 6, N'glhst_trans_dt', N'Transaction Date', 117, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76777, 6, N'glhst_src_id', N'Source ID', 117, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76778, 6, N'glhst_src_seq', N'Source Sequence', 118, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76779, 6, N'glhst_dr_cr_ind', N'Credit/Debit', 117, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76780, 6, N'glhst_jrnl_no', N'Journal #', 117, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76781, 6, N'glhst_doc', N'Document #', 117, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76782, 6, N'Amount', N'Amount', 120, N'Left', N'', N'Sum', N'$####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76783, 6, N'glhst_units', N'Units', 117, N'Left', N'', N'', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76784, 65, N'glhst_acct1_8', N'GL Acct', 347, N'Left', N'', N'', N'', 2, N'', N'', N'glhstmst.glhst_acct1_8', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76785, 65, N'glhst_acct9_16', N'Profit Center', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76786, 65, N'glact_desc', N'GL Desc', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76787, 65, N'Amount', N'Amount', 346, N'Left', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76788, 3364, N'glact_acct1_8', N'GL Acct', 463, N'Left', N'', N'', N'', 2, N'', N'', N'glhst_acct1_8', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76789, 3364, N'glact_acct9_16', N'Profit Center', 462, N'Left', N'', N'', N'', 3, N'', N'', N'glhst_acct9_16', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76790, 3364, N'glact_desc', N'Description', 462, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76791, 69, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 31, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76792, 69, N'Amount', N'Amount', 693, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 31, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76793, 70, N'glact_desc', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 32, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76794, 70, N'Amount', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 32, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76795, 71, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 33, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76796, 71, N'Amount', N'Amount', 693, N'Left', N'', N' ', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 33, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76797, 73, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 34, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76798, 73, N'Amount', N'Amount', 693, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 34, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76799, 76, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76800, 76, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76801, 76, N'Amount', N'Revenue Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76802, 76, N'Amount', N'Expense Amount', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76803, 74, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76804, 74, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76805, 74, N'Amount', N'Assets Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76806, 74, N'Amount', N'Liabilities Amount', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76807, 58, N'agstm_ivc_no', N'Invoice #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'agstm_ivc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76808, 58, N'agstm_ship_rev_dt', N'Ship Date', 25, N'Right', N'', N'', N'Date', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76809, 58, N'Profit Percent', N'Profit Percent', 25, N'Right', N'', N'', N'##.###%', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76810, 39, N'', N'', 0, N'Series2AxisX', NULL, NULL, N'', 2, NULL, NULL, NULL, 0, N'Chart', N'Series2AxisX', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 84, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76811, 39, N'', N'', 0, N'Series2AxisY', NULL, NULL, N'', 2, NULL, NULL, NULL, 0, N'Chart', N'Series2AxisY', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 84, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76812, 32, N'gacnt_pur_sls_ind', N'P/S', 107, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76813, 32, N'gacnt_cus_no', N'Customer #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76814, 32, N'agcus_last_name', N'Last Name', 107, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76815, 32, N'agcus_first_name', N'First Name', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76816, 32, N'gacnt_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76817, 32, N'gacnt_com_cd', N'Com', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76818, 32, N'gacnt_cnt_no', N'Contact #', 106, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76819, 32, N'gacnt_seq_no', N'Seq', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76820, 32, N'gacnt_mkt_zone', N'Market Zone', 107, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76821, 32, N'gacnt_beg_ship_rev_dt', N'Beg Ship Date', 106, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76822, 32, N'gacnt_due_rev_dt', N'Due Date', 106, N'Right', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76823, 32, N'gacnt_pbhcu_ind', N'PBHU', 107, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76824, 32, N'gacnt_un_bal', N'Unit Balance', 106, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76825, 2, N'gacom_desc', N'Com', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76826, 2, N'gapos_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76827, 2, N'gapos_in_house', N'In House', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76828, 2, N'gapos_offsite', N'Offsite', 25, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76829, 2, N'gapos_sls_in_transit', N'In Transit', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76830, 45, N'Current', N'Current', 25, N'Center', N'', N'', N'$####.00', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76831, 45, N'31-60 Days', N'31-60 Days', 25, N'Center', N'', N'', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76832, 45, N'61-90 Days', N'61-90 Days', 25, N'Center', N'', N'', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76833, 45, N'91-120 Days', N'91-120 Days', 25, N'Center', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76834, 45, N'Over 120 Days', N'Over 120 Days', 25, N'Center', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76835, 10, N'Future', N'Future', 25, N'Left', N'', N'', N'$####.00', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76836, 10, N'Current', N'Current', 25, N'Left', N'', N'', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76837, 10, N'30days', N'31-60 Days', 25, N'Left', N'', N'', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76838, 10, N'60days', N'61-90 Days', 25, N'Left', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76839, 10, N'90days', N'91-120 Days', 25, N'Left', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76840, 10, N'120days', N'Over 120 Days', 25, N'Left', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76841, 95, N'agcus_key', N'Customer #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76842, 95, N'agcus_last_name', N'Customer Last Name', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76843, 95, N'agcus_first_name', N'First Name', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76844, 95, N'agcus_cred_limit', N'Credit Limit', 231, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76845, 95, N'Total Balance', N'Total Balance', 231, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76846, 95, N'Overage', N'Overage', 231, N'Right', N'', N'Sum', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76847, 1, N'agitm_no', N'Item#', 174, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76848, 1, N'agitm_desc', N'Item/Product', 174, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76849, 1, N'agitm_pak_desc', N'Package', 174, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76850, 1, N'agitm_class', N'Class', 173, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76851, 1, N'agitm_loc_no', N'Loc', 173, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76852, 1, N'agitm_last_un_cost', N'Last Unit Cost', 173, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76853, 1, N'agitm_avg_un_cost', N'Average Unit Cost', 173, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76854, 1, N'agitm_un_on_hand', N'Units On Hand Qty', 173, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76855, 18, N'agstm_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76856, 18, N'agitm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76857, 18, N'Sales', N'Sales', 25, N'Right', N'', N'Sum', N'$###0.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76858, 18, N'Units', N'Units', 25, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76859, 17, N'Customer Last Name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76860, 17, N'First Name', N'First Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76861, 17, N'Customer Code', N'Customer Code', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76862, 17, N'Sales', N'Sales', 25, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76863, 17, N'Units', N'Units', 25, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76864, 25, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76865, 25, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76866, 25, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76867, 22, N'intGLDetailId', N'GL Detail ID', 100, N'Left', N'Filter', N'', N'', 1, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76868, 22, N'dtmDate', N'Date', 100, N'Left', N'Filter', N'', N'Date', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76869, 22, N'strBatchId', N'Batch ', 100, N'Left', N'Filter', N'', N'', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76870, 22, N'intAccountId', N'Account ID', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76871, 22, N'strAccountGroup', N'Account Group', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76872, 22, N'dblDebit', N'Debit Amount', 100, N'Left', N'Filter', N'', N'$####.00', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76873, 22, N'dblCredit', N'Credit Amount', 100, N'Left', N'Filter', N'', N'$####.00', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76874, 22, N'dblDebitUnit', N'Debit Unit', 100, N'Left', N'Filter', N'', N'', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76875, 22, N'dblCreditUnit', N'Credit Unit', 100, N'Left', N'Filter', N'', N'', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76876, 22, N'strDescription', N'GL Description', 100, N'Left', N'Filter', N'', N'', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76877, 22, N'strCode', N'Code', 100, N'Left', N'Filter', N'', N'', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76878, 22, N'strTransactionId', N'Trans ID', 100, N'Left', N'Filter', N'', N'', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76879, 22, N'strReference', N'Reference', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76880, 22, N'strJobId', N'Job ID', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76881, 22, N'intCurrencyId', N'Currency ID', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76882, 22, N'dblExchangeRate', N'Exchange Rate', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76883, 22, N'dtmDateEntered', N'Date Entered', 100, N'Left', N'Filter', N'', N'', 17, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76884, 22, N'dtmTransactionDate', N'Trans Date', 100, N'Left', N'Filter', N'', N'', 18, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76885, 22, N'strProductId', N'Product ID', 100, N'Left', N'Filter', N'', N'', 19, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76886, 22, N'strWarehouseId', N'Warehouse ID', 100, N'Left', N'Filter', N'', N'', 20, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76887, 22, N'strNum', N'Num', 100, N'Left', N'Filter', N'', N'', 21, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76888, 22, N'strCompanyName', N'Company Name', 100, N'Left', N'Filter', N'', N'', 22, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76889, 22, N'strBillInvoiceNumber', N'Bill Invoice #', 100, N'Left', N'Filter', N'', N'', 23, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76890, 22, N'strJournalLineDescription', N'Journal Line Desc', 100, N'Left', N'Filter', N'', N'', 24, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76891, 22, N'ysnIsUnposted', N'Unposted?', 100, N'Left', N'Filter', N'', N'', 25, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76892, 22, N'intConcurrencyId', N'Concurrency ID', 100, N'Left', N'Filter', N'', N'', 26, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76893, 22, N'intUserID', N'User ID', 100, N'Left', N'Filter', N'', N'', 27, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76894, 22, N'strTransactionForm', N'Trans Form', 100, N'Left', N'Filter', N'', N'', 28, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76895, 22, N'strModuleName', N'Module Name', 100, N'Left', N'Filter', N'', N'', 29, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76896, 22, N'strUOMCode', N'UOM Code', 100, N'Left', N'Filter', N'', N'', 30, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76897, 22, N'intAccountId1', N'Account ID 1', 100, N'Left', N'Filter', N'', N'', 31, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76898, 22, N'strAccountId', N'Account ID', 100, N'Left', N'Filter', N'', N'', 32, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76899, 22, N'strDescription1', N'Description 1', 100, N'Left', N'Filter', N'', N'', 33, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76900, 22, N'strNote', N'Note', 100, N'Left', N'Filter', N'', N'', 34, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76901, 22, N'intAccountGroupId', N'Account Group ID', 100, N'Left', N'Filter', N'', N'', 35, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76902, 22, N'dblOpeningBalance', N'Opening Balance', 100, N'Left', N'Filter', N'', N'', 36, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76903, 22, N'ysnIsUsed', N'Is Used?', 100, N'Left', N'Filter', N'', N'', 37, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76904, 22, N'strComments', N'Comments', 100, N'Left', N'Filter', N'', N'', 40, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76905, 22, N'ysnActive', N'Active', 100, N'Left', N'Filter', N'', N'', 41, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76906, 22, N'ysnSystem', N'System', 100, N'Left', N'Filter', N'', N'', 42, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76907, 22, N'strCashFlow', N'Cash Flow', 100, N'Left', N'Filter', N'', N'', 43, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76908, 22, N'intAccountGroupId1', N'Account Group ID 1', 100, N'Left', N'Filter', N'', N'', 44, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76909, 22, N'strAccountGroup1', N'Account Group 1', 100, N'Left', N'Filter', N'', N'', 45, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76910, 22, N'strAccountType', N'Account Type', 100, N'Left', N'Filter', N'', N'', 46, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76911, 22, N'intParentGroupId', N'Parent Group ID', 100, N'Left', N'Filter', N'', N'', 47, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76912, 22, N'intGroup', N'Group', 100, N'Left', N'Filter', N'', N'', 48, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76913, 22, N'intSort', N'Sort', 100, N'Left', N'Filter', N'', N'', 49, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76914, 22, N'intConcurrencyId2', N'Concurrency ID 2', 100, N'Left', N'Filter', N'', N'', 50, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76915, 22, N'intAccountBegin', N'Account Begin', 100, N'Left', N'Filter', N'', N'', 51, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76916, 22, N'intAccountEnd', N'Account End', 100, N'Left', N'Filter', N'', N'', 52, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76917, 22, N'strAccountGroupNamespace', N'Account Group Name', 100, N'Left', N'Filter', N'', N'', 53, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76918, 28, N'glije_acct_no', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76919, 28, N'glije_date', N'Date', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76920, 28, N'glije_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76921, 28, N'glije_ref', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76922, 28, N'glije_doc', N'Document #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76923, 28, N'glije_amt', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76924, 30, N'glije_acct_no', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76925, 30, N'glije_date', N'Date', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76926, 30, N'glije_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76927, 30, N'glije_ref', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76928, 30, N'glije_doc', N'Document #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76929, 30, N'glije_amt', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76930, 67, N'gaaudpay_pmt_audit_no', N'EOD Audit Number', 75, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76931, 67, N'gaaud_pur_sls_ind', N'Sales', 75, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76932, 67, N'gaaud_trans_type', N'Transaction Type', 75, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76933, 67, N'gaaud_in_type', N'', 75, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76934, 67, N'gaaud_key_filler1', N'Key Info', 75, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76935, 67, N'gaaudpay_pmt_rev_dt', N'Payment Date', 75, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76936, 67, N'gaaudpay_chk_no', N'Check Number', 75, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76937, 67, N'gaaudpay_stl_amt', N'Payment Amt', 75, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76938, 67, N'gaaudstl_ivc_no', N'Advance Invoice Number', 75, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76939, 67, N'gaaudpay_cus_ref_no', N'', 74, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76940, 67, N'gaaudstl_stl_amt', N'Advance Payment Amt', 75, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76941, 68, N'sthss_store_name', N'Store Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 89, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76942, 68, N'FormattedDate', N'Date', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 89, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76943, 68, N'sthss_tot_cash_overshort', N'Over / Short Amount', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 89, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76944, 72, N'Store Name', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 91, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76945, 72, N'Date', N'', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 91, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76946, 72, N'Total Customers', N'', 25, N'Right', N'', N'Sum', N'####', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 91, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76947, 75, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 92, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76948, 75, N'sthss_rev_dt', N'Date', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 92, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76949, 75, N'sthss_key_deptno', N'Dept. #', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 92, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76950, 75, N'sthss_key_desc', N'Description', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 92, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76951, 75, N'sthss_key_total_sales', N'Total Sales', 25, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 92, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76952, 85, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76953, 85, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76954, 85, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76955, 85, N'Retail Price', N'', 25, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76956, 85, N'Last Price', N'', 25, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76957, 85, N'On-Hand Qty', N'', 25, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76958, 85, N'On Order Qty', N'', 25, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 93, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76959, 77, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 94, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76960, 77, N'sthss_pmp_id', N'Fuel Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 94, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76961, 77, N'c', N'Fuel Margins', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 94, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76962, 78, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 95, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76963, 78, N'sthss_pmp_desc', N'Fuel Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 95, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76964, 78, N'c', N'Sales Amount', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 95, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76965, 79, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 96, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76966, 79, N'sthss_pmp_id', N'Fuel Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 96, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76967, 79, N'c', N'Gallons', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 96, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76968, 81, N'Store Name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 97, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76969, 81, N'Dept #', N'Department', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 97, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76970, 81, N'Gross Profit', N'Gross Profit', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 97, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76971, 86, N'UPC #', N'', 100, N'Left', N'Filter', N'', N'', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76972, 86, N'Trans Dt', N'', 100, N'Left', N'Filter', N'', N'Date', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76973, 86, N'Purchase / Sale', N'', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76974, 86, N'Store', N'', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76975, 86, N'Inv #', N'', 100, N'Left', N'Filter', N'', N'', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76976, 86, N'Department', N'', 100, N'Left', N'Filter', N'', N'', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76977, 86, N'Purchase Qty', N'', 100, N'Left', N'Filter', N'', N'####.00', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76978, 86, N'Units Cost', N'', 100, N'Left', N'Filter', N'', N'$####.00', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76979, 86, N'Retail Price', N'', 100, N'Left', N'Filter', N'', N'$####.00', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76980, 86, N'Qty Sold', N'', 100, N'Left', N'Filter', N'', N'####.00', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76981, 86, N'Amount Sold', N'', 100, N'Left', N'Filter', N'', N'$####.00', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76982, 86, N'Month', N'', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76983, 86, N'UPC Desc', N'', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76984, 86, N'Family', N'', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76985, 86, N'Class', N'', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 98, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76986, 82, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 99, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76987, 82, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 99, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76988, 82, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 99, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76989, 82, N'Min Qty', N'', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 99, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76990, 82, N'On-Hand Qty', N'', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 99, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76991, 83, N'Store', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 100, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76992, 83, N'Date', N'', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 100, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76993, 83, N'No Sale Transactions', N'', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 100, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76994, 84, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76995, 84, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76996, 84, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76997, 84, N'Start Date', N'', 25, N'Right', N'', N'', N'Date', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76998, 84, N'End Date', N'', 25, N'Right', N'', N'', N'Date', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (76999, 84, N'Sale Price', N'', 25, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 101, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77000, 90, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77001, 90, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77002, 90, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77003, 90, N'Vendor ID', N'', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77004, 90, N'Dept #', N'', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77005, 90, N'Family', N'', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77006, 90, N'Class', N'', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77007, 90, N'Case Cost', N'', 25, N'Right', N'', N'Sum', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77008, 90, N'Retail Price', N'', 25, N'Right', N'', N'Sum', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77009, 90, N'Last Price', N'', 25, N'Right', N'', N'Sum', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77010, 90, N'Min Qty', N'', 25, N'Right', N'', N'Sum', N'####', 12, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77011, 90, N'Sug Qty', N'', 25, N'Right', N'', N'Sum', N'####', 13, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77012, 90, N'Min Order Qty', N'', 25, N'Right', N'', N'Sum', N'####', 14, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77013, 90, N'On-Hand Qty', N'', 25, N'Right', N'', N'Sum', N'####', 15, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77014, 90, N'On Order Qty', N'', 25, N'Right', N'', N'Sum', N'####', 16, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77015, 90, N'Qty Sold', N'', 25, N'Right', N'', N'Sum', N'####', 17, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 102, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77016, 87, N'Store', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 103, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77017, 87, N'Date', N'', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 103, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77018, 87, N'Refund Amount', N'', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 103, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77019, 88, N'store name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'sthss_store_name', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 2, 104, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77020, 88, N'dept #', N'Dept. #', 25, N'Left', N'', N'', N'', 3, N'', N'', N'sthss_key_deptno', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 2, 104, N'System.Int16')
 
INSERT INTO #TempCannedPanelColumn VALUES (77021, 88, N'total sales', N'Total Sales', 25, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 2, 104, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77022, 89, N'stphy_store_name', N'Store Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 105, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77023, 89, N'stphy_rev_dt', N'Date', 25, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 105, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77024, 89, N'stphy_shift_no', N'Shift #', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 105, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77025, 89, N'stphy_itm_desc', N'Item', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 105, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77026, 89, N'stphy_diff_qty', N'Diff Qty', 25, N'Left', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'KIM', 6, 0, 0, 0, 0, N'', 0, 1, 105, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77027, 62, N'Store', N'Store', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 90, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77028, 62, N'Cash Over / Short Amount', N'Over / Short Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 90, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77029, 91, N'Trans Dt', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 109, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77030, 91, N'Purchase Qty', N'Purchase Qty', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 109, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77031, 92, N'Trans Dt', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 106, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77032, 92, N'Amount Sold', N'Amount Sold', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 106, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77033, 93, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 107, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77034, 93, N'Total Sales', N'Total Sales', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 107, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77035, 94, N'strPanelName', N'', 434, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 108, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77036, 94, N'strUserName', N'', 434, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 108, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77037, 94, N'strFullName', N'', 433, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 108, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (77038, 96, N'strAccountId', N'Account ID', 200, N'Left', NULL, NULL, NULL, 1, NULL, NULL, N'', 0, N'Grid', NULL, N'TRENNER', 0, 0, 0, 0, 0, NULL, 0, 1, 112, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77039, 96, N'strDescription', N'Description', 200, N'Left', NULL, NULL, NULL, 2, NULL, NULL, N'', 0, N'Grid', NULL, N'TRENNER', 0, 0, 0, 0, 0, NULL, 0, 1, 112, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77040, 97, N'Employee', N'', 45, N'Left', NULL, NULL, NULL, 1, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77041, 97, N'Vendor', N'', 91, N'Left', NULL, NULL, NULL, 2, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77042, 97, N'GLDate', N'', 91, N'Left', NULL, NULL, N'Date', 3, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (77043, 97, N'BillDate', N'', 91, N'Left', NULL, NULL, N'Date', 4, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 111, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (77044, 97, N'DueDate', N'', 91, N'Left', NULL, NULL, N'Date', 5, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (77045, 97, N'InvoiceNumber', N'', 115, N'Left', NULL, NULL, NULL, 6, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77046, 97, N'ItemTotal', N'', 105, N'Right', NULL, N'Sum', N'$####.00', 7, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77047, 97, N'Item', N'', 35, N'Left', NULL, NULL, NULL, 8, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77048, 97, N'Account', N'', 114, N'Left', NULL, NULL, NULL, 9, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77049, 97, N'AccountDesc', N'', 114, N'Left', NULL, NULL, NULL, 10, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 111, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77050, 97, N'Due', N'', 100, N'Left', NULL, NULL, N'$####.00', 11, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 111, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77051, 139, N'Cust Number', N'', 100, N'Left', NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77052, 139, N'Cust Name', N'', 100, N'Left', NULL, NULL, NULL, 2, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77053, 139, N'Site Number', N'', 100, N'Left', NULL, NULL, NULL, 3, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.Int32')
 
INSERT INTO #TempCannedPanelColumn VALUES (77054, 139, N'Item', N'', 100, N'Left', NULL, NULL, NULL, 4, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77055, 139, N'Date Marked As For Review', N'', 100, N'Left', NULL, NULL, NULL, 5, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (77056, 139, N'Gallons', N'', 100, N'Left', NULL, NULL, NULL, 6, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77057, 139, N'Transaction Type', N'', 100, N'Left', NULL, NULL, NULL, 7, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 113, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77058, 4395, N'vwcus_last_name', N'Last Name', 100, N'Left', NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77059, 4395, N'vwcus_first_name', N'First Name', 100, N'Left', NULL, NULL, NULL, 2, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77060, 4395, N'strTankTownship', N'Township', 100, N'Left', NULL, NULL, NULL, 3, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77061, 4395, N'strSiteAddress', N'Address', 100, N'Left', NULL, NULL, NULL, 4, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77062, 4395, N'strCity', N'City', 100, N'Left', NULL, NULL, NULL, 5, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77063, 4395, N'strState', N'State', 50, N'Left', NULL, NULL, NULL, 6, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77064, 4395, N'strBulkPlant', N'Bulk Plant', 50, N'Left', NULL, NULL, NULL, 7, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77065, 4395, N'dblPurchasePrice', N'Purchase Price', 50, N'Left', NULL, NULL, NULL, 8, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77066, 4395, N'dtmPurchaseDate', N'Purchase Date', 50, N'Left', NULL, NULL, N'Date', 9, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (77067, 4395, N'dtmManufacturedDate', N'Manufactured Date', 50, N'Left', NULL, NULL, N'Date', 10, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (77068, 4395, N'strManufacturerID', N'Manufactured ID', 50, N'Left', NULL, NULL, NULL, 11, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77069, 4395, N'dblTankCapacity', N'Tank Capacity', 100, N'Left', NULL, NULL, NULL, 12, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77070, 4395, N'strSerialNumber', N'Serial Number', 75, N'Left', NULL, NULL, NULL, 13, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77071, 4395, N'strInventoryStatusType', N'Inventory Status Type', 50, N'Left', NULL, NULL, NULL, 14, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77072, 4395, N'strOwnership', N'Ownership', 75, N'Left', NULL, NULL, NULL, 15, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77073, 4395, N'strTankType', N'Tank Type', 75, N'Left', NULL, NULL, NULL, 16, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77074, 4395, N'strDeviceType', N'Device Type', 75, N'Left', NULL, NULL, NULL, 17, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 114, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77075, 4396, N'agstm_bill_to_cus', N'Bill To Customer', 25, N'Left', NULL, N'', N'', 1, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77076, 4396, N'agstm_ivc_no', N'Invoice #', 25, N'Left', NULL, N'', N'', 2, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77077, 4396, N'agstm_ship_rev_dt', N'Ship Date', 25, N'Left', NULL, N'', N'', 3, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Int32')
 
INSERT INTO #TempCannedPanelColumn VALUES (77078, 4396, N'agstm_itm_no', N'Item #', 25, N'Left', NULL, N'', N'', 4, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77079, 4396, N'agstm_loc_no', N'Loc', 25, N'Left', NULL, N'', N'', 5, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77080, 4396, N'agstm_class', N'Class Code', 25, N'Left', NULL, N'', N'', 6, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77081, 4396, N'agstm_un', N'Units Sold', 25, N'Left', NULL, N'', N'', 7, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77082, 4396, N'agstm_un_prc', N'Unit Price', 25, N'Left', NULL, N'', N'', 8, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77083, 4396, N'agstm_sls', N'Sales Amount', 25, N'Left', NULL, N'', N'', 9, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77084, 4396, N'agstm_un_cost', N'Unit Cost', 25, N'Left', NULL, N'', N'', 10, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77085, 4396, N'agstm_cgs', N'Costs Amount', 25, N'Left', NULL, N'', N'', 11, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77086, 4396, N'agstm_slsmn_id', N'Salesperson', 25, N'Left', NULL, N'', N'', 12, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77087, 4396, N'agstm_pak_desc', N'Package Desc', 25, N'Left', NULL, N'', N'', 13, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77088, 4396, N'agstm_un_desc', N'Unit Desc', 25, N'Left', NULL, N'', N'', 14, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77089, 4396, N'unit margins', N'Unit Margins', 25, N'Left', NULL, N'', N'', 15, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77090, 4396, N'Profit Amount', N'Profit Amount', 25, N'Left', NULL, N'', N'', 16, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77091, 4396, N'Profit Percent', N'Profit Percent', 25, N'Left', NULL, N'', N'', 17, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 115, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77092, 1260, N'Cus #', N'', 25, N'Left', NULL, N'', N'', 1, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77093, 1260, N'Last Name', N'', 25, N'Left', NULL, N'', N'', 2, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77094, 1260, N'First Name', N'', 25, N'Left', NULL, N'', N'', 3, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77095, 1260, N'Lease Number', N'', 25, N'Left', NULL, N'', N'', 4, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77096, 1260, N'Tank Serial #', N'', 25, N'Left', NULL, N'', N'', 5, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77097, 1260, N'Tank Capacity', N'', 25, N'Left', NULL, N'', N'', 6, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77098, 1260, N'Lease Status', N'', 25, N'Left', NULL, N'', N'', 7, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77099, 1260, N'Lease Code Desc', N'', 25, N'Left', NULL, N'', N'', 8, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77100, 1260, N'Lease Amount', N'', 25, N'Left', NULL, N'', N'$####.00', 9, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (77101, 1260, N'Lease Billing Month', N'', 25, N'Left', NULL, N'', N'', 10, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.Int32')
 
INSERT INTO #TempCannedPanelColumn VALUES (77102, 1260, N'Lease Frequency', N'', 25, N'Left', NULL, N'', N'', 11, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77103, 1260, N'Lease Start Date', N'', 25, N'Left', NULL, N'', N'Date', 12, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (77104, 1260, N'Last Lease Billing Date', N'', 25, N'Left', NULL, N'', N'Date', 13, NULL, NULL, N'', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 116, N'System.DateTime')
 
INSERT INTO #TempCannedPanelColumn VALUES (77105, 4379, N'name', N'', 75, N'Left', NULL, NULL, NULL, 1, NULL, NULL, N'sys.tables.name', 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 2, 117, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77106, 4378, N'name', N'', 116, N'Left', NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 118, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77107, 4378, N'COLUMN NAME', N'', 116, N'Left', NULL, NULL, NULL, 2, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 118, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77108, 4378, N'DATA TYPE', N'', 116, N'Left', NULL, NULL, NULL, 3, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 118, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77109, 4378, N'DESCRIPTION', N'', 116, N'Left', NULL, NULL, NULL, 4, NULL, NULL, NULL, 0, N'Grid', NULL, N'KIM', 6, 0, 0, 0, 0, NULL, 0, 1, 118, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (77147, 88, N'stdpt_desc', N'Department Name', 75, N'Left', NULL, NULL, NULL, 4, NULL, NULL, NULL, 0, N'Grid', NULL, N'AGADMIN', 2, 0, 0, 0, 0, NULL, 0, 1, 104, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (78110, 15560, N'store name', N'Store', 75, N'Left', NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, N'Grid', NULL, N'AGADMIN', 0, 0, 0, 0, 0, NULL, 0, 1, 130, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (78111, 15560, N'dept #', N'Dept #', 75, N'Left', NULL, NULL, NULL, 2, NULL, NULL, NULL, 0, N'Grid', NULL, N'AGADMIN', 0, 0, 0, 0, 0, NULL, 0, 1, 130, N'System.Int16')
 
INSERT INTO #TempCannedPanelColumn VALUES (78112, 15560, N'total sales', N'Total Sales', 75, N'Left', NULL, NULL, N'$####.00', 6, NULL, NULL, NULL, 0, N'Grid', NULL, N'AGADMIN', 0, 0, 0, 0, 0, NULL, 0, 2, 130, N'System.Decimal')
 
INSERT INTO #TempCannedPanelColumn VALUES (78113, 15560, N'stdpt_desc', N'Department Name', 75, N'Left', NULL, NULL, NULL, 3, NULL, NULL, NULL, 0, N'Grid', NULL, N'AGADMIN', 0, 0, 0, 0, 0, NULL, 0, 1, 130, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (78128, 15560, N'sthss_rec_type', N'Type', 75, N'Left', NULL, NULL, NULL, 4, NULL, NULL, NULL, 0, N'Grid', NULL, N'AGADMIN', 2, 0, 0, 0, 0, NULL, 0, 1, 130, N'System.String')
 
INSERT INTO #TempCannedPanelColumn VALUES (78129, 15560, N'sthss_rev_dt', N'Date', 75, N'Left', NULL, NULL, N'Date', 5, NULL, NULL, NULL, 0, N'Grid', NULL, N'AGADMIN', 2, 0, 0, 0, 0, NULL, 0, 1, 130, N'System.Int32')
 
INSERT INTO #TempCannedPanelColumn VALUES (78130, 62, N'', N'', 0, N'Series2AxisX', NULL, NULL, N'', 2, NULL, NULL, NULL, 0, N'Chart', N'Series2AxisX', NULL, 2, 0, 0, 0, 0, N'', 0, 1, 90, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (78131, 62, N'', N'', 0, N'Series2AxisY', NULL, NULL, N'', 2, NULL, NULL, NULL, 0, N'Chart', N'Series2AxisY', NULL, 2, 0, 0, 0, 0, N'', 0, 1, 90, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79164, 24, N'strDescription', N'Description', 183, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79165, 24, N'dblDebit', N'Debit ', 183, N'Left', N'', N'Sum', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79166, 24, N'dblCredit', N'Credit', 183, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79167, 24, N'Balance', N'Balance', 183, N'Left', N'', N'Sum', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79168, 24, N'strAccountId', N'AccountID', 183, N'Left', N'', N'Count', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79169, 24, N'dtmDate', N'Date', 183, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79170, 24, N'strTransactionId', N'Document', 183, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79171, 24, N'strReference', N'Reference', 183, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79172, 24, N'strAccountGroup', N'Account Group', 183, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 75, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79185, 23, N'strAccountId', N'Account ID', 549, N'Left', N'', N'Count', N'', 2, N'', N'', N'strAccountId', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 76, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79186, 23, N'strDescription', N'Description', 549, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 76, NULL)
 
INSERT INTO #TempCannedPanelColumn VALUES (79187, 23, N'Balance', N'Balance', 549, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 0, 76, NULL)

--Payroll
INSERT INTO #TempCannedPanelColumn VALUES (79188, 15561, N'EmployeeName',	N'Employee Name',	75, N'Left', N'', N'',		N'',		2,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 131, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79189, 15561, N'CheckNo',		N'Paycheck ID',		75, N'Left', N'', N'',		N'',		3,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 131, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79190, 15561, N'PayDate',		N'Pay Date',		75, N'Left', N'', N'',		N'',		4,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 131, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79191, 15561, N'CheckTotal',		N'Gross Pay',		75, N'Left', N'', N'Sum',	N'',		5,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 131, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79192, 15561, N'CheckNet',		N'Net Pay',			75, N'Left', N'', N'Sum',	N'',		6,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 131, NULL)

INSERT INTO #TempCannedPanelColumn VALUES (79193, 15562, N'EmployeeName',	N'Employee Name',	75, N'Left', N'', N'',		N'',		2,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 132, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79194, 15562, N'CheckNo',		N'Paycheck ID',		75, N'Left', N'', N'Count',	N'',		3,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 132, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79195, 15562, N'PayDate',		N'Pay Date',		75, N'Left', N'', N'',		N'',		4,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 132, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79196, 15562, N'CheckTotal',		N'Gross Pay',		75, N'Left', N'', N'Sum',	N'',		5,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 132, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79197, 15562, N'CheckNet',		N'Net Pay',			75, N'Left', N'', N'Sum',	N'',		6,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 132, NULL)

INSERT INTO #TempCannedPanelColumn VALUES (79198, 15563, N'EmployeeName',	N'Employee Name',	75, N'Left', N'', N'',		N'',		2,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 133, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79199, 15563, N'CheckNo',		N'Paycheck ID',		75, N'Left', N'', N'Count',	N'',		3,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 133, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79200, 15563, N'PayDate',		N'Pay Date',		75, N'Left', N'', N'',		N'',		4,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 133, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79201, 15563, N'CheckTotal',		N'Gross Pay',		75, N'Left', N'', N'Sum',	N'',		5,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 133, NULL)
INSERT INTO #TempCannedPanelColumn VALUES (79202, 15563, N'CheckNet',		N'Net Pay',			75, N'Left', N'', N'Sum',	N'',		6,	N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 1, 0, 0, 0, 0, N'', 0, 1, 133, NULL)


--End Payroll

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