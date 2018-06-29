CREATE VIEW vyuLGInventoryView
	AS 
SELECT Top 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY strStatus)) as intKeyColumn,*  FROM (
SELECT
	'In-transit' as strStatus
	,Shipment.strContractNumber
	,Shipment.intContractSeq
	,Shipment.intContractDetailId
	,Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0) as dblStockQty
	,Shipment.strItemUOM as strStockUOM
	,CASE 
		WHEN IsNull(Shipment.dblContainerContractReceivedQty, 0) > 0
			THEN CASE 
					WHEN ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0) = 0
						THEN Shipment.dblBLNetWt
					ELSE ((ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0)) / ISNULL(Shipment.dblContainerContractQty, 1)) * (ISNULL(Shipment.dblContainerContractQty, 0) - ISNULL(Shipment.dblContainerContractReceivedQty, 0))
					END
		ELSE CASE 
				WHEN ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0) = 0
					THEN Shipment.dblBLNetWt
				ELSE ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0)
				END
		END AS dblNetWeight
	,Shipment.strWeightUOM
	,Shipment.intVendorEntityId
	,Shipment.strVendor
	,Shipment.strCommodity
	,Shipment.strItemNo
	,Shipment.strItemDescription
	,'' strTrackingNumber
	,Shipment.strBLNumber
	,Shipment.strContainerNumber
	,Shipment.strMarks
	,'' as strLotNumber
	,Shipment.strSubLocationName as strWarehouse
	,'' as strCondition
	,Shipment.dtmPostedDate
	,dblQtyInStockUOM = (Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0)) * dbo.fnICConvertUOMtoStockUnit (Shipment.intItemId, Shipment.intItemUOMId, 1)
	,Shipment.intItemId
	,intWeightItemUOMId = (SELECT U.intItemUOMId FROM tblICItemUOM U WHERE U.intItemId = Shipment.intItemId AND U.intUnitMeasureId=Shipment.intWeightUOMId)
	,strWarehouseRefNo = ''
	,((dbo.fnCTConvertQtyToTargetItemUOM(Shipment.intWeightItemUOMId, 
											CD.intPriceItemUOMId, 
											CASE 
											WHEN ISNULL(Shipment.dblContainerContractReceivedQty, 0) > 0
												THEN ((ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0)) / ISNULL(Shipment.dblContainerContractQty, 1)) * (ISNULL(Shipment.dblContainerContractQty, 0) - ISNULL(Shipment.dblContainerContractReceivedQty, 0))
											ELSE ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0)
											END)
		) * Shipment.dblCashPrice)/ (CASE WHEN CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) = 0 THEN 1 ELSE 100 END) AS dblTotalCost
	,Shipment.dblFutures
	,Shipment.dblCashPrice
	,Shipment.dblBasis
	,L.strExternalShipmentNumber
	,CD.strERPPONumber
	,Shipment.strPosition
	,Shipment.intLoadId
	,CD.intCompanyLocationId
	,Shipment.intBookId
	,Shipment.strBook
	,Shipment.intSubBookId
	,Shipment.strSubBook
	,Shipment.intCropYear
	,Shipment.strCropYear
	,Shipment.strProducer
	,Shipment.strCertification
	,Shipment.strCertificationId
FROM vyuLGInboundShipmentView Shipment
LEFT JOIN tblLGLoad L ON Shipment.intLoadId = L.intLoadId
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = Shipment.intContractDetailId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId			
LEFT JOIN tblSMCurrency	CY ON CY.intCurrencyID = CU.intMainCurrencyId
LEFT JOIN tblARInvoice INV ON ISNULL(Shipment.intLoadId,0) = ISNULL(INV.intLoadId,0) 
WHERE (Shipment.dblContainerContractQty - IsNull(Shipment.dblContainerContractReceivedQty, 0.0)) > 0.0 
   AND Shipment.ysnInventorized = 1
   AND INV.intLoadId IS NULL

UNION ALL

SELECT 
	'Spot'
	,Spot.strContractNumber
	,Spot.intContractSeq
	,Spot.intContractDetailId
	,Spot.dblQty as dblStockQty
	,Spot.strItemUOM as strStockUOM
	,Spot.dblNetWeightFull
	,Spot.strWeightUOM
	,Spot.intEntityVendorId
	,Spot.strVendor
	,Spot.strCommodity
	,Spot.strItemNo
	,Spot.strItemDescription
	,Spot.strLoadNumber AS strTrackingNumber
	,Spot.strBLNumber
	,Spot.strContainerNumber
	,Spot.strMarkings as strMarks
	,Spot.strLotNumber
	,Spot.strSubLocationName as strWarehouse
	,Spot.strCondition
	,Spot.dtmPostedDate
	,dblQtyInStockUOM = Spot.dblQty * dbo.fnICConvertUOMtoStockUnit (Spot.intItemId, Spot.intItemUOMId, 1)
	,Spot.intItemId
	,intWeightItemUOMId = Spot.intItemWeightUOMId
	,Spot.strWarehouseRefNo
	,((dbo.fnCTConvertQtyToTargetItemUOM(Spot.intWeightItemUOMId, 
											CD.intPriceItemUOMId, Spot.dblNetWeight )
		) * Spot.dblCashPrice)/ (CASE WHEN CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) = 0 THEN 1 ELSE 100 END)
	,Spot.dblFutures
	,Spot.dblCashPrice
	,Spot.dblBasis
	,L.strExternalShipmentNumber
	,CD.strERPPONumber
	,Spot.strPosition
	,L.intLoadId
	,CD.intCompanyLocationId
	,Spot.intBookId
	,Spot.strBook
	,Spot.intSubBookId
	,Spot.strSubBook
	,Spot.intCropYear
	,Spot.strCropYear
	,Spot.strProducer
	,Spot.strCertification
	,Spot.strCertificationId
FROM vyuLGPickOpenInventoryLots Spot
LEFT JOIN tblLGLoad L ON Spot.strLoadNumber = L.strLoadNumber
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = Spot.intContractDetailId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId			
LEFT JOIN tblSMCurrency	CY ON CY.intCurrencyID = CU.intMainCurrencyId
WHERE Spot.dblQty > 0.0
) t1