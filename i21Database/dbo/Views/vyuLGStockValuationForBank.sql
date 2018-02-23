CREATE VIEW vyuLGStockValuationForBank
AS
SELECT DISTINCT CH.intContractHeaderId
	,CH.strContractNumber + '/' + LTRIM(CD.intContractSeq) AS strContractNoWithSeq
	,CH.strContractNumber
	,CD.intContractSeq
	,CL.strLocationName
	,(
		SELECT strCompanyName
		FROM tblSMCompanySetup
		) AS strCompanyName
	,CASE L.intShipmentStatus
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Dispatched'
		WHEN 3
			THEN 'Inbound transit'
		WHEN 4
			THEN 'Received'
		WHEN 5
			THEN 'Outbound transit'
		WHEN 6
			THEN 'Delivered'
		WHEN 7
			THEN 'Instruction created'
		WHEN 8
			THEN 'Partial Shipment Created'
		WHEN 9
			THEN 'Full Shipment Created'
		WHEN 10
			THEN 'Cancelled'
		WHEN 11
			THEN 'Invoiced'
		ELSE ''
		END COLLATE Latin1_General_CI_AS AS strShipmentStatus
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,ProductType.strDescription AS strProductType
	,ProductLine.strDescription AS strProductLine
	,CASE 
		WHEN ProductLine.strDescription LIKE '%Green Organic%'
			THEN 'Y'
		ELSE 'N'
		END AS ysnOrganic
	,STUFF((
			SELECT DISTINCT ', ' + LTRIM(BD.strCertificationName)
			FROM (
				SELECT strCertificationName
				FROM tblICCertification IC
				JOIN tblCTContractCertification CC ON IC.intCertificationId = CC.intCertificationId
				WHERE CC.intContractDetailId = CD.intContractDetailId
				) BD
			FOR XML PATH('')
			), 1, 2, '') strCertificationName
	,CASE 
		WHEN C.ysnSubCurrency = 1
			THEN CU.strCurrency
		ELSE C.strCurrency
		END AS strCurrency
	,CD.dblCashPrice
	--,C.strCurrency
	,U.strUnitMeasure
	,U.intUnitMeasureId
	,CD.intPriceItemUOMId
	,ROUND(CASE 
			WHEN C.ysnSubCurrency = 1
				THEN dbo.fnCTConvertQtyToTargetItemUOM((
							SELECT intItemUOMId
							FROM tblICItemUOM IU
							JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
							WHERE IU.intItemId = CD.intItemId
								AND UM.strUnitMeasure IN (
									'Metric Ton'
									,'MT'
									)
							), CD.intPriceItemUOMId, 1) * CD.dblCashPrice / 100
			ELSE dbo.fnCTConvertQtyToTargetItemUOM((
						SELECT intItemUOMId
						FROM tblICItemUOM IU
						JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
						WHERE IU.intItemId = CD.intItemId
							AND UM.strUnitMeasure IN (
								'Metric Ton'
								,'MT'
								)
						), CD.intPriceItemUOMId, 1) * CD.dblCashPrice
			END, 4) AS dblPriceInMT
	,SL.strName AS strStorageLocation
	,CD.dblQuantity AS dblPurchaseQty
	,UM.strUnitMeasure AS strPurchaseQtyUOM
	,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, (
			SELECT intItemUOMId
			FROM tblICItemUOM IU
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
			WHERE IU.intItemId = CD.intItemId
				AND UM.strUnitMeasure IN (
					'Metric Ton'
					,'MT'
					)
			), 1) * (CD.dblQuantity - ISNULL(CD.dblAllocatedQty, 0)) AS dblUnAllocatedQtyInMT
	,(
		dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, (
				SELECT intItemUOMId
				FROM tblICItemUOM IU
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				WHERE IU.intItemId = CD.intItemId
					AND UM.strUnitMeasure IN (
						'Metric Ton'
						,'MT'
						)
				), 1) * (CD.dblQuantity - ISNULL(CD.dblAllocatedQty, 0))
		) * ROUND(CASE 
			WHEN C.ysnSubCurrency = 1
				THEN dbo.fnCTConvertQtyToTargetItemUOM((
							SELECT intItemUOMId
							FROM tblICItemUOM IU
							JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
							WHERE IU.intItemId = CD.intItemId
								AND UM.strUnitMeasure IN (
									'Metric Ton'
									,'MT'
									)
							), CD.intPriceItemUOMId, 1) * CD.dblCashPrice / 100
			ELSE dbo.fnCTConvertQtyToTargetItemUOM((
						SELECT intItemUOMId
						FROM tblICItemUOM IU
						JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
						WHERE IU.intItemId = CD.intItemId
							AND UM.strUnitMeasure IN (
								'Metric Ton'
								,'MT'
								)
						), CD.intPriceItemUOMId, 1) * CD.dblCashPrice
			END, 4) AS dblUnsoldCommodityValue
	,(
		dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, (
				SELECT intItemUOMId
				FROM tblICItemUOM IU
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				WHERE IU.intItemId = CD.intItemId
					AND UM.strUnitMeasure IN (
						'Metric Ton'
						,'MT'
						)
				), 1) * (CD.dblQuantity - ISNULL(CD.dblAllocatedQty, 0))
		) * dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId, CD.intFutureMonthId, GeTdate()) AS dblUnsoldCommodityMarketValue
	,LD.dblQuantity AS dblLGLoadQty
	,(
		SELECT TOP 1 strLocationName
		FROM tblSMCompanyLocationSubLocation CLSL
		WHERE CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		) AS strWarehouse
	,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, (
			SELECT intItemUOMId
			FROM tblICItemUOM IU
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
			WHERE IU.intItemId = CD.intItemId
				AND UM.strUnitMeasure IN (
					'Metric Ton'
					,'MT'
					)
			), 1) * (CD.dblQuantity - ISNULL(CD.dblAllocatedQty, 0)) * ROUND(CASE 
			WHEN C.ysnSubCurrency = 1
				THEN dbo.fnCTConvertQtyToTargetItemUOM((
							SELECT intItemUOMId
							FROM tblICItemUOM IU
							JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
							WHERE IU.intItemId = CD.intItemId
								AND UM.strUnitMeasure IN (
									'Metric Ton'
									,'MT'
									)
							), CD.intPriceItemUOMId, 1) * CD.dblCashPrice / 100
			ELSE dbo.fnCTConvertQtyToTargetItemUOM((
						SELECT intItemUOMId
						FROM tblICItemUOM IU
						JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
						WHERE IU.intItemId = CD.intItemId
							AND UM.strUnitMeasure IN (
								'Metric Ton'
								,'MT'
								)
						), CD.intPriceItemUOMId, 1) * CD.dblCashPrice
			END, 4) * dblRate AS dblUnsoldCommodityInUSD
	,dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId, CD.intFutureMonthId, GETDATE()) AS dblMarketClosingPrice
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
	AND CH.intContractTypeId = 1
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblSMCurrency C ON C.intCurrencyID = CD.intCurrencyId
JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intPriceItemUOMId
JOIN tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICItemUOM IUM ON IUM.intItemUOMId = CD.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUM.intUnitMeasureId
LEFT JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	AND L.intShipmentType = 1
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = C.intMainCurrencyId
LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = I.intProductTypeId
LEFT JOIN tblICCommodityProductLine ProductLine ON ProductLine.intCommodityProductLineId = I.intProductLineId
LEFT JOIN tblRKFutureMarket FMA ON FMA.intFutureMarketId = CD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth FMO ON FMO.intFutureMonthId = CD.intFutureMonthId
LEFT JOIN tblARInvoiceDetail ID ON ID.intLoadDetailId = LD.intLoadDetailId