CREATE VIEW vyuLGOverallPosition
AS
SELECT *
FROM (
	SELECT CH.intContractHeaderId
		,CASE 
			WHEN CH.intContractTypeId = 1
				THEN 'PO'
			ELSE 'SO'
			END AS Quant_Type
		,CH.strContractNumber AS Partijnr
		,CD.intContractSeq AS Seq
		,CL.strLocationName AS CompanyLocation
		,dbo.fnLGGetShipmentStatus(CD.intContractDetailId) Shipment_Status
		,I.strDescription AS Soort_Koffie
		,ProductType.strDescription AS Type_of_coffee
		,CASE 
			WHEN ISNULL((
						SELECT C.strCertificationName
						FROM tblCTContractCertification CC
						LEFT JOIN tblICCertification C ON C.intCertificationId = CC.intCertificationId
						WHERE CC.intContractDetailId = CD.intContractDetailId
							AND C.strCertificationName IN (
								'Fairtrade'
								,'Fair Trade'
								)
						), '') = ''
				THEN 'Regular Coffee'
			ELSE 'Fair Trade'
			END AS MH
		,UPPER(LEFT(DATENAME(MONTH, CD.dtmEndDate), 3)) + DATENAME(YEAR, CD.dtmEndDate) AS Position_Month
		,(SELECT TOP 1 strSubLocationName FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = IRI.intSubLocationId) AS Warehouse 		
		,UM.strUnitMeasure AS Packing_Unit
		,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, (
				SELECT TOP 1 intItemUOMId
				FROM tblICItemUOM IU
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				WHERE IU.intItemId = CD.intItemId
					AND UM.strUnitMeasure IN (
						'Metric Ton'
						,'MT'
						,'matricton'
						)
				), 1) * CASE 
			WHEN CH.intContractTypeId = 1
				THEN CD.dblQuantity
			ELSE 0
			END AS Total_PO_Qty_In_MT
		,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, (
				SELECT intItemUOMId
				FROM tblICItemUOM IU
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				WHERE IU.intItemId = CD.intItemId
					AND UM.strUnitMeasure IN (
						'Metric Ton'
						,'MT'
						,'matricton'
						)
				), 1) * ISNULL(CD.dblAllocatedQty, 0) AS Total_Sold_Qty_In_MT
		,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, (
				SELECT TOP 1 intItemUOMId
				FROM tblICItemUOM IU
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				WHERE IU.intItemId = CD.intItemId
					AND UM.strUnitMeasure IN (
						'Metric Ton'
						,'MT'
						,'matricton'
						)
				), 1) * (CD.dblQuantity - ISNULL(CD.dblInvoicedQty, 0)) AS Sold_And_To__Be_Invoiced
		,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, (
				SELECT intItemUOMId
				FROM tblICItemUOM IU
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				WHERE IU.intItemId = CD.intItemId
					AND UM.strUnitMeasure IN (
						'Metric Ton'
						,'MT'
						,'matricton'
						)
				), 1) * (CD.dblQuantity - ISNULL(CD.dblAllocatedQty, 0)) * (
			CASE 
				WHEN CH.intContractTypeId = 2
					THEN - 1
				ELSE 1
				END
			) AS Unallocated_In_MT
		,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, (
				SELECT TOP 1 intItemUOMId
				FROM tblICItemUOM IU
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
				WHERE IU.intItemId = CD.intItemId
					AND UM.strUnitMeasure IN (
						'Metric Ton'
						,'MT'
						,'matricton'
						)
				), 1) * SUM(LOT.dblQty) Physical_Stock_MT
		,SUM(LOT.dblQty) Physical_Stock_With_Packing_Type
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		AND L.intPurchaseSale IN (
			1
			,2
			)
	RIGHT JOIN tblCTContractDetail CD ON CD.intContractDetailId = (
			CASE 
				WHEN L.intPurchaseSale = 1
					THEN LD.intPContractDetailId
				WHEN L.intPurchaseSale = 2
					THEN LD.intSContractDetailId
				END
			)
	JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
	JOIN tblSMCompanyLocation CL ON CD.intCompanyLocationId = CL.intCompanyLocationId
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = I.intProductTypeId
	LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intLineNo = CD.intContractDetailId
	LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
	LEFT JOIN tblICLot LOT ON LOT.intLotId = IRIL.intLotId
	WHERE CH.intContractTypeId = 1
		OR (
			CH.intContractTypeId = 2
			AND (CD.dblQuantity <> ISNULL(CD.dblAllocatedQty, 0))
			)
	GROUP BY CH.intContractTypeId
		,CH.intContractHeaderId
		,CH.strContractNumber
		,CD.intContractSeq
		,CL.strLocationName
		,I.strDescription
		,ProductType.strDescription
		,CD.intContractDetailId
		,CD.dtmEndDate
		,UM.strUnitMeasure
		,CD.intItemId
		,CD.intItemUOMId
		,CD.dblQuantity
		,CD.dblAllocatedQty
		,CD.dblInvoicedQty
		,IRI.intSubLocationId
	) tbl