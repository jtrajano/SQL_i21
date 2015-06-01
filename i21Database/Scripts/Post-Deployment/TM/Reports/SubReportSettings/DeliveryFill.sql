GO	
print N'BEGIN Update Delivery Fill Report Sub report settings'
GO

DECLARE @strReportName NVARCHAR(100)
DECLARE @strSubReportName NVARCHAR(100)
DECLARE @strReportGroup NVARCHAR(100)
DECLARE @intSubReportId AS INT
DECLARE @intReportId AS INT
DECLARE @intSubreportSettingId AS INT
DECLARE @strControlName AS NVARCHAR(100)

SET @strReportName = 'Delivery Fill Report'
SET @strReportGroup = 'Tank Management'

SELECT	@intReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strReportName AND strGroup = @strReportGroup




-----------------------------------Start Product totals
-------------------Update Sub report settings---------------------------------------------------------------------
-----------------------------------------------------------------------------------------
SET @strSubReportName = 'Product Totals'
SET @strControlName = 'ProductTotals'
SET @strReportGroup = 'Sub Report'

SELECT	@intSubReportId = intReportId
FROM	[dbo].[tblRMReport] 
WHERE	[strName] = @strSubReportName AND strGroup = @strReportGroup


IF NOT EXISTS(SELECT TOP 1 1 FROM tblRMSubreportSetting WHERE intReportId = @intReportId AND strControlName = @strControlName AND intSubreportId =  @intSubReportId)
BEGIN
	INSERT INTO tblRMSubreportSetting (
		intReportId
		,strControlName
		,intSubreportId
	)
	VALUES(
		@intReportId
		,@strControlName
		,@intSubReportId
	)
	
END
SELECT @intSubreportSettingId = intSubreportSettingId
FROM tblRMSubreportSetting
WHERE intReportId = @intReportId AND strControlName = @strControlName AND intSubreportId =  @intSubReportId

IF (@intSubreportSettingId IS NOT NULL)
BEGIN
	DELETE tblRMSubreportFilter WHERE intSubreportSettingId = @intSubreportSettingId

	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dtmForecastedDelivery','Date','dtmForecastedDelivery','Date')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strLocation','String','strLocation','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strBetweenDlvry','String','strBetweenDlvry','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strFillMethod','String','strFillMethod','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strRouteId','String','strRouteId','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strProductDescription','String','strProductDescription','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strProductId','String','strProductId','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dblQuantity','Decimal','dblQuantity','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dtmRequestedDate','Date','dtmRequestedDate','Date')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strDriverId','String','strDriverId','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strDriverName','String','strDriverName','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'intFillGroupId','Integer','intFillGroupId','Integer')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'ysnActive','Bool','ysnActive','Bool')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strDescription','String','strDescription','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strFillGroupCode','String','strFillGroupCode','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dblDailyUse','Decimal','dblDailyUse','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'SiteDeliveryDD','Decimal','SiteDeliveryDD','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'SiteLabel','String','SiteLabel','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'intNextDeliveryDegreeDay','Integer','intNextDeliveryDegreeDay','Integer')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dtmNextDeliveryDate','Date','dtmNextDeliveryDate','Date')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dblEstimatedPercentLeft','Decimal','dblEstimatedPercentLeft','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'intSiteID','Integer','intSiteID','Integer')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dtmLastDeliveryDate','Date','dtmLastDeliveryDate','Date')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dblLastGalsInTank','Decimal','dblLastGalsInTank','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strSiteDescription','String','strSiteDescription','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dblTotalReserve','Decimal','dblTotalReserve','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dblTotalCapacity','Decimal','dblTotalCapacity','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dblDegreeDayBetweenDelivery','Decimal','dblDegreeDayBetweenDelivery','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strInstruction','String','strInstruction','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strComment','String','strComment','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strZipCode','String','strZipCode','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strState','String','strState','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strCity','String','strCity','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'intFillMethodId','Integer','intFillMethodId','Integer')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strOnHold','String','strOnHold','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dtmOnHoldEndDate','Date','dtmOnHoldEndDate','Date')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strSiteAddress','String','strSiteAddress','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'intLastDeliveryDegreeDay','Integer','intLastDeliveryDegreeDay','Integer')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'strSequenceID','String','strSequenceID','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dblLastDeliveredGal','Decimal','dblLastDeliveredGal','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'intSiteNumber','Integer','intSiteNumber','Integer')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dblPastCredit','Decimal','dblPastCredit','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'ARBalance','Decimal','ARBalance','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'TotalPast','Decimal','TotalPast','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'Credits','Decimal','Credits','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'Terms','String','Terms','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'agcus_prc_lvl','Integer','agcus_prc_lvl','Integer')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'agcus_key','String','agcus_key','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'CustomerName','String','CustomerName','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'agcus_phone','String','agcus_phone','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'intCustomerID','Integer','intCustomerID','Integer')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'dblProductCost','Decimal','dblProductCost','Decimal')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'agcus_first_name','String','agcus_first_name','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'agcus_last_name','String','agcus_last_name','String')
	INSERT INTO tblRMSubreportFilter (intSubreportSettingId,intType,strParentField,strParentDataType,strChildField,strChildDataType) VALUES(@intSubreportSettingId,1,'agcus_tax_state','String','agcus_tax_state','String')
END

-----------------------------------END Product totals
------------------------------------------------------------------------------------

GO
print N'END Update Delivery Fill Report Sub report settings'
GO