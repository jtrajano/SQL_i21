PRINT '*Start Create BUSINESS INSIGHTS DASHBOARD*'
--IF NOT EXISTS (SELECT TOP 1 1 FROM tblDBPanelTab WHERE strTabName = 'Business Insights' AND ysnSystemTab = 1)
--BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @entityId INT
			DECLARE @panelTabId INT
			DECLARE @cashProjectionChartPanelId INT
			DECLARE @cashProjectionGridPanelId INT
			DECLARE @grossMarginChartPanelId INT
			DECLARE @grossMarginGridPanelId INT
			DECLARE @customerAgingChartPanelId INT
			DECLARE @customerAgingGridPanelId INT
			DECLARE @salesChartPanelId INT
			DECLARE @salesGridPanelId INT
			DECLARE @aggregator NVARCHAR(MAX)


			SELECT @entityId = intEntityId FROM tblSMUserSecurity where UPPER(strUserName) = 'IRELYADMIN'
			IF ISNULL(@entityId, 0) = 0
			BEGIN
				SELECT TOP 1 @entityId = intEntityId  FROM tblSMUserSecurity where ysnAdmin = 1 and ysnDisabled = 0
			END

			IF ISNULL(@entityId, 0) <> 0
			BEGIN
				IF NOT EXISTS (SELECT TOP 1 1 FROM tblDBPanelTab WHERE strTabName = 'Business Insights' AND ysnSystemTab = 1)
				BEGIN
					INSERT INTO tblDBPanelTab (
						[intSort], [intUserId], [intColumn1Width], [intColumn2Width], [intColumn3Width], [intColumn4Width], [intColumn5Width], [intColumn6Width], [intColumnCount], [strTabName], 
						[strRenameTabName], [intConcurrencyId ], [ysnDefaultTab], [ysnSystemTab]
					)
					VALUES (
						0, @entityId, 300, 300, 300, 300, 300, 300, 2, 
						N'Business Insights', N'', 1, 0, 1
					)

					SELECT @panelTabId = SCOPE_IDENTITY()
				END
				ELSE
				BEGIN
					SELECT TOP 1 @panelTabId = intPanelTabId FROM tblDBPanelTab WHERE strTabName = 'Business Insights' AND ysnSystemTab = 1
				END

				--CREATE ALL 8 PANELS--
				--Customer Aging Chart
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblDBPanel WHERE strPanelName = 'Customer Aging Chart' AND ysnSystemPanel = 1)
				BEGIN
					INSERT INTO tblDBPanel (
						[intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId],
						[intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition],
						[strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription],
						[strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2],
						[strGroupFields],  [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId],
						[intConcurrencyId], [intCannedPanelId], [strSortValue], [ysnAutoRefresh], [intAutoRefreshInterval],	[strOrderByVariable], [strOrderByFieldName], [ysnOrderByFieldDescending],
						[intGridLayoutId], [strTableName], [strColumnName],	[ysnSystemPanel], [ysnSystemPanelChild]
					)
					VALUES (
						5, 7, 100, 400, @entityId, 0, 0, 0,	0, 1,	
						0,	N'Master', N'Customer Aging Chart', N'Chart', N'', N'Customer Aging', N'3D Pie', N'rotate', N'Base', NULL, N'None',
						N'None', N'', N'', N'select top 5 strCustomerName, intEntityCustomerId, dblTotalDue from vyuARCustomerAging_DashBoard', N'', N'@DATE@', N'@DATE@', N'', N'',	
						NULL, N'', N'',	N'None', N'', N'', N'',	N'',
						N'', N'', N'', 0, 0, NULL, NULL, N'20.1.1',	NULL,
						1, 0, N'', NULL, NULL, N'@ORDERBY@', N'', 0, 
						NULL, NULL, NULL, 1, NULL
					)

					SELECT @customerAgingChartPanelId = SCOPE_IDENTITY()

					--INSERT THE COLUMNS
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@customerAgingChartPanelId, N'strCustomerName', N'Customer', 0, N'Series1AxisX', N'', N'', N'General', 0, N'', N'', N'',
						1, N'Chart', N'Series1AxisX', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.String', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@customerAgingChartPanelId, N'dblTotalDue', N'Total Due', 0, N'Series1AxisY', N'', N'', N'Round', 1, N'', N'', N'',
						1, N'Chart', N'Series1AxisY', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.Decimal', N'', NULL
					)

					--INSERT PANEL OWNER
					INSERT INTO tblDBPanelOwner (
						[intPanelId], [intUserId], [intConcurrencyId]
					)
					VALUES (
						@customerAgingChartPanelId, @entityId, 1
					)

					--INSERT PANEL LAYOUT
					INSERT INTO tblDBPanelUser (
						[intPanelId], [intSort], [intPanelTabId], [intColumn], [intUserId], [ysnSystemPanelVisible], [intConcurrencyId ]
					)
					VALUES (
						@customerAgingChartPanelId, 1, @panelTabId, 1, @entityId, 1, 1
					)
				END
				ELSE
				BEGIN
					SELECT @customerAgingChartPanelId = intPanelId FROM tblDBPanel WHERE strPanelName = 'Customer Aging Chart' AND ysnSystemPanel = 1

					UPDATE tblDBPanel SET ysnChartLegend = 0 WHERE strPanelName = 'Customer Aging Chart' AND ysnSystemPanel = 1
					UPDATE tblDBPanelColumn SET strFormat = N'Round' WHERE intPanelId = @customerAgingChartPanelId AND strAlignment = 'Series1AxisY'
					UPDATE tblDBPanelUser SET intSort = 1 WHERE intPanelId = @customerAgingChartPanelId and intPanelTabId = @panelTabId
				END

				--Customer Aging Grid
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblDBPanel WHERE strPanelName = 'Customer Aging Grid' AND ysnSystemPanel = 1)
				BEGIN
					INSERT INTO tblDBPanel (
						[intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId],
						[intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition],
						[strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription],
						[strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2],
						[strGroupFields],  [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId],
						[intConcurrencyId], [intCannedPanelId], [strSortValue], [ysnAutoRefresh], [intAutoRefreshInterval],	[strOrderByVariable], [strOrderByFieldName], [ysnOrderByFieldDescending],
						[intGridLayoutId], [strTableName], [strColumnName],	[ysnSystemPanel], [ysnSystemPanelChild]
					)
					VALUES (
						0, 5, 100, 250, @entityId, 0, 0, 0,	0, 1,	
						0,	N'Master', N'Customer Aging Grid', N'Grid', N'', N'Customer Aging', N'3D Pie', N'rotate', N'Red', NULL, N'None',
						N'None', N'', N'', N'select distinct a.strCustomerNumber, a.strInvoiceNumber, b.dblTotalDue  from vyuARCustomerAgingInvoice a  inner join vyuARCustomerAging_DashBoard b on a.intEntityCustomerId = b.intEntityCustomerId order by b.dblTotalDue desc', N'', N'@DATE@', N'@DATE@', N'', N'',	
						NULL, N'', N'',	N'None', N'', N'', N'',	N'',
						N'', N'', N'', 1, 0, NULL, NULL, N'20.1.1',	NULL,
						1, 0, N'', NULL, NULL, N'@ORDERBY@', N'', 0, NULL, NULL, NULL, 1, 1
					)

					SELECT @customerAgingGridPanelId = SCOPE_IDENTITY()

					--INSERT THE COLUMNS
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ], [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@customerAgingGridPanelId, N'strCustomerNumber', N'Customer', 100, N'Left', N'Row', N'', N'', 1, N'', N'', N'',
						0, N'Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ], [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@customerAgingGridPanelId, N'strInvoiceNumber', N'Invoice', 100, N'Left', N'Data', N'', N'', 2, N'', N'', N'',
						0, N'Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'', N'AccountsReceivable.view.Invoice', NULL
					)
					

					--INSERT PANEL OWNER
					INSERT INTO tblDBPanelOwner (
						[intPanelId], [intUserId], [intConcurrencyId]
					)
					VALUES (
						@customerAgingGridPanelId, @entityId, 1
					)

					--INSERT PANEL LAYOUT
					INSERT INTO tblDBPanelUser (
						[intPanelId], [intSort], [intPanelTabId], [intColumn], [intUserId], [ysnSystemPanelVisible], [intConcurrencyId ]
					)
					VALUES (
						@customerAgingGridPanelId, 2, @panelTabId, 1, @entityId, 0, 1
					)
				END
				ELSE
				BEGIN
					SELECT @customerAgingGridPanelId = intPanelId FROM tblDBPanel WHERE strPanelName = 'Customer Aging Grid' AND ysnSystemPanel = 1

					UPDATE tblDBPanelUser SET ysnSystemPanelVisible = 0 WHERE intPanelId = @customerAgingGridPanelId AND intPanelTabId = @panelTabId
					UPDATE tblDBPanelUser SET intSort = 2 WHERE intPanelId = @customerAgingGridPanelId and intPanelTabId = @panelTabId
				END

				--Sales Chart
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblDBPanel WHERE strPanelName = 'Sales Chart' AND ysnSystemPanel = 1)
				BEGIN
					INSERT INTO tblDBPanel (
						[intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId],
						[intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition],
						[strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription],
						[strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2],
						[strGroupFields],  [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId],
						[intConcurrencyId], [intCannedPanelId], [strSortValue], [ysnAutoRefresh], [intAutoRefreshInterval],	[strOrderByVariable], [strOrderByFieldName], [ysnOrderByFieldDescending],
						[intGridLayoutId], [strTableName], [strColumnName],	[ysnSystemPanel], [ysnSystemPanelChild]
					)
					VALUES (
						5, 5, 100, 400, @entityId, 0, 0, 0,	0, 1,	
						0,	N'Master', N'Sales Chart', N'Chart', N'', N'Sales', N'Column Stacked', N'insideEnd', N'Blue', NULL, N'None',
						N'None', N'', N'', N'select SUM(dblTotal) as Total, strItemNo from vyuARInvoiceSalesDWM group by strItemNo order by Total desc, strItemNo asc', N'', N'@DATE@', N'@DATE@', N'', N'',	
						NULL, N'', N'',	N'None', N'', N'', N'',	N'',
						N'', N'', N'', 0, 0, NULL, NULL, N'20.1.1',	NULL,
						1, 0, N'', NULL, NULL, N'@ORDERBY@', N'', 0, 
						NULL, NULL, NULL, 1, NULL
					)

					SELECT @salesChartPanelId = SCOPE_IDENTITY()

					--INSERT THE COLUMNS
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@salesChartPanelId, N'strItemNo', N'Item No', 0, N'Series1AxisX', N'', N'', N'General', 0, N'', N'', N'',
						1, N'Chart', N'Series1AxisX', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.Decimal', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@salesChartPanelId, N'Total', N'Revenue', 0, N'Series1AxisY', N'', N'', N'Round', 1, N'', N'', N'',
						1, N'Chart', N'Series1AxisY', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.String', N'', NULL
					)

					--INSERT PANEL OWNER
					INSERT INTO tblDBPanelOwner (
						[intPanelId], [intUserId], [intConcurrencyId]
					)
					VALUES (
						@salesChartPanelId, @entityId, 1
					)

					--INSERT PANEL LAYOUT
					INSERT INTO tblDBPanelUser (
						[intPanelId], [intSort], [intPanelTabId], [intColumn], [intUserId], [ysnSystemPanelVisible], [intConcurrencyId ]
					)
					VALUES (
						@salesChartPanelId, 1, @panelTabId, 2, @entityId, 1, 1
					)
				END
				ELSE
				BEGIN
					SELECT @salesChartPanelId = intPanelId FROM tblDBPanel WHERE strPanelName = 'Sales Chart' AND ysnSystemPanel = 1

					UPDATE tblDBPanel SET ysnChartLegend = 0 WHERE strPanelName = 'Sales Chart' AND ysnSystemPanel = 1
					UPDATE tblDBPanelColumn SET strFormat = N'Round' WHERE intPanelId = @salesChartPanelId AND strAlignment = 'Series1AxisY'
					UPDATE tblDBPanelUser SET intSort = 1 WHERE intPanelId = @salesChartPanelId and intPanelTabId = @panelTabId
				END

				--Sales Grid
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblDBPanel WHERE strPanelName = 'Sales Grid' AND ysnSystemPanel = 1)
				BEGIN
					INSERT INTO tblDBPanel (
						[intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId],
						[intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition],
						[strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription],
						[strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2],
						[strGroupFields],  [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId],
						[intConcurrencyId], [intCannedPanelId], [strSortValue], [ysnAutoRefresh], [intAutoRefreshInterval],	[strOrderByVariable], [strOrderByFieldName], [ysnOrderByFieldDescending],
						[intGridLayoutId], [strTableName], [strColumnName],	[ysnSystemPanel], [ysnSystemPanelChild]
					)
					VALUES (
						5, 5, 100, 250, @entityId, 0, 0, 0,	0, 1,	
						0,	N'Master', N'Sales Grid', N'Grid', N'', N'Sales', N'Column Stacked', N'insideEnd', N'Blue', NULL, N'None',
						N'None', N'', N'', N'select SUM(dblTotal) as Total, strItemNo from vyuARInvoiceSalesDWM group by strItemNo order by Total desc, strItemNo asc', N'', N'@DATE@', N'@DATE@', N'', N'',	
						NULL, N'', N'',	N'None', N'', N'', N'',	N'',
						N'', N'', N'', 1, 0, NULL, NULL, N'20.1.1',	NULL,
						1, 0, N'', NULL, NULL, N'@ORDERBY@', N'', 0, NULL, NULL, NULL, 1, 1
					)

					SELECT @salesGridPanelId = SCOPE_IDENTITY()

					--INSERT THE COLUMNS
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ], [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@salesGridPanelId, N'strItemNo', N'Item No', 100, N'Left', N'', N'', N'', 1, N'', N'', N'',
						1, N'Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.String', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ], [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@salesGridPanelId, N'Total', N'Revenue', 100, N'Left', N'', N'', N'###0.00', 0, N'', N'', N'',
						1, N'Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.Decimal', N'', NULL
					)

					--INSERT PANEL OWNER
					INSERT INTO tblDBPanelOwner (
						[intPanelId], [intUserId], [intConcurrencyId]
					)
					VALUES (
						@salesGridPanelId, @entityId, 1
					)

					--INSERT PANEL LAYOUT
					INSERT INTO tblDBPanelUser (
						[intPanelId], [intSort], [intPanelTabId], [intColumn], [intUserId], [ysnSystemPanelVisible], [intConcurrencyId ]
					)
					VALUES (
						@salesGridPanelId, 2, @panelTabId, 2, @entityId, 0, 1
					)
				END
				ELSE
				BEGIN
					SELECT @salesGridPanelId = intPanelId FROM tblDBPanel WHERE strPanelName = 'Sales Grid' AND ysnSystemPanel = 1

					UPDATE tblDBPanelColumn SET strFormat = '###0.00' WHERE intPanelId = @salesGridPanelId AND strColumn IN ('Total')
					UPDATE tblDBPanelUser SET ysnSystemPanelVisible = 0 WHERE intPanelId = @salesGridPanelId AND intPanelTabId = @panelTabId
					UPDATE tblDBPanelUser SET intSort = 2 WHERE intPanelId = @salesGridPanelId and intPanelTabId = @panelTabId
				END

				--Cash Projection Chart
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblDBPanel WHERE strPanelName = 'Cash Projection Chart' AND ysnSystemPanel = 1)
				BEGIN
					INSERT INTO tblDBPanel (
						[intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId],
						[intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition],
						[strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription],
						[strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2],
						[strGroupFields],  [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId],
						[intConcurrencyId], [intCannedPanelId], [strSortValue], [ysnAutoRefresh], [intAutoRefreshInterval],	[strOrderByVariable], [strOrderByFieldName], [ysnOrderByFieldDescending],
						[intGridLayoutId], [strTableName], [strColumnName],	[ysnSystemPanel], [ysnSystemPanelChild]
					)
					VALUES (
						5, 7, 100, 300, @entityId, 0, 0, 0,	0, 1,	
						0, N'Master', N'Cash Projection Chart', N'Chart', N'', N'Cash Projection', N'Line', N'over', N'Base', NULL,	N'None',
						N'None', N'', N'', N'select * from vyuCMCashProjection', N'', N'@DATE@', N'@DATE@', N'', N'',	
						NULL, N'', N'',	N'None', N'', N'', N'',	N'',	
						N'', N'', N'', 0, 0, NULL, NULL, N'20.1.1',	NULL,
						1, 0, N'', NULL, NULL, N'@ORDERBY@', N'', 0, 
						NULL, NULL, NULL, 1, NULL
					)

					SELECT @cashProjectionChartPanelId = SCOPE_IDENTITY()

					--INSERT THE COLUMNS
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@cashProjectionChartPanelId, N'WeekNo', N'Week No', 0, N'Series1AxisX', N'', N'', N'Currency', 0, N'', N'', N'',
						1, N'Chart', N'Series1AxisX', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@cashProjectionChartPanelId, N'NetAmount', N'Net Amount', 0, N'Series1AxisY', N'', N'', N'Round', 1, N'', N'', N'',
						1, N'Chart', N'Series1AxisY', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'', N'', NULL
					)

					--INSERT PANEL OWNER
					INSERT INTO tblDBPanelOwner (
						[intPanelId], [intUserId], [intConcurrencyId]
					)
					VALUES (
						@cashProjectionChartPanelId, @entityId, 1
					)

					--INSERT PANEL LAYOUT
					INSERT INTO tblDBPanelUser (
						[intPanelId], [intSort], [intPanelTabId], [intColumn], [intUserId], [ysnSystemPanelVisible], [intConcurrencyId ]
					)
					VALUES (
						@cashProjectionChartPanelId, 3, @panelTabId, 1, @entityId, 1, 1
					)
				END
				ELSE
				BEGIN
					SELECT @cashProjectionChartPanelId = intPanelId FROM tblDBPanel WHERE strPanelName = 'Cash Projection Chart' AND ysnSystemPanel = 1

					UPDATE tblDBPanel SET ysnChartLegend = 0 WHERE strPanelName = 'Cash Projection Chart' AND ysnSystemPanel = 1
					UPDATE tblDBPanelColumn SET strFormat = N'Round' WHERE intPanelId = @cashProjectionChartPanelId AND strAlignment = 'Series1AxisY'
					UPDATE tblDBPanelUser SET intSort = 3 WHERE intPanelId = @cashProjectionChartPanelId and intPanelTabId = @panelTabId
				END

				--Cash Projection Grid
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblDBPanel WHERE strPanelName = 'Cash Projection Grid' AND ysnSystemPanel = 1)
				BEGIN
					INSERT INTO tblDBPanel (
						[intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId],
						[intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition],
						[strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription],
						[strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2],
						[strGroupFields],  [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId],
						[intConcurrencyId], [intCannedPanelId], [strSortValue], [ysnAutoRefresh], [intAutoRefreshInterval],	[strOrderByVariable], [strOrderByFieldName], [ysnOrderByFieldDescending],
						[intGridLayoutId], [strTableName], [strColumnName],	[ysnSystemPanel], [ysnSystemPanelChild]
					)
					VALUES (
						0, 8, 100, 250, @entityId, 0, 0, 0,	0, 1,	
						0, N'Master', N'Cash Projection Grid', N'Pivot Grid', N'', N'Cash Projection', N'Bar', N'outside', N'Base',	NULL, N'None',
						N'None', N'', N'', N'select * from vyuCMCashProjection', N'', N'@DATE@', N'@DATE@', N'', N'',	
						NULL, N'', N'',	N'None', N'', N'', N'', N'',	
						N'', N'', N'', 1, 0, NULL, NULL, N'20.1.1',	NULL,
						1, 0, N'', NULL, NULL, N'@ORDERBY@', N'', 0, NULL, NULL, NULL,	1,	1
					)

					SELECT @cashProjectionGridPanelId = SCOPE_IDENTITY()

					--INSERT THE COLUMNS
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@cashProjectionGridPanelId, N'WeekNo', N'Week', 100, N'Left', N'Column', N'', N'', 1, N'', N'', N'',
						0, N'Pivot Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.String', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@cashProjectionGridPanelId, N'dblAmountDue', N'Amount Due', 100, N'Left', N'Data', N'', N'###0.00', 2, N'', N'', N'',
						0, N'Pivot Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.Decimal', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@cashProjectionGridPanelId, N'RunningTotal', N'Running Total', 100, N'Left', N'Data', N'', N'###0.00', 3, N'', N'', N'',
						0, N'Pivot Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.Decimal', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@cashProjectionGridPanelId, N'NetAmount', N'Net Amount', 100, N'Left', N'Data', N'', N'###0.00', 4, N'', N'', N'',
						0, N'Pivot Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.Decimal', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@cashProjectionGridPanelId, N'FirsDayOfWeek', N'First Day of the Week', 100, N'Left', N'Row', N'', N'Date', 5, N'', N'', N'',
						0, N'Pivot Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'', N'', NULL
					)

					--INSERT PANEL OWNER
					INSERT INTO tblDBPanelOwner (
						[intPanelId], [intUserId], [intConcurrencyId]
					)
					VALUES (
						@cashProjectionGridPanelId, @entityId, 1
					)

					--INSERT PANEL LAYOUT
					INSERT INTO tblDBPanelUser (
						[intPanelId], [intSort], [intPanelTabId], [intColumn], [intUserId], [ysnSystemPanelVisible], [intConcurrencyId ]
					)
					VALUES (
						@cashProjectionGridPanelId, 4, @panelTabId, 1, @entityId, 0, 1
					)

					--UPDATE strConfigurator for Pivot Grid
					SET @aggregator = N'{
						"aggregate":[{
							"align":"Left",
							"sortable":true,
							"header":"Amount Due",
							"dataIndex":"dblAmountDue",
							"measure":"dblAmountDue",
							"aggregator":"sum",
							"width":100,
							"isAggregate":true,
							"showZeroAsBlank":false
						},
						{
							"align":"Left",
							"sortable":true,
							"header":"Running Total",
							"dataIndex":"RunningTotal",
							"measure":"RunningTotal",
							"aggregator":"sum",
							"width":100,
							"isAggregate":true,
							"showZeroAsBlank":false
						},
						{
							"align":"Left",
							"sortable":true,
							"header":"Net Amount",
							"dataIndex":"NetAmount",
							"measure":"NetAmount",
							"aggregator":"sum",
							"width":100,
							"isAggregate":true,
							"showZeroAsBlank":false
						}],
						"leftAxis":[{
							"align":"Left",
							"sortable":true,
							"header":"First Day of the Week",
							"dataIndex":"FirsDayOfWeek",
							"width":120,
							"colFormat":"m/d/Y"
						}],
						"topAxis":[{
							"align":"Left",
							"sortable":true,
							"header":"Week",
							"dataIndex":"WeekNo"
						}]
					}';
					UPDATE tblDBPanel SET strConfigurator = @aggregator WHERE intPanelId = @cashProjectionGridPanelId
				END
				ELSE
				BEGIN
					SELECT @cashProjectionGridPanelId = intPanelId FROM tblDBPanel WHERE strPanelName = 'Cash Projection Grid' AND ysnSystemPanel = 1

					UPDATE tblDBPanelColumn SET strFormat = '###0.00' WHERE intPanelId = @cashProjectionGridPanelId AND strColumn IN ('dblAmountDue', 'RunningTotal', 'NetAmount')
					UPDATE tblDBPanelUser SET ysnSystemPanelVisible = 0 WHERE intPanelId = @cashProjectionGridPanelId AND intPanelTabId = @panelTabId
					UPDATE tblDBPanelUser SET intSort = 4 WHERE intPanelId = @cashProjectionGridPanelId and intPanelTabId = @panelTabId
				END

				--Gross Margin Chart
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblDBPanel WHERE strPanelName = 'Gross Margin Chart' AND ysnSystemPanel = 1)
				BEGIN
					INSERT INTO tblDBPanel (
						[intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId],
						[intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition],
						[strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription],
						[strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2],
						[strGroupFields],  [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId],
						[intConcurrencyId], [intCannedPanelId], [strSortValue], [ysnAutoRefresh], [intAutoRefreshInterval],	[strOrderByVariable], [strOrderByFieldName], [ysnOrderByFieldDescending],
						[intGridLayoutId], [strTableName], [strColumnName],	[ysnSystemPanel], [ysnSystemPanelChild]
					)
					VALUES (
						10, 5, 100, 300, @entityId, 0, 0, 0,	0, 1,	
						0,	N'Master', N'Gross Margin Chart', N'Chart', N'', N'Gross Margin', N'Column Stacked', N'insideEnd', N'Red', NULL, N'None',
						N'None', N'', N'', N'select *  from vyuARInvoiceGrossMargin order by dblNet desc', N'', N'@DATE@', N'@DATE@', N'', N'',	
						NULL, N'', N'',	N'None', N'', N'', N'',	N'',
						N'', N'', N'', 0, 0, NULL, NULL, N'20.1.1',	NULL,
						1, 0, N'', NULL, NULL, N'@ORDERBY@', N'', 0, 
						NULL, NULL, NULL, 1, NULL
					)

					SELECT @grossMarginChartPanelId = SCOPE_IDENTITY()

					--INSERT THE COLUMNS
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@grossMarginChartPanelId, N'strInvoiceNumber', N'Invoice No', 0, N'Series1AxisX', N'', N'', N'General', 0, N'', N'', N'',
						1, N'Chart', N'Series1AxisX', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.String', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@grossMarginChartPanelId, N'dblNet', N'Net', 0, N'Series1AxisY', N'', N'', N'Round', 1, N'', N'', N'',
						1, N'Chart', N'Series1AxisY', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.Decimal', N'', NULL
					)

					--INSERT PANEL OWNER
					INSERT INTO tblDBPanelOwner (
						[intPanelId], [intUserId], [intConcurrencyId]
					)
					VALUES (
						@grossMarginChartPanelId, @entityId, 1
					)

					--INSERT PANEL LAYOUT
					INSERT INTO tblDBPanelUser (
						[intPanelId], [intSort], [intPanelTabId], [intColumn], [intUserId], [ysnSystemPanelVisible], [intConcurrencyId ]
					)
					VALUES (
						@grossMarginChartPanelId, 3, @panelTabId, 2, @entityId, 1, 1
					)
				END
				ELSE
				BEGIN
					SELECT @grossMarginChartPanelId = intPanelId FROM tblDBPanel WHERE strPanelName = 'Gross Margin Chart' AND ysnSystemPanel = 1

					UPDATE tblDBPanel SET ysnChartLegend = 0 WHERE strPanelName = 'Gross Margin Chart' AND ysnSystemPanel = 1
					UPDATE tblDBPanelColumn SET strFormat = N'Round' WHERE intPanelId = @grossMarginChartPanelId AND strAlignment = 'Series1AxisY'
					UPDATE tblDBPanelUser SET intSort = 3 WHERE intPanelId = @grossMarginChartPanelId and intPanelTabId = @panelTabId
				END

				--Gross Margin Grid
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblDBPanel WHERE strPanelName = 'Gross Margin Grid' AND ysnSystemPanel = 1)
				BEGIN
					INSERT INTO tblDBPanel (
						[intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId],
						[intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition],
						[strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription],
						[strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2],
						[strGroupFields],  [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId],
						[intConcurrencyId], [intCannedPanelId], [strSortValue], [ysnAutoRefresh], [intAutoRefreshInterval],	[strOrderByVariable], [strOrderByFieldName], [ysnOrderByFieldDescending],
						[intGridLayoutId], [strTableName], [strColumnName],	[ysnSystemPanel], [ysnSystemPanelChild]
					)
					VALUES (
						0, 6, 100, 250, @entityId, 0, 0, 0,	0, 1,	
						0,	N'Master', N'Gross Margin Grid', N'Grid', N'', N'Gross Margin', N'Column Stacked', N'insideEnd', N'Red', NULL, N'None',
						N'None', N'', N'', N'select strInvoiceNumber, dblRevenue, dblExpense, dblNet from vyuARInvoiceGrossMargin order by dblNet desc', N'', N'@DATE@', N'@DATE@', N'', N'',	
						NULL, N'', N'',	N'None', N'', N'', N'',	N'',
						N'', N'', N'', 1, 0, NULL, NULL, N'20.1.1',	NULL,
						1, 0, N'', NULL, NULL, N'@ORDERBY@', N'', 0, NULL, NULL, NULL, 1, 1
					)

					SELECT @grossMarginGridPanelId = SCOPE_IDENTITY()

					--INSERT THE COLUMNS
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@grossMarginGridPanelId, N'strInvoiceNumber', N'Invoice No', 100, N'Left', N'', N'', N'', 0, N'', N'', N'',
						1, N'Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.String', N'AccountsReceivable.view.Invoice', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@grossMarginGridPanelId, N'dblRevenue', N'Revenue', 100, N'Left', N'', N'', N'###0.00', 1, N'', N'', N'',
						1, N'Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.Decimal', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@grossMarginGridPanelId, N'dblExpense', N'Expense', 100, N'Left', N'', N'', N'###0.00', 2, N'', N'', N'',
						1, N'Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.Decimal', N'', NULL
					)
					INSERT INTO tblDBPanelColumn (
						[intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn],
						[ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn],
						[intConcurrencyId ],    [intCannedPanelId], [strDataType], [strDrillDownScreenName], [strDrillDownScreenKey]
					)
					VALUES (
						@grossMarginGridPanelId, N'dblNet', N'Net', 100, N'Left', N'', N'', N'###0.00', 3, N'', N'', N'',
						1, N'Grid', N'', N'',	@entityId,	0,	0,	0,	0,	N'', 0,	
						1,	0,	N'System.Decimal', N'', NULL
					)

					--INSERT PANEL OWNER
					INSERT INTO tblDBPanelOwner (
						[intPanelId], [intUserId], [intConcurrencyId]
					)
					VALUES (
						@grossMarginGridPanelId, @entityId, 1
					)

					--INSERT PANEL LAYOUT
					INSERT INTO tblDBPanelUser (
						[intPanelId], [intSort], [intPanelTabId], [intColumn], [intUserId], [ysnSystemPanelVisible], [intConcurrencyId ]
					)
					VALUES (
						@grossMarginGridPanelId, 4, @panelTabId, 2, @entityId, 0, 1
					)
				END
				ELSE
				BEGIN
					SELECT @grossMarginGridPanelId = intPanelId FROM tblDBPanel WHERE strPanelName = 'Gross Margin Grid' AND ysnSystemPanel = 1

					UPDATE tblDBPanelColumn SET strFormat = '###0.00' WHERE intPanelId = @grossMarginGridPanelId AND strColumn IN ('dblRevenue', 'dblExpense', 'dblNet')
					UPDATE tblDBPanelUser SET ysnSystemPanelVisible = 0 WHERE intPanelId = @grossMarginGridPanelId AND intPanelTabId = @panelTabId
					UPDATE tblDBPanelUser SET intSort = 4 WHERE intPanelId = @grossMarginGridPanelId and intPanelTabId = @panelTabId
				END

			END

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH	
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION  


		DECLARE @ErrorMerssage NVARCHAR(MAX)
		SELECT @ErrorMerssage = ERROR_MESSAGE()									
		RAISERROR(@ErrorMerssage, 11, 1);
	END CATCH	
--END
PRINT '*End Create BUSINESS INSIGHTS DASHBOARD*'
