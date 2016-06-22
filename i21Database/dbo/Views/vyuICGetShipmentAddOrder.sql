CREATE VIEW [dbo].[vyuICGetShipmentAddOrder]
	AS 

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityCustomerId, intLineNo) AS INT)
, * FROM (
	SELECT 	
		strOrderType = 'Sales Order'
		, strSourceType = 'None'
		, intLocationId = SODetail.intCompanyLocationId
		, strShipFromLocation = SODetail.strLocationName
		, SODetail.intEntityCustomerId
		, SODetail.strCustomerNumber
		, SODetail.strCustomerName
		, intLineNo = intSalesOrderDetailId
		, intOrderId = SODetail.intSalesOrderId
		, strOrderNumber = SODetail.strSalesOrderNumber
		, intSourceId = NULL
		, strSourceNumber = NULL
		, SODetail.intItemId
		, strItemNo
		, strItemDescription
		, strLotTracking
		, SODetail.intCommodityId
		,DefaultFromItemLocation.intSubLocationId
		,SubLocation.strSubLocationName
		,DefaultFromItemLocation.intStorageLocationId
		,strStorageLocationName = StorageLocation.strName
		, intOrderUOMId = intItemUOMId
		, strOrderUOM = strUnitMeasure
		, dblOrderUOMConvFactor = dblUOMConversion
		, intItemUOMId
		, strItemUOM = strUnitMeasure
		, dblItemUOMConv = dblUOMConversion
		, intWeightUOMId = intItemUOMId
		, strWeightUOM = strUnitMeasure
		, dblWeightItemUOMConv = dblUOMConversion
		, dblQtyOrdered = ISNULL(dblQtyOrdered, 0)
		, dblQtyAllocated = ISNULL(dblQtyAllocated, 0)
		, dblQtyShipped = ISNULL(dblQtyShipped, 0)
		, dblUnitPrice = ISNULL(dblPrice, 0)
		, dblDiscount = ISNULL(SODetail.dblDiscount, 0)
		, dblTotal = ISNULL(dblTotal, 0)
		, dblQtyToShip = ISNULL(dblQtyOrdered, 0)
		, dblPrice = ISNULL(dblPrice, 0)
		, dblLineTotal = ISNULL(dblQtyShipped, 0) * ISNULL(dblPrice, 0)
		, intGradeId = NULL
		, strGrade = NULL
	FROM vyuSOSalesOrderDetail SODetail INNER JOIN vyuSOSalesOrderSearch SO
			ON SODetail.intSalesOrderId = SO.intSalesOrderId
		LEFT JOIN dbo.tblICItemLocation DefaultFromItemLocation
			ON DefaultFromItemLocation.intItemId = SODetail.intItemId
			AND DefaultFromItemLocation.intLocationId = SODetail.intCompanyLocationId
		LEFT JOIN dbo.tblSMCompanyLocationSubLocation SubLocation
			ON SubLocation.intCompanyLocationSubLocationId = DefaultFromItemLocation.intSubLocationId
		LEFT JOIN dbo.tblICStorageLocation StorageLocation
			ON StorageLocation.intStorageLocationId = DefaultFromItemLocation.intStorageLocationId
	--WHERE ysnProcessed = 0
	WHERE	ISNULL(SODetail.dblQtyShipped, 0) < ISNULL(SODetail.dblQtyOrdered, 0) 
			AND ISNULL(SO.strOrderStatus, '') IN ('Open', 'Partial', 'Pending')

	UNION ALL 

	SELECT 	
		strOrderType = 'Sales Contract'
		, strSourceType = 'None'
		, intLocationId = intCompanyLocationId
		, strShipFromLocation = strLocationName
		, intEntityCustomerId = intEntityId
		, strCustomerNumber = strEntityNumber
		, strCustomerName = strEntityName
		, intLineNo = intContractDetailId
		, intOrderId = intContractHeaderId
		, strOrderNumber = strContractNumber
		, intSourceId = NULL
		, strSourceNumber = NULL
		, intItemId
		, strItemNo
		, strItemDescription
		, strLotTracking
		, intCommodityId
		, intSubLocationId = intCompanyLocationSubLocationId
		, strSubLocationName
		, intStorageLocationId
		, strStorageLocationName = strStorageLocationName
		, intOrderUOMId = intItemUOMId
		, strOrderUOM = strItemUOM
		, dblOrderUOMConvFactor = dblItemUOMCF
		, intItemUOMId
		, strItemUOM = strItemUOM
		, dblItemUOMConv = dblItemUOMCF
		, intWeightUOMId = intItemUOMId
		, strWeightUOM = strItemUOM
		, dblWeightItemUOMConv = dblItemUOMCF
		, dblQtyOrdered = CASE WHEN ysnLoad = 1 THEN intNoOfLoad ELSE dblDetailQuantity END
		, dblQtyAllocated = ISNULL(dblAllocatedQty, 0)
		, dblQtyShipped = 0
		, dblUnitPrice = ISNULL(dblSeqPrice, 0)
		, dblDiscount = 0
		, dblTotal = 0
		, dblQtyToShip = ISNULL(dblDetailQuantity, 0)
		, dblPrice = ISNULL(dblSeqPrice, 0)
		, dblLineTotal = ISNULL(dblDetailQuantity, 0) * ISNULL(dblSeqPrice, 0)
		, intGradeId = NULL
		, strGrade = NULL
	FROM vyuCTContractDetailView ContractView
	WHERE ysnAllowedToShow = 1
		AND strContractType = 'Sale'
		
	UNION ALL 

	SELECT DISTINCT
		strOrderType = 'Sales Contract'
		, strSourceType = 'Pick Lot'
		, intLocationId = PickLot.intCompanyLocationId
		, strShipFromLocation = PickLot.strLocationName
		, intEntityCustomerId = PickLot.intCustomerEntityId
		, strCustomerNumber = PickLotDetail.strCustomerNo
		, strCustomerName = PickLotDetail.strCustomer
		, intLineNo = PickLotDetail.intSContractDetailId --PickLotDetail.intPickLotDetailId
		, intOrderId = PickLotDetail.intSContractHeaderId
		, strOrderNumber = PickLotDetail.strSContractNumber
		, intSourceId = PickLotDetail.intPickLotHeaderId
		, strSourceNumber = PickLotDetail.intReferenceNumber
		, intItemId
		, strItemNo
		, strItemDescription
		, strLotTracking
		, PickLotDetail.intCommodityId
		, PickLotDetail.intSubLocationId
		, PickLotDetail.strSubLocationName
		, PickLotDetail.intStorageLocationId
		, strStorageLocationName = PickLotDetail.strStorageLocation
		, intOrderUOMId = PickLotDetail.intItemUOMId
		, strOrderUOM = PickLotDetail.strSaleUnitMeasure
		, dblOrderUOMConvFactor = PickLotDetail.dblItemUOMConv
		, PickLotDetail.intItemUOMId
		, strItemUOM = PickLotDetail.strSaleUnitMeasure
		, dblItemUOMConv = PickLotDetail.dblItemUOMConv
		, intWeightUOMId = intWeightItemUOMId
		, strWeightUOM = PickLotDetail.strWeightUnitMeasure
		, dblWeightItemUOMConv = PickLotDetail.dblWeightItemUOMConv
		, dblQtyOrdered = PickLotDetail.dblDetailQuantity
		, dblQtyAllocated = 0
		, dblQtyShipped = 0
		, dblUnitPrice = ISNULL(dblCashPrice, 0)
		, dblDiscount = 0
		, dblTotal = 0
		, dblQtyToShip = ISNULL(dblDetailQuantity, 0)
		, dblPrice = ISNULL(dblCashPrice, 0)
		, dblLineTotal = ISNULL(dblDetailQuantity, 0) * ISNULL(dblCashPrice, 0)
		, intGradeId = NULL
		, strGrade = NULL
	FROM vyuLGDeliveryOpenPickLots PickLot
	LEFT JOIN vyuLGDeliveryOpenPickLotDetails PickLotDetail ON PickLotDetail.intPickLotHeaderId = PickLot.intPickLotHeaderId
	WHERE PickLot.ysnShipped = 0)
tblAddOrders