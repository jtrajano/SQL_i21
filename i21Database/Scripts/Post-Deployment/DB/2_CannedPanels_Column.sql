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


INSERT INTO #TempCannedPanelColumn VALUES (1417, 41, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16)

INSERT INTO #TempCannedPanelColumn VALUES (1418, 41, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16)

INSERT INTO #TempCannedPanelColumn VALUES (1419, 41, N'units', N'Purchased Units', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16)

INSERT INTO #TempCannedPanelColumn VALUES (1420, 41, N'units', N'Sales Units', 0, N'Series2AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 16)

INSERT INTO #TempCannedPanelColumn VALUES (1421, 37, N'gahdg_com_cd', N'Com', 107, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1422, 37, N'gahdg_broker_no', N'Broker #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1423, 37, N'gahdg_rev_dt', N'Date', 107, N'Right', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1424, 37, N'gahdg_ref', N'Ref#', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1425, 37, N'gahdg_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1426, 37, N'gahdg_bot_prc', N'BOT Price', 107, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1427, 37, N'gahdg_bot_basis', N'BOT Basis', 106, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1428, 37, N'gahdg_bot', N'BOT', 106, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1429, 37, N'gahdg_bot_option', N'BOT Option', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1430, 37, N'gahdg_long_short_ind', N'L / S', 106, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1431, 37, N'gahdg_un_hdg_bal', N'Balance', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1432, 37, N'gahdg_offset_yn', N'Offset?', 106, N'Left', N'', N'', N'Yes/No', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1433, 37, N'gahdg_hedge_yyyymm', N'Hedge', 107, N'Right', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (1434, 38, N'gastr_pur_sls_ind', N'P or S', 278, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22)

INSERT INTO #TempCannedPanelColumn VALUES (1435, 38, N'gastr_com_cd', N'Com', 278, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22)

INSERT INTO #TempCannedPanelColumn VALUES (1436, 38, N'gastr_stor_type', N'Type', 277, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22)

INSERT INTO #TempCannedPanelColumn VALUES (1437, 38, N'gastr_cus_no', N'Customer #', 277, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22)

INSERT INTO #TempCannedPanelColumn VALUES (1438, 38, N'gastr_un_bal', N'Unit Balance', 277, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 22)

INSERT INTO #TempCannedPanelColumn VALUES (1439, 42, N'gaphs_pur_sls_ind', N'P / S', 109, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1440, 42, N'gaphs_cus_no', N'Customer Code', 108, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1441, 42, N'gaphs_com_cd', N'Com', 108, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1442, 42, N'gaphs_loc_no', N'Loc', 108, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1443, 42, N'gaphs_tic_no', N'Ticket #', 107, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1444, 42, N'gaphs_cus_ref_no', N'Customer Ref', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1445, 42, N'gaphs_gross_wgt', N'Gross Weight', 105, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1446, 42, N'gaphs_tare_wgt', N'Tare Weight', 107, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1447, 42, N'gaphs_gross_un', N'Gross Units', 106, N'Right', N'', N'Sum', N'####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1448, 42, N'gaphs_wet_un', N'Wet Units', 105, N'Right', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1449, 42, N'gaphs_net_un', N'Net Units', 105, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1450, 42, N'gaphs_fees', N'Fees', 107, N'Right', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1451, 42, N'gaphs_dlvry_rev_dt', N'Delivery Date', 105, N'Right', N'', N'', N'', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (1452, 43, N'gaitr_pur_sls_ind', N'P or S', 50, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (1453, 43, N'gaitr_loc_no', N'Loc', 6, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (1454, 43, N'gaitr_cus_no', N'Cust#', 148, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (1455, 43, N'agcus_last_name', N'Customer Last Name', 246, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (1456, 43, N'agcus_first_name', N'First Name', 246, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (1457, 43, N'gacom_desc', N'Com', 147, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (1458, 43, N'gaitr_tic_no', N'Ticket', 246, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (1459, 43, N'gaitr_un_out', N'Units', 245, N'Right', N'', N'Sum', N'####.000', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (1460, 44, N'gacnt_pur_sls_ind', N'P or S', 116, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1461, 44, N'gacnt_com_cd', N'Com', 116, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1462, 44, N'Option Month', N'Option Month', 116, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1463, 44, N'Option Year', N'Option Year', 116, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1464, 44, N'Balance', N'Balance', 115, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1465, 44, N'Price', N'Price', 116, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1466, 44, N'Extended Amount', N'Ext Amount', 115, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1467, 44, N'WAP', N'WAP', 115, N'Right', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1468, 44, N'WAB', N'WAB', 115, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1469, 44, N'WAF', N'WAF', 116, N'Right', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1470, 44, N'gacnt_due_rev_dt', N'Due Date', 115, N'Right', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1471, 44, N'gacnt_cnt_no', N'Contract #', 116, N'Right', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (1477, 54, N'gacom_desc', N'Com', 25, N'Left', N'', N'', N'', 2, N'', N'', N'gacommst.gacom_desc', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 20)

INSERT INTO #TempCannedPanelColumn VALUES (1478, 54, N'totals', N'Totals', 25, N'Right', N'', N'Sum', N'####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 20)

INSERT INTO #TempCannedPanelColumn VALUES (1479, 45, N'pttic_cus_no', N'Customer#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (1480, 45, N'ptcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (1481, 45, N'ptcus_first_name', N'Customer Name', 25, N'Left', N'', N'', N' ', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (1482, 45, N'pttic_itm_no', N'Item#', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (1483, 45, N'pttic_qty_orig', N'Quantity', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (1484, 45, N'pttic_tic_no', N'Ticket #', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (1485, 45, N'pttic_rev_dt', N'Date', 25, N'Right', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (1491, 47, N'ptcus_cus_no', N'Customer Code', 347, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68)

INSERT INTO #TempCannedPanelColumn VALUES (1492, 47, N'ptcus_last_name', N'Last Name', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68)

INSERT INTO #TempCannedPanelColumn VALUES (1493, 47, N'ptcus_first_name', N'First Name', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68)

INSERT INTO #TempCannedPanelColumn VALUES (1494, 47, N'ptcus_ar_ov120', N'Amount', 346, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 68)

INSERT INTO #TempCannedPanelColumn VALUES (1495, 48, N'ptitm_itm_no', N'Item #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (1496, 48, N'ptitm_desc', N'Item/Product', 417, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (1497, 48, N'ptitm_loc_no', N'Loc', 138, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (1498, 48, N'ptitm_unit', N'Unit Desc', 138, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (1499, 48, N'ptitm_on_hand', N'On Hand Qty', 231, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (1500, 48, N'ptitm_last_sale_rev_dt', N'Last Sale Date', 231, N'Right', N'', N'', N'Date', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (1501, 49, N'ptstm_itm_no', N'Item #', 287, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58)

INSERT INTO #TempCannedPanelColumn VALUES (1502, 49, N'ptitm_desc', N'Description', 287, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58)

INSERT INTO #TempCannedPanelColumn VALUES (1503, 49, N'Sales', N'Sales', 287, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58)

INSERT INTO #TempCannedPanelColumn VALUES (1504, 49, N'Units', N'Units', 286, N'Left', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 58)

INSERT INTO #TempCannedPanelColumn VALUES (1505, 50, N'Location', N'Location', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 59)

INSERT INTO #TempCannedPanelColumn VALUES (1506, 50, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 59)

INSERT INTO #TempCannedPanelColumn VALUES (1507, 64, N'ptitm_itm_no', N'Item Code', 243, N'Left', N'', N'', N'', 2, N'', N'', N'ptitm_itm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66)

INSERT INTO #TempCannedPanelColumn VALUES (1508, 64, N'ptitm_desc', N'Item/Product', 437, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66)

INSERT INTO #TempCannedPanelColumn VALUES (1509, 64, N'ptitm_loc_no', N'Loc', 242, N'Left', N'', N'', N'', 4, N'', N'', N'ptitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66)

INSERT INTO #TempCannedPanelColumn VALUES (1510, 64, N'ptitm_on_hand', N'On Hand Quantity', 242, N'Right', N'', N'', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 66)

INSERT INTO #TempCannedPanelColumn VALUES (1511, 52, N'ptcus_last_name', N'Customer Last Name', 282, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62)

INSERT INTO #TempCannedPanelColumn VALUES (1512, 52, N'ptcus_first_name', N'First Name', 282, N'Left', N'', N'', N' ', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62)

INSERT INTO #TempCannedPanelColumn VALUES (1513, 52, N'ptcus_cus_no', N'Customer Code', 280, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62)

INSERT INTO #TempCannedPanelColumn VALUES (1514, 52, N'Sales', N'Sales', 280, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62)

INSERT INTO #TempCannedPanelColumn VALUES (1515, 52, N'Units', N'Units', 280, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 62)

INSERT INTO #TempCannedPanelColumn VALUES (1516, 51, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60)

INSERT INTO #TempCannedPanelColumn VALUES (1517, 51, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60)

INSERT INTO #TempCannedPanelColumn VALUES (1518, 51, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60)

INSERT INTO #TempCannedPanelColumn VALUES (1519, 51, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 60)

INSERT INTO #TempCannedPanelColumn VALUES (1520, 53, N'ptcus_cus_no', N'Customer#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (1521, 53, N'ptcus_last_name', N'Customer Last Name', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (1522, 53, N'ptcus_first_name', N'First Name', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (1523, 53, N'ptcus_credit_limit', N'Credit Limit', 231, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (1524, 53, N'Total Balance', N'Total Balance', 231, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (1525, 53, N'overage', N'Overage', 231, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (1526, 4, N'ptstm_bill_to_cus', N'Bill To Cus', 94, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1527, 4, N'ptstm_ivc_no', N'Invoice #', 93, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1528, 4, N'ptstm_ship_rev_dt', N'Ship Date', 93, N'Right', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1529, 4, N'ptstm_itm_no', N'Item#', 93, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1530, 4, N'ptstm_loc_no', N'Loc', 93, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1531, 4, N'ptstm_class', N'Class Code', 93, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1532, 4, N'ptstm_un', N'Units Sold', 93, N'Right', N'', N'', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1533, 4, N'ptstm_un_prc', N'Unit Price', 92, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1534, 4, N'ptstm_net', N'Sales', 92, N'Right', N'', N'', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1535, 4, N'ptstm_cgs', N'Costs', 92, N'Right', N'', N'', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1536, 4, N'ptstm_slsmn_id', N'Salesperson', 92, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1537, 4, N'ptstm_pak_desc', N'Package Desc', 92, N'Left', N'', N'', N'', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1538, 4, N'ptstm_un_desc', N'Unit Desc', 92, N'Left', N'', N'', N'', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1539, 4, N'Profit Amount', N'Profit Amount', 92, N'Right', N'', N'', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1540, 4, N'Profit Percent', N'Profit Percentage', 91, N'Right', N'', N'', N'##.###%', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (1541, 63, N'ptstm_bill_to_cus', N'Bill To Cus', 347, N'Left', N'', N'', N'', 2, N'', N'', N'ptstm_bill_to_cus', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61)

INSERT INTO #TempCannedPanelColumn VALUES (1542, 63, N'ptstm_ivc_no', N'Invoice #', 347, N'Left', N'', N'', N'', 3, N'', N'', N'ptstm_ivc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61)

INSERT INTO #TempCannedPanelColumn VALUES (1543, 63, N'ptstm_ship_rev_dt', N'Ship Date', 347, N'Left', N'', N'', N'Date', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61)

INSERT INTO #TempCannedPanelColumn VALUES (1544, 63, N'Profit Percent', N'Profit Percentage', 346, N'Right', N'', N'', N'##.###%', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 61)

INSERT INTO #TempCannedPanelColumn VALUES (1545, 5, N'ptitm_itm_no', N'Item#', 155, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (1546, 5, N'ptitm_desc', N'Item/Product', 278, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (1547, 5, N'ptitm_loc_no', N'Loc', 92, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (1548, 5, N'ptitm_class', N'Class', 154, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (1549, 5, N'ptitm_unit', N'Unit Desc', 92, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (1550, 5, N'ptitm_cost1', N'Last Costs', 154, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (1551, 5, N'ptitm_avg_cost', N'Average Costs', 154, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (1552, 5, N'ptitm_std_cost', N'Standard Costs', 154, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (1553, 5, N'ptitm_on_hand', N'Units On Hand', 154, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (1554, 62, N'ptitm_itm_no', N'Item Code', 347, N'Left', N'', N'', N'', 2, N'', N'', N'ptitm_itm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55)

INSERT INTO #TempCannedPanelColumn VALUES (1555, 62, N'ptitm_desc', N'Item/Product', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55)

INSERT INTO #TempCannedPanelColumn VALUES (1556, 62, N'ptitm_loc_no', N'Loc', 347, N'Left', N'', N'', N' ', 4, N'', N'', N'ptitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55)

INSERT INTO #TempCannedPanelColumn VALUES (1557, 62, N'ptitm_on_hand', N'On-Hand Quantity', 346, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 55)

INSERT INTO #TempCannedPanelColumn VALUES (1558, 9, N'agcus_last_name', N'Customer Last Name', 347, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44)

INSERT INTO #TempCannedPanelColumn VALUES (1559, 9, N'Amount', N'Amount', 346, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44)

INSERT INTO #TempCannedPanelColumn VALUES (1560, 9, N'agcus_first_name', N'Customer First Name', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44)

INSERT INTO #TempCannedPanelColumn VALUES (1561, 9, N'agcus_key', N'Customer #', 347, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 44)

INSERT INTO #TempCannedPanelColumn VALUES (1588, 58, N'agitm_no', N'Item#', 347, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51)

INSERT INTO #TempCannedPanelColumn VALUES (1589, 58, N'agitm_desc', N'Item/Product', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51)

INSERT INTO #TempCannedPanelColumn VALUES (1590, 58, N'agitm_loc_no', N'Loc', 347, N'Left', N'', N'', N'', 6, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51)

INSERT INTO #TempCannedPanelColumn VALUES (1591, 58, N'agitm_un_on_hand', N'Units On Hand Qty', 346, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 51)

INSERT INTO #TempCannedPanelColumn VALUES (1592, 17, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65)

INSERT INTO #TempCannedPanelColumn VALUES (1593, 17, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65)

INSERT INTO #TempCannedPanelColumn VALUES (1594, 17, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65)

INSERT INTO #TempCannedPanelColumn VALUES (1595, 17, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 65)

INSERT INTO #TempCannedPanelColumn VALUES (1596, 20, N'agcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46)

INSERT INTO #TempCannedPanelColumn VALUES (1597, 20, N'agstm_key_loc_no', N'Location', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46)

INSERT INTO #TempCannedPanelColumn VALUES (1598, 20, N'agstm_key_loc_no', N'Location', 0, N'Series2AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46)

INSERT INTO #TempCannedPanelColumn VALUES (1599, 20, N'Sales', N'Sales Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46)

INSERT INTO #TempCannedPanelColumn VALUES (1600, 20, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 46)

INSERT INTO #TempCannedPanelColumn VALUES (1610, 21, N'agitm_no', N'Item #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (1611, 21, N'agitm_desc', N'Item/Product', 417, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (1612, 21, N'agitm_loc_no', N'Loc', 138, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (1613, 21, N'agitm_un_desc', N'Unit Desc', 138, N'Left', N'', N'', N' ', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (1614, 21, N'agitm_un_on_hand', N'On Hand Qty', 231, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (1615, 21, N'agitm_last_sale_rev_dt', N'Last Sale Date', 231, N'Right', N'', N'', N'Date', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (1616, 22, N'agord_cus_no', N'Customer#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (1617, 22, N'agord_ord_no', N'Order#', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (1618, 22, N'agord_loc_no', N'Loc', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (1619, 22, N'agord_ord_rev_dt', N'Order Date', 231, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (1620, 22, N'agord_itm_no', N'Item #', 231, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (1621, 22, N'agord_pkg_sold', N'Packages Sold', 231, N'Left', N'', N'', N'####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (1623, 6, N'agcnt_cus_no', N'Customer#', 108, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1624, 6, N'agcus_last_name', N'Customer Last Name', 108, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1625, 6, N'agcus_first_name', N'First Name', 108, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1626, 6, N'agcnt_slsmn_id', N'Salesperson ID', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1627, 6, N'agcnt_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1628, 6, N'agcnt_cnt_no', N'Contract #', 108, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1629, 6, N'agcnt_cnt_rev_dt', N'Contract Date', 105, N'Right', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1630, 6, N'agcnt_due_rev_dt', N'Due Date', 107, N'Right', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1631, 6, N'agcnt_itm_or_cls', N'Item or Class', 107, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1632, 6, N'agcnt_prc_lvl', N'Price Level', 105, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1633, 6, N'agcnt_ppd_yndm', N'Prepaid', 105, N'Left', N'', N'', N'Yes/No', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1634, 6, N'agcnt_un_orig', N'Original Units', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1635, 6, N'agcnt_un_bal', N'Unit Balance', 105, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (1636, 61, N'agcnt_cus_no', N'Customer#', 199, N'Left', N'', N'', N'', 3, N'', N'', N'agcnt_cus_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (1637, 61, N'agcus_last_name', N'Customer Last Name', 198, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (1638, 61, N'agcus_first_name', N'First Name', 198, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (1639, 61, N'agcnt_loc_no', N'Loc', 198, N'Left', N'', N'', N'', 7, N'', N'', N'agcnt_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (1640, 61, N'agcnt_cnt_no', N'Contract #', 200, N'Left', N'', N'Count', N'', 2, N'', N'', N'agcnt_cnt_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (1641, 61, N'agcnt_un_bal', N'Unit Balance', 196, N'Right', N'', N'Sum', N'####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (1642, 61, N'agcnt_itm_or_cls', N'Item or Class', 198, N'Left', N'', N'', N'', 14, N'', N'', N'agcnt_itm_or_cls', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (1644, 60, N'agitm_desc', N'Item/Product', 427, N'Left', N'', N'Count', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42)

INSERT INTO #TempCannedPanelColumn VALUES (1645, 60, N'agitm_loc_no', N'Loc', 371, N'Left', N'', N'', N'', 4, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42)

INSERT INTO #TempCannedPanelColumn VALUES (1646, 60, N'agitm_un_on_hand', N'On Hand Inventory', 369, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42)

INSERT INTO #TempCannedPanelColumn VALUES (1647, 60, N'agitm_no', N'Item #', 220, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 42)

INSERT INTO #TempCannedPanelColumn VALUES (1648, 8, N'agitm_no', N'Item #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1649, 8, N'agitm_desc', N'Item Name', 107, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1650, 8, N'agitm_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1651, 8, N'agitm_un_desc', N'Unit Desc', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1652, 8, N'agitm_un_on_hand', N'On Hand', 107, N'Right', N'', N'Sum', N'####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1653, 8, N'agitm_un_pend_ivcs', N'Pending Invoices', 106, N'Right', N'', N'Sum', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1654, 8, N'agitm_un_on_order', N'On Order', 107, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1655, 8, N'agitm_un_mfg_in_prs', N'Mfg', 107, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1656, 8, N'agitm_un_fert_committed', N'Contracts Committed', 106, N'Right', N'', N'Sum', N'####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1657, 8, N'agitm_un_ord_committed', N'Orders Committed', 106, N'Right', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1658, 8, N'agitm_un_cnt_committed', N'Other Contracts Committed', 107, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1659, 8, N'Available', N'Available', 106, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1660, 8, N'agitm_class', N'Class', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (1661, 57, N'agitm_no', N'Item #', 347, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54)

INSERT INTO #TempCannedPanelColumn VALUES (1662, 57, N'agitm_desc', N'Item Name', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54)

INSERT INTO #TempCannedPanelColumn VALUES (1663, 57, N'agitm_loc_no', N'Loc', 347, N'Left', N'', N'', N'', 4, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54)

INSERT INTO #TempCannedPanelColumn VALUES (1664, 57, N'Available', N'Available', 346, N'Left', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 54)

INSERT INTO #TempCannedPanelColumn VALUES (1668, 1, N'agstm_bill_to_cus', N'Bill To Customer', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1669, 1, N'agstm_ivc_no', N'Invoice #', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1670, 1, N'agstm_ship_rev_dt', N'Ship Date', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1671, 1, N'agstm_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1672, 1, N'agstm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1673, 1, N'agstm_class', N'Class Code', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1674, 1, N'agstm_un', N'Units Sold', 25, N'Right', N'', N'', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1675, 1, N'agstm_un_prc', N'Unit Price', 25, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1676, 1, N'agstm_sls', N'Sales Amount', 25, N'Right', N'', N'', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1677, 1, N'agstm_un_cost', N'Unit Costs', 25, N'Right', N'', N'', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1678, 1, N'agstm_cgs', N'Costs Amount', 25, N'Right', N'', N'', N'$####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1679, 1, N'agstm_slsmn_id', N'Salesperson', 25, N'Left', N'', N'', N'', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1680, 1, N'agstm_pak_desc', N'Package Desc', 25, N'Left', N'', N'', N'', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1681, 1, N'agstm_un_desc', N'Unit Desc', 25, N'Left', N'', N'', N'', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1682, 1, N'unit margins', N'Unit Margins', 25, N'Right', N'', N'Sum', N'$####.000', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1683, 1, N'Profit Amount', N'Profit Amount', 25, N'Right', N'', N'Sum', N'$###0.000', 17, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1684, 1, N'Profit Percent', N'Profit Percent', 25, N'Right', N'', N'', N'##.###%', 18, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (1685, 40, N'pxrpt_trans_type', N'Trans Type', 26, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1686, 40, N'pxrpt_trans_rev_dt', N'Trans Date', 65, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1687, 40, N'pxrpt_ord_no', N'Order #', 76, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1688, 40, N'pxrpt_car_name', N'Carrier', 76, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1689, 40, N'pxrpt_cus_name', N'Customer', 76, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1690, 40, N'pxrpt_cus_state', N'Customer State', 76, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1691, 40, N'pxrpt_itm_desc', N'Item/Product', 76, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1692, 40, N'pxrpt_itm_loc_no', N'Loc', 76, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1693, 40, N'pxrpt_vnd_name', N'Vendor', 76, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1694, 40, N'pxrpt_vnd_state', N'Vendor State', 28, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1695, 40, N'pxrpt_pur_gross_un', N'Gross Units Purchased', 75, N'Left', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1696, 40, N'pxrpt_pur_net_un', N'Net Units Purchased', 75, N'Left', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1697, 40, N'pxrpt_pur_fet_amt', N'FET', 75, N'Left', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1698, 40, N'pxrpt_pur_set_amt', N'SET', 75, N'Left', N'', N'Sum', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1699, 40, N'pxrpt_pur_sst_amt', N'SST', 75, N'Left', N'', N'Sum', N'$####.00', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1700, 40, N'pxrpt_pur_lc1_amt', N'LC1', 75, N'Left', N'', N'Sum', N'$####.00', 17, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1701, 40, N'pxrpt_pur_lc2_amt', N'LC2', 75, N'Left', N'', N'Sum', N'$####.00', 18, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1702, 40, N'pxrpt_pur_lc3_amt', N'LC3', 25, N'Left', N'', N'Sum', N'$####.00', 19, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1703, 40, N'pxrpt_pur_lc4_amt', N'LC4', 25, N'Left', N'', N'Sum', N'$####.00', 20, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1704, 40, N'pxrpt_pur_un_received', N'Units Received', 76, N'Left', N'', N'Sum', N'####.00', 21, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1705, 40, N'pxrpt_src_sys', N'Source System', 76, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1706, 40, N'pxrpt_itm_dyed_yn', N'Dyed?', 25, N'Left', N'', N'', N'', 22, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (1707, 32, N'pxrpt_trans_type', N'Trans Type', 82, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1708, 32, N'pxrpt_trans_rev_dt', N'Trans Date', 82, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1709, 32, N'pxrpt_src_sys', N'Source System', 79, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1710, 32, N'pxrpt_ord_no', N'Order #', 79, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1711, 32, N'pxrpt_car_name', N'Carrier', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1712, 32, N'pxrpt_cus_name', N'Customer', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1713, 32, N'pxrpt_cus_state', N'Customer State', 27, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1714, 32, N'pxrpt_itm_desc', N'Item/Product', 78, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1715, 32, N'pxrpt_itm_loc_no', N'Loc', 69, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1716, 32, N'pxrpt_vnd_name', N'Vendor ', 76, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1717, 32, N'pxrpt_vnd_state', N'Vendor State', 77, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1718, 32, N'pxrpt_sls_trans_gals', N'Sales Units', 77, N'Left', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1719, 32, N'pxrpt_sls_fet_amt', N'FET', 77, N'Left', N'', N'Sum', N'$####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1720, 32, N'pxrpt_sls_set_amt', N'SET', 77, N'Left', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1721, 32, N'pxrpt_sls_lc1_amt', N'LC1', 76, N'Left', N'', N'Sum', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1722, 32, N'pxrpt_sls_lc2_amt', N'LC2', 76, N'Left', N'', N'Sum', N'$####.00', 16, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1723, 32, N'pxrpt_sls_lc3_amt', N'LC3', 76, N'Left', N'', N'Sum', N'$####.00', 17, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1724, 32, N'pxrpt_sls_lc4_amt', N'LC4', 76, N'Left', N'', N'Sum', N'$####.00', 18, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1725, 32, N'pxrpt_itm_dyed_yn', N'Dyed?', 77, N'Left', N'', N'', N'', 19, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1726, 32, N'pxrpt_cus_acct_stat', N'Cus  Acct Status ', 76, N'Left', N'', N'', N'', 20, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (1727, 11, N'apcbk_desc', N'Checkbook Name', 25, N'Left', N'', N'', N' ', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37)

INSERT INTO #TempCannedPanelColumn VALUES (1728, 11, N'apcbk_no', N'Checkbook #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37)

INSERT INTO #TempCannedPanelColumn VALUES (1729, 11, N'apcbk_bal', N'Checkbook Balance', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 37)

INSERT INTO #TempCannedPanelColumn VALUES (1740, 15, N'apchk_rev_dt', N'Date', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35)

INSERT INTO #TempCannedPanelColumn VALUES (1741, 15, N'apchk_name', N'Check Name', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35)

INSERT INTO #TempCannedPanelColumn VALUES (1742, 15, N'apchk_chk_amt', N'Check Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 35)

INSERT INTO #TempCannedPanelColumn VALUES (1743, 14, N'apivc_ivc_no', N'Invoice#', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (1744, 14, N'apivc_ivc_rev_dt', N'Invoice Date', 231, N'Right', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (1745, 14, N'apivc_vnd_no', N'Vendor #', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (1746, 14, N'ssvnd_name', N'Vendor', 231, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (1747, 14, N'amounts', N'Amount Due', 231, N'Right', N'', N'Sum', N'$###0.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (1748, 14, N'apivc_due_rev_dt', N'Due Date', 231, N'Right', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (1749, 13, N'apchk_cbk_no', N'Checkbook #', 139, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (1750, 13, N'apchk_rev_dt', N'Date', 139, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (1751, 13, N'apchk_vnd_no', N'Vendor #', 139, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (1752, 13, N'apchk_name', N'Vendor Name', 139, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (1753, 13, N'apchk_chk_amt', N'Check Amount', 139, N'Left', N'', N'Sum', N'$###0.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (1754, 13, N'apchk_disc_amt', N'Discount Amount', 139, N'Left', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (1755, 13, N'apchk_gl_rev_dt', N'GL Date', 139, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (1756, 13, N'apchk_cleared_ind', N'Cleared?', 138, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (1757, 13, N'apchk_clear_rev_dt', N'Cleared Date', 138, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (1758, 13, N'apchk_src_sys', N'Source System', 138, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (1759, 16, N'apivc_ivc_no', N'Invoice #', 127, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38)

INSERT INTO #TempCannedPanelColumn VALUES (1760, 16, N'apivc_ivc_rev_dt', N'Invoice Date', 315, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38)

INSERT INTO #TempCannedPanelColumn VALUES (1761, 16, N'apivc_vnd_no', N'Vendor #', 315, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38)

INSERT INTO #TempCannedPanelColumn VALUES (1762, 16, N'ssvnd_name', N'Vendor Name', 315, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38)

INSERT INTO #TempCannedPanelColumn VALUES (1763, 16, N'amounts', N'Amount', 315, N'Left', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 38)

INSERT INTO #TempCannedPanelColumn VALUES (1764, 55, N'CheckDate', N'Check Date', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 39)

INSERT INTO #TempCannedPanelColumn VALUES (1765, 55, N'Amount', N'Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 39)

INSERT INTO #TempCannedPanelColumn VALUES (1766, 24, N'strDescription', N'Description', 154, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (1767, 24, N'dblDebit', N'Debit ', 153, N'Left', N'', N'Sum', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (1768, 24, N'dblCredit', N'Credit', 153, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (1769, 24, N'Balance', N'Balance', 153, N'Left', N'', N'Sum', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (1770, 24, N'strAccountId', N'AccountID', 159, N'Left', N'', N'Count', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (1771, 24, N'dtmDate', N'Date', 154, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (1772, 24, N'strTransactionId', N'Document', 154, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (1773, 24, N'strReference', N'Reference', 154, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (1774, 24, N'strAccountGroup', N'Account Group', 153, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (1775, 25, N'strAccountId', N'Account ID', 463, N'Left', N'', N'Count', N'', 2, N'', N'', N'strAccountId', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 76)

INSERT INTO #TempCannedPanelColumn VALUES (1776, 25, N'strDescription', N'Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 76)

INSERT INTO #TempCannedPanelColumn VALUES (1777, 25, N'Balance', N'Balance', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 76)

INSERT INTO #TempCannedPanelColumn VALUES (1781, 27, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78)

INSERT INTO #TempCannedPanelColumn VALUES (1782, 27, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78)

INSERT INTO #TempCannedPanelColumn VALUES (1783, 27, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 78)

INSERT INTO #TempCannedPanelColumn VALUES (1788, 34, N'Period', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81)

INSERT INTO #TempCannedPanelColumn VALUES (1789, 34, N'TotalBalance', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81)

INSERT INTO #TempCannedPanelColumn VALUES (1790, 34, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81)

INSERT INTO #TempCannedPanelColumn VALUES (1791, 34, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 81)

INSERT INTO #TempCannedPanelColumn VALUES (1792, 35, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 82)

INSERT INTO #TempCannedPanelColumn VALUES (1793, 35, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 82)

INSERT INTO #TempCannedPanelColumn VALUES (1794, 28, N'strAccountId', N'Account ID', 459, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79)

INSERT INTO #TempCannedPanelColumn VALUES (1795, 28, N'strDescription', N'GL Description', 465, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79)

INSERT INTO #TempCannedPanelColumn VALUES (1796, 28, N'Amount', N'Amount', 463, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 79)

INSERT INTO #TempCannedPanelColumn VALUES (1797, 36, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 83)

INSERT INTO #TempCannedPanelColumn VALUES (1798, 36, N'Revenue', N'Revenue', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 83)

INSERT INTO #TempCannedPanelColumn VALUES (1799, 29, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80)

INSERT INTO #TempCannedPanelColumn VALUES (1800, 29, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80)

INSERT INTO #TempCannedPanelColumn VALUES (1801, 29, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 80)

INSERT INTO #TempCannedPanelColumn VALUES (1802, 39, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 84)

INSERT INTO #TempCannedPanelColumn VALUES (1803, 39, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 84)

INSERT INTO #TempCannedPanelColumn VALUES (1859, 56, N'cftrx_ar_cus_no', N'A/R Customer #', 100, N'Left', N'Filter', N'', N'', 1, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1860, 56, N'cftrx_card_no', N'Card #', 100, N'Left', N'Filter', N'', N'', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1861, 56, N'cfcus_card_desc', N'Card Desc', 100, N'Left', N'Filter', N'', N'', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1862, 56, N'cftrx_rev_dt', N'Date', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1863, 56, N'cftrx_qty', N'Quantity', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1864, 56, N'cftrx_prc', N'Price', 100, N'Left', N'Filter', N'', N'', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1865, 56, N'cftrx_calc_total', N'Calc Total', 100, N'Left', N'Filter', N'', N'', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1866, 56, N'cftrx_ar_itm_no', N'A/R Item #', 100, N'Left', N'Filter', N'', N'', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1867, 56, N'cftrx_ar_itm_loc_no', N'Loc ', 100, N'Left', N'Filter', N'', N'', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1868, 56, N'cftrx_sls_id', N'Salesperson ID', 100, N'Left', N'Filter', N'', N'', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1869, 56, N'cftrx_sell_prc', N'Sell Price', 100, N'Left', N'Filter', N'', N'', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1870, 56, N'cftrx_prc_per_un', N'Price per Unit', 100, N'Left', N'Filter', N'', N'', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1871, 56, N'cftrx_site', N'Site', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1872, 56, N'cftrx_time', N'Time', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1873, 56, N'cftrx_odometer', N'Odometer', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1874, 56, N'cftrx_site_state', N'Site State', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1875, 56, N'cftrx_site_county', N'Site County', 100, N'Left', N'Filter', N'', N'', 17, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1876, 56, N'cftrx_site_city', N'Site City', 100, N'Left', N'Filter', N'', N'', 18, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1877, 56, N'cftrx_selling_host_id', N'Selling Host ID', 100, N'Left', N'Filter', N'', N'', 19, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1878, 56, N'cftrx_buying_host_id', N'Buying Host ID', 100, N'Left', N'Filter', N'', N'', 20, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1879, 56, N'cftrx_po_no', N'PO #', 100, N'Left', N'Filter', N'', N'', 21, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1880, 56, N'cftrx_ar_ivc_no', N'A/R Invoice #', 100, N'Left', N'Filter', N'', N'', 22, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1881, 56, N'cftrx_calc_fet_amt', N'Calc FET Amount', 100, N'Left', N'Filter', N'', N'', 23, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1882, 56, N'cftrx_calc_set_amt', N'Calc SET Amount', 100, N'Left', N'Filter', N'', N'', 24, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1883, 56, N'cftrx_calc_sst_amt', N'Calc SST Amount', 100, N'Left', N'Filter', N'', N'', 25, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1884, 56, N'cftrx_tax_cls_id', N'Tax Class ID', 100, N'Left', N'Filter', N'', N'', 26, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1885, 56, N'cftrx_ivc_prtd_yn', N'Inv Printed ?', 100, N'Left', N'Filter', N'', N'', 27, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1886, 56, N'cftrx_vehl_no', N'Vehicle #', 100, N'Left', N'Filter', N'', N'', 28, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1887, 56, N'cftrx_calc_net_sell_prc', N'Calc Net Sell', 100, N'Left', N'Filter', N'', N'', 29, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1888, 56, N'cftrx_pump_no', N'Pump No', 100, N'Left', N'Filter', N'', N'', 30, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (1889, 7, N'glhst_acct1_8', N'GL Acct', 125, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1890, 7, N'glhst_acct9_16', N'Profit Center', 122, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1891, 7, N'glhst_ref', N'Reference', 119, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1892, 7, N'glhst_period', N'Period', 81, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1893, 7, N'glhst_trans_dt', N'Transaction Date', 117, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1894, 7, N'glhst_src_id', N'Source ID', 117, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1895, 7, N'glhst_src_seq', N'Source Sequence', 118, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1896, 7, N'glhst_dr_cr_ind', N'Credit/Debit', 117, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1897, 7, N'glhst_jrnl_no', N'Journal #', 117, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1898, 7, N'glhst_doc', N'Document #', 117, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1899, 7, N'Amount', N'Amount', 120, N'Left', N'', N'Sum', N'$####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1900, 7, N'glhst_units', N'Units', 117, N'Left', N'', N'', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (1901, 65, N'glhst_acct1_8', N'GL Acct', 347, N'Left', N'', N'', N'', 2, N'', N'', N'glhstmst.glhst_acct1_8', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27)

INSERT INTO #TempCannedPanelColumn VALUES (1902, 65, N'glhst_acct9_16', N'Profit Center', 347, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27)

INSERT INTO #TempCannedPanelColumn VALUES (1903, 65, N'glact_desc', N'GL Desc', 347, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27)

INSERT INTO #TempCannedPanelColumn VALUES (1904, 65, N'Amount', N'Amount', 346, N'Left', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 27)

INSERT INTO #TempCannedPanelColumn VALUES (1905, 66, N'glact_acct1_8', N'GL Acct', 463, N'Left', N'', N'', N'', 2, N'', N'', N'glhst_acct1_8', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30)

INSERT INTO #TempCannedPanelColumn VALUES (1906, 66, N'glact_acct9_16', N'Profit Center', 462, N'Left', N'', N'', N'', 3, N'', N'', N'glhst_acct9_16', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30)

INSERT INTO #TempCannedPanelColumn VALUES (1907, 66, N'glact_desc', N'Description', 462, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 30)

INSERT INTO #TempCannedPanelColumn VALUES (1908, 67, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 31)

INSERT INTO #TempCannedPanelColumn VALUES (1909, 67, N'Amount', N'Amount', 693, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 31)

INSERT INTO #TempCannedPanelColumn VALUES (1910, 68, N'glact_desc', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 32)

INSERT INTO #TempCannedPanelColumn VALUES (1911, 68, N'Amount', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 32)

INSERT INTO #TempCannedPanelColumn VALUES (1912, 69, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 33)

INSERT INTO #TempCannedPanelColumn VALUES (1913, 69, N'Amount', N'Amount', 693, N'Left', N'', N' ', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 33)

INSERT INTO #TempCannedPanelColumn VALUES (1914, 70, N'glact_desc', N'GL Acct', 694, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 34)

INSERT INTO #TempCannedPanelColumn VALUES (1915, 70, N'Amount', N'Amount', 693, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 34)

INSERT INTO #TempCannedPanelColumn VALUES (1916, 71, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40)

INSERT INTO #TempCannedPanelColumn VALUES (1917, 71, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40)

INSERT INTO #TempCannedPanelColumn VALUES (1918, 71, N'Amount', N'Revenue Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40)

INSERT INTO #TempCannedPanelColumn VALUES (1919, 71, N'Amount', N'Expense Amount', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 40)

INSERT INTO #TempCannedPanelColumn VALUES (1920, 72, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41)

INSERT INTO #TempCannedPanelColumn VALUES (1921, 72, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41)

INSERT INTO #TempCannedPanelColumn VALUES (1922, 72, N'Amount', N'Assets Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41)

INSERT INTO #TempCannedPanelColumn VALUES (1923, 72, N'Amount', N'Liabilities Amount', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 41)

INSERT INTO #TempCannedPanelColumn VALUES (1927, 59, N'agstm_ivc_no', N'Invoice #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'agstm_ivc_no', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43)

INSERT INTO #TempCannedPanelColumn VALUES (1928, 59, N'agstm_ship_rev_dt', N'Ship Date', 25, N'Right', N'', N'', N'Date', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43)

INSERT INTO #TempCannedPanelColumn VALUES (1929, 59, N'Profit Percent', N'Profit Percent', 25, N'Right', N'', N'', N'##.###%', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 43)

INSERT INTO #TempCannedPanelColumn VALUES (4091, 33, N'gacnt_pur_sls_ind', N'P/S', 107, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4092, 33, N'gacnt_cus_no', N'Customer #', 107, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4093, 33, N'agcus_last_name', N'Last Name', 107, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4094, 33, N'agcus_first_name', N'First Name', 107, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4095, 33, N'gacnt_loc_no', N'Loc', 107, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4096, 33, N'gacnt_com_cd', N'Com', 107, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4097, 33, N'gacnt_cnt_no', N'Contact #', 106, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4098, 33, N'gacnt_seq_no', N'Seq', 107, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4099, 33, N'gacnt_mkt_zone', N'Market Zone', 107, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4100, 33, N'gacnt_beg_ship_rev_dt', N'Beg Ship Date', 106, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4101, 33, N'gacnt_due_rev_dt', N'Due Date', 106, N'Right', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4102, 33, N'gacnt_pbhcu_ind', N'PBHU', 107, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4103, 33, N'gacnt_un_bal', N'Unit Balance', 106, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (4159, 3, N'gacom_desc', N'Com', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19)

INSERT INTO #TempCannedPanelColumn VALUES (4160, 3, N'gapos_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19)

INSERT INTO #TempCannedPanelColumn VALUES (4161, 3, N'gapos_in_house', N'In House', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19)

INSERT INTO #TempCannedPanelColumn VALUES (4162, 3, N'gapos_offsite', N'Offsite', 25, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19)

INSERT INTO #TempCannedPanelColumn VALUES (4163, 3, N'gapos_sls_in_transit', N'In Transit', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 19)

INSERT INTO #TempCannedPanelColumn VALUES (4173, 46, N'Current', N'Current', 25, N'Center', N'', N'', N'$####.00', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67)

INSERT INTO #TempCannedPanelColumn VALUES (4174, 46, N'31-60 Days', N'31-60 Days', 25, N'Center', N'', N'', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67)

INSERT INTO #TempCannedPanelColumn VALUES (4175, 46, N'61-90 Days', N'61-90 Days', 25, N'Center', N'', N'', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67)

INSERT INTO #TempCannedPanelColumn VALUES (4176, 46, N'91-120 Days', N'91-120 Days', 25, N'Center', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67)

INSERT INTO #TempCannedPanelColumn VALUES (4177, 46, N'Over 120 Days', N'Over 120 Days', 25, N'Center', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 67)

INSERT INTO #TempCannedPanelColumn VALUES (4249, 10, N'Future', N'Future', 25, N'Left', N'', N'', N'$####.00', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (4250, 10, N'Current', N'Current', 25, N'Left', N'', N'', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (4251, 10, N'30days', N'31-60 Days', 25, N'Left', N'', N'', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (4252, 10, N'60days', N'61-90 Days', 25, N'Left', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (4253, 10, N'90days', N'91-120 Days', 25, N'Left', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (4254, 10, N'120days', N'Over 120 Days', 25, N'Left', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (4255, 256, N'agcus_key', N'Customer #', 232, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)

INSERT INTO #TempCannedPanelColumn VALUES (4256, 256, N'agcus_last_name', N'Customer Last Name', 231, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)

INSERT INTO #TempCannedPanelColumn VALUES (4257, 256, N'agcus_first_name', N'First Name', 231, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)

INSERT INTO #TempCannedPanelColumn VALUES (4258, 256, N'agcus_cred_limit', N'Credit Limit', 231, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)

INSERT INTO #TempCannedPanelColumn VALUES (4259, 256, N'Total Balance', N'Total Balance', 231, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)

INSERT INTO #TempCannedPanelColumn VALUES (4260, 256, N'Overage', N'Overage', 231, N'Right', N'', N'Sum', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 86)

INSERT INTO #TempCannedPanelColumn VALUES (4261, 2, N'agitm_no', N'Item#', 174, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (4262, 2, N'agitm_desc', N'Item/Product', 174, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (4263, 2, N'agitm_pak_desc', N'Package', 174, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (4264, 2, N'agitm_class', N'Class', 173, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (4265, 2, N'agitm_loc_no', N'Loc', 173, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (4266, 2, N'agitm_last_un_cost', N'Last Unit Cost', 173, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (4267, 2, N'agitm_avg_un_cost', N'Average Unit Cost', 173, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (4268, 2, N'agitm_un_on_hand', N'Units On Hand Qty', 173, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (4282, 19, N'agstm_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70)

INSERT INTO #TempCannedPanelColumn VALUES (4283, 19, N'agitm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70)

INSERT INTO #TempCannedPanelColumn VALUES (4284, 19, N'Sales', N'Sales', 25, N'Right', N'', N'Sum', N'$###0.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70)

INSERT INTO #TempCannedPanelColumn VALUES (4285, 19, N'Units', N'Units', 25, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 70)

INSERT INTO #TempCannedPanelColumn VALUES (4286, 18, N'Customer Last Name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69)

INSERT INTO #TempCannedPanelColumn VALUES (4287, 18, N'First Name', N'First Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69)

INSERT INTO #TempCannedPanelColumn VALUES (4288, 18, N'Customer Code', N'Customer Code', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69)

INSERT INTO #TempCannedPanelColumn VALUES (4289, 18, N'Sales', N'Sales', 25, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69)

INSERT INTO #TempCannedPanelColumn VALUES (4290, 18, N'Units', N'Units', 25, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 69)

INSERT INTO #TempCannedPanelColumn VALUES (4444, 26, N'strAccountId', N'Account ID', 463, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77)

INSERT INTO #TempCannedPanelColumn VALUES (4445, 26, N'strDescription', N'GL Description', 462, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77)

INSERT INTO #TempCannedPanelColumn VALUES (4446, 26, N'Amount', N'Amount', 462, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 77)

INSERT INTO #TempCannedPanelColumn VALUES (4466, 23, N'intGLDetailId', N'GL Detail ID', 100, N'Left', N'Filter', N'', N'', 1, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4467, 23, N'dtmDate', N'Date', 100, N'Left', N'Filter', N'', N'Date', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4468, 23, N'strBatchId', N'Batch ', 100, N'Left', N'Filter', N'', N'', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4469, 23, N'intAccountId', N'Account ID', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4470, 23, N'strAccountGroup', N'Account Group', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4471, 23, N'dblDebit', N'Debit Amount', 100, N'Left', N'Filter', N'', N'$####.00', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4472, 23, N'dblCredit', N'Credit Amount', 100, N'Left', N'Filter', N'', N'$####.00', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4473, 23, N'dblDebitUnit', N'Debit Unit', 100, N'Left', N'Filter', N'', N'', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4474, 23, N'dblCreditUnit', N'Credit Unit', 100, N'Left', N'Filter', N'', N'', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4475, 23, N'strDescription', N'GL Description', 100, N'Left', N'Filter', N'', N'', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4476, 23, N'strCode', N'Code', 100, N'Left', N'Filter', N'', N'', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4477, 23, N'strTransactionId', N'Trans ID', 100, N'Left', N'Filter', N'', N'', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4478, 23, N'strReference', N'Reference', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4479, 23, N'strJobId', N'Job ID', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4480, 23, N'intCurrencyId', N'Currency ID', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4481, 23, N'dblExchangeRate', N'Exchange Rate', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4482, 23, N'dtmDateEntered', N'Date Entered', 100, N'Left', N'Filter', N'', N'', 17, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4483, 23, N'dtmTransactionDate', N'Trans Date', 100, N'Left', N'Filter', N'', N'', 18, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4484, 23, N'strProductId', N'Product ID', 100, N'Left', N'Filter', N'', N'', 19, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4485, 23, N'strWarehouseId', N'Warehouse ID', 100, N'Left', N'Filter', N'', N'', 20, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4486, 23, N'strNum', N'Num', 100, N'Left', N'Filter', N'', N'', 21, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4487, 23, N'strCompanyName', N'Company Name', 100, N'Left', N'Filter', N'', N'', 22, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4488, 23, N'strBillInvoiceNumber', N'Bill Invoice #', 100, N'Left', N'Filter', N'', N'', 23, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4489, 23, N'strJournalLineDescription', N'Journal Line Desc', 100, N'Left', N'Filter', N'', N'', 24, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4490, 23, N'ysnIsUnposted', N'Unposted?', 100, N'Left', N'Filter', N'', N'', 25, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4491, 23, N'intConcurrencyId', N'Concurrency ID', 100, N'Left', N'Filter', N'', N'', 26, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4492, 23, N'intUserID', N'User ID', 100, N'Left', N'Filter', N'', N'', 27, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4493, 23, N'strTransactionForm', N'Trans Form', 100, N'Left', N'Filter', N'', N'', 28, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4494, 23, N'strModuleName', N'Module Name', 100, N'Left', N'Filter', N'', N'', 29, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4495, 23, N'strUOMCode', N'UOM Code', 100, N'Left', N'Filter', N'', N'', 30, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4496, 23, N'intAccountId1', N'Account ID 1', 100, N'Left', N'Filter', N'', N'', 31, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4497, 23, N'strAccountId', N'Account ID', 100, N'Left', N'Filter', N'', N'', 32, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4498, 23, N'strDescription1', N'Description 1', 100, N'Left', N'Filter', N'', N'', 33, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4499, 23, N'strNote', N'Note', 100, N'Left', N'Filter', N'', N'', 34, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4500, 23, N'intAccountGroupId', N'Account Group ID', 100, N'Left', N'Filter', N'', N'', 35, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4501, 23, N'dblOpeningBalance', N'Opening Balance', 100, N'Left', N'Filter', N'', N'', 36, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4502, 23, N'ysnIsUsed', N'Is Used?', 100, N'Left', N'Filter', N'', N'', 37, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4503, 23, N'strComments', N'Comments', 100, N'Left', N'Filter', N'', N'', 40, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4504, 23, N'ysnActive', N'Active', 100, N'Left', N'Filter', N'', N'', 41, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4505, 23, N'ysnSystem', N'System', 100, N'Left', N'Filter', N'', N'', 42, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4506, 23, N'strCashFlow', N'Cash Flow', 100, N'Left', N'Filter', N'', N'', 43, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4507, 23, N'intAccountGroupId1', N'Account Group ID 1', 100, N'Left', N'Filter', N'', N'', 44, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4508, 23, N'strAccountGroup1', N'Account Group 1', 100, N'Left', N'Filter', N'', N'', 45, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4509, 23, N'strAccountType', N'Account Type', 100, N'Left', N'Filter', N'', N'', 46, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4510, 23, N'intParentGroupId', N'Parent Group ID', 100, N'Left', N'Filter', N'', N'', 47, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4511, 23, N'intGroup', N'Group', 100, N'Left', N'Filter', N'', N'', 48, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4512, 23, N'intSort', N'Sort', 100, N'Left', N'Filter', N'', N'', 49, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4513, 23, N'intConcurrencyId2', N'Concurrency ID 2', 100, N'Left', N'Filter', N'', N'', 50, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4514, 23, N'intAccountBegin', N'Account Begin', 100, N'Left', N'Filter', N'', N'', 51, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4515, 23, N'intAccountEnd', N'Account End', 100, N'Left', N'Filter', N'', N'', 52, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4516, 23, N'strAccountGroupNamespace', N'Account Group Name', 100, N'Left', N'Filter', N'', N'', 53, N'', N'', N'', 0, N'Pivot Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (4590, 30, N'glije_acct_no', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (4591, 30, N'glije_date', N'Date', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (4592, 30, N'glije_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (4593, 30, N'glije_ref', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (4594, 30, N'glije_doc', N'Document #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (4595, 30, N'glije_amt', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (4596, 31, N'glije_acct_no', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (4597, 31, N'glije_date', N'Date', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (4598, 31, N'glije_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (4599, 31, N'glije_ref', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (4600, 31, N'glije_doc', N'Document #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (4601, 31, N'glije_amt', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (5096, 234, N'TABLE_NAME', N'Table', 237, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)

INSERT INTO #TempCannedPanelColumn VALUES (5097, 234, N'COLUMN_NAME', N'Column', 234, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)

INSERT INTO #TempCannedPanelColumn VALUES (5098, 234, N'DATA_TYPE', N'Data Type', 156, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)

INSERT INTO #TempCannedPanelColumn VALUES (5099, 234, N'SIZE', N'Size', 155, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)

INSERT INTO #TempCannedPanelColumn VALUES (5100, 234, N'DESCRIPTION', N'Description', 622, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 87)

INSERT INTO #TempCannedPanelColumn VALUES (5101, 225, N'gaaudpay_pmt_audit_no', N'EOD Audit Number', 75, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5102, 225, N'gaaud_pur_sls_ind', N'Sales', 75, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5103, 225, N'gaaud_trans_type', N'Transaction Type', 75, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5104, 225, N'gaaud_in_type', N'', 75, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5105, 225, N'gaaud_key_filler1', N'Key Info', 75, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5106, 225, N'gaaudpay_pmt_rev_dt', N'Payment Date', 75, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5107, 225, N'gaaudpay_chk_no', N'Check Number', 75, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5108, 225, N'gaaudpay_stl_amt', N'Payment Amt', 75, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5109, 225, N'gaaudstl_ivc_no', N'Advance Invoice Number', 75, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5110, 225, N'gaaudpay_cus_ref_no', N'', 74, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5111, 225, N'gaaudstl_stl_amt', N'Advance Payment Amt', 75, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 88)

INSERT INTO #TempCannedPanelColumn VALUES (5112, 226, N'sthss_store_name', N'Store Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 89)

INSERT INTO #TempCannedPanelColumn VALUES (5113, 226, N'FormattedDate', N'Date', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 89)

INSERT INTO #TempCannedPanelColumn VALUES (5114, 226, N'sthss_tot_cash_overshort', N'Over / Short Amount', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 89)

INSERT INTO #TempCannedPanelColumn VALUES (5115, 228, N'Store Name', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 91)

INSERT INTO #TempCannedPanelColumn VALUES (5116, 228, N'Date', N'', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 91)

INSERT INTO #TempCannedPanelColumn VALUES (5117, 228, N'Total Customers', N'', 25, N'Right', N'', N'Sum', N'####', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 91)

INSERT INTO #TempCannedPanelColumn VALUES (5118, 229, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 92)

INSERT INTO #TempCannedPanelColumn VALUES (5119, 229, N'sthss_rev_dt', N'Date', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 92)

INSERT INTO #TempCannedPanelColumn VALUES (5120, 229, N'sthss_key_deptno', N'Dept. #', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 92)

INSERT INTO #TempCannedPanelColumn VALUES (5121, 229, N'sthss_key_desc', N'Description', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 92)

INSERT INTO #TempCannedPanelColumn VALUES (5122, 229, N'sthss_key_total_sales', N'Total Sales', 25, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 92)

INSERT INTO #TempCannedPanelColumn VALUES (5123, 237, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 93)

INSERT INTO #TempCannedPanelColumn VALUES (5124, 237, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 93)

INSERT INTO #TempCannedPanelColumn VALUES (5125, 237, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 93)

INSERT INTO #TempCannedPanelColumn VALUES (5126, 237, N'Retail Price', N'', 25, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 93)

INSERT INTO #TempCannedPanelColumn VALUES (5127, 237, N'Last Price', N'', 25, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 93)

INSERT INTO #TempCannedPanelColumn VALUES (5128, 237, N'On-Hand Qty', N'', 25, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 93)

INSERT INTO #TempCannedPanelColumn VALUES (5129, 237, N'On Order Qty', N'', 25, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 93)

INSERT INTO #TempCannedPanelColumn VALUES (5130, 230, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 94)

INSERT INTO #TempCannedPanelColumn VALUES (5131, 230, N'sthss_pmp_id', N'Fuel Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 94)

INSERT INTO #TempCannedPanelColumn VALUES (5132, 230, N'c', N'Fuel Margins', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 94)

INSERT INTO #TempCannedPanelColumn VALUES (5133, 231, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 95)

INSERT INTO #TempCannedPanelColumn VALUES (5134, 231, N'sthss_pmp_desc', N'Fuel Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 95)

INSERT INTO #TempCannedPanelColumn VALUES (5135, 231, N'c', N'Sales Amount', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 95)

INSERT INTO #TempCannedPanelColumn VALUES (5136, 232, N'sthss_store_name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 96)

INSERT INTO #TempCannedPanelColumn VALUES (5137, 232, N'sthss_pmp_id', N'Fuel Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 96)

INSERT INTO #TempCannedPanelColumn VALUES (5138, 232, N'c', N'Gallons', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 96)

INSERT INTO #TempCannedPanelColumn VALUES (5139, 235, N'Store Name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 97)

INSERT INTO #TempCannedPanelColumn VALUES (5140, 235, N'Dept #', N'Department', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 97)

INSERT INTO #TempCannedPanelColumn VALUES (5141, 235, N'Gross Profit', N'Gross Profit', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 97)

INSERT INTO #TempCannedPanelColumn VALUES (5142, 238, N'UPC #', N'', 100, N'Left', N'Filter', N'', N'', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5143, 238, N'Trans Dt', N'', 100, N'Left', N'Filter', N'', N'Date', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5144, 238, N'Purchase / Sale', N'', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5145, 238, N'Store', N'', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5146, 238, N'Inv #', N'', 100, N'Left', N'Filter', N'', N'', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5147, 238, N'Department', N'', 100, N'Left', N'Filter', N'', N'', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5148, 238, N'Purchase Qty', N'', 100, N'Left', N'Filter', N'', N'####.00', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5149, 238, N'Units Cost', N'', 100, N'Left', N'Filter', N'', N'$####.00', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5150, 238, N'Retail Price', N'', 100, N'Left', N'Filter', N'', N'$####.00', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5151, 238, N'Qty Sold', N'', 100, N'Left', N'Filter', N'', N'####.00', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5152, 238, N'Amount Sold', N'', 100, N'Left', N'Filter', N'', N'$####.00', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5153, 238, N'Month', N'', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5154, 238, N'UPC Desc', N'', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5155, 238, N'Family', N'', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5156, 238, N'Class', N'', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 98)

INSERT INTO #TempCannedPanelColumn VALUES (5157, 236, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 99)

INSERT INTO #TempCannedPanelColumn VALUES (5158, 236, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 99)

INSERT INTO #TempCannedPanelColumn VALUES (5159, 236, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 99)

INSERT INTO #TempCannedPanelColumn VALUES (5160, 236, N'Min Qty', N'', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 99)

INSERT INTO #TempCannedPanelColumn VALUES (5161, 236, N'On-Hand Qty', N'', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 99)

INSERT INTO #TempCannedPanelColumn VALUES (5162, 239, N'Store', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 100)

INSERT INTO #TempCannedPanelColumn VALUES (5163, 239, N'Date', N'', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 100)

INSERT INTO #TempCannedPanelColumn VALUES (5164, 239, N'No Sale Transactions', N'', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 100)

INSERT INTO #TempCannedPanelColumn VALUES (5165, 240, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 101)

INSERT INTO #TempCannedPanelColumn VALUES (5166, 240, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 101)

INSERT INTO #TempCannedPanelColumn VALUES (5167, 240, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 101)

INSERT INTO #TempCannedPanelColumn VALUES (5168, 240, N'Start Date', N'', 25, N'Right', N'', N'', N'Date', 5, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 101)

INSERT INTO #TempCannedPanelColumn VALUES (5169, 240, N'End Date', N'', 25, N'Right', N'', N'', N'Date', 6, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 101)

INSERT INTO #TempCannedPanelColumn VALUES (5170, 240, N'Sale Price', N'', 25, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 101)

INSERT INTO #TempCannedPanelColumn VALUES (5171, 242, N'Store #', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5172, 242, N'UPC #', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5173, 242, N'Item Desc', N'', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5174, 242, N'Vendor ID', N'', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5175, 242, N'Dept #', N'', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5176, 242, N'Family', N'', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5177, 242, N'Class', N'', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5178, 242, N'Case Cost', N'', 25, N'Right', N'', N'Sum', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5179, 242, N'Retail Price', N'', 25, N'Right', N'', N'Sum', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5180, 242, N'Last Price', N'', 25, N'Right', N'', N'Sum', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5181, 242, N'Min Qty', N'', 25, N'Right', N'', N'Sum', N'####', 12, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5182, 242, N'Sug Qty', N'', 25, N'Right', N'', N'Sum', N'####', 13, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5183, 242, N'Min Order Qty', N'', 25, N'Right', N'', N'Sum', N'####', 14, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5184, 242, N'On-Hand Qty', N'', 25, N'Right', N'', N'Sum', N'####', 15, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5185, 242, N'On Order Qty', N'', 25, N'Right', N'', N'Sum', N'####', 16, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5186, 242, N'Qty Sold', N'', 25, N'Right', N'', N'Sum', N'####', 17, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 102)

INSERT INTO #TempCannedPanelColumn VALUES (5187, 241, N'Store', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 103)

INSERT INTO #TempCannedPanelColumn VALUES (5188, 241, N'Date', N'', 25, N'Right', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 103)

INSERT INTO #TempCannedPanelColumn VALUES (5189, 241, N'Refund Amount', N'', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 103)

INSERT INTO #TempCannedPanelColumn VALUES (5190, 243, N'store name', N'Store', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 104)

INSERT INTO #TempCannedPanelColumn VALUES (5191, 243, N'dept #', N'Dept. #', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 104)

INSERT INTO #TempCannedPanelColumn VALUES (5192, 243, N'total sales', N'Total Sales', 25, N'Right', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 104)

INSERT INTO #TempCannedPanelColumn VALUES (5193, 244, N'stphy_store_name', N'Store Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 105)

INSERT INTO #TempCannedPanelColumn VALUES (5194, 244, N'stphy_rev_dt', N'Date', 25, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 105)

INSERT INTO #TempCannedPanelColumn VALUES (5195, 244, N'stphy_shift_no', N'Shift #', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 105)

INSERT INTO #TempCannedPanelColumn VALUES (5196, 244, N'stphy_itm_desc', N'Item', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 105)

INSERT INTO #TempCannedPanelColumn VALUES (5197, 244, N'stphy_diff_qty', N'Diff Qty', 25, N'Left', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'trenner', 6, 0, 0, 0, 0, N'', 0, 1, 105)

INSERT INTO #TempCannedPanelColumn VALUES (5198, 227, N'Store', N'Store', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 90)

INSERT INTO #TempCannedPanelColumn VALUES (5199, 227, N'Cash Over / Short Amount', N'Over / Short Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 90)

INSERT INTO #TempCannedPanelColumn VALUES (5200, 245, N'Trans Dt', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 109)

INSERT INTO #TempCannedPanelColumn VALUES (5201, 245, N'Purchase Qty', N'Purchase Qty', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 109)

INSERT INTO #TempCannedPanelColumn VALUES (5202, 246, N'Trans Dt', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 106)

INSERT INTO #TempCannedPanelColumn VALUES (5203, 246, N'Amount Sold', N'Amount Sold', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 106)

INSERT INTO #TempCannedPanelColumn VALUES (5204, 247, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 107)

INSERT INTO #TempCannedPanelColumn VALUES (5205, 247, N'Total Sales', N'Total Sales', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'trenner', 0, 0, 0, 0, 0, N'', 0, 1, 107)

INSERT INTO #TempCannedPanelColumn VALUES (5206, 248, N'strPanelName', N'', 434, N'Left', N'', N'Count', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 108)

INSERT INTO #TempCannedPanelColumn VALUES (5207, 248, N'strUserName', N'', 434, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 108)

INSERT INTO #TempCannedPanelColumn VALUES (5208, 248, N'strFullName', N'', 433, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'CannedPanel', 0, 0, 0, 0, 0, N'', 0, 1, 108)


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