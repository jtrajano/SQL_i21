CREATE PROCEDURE uspRKM2MInquirySummary 
		@intM2MBasisId INT
AS
DECLARE @ysnIncludeBasisDifferentialsInResults BIT
DECLARE @dtmPriceDate DATETIME

SELECT @dtmPriceDate = dtmM2MBasisDate
FROM tblRKM2MBasis
WHERE intM2MBasisId = @intM2MBasisId

SELECT @ysnIncludeBasisDifferentialsInResults = ysnIncludeBasisDifferentialsInResults
FROM tblRKCompanyPreference

IF @ysnIncludeBasisDifferentialsInResults = 1
BEGIN
	SELECT *
	INTO #temp
	FROM tblRKM2MBasisDetail
	WHERE intM2MBasisId = @intM2MBasisId
END

SELECT *
	,isnull(dblCosts, 0) + (isnull(dblContractBasis, 0) + ISNULL(dblFutures, 0)) AS dblAdjustedContractPrice
	,isnull(dblFuturesClosingPrice, 0) + isnull(dblMarketBasis, 0) dblCashPrice
	,isnull(dblFuturesClosingPrice, 0) + isnull(dblMarketBasis, 0) dblMarketPrice
	,CASE 
		WHEN intContractTypeId = 1
			AND (((isnull(dblFuturesClosingPrice, 0) + isnull(dblMarketBasis, 0)) - (isnull(dblContractBasis, 0) + isnull(dblFutures, 0)))) < 0
			THEN ((isnull(dblFuturesClosingPrice, 0) + isnull(dblMarketBasis, 0)) - (isnull(dblContractBasis, 0) + isnull(dblFutures, 0))) * dblOpenQty
		WHEN intContractTypeId = 1
			AND (((isnull(dblFuturesClosingPrice, 0) + isnull(dblMarketBasis, 0)) - (isnull(dblContractBasis, 0) + isnull(dblFutures, 0)))) >= 0
			THEN abs((isnull(dblFuturesClosingPrice, 0) + isnull(dblMarketBasis, 0)) - (isnull(dblContractBasis, 0) + isnull(dblFutures, 0))) * dblOpenQty
		WHEN intContractTypeId = 2
			AND (((isnull(dblFuturesClosingPrice, 0) + isnull(dblMarketBasis, 0)) - (isnull(dblContractBasis, 0) + isnull(dblFutures, 0)))) <= 0
			THEN abs((isnull(dblFuturesClosingPrice, 0) + isnull(dblMarketBasis, 0)) - (isnull(dblContractBasis, 0) + isnull(dblFutures, 0))) * dblOpenQty
		WHEN intContractTypeId = 2
			AND (((isnull(dblFuturesClosingPrice, 0) + isnull(dblMarketBasis, 0)) - (isnull(dblContractBasis, 0) + isnull(dblFutures, 0)))) > 0
			THEN - ((isnull(dblFuturesClosingPrice, 0) + isnull(dblMarketBasis, 0)) - (isnull(dblContractBasis, 0) + isnull(dblFutures, 0))) * dblOpenQty
		END dblResult
	,CASE 
		WHEN intContractTypeId = 1
			AND ((isnull(dblMarketBasis, 0) - (dblContractBasis + dblCosts))) < 0
			THEN (isnull(dblMarketBasis, 0) - (dblContractBasis + dblCosts)) * dblOpenQty
		WHEN intContractTypeId = 1
			AND ((isnull(dblMarketBasis, 0) - (dblContractBasis + dblCosts))) >= 0
			THEN abs(isnull(dblMarketBasis, 0) - (dblContractBasis + dblCosts)) * dblOpenQty
		WHEN intContractTypeId = 2
			AND ((isnull(dblMarketBasis, 0) - (dblContractBasis + dblCosts))) <= 0
			THEN abs(isnull(dblMarketBasis, 0) - (dblContractBasis + dblCosts)) * dblOpenQty
		WHEN intContractTypeId = 2
			AND ((isnull(dblMarketBasis, 0) - (dblContractBasis + dblCosts))) > 0
			THEN - (isnull(dblMarketBasis, 0) - (dblContractBasis + dblCosts)) * dblOpenQty
		END dblResultBasis
	,CASE 
		WHEN intContractTypeId = 1
			AND (((dblFuturesClosingPrice - dblFutures) * dblOpenQty) < 0)
			THEN (dblFuturesClosingPrice - dblFutures) * dblOpenQty
		WHEN intContractTypeId = 1
			AND (((dblFuturesClosingPrice - dblFutures) * dblOpenQty) >= 0)
			THEN abs(dblFuturesClosingPrice - dblFutures) * dblOpenQty
		WHEN intContractTypeId = 2
			AND (((dblFuturesClosingPrice - dblFutures) * dblOpenQty) <= 0)
			THEN abs(dblFuturesClosingPrice - dblFutures) * dblOpenQty
		WHEN intContractTypeId = 2
			AND (((dblFuturesClosingPrice - dblFutures) * dblOpenQty) > 0)
			THEN - (dblFuturesClosingPrice - dblFutures) * dblOpenQty
		END dblMarketFuturesResult
	,CASE 
		WHEN intContractTypeId = 1
			AND ((isnull(dblMarketBasis, 0) - isnull(dblCash, 0))) < 0
			THEN (isnull(dblMarketBasis, 0) - isnull(dblCash, 0)) * dblOpenQty
		WHEN intContractTypeId = 1
			AND ((isnull(dblMarketBasis, 0) - isnull(dblCash, 0))) >= 0
			THEN abs(isnull(dblMarketBasis, 0) - isnull(dblCash, 0)) * dblOpenQty
		WHEN intContractTypeId = 2
			AND ((isnull(dblMarketBasis, 0) - isnull(dblCash, 0))) <= 0
			THEN abs(isnull(dblMarketBasis, 0) - isnull(dblCash, 0)) * dblOpenQty
		WHEN intContractTypeId = 2
			AND ((isnull(dblMarketBasis, 0) - isnull(dblCash, 0))) > 0
			THEN - (isnull(dblMarketBasis, 0) - isnull(dblCash, 0)) * dblOpenQty
		END dblResultCash
	,isnull(dblContractBasis, 0) + isnull(dblFutures, 0) dblContractPrice
INTO #tempSummary
FROM (
	SELECT cd.intContractDetailId
		,'Contract' + '(' + LEFT(ch.strContractType, 1) + ')' AS strContractOrInventoryType
		,cd.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq) AS strContractSeq
		,cd.strEntityName strEntityName
		,cd.intEntityId
		,cd.strFutMarketName
		,cd.intFutureMarketId
		,cd.strFutureMonth
		,cd.intFutureMonthId
		,cd.dblBalance AS dblOpenQty
		,cd.strCommodityCode
		,cd.intCommodityId
		,cd.strItemNo
		,cd.intItemId AS intItemId
		,cd.strOriginDest AS strOrgin
		,cd.intOriginId intOriginId
		,ch.strPosition
		,RIGHT(CONVERT(VARCHAR(8), dtmStartDate, 3), 5) + '-' + RIGHT(CONVERT(VARCHAR(8), dtmEndDate, 3), 5) AS strPeriod
		,cd.strPricingStatus AS strPriOrNotPriOrParPriced
		,cd.intPricingTypeId
		,cd.strPricingType
		,isnull(cd.dblBasis, 0) dblContractBasis
		,(
			SELECT avgLot / intTotLot
			FROM (
				SELECT sum(intNoOfLots * dblFixationPrice) + ((max(cdv.dblNoOfLots) - sum(intNoOfLots)) * max(dbo.fnRKGetLatestClosingPrice(cdv.intFutureMarketId, cdv.intFutureMonthId, @dtmPriceDate))) avgLot
					,max(cdv.dblNoOfLots) intTotLot
				FROM tblCTPriceFixation pf
				INNER JOIN tblCTPriceFixationDetail pfd ON pf.intPriceFixationId = pfd.intPriceFixationId
					AND cd.intContractDetailId = pf.intContractDetailId
					AND pf.intContractHeaderId = cd.intContractHeaderId
				INNER JOIN tblCTContractDetail cdv ON cdv.intContractDetailId = pf.intContractDetailId
					AND cdv.intContractHeaderId = pf.intContractHeaderId
				) t
			) dblFutures
		,CASE 
			WHEN cd.intPricingTypeId = 6
				THEN dblCashPrice
			ELSE NULL
			END dblCash
		,isnull((
				SELECT SUM(dblRate)
				FROM tblCTContractCost ct
				WHERE cd.intContractDetailId = ct.intContractDetailId
				), 0) dblCosts
		,isnull((
				SELECT TOP 1 isnull(dblBasisOrDiscount, 0) + isnull(dblCashOrFuture, 0)
				FROM #temp TEMP
				WHERE TEMP.intM2MBasisId = @intM2MBasisId
					AND isnull(TEMP.intItemId, 0) = CASE 
						WHEN isnull(TEMP.intItemId, 0) = 0
							THEN 0
						ELSE cd.intItemId
						END
					AND RIGHT(CONVERT(VARCHAR(11), TEMP.strPeriodTo, 106), 8) = CASE 
						WHEN isnull(TEMP.strPeriodTo, '') = ''
							THEN ''
						ELSE RIGHT(CONVERT(VARCHAR(11), cd.dtmEndDate, 106), 8)
						END
					AND isnull(TEMP.intCompanyLocationId, 0) = CASE 
						WHEN isnull(TEMP.intCompanyLocationId, 0) = 0
							THEN 0
						ELSE isnull(cd.intCompanyLocationId, 0)
						END
					AND TEMP.intContractTypeId = ch.intContractTypeId
				), 0) AS dblMarketBasis
		,dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId, cd.intFutureMonthId, @dtmPriceDate) AS dblFuturesClosingPrice
		,convert(INT, ch.intContractTypeId) intContractTypeId
		,0 AS intConcurrencyId
	FROM vyuCTContractDetailView cd
	INNER JOIN vyuCTContractHeaderView ch ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.dblBalance > 0
	INNER JOIN tblICItem i ON cd.intItemId = i.intItemId
	LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = i.intOriginId
	WHERE intContractStatusId <> 3
	) t

DECLARE @tblRow TABLE (
	RowNumber INT IDENTITY(1, 1)
	,intCommodityId INT
	)
DECLARE @tblFinalDetail TABLE (
	RowNumber INT IDENTITY(1, 1)
	,strSummary NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strContractOrInventoryType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblQty NUMERIC(24, 10)
	,dblTotal NUMERIC(24, 10)
	,dblFutures NUMERIC(24, 10)
	,dblBasis NUMERIC(24, 10)
	,dblCash NUMERIC(24, 10)
	)

INSERT INTO @tblRow (intCommodityId)
SELECT intCommodityId
FROM (
	SELECT DISTINCT intCommodityId
		,strCommodityCode
	FROM #tempSummary
	
	UNION
	
	SELECT DISTINCT intCommodityId
		,strCommodityCode
	FROM vyuRKUnrealizedPnL
	) t
ORDER BY strCommodityCode

DECLARE @mRowNumber INT
DECLARE @intCommodityId INT
DECLARE @strDescription NVARCHAR(50)

SELECT @mRowNumber = MIN(RowNumber)
FROM @tblRow

WHILE @mRowNumber > 0
BEGIN
	SET @intCommodityId = 0
	SET @strDescription = ''

	SELECT @intCommodityId = intCommodityId
	FROM @tblRow
	WHERE RowNumber = @mRowNumber

	SELECT @strDescription = strDescription
	FROM tblICCommodity
	WHERE intCommodityId = @intCommodityId
	
		INSERT INTO @tblFinalDetail (
		strSummary
		,intCommodityId
		,strCommodityCode
		,strContractOrInventoryType
		,dblQty
		,dblTotal
		,dblFutures
		,dblBasis
		,dblCash
		)
	
	SELECT '' strSummary
		,NULL intCommodityId
		,@strDescription AS strCommodityCode
		,'' strContractOrInventoryType
		,NULL AS dblQty
		,NULL AS dblTotal
		,NULL AS dblFutures
		,NULL AS dblBasis
		,NULL AS dblCash
	

	INSERT INTO @tblFinalDetail (
		strSummary
		,intCommodityId
		,strCommodityCode
		,strContractOrInventoryType
		,dblQty
		,dblTotal
		,dblFutures
		,dblBasis
		,dblCash
		)
	
		SELECT 'Physical' strSummary
			,intCommodityId
			,'' strCommodityCode
			,strContractOrInventoryType
			,sum(isnull(dblOpenQty, 0)) dblQty
			,CASE 
				WHEN sum(ISNULL(dblCash, 0)) = 0
					THEN sum(ISNULL(dblMarketFuturesResult, 0)) + sum(isnull(dblResultBasis, 0))
				ELSE sum(isnull(dblResultCash, 0))
				END AS dblTotal
			,sum(isnull(dblMarketFuturesResult, 0)) AS dblFutures
			,sum(isnull(dblResultBasis, 0)) AS dblBasis
			,sum(isnull(dblResultCash, 0)) AS dblCash
		FROM #tempSummary s
		WHERE s.intCommodityId = @intCommodityId
		GROUP BY intCommodityId
			,strCommodityCode
			,strContractOrInventoryType
		
		INSERT INTO @tblFinalDetail (
		strSummary
		,intCommodityId
		,strCommodityCode
		,strContractOrInventoryType
		,dblQty
		,dblTotal
		,dblFutures
		,dblBasis
		,dblCash
		)
		
		SELECT 'Derivatives' strSummary
			,intCommodityId
			,'' strCommodityCode
			,'' strContractOrInventoryType
			,NULL AS dblQty
			,pnl AS dblTotal
			,NULL AS dblFutures
			,NULL AS dblBasis
			,NULL AS dblCash
		FROM (
			SELECT DISTINCT intCommodityId
				,strCommodityCode
				,sum((ISNULL(GrossPnL, 0) * (isnull(dbo.fnRKGetLatestClosingPrice(vp.intFutureMarketId, vp.intFutureMonthId, @dtmPriceDate), 0) - isnull(dblPrice, 0))) - isnull(dblFutCommission, 0)) pnl
			FROM vyuRKUnrealizedPnL vp
			WHERE intCommodityId = @intCommodityId
			GROUP BY intCommodityId
				,strCommodityCode
			) t
	
	SELECT @mRowNumber = MIN(RowNumber)
	FROM @tblRow
	WHERE RowNumber > @mRowNumber
END

SELECT *,0 as intConcurrencyId  
FROM @tblFinalDetail
	
--uspRKM2MInquirySummary 6