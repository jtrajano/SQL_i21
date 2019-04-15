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
	SELECT TOP 1 *
		, dtmFrom = @dtmFrom
		, dtmTo = @dtmTo
		, Commodity = @Commodity
		, Item = @Item
		, [Location] = @Location
		, License = @License
	FROM tblRKDPISummary
	WHERE intDPIHeaderId = @intDPIHeaderId
		AND dtmTransactionDate >= @dtmFrom
		AND dtmTransactionDate <= @dtmTo
END