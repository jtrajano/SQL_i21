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

INSERT INTO #TempCannedPanelColumn VALUES (1, 9, N'agcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 44)

INSERT INTO #TempCannedPanelColumn VALUES (2, 9, N'Amount', N'Amount', 25, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 44)

INSERT INTO #TempCannedPanelColumn VALUES (3, 10, N'Future', N'', 25, N'Left', N'', N'', N'$####.00', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (4, 10, N'Current', N'', 25, N'Left', N'', N'', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (5, 10, N'30days', N'31-60 Days', 25, N'Left', N'', N'', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (6, 10, N'60days', N'61-90 Days', 25, N'Left', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (7, 10, N'90days', N'91-120 Days', 25, N'Left', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (8, 10, N'120days', N'Over 120 Days', 25, N'Left', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 47)

INSERT INTO #TempCannedPanelColumn VALUES (9, 12, N'agcus_key', N'Customer #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 1)

INSERT INTO #TempCannedPanelColumn VALUES (10, 12, N'agcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 1)

INSERT INTO #TempCannedPanelColumn VALUES (11, 12, N'agcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 1)

INSERT INTO #TempCannedPanelColumn VALUES (12, 12, N'agcus_cred_limit', N'Credit Limit', 25, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 1)

INSERT INTO #TempCannedPanelColumn VALUES (13, 12, N'Total Balance', N'Total Balance', 25, N'Right', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 1)

INSERT INTO #TempCannedPanelColumn VALUES (14, 12, N'Overage', N'Overage', 25, N'Right', N'', N'Sum', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 1)

INSERT INTO #TempCannedPanelColumn VALUES (15, 8, N'agitm_no', N'Item #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (16, 8, N'agitm_desc', N'Item Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (17, 8, N'agitm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (18, 8, N'agitm_un_desc', N'Unit Desc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (19, 8, N'agitm_un_on_hand', N'On Hand', 25, N'Right', N'', N'Sum', N'####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (20, 8, N'agitm_un_pend_ivcs', N'Pending Invoices', 25, N'Right', N'', N'Sum', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (21, 8, N'agitm_un_on_order', N'On Order', 25, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (22, 8, N'agitm_un_mfg_in_prs', N'Mfg', 25, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (23, 8, N'agitm_un_fert_committed', N'Contracts Committed', 25, N'Right', N'', N'Sum', N'####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (24, 8, N'agitm_un_ord_committed', N'Orders Committed', 25, N'Right', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (25, 8, N'agitm_un_cnt_committed', N'Other Contracts Committed', 25, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (26, 8, N'Available', N'Available', 25, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (27, 2, N'agitm_no', N'Item#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (28, 2, N'agitm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (29, 2, N'agitm_pak_desc', N'Package', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (30, 2, N'agitm_class', N'Class', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (31, 2, N'agitm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (32, 2, N'agitm_last_un_cost', N'Last Unit Cost', 25, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (33, 2, N'agitm_avg_un_cost', N'Average Unit Cost', 25, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (34, 2, N'agitm_un_on_hand', N'Units On Hand Qty', 25, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 45)

INSERT INTO #TempCannedPanelColumn VALUES (35, 11, N'apcbk_desc', N'Checkbook Name', 25, N'Left', N'', N'', N' ', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 37)

INSERT INTO #TempCannedPanelColumn VALUES (36, 11, N'apcbk_no', N'Checkbook #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 37)

INSERT INTO #TempCannedPanelColumn VALUES (37, 11, N'apcbk_bal', N'Checkbook Balance', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 37)

INSERT INTO #TempCannedPanelColumn VALUES (38, 14, N'apivc_ivc_no', N'Invoice#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (39, 14, N'apivc_ivc_rev_dt', N'Invoice Date', 25, N'Right', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (40, 14, N'apivc_vnd_no', N'Vendor #', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (41, 14, N'ssvnd_name', N'Vendor', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (42, 14, N'amounts', N'Amount Due', 25, N'Right', N'', N'', N'$###0.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (43, 14, N'apivc_due_rev_dt', N'Due Date', 25, N'Right', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 73)

INSERT INTO #TempCannedPanelColumn VALUES (44, 15, N'apchk_rev_dt', N'Date', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 35)

INSERT INTO #TempCannedPanelColumn VALUES (45, 15, N'apchk_name', N'Check Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 35)

INSERT INTO #TempCannedPanelColumn VALUES (46, 15, N'apchk_chk_amt', N'Check Amount', 25, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 35)

INSERT INTO #TempCannedPanelColumn VALUES (47, 16, N'apivc_ivc_no', N'Invoice #', 10, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 38)

INSERT INTO #TempCannedPanelColumn VALUES (48, 16, N'apivc_ivc_rev_dt', N'Invoice Date', 25, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 38)

INSERT INTO #TempCannedPanelColumn VALUES (49, 16, N'apivc_vnd_no', N'Vendor #', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 38)

INSERT INTO #TempCannedPanelColumn VALUES (50, 16, N'ssvnd_name', N'Vendor Name', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 38)

INSERT INTO #TempCannedPanelColumn VALUES (51, 16, N'amounts', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 38)

INSERT INTO #TempCannedPanelColumn VALUES (52, 18, N'Customer Last Name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 69)

INSERT INTO #TempCannedPanelColumn VALUES (53, 18, N'First Name', N'First Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 69)

INSERT INTO #TempCannedPanelColumn VALUES (54, 18, N'Customer Code', N'Customer Code', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 69)

INSERT INTO #TempCannedPanelColumn VALUES (55, 18, N'Sales', N'Sales', 25, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 69)

INSERT INTO #TempCannedPanelColumn VALUES (56, 18, N'Units', N'Units', 25, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 69)

INSERT INTO #TempCannedPanelColumn VALUES (57, 19, N'agstm_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 70)

INSERT INTO #TempCannedPanelColumn VALUES (58, 19, N'agitm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 70)

INSERT INTO #TempCannedPanelColumn VALUES (59, 19, N'Sales', N'Sales', 25, N'Right', N'', N'', N'$###0.00', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 70)

INSERT INTO #TempCannedPanelColumn VALUES (60, 19, N'Units', N'Units', 25, N'Right', N'', N'', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 70)

INSERT INTO #TempCannedPanelColumn VALUES (61, 20, N'agcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 46)

INSERT INTO #TempCannedPanelColumn VALUES (62, 20, N'agstm_key_loc_no', N'Location', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 46)

INSERT INTO #TempCannedPanelColumn VALUES (63, 20, N'agstm_key_loc_no', N'Location', 0, N'Series2AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 46)

INSERT INTO #TempCannedPanelColumn VALUES (64, 20, N'Sales', N'Sales Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 46)

INSERT INTO #TempCannedPanelColumn VALUES (65, 20, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 46)

INSERT INTO #TempCannedPanelColumn VALUES (66, 21, N'agitm_no', N'Item #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (67, 21, N'agitm_desc', N'Item/Product', 45, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (68, 21, N'agitm_loc_no', N'Loc', 15, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (69, 21, N'agitm_un_desc', N'Unit Desc', 15, N'Left', N'', N'', N' ', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (70, 21, N'agitm_un_on_hand', N'On Hand Qty', 25, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (71, 21, N'agitm_last_sale_rev_dt', N'Last Sale Date', 25, N'Right', N'', N'', N'Date', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 72)

INSERT INTO #TempCannedPanelColumn VALUES (72, 22, N'ard_cus_no', N'Customer#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (73, 22, N'ard_ord_no', N'Order#', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (74, 22, N'ard_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (75, 22, N'ard_ord_rev_dt', N'Order Date', 25, N'Right', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (76, 22, N'ard_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (77, 22, N'ard_pkg_sold', N'Packages Sold', 25, N'Right', N'', N'', N'####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 52)

INSERT INTO #TempCannedPanelColumn VALUES (78, 1, N'agstm_bill_to_cus', N'Bill To Customer', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (79, 1, N'agstm_ivc_no', N'Invoice #', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (80, 1, N'agstm_ship_rev_dt', N'Ship Date', 25, N'Right', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (81, 1, N'agstm_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (82, 1, N'agstm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (83, 1, N'agstm_class', N'Class Code', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (84, 1, N'agstm_un', N'Units Sold', 25, N'Right', N'', N'', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (85, 1, N'agstm_un_prc', N'Unit Price', 25, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (86, 1, N'agstm_sls', N'Sales Amount', 25, N'Right', N'', N'', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (87, 1, N'agstm_un_cost', N'Unit Costs', 25, N'Right', N'', N'', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (88, 1, N'agstm_cgs', N'Costs Amount', 25, N'Right', N'', N'', N'$####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (89, 1, N'agstm_slsmn_id', N'Salesperson', 25, N'Left', N'', N'', N'', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (90, 1, N'agstm_pak_desc', N'Package Desc', 25, N'Left', N'', N'', N'', 14, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (91, 1, N'agstm_un_desc', N'Unit Desc', 25, N'Left', N'', N'', N'', 15, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (92, 1, N'unit margins', N'Unit Margins', 25, N'Right', N'', N'', N'$####.000', 16, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (93, 1, N'Profit Amount', N'Profit Amount', 25, N'Right', N'', N'', N'$###0.000', 17, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (94, 1, N'Profit Percent', N'Profit Percent', 25, N'Right', N'', N'', N'##.###%', 18, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 49)

INSERT INTO #TempCannedPanelColumn VALUES (95, 24, N'strDescription', N'Description', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (96, 24, N'dblDebit', N'Debit ', 25, N'Left', N'', N'Sum', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (97, 24, N'dblCredit', N'Credit', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (98, 24, N'Balance', N'Balance', 25, N'Left', N'', N'Sum', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (99, 24, N'strAccountID', N'AccountID', 25, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (100, 24, N'dtmDate', N'Date', 25, N'Left', N'', N'', N'Date', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (101, 24, N'strTransactionID', N'Document', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (102, 24, N'strReference', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (103, 13, N'apchk_cbk_no', N'Checkbook #', 25, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (104, 13, N'apchk_rev_dt', N'Date', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (105, 13, N'apchk_vnd_no', N'Vendor #', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (106, 13, N'apchk_name', N'Vendor Name', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (107, 13, N'apchk_chk_amt', N'Check Amount', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (108, 13, N'apchk_disc_amt', N'Discount Amount', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (109, 13, N'apchk_gl_rev_dt', N'GL Date', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (110, 13, N'apchk_cleared_ind', N'Cleared?', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (111, 13, N'apchk_clear_rev_dt', N'Cleared Date', 25, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (112, 13, N'apchk_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 36)

INSERT INTO #TempCannedPanelColumn VALUES (113, 26, N'strAccountID', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 77)

INSERT INTO #TempCannedPanelColumn VALUES (114, 26, N'strDescription', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 77)

INSERT INTO #TempCannedPanelColumn VALUES (115, 26, N'Amount', N'', 25, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 77)

INSERT INTO #TempCannedPanelColumn VALUES (116, 23, N'intGLDetailID', N'', 100, N'Left', N'Filter', N'', N'', 1, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (117, 23, N'dtmDate', N'', 100, N'Left', N'Filter', N'', N'Date', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (118, 23, N'strBatchID', N'', 100, N'Left', N'Filter', N'', N'', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (119, 23, N'intAccountID', N'', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (120, 23, N'strAccountGroup', N'', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (121, 23, N'dblDebit', N'', 100, N'Left', N'Filter', N'', N'$####.00', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (122, 23, N'dblCredit', N'', 100, N'Left', N'Filter', N'', N'$####.00', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (123, 23, N'dblDebitUnit', N'', 100, N'Left', N'Filter', N'', N'', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (124, 23, N'dblCreditUnit', N'', 100, N'Left', N'Filter', N'', N'', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (125, 23, N'strDescription', N'', 100, N'Left', N'Filter', N'', N'', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (126, 23, N'strCode', N'', 100, N'Left', N'Filter', N'', N'', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (127, 23, N'strTransactionID', N'', 100, N'Left', N'Filter', N'', N'', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (128, 23, N'strReference', N'', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (129, 23, N'strJobID', N'', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (130, 23, N'intCurrencyID', N'', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (131, 23, N'dblExchangeRate', N'', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (132, 23, N'dtmDateEntered', N'', 100, N'Left', N'Filter', N'', N'', 17, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (133, 23, N'dtmTransactionDate', N'', 100, N'Left', N'Filter', N'', N'', 18, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (134, 23, N'strProductID', N'', 100, N'Left', N'Filter', N'', N'', 19, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (135, 23, N'strWarehouseID', N'', 100, N'Left', N'Filter', N'', N'', 20, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (136, 23, N'strNum', N'', 100, N'Left', N'Filter', N'', N'', 21, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (137, 23, N'strCompanyName', N'', 100, N'Left', N'Filter', N'', N'', 22, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (138, 23, N'strBillInvoiceNumber', N'', 100, N'Left', N'Filter', N'', N'', 23, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (139, 23, N'strJournalLineDescription', N'', 100, N'Left', N'Filter', N'', N'', 24, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (140, 23, N'ysnIsUnposted', N'', 100, N'Left', N'Filter', N'', N'', 25, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (141, 23, N'intConcurrencyID', N'', 100, N'Left', N'Filter', N'', N'', 26, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (142, 23, N'intUserID', N'', 100, N'Left', N'Filter', N'', N'', 27, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (143, 23, N'strTransactionForm', N'', 100, N'Left', N'Filter', N'', N'', 28, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (144, 23, N'strModuleName', N'', 100, N'Left', N'Filter', N'', N'', 29, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (145, 23, N'strUOMCode', N'', 100, N'Left', N'Filter', N'', N'', 30, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (146, 23, N'intAccountID1', N'', 100, N'Left', N'Filter', N'', N'', 31, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (147, 23, N'strAccountID', N'', 100, N'Left', N'Filter', N'', N'', 32, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (148, 23, N'strDescription1', N'', 100, N'Left', N'Filter', N'', N'', 33, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (149, 23, N'strNote', N'', 100, N'Left', N'Filter', N'', N'', 34, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (150, 23, N'intAccountGroupID', N'', 100, N'Left', N'Filter', N'', N'', 35, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (151, 23, N'dblOpeningBalance', N'', 100, N'Left', N'Filter', N'', N'', 36, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (152, 23, N'ysnIsUsed', N'', 100, N'Left', N'Filter', N'', N'', 37, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (153, 23, N'intConcurrencyID1', N'', 100, N'Left', N'Filter', N'', N'', 38, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (154, 23, N'intAccountUnitID', N'', 100, N'Left', N'Filter', N'', N'', 39, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (155, 23, N'strComments', N'', 100, N'Left', N'Filter', N'', N'', 40, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (156, 23, N'ysnActive', N'', 100, N'Left', N'Filter', N'', N'', 41, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (157, 23, N'ysnSystem', N'', 100, N'Left', N'Filter', N'', N'', 42, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (158, 23, N'strCashFlow', N'', 100, N'Left', N'Filter', N'', N'', 43, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (159, 23, N'intAccountGroupID1', N'', 100, N'Left', N'Filter', N'', N'', 44, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (160, 23, N'strAccountGroup1', N'', 100, N'Left', N'Filter', N'', N'', 45, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (161, 23, N'strAccountType', N'', 100, N'Left', N'Filter', N'', N'', 46, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (162, 23, N'intParentGroupID', N'', 100, N'Left', N'Filter', N'', N'', 47, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (163, 23, N'intGroup', N'', 100, N'Left', N'Filter', N'', N'', 48, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (164, 23, N'intSort', N'', 100, N'Left', N'Filter', N'', N'', 49, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (165, 23, N'intConcurrencyID2', N'', 100, N'Left', N'Filter', N'', N'', 50, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (166, 23, N'intAccountBegin', N'', 100, N'Left', N'Filter', N'', N'', 51, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (167, 23, N'intAccountEnd', N'', 100, N'Left', N'Filter', N'', N'', 52, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (168, 23, N'strAccountGroupNamespace', N'', 100, N'Left', N'Filter', N'', N'', 53, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 74)

INSERT INTO #TempCannedPanelColumn VALUES (169, 24, N'strAccountGroup', N'Account Group', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 75)

INSERT INTO #TempCannedPanelColumn VALUES (170, 25, N'strAccountID', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 76)

INSERT INTO #TempCannedPanelColumn VALUES (171, 25, N'strDescription', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 76)

INSERT INTO #TempCannedPanelColumn VALUES (172, 25, N'Balance', N'', 25, N'Left', N'', N'Sum', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 76)

INSERT INTO #TempCannedPanelColumn VALUES (173, 27, N'strAccountID', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 78)

INSERT INTO #TempCannedPanelColumn VALUES (174, 27, N'strDescription', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 78)

INSERT INTO #TempCannedPanelColumn VALUES (175, 27, N'Amount', N'', 25, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 78)

INSERT INTO #TempCannedPanelColumn VALUES (176, 28, N'strAccountID', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 79)

INSERT INTO #TempCannedPanelColumn VALUES (177, 28, N'strDescription', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 79)

INSERT INTO #TempCannedPanelColumn VALUES (178, 28, N'Amount', N'', 25, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 79)

INSERT INTO #TempCannedPanelColumn VALUES (179, 29, N'strAccountID', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 80)

INSERT INTO #TempCannedPanelColumn VALUES (180, 29, N'strDescription', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 80)

INSERT INTO #TempCannedPanelColumn VALUES (181, 29, N'Amount', N'', 25, N'Left', N'', N'Sum', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 80)

INSERT INTO #TempCannedPanelColumn VALUES (182, 30, N'glije_acct_no', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (183, 30, N'glije_date', N'Date', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (184, 30, N'glije_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (185, 30, N'glije_ref', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (186, 30, N'glije_doc', N'Document #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (187, 30, N'glije_amt', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 28)

INSERT INTO #TempCannedPanelColumn VALUES (188, 31, N'glije_acct_no', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (189, 31, N'glije_date', N'Date', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (190, 31, N'glije_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (191, 31, N'glije_ref', N'Reference', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (192, 31, N'glije_doc', N'Document #', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (193, 31, N'glije_amt', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 29)

INSERT INTO #TempCannedPanelColumn VALUES (194, 34, N'Period', N'', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 81)

INSERT INTO #TempCannedPanelColumn VALUES (195, 34, N'TotalBalance', N'', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 81)

INSERT INTO #TempCannedPanelColumn VALUES (196, 40, N'pxrpt_trans_type', N'Trans Type', 25, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (197, 40, N'pxrpt_trans_rev_dt', N'Trans Date', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (198, 40, N'pxrpt_ord_no', N'Order #', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (199, 40, N'pxrpt_car_name', N'Carrier', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (200, 40, N'pxrpt_cus_name', N'Customer', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (201, 40, N'pxrpt_cus_state', N'Customer State', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (202, 40, N'pxrpt_itm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (203, 40, N'pxrpt_itm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (204, 40, N'pxrpt_vnd_name', N'Vendor', 25, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (205, 40, N'pxrpt_vnd_state', N'Vendor State', 25, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (206, 40, N'pxrpt_pur_gross_un', N'Gross Units Purchased', 25, N'Left', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (207, 40, N'pxrpt_pur_net_un', N'Net Units Purchased', 25, N'Left', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (208, 40, N'pxrpt_pur_fet_amt', N'FET', 25, N'Left', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (209, 40, N'pxrpt_pur_set_amt', N'SET', 25, N'Left', N'', N'Sum', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (210, 40, N'pxrpt_pur_sst_amt', N'SST', 25, N'Left', N'', N'Sum', N'$####.00', 16, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (211, 40, N'pxrpt_pur_lc1_amt', N'LC1', 25, N'Left', N'', N'Sum', N'$####.00', 17, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (212, 40, N'pxrpt_pur_lc2_amt', N'LC2', 25, N'Left', N'', N'Sum', N'$####.00', 18, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (213, 40, N'pxrpt_pur_lc3_amt', N'LC3', 25, N'Left', N'', N'Sum', N'$####.00', 19, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (214, 40, N'pxrpt_pur_lc4_amt', N'LC4', 25, N'Left', N'', N'Sum', N'$####.00', 20, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (215, 40, N'pxrpt_pur_un_received', N'Units Received', 25, N'Left', N'', N'Sum', N'####.00', 21, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (216, 40, N'pxrpt_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (217, 40, N'pxrpt_itm_dyed_yn', N'Dyed?', 25, N'Left', N'', N'', N'', 22, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 24)

INSERT INTO #TempCannedPanelColumn VALUES (218, 32, N'pxrpt_trans_type', N'Trans Type', 25, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (219, 32, N'pxrpt_trans_rev_dt', N'Trans Date', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (220, 32, N'pxrpt_src_sys', N'Source System', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (221, 32, N'pxrpt_ord_no', N'Order #', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (222, 32, N'pxrpt_car_name', N'Carrier', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (223, 32, N'pxrpt_cus_name', N'Customer', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (224, 32, N'pxrpt_cus_state', N'Customer State', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (225, 32, N'pxrpt_itm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (226, 32, N'pxrpt_itm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (227, 32, N'pxrpt_vnd_name', N'Vendor ', 25, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (228, 32, N'pxrpt_vnd_state', N'Vendor State', 25, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (229, 32, N'pxrpt_sls_trans_gals', N'Sales Units', 25, N'Left', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (230, 32, N'pxrpt_sls_fet_amt', N'FET', 25, N'Left', N'', N'Sum', N'$####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (231, 32, N'pxrpt_sls_set_amt', N'SET', 25, N'Left', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (232, 32, N'pxrpt_sls_lc1_amt', N'LC1', 25, N'Left', N'', N'Sum', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (233, 32, N'pxrpt_sls_lc2_amt', N'LC2', 25, N'Left', N'', N'Sum', N'$####.00', 16, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (234, 32, N'pxrpt_sls_lc3_amt', N'LC3', 25, N'Left', N'', N'Sum', N'$####.00', 17, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (235, 32, N'pxrpt_sls_lc4_amt', N'LC4', 25, N'Left', N'', N'Sum', N'$####.00', 18, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (236, 32, N'pxrpt_itm_dyed_yn', N'Dyed?', 25, N'Left', N'', N'', N'', 19, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (237, 32, N'pxrpt_cus_acct_stat', N'Cus  Acct Status ', 25, N'Left', N'', N'', N'', 20, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 25)

INSERT INTO #TempCannedPanelColumn VALUES (238, 33, N'gacnt_pur_sls_ind', N'P/S', 25, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (239, 33, N'gacnt_cus_no', N'Customer #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (240, 33, N'agcus_last_name', N'Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (241, 33, N'agcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (242, 33, N'gacnt_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (243, 33, N'gacnt_com_cd', N'Com', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (244, 33, N'gacnt_cnt_no', N'Contact #', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (245, 33, N'gacnt_seq_no', N'Seq', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (246, 33, N'gacnt_mkt_zone', N'Market Zone', 25, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (247, 33, N'gacnt_beg_ship_rev_dt', N'Beg Ship Date', 25, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (248, 33, N'gacnt_due_rev_dt', N'Due Date', 25, N'Right', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (249, 33, N'gacnt_pbhcu_ind', N'PBHU', 25, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (250, 33, N'gacnt_un_bal', N'Unit Balance', 25, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 17)

INSERT INTO #TempCannedPanelColumn VALUES (251, 41, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 16)

INSERT INTO #TempCannedPanelColumn VALUES (252, 41, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 16)

INSERT INTO #TempCannedPanelColumn VALUES (253, 41, N'units', N'Purchased Units', 0, N'Series1AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 16)

INSERT INTO #TempCannedPanelColumn VALUES (254, 41, N'units', N'Sales Units', 0, N'Series2AxisY', N'', N'', N'Number', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 16)

INSERT INTO #TempCannedPanelColumn VALUES (255, 37, N'gahdg_com_cd', N'Com', 25, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (256, 37, N'gahdg_broker_no', N'Broker #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (257, 37, N'gahdg_rev_dt', N'Date', 25, N'Right', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (258, 37, N'gahdg_ref', N'Ref#', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (259, 37, N'gahdg_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (260, 37, N'gahdg_bot_prc', N'BOT Price', 25, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (261, 37, N'gahdg_bot_basis', N'BOT Basis', 25, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (262, 37, N'gahdg_bot', N'BOT', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (263, 37, N'gahdg_bot_option', N'BOT Option', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (264, 37, N'gahdg_long_short_ind', N'L / S', 25, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (265, 37, N'gahdg_un_hdg_bal', N'Balance', 25, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (266, 37, N'gahdg_offset_yn', N'Offset?', 25, N'Left', N'', N'', N'Yes/No', 14, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (267, 37, N'gahdg_hedge_yyyymm', N'Hedge', 25, N'Right', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 21)

INSERT INTO #TempCannedPanelColumn VALUES (268, 38, N'gastr_pur_sls_ind', N'P or S', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 22)

INSERT INTO #TempCannedPanelColumn VALUES (269, 38, N'gastr_com_cd', N'Com', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 22)

INSERT INTO #TempCannedPanelColumn VALUES (270, 38, N'gastr_stor_type', N'Type', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 22)

INSERT INTO #TempCannedPanelColumn VALUES (271, 38, N'gastr_cus_no', N'Customer #', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 22)

INSERT INTO #TempCannedPanelColumn VALUES (272, 38, N'gastr_un_bal', N'Unit Balance', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 22)

INSERT INTO #TempCannedPanelColumn VALUES (273, 42, N'gaphs_pur_sls_ind', N'P / S', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (274, 42, N'gaphs_cus_no', N'Customer Code', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (275, 42, N'gaphs_com_cd', N'Com', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (276, 42, N'gaphs_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (277, 42, N'gaphs_tic_no', N'Ticket #', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (278, 42, N'gaphs_cus_ref_no', N'Customer Ref', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (279, 42, N'gaphs_gross_wgt', N'Gross Weight', 25, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (280, 42, N'gaphs_tare_wgt', N'Tare Weight', 25, N'Right', N'', N'Sum', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (281, 42, N'gaphs_gross_un', N'Gross Units', 25, N'Right', N'', N'Sum', N'####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (282, 42, N'gaphs_wet_un', N'Wet Units', 25, N'Right', N'', N'Sum', N'####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (283, 42, N'gaphs_net_un', N'Net Units', 25, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (284, 42, N'gaphs_fees', N'Fees', 25, N'Right', N'', N'Sum', N'$####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (285, 42, N'gaphs_dlvry_rev_dt', N'Delivery Date', 25, N'Right', N'', N'', N'', 15, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 23)

INSERT INTO #TempCannedPanelColumn VALUES (286, 43, N'gaitr_pur_sls_ind', N'P or S', 5, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (287, 43, N'gaitr_loc_no', N'Loc', 6, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (288, 43, N'gaitr_cus_no', N'Cust#', 15, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (289, 43, N'agcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (290, 43, N'agcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (291, 43, N'gacom_desc', N'Com', 15, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (292, 43, N'gaitr_tic_no', N'Ticket', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (293, 43, N'gaitr_un_out', N'Units', 25, N'Right', N'', N'Sum', N'####.000', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 15)

INSERT INTO #TempCannedPanelColumn VALUES (294, 44, N'gacnt_pur_sls_ind', N'P or S', 25, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (295, 44, N'gacnt_com_cd', N'Com', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (296, 44, N'Option Month', N'Option Month', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (297, 44, N'Option Year', N'Option Year', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (298, 44, N'Balance', N'Balance', 25, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (299, 44, N'Price', N'Price', 25, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (300, 44, N'Extended Amount', N'Ext Amount', 25, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (301, 44, N'WAP', N'WAP', 25, N'Right', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (302, 44, N'WAB', N'WAB', 25, N'Right', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (303, 44, N'WAF', N'WAF', 25, N'Right', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (304, 44, N'gacnt_due_rev_dt', N'Due Date', 25, N'Right', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (305, 44, N'gacnt_cnt_no', N'Contract #', 25, N'Right', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 18)

INSERT INTO #TempCannedPanelColumn VALUES (306, 3, N'gacom_desc', N'Com', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 19)

INSERT INTO #TempCannedPanelColumn VALUES (307, 3, N'gapos_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 19)

INSERT INTO #TempCannedPanelColumn VALUES (308, 3, N'gapos_in_house', N'In House', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 19)

INSERT INTO #TempCannedPanelColumn VALUES (309, 3, N'gapos_offsite', N'Offsite', 25, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 19)

INSERT INTO #TempCannedPanelColumn VALUES (310, 3, N'gapos_sls_in_transit', N'In Transit', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 19)

INSERT INTO #TempCannedPanelColumn VALUES (311, 45, N'pttic_cus_no', N'Customer#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (312, 45, N'ptcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (313, 45, N'ptcus_first_name', N'Customer Name', 25, N'Left', N'', N'', N' ', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (314, 45, N'pttic_itm_no', N'Item#', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (315, 45, N'pttic_qty_orig', N'Quantity', 25, N'Right', N'', N'Sum', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (316, 45, N'pttic_tic_no', N'Ticket #', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (317, 45, N'pttic_rev_dt', N'Date', 25, N'Right', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 56)

INSERT INTO #TempCannedPanelColumn VALUES (318, 46, N'Current', N'Current', 25, N'Center', N'', N'', N'$####.00', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 67)

INSERT INTO #TempCannedPanelColumn VALUES (319, 46, N'31-60 Days', N'31-60 Days', 25, N'Center', N'', N'', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 67)

INSERT INTO #TempCannedPanelColumn VALUES (320, 46, N'61-90 Days', N'61-90 Days', 25, N'Center', N'', N'', N'$####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 67)

INSERT INTO #TempCannedPanelColumn VALUES (321, 46, N'91-120 Days', N'91-120 Days', 25, N'Center', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 67)

INSERT INTO #TempCannedPanelColumn VALUES (322, 46, N'Over 120 Days', N'Over 120 Days', 25, N'Center', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 67)

INSERT INTO #TempCannedPanelColumn VALUES (323, 47, N'ptcus_cus_no', N'Customer Code', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 68)

INSERT INTO #TempCannedPanelColumn VALUES (324, 47, N'ptcus_last_name', N'Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 68)

INSERT INTO #TempCannedPanelColumn VALUES (325, 47, N'ptcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 68)

INSERT INTO #TempCannedPanelColumn VALUES (326, 47, N'ptcus_ar_ov120', N'Amount', 25, N'Right', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 68)

INSERT INTO #TempCannedPanelColumn VALUES (327, 48, N'ptitm_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (328, 48, N'ptitm_desc', N'Item/Product', 45, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (329, 48, N'ptitm_loc_no', N'Loc', 15, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (330, 48, N'ptitm_unit', N'Unit Desc', 15, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (331, 48, N'ptitm_on_hand', N'On Hand Qty', 25, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (332, 48, N'ptitm_last_sale_rev_dt', N'Last Sale Date', 25, N'Right', N'', N'', N'Date', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 71)

INSERT INTO #TempCannedPanelColumn VALUES (333, 52, N'ptcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 62)

INSERT INTO #TempCannedPanelColumn VALUES (334, 52, N'ptcus_first_name', N'First Name', 25, N'Left', N'', N'', N' ', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 62)

INSERT INTO #TempCannedPanelColumn VALUES (335, 52, N'ptcus_cus_no', N'Customer Code', 25, N'Left', N'', N' ', N' ', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 62)

INSERT INTO #TempCannedPanelColumn VALUES (336, 52, N'Sales', N'Sales', 25, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 62)

INSERT INTO #TempCannedPanelColumn VALUES (337, 52, N'Units', N'Units', 25, N'Right', N'', N'', N'####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 62)

INSERT INTO #TempCannedPanelColumn VALUES (338, 53, N'ptcus_cus_no', N'Customer#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (339, 53, N'ptcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (340, 53, N'ptcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (341, 53, N'ptcus_credit_limit', N'Credit Limit', 25, N'Right', N'', N'', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (342, 53, N'Total Balance', N'Total Balance', 25, N'Right', N'', N'', N'$####.00', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (343, 53, N'overage', N'Overage', 25, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 64)

INSERT INTO #TempCannedPanelColumn VALUES (344, 4, N'ptstm_bill_to_cus', N'Bill To Cus', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (345, 4, N'ptstm_ivc_no', N'Invoice #', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (346, 4, N'ptstm_ship_rev_dt', N'Ship Date', 25, N'Right', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (347, 4, N'ptstm_itm_no', N'Item#', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (348, 4, N'ptstm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (349, 4, N'ptstm_class', N'Class Code', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (350, 4, N'ptstm_un', N'Units Sold', 25, N'Right', N'', N'', N'####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (351, 4, N'ptstm_un_prc', N'Unit Price', 25, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (352, 4, N'ptstm_net', N'Sales', 25, N'Right', N'', N'', N'$####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (353, 4, N'ptstm_cgs', N'Costs', 25, N'Right', N'', N'', N'$####.00', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (354, 4, N'ptstm_slsmn_id', N'Salesperson', 25, N'Left', N'', N'', N'', 12, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (355, 4, N'ptstm_pak_desc', N'Package Desc', 25, N'Left', N'', N'', N'', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (356, 4, N'ptstm_un_desc', N'Unit Desc', 25, N'Left', N'', N'', N'', 14, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (357, 4, N'Profit Amount', N'Profit Amount', 25, N'Right', N'', N'', N'$####.00', 15, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (358, 4, N'Profit Percent', N'Profit Percentage', 25, N'Right', N'', N'', N'##.###%', 16, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 57)

INSERT INTO #TempCannedPanelColumn VALUES (359, 5, N'ptitm_itm_no', N'Item#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (360, 5, N'ptitm_desc', N'Item/Product', 45, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (361, 5, N'ptitm_loc_no', N'Loc', 15, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (362, 5, N'ptitm_class', N'Class', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (363, 5, N'ptitm_unit', N'Unit Desc', 15, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (364, 5, N'ptitm_cost1', N'Last Costs', 25, N'Right', N'', N'', N'$####.00', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (365, 5, N'ptitm_avg_cost', N'Average Costs', 25, N'Right', N'', N'', N'$####.00', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (366, 5, N'ptitm_std_cost', N'Standard Costs', 25, N'Right', N'', N'', N'$####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (367, 5, N'ptitm_on_hand', N'Units On Hand', 25, N'Right', N'', N'', N'####.00', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 63)

INSERT INTO #TempCannedPanelColumn VALUES (368, 6, N'agcnt_cus_no', N'Customer#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (369, 6, N'agcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (370, 6, N'agcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (371, 6, N'agcnt_slsmn_id', N'Salesperson ID', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (372, 6, N'agcnt_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (373, 6, N'agcnt_cnt_no', N'Contract #', 25, N'Left', N'', N'Count', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (374, 6, N'agcnt_cnt_rev_dt', N'Contract Date', 25, N'Right', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (375, 6, N'agcnt_due_rev_dt', N'Due Date', 25, N'Right', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (376, 6, N'agcnt_itm_or_cls', N'Item or Class', 25, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (377, 6, N'agcnt_prc_lvl', N'Price Level', 25, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (378, 6, N'agcnt_ppd_yndm', N'Prepaid', 25, N'Left', N'', N'', N'Yes/No', 12, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (379, 6, N'agcnt_un_orig', N'Original Units', 25, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (380, 6, N'agcnt_un_bal', N'Unit Balance', 25, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 50)

INSERT INTO #TempCannedPanelColumn VALUES (381, 9, N'agcus_first_name', N'Customer First Name', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 44)

INSERT INTO #TempCannedPanelColumn VALUES (382, 9, N'agcus_key', N'Customer #', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 44)

INSERT INTO #TempCannedPanelColumn VALUES (383, 8, N'agitm_class', N'Class', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 53)

INSERT INTO #TempCannedPanelColumn VALUES (384, 50, N'Location', N'Location', 0, N'Series1AxisX', N'', N'', N'General', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 59)

INSERT INTO #TempCannedPanelColumn VALUES (385, 50, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 59)

INSERT INTO #TempCannedPanelColumn VALUES (386, 49, N'ptstm_itm_no', N'Item #', 25, N'Left', N'', N'', N'', 1, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 58)

INSERT INTO #TempCannedPanelColumn VALUES (387, 49, N'ptitm_desc', N'Description', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 58)

INSERT INTO #TempCannedPanelColumn VALUES (388, 49, N'Sales', N'Sales', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 58)

INSERT INTO #TempCannedPanelColumn VALUES (389, 49, N'Units', N'Units', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 58)

INSERT INTO #TempCannedPanelColumn VALUES (390, 51, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 60)

INSERT INTO #TempCannedPanelColumn VALUES (391, 51, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 60)

INSERT INTO #TempCannedPanelColumn VALUES (392, 51, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 60)

INSERT INTO #TempCannedPanelColumn VALUES (393, 51, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 60)

INSERT INTO #TempCannedPanelColumn VALUES (394, 17, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 65)

INSERT INTO #TempCannedPanelColumn VALUES (395, 17, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 65)

INSERT INTO #TempCannedPanelColumn VALUES (396, 17, N'Sales', N'Sales', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 65)

INSERT INTO #TempCannedPanelColumn VALUES (397, 17, N'Costs', N'Costs', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 65)

INSERT INTO #TempCannedPanelColumn VALUES (398, 36, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 83)

INSERT INTO #TempCannedPanelColumn VALUES (399, 36, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 83)

INSERT INTO #TempCannedPanelColumn VALUES (400, 39, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 84)

INSERT INTO #TempCannedPanelColumn VALUES (401, 39, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 84)

INSERT INTO #TempCannedPanelColumn VALUES (402, 35, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 82)

INSERT INTO #TempCannedPanelColumn VALUES (403, 35, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 82)

INSERT INTO #TempCannedPanelColumn VALUES (404, 34, N'Period', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 81)

INSERT INTO #TempCannedPanelColumn VALUES (405, 34, N'TotalBalance', N'Total Balance', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 81)

INSERT INTO #TempCannedPanelColumn VALUES (406, 56, N'cftrx_ar_cus_no', N'A/R Customer #', 100, N'Left', N'Filter', N'', N'', 1, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (407, 56, N'cftrx_card_no', N'Card #', 100, N'Left', N'Filter', N'', N'', 2, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (408, 56, N'cfcus_card_desc', N'Card Desc', 100, N'Left', N'Filter', N'', N'', 3, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (409, 56, N'cftrx_rev_dt', N'Date', 100, N'Left', N'Filter', N'', N'', 4, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (410, 56, N'cftrx_qty', N'Quantity', 100, N'Left', N'Filter', N'', N'', 5, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (411, 56, N'cftrx_prc', N'Price', 100, N'Left', N'Filter', N'', N'', 6, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (412, 56, N'cftrx_calc_total', N'Calc Total', 100, N'Left', N'Filter', N'', N'', 7, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (413, 56, N'cftrx_ar_itm_no', N'A/R Item #', 100, N'Left', N'Filter', N'', N'', 8, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (414, 56, N'cftrx_ar_itm_loc_no', N'Loc ', 100, N'Left', N'Filter', N'', N'', 9, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (415, 56, N'cftrx_sls_id', N'Salesperson ID', 100, N'Left', N'Filter', N'', N'', 10, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (416, 56, N'cftrx_sell_prc', N'Sell Price', 100, N'Left', N'Filter', N'', N'', 11, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (417, 56, N'cftrx_prc_per_un', N'Price per Unit', 100, N'Left', N'Filter', N'', N'', 12, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (418, 56, N'cftrx_site', N'Site', 100, N'Left', N'Filter', N'', N'', 13, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (419, 56, N'cftrx_time', N'Time', 100, N'Left', N'Filter', N'', N'', 14, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (420, 56, N'cftrx_odometer', N'Odometer', 100, N'Left', N'Filter', N'', N'', 15, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (421, 56, N'cftrx_site_state', N'Site State', 100, N'Left', N'Filter', N'', N'', 16, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (422, 56, N'cftrx_site_county', N'Site County', 100, N'Left', N'Filter', N'', N'', 17, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (423, 56, N'cftrx_site_city', N'Site City', 100, N'Left', N'Filter', N'', N'', 18, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (424, 56, N'cftrx_selling_host_id', N'Selling Host ID', 100, N'Left', N'Filter', N'', N'', 19, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (425, 56, N'cftrx_buying_host_id', N'Buying Host ID', 100, N'Left', N'Filter', N'', N'', 20, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (426, 56, N'cftrx_po_no', N'PO #', 100, N'Left', N'Filter', N'', N'', 21, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (427, 56, N'cftrx_ar_ivc_no', N'A/R Invoice #', 100, N'Left', N'Filter', N'', N'', 22, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (428, 56, N'cftrx_calc_fet_amt', N'Calc FET Amount', 100, N'Left', N'Filter', N'', N'', 23, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (429, 56, N'cftrx_calc_set_amt', N'Calc SET Amount', 100, N'Left', N'Filter', N'', N'', 24, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (430, 56, N'cftrx_calc_sst_amt', N'Calc SST Amount', 100, N'Left', N'Filter', N'', N'', 25, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (431, 56, N'cftrx_tax_cls_id', N'Tax Class ID', 100, N'Left', N'Filter', N'', N'', 26, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (432, 56, N'cftrx_ivc_prtd_yn', N'Inv Printed ?', 100, N'Left', N'Filter', N'', N'', 27, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (433, 56, N'cftrx_vehl_no', N'Vehicle #', 100, N'Left', N'Filter', N'', N'', 28, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (434, 56, N'cftrx_calc_net_sell_prc', N'Calc Net Sell', 100, N'Left', N'Filter', N'', N'', 29, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (435, 56, N'cftrx_pump_no', N'Pump No', 100, N'Left', N'Filter', N'', N'', 30, N'', N'', N'', 0, N'Pivot Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 85)

INSERT INTO #TempCannedPanelColumn VALUES (436, 54, N'gacom_desc', N'Com', 25, N'Left', N'', N'', N'', 2, N'', N'', N'gacommst.gacom_desc', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 20)

INSERT INTO #TempCannedPanelColumn VALUES (437, 54, N'totals', N'Totals', 25, N'Right', N'', N'', N'####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 20)

INSERT INTO #TempCannedPanelColumn VALUES (438, 55, N'CheckDate', N'Check Date', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 39)

INSERT INTO #TempCannedPanelColumn VALUES (439, 55, N'Amount', N'Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 39)

INSERT INTO #TempCannedPanelColumn VALUES (440, 57, N'agitm_no', N'Item #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 54)

INSERT INTO #TempCannedPanelColumn VALUES (441, 57, N'agitm_desc', N'Item Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 54)

INSERT INTO #TempCannedPanelColumn VALUES (442, 57, N'agitm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 4, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 54)

INSERT INTO #TempCannedPanelColumn VALUES (443, 57, N'Available', N'Available', 25, N'Right', N'', N'Sum', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 54)

INSERT INTO #TempCannedPanelColumn VALUES (444, 58, N'agitm_no', N'Item#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 51)

INSERT INTO #TempCannedPanelColumn VALUES (445, 58, N'agitm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 51)

INSERT INTO #TempCannedPanelColumn VALUES (446, 58, N'agitm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 51)

INSERT INTO #TempCannedPanelColumn VALUES (447, 58, N'agitm_un_on_hand', N'Units On Hand Qty', 25, N'Right', N'', N'Sum', N'####.00', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 51)

INSERT INTO #TempCannedPanelColumn VALUES (448, 59, N'agstm_ivc_no', N'Invoice #', 25, N'Left', N'', N'', N'', 2, N'', N'', N'agstm_ivc_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 43)

INSERT INTO #TempCannedPanelColumn VALUES (449, 59, N'agstm_ship_rev_dt', N'Ship Date', 25, N'Right', N'', N'', N'Date', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 43)

INSERT INTO #TempCannedPanelColumn VALUES (450, 59, N'Profit Percent', N'Profit Percent', 25, N'Right', N'', N'', N'##.###%', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 43)

INSERT INTO #TempCannedPanelColumn VALUES (451, 60, N'agstm_bill_to_cus', N'Bill To #', 25, N'Left', N'', N'', N' ', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 42)

INSERT INTO #TempCannedPanelColumn VALUES (452, 60, N'agitm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 2, N'', N'', N'agitm_desc', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 42)

INSERT INTO #TempCannedPanelColumn VALUES (453, 60, N'agitm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 3, N'', N'', N'agitm_loc_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 42)

INSERT INTO #TempCannedPanelColumn VALUES (454, 60, N'agitm_un_on_hand', N'On Hand Inventory', 25, N'Right', N'', N'Sum', N'####.00', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 42)

INSERT INTO #TempCannedPanelColumn VALUES (455, 61, N'agcnt_cus_no', N'Customer#', 25, N'Left', N'', N'', N'', 2, N'', N'', N'agcnt_cus_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (456, 61, N'agcus_last_name', N'Customer Last Name', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (457, 61, N'agcus_first_name', N'First Name', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (458, 61, N'agcnt_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 6, N'', N'', N'agcnt_loc_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (459, 61, N'agcnt_cnt_no', N'Contract #', 25, N'Left', N'', N'Count', N'', 7, N'', N'', N'agcnt_cnt_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (460, 61, N'agcnt_un_bal', N'Unit Balance', 25, N'Right', N'', N'Sum', N'####.00', 14, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 48)

INSERT INTO #TempCannedPanelColumn VALUES (461, 62, N'ptitm_itm_no', N'Item Code', 25, N'Left', N'', N'', N'', 2, N'', N'', N'ptitm_itm_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 55)

INSERT INTO #TempCannedPanelColumn VALUES (462, 62, N'ptitm_desc', N'Item/Product', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 55)

INSERT INTO #TempCannedPanelColumn VALUES (463, 62, N'ptitm_loc_no', N'Loc', 25, N'Left', N'', N'', N' ', 4, N'', N'', N'ptitm_loc_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 55)

INSERT INTO #TempCannedPanelColumn VALUES (464, 62, N'ptitm_on_hand', N'On-Hand Quantity', 25, N'Right', N'', N'Sum', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 55)

INSERT INTO #TempCannedPanelColumn VALUES (465, 63, N'ptstm_bill_to_cus', N'Bill To Cus', 25, N'Left', N'', N'', N'', 2, N'', N'', N'ptstm_bill_to_cus', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 61)

INSERT INTO #TempCannedPanelColumn VALUES (466, 63, N'ptstm_ivc_no', N'Invoice #', 25, N'Left', N'', N'', N'', 3, N'', N'', N'ptstm_ivc_no', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 61)

INSERT INTO #TempCannedPanelColumn VALUES (467, 63, N'ptstm_ship_rev_dt', N'Ship Date', 25, N'Right', N'', N'', N'Date', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 61)

INSERT INTO #TempCannedPanelColumn VALUES (468, 63, N'Profit Percent', N'Profit Percentage', 25, N'Right', N'', N'', N'##.###%', 16, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 61)

INSERT INTO #TempCannedPanelColumn VALUES (469, 64, N'ptitm_itm_no', N'Item Code', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 66)

INSERT INTO #TempCannedPanelColumn VALUES (470, 64, N'ptitm_desc', N'Item/Product', 45, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 66)

INSERT INTO #TempCannedPanelColumn VALUES (471, 64, N'ptitm_loc_no', N'Loc', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 66)

INSERT INTO #TempCannedPanelColumn VALUES (472, 64, N'ptitm_on_hand', N'On Hand Quantity', 25, N'Right', N'', N'', N'####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 66)

INSERT INTO #TempCannedPanelColumn VALUES (473, 7, N'glhst_acct1_8', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (474, 7, N'glhst_acct9_16', N'Profit Center', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (475, 7, N'glhst_ref', N'Reference', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (476, 7, N'glhst_period', N'Period', 25, N'Left', N'', N'', N'', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (477, 7, N'glhst_trans_dt', N'Transaction Date', 25, N'Left', N'', N'', N'', 6, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (478, 7, N'glhst_src_id', N'Source ID', 25, N'Left', N'', N'', N'', 7, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (479, 7, N'glhst_src_seq', N'Source Sequence', 25, N'Left', N'', N'', N'', 8, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (480, 7, N'glhst_dr_cr_ind', N'Credit/Debit', 25, N'Left', N'', N'', N'', 9, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (481, 7, N'glhst_jrnl_no', N'Journal #', 25, N'Left', N'', N'', N'', 10, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (482, 7, N'glhst_doc', N'Document #', 25, N'Left', N'', N'', N'', 11, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (483, 7, N'Amount', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 12, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (484, 7, N'glhst_units', N'Units', 25, N'Left', N'', N'', N'####.00', 13, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 26)

INSERT INTO #TempCannedPanelColumn VALUES (485, 65, N'glhst_acct1_8', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'glhstmst.glhst_acct1_8', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 27)

INSERT INTO #TempCannedPanelColumn VALUES (486, 65, N'glhst_acct9_16', N'Profit Center', 25, N'Left', N'', N'', N'', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 27)

INSERT INTO #TempCannedPanelColumn VALUES (487, 65, N'glact_desc', N'GL Desc', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 27)

INSERT INTO #TempCannedPanelColumn VALUES (488, 65, N'Amount', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 5, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 27)

INSERT INTO #TempCannedPanelColumn VALUES (489, 66, N'glact_acct1_8', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'glhst_acct1_8', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 30)

INSERT INTO #TempCannedPanelColumn VALUES (490, 66, N'glact_acct9_16', N'Profit Center', 25, N'Left', N'', N'', N'', 3, N'', N'', N'glhst_acct9_16', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 30)

INSERT INTO #TempCannedPanelColumn VALUES (491, 66, N'glact_desc', N'Description', 25, N'Left', N'', N'', N'', 4, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 30)

INSERT INTO #TempCannedPanelColumn VALUES (492, 67, N'glact_desc', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 31)

INSERT INTO #TempCannedPanelColumn VALUES (493, 67, N'Amount', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 31)

INSERT INTO #TempCannedPanelColumn VALUES (494, 68, N'glact_desc', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 32)

INSERT INTO #TempCannedPanelColumn VALUES (495, 68, N'Amount', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 32)

INSERT INTO #TempCannedPanelColumn VALUES (496, 69, N'glact_desc', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 33)

INSERT INTO #TempCannedPanelColumn VALUES (497, 69, N'Amount', N'Amount', 25, N'Left', N'', N' ', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 33)

INSERT INTO #TempCannedPanelColumn VALUES (498, 70, N'glact_desc', N'GL Acct', 25, N'Left', N'', N'', N'', 2, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 34)

INSERT INTO #TempCannedPanelColumn VALUES (499, 70, N'Amount', N'Amount', 25, N'Left', N'', N'Sum', N'$####.00', 3, N'', N'', N'', 0, N'Grid', N'', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 34)

INSERT INTO #TempCannedPanelColumn VALUES (500, 71, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 40)

INSERT INTO #TempCannedPanelColumn VALUES (501, 71, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 40)

INSERT INTO #TempCannedPanelColumn VALUES (502, 71, N'Amount', N'Revenue Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 40)

INSERT INTO #TempCannedPanelColumn VALUES (503, 71, N'Amount', N'Expense Amount', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 40)

INSERT INTO #TempCannedPanelColumn VALUES (504, 72, N'Month', N'Month', 0, N'Series1AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series1AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 41)

INSERT INTO #TempCannedPanelColumn VALUES (505, 72, N'Month', N'Month', 0, N'Series2AxisX', N'', N'', N'Month', 1, N'', N'', N'', 1, N'Chart', N'Series2AxisX', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 41)

INSERT INTO #TempCannedPanelColumn VALUES (506, 72, N'Amount', N'Assets Amount', 0, N'Series1AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series1AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 41)

INSERT INTO #TempCannedPanelColumn VALUES (507, 72, N'Amount', N'Liabilities Amount', 0, N'Series2AxisY', N'', N'', N'Currency', 2, N'', N'', N'', 1, N'Chart', N'Series2AxisY', N'Nicholas', 0, 0, 0, 0, 0, N'', 0, 1, 41)


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