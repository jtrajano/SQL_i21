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
		,@intDPRRunNumber int
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

	SELECT @intDPRRunNumber = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intDPRRunNumber'
	

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
		, strTranType NVARCHAR(100)
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
		AND	 strLocationName = CASE WHEN @strLocationName = 'All' THEN strLocationName ELSE @strLocationName END

	IF (@strCommodityCode IS NULL) 
	BEGIN
		SELECT TOP 1 @strCommodityCode = strCommodityCode FROM @List
	END

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
				@colCtr as int = 3


		DECLARE  @tmpColList TABLE(
			strContractEndMonth nvarchar(max)
		)

		--select @cols = STUFF((select ',' + QUOTENAME(strType) 
		--					from @List
		--					where strType not in('Position') and strType <> CASE WHEN isnull(@intVendorId,0) = 0 THEN '' ELSE 'Net Hedge' END
		--					group by strType, intSeqNo
		--					order by intSeqNo, strType
		--			FOR XML PATH(''), TYPE
		--			).value('.', 'NVARCHAR(MAX)') 
		--		,1,1,'')

	
		select @cols = STUFF((select ',' + QUOTENAME(strContractEndMonth) 
							from @List
							group by strContractEndMonth
							order by case when strContractEndMonth = 'Near By' then 0 else 1 end , CASE WHEN  strContractEndMonth not in('Near By','Total') THEN CONVERT(DATETIME,'01 '+strContractEndMonth) END
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')


		insert into @tmpColList (strContractEndMonth)
		SELECT DISTINCT strContractEndMonth
					from @List
					where strType not in('Position') and strType <> CASE WHEN isnull(@intVendorId,0) = 0 THEN '' ELSE 'Net Hedge' END
					--order by case when strContractEndMonth = 'Near By' then 0 else 1 end
					--group by strContractEndMonth


				WHILE EXISTS (SELECT TOP 1 strContractEndMonth FROM @tmpColList)
				BEGIN
					DECLARE @strCol AS NVARCHAR(max)
					SET @colCtr = @colCtr + 1;

					SELECT TOP 1 @strCol = strContractEndMonth FROM @tmpColList order by case when strContractEndMonth = 'Near By' then 0 else 1 end , CASE WHEN  strContractEndMonth not in('Near By','Total') THEN CONVERT(DATETIME,'01 '+strContractEndMonth) END
			

					SET @colstry = @colstry + '''' + @strCol + ''' as col' + cast(@colCtr as nvarchar(20)) + ','
			
					DELETE FROM @tmpColList WHERE strContractEndMonth = @strCol 

				END
			

			SET @colstry = SUBSTRING(@colstry,0,LEN(@colstry))



			--IF @ysnIsCrushPosition = 1
			--BEGIN
			--	SET @colstry = SUBSTRING(@colstry,0,LEN(@colstry))
			--END
			--ELSE
			--BEGIN
			--	SET @colstry = @colstry + '''Position''as col' +  cast(@colCtr + 1 as nvarchar(20)) +' '
			--	SET @cols = @cols + ',[Position]'
			--END

			DECLARE @GrandTotalCol	NVARCHAR (MAX)

			SELECT @GrandTotalCol = COALESCE (@GrandTotalCol + 'ISNULL ([' + CAST (strContractEndMonth AS VARCHAR) +'],0) + ', 'ISNULL([' + CAST(strContractEndMonth AS VARCHAR)+ '],0) + ')
			FROM @List
			GROUP BY strContractEndMonth
			ORDER BY strContractEndMonth
			SET @GrandTotalCol = LEFT (@GrandTotalCol, LEN (@GrandTotalCol)-1)
			
			
			set @query = N'

					SELECT intSeqNo as col1 ,strType,  ('+ @GrandTotalCol + ') AS [dblTotal],' + @cols + N' into ##tmpTry from 
					 (
               			select * from (
							select strCommodityCode, strType, sum(dblTotal) as dblTotal, strContractEndMonth, intSeqNo
							from #tmpList
							group by strContractEndMonth,strCommodityCode,strType, intSeqNo
						) t
					) x
					pivot 
					(
						sum(dblTotal)
						for strContractEndMonth in (' + @cols + N')
					) p
			 

					'
	 
		exec (@query)


		exec ('select 0 as col1,''     '' as col2, ''Total'' as col3, '+ @colstry +' into ##tmpTry2')


		 DECLARE @colCAST AS NVARCHAR(MAX)

		 select @colCAST = STUFF((SELECT ',CAST(CONVERT(varchar,cast(round(' + QUOTENAME([name]) + ',2)as money),1) as nvarchar(max))'
							from tempdb.sys.columns where object_id = (SELECT object_id FROM tempdb.sys.objects WHERE name = '##tmpTry') and [name] not in ('col1','strType')
							ORDER BY column_id
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')


	
		 DECLARE @colSUM AS NVARCHAR(MAX)

	--	 select @colSUM = STUFF((SELECT ',CAST(CONVERT(varchar,cast(sum(' + QUOTENAME([name]) + ')as money),1) as nvarchar(max))'
	--						from tempdb.sys.columns where object_id = (SELECT object_id FROM tempdb.sys.objects WHERE name = '##tmpTry') and [name] not in ('col1','strContractEndMonth')
	--						ORDER BY column_id
	--				FOR XML PATH(''), TYPE
	--				).value('.', 'NVARCHAR(MAX)') 
	--			,1,1,'')

		set @strLocationName =  replace( @strLocationName,'''','''''')
		set @strEntityName =  replace( @strEntityName,'''','''''')

		exec (N' SELECT *, '''+ @xmlParam +''' AS xmlParam 
		, '''+ @strCommodityCode +''' AS strCommodityCode
		, '''+ @dtmToDate +''' AS dtmToDate
		, '''+ @strLocationName +''' AS strLocationName
		, '''+ @strPositionIncludes +''' AS strPositionIncludes 
		, '''+ @intDPRRunNumber +''' AS intDPRRunNumber 
		, '''+ @strEntityName +''' AS strEntityName 
		FROM (
			select * from ##tmpTry2
			union all
			select col1,strType,
				' + @colCAST +'
			from ##tmpTry
		
		) t ORDER BY col1 '
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
			@intDPRRunNumber as intDPRRunNumber,
			@strEntityName as strEntityName

	END
END