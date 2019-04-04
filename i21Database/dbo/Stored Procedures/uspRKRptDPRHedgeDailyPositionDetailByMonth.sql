﻿CREATE PROCEDURE [dbo].[uspRKRptDPRHedgeDailyPositionDetailByMonth]
		@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN
	DECLARE @idoc INT
		,@intCommodityId nvarchar(max)
		,@intLocationId nvarchar(max) = NULL		
		,@intVendorId int = null
		,@strPurchaseSales nvarchar(50) = NULL
				,@strPositionIncludes nvarchar(50) = NULL
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

if isnull(@strPurchaseSales,'') <> ''
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

DECLARE @strCommodityCode NVARCHAR(50)

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

SELECT  @strCommodityCode = strCommodityCode FROM tblICCommodity    WHERE intCommodityId IN (SELECT intCommodityId FROM @Commodity)

DECLARE @List AS TABLE (  
	 intSeqNo int,
     intRowNumber INT,
	 strCommodityCode NVARCHAR(200), 
	 strContractNumber NVARCHAR(200),
	 intContractHeaderId int,
	 strInternalTradeNo NVARCHAR(200),
	 intFutOptTransactionHeaderId int,
	 strType  NVARCHAR(50),
	 strLocationName NVARCHAR(100),
	 strContractEndMonth NVARCHAR(50),
	 strContractEndMonthNearBy NVARCHAR(50),
	 dblTotal DECIMAL(24,10)
	 ,strUnitMeasure NVARCHAR(50)
	 ,strAccountNumber NVARCHAR(100)
	 ,strTranType NVARCHAR(20)
	 ,dblNoOfLot NUMERIC(24, 10)
	 ,dblDelta NUMERIC(24, 10)
	 ,intBrokerageAccountId int
	 ,strInstrumentType nvarchar(50)
     ) 

	 INSERT INTO @List
	 EXEC uspRKDPRHedgeDailyPositionDetailByMonth @intCommodityId, @intLocationId, @intVendorId, @strPurchaseSales, @strPositionIncludes

	DECLARE @ctr as int
	SELECT @ctr = COUNT(intRowNumber) FROM @List 

    IF @ctr > 0 
    BEGIN

	 SELECT 
		strCommodityCode
		,strContractEndMonth
		,[Purchase Basis] as PurcahseBasis
		,[Purchase Priced] as PurchasePriced
		,[Purchase HTA] as PurchaseHTA
		,[Sale Basis] as SaleBasis
		,[Sale Priced] as SalePriced
		,[Sale HTA] as SaleHTA
		,[Net Hedge] as NetHedge
		,[Position]
		,@xmlParam AS xmlParam
	 FROM
		(
           select * from (
				select strCommodityCode, strType, sum(dblTotal) as dblTotal, strContractEndMonth
				from @List
				group by strContractEndMonth,strCommodityCode,strType
			) t
         ) x
         pivot 
         (
            sum(dblTotal)
            for strType in ([Purchase Basis],[Purchase Priced],[Purchase HTA],[Sale Basis],[Sale Priced],[Sale HTA],[Net Hedge],[Position])
				
         ) p order by CASE WHEN  strContractEndMonth not in('Near By','Total') THEN CONVERT(DATETIME,'01 '+strContractEndMonth) END

	END
	ELSE
		    SELECT 
            @strCommodityCode as strCommodityCode
            ,'' as strContractEndMonth
            ,NULL as PurcahseBasis
            ,NULL as PurchasePriced
            ,NULL as PurchaseHTA
            ,NULL as PurchaseRatio
            ,NULL as SaleBasis
            ,NULL as SalePriced
            ,NULL as SaleHTA
            ,NULL as SaleRatio
            ,NULL as NetHedge
            ,NULL as Position
            ,@xmlParam as xmlParam


END
