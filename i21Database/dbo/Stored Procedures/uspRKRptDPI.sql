CREATE PROCEDURE [dbo].[uspRKRptDPI]
	@xmlParam NVARCHAR(MAX)

AS

DECLARE @idoc INT
	, @intDPIHeaderId INTEGER
	, @dtmFrom DATETIME
	, @dtmTo DATETIME
	, @Commodity NVARCHAR(100)
	, @Item NVARCHAR(100)
	, @Location NVARCHAR(100)
	, @License NVARCHAR(100)

IF LTRIM(RTRIM(@xmlParam)) = ''
  SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE (
  fieldname NVARCHAR(50)
  ,condition NVARCHAR(20)
  ,[from] NVARCHAR(50)
  ,[to] NVARCHAR(50)
  ,[join] NVARCHAR(10)
  ,[begingroup] NVARCHAR(50)
  ,[endgroup] NVARCHAR(50)
  ,[datatype] NVARCHAR(50)
  )

EXEC sp_xml_preparedocument @idoc OUTPUT
  ,@xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (
    fieldname NVARCHAR(50)
   ,condition NVARCHAR(20)
   ,[from] NVARCHAR(50)
   ,[to] NVARCHAR(50)
   ,[join] NVARCHAR(10)
   ,[begingroup] NVARCHAR(50)
   ,[endgroup] NVARCHAR(50)
   ,[datatype] NVARCHAR(50)
   )

SELECT @intDPIHeaderId = [from] FROM @temp_xml_table WHERE [fieldname] = 'intDPIHeaderId' 
SELECT @dtmFrom = [from] FROM @temp_xml_table WHERE [fieldname] = 'dtmFrom'
SELECT @dtmTo = [from] FROM @temp_xml_table WHERE [fieldname] = 'dtmTo'
SELECT @Commodity = [from] FROM @temp_xml_table WHERE [fieldname] = 'Commodity' 
SELECT @Item = [from] FROM @temp_xml_table WHERE [fieldname] = 'Item'
SELECT @Location = [from] FROM @temp_xml_table WHERE [fieldname] = 'Location'
SELECT @License = [from] FROM @temp_xml_table WHERE [fieldname] = 'License'

IF (ISNULL(@xmlParam ,'') = '')
BEGIN
	SELECT intDPISummaryId = NULL
		, intDPIHeaderId = NULL
		, dtmTransactionDate = GETDATE()
		, dblReceiveIn = NULL
		, dblShipOut = NULL
		, dblAdjustments = NULL
		, dblCount = NULL
		, dblInvoiceQty = NULL
		, dblInventoryBalance = NULL
		, dblSalesInTransit = NULL
		, strDistributionA = NULL
		, dblAIn = NULL
		, dblAOut = NULL
		, dblANet = NULL
		, strDistributionB = NULL
		, dblBIn = NULL
		, dblBOut = NULL
		, dblBNet = NULL
		, strDistributionC = NULL
		, dblCIn = NULL
		, dblCOut = NULL
		, dblCNet = NULL
		, strDistributionD = NULL
		, dblDIn = NULL
		, dblDOut = NULL
		, dblDNet = NULL
		, strDistributionE = NULL
		, dblEIn = NULL
		, dblEOut = NULL
		, dblENet = NULL
		, strDistributionF = NULL
		, dblFIn = NULL
		, dblFOut = NULL
		, dblFNet = NULL
		, strDistributionG = NULL
		, dblGIn = NULL
		, dblGOut = NULL
		, dblGNet = NULL
		, strDistributionH = NULL
		, dblHIn = NULL
		, dblHOut = NULL
		, dblHNet = NULL
		, strDistributionI = NULL
		, dblIIn = NULL
		, dblIOut = NULL
		, dblINet = NULL
		, strDistributionJ = NULL
		, dblJIn = NULL
		, dblJOut = NULL
		, dblJNet = NULL
		, strDistributionK = NULL
		, dblKIn = NULL
		, dblKOut = NULL
		, dblKNet = NULL
		, dblUnpaidIn = NULL
		, dblUnpaidOut = NULL
		, dblBalance = NULL
		, dblPaidBalance = NULL
		, dblTotalCompanyOwned = NULL
		, dblUnpaidBalance = NULL
		, dtmFrom = GETDATE()
		, dtmTo = GETDATE()
		, Commodity = @Commodity
		, Item = @Item
		, [Location] = @Location
		, License = @License
END
ELSE
BEGIN
	SELECT TOP 1 intDPISummaryId
		, intDPIHeaderId
		, dtmTransactionDate
		, dblReceiveIn
		, dblShipOut
		, dblAdjustments
		, dblCount
		, dblInvoiceQty
		, dblInventoryBalance = ISNULL(dblInventoryBalance, 0.00)
		, dblSalesInTransit
		, strDistributionA
		, dblAIn
		, dblAOut
		, dblANet = ISNULL(dblANet, 0.00)
		, strDistributionB
		, dblBIn
		, dblBOut
		, dblBNet = ISNULL(dblBNet, 0.00)
		, strDistributionC
		, dblCIn
		, dblCOut
		, dblCNet = ISNULL(dblCNet, 0.00)
		, strDistributionD
		, dblDIn
		, dblDOut
		, dblDNet = ISNULL(dblDNet, 0.00)
		, strDistributionE
		, dblEIn
		, dblEOut
		, dblENet = ISNULL(dblENet, 0.00)
		, strDistributionF
		, dblFIn
		, dblFOut
		, dblFNet = ISNULL(dblFNet, 0.00)
		, strDistributionG
		, dblGIn
		, dblGOut
		, dblGNet = ISNULL(dblGNet, 0.00)
		, strDistributionH
		, dblHIn
		, dblHOut
		, dblHNet = ISNULL(dblHNet, 0.00)
		, strDistributionI
		, dblIIn
		, dblIOut
		, dblINet = ISNULL(dblINet, 0.00)
		, strDistributionJ
		, dblJIn
		, dblJOut
		, dblJNet = ISNULL(dblJNet, 0.00)
		, strDistributionK
		, dblKIn
		, dblKOut
		, dblKNet = ISNULL(dblKNet, 0.00)
		, dblUnpaidIn
		, dblUnpaidOut
		, dblBalance
		, dblPaidBalance = ISNULL(dblPaidBalance, 0.00)
		, dblTotalCompanyOwned = ISNULL(dblTotalCompanyOwned, 0.00)
		, dblUnpaidBalance = ISNULL(dblUnpaidBalance, 0.00)
		, dtmFrom = @dtmFrom
		, dtmTo = @dtmTo
		, Commodity = @Commodity
		, Item = @Item
		, [Location] = @Location
		, License = @License
	FROM tblRKDPISummary
	WHERE intDPIHeaderId = @intDPIHeaderId
		AND (dtmTransactionDate < @dtmFrom OR dtmTransactionDate IS NULL)
	ORDER BY dtmTransactionDate DESC
END