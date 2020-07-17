CREATE PROCEDURE [dbo].[uspRKRptDPRHedgeDailyPositionDetailByMonth]
		@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN
	DECLARE @idoc INT
		,@intCommodityId nvarchar(max)
		,@intLocationId nvarchar(max) = NULL		
		,@intVendorId int = null
		,@strPurchaseSales nvarchar(50) = NULL
		,@strPositionIncludes nvarchar(50) = NULL
		,@dtmToDate datetime = null
		,@ysnIsCrushPosition bit = NULL
		,@strPositionBy nvarchar(50) = NULL
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
	

DECLARE @strCommodityCode NVARCHAR(50)

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

SELECT  @strCommodityCode = strCommodityCode FROM tblICCommodity WHERE intCommodityId IN (SELECT intCommodity FROM @Commodity)

DECLARE @strLocationName NVARCHAR(150)

IF isnull(@intLocationId,0) <> 0
BEGIN
	SELECT  @strLocationName = strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intLocationId

END
ELSE
BEGIN
	SET @strLocationName = 'All'
END

DECLARE @strEntityName NVARCHAR(150)

IF isnull(@intVendorId,0) <> 0
BEGIN
	SELECT  @strEntityName = CASE WHEN @strPurchaseSales = 'Purchase' THEN 'Vendor: ' + REPLACE(strName,'''','''''') ELSE 'Customer: ' + REPLACE(strName,'''','''''') END FROM tblEMEntity WHERE intEntityId = @intVendorId
END
ELSE
BEGIN
	SET @strEntityName = ''
END



	DECLARE @List AS TABLE (intRowNumber1 INT,intRowNumber INT
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200)
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200)
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200)
		, strType NVARCHAR(50)
		, strLocationName NVARCHAR(100)
		, strContractEndMonth NVARCHAR(50)
		, strContractEndMonthNearBy NVARCHAR(50)
		, dblTotal DECIMAL(24,10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50)
		, intFromCommodityUnitMeasureId int
		, intToCommodityUnitMeasureId int
		, strAccountNumber NVARCHAR(100)
		, strTranType NVARCHAR(20)
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId int
		, strInstrumentType NVARCHAR(50)
		, strEntityName NVARCHAR(100)
		, intOrderId int
		, strInventoryType NVARCHAR(100)
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, intCategoryId INT
		, strCategory NVARCHAR(100)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, strDeliveryDate NVARCHAR(50)
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT)
	

		INSERT INTO @List (
			intSeqNo
			, intRowNumber
			, strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal
			, strUnitMeasure
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, strEntityName
			, intOrderId
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, strDeliveryDate
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		)
		SELECT
			intSeqNo
			, intRowNumber
			, strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal
			, strUnitMeasure
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, strEntityName
			, intOrderId = intSeqNo
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName = strFutureMarket
			, intFutureMonthId
			, strFutureMonth
			, strDeliveryDate
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush = ysnCrush
		FROM tblRKDPRContractHedgeByMonth
		WHERE intDPRHeaderId = @intDPRHeaderId




	DECLARE @ctr as int
	SELECT @ctr = COUNT(intRowNumber) FROM @List 

	IF OBJECT_ID('tempdb..#tmpList') IS NOT NULL
	DROP TABLE  #tmpList
	IF OBJECT_ID('tempdb..##tmpTry') IS NOT NULL
	DROP TABLE  ##tmpTry
	IF OBJECT_ID('tempdb..##tmpTry2') IS NOT NULL
	DROP TABLE  ##tmpTry2


	IF @ctr > 0 
	BEGIN

		select * into #tmpList
		from @List 
		where strType <> CASE WHEN isnull(@intVendorId,0) = 0 THEN '' ELSE 'Net Hedge' END


		DECLARE @cols AS NVARCHAR(MAX),
				@colstry AS NVARCHAR(MAX) = '',
				@query  AS NVARCHAR(MAX),
				@intColCount AS INT,
				@colCtr as int = 2


		DECLARE  @tmpColList TABLE(
			strType nvarchar(max),
			intSeqNo int
		)

		select @cols = STUFF((select ',' + QUOTENAME(strType) 
							from @List
							where strType not in('Position') and strType <> CASE WHEN isnull(@intVendorId,0) = 0 THEN '' ELSE 'Net Hedge' END
							group by strType, intSeqNo
							order by intSeqNo, strType
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		insert into @tmpColList (strType,intSeqNo)
		SELECT DISTINCT strType,intSeqNo
					from @List
					where strType not in('Position') and strType <> CASE WHEN isnull(@intVendorId,0) = 0 THEN '' ELSE 'Net Hedge' END
					order by intSeqNo, strType
					--group by strType


				WHILE EXISTS (SELECT TOP 1 strType FROM @tmpColList)
				BEGIN
					DECLARE @strCol AS NVARCHAR(max)
					SET @colCtr = @colCtr + 1;

					SELECT TOP 1 @strCol = strType FROM @tmpColList ORDER BY intSeqNo, strType
			

					SET @colstry = @colstry + '''' + @strCol + ''' as col' + cast(@colCtr as nvarchar(20)) + ','
			
					DELETE FROM @tmpColList WHERE strType = @strCol 

				END
			
			IF @ysnIsCrushPosition = 1
			BEGIN
				SET @colstry = SUBSTRING(@colstry,0,LEN(@colstry))
			END
			ELSE
			BEGIN
				SET @colstry = @colstry + '''Position''as col' +  cast(@colCtr + 1 as nvarchar(20)) +' '
				SET @cols = @cols + ',[Position]'
			END
	
			set @query = N'

					SELECT 1 as col1 ,strContractEndMonth,' + @cols + N' into ##tmpTry from 
					 (
               			select * from (
							select strCommodityCode, strType, sum(dblTotal) as dblTotal, strContractEndMonth
							from #tmpList
							group by strContractEndMonth,strCommodityCode,strType
						) t
					) x
					pivot 
					(
						sum(dblTotal)
						for strType in (' + @cols + N')
					) p  order by CASE WHEN  strContractEndMonth not in(''Near By'',''Total'') THEN CONVERT(DATETIME,''01 ''+strContractEndMonth) END
			 

					'

		exec (@query)


		exec ('select 0 as col1,''Year'' as col2, '+ @colstry +' into ##tmpTry2')


		 DECLARE @colCAST AS NVARCHAR(MAX)

		 select @colCAST = STUFF((SELECT ',CAST(CONVERT(varchar,cast(round(' + QUOTENAME([name]) + ',2)as money),1) as nvarchar(max))'
							from tempdb.sys.columns where object_id = (SELECT object_id FROM tempdb.sys.objects WHERE name = '##tmpTry') and [name] not in ('col1','strContractEndMonth')
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		 DECLARE @colSUM AS NVARCHAR(MAX)

		 select @colSUM = STUFF((SELECT ',CAST(CONVERT(varchar,cast(sum(' + QUOTENAME([name]) + ')as money),1) as nvarchar(max))'
							from tempdb.sys.columns where object_id = (SELECT object_id FROM tempdb.sys.objects WHERE name = '##tmpTry') and [name] not in ('col1','strContractEndMonth')
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		exec (N' SELECT *, '''+ @xmlParam +''' AS xmlParam 
		, '''+ @strCommodityCode +''' AS strCommodityCode
		, '''+ @dtmToDate +''' AS dtmToDate
		, '''+ @strLocationName +''' AS strLocationName
		, '''+ @strPositionIncludes +''' AS strPositionIncludes 
		, '''+ @strEntityName +''' AS strEntityName 
		FROM (
			select * from ##tmpTry2
		union all
		select col1,strContractEndMonth,
			' + @colCAST +'
		from ##tmpTry
		union all
		select 2 as col1,''Total'' strContractEndMonth,
			' + @colSUM +'
		from ##tmpTry
		) t ORDER BY col1 , CASE WHEN  col2 not in(''Near By'',''Year'',''Total'') THEN CONVERT(DATETIME,''01 ''+col2) END'
		)


	END
	ELSE
	BEGIN
		SELECT 
			'' as col1,
			'' as col2,
			'' as col3,
			'' as col4,
			'' as col5,
			'' as col6,
			'' as col7,
			'' as col8,
			'' as col9,
			'' as col10,
			'' as col11,
			'' as col12,
			'' as col13,
			'' as col14,
			@xmlParam as xmlParam,
			@strCommodityCode as strCommodityCode,
			@dtmToDate as dtmToDate,
			@strLocationName as strLocationName,
			@strPositionIncludes as strPositionIncludes,
			@strEntityName as strEntityName

	END
END