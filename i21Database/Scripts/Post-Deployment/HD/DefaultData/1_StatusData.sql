/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

GO
	PRINT N'BEGIN INSERT DEFAULT HELP DESK STATUS'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketStatus] WHERE strStatus = 'Open') INSERT [dbo].[tblHDTicketStatus] ([strStatus], [strDescription], [strIcon], [strFontColor], [strBackColor], [intSort], [intConcurrencyId]) VALUES (N'Open', N'Open', NULL, NULL, NULL, 1, 1)
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketStatus] WHERE strStatus = 'Closed') INSERT [dbo].[tblHDTicketStatus] ([strStatus], [strDescription], [strIcon], [strFontColor], [strBackColor], [intSort], [intConcurrencyId]) VALUES (N'Closed', N'Closed', NULL, NULL, NULL, 2, 1)
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketStatus] WHERE strStatus = 'Reopen') INSERT [dbo].[tblHDTicketStatus] ([strStatus], [strDescription], [strIcon], [strFontColor], [strBackColor], [intSort], [intConcurrencyId]) VALUES (N'Reopen', N'Reopen', NULL, NULL, NULL, 3, 1)

GO
	PRINT N'END INSERT DEFAULT HELP DESK STATUS'
	PRINT N'BEGIN INSERT DEFAULT HELP DESK TICKET LINK TYPE'
GO

SET IDENTITY_INSERT [dbo].[tblHDTicketLinkType] ON
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketLinkType] WHERE strLinkType = 'relates to') INSERT [dbo].[tblHDTicketLinkType]
																							(
																								[intTicketLinkTypeId]
																								,[strLinkType]
																								,[intTicketLinkTypeCounterId]
																								,[intSort]
																								,[intConcurrencyId]
																							) VALUES (
																								1
																								,N'relates to'
																								,1
																								,1
																								,1
																							)

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketLinkType] WHERE strLinkType = 'is blocked by') INSERT [dbo].[tblHDTicketLinkType]
																							(
																								[intTicketLinkTypeId]
																								,[strLinkType]
																								,[intTicketLinkTypeCounterId]
																								,[intSort]
																								,[intConcurrencyId]
																							) VALUES (
																								2
																								,N'is blocked by'
																								,3
																								,2
																								,1
																							)

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketLinkType] WHERE strLinkType = 'blocks') INSERT [dbo].[tblHDTicketLinkType]
																							(
																								[intTicketLinkTypeId]
																								,[strLinkType]
																								,[intTicketLinkTypeCounterId]
																								,[intSort]
																								,[intConcurrencyId]
																							) VALUES (
																								3
																								,N'blocks'
																								,2
																								,3
																								,1
																							)

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketLinkType] WHERE strLinkType = 'is duplicated by') INSERT [dbo].[tblHDTicketLinkType]
																							(
																								[intTicketLinkTypeId]
																								,[strLinkType]
																								,[intTicketLinkTypeCounterId]
																								,[intSort]
																								,[intConcurrencyId]
																							) VALUES (
																								4
																								,N'is duplicated by'
																								,5
																								,4
																								,1
																							)

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketLinkType] WHERE strLinkType = 'duplicates') INSERT [dbo].[tblHDTicketLinkType]
																							(
																								[intTicketLinkTypeId]
																								,[strLinkType]
																								,[intTicketLinkTypeCounterId]
																								,[intSort]
																								,[intConcurrencyId]
																							) VALUES (
																								5
																								,N'duplicates'
																								,4
																								,5
																								,1
																							)

SET IDENTITY_INSERT [dbo].[tblHDTicketLinkType] OFF

GO
	PRINT N'END INSERT DEFAULT HELP DESK TICKET LINK TYPE'
	PRINT N'CREATING CRM LOST REVENUE DEFAULT GRID LAYOUT'
GO

if ((SELECT count(*) from tblSMGridLayout a where a.strGridLayoutName = 'By Quantity' and a.strScreen = 'CRM.view.LostRevenue' and a.strGrid = 'grdLostRevenue' and a.ysnReadOnly = convert(bit,1)) = 0)
begin
	INSERT INTO [dbo].[tblSMGridLayout]
			   ([strGridLayoutName]
			   ,[strGridLayoutFields]
			   ,[strGridLayoutFilters]
			   ,[strGridLayoutSorters]
			   ,[strScreen]
			   ,[strGrid]
			   ,[intUserId]
			   ,[ysnActive]
			   ,[ysnIsQuickFilter]
			   ,[intTabIndex]
			   ,[ysnIsSorted]
			   ,[ysnSystemLayout]
			   ,[ysnSystemLayoutDefault]
			   ,[ysnReadOnly]
			   ,[intConcurrencyId])
		 VALUES
			   ('By Quantity'
			   ,'[{"strItemId":"colEntityName","strFieldName":"strName","strDataType":"string","strDisplayName":"Customer","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":200,"dblFlex":0,"intIndex":0,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":200},{"strItemId":"colCategory","strFieldName":"strCategory","strDataType":"string","strDisplayName":"Category","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":1,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null},{"strItemId":"colItem","strFieldName":"strItem","strDataType":"string","strDisplayName":"Item","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":2,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null},{"strItemId":"colLastThreeYearsAveSales","strFieldName":"dblThreeYearsAveSales","strDataType":"numeric","strDisplayName":"Last 3 Years Ave. Sales ","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":3,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colLastThreeYearsAveSalesUnits","strFieldName":"dblThreeYearsAveSalesUnits","strDataType":"numeric","strDisplayName":"Last 3 Years Ave. Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":160,"dblFlex":0,"intIndex":4,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":160},{"strItemId":"colRevenue","strFieldName":"intRevenue","strDataType":"numeric","strDisplayName":"01/01/2016 to 12/31/2016</br>Total Sales","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":5,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colRevenueUnits","strFieldName":"dblSalesOrderTotalUnits","strDataType":"numeric","strDisplayName":"01/01/2016 to 12/31/2016</br>Total Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":0,"intIndex":6,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueShipped","strFieldName":"dblSalesOrderTotalShip","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Shipped","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":7,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueShippedUnits","strFieldName":"dblSalesOrderTotalShipUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Shipped Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":0,"intIndex":8,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueNotYetShipped","strFieldName":"dblSalesOrderTotalUnShip","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Not Yet Shipped","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":9,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueNotYetShippedUnits","strFieldName":"dblSalesOrderTotalUnShipUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Not Yet Shipped Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":0,"intIndex":10,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueContracted","strFieldName":"dblRemainingContractAmount","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Contracted","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":11,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueContractedUnits","strFieldName":"dblRemainingContractAmountUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Contracted Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":0,"intIndex":12,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenue","strFieldName":"dblTotalOrderAndContract","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Total Sales","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":13,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueUnits","strFieldName":"dblTotalOrderAndContractUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Total Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":0,"intIndex":14,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colUnitsDifference","strFieldName":"intUnitsDifference","strDataType":"numeric","strDisplayName":"Units Difference","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":15,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colUnitsPercentage","strFieldName":"intUnitsPercentage","strDataType":"numeric","strDisplayName":"Units Percentage","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":16,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colDifference","strFieldName":"intDifference","strDataType":"numeric","strDisplayName":"Sales Difference","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":100,"dblFlex":0,"intIndex":17,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colPercentage","strFieldName":"intPercentage","strDataType":"numeric","strDisplayName":"Sales Percentage","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":100,"dblFlex":0,"intIndex":18,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colLostRevenue","strFieldName":"ysnLostSale","strDataType":"boolean","strDisplayName":"Lost Sale","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":19,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colGenerateOppportunity","strFieldName":"ysnGenerateOpportunity","strDataType":"boolean","strDisplayName":"Generate Opportunity","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":20,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colGenerateCampaign","strFieldName":"ysnGenerateCampaign","strDataType":"boolean","strDisplayName":"Generate Campaign","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":21,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colContact","strFieldName":"strContact","strDataType":"string","strDisplayName":"Contact","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":22,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null}]'
			   ,'[]'
			   ,'[]'
			   ,'CRM.view.LostRevenue'
			   ,'grdLostRevenue'
			   ,(select top 1 intEntityId from tblSMUserSecurity)
			   ,convert(bit,0)
			   ,convert(bit,0)
			   ,0
			   ,convert(bit,0)
			   ,convert(bit,0)
			   ,convert(bit,0)
			   ,convert(bit,1)
			   ,1);
end
else
begin
	update tblSMGridLayout set strGridLayoutFields = '[{"strItemId":"colEntityName","strFieldName":"strName","strDataType":"string","strDisplayName":"Customer","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":200,"dblFlex":0,"intIndex":0,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":200},{"strItemId":"colCategory","strFieldName":"strCategory","strDataType":"string","strDisplayName":"Category","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":1,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null},{"strItemId":"colItem","strFieldName":"strItem","strDataType":"string","strDisplayName":"Item","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":2,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null},{"strItemId":"colLastThreeYearsAveSales","strFieldName":"dblThreeYearsAveSales","strDataType":"numeric","strDisplayName":"Last 3 Years Ave. Sales ","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":3,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colLastThreeYearsAveSalesUnits","strFieldName":"dblThreeYearsAveSalesUnits","strDataType":"numeric","strDisplayName":"Last 3 Years Ave. Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":160,"dblFlex":0,"intIndex":4,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":160},{"strItemId":"colRevenue","strFieldName":"intRevenue","strDataType":"numeric","strDisplayName":"01/01/2016 to 12/31/2016</br>Total Sales","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":5,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colRevenueUnits","strFieldName":"dblSalesOrderTotalUnits","strDataType":"numeric","strDisplayName":"01/01/2016 to 12/31/2016</br>Total Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":0,"intIndex":6,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueShipped","strFieldName":"dblSalesOrderTotalShip","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Shipped","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":7,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueShippedUnits","strFieldName":"dblSalesOrderTotalShipUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Shipped Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":0,"intIndex":8,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueNotYetShipped","strFieldName":"dblSalesOrderTotalUnShip","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Not Yet Shipped","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":9,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueNotYetShippedUnits","strFieldName":"dblSalesOrderTotalUnShipUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Not Yet Shipped Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":0,"intIndex":10,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueContracted","strFieldName":"dblRemainingContractAmount","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Contracted","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":11,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueContractedUnits","strFieldName":"dblRemainingContractAmountUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Contracted Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":0,"intIndex":12,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenue","strFieldName":"dblTotalOrderAndContract","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Total Sales","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":150,"dblFlex":0,"intIndex":13,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueUnits","strFieldName":"dblTotalOrderAndContractUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Total Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":0,"intIndex":14,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colUnitsDifference","strFieldName":"intUnitsDifference","strDataType":"numeric","strDisplayName":"Units Difference","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":15,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colUnitsPercentage","strFieldName":"intUnitsPercentage","strDataType":"numeric","strDisplayName":"Units Percentage","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":16,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colDifference","strFieldName":"intDifference","strDataType":"numeric","strDisplayName":"Sales Difference","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":100,"dblFlex":0,"intIndex":17,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colPercentage","strFieldName":"intPercentage","strDataType":"numeric","strDisplayName":"Sales Percentage","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":100,"dblFlex":0,"intIndex":18,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colLostRevenue","strFieldName":"ysnLostSale","strDataType":"boolean","strDisplayName":"Lost Sale","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":19,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colGenerateOppportunity","strFieldName":"ysnGenerateOpportunity","strDataType":"boolean","strDisplayName":"Generate Opportunity","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":20,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colGenerateCampaign","strFieldName":"ysnGenerateCampaign","strDataType":"boolean","strDisplayName":"Generate Campaign","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":21,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colContact","strFieldName":"strContact","strDataType":"string","strDisplayName":"Contact","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":22,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null}]' where strGridLayoutName = 'By Quantity' and strScreen = 'CRM.view.LostRevenue' and strGrid = 'grdLostRevenue' and ysnReadOnly = convert(bit,1);
end


if ((SELECT count(*) from tblSMGridLayout a where a.strGridLayoutName = 'By Sales Dollar' and a.strScreen = 'CRM.view.LostRevenue' and a.strGrid = 'grdLostRevenue' and a.ysnReadOnly = convert(bit,1)) = 0)
begin
	INSERT INTO [dbo].[tblSMGridLayout]
			   ([strGridLayoutName]
			   ,[strGridLayoutFields]
			   ,[strGridLayoutFilters]
			   ,[strGridLayoutSorters]
			   ,[strScreen]
			   ,[strGrid]
			   ,[intUserId]
			   ,[ysnActive]
			   ,[ysnIsQuickFilter]
			   ,[intTabIndex]
			   ,[ysnIsSorted]
			   ,[ysnSystemLayout]
			   ,[ysnSystemLayoutDefault]
			   ,[ysnReadOnly]
			   ,[intConcurrencyId])
		 VALUES
			   ('By Sales Dollar'
			   ,'[{"strItemId":"colEntityName","strFieldName":"strName","strDataType":"string","strDisplayName":"Customer","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":200,"dblFlex":2,"intIndex":0,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":200},{"strItemId":"colCategory","strFieldName":"strCategory","strDataType":"string","strDisplayName":"Category","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":1,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null},{"strItemId":"colItem","strFieldName":"strItem","strDataType":"string","strDisplayName":"Item","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":2,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null},{"strItemId":"colLastThreeYearsAveSales","strFieldName":"dblThreeYearsAveSales","strDataType":"numeric","strDisplayName":"Last 3 Years Ave. Sales ","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":3,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colLastThreeYearsAveSalesUnits","strFieldName":"dblThreeYearsAveSalesUnits","strDataType":"numeric","strDisplayName":"Last 3 Years Ave. Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":4,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":160},{"strItemId":"colRevenue","strFieldName":"intRevenue","strDataType":"numeric","strDisplayName":"01/01/2016 to 12/31/2016</br>Total Sales","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":5,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colRevenueUnits","strFieldName":"dblSalesOrderTotalUnits","strDataType":"numeric","strDisplayName":"01/01/2016 to 12/31/2016</br>Total Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":6,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueShipped","strFieldName":"dblSalesOrderTotalShip","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Shipped","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":7,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueShippedUnits","strFieldName":"dblSalesOrderTotalShipUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Shipped Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":8,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueNotYetShipped","strFieldName":"dblSalesOrderTotalUnShip","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Not Yet Shipped","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":9,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueNotYetShippedUnits","strFieldName":"dblSalesOrderTotalUnShipUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Not Yet Shipped Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":10,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueContracted","strFieldName":"dblRemainingContractAmount","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Contracted","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":11,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueContractedUnits","strFieldName":"dblRemainingContractAmountUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Contracted Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":12,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenue","strFieldName":"dblTotalOrderAndContract","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Total Sales","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":13,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueUnits","strFieldName":"dblTotalOrderAndContractUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Total Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":14,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colUnitsDifference","strFieldName":"intUnitsDifference","strDataType":"numeric","strDisplayName":"Units Difference","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1,"intIndex":15,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colUnitsPercentage","strFieldName":"intUnitsPercentage","strDataType":"numeric","strDisplayName":"Units Percentage","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1,"intIndex":16,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colDifference","strFieldName":"intDifference","strDataType":"numeric","strDisplayName":"Sales Difference","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":100,"dblFlex":1,"intIndex":17,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colPercentage","strFieldName":"intPercentage","strDataType":"numeric","strDisplayName":"Sales Percentage","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":100,"dblFlex":1,"intIndex":18,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colLostRevenue","strFieldName":"ysnLostSale","strDataType":"boolean","strDisplayName":"Lost Sale","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":1,"intIndex":19,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colGenerateOppportunity","strFieldName":"ysnGenerateOpportunity","strDataType":"boolean","strDisplayName":"Generate Opportunity","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":1,"intIndex":20,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colGenerateCampaign","strFieldName":"ysnGenerateCampaign","strDataType":"boolean","strDisplayName":"Generate Campaign","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":1,"intIndex":21,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colContact","strFieldName":"strContact","strDataType":"string","strDisplayName":"Contact","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":22,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null}]'
			   ,'[]'
			   ,'[]'
			   ,'CRM.view.LostRevenue'
			   ,'grdLostRevenue'
			   ,(select top 1 intEntityId from tblSMUserSecurity)
			   ,convert(bit,0)
			   ,convert(bit,0)
			   ,0
			   ,convert(bit,0)
			   ,convert(bit,0)
			   ,convert(bit,0)
			   ,convert(bit,1)
			   ,1);
end
else
begin
	update tblSMGridLayout set strGridLayoutFields = '[{"strItemId":"colEntityName","strFieldName":"strName","strDataType":"string","strDisplayName":"Customer","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":200,"dblFlex":2,"intIndex":0,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":200},{"strItemId":"colCategory","strFieldName":"strCategory","strDataType":"string","strDisplayName":"Category","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":1,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null},{"strItemId":"colItem","strFieldName":"strItem","strDataType":"string","strDisplayName":"Item","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":2,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null},{"strItemId":"colLastThreeYearsAveSales","strFieldName":"dblThreeYearsAveSales","strDataType":"numeric","strDisplayName":"Last 3 Years Ave. Sales ","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":3,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colLastThreeYearsAveSalesUnits","strFieldName":"dblThreeYearsAveSalesUnits","strDataType":"numeric","strDisplayName":"Last 3 Years Ave. Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":4,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":160},{"strItemId":"colRevenue","strFieldName":"intRevenue","strDataType":"numeric","strDisplayName":"01/01/2016 to 12/31/2016</br>Total Sales","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":5,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colRevenueUnits","strFieldName":"dblSalesOrderTotalUnits","strDataType":"numeric","strDisplayName":"01/01/2016 to 12/31/2016</br>Total Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":6,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueShipped","strFieldName":"dblSalesOrderTotalShip","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Shipped","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":7,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueShippedUnits","strFieldName":"dblSalesOrderTotalShipUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Shipped Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":8,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueNotYetShipped","strFieldName":"dblSalesOrderTotalUnShip","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Not Yet Shipped","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":9,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueNotYetShippedUnits","strFieldName":"dblSalesOrderTotalUnShipUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Sales Not Yet Shipped Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":10,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueContracted","strFieldName":"dblRemainingContractAmount","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Contracted","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":11,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueContractedUnits","strFieldName":"dblRemainingContractAmountUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Contracted Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":12,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenue","strFieldName":"dblTotalOrderAndContract","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Total Sales","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":150,"dblFlex":1.3,"intIndex":13,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colCompareToRevenueUnits","strFieldName":"dblTotalOrderAndContractUnits","strDataType":"numeric","strDisplayName":"01/01/2017 to 12/29/2017</br>Total Sales Qty.","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1.3,"intIndex":14,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":150},{"strItemId":"colUnitsDifference","strFieldName":"intUnitsDifference","strDataType":"numeric","strDisplayName":"Units Difference","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1,"intIndex":15,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colUnitsPercentage","strFieldName":"intUnitsPercentage","strDataType":"numeric","strDisplayName":"Units Percentage","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":true,"dblWidth":0,"dblFlex":1,"intIndex":16,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colDifference","strFieldName":"intDifference","strDataType":"numeric","strDisplayName":"Sales Difference","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":100,"dblFlex":1,"intIndex":17,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colPercentage","strFieldName":"intPercentage","strDataType":"numeric","strDisplayName":"Sales Percentage","strControlType":"numbercolumn","strControlAlignment":"right","ysnHidden":false,"dblWidth":100,"dblFlex":1,"intIndex":18,"strSort":null,"ysnGroup":null,"format":"#,##0.00","hideable":true,"minWidth":100},{"strItemId":"colLostRevenue","strFieldName":"ysnLostSale","strDataType":"boolean","strDisplayName":"Lost Sale","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":1,"intIndex":19,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colGenerateOppportunity","strFieldName":"ysnGenerateOpportunity","strDataType":"boolean","strDisplayName":"Generate Opportunity","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":1,"intIndex":20,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colGenerateCampaign","strFieldName":"ysnGenerateCampaign","strDataType":"boolean","strDisplayName":"Generate Campaign","strControlType":"checkcolumn","strControlAlignment":"center","ysnHidden":false,"dblWidth":100,"dblFlex":1,"intIndex":21,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":100},{"strItemId":"colContact","strFieldName":"strContact","strDataType":"string","strDisplayName":"Contact","strControlType":"gridcolumn","strControlAlignment":"left","ysnHidden":false,"dblWidth":100,"dblFlex":0,"intIndex":22,"strSort":null,"ysnGroup":null,"hideable":true,"minWidth":null}]' where strGridLayoutName = 'By Sales Dollar' and strScreen = 'CRM.view.LostRevenue' and strGrid = 'grdLostRevenue' and ysnReadOnly = convert(bit,1);
end

/*Add default Time Entry record*/
if not exists (select * from tblHDTimeEntry where intTimeEntryId = 1)
begin
	set identity_insert tblHDTimeEntry on;
	insert into tblHDTimeEntry (intTimeEntryId) select intTimeEntryId = 1;
	set identity_insert tblHDTimeEntry off;

	update tblHDTicketHoursWorked set intTimeEntryId = 1;

end

GO
	PRINT N'END CREATING CRM LOST REVENUE DEFAULT GRID LAYOUT'
GO