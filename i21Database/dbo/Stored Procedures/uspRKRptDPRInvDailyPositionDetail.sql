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

DECLARE @FinalTable AS TABLE (
					intRow int , 
					intSeqId int, 
					strSeqHeader nvarchar(100),
					strCommodityCode nvarchar(100),
					strType nvarchar(100),
					dblTotal DECIMAL(24,10),
					intCollateralId int,
					strLocationName nvarchar(250),
					strCustomer nvarchar(250),
					intReceiptNo nvarchar(250),
					intContractHeaderId int,
					strContractNumber nvarchar(100),
					strCustomerReference nvarchar(100),
					strDistributionOption nvarchar(100),
					strDPAReceiptNo nvarchar(100),
					dblDiscDue DECIMAL(24,10),
					[Storage Due] DECIMAL(24,10),	
					dtmLastStorageAccrueDate datetime,
					strScheduleId nvarchar(100),
					strTicket nvarchar(100),
					dtmOpenDate datetime,
					dtmDeliveryDate datetime,
					dtmTicketDateTime datetime,
					dblOriginalQuantity  DECIMAL(24,10),
					dblRemainingQuantity DECIMAL(24,10),
					intCommodityId int,
					strItemNo nvarchar(100),
					strUnitMeasure nvarchar(100)
					,intFromCommodityUnitMeasureId int
					,intToCommodityUnitMeasureId int
					,strTruckName  nvarchar(100)
					,strDriverName  nvarchar(100)
					,intCompanyLocationId int
					,intItemId int
					,intTicketId int,
					strTicketNumber nvarchar(100)
					,strShipmentNumber nvarchar(100)
					,intInventoryShipmentId int
					,intInventoryReceiptId int, 
					strReceiptNumber  nvarchar(100)
)


INSERT INTO @FinalTable(intRow,intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
							intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
							strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,[Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
							dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName	,intInventoryReceiptId,strReceiptNumber,intTicketId,strShipmentNumber,
							intInventoryShipmentId,intItemId, strTicketNumber)
EXEC uspRKDPRInvDailyPositionDetail @intCommodityId, @intLocationId, @intVendorId, @strPurchaseSales, @strPositionIncludes, @dtmToDate

SELECT 
	intSeqId
	,strSeqHeader
	,strCommodityCode
	,dblTotal 
FROM 
(
	select intSeqId,strSeqHeader,strCommodityCode,sum(dblTotal) as dblTotal 
	from @FinalTable
	group by intSeqId,strSeqHeader,strCommodityCode
) a 
WHERE round(dblTotal,2) <> 0

END