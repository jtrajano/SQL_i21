﻿CREATE VIEW vyuLGInventoryView
AS 
SELECT TOP 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY strStatus)) as intKeyColumn,*  
FROM (
	SELECT
		'In-transit' AS strStatus
		,strContractNumber = Shipment.strContractNumber
		,intContractSeq = Shipment.intContractSeq
		,intContractDetailId = Shipment.intContractDetailId
		,dblStockQty = Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0)
		,strStockUOM = Shipment.strItemUOM
		,dblNetWeight = CASE WHEN IsNull(Shipment.dblContainerContractReceivedQty, 0) > 0
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
							END
		,strWeightUOM = Shipment.strWeightUOM
		,intVendorEntityId = Shipment.intVendorEntityId
		,strVendor = Shipment.strVendor
		,intCustomerEntityId = Shipment.intCustomerEntityId
		,strCustomer = Shipment.strCustomer
		,strCommodity = Shipment.strCommodity
		,strItemNo = Shipment.strItemNo
		,strItemDescription = Shipment.strItemDescription
		,strItemType = Shipment.strType
		,strItemSpecification = Shipment.strItemSpecification
		,strOrigin = Shipment.strOrigin
		,strVessel = Shipment.strMVessel
		,dtmETAPOL = Shipment.dtmETAPOL
		,dtmETAPOD = Shipment.dtmETAPOD
		,strTrackingNumber = '' COLLATE Latin1_General_CI_AS
		,strBLNumber = Shipment.strBLNumber
		,strContainerNumber = Shipment.strContainerNumber
		,strMarks = Shipment.strMarks
		,strLotNumber = '' COLLATE Latin1_General_CI_AS
		,strWarehouse = Shipment.strSubLocationName
		,strCondition = '' COLLATE Latin1_General_CI_AS
		,dtmPostedDate = Shipment.dtmPostedDate
		,dblQtyInStockUOM = (Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0)) * dbo.fnICConvertUOMtoStockUnit (Shipment.intItemId, Shipment.intItemUOMId, 1)
		,intItemId = Shipment.intItemId
		,intWeightItemUOMId = (SELECT U.intItemUOMId FROM tblICItemUOM U WHERE U.intItemId = Shipment.intItemId AND U.intUnitMeasureId=Shipment.intWeightUOMId)
		,strWarehouseRefNo = '' COLLATE Latin1_General_CI_AS
		,dblTotalCost = CAST(ISNULL(((dbo.fnCTConvertQtyToTargetItemUOM(Shipment.intWeightItemUOMId, 
												CD.intPriceItemUOMId, 
												CASE 
												WHEN ISNULL(Shipment.dblContainerContractReceivedQty, 0) > 0
													THEN ((ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0)) / ISNULL(Shipment.dblContainerContractQty, 1)) * (ISNULL(Shipment.dblContainerContractQty, 0) - ISNULL(Shipment.dblContainerContractReceivedQty, 0))
												ELSE ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0)
												END)
						) * Shipment.dblCashPrice)/ (CASE WHEN CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) = 0 THEN 1 ELSE 100 END),0) AS NUMERIC(18,6))
		,dblFutures = Shipment.dblFutures
		,dblCashPrice = Shipment.dblCashPrice
		,dblBasis = Shipment.dblBasis
		,strPricingType = Shipment.strPricingType
		,strExternalShipmentNumber = L.strExternalShipmentNumber
		,strERPPONumber = CD.strERPPONumber
		,strPosition = Shipment.strPosition
		,intLoadId = Shipment.intLoadId
		,intCompanyLocationId = CD.intCompanyLocationId
		,intBookId = Shipment.intBookId
		,strBook = Shipment.strBook
		,intSubBookId = Shipment.intSubBookId
		,strSubBook = Shipment.strSubBook
		,intCropYear = Shipment.intCropYear
		,strCropYear = Shipment.strCropYear
		,strProducer = Shipment.strProducer
		,strCertification = Shipment.strCertification
		,strCertificationId = Shipment.strCertificationId
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
		'Spot' AS strStatus
		,strContractNumber = Spot.strContractNumber
		,intContractSeq = Spot.intContractSeq
		,intContractDetailId = Spot.intContractDetailId
		,dblStockQty = Spot.dblQty
		,strStockUOM = Spot.strItemUOM
		,dblNetWeightFull = Spot.dblNetWeightFull
		,strWeightUOM = Spot.strWeightUOM
		,intEntityVendorId = Spot.intEntityVendorId
		,strVendor = Spot.strVendor
		,intCustomerEntityId = Spot.intCustomerEntityId
		,strCustomer = Spot.strCustomer
		,strCommodity = Spot.strCommodity
		,strItemNo = Spot.strItemNo
		,strItemDescription = Spot.strItemDescription
		,strItemType = Spot.strItemType
		,strItemSpecification = Spot.strItemSpecification
		,strOrigin = Spot.strOrigin
		,strVessel = Spot.strVessel
		,dtmETAPOL = Spot.dtmETAPOL
		,dtmETAPOD = Spot.dtmETAPOD
		,strTrackingNumber = Spot.strLoadNumber
		,strBLNumber = Spot.strBLNumber
		,strContainerNumber = Spot.strContainerNumber
		,strMarks = Spot.strMarkings
		,strLotNumber = Spot.strLotNumber
		,strWarehouse = Spot.strSubLocationName
		,strCondition = Spot.strCondition
		,dtmPostedDate = Spot.dtmPostedDate
		,dblQtyInStockUOM = Spot.dblQty * dbo.fnICConvertUOMtoStockUnit (Spot.intItemId, Spot.intItemUOMId, 1)
		,intItemId = Spot.intItemId
		,intWeightItemUOMId = Spot.intItemWeightUOMId
		,strWarehouseRefNo = Spot.strWarehouseRefNo
		,dblTotalCost = CAST(ISNULL(((dbo.fnCTConvertQtyToTargetItemUOM(Spot.intWeightItemUOMId, 
												CD.intPriceItemUOMId, Spot.dblNetWeight )
						) * Spot.dblCashPrice)/ (CASE WHEN CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) = 0 THEN 1 ELSE 100 END),0) AS NUMERIC(18,6))
		,dblFutures = Spot.dblFutures
		,dblCashPrice = Spot.dblCashPrice
		,dblBasis = Spot.dblBasis
		,strPricingType = Spot.strPricingType
		,strExternalShipmentNumber = L.strExternalShipmentNumber
		,strERPPONumber = CD.strERPPONumber
		,strPosition = Spot.strPosition
		,intLoadId = L.intLoadId
		,intCompanyLocationId = CD.intCompanyLocationId
		,intBookId = Spot.intBookId
		,strBook = Spot.strBook
		,intSubBookId = Spot.intSubBookId
		,strSubBook = Spot.strSubBook
		,intCropYear = Spot.intCropYear
		,strCropYear = Spot.strCropYear
		,strProducer = Spot.strProducer
		,strCertification = Spot.strCertification
		,strCertificationId = Spot.strCertificationId
	FROM vyuLGPickOpenInventoryLots Spot
	LEFT JOIN tblLGLoad L ON Spot.strLoadNumber = L.strLoadNumber
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = Spot.intContractDetailId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId			
	LEFT JOIN tblSMCurrency	CY ON CY.intCurrencyID = CU.intMainCurrencyId
	WHERE Spot.dblQty > 0.0
	) t1