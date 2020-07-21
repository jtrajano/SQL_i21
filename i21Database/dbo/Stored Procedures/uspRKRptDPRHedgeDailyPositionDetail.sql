CREATE PROCEDURE [dbo].[uspRKRptDPRHedgeDailyPositionDetail] 
			@xmlParam NVARCHAR(MAX) = NULL
AS

DECLARE @idoc INT
		,@intCommodityId nvarchar(max)
		,@intLocationId nvarchar(max) = NULL		
		,@intVendorId int = null
		,@strPurchaseSales nvarchar(50) = NULL
		,@strPositionIncludes nvarchar(50) = NULL
		,@dtmToDate datetime = null
		,@ysnIsCrushPosition bit = NULL
		,@strPositionBy NVARCHAR(50) = NULL
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

	SELECT @ysnIsCrushPosition = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'ysnIsCrushPosition'

	SELECT @strPositionBy = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'strPositionBy'

	SELECT @intDPRHeaderId = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intDPRHeaderId'

IF isnull(@strPurchaseSales,'') <> ''
BEGIN
                if @strPurchaseSales='Purchase'
                BEGIN
                                SELECT @strPurchaseSales='Sale'
                END
                ELSE
                BEGIN
                                SELECT @strPurchaseSales='Purchase'
                END
END


DECLARE @Commodity AS TABLE 
(
intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
intCommodity  INT
)
INSERT INTO @Commodity(intCommodity)
SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  
                 
SELECT
	dblTotal
	,intSeqNo
	,strCommodityCode
	,strType
	,strUnitMeasure
FROM tblRKDPRContractHedge
WHERE intDPRHeaderId = @intDPRHeaderId
