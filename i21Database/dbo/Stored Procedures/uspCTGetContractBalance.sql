CREATE PROCEDURE [dbo].[uspCTGetContractBalance]
	@intContractTypeId INT = NULL
	, @intEntityId INT = NULL
	, @IntCommodityId INT = NULL
	, @dtmEndDate DATE = NULL
	, @intCompanyLocationId INT = NULL
	, @IntFutureMarketId INT = NULL
	, @IntFutureMonthId INT = NULL
	, @strPositionIncludes NVARCHAR(MAX) = NULL
	, @strCallingApp NVARCHAR(MAX) = NULL
	, @strPrintOption NVARCHAR(MAX) = NULL
	, @IntLocalTimeOffset int  = null	

AS

BEGIN 

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@blbHeaderLogo			VARBINARY(MAX),
			@intContractDetailId	INT,
			@intShipmentKey			INT,
			@intReceiptKey			INT,
			@intPriceFixationKey	INT,
			@dblShipQtyToAllocate	NUMERIC(38,20),
			@dblAllocatedQty		NUMERIC(38,20),
			@dblPriceQtyToAllocate  NUMERIC(38,20),
			@strCompanyName			NVARCHAR(500)
		
	SELECT	@strCompanyName	=	CASE 
									WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL 
									ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) 
								END
	FROM	tblSMCompanySetup

	SELECT @blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header')

	DECLARE @tblStatus TABLE
	(
		intContractDetailId INT,
		intContractStatusId INT,
		dblFutures NUMERIC(18, 6),
		dblBasis NUMERIC(18, 6)
	)

	INSERT INTO @tblStatus(intContractDetailId, intContractStatusId, dblFutures, dblBasis)
	SELECT intContractDetailId, intContractStatusId, dblFutures, dblBasis
	FROM
	(
		SELECT intRowNumber = ROW_NUMBER() OVER (PARTITION BY CBL.intContractDetailId ORDER BY dtmCreatedDate DESC)
			, CBL.intContractDetailId
			, CBL.intContractStatusId
			, dblFutures = CASE WHEN CD.dblFutures IS NOT NULL THEN CD.dblFutures ELSE CASE WHEN strNotes LIKE '%Priced Quantity is%' OR strNotes LIKE '%Priced Load is%' THEN NULL ELSE CBL.dblFutures END END
			, dblBasis = CASE WHEN CD.dblBasis IS NOT NULL THEN CD.dblBasis ELSE CASE WHEN strNotes LIKE '%Priced Quantity is%' OR strNotes LIKE '%Priced Load is%' THEN NULL ELSE CBL.dblBasis END END
		FROM tblCTContractBalanceLog CBL
		INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = CBL.intContractDetailId
		WHERE dbo.fnRemoveTimeOnDate((case when @IntLocalTimeOffset is not null then dateadd(minute,@IntLocalTimeOffset,DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), @IntLocalTimeOffset)) else CBL.dtmTransactionDate end)) <= @dtmEndDate
	) tbl
	WHERE intRowNumber = 1

	-- FOR IMPROVEMENT
	--IF ISNULL(@strCallingApp,'') = 'DPR'
	--BEGIN
	--	DELETE FROM tblCTContractBalance WHERE dtmEndDate = @dtmEndDate
	--	INSERT INTO tblCTContractBalance(dtmEndDate
	--		,intContractHeaderId
	--		,strType
	--		,intContractDetailId
	--		,strDate
	--		,strContractType
	--		,intCommodityId
	--		,strCommodityCode
	--		,strCommodity
	--		,intItemId
	--		,strItemNo
	--		,intCompanyLocationId
	--		,strLocationName
	--		,strCustomer
	--		,strContract
	--		,strPricingType
	--		,strContractDate
	--		,strShipMethod
	--		,strShipmentPeriod
	--		,intFutureMarketId
	--		,intFutureMonthId
	--		,strDeliveryMonth
	--		,strFutureMonth
	--		,dblFutures
	--		,dblBasis
	--		,strBasisUOM
	--		,dblQuantity
	--		,strQuantityUOM
	--		,dblCashPrice
	--		,strPriceUOM
	--		,strStockUOM
	--		,dblAvailableQty
	--		,dblAmount
	--		,dblQtyinCommodityStockUOM
	--		,dblFuturesinCommodityStockUOM
	--		,dblBasisinCommodityStockUOM
	--		,dblCashPriceinCommodityStockUOM
	--		,dblAmountinCommodityStockUOM)
	--	SELECT dtmTransactionDate = MAX(dtmTransactionDate)
	--		,intContractHeaderId
	--		,strType
	--		,intContractDetailId
	--		,strDate
	--		,strContractType
	--		,intCommodityId
	--		,strCommodityCode
	--		,strCommodity
	--		,intItemId
	--		,strItemNo
	--		,intCompanyLocationId
	--		,strLocationName
	--		,strCustomer
	--		,strContract
	--		,strPricingType
	--		,strContractDate
	--		,strShipMethod
	--		,strShipmentPeriod
	--		,intFutureMarketId
	--		,intFutureMonthId
	--		,strDeliveryMonth
	--		,strFutureMonth
	--		,dblFutures 						= CASE WHEN ISNULL(MAX(dblFutures), 0) = 0 THEN NULL ELSE CASE WHEN SUM(ISNULL(dblOrigQty, 0)) <> 0 THEN CAST (SUM(CASE WHEN ISNULL(dblFutures, 0) <> 0 THEN dblFutures * dblOrigQty ELSE 0 END) / SUM(ISNULL(dblOrigQty, 0)) AS NUMERIC(20,6)) ELSE NULL END END
	--		,dblBasis 							= CASE WHEN ISNULL(MAX(dblBasis), 0) = 0 THEN NULL ELSE CASE WHEN SUM(ISNULL(dblOrigQty, 0)) <> 0 THEN CAST (SUM(CASE WHEN ISNULL(dblBasis, 0) <> 0 THEN dblBasis * dblOrigQty ELSE 0 END) / SUM(ISNULL(dblOrigQty, 0)) AS NUMERIC(20,6)) ELSE NULL END END
	--		,strBasisUOM
	--		,dblQuantity 						= CAST (SUM(dblQuantity) AS NUMERIC(20,6))
	--		,strQuantityUOM
	--		,dblCashPrice 						= CASE WHEN ISNULL(MAX(dblCashPrice), 0) = 0 THEN NULL ELSE CASE WHEN SUM(ISNULL(dblOrigQty, 0)) <> 0 THEN CAST (SUM(CASE WHEN ISNULL(dblCashPrice, 0) <> 0 THEN dblCashPrice * dblOrigQty ELSE 0 END) / SUM(ISNULL(dblOrigQty, 0)) AS NUMERIC(20,6)) ELSE NULL END END
	--		,strPriceUOM
	--		,strStockUOM
	--		,dblAvailableQty 					= CAST (SUM(dblAvailableQty) AS NUMERIC(20,6))
	--		,dblAmount 							= CAST ((SUM(dblQuantity) * ((CASE WHEN ISNULL(MAX(dblBasis), 0) = 0 THEN NULL ELSE CASE WHEN SUM(ISNULL(dblOrigQty, 0)) <> 0 THEN CAST (SUM(CASE WHEN ISNULL(dblBasis, 0) <> 0 THEN dblBasis * dblOrigQty ELSE 0 END) / SUM(ISNULL(dblOrigQty, 0)) AS NUMERIC(20,6)) ELSE NULL END END) + (CASE WHEN ISNULL(MAX(dblFutures), 0) = 0 THEN NULL ELSE CASE WHEN SUM(ISNULL(dblOrigQty, 0)) <> 0 THEN CAST (SUM(CASE WHEN ISNULL(dblFutures, 0) <> 0 THEN dblFutures * dblOrigQty ELSE 0 END) / SUM(ISNULL(dblOrigQty, 0)) AS NUMERIC(20,6)) ELSE NULL END END))) AS NUMERIC(20,6))
	--		,dblQtyinCommodityStockUOM 			= CAST (SUM(dblQtyinCommodityStockUOM) AS NUMERIC(20,6))
	--		,dblFuturesinCommodityStockUOM 		= CAST (MAX(dblFuturesinCommodityStockUOM) AS NUMERIC(20,6))
	--		,dblBasisinCommodityStockUOM		= CAST (MAX(dblBasisinCommodityStockUOM) AS NUMERIC(20,6))
	--		,dblCashPriceinCommodityStockUOM 	= CAST (MAX(dblCashPriceinCommodityStockUOM) AS NUMERIC(20,6))
	--		,dblAmountinCommodityStockUOM 		= CAST (SUM(dblAmountinCommodityStockUOM) AS NUMERIC(20,6))
	--	FROM
	--	(
	--		SELECT  intContractBalanceId			=	intContractBalanceLogId
	--			,dtmTransactionDate					=	CASE WHEN CBL.strAction = 'Created Price' THEN CBL.dtmTransactionDate ELSE dbo.[fnCTConvertDateTime](CBL.dtmCreatedDate,'ToServerDate',0) END--dtmTransactionDate
	--			,CBL.intContractHeaderId
	--			,strType							=	CASE WHEN CBL.intPricingTypeId = 1 THEN 'PriceFixation' ELSE 'Basis' END	
	--			,CBL.intContractDetailId
	--			,strCompanyName						=	@strCompanyName
	--			,blbHeaderLogo						=	@blbHeaderLogo
	--			,strDate							=	LTRIM(DATEPART(mm,GETDATE())) + '-' + LTRIM(DATEPART(dd,GETDATE())) + '-' + RIGHT(LTRIM(DATEPART(yyyy,GETDATE())),2)			
	--			,strContractType					=	CASE WHEN CBL.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sale' END
	--			,CBL.intCommodityId
	--			,strCommodityCode					=	CY.strCommodityCode
	--			,strCommodity						=	CM.strDescription +' '+ UOM.strUnitMeasure
	--			,CBL.intItemId
	--			,strItemNo							=	IM.strItemNo
	--			,intCompanyLocationId				=	CBL.intLocationId
	--			,strLocationName					=	L.strLocationName
	--			,strCustomer						=	EY.strEntityName
	--			,strContract						=	CBL.strContractNumber + '-' + LTRIM(CBL.intContractSeq)
	--			,strPricingType						=	CASE WHEN CBL.intPricingTypeId = 1 THEN 'P' ELSE 'B' END
	--			,strContractDate					=	LEFT(CONVERT(NVARCHAR,CH.dtmContractDate,101),5)
	--			,strShipMethod						=	FT.strFreightTerm
	--			,strShipmentPeriod					=	LTRIM(DATEPART(mm,CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmStartDate)) + ' - ' + LTRIM(DATEPART(mm,CD.dtmEndDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmEndDate))
	--			,CBL.intFutureMarketId
	--			,CBL.intFutureMonthId
	--			,strDeliveryMonth					=	LEFT(DATENAME(MONTH, CD.dtmEndDate), 3) + ' ' + RIGHT(DATENAME(YEAR, CD.dtmEndDate),2)
	--			,strFutureMonth						=	FH.strFutureMonth
	--			,dblFutures							=	CASE WHEN CBL.intPricingTypeId IN (1, 3) THEN CBL.dblFutures ELSE NULL END
	--			,dblBasis							=	CASE WHEN CBL.intPricingTypeId = 3 THEN NULL ELSE CAST(CBL.dblBasis AS NUMERIC(20,6)) END
	--			,strBasisUOM						=	BUOM.strUnitMeasure
	--			,dblQuantity						=	CBL.dblQty
	--			,strQuantityUOM						=	IUM.strUnitMeasure
	--			,dblCashPrice						=	CASE WHEN CBL.intPricingTypeId = 1 THEN ISNULL(CBL.dblFutures,0) + ISNULL(CBL.dblBasis,0) ELSE NULL END
	--			,strPriceUOM						=	PUOM.strUnitMeasure			
	--			,strStockUOM						=	dbo.fnCTGetCommodityUOM(C1.intUnitMeasureId)
	--			,dblAvailableQty					=	CBL.dblQty
	--			,dblAmount							=	CASE 
	--														WHEN CBL.intPricingTypeId = 1 THEN 
	--														[dbo].[fnCTConvertQtyToStockItemUOM](CD.intItemUOMId, CBL.dblQty) * [dbo].[fnCTConvertPriceToStockItemUOM](CD.intPriceItemUOMId,ISNULL(CBL.dblFutures, 0) + ISNULL(CBL.dblBasis, 0))
	--														ELSE NULL
	--													END
	--			,dblQtyinCommodityStockUOM			=	dbo.fnCTConvertQtyToTargetCommodityUOM(CH.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId),C1.intUnitMeasureId, CBL.dblQty)
	--			,dblFuturesinCommodityStockUOM		=	CASE WHEN CBL.intPricingTypeId IN (1,3) THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CBL.dblFutures,0)),0) ELSE NULL END
	--			,dblBasisinCommodityStockUOM		=	CASE WHEN CBL.intPricingTypeId <> 3 THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId),ISNULL(CBL.dblBasis,0)),0) ELSE NULL END
	--			,dblCashPriceinCommodityStockUOM	=	CASE 
	--														WHEN CBL.intPricingTypeId = 1 THEN ISNULL(dbo.fnCTConvertCostToTargetCommodityUOM(CH.intCommodityId,CD.intBasisUOMId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId), ISNULL(CBL.dblFutures,0) + ISNULL(CBL.dblBasis,0)),0)
	--														ELSE NULL
	--													END
	--			,dblAmountinCommodityStockUOM		= 	CASE WHEN CBL.intPricingTypeId = 1 THEN (dbo.fnCTConvertQtyToTargetCommodityUOM(CH.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId),C1.intUnitMeasureId, CBL.dblQty))
	--														*-- This is dblCashPriceinCommodityStockUOM
	--														(ISNULL(dbo.fnCTConvertCostToTargetCommodityUOM(CH.intCommodityId,CD.intBasisUOMId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId), ISNULL(CBL.dblFutures,0) + ISNULL(CBL.dblBasis,0)),0))
	--													ELSE NULL END
	--			,strPrintOption						= 	@strPrintOption
	--			,CBL.intContractTypeId
	--			,CBL.intEntityId
	--			,dblOrigQty = CASE WHEN ISNULL(CH.ysnLoad, 0) = 1 THEN CAST(CASE WHEN ISNULL(CBL.strNotes, '') LIKE '%Priced Load is%' THEN REPLACE(CBL.strNotes, 'Priced Load is ', '') ELSE CBL.dblQty END AS NUMERIC(18, 6)) * CH.dblQuantityPerLoad
	--								ELSE CAST(CASE WHEN ISNULL(CBL.strNotes, '') LIKE '%Priced Quantity is%' THEN REPLACE(CBL.strNotes, 'Priced Quantity is ', '') ELSE CBL.dblQty END AS NUMERIC(18, 6)) END
	--		FROM tblCTContractBalanceLog		CBL
	--		INNER JOIN tblICCommodity			CY			ON CBL.intCommodityId = CY.intCommodityId
	--		INNER JOIN tblICCommodity			CM			ON CM.intCommodityId = CBL.intCommodityId
	--		INNER JOIN tblICCommodityUnitMeasure	C1		ON C1.intCommodityId = CBL.intCommodityId AND C1.intCommodityId = CM.intCommodityId AND C1.ysnStockUnit = 1
	--		INNER JOIN tblICUnitMeasure			UOM			ON UOM.intUnitMeasureId = C1.intUnitMeasureId
	--		INNER JOIN tblICItem				IM			ON IM.intItemId = CBL.intItemId
	--		INNER JOIN tblSMCompanyLocation		L			ON L.intCompanyLocationId = CBL.intLocationId
	--		INNER JOIN vyuCTEntity				EY			ON EY.intEntityId = CBL.intEntityId AND EY.strEntityType = (CASE WHEN CBL.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	--		INNER JOIN tblCTContractHeader		CH			ON CH.intContractHeaderId = CBL.intContractHeaderId
	--		INNER JOIN tblCTContractDetail		CD			ON CD.intContractDetailId = CBL.intContractDetailId
	--		INNER JOIN tblICItemUOM				ItemUOM		ON ItemUOM.intItemUOMId = CD.intItemUOMId
	--		INNER JOIN tblICUnitMeasure			IUM			ON IUM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	--		LEFT JOIN tblSMFreightTerms			FT			ON FT.intFreightTermId = CD.intFreightTermId
	--		LEFT JOIN	tblRKFuturesMonth		FH			ON FH.intFutureMonthId = CD.intFutureMonthId
	--		LEFT JOIN tblICItemUOM				BASISUOM	ON BASISUOM.intItemUOMId = CBL.intBasisUOMId
	--		LEFT JOIN tblICUnitMeasure			BUOM		ON BUOM.intUnitMeasureId = BASISUOM.intUnitMeasureId
	--		LEFT JOIN tblICItemUOM				PriceUOM	ON PriceUOM.intItemUOMId = CD.intPriceItemUOMId
	--		LEFT JOIN tblICUnitMeasure			PUOM		ON PUOM.intUnitMeasureId = PriceUOM.intUnitMeasureId	
	--		WHERE CBL.strTransactionType = 'Contract Balance'
	--	) tbl
	--	WHERE intContractTypeId			= CASE WHEN ISNULL(@intContractTypeId ,0) > 0		THEN @intContractTypeId	 	ELSE intContractTypeId		END
	--	AND intEntityId			 		= CASE WHEN ISNULL(@intEntityId ,0) > 0				THEN @intEntityId		 	ELSE intEntityId			END
	--	AND intCommodityId				= CASE WHEN ISNULL(@IntCommodityId ,0) > 0			THEN @IntCommodityId	 	ELSE intCommodityId	 		END
	--	AND intCompanyLocationId 		= CASE WHEN ISNULL(@intCompanyLocationId ,0) > 0	THEN @intCompanyLocationId	ELSE intCompanyLocationId	END
	--	AND ISNULL(intFutureMarketId,0)	= CASE 
	--											WHEN ISNULL(@IntFutureMarketId ,0) > 0		THEN @IntFutureMarketId		 
	--											ELSE ISNULL(intFutureMarketId,0)	 
	--										END
	--	AND ISNULL(intFutureMonthId,0)	= CASE 
	--											WHEN ISNULL(@IntFutureMonthId ,0) > 0		THEN @IntFutureMonthId		 
	--											ELSE ISNULL(intFutureMonthId,0)		 
	--										END
	--	AND dbo.fnRemoveTimeOnDate(dtmTransactionDate) <= @dtmEndDate
	--	GROUP BY intContractHeaderId
	--		,strType
	--		,intContractDetailId
	--		,strDate
	--		,strContractType
	--		,intCommodityId
	--		,strCommodityCode
	--		,strCommodity
	--		,intItemId
	--		,strItemNo
	--		,intCompanyLocationId
	--		,strLocationName
	--		,strCustomer
	--		,strContract
	--		,strPricingType
	--		,strContractDate
	--		,strShipMethod
	--		,strShipmentPeriod
	--		,intFutureMarketId
	--		,intFutureMonthId
	--		,strDeliveryMonth
	--		,strFutureMonth
	--		,strBasisUOM
	--		,strQuantityUOM
	--		,strPriceUOM
	--		,strStockUOM
	--		,strPrintOption
	--	HAVING SUM(dblQuantity) > 0
	--END
	--ELSE
	--BEGIN
		SELECT intContractBalanceId
			, dtmTransactionDate
			, intContractHeaderId
			, strType
			, intContractDetailId
			, strDate
			, strContractType
			, intCommodityId
			, strCommodityCode
			, strCommodity
			, intItemId
			, strItemNo
			, intCompanyLocationId
			, strLocationName
			, strCustomer
			, strContract
			, strPricingType
			, strContractDate
			, strShipMethod
			, strShipmentPeriod
			, intFutureMarketId
			, intFutureMonthId
			, strDeliveryMonth
			, strFutureMonth
			, dblFutures						= CASE WHEN intPricingTypeId = 2 THEN NULL ELSE dblFutures END
			, dblBasis
			, strBasisUOM
			, dblQuantity
			, strQuantityUOM
			, dblCashPrice 						= CASE WHEN intPricingTypeId = 1 THEN (ISNULL(dblFutures, 0) + ISNULL(dblBasis, 0)) ELSE NULL END
			, strPriceUOM
			, strStockUOM
			, dblAvailableQty
			, dblAmount 						= CASE WHEN intPricingTypeId = 1 THEN (ISNULL(dblFutures, 0) + ISNULL(dblBasis, 0)) * dblQuantity ELSE NULL END
			, dblQtyinCommodityStockUOM
			, dblFuturesinCommodityStockUOM 	= CASE WHEN intPricingTypeId IN (1, 3) THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(intPriceItemUOMId, dbo.fnGetItemStockUOM(intItemId), ISNULL(dblFutures, 0)), 0) ELSE NULL END
			, dblBasisinCommodityStockUOM		= CASE WHEN intPricingTypeId <> 3 THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(intPriceItemUOMId, dbo.fnGetItemStockUOM(intItemId), ISNULL(dblBasis, 0)), 0) ELSE NULL END
			, dblCashPriceinCommodityStockUOM 	= CASE WHEN intPricingTypeId = 1 THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(intPriceItemUOMId, dbo.fnGetItemStockUOM(intItemId), (ISNULL(dblFutures, 0) + ISNULL(dblBasis, 0))), 0) ELSE NULL END
			, dblAmountinCommodityStockUOM 		= CASE WHEN intPricingTypeId = 1 THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(intPriceItemUOMId, dbo.fnGetItemStockUOM(intItemId), (ISNULL(dblFutures, 0) + ISNULL(dblBasis, 0))), 0) ELSE NULL END * dblQtyinCommodityStockUOM
			, strPrintOption
			, intContractStatusId
		FROM (
			SELECT intContractBalanceId = MAX(intContractBalanceId)
				, dtmTransactionDate		= MAX(dtmTransactionDate)
				, intContractHeaderId
				, strType
				, Stat.intContractDetailId
				, strDate
				, strContractType
				, intCommodityId
				, strCommodityCode
				, strCommodity
				, intItemId
				, strItemNo
				, intCompanyLocationId
				, strLocationName
				, strCustomer
				, strContract
				, intPricingTypeId
				, strPricingType
				, strContractDate
				, strShipMethod
				, strShipmentPeriod
				, intFutureMarketId
				, intFutureMonthId
				, strDeliveryMonth
				, strFutureMonth
				, dblFutures 						= CASE WHEN MAX(Stat.dblFutures) IS NOT NULL THEN MAX(Stat.dblFutures) ELSE ((CASE WHEN ISNULL(MAX(cb.dblFutures), 0) = 0 THEN NULL ELSE CASE WHEN SUM(ISNULL(dblOrigQty, 0)) <> 0 THEN CAST (SUM(CASE WHEN ISNULL(cb.dblFutures, 0) <> 0 THEN cb.dblFutures * dblOrigQty ELSE 0 END) / SUM(ISNULL(dblOrigQty, 0)) AS NUMERIC(20,6)) ELSE NULL END END)) END
				, dblBasis 							= CASE WHEN MAX(Stat.dblBasis) IS NOT NULL THEN MAX(Stat.dblBasis) ELSE ((CASE WHEN ISNULL(MAX(cb.dblBasis), 0) = 0 THEN NULL ELSE CASE WHEN SUM(ISNULL(dblOrigQty, 0)) <> 0 THEN CAST (SUM(CASE WHEN ISNULL(cb.dblBasis, 0) <> 0 THEN cb.dblBasis * dblOrigQty ELSE 0 END) / SUM(ISNULL(dblOrigQty, 0)) AS NUMERIC(20,6)) ELSE NULL END END)) END
				, strBasisUOM
				, dblQuantity 						= CAST (SUM(dblQuantity) AS NUMERIC(20,6))
				, strQuantityUOM
				, intPriceItemUOMId
				, strPriceUOM
				, strStockUOM
				, dblAvailableQty 					= CAST (SUM(dblAvailableQty) AS NUMERIC(20,6))
				, dblQtyinCommodityStockUOM 		= CAST (SUM(dblQtyinCommodityStockUOM) AS NUMERIC(20,6))
				, strPrintOption
				, intContractStatusId				= Stat.intContractStatusId
			FROM (
				SELECT intContractBalanceId			=	intContractBalanceLogId
					, dtmTransactionDate			=	CASE WHEN CBL.strAction = 'Created Price' THEN CBL.dtmTransactionDate ELSE dbo.[fnCTConvertDateTime](CBL.dtmCreatedDate,'ToServerDate', 0) END--dtmTransactionDate
					, CBL.intContractHeaderId
					, strType						=	CASE WHEN CBL.intPricingTypeId = 1 THEN 'PriceFixation' ELSE 'Basis' END	
					, CBL.intContractDetailId
					, strCompanyName				=	@strCompanyName
					, blbHeaderLogo					=	@blbHeaderLogo
					--, strDate						=	LTRIM(DATEPART(mm,GETDATE())) + '-' + LTRIM(DATEPART(dd,GETDATE())) + '-' + RIGHT(LTRIM(DATEPART(yyyy,GETDATE())),2)			
					, strDate						=	CONVERT(VARCHAR(20), CASE WHEN @IntLocalTimeOffset IS NOT NULL THEN DATEADD(MINUTE, @IntLocalTimeOffset, CH.dtmCreated) ELSE CH.dtmCreated END, 101)
					, strContractType				=	CASE WHEN CBL.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sale' END
					, CBL.intCommodityId
					, strCommodityCode				=	CM.strCommodityCode
					, strCommodity					=	CM.strDescription + ' ' + UOM.strUnitMeasure
					, CBL.intItemId
					, strItemNo						=	IM.strItemNo
					, intCompanyLocationId			=	CBL.intLocationId
					, strLocationName				=	L.strLocationName
					, strCustomer					=	EY.strEntityName
					, strContract					=	CBL.strContractNumber + '-' + LTRIM(CBL.intContractSeq)
					, CBL.intPricingTypeId
					, strPricingType				=	CASE WHEN CBL.intPricingTypeId = 1 THEN 'P' ELSE 'B' END
					, strContractDate				=	LEFT(CONVERT(NVARCHAR,CH.dtmContractDate,101),5)
					, strShipMethod					=	FT.strFreightTerm
					, strShipmentPeriod				=	LTRIM(DATEPART(mm,CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmStartDate)) + ' - ' + LTRIM(DATEPART(mm,CD.dtmEndDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmEndDate))
					, CBL.intFutureMarketId
					, CBL.intFutureMonthId
					, strDeliveryMonth				=	LEFT(DATENAME(MONTH, CD.dtmEndDate), 3) + ' ' + RIGHT(DATENAME(YEAR, CD.dtmEndDate),2)
					, strFutureMonth				=	FH.strFutureMonth
					, strBasisUOM					=	BUOM.strUnitMeasure
					, dblQuantity					=	CBL.dblQty
					, strQuantityUOM				=	IUM.strUnitMeasure
					, CD.intPriceItemUOMId
					, strPriceUOM					=	PUOM.strUnitMeasure			
					, strStockUOM					=	dbo.fnCTGetCommodityUOM(C1.intUnitMeasureId)
					, dblAvailableQty				=	CBL.dblQty
					, dblQtyinCommodityStockUOM		=	dbo.fnCTConvertQtyToTargetCommodityUOM(CH.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId),C1.intUnitMeasureId, CBL.dblQty)
					, strPrintOption				= 	@strPrintOption
					, CBL.intContractTypeId
					, CBL.intEntityId
					, dblOrigQty = CBL.dblOrigQty
					, dblFutures					=	CASE WHEN CBL.intPricingTypeId IN (1, 3) AND CD.dblFutures IS NOT NULL THEN CD.dblFutures
															ELSE (CASE WHEN CBL.intPricingTypeId = 1 THEN PF.dblPriceWORollArb ELSE NULL END) END  
					, dblBasis						=	CASE WHEN CBL.intPricingTypeId = 3 THEN NULL ELSE CAST(isnull(CBL.dblBasis, 0) AS NUMERIC(20,6)) END
				FROM tblCTContractBalanceLog		CBL
				INNER JOIN tblICCommodity			CM			ON CM.intCommodityId = CBL.intCommodityId
				INNER JOIN tblICCommodityUnitMeasure	C1		ON C1.intCommodityId = CBL.intCommodityId AND C1.ysnStockUnit = 1
				INNER JOIN tblICUnitMeasure			UOM			ON UOM.intUnitMeasureId = C1.intUnitMeasureId
				INNER JOIN tblICItem				IM			ON IM.intItemId = CBL.intItemId
				INNER JOIN tblSMCompanyLocation		L			ON L.intCompanyLocationId = CBL.intLocationId
				INNER JOIN vyuCTEntity				EY			ON EY.intEntityId = CBL.intEntityId AND EY.strEntityType = (CASE WHEN CBL.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
				INNER JOIN tblCTContractHeader		CH			ON CH.intContractHeaderId = CBL.intContractHeaderId
				INNER JOIN tblCTContractDetail		CD			ON CD.intContractDetailId = CBL.intContractDetailId
				INNER JOIN tblICItemUOM				ItemUOM		ON ItemUOM.intItemUOMId = CD.intItemUOMId
				INNER JOIN tblICUnitMeasure			IUM			ON IUM.intUnitMeasureId = ItemUOM.intUnitMeasureId
				LEFT JOIN tblSMFreightTerms			FT			ON FT.intFreightTermId = CD.intFreightTermId
				LEFT JOIN tblRKFuturesMonth			FH			ON FH.intFutureMonthId = CD.intFutureMonthId
				LEFT JOIN tblICItemUOM				BASISUOM	ON BASISUOM.intItemUOMId = CBL.intBasisUOMId
				LEFT JOIN tblICUnitMeasure			BUOM		ON BUOM.intUnitMeasureId = BASISUOM.intUnitMeasureId
				LEFT JOIN tblICItemUOM				PriceUOM	ON PriceUOM.intItemUOMId = CD.intPriceItemUOMId
				LEFT JOIN tblICUnitMeasure			PUOM		ON PUOM.intUnitMeasureId = PriceUOM.intUnitMeasureId
				LEFT JOIN tblCTPriceFixation 		PF 			ON PF.intContractDetailId = CD.intContractDetailId	
				WHERE CBL.strTransactionType = 'Contract Balance'
			) cb
			INNER JOIN @tblStatus Stat ON cb.intContractDetailId = Stat.intContractDetailId
			WHERE intContractTypeId				= CASE WHEN ISNULL(@intContractTypeId , 0) > 0		THEN @intContractTypeId	 	ELSE intContractTypeId		END
				AND intEntityId			 		= CASE WHEN ISNULL(@intEntityId , 0) > 0				THEN @intEntityId		 	ELSE intEntityId			END
				AND intCommodityId				= CASE WHEN ISNULL(@IntCommodityId , 0) > 0			THEN @IntCommodityId	 	ELSE intCommodityId	 		END
				AND intCompanyLocationId 		= CASE WHEN ISNULL(@intCompanyLocationId , 0) > 0	THEN @intCompanyLocationId	ELSE intCompanyLocationId	END
				AND ISNULL(intFutureMarketId, 0)	= CASE WHEN ISNULL(@IntFutureMarketId , 0) > 0		THEN @IntFutureMarketId		ELSE ISNULL(intFutureMarketId, 0) END
				AND ISNULL(intFutureMonthId, 0)	= CASE WHEN ISNULL(@IntFutureMonthId , 0) > 0		THEN @IntFutureMonthId		ELSE ISNULL(intFutureMonthId, 0) END
				AND Stat.intContractStatusId NOT IN (2,3,5,6)
				AND dbo.fnRemoveTimeOnDate(dtmTransactionDate) <= @dtmEndDate
			GROUP BY intContractHeaderId
				,strType
				,Stat.intContractDetailId
				,strDate
				,strContractType
				,intCommodityId
				,strCommodityCode
				,strCommodity
				,intItemId
				,strItemNo
				,intCompanyLocationId
				,strLocationName
				,strCustomer
				,strContract
				,intPricingTypeId
				,strPricingType
				,strContractDate
				,strShipMethod
				,strShipmentPeriod
				,intFutureMarketId
				,intFutureMonthId
				,strDeliveryMonth
				,strFutureMonth
				,strBasisUOM
				,strQuantityUOM
				,intPriceItemUOMId
				,strPriceUOM
				,strStockUOM
				,strPrintOption
				,Stat.intContractStatusId
			HAVING SUM(dblQuantity) > 0
		) tbl
	--END
END