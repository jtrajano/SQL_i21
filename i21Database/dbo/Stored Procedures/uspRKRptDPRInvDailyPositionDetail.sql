CREATE PROCEDURE [dbo].[uspRKRptDPRInvDailyPositionDetail] 
	@xmlParam NVARCHAR(MAX) = NULL

as
BEGIN

	DECLARE @idoc INT
		,@intCommodityId nvarchar(max)
		,@intLocationId nvarchar(max) = NULL		
		,@intVendorId int = null
		,@strPurchaseSales nvarchar(50) = NULL
		,@strPositionIncludes nvarchar(50) = NULL
		,@dtmToDate datetime = null
		,@intDPRHeaderId int
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

	SELECT @intCommodityId = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intCommodityId'
	
	SELECT @intLocationId = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intLocationId'
	
	SELECT @intVendorId = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intVendorId'
	
	SELECT @strPurchaseSales = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'strPurchaseSales'
	
	SELECT @strPositionIncludes = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'strPositionIncludes'

	SELECT @dtmToDate = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'dtmToDate'

	SELECT @intDPRHeaderId = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intDPRHeaderId'

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

if isnull(@strPurchaseSales,'') <> ''
BEGIN
if @strPurchaseSales='Purchase'
BEGIN
select @strPurchaseSales='Sales'
END
ELSE
BEGIN
SELECT @strPurchaseSales='Purchase'
END
END

DECLARE @FinalTable AS TABLE (intRow INT
		, intSeqId INT
		, strSeqHeader NVARCHAR(100)
		, strCommodityCode NVARCHAR(100)
		, strType NVARCHAR(100)
		, dblTotal DECIMAL(24,10)
		, intCollateralId INT
		, strLocationName NVARCHAR(250)
		, strCustomerName NVARCHAR(250)
		, strReceiptNo NVARCHAR(250)
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(100)
		, strCustomerReference NVARCHAR(100)
		, strDistributionOption NVARCHAR(100)
		, strDPAReceiptNo NVARCHAR(100)
		, dblDiscDue DECIMAL(24,10)
		, dblStorageDue DECIMAL(24,10)
		, dtmLastStorageAccrueDate DATETIME
		, strScheduleId NVARCHAR(100)
		, intTicketId INT
		, strTicketType NVARCHAR(100)
		, strTicketNumber NVARCHAR(100)		
		, dtmOpenDate DATETIME
		, strDeliveryDate NVARCHAR(50)
		, dtmTicketDateTime DATETIME
		, dblOriginalQuantity  DECIMAL(24,10)
		, dblRemainingQuantity DECIMAL(24,10)
		, intCommodityId INT
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, strUnitMeasure NVARCHAR(100)
		, intFromCommodityUnitMeasureId int
		, intToCommodityUnitMeasureId int
		, strTruckName NVARCHAR(100)
		, strDriverName NVARCHAR(100)
		, intCompanyLocationId INT
		, strShipmentNumber NVARCHAR(100)
		, intInventoryShipmentId INT
		, intInventoryReceiptId INT
		, strReceiptNumber NVARCHAR(100)
		, strTransactionType NVARCHAR(100)
		, intCategoryId INT
		, strCategory NVARCHAR(100)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT
		, strContractEndMonth NVARCHAR(50))


INSERT INTO @FinalTable(
			  intRow
			, intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, strUnitMeasure
			, intCollateralId
			, strLocationName
			, strCustomerName
			, strReceiptNo
			, intContractHeaderId
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, intCommodityId
			, strCustomerReference
			, strDistributionOption
			, strDPAReceiptNo
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, intTicketId
			, strTicketType
			, strTicketNumber 
			, strContractEndMonth
			, strDeliveryDate
			, dtmTicketDateTime
			, intItemId
			, strItemNo
			, strTruckName
			, strDriverName
			, intInventoryReceiptId
			, strReceiptNumber 
			, strShipmentNumber 
			, intInventoryShipmentId
			, strTransactionType
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush)
SELECT   intRow
			, intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, strUnitMeasure
			, intCollateralId
			, strLocationName
			, strCustomerName
			, strReceiptNo
			, intContractHeaderId
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, intCommodityId
			, strCustomerReference
			, strDistributionOption
			, strDPAReceiptNo
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, intTicketId
			, strTicketType
			, strTicketNumber 
			, strContractEndMonth
			, strDeliveryDate
			, dtmTicketDateTime
			, intItemId
			, strItemNo
			, strTruckName
			, strDriverName
			, intInventoryReceiptId
			, strReceiptNumber 
			, strShipmentNumber 
			, intInventoryShipmentId
			, strTransactionType
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName = strFutureMarket
			, intFutureMonthId
			, strFutureMonth
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush = ysnCrush
FROM tblRKDPRInventory
WHERE intDPRHeaderId = @intDPRHeaderId 

SELECT intSeqId
	, strSeqHeader
	, strCommodityCode
	, dblTotal
FROM (
	SELECT intSeqId
		, strSeqHeader
		, strCommodityCode
		, dblTotal = SUM(dblTotal)
	FROM @FinalTable
	GROUP BY intSeqId
		, strSeqHeader
		, strCommodityCode
) a WHERE ROUND(dblTotal, 2) <> 0

END