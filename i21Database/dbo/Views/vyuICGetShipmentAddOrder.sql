CREATE VIEW [dbo].[vyuICGetShipmentAddOrder]
	AS 

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityCustomerId, intLineNo) AS INT)
, * FROM (
	SELECT 	
		strOrderType = 'Sales Order'
		, strSourceType = 'None'
		, intLocationId = intCompanyLocationId
		, strShipFromLocation = SODetail.strLocationName
		, intEntityCustomerId
		, strCustomerNumber
		, strCustomerName
		, intLineNo = intSalesOrderDetailId
		, intOrderId = intSalesOrderId
		, strOrderNumber = SODetail.strSalesOrderNumber
		, intSourceId = NULL
		, strSourceNumber = NULL
		, intItemId
		, strItemNo
		, strItemDescription
		, strLotTracking
		, intCommodityId
		, intSubLocationId
		, strSubLocationName
		, intStorageLocationId
		, strStorageLocationName = SODetail.strStorageLocation
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
	FROM vyuSOSalesOrderDetail SODetail
	WHERE ysnProcessed = 0

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
		, dblUnitPrice = ISNULL(dblCashPrice, 0)
		, dblDiscount = 0
		, dblTotal = 0
		, dblQtyToShip = ISNULL(dblDetailQuantity, 0)
		, dblPrice = ISNULL(dblCashPrice, 0)
		, dblLineTotal = ISNULL(dblDetailQuantity, 0) * ISNULL(dblCashPrice, 0)
		, intGradeId = NULL
		, strGrade = NULL
	FROM vyuCTContractDetailView ContractView
	WHERE ysnAllowedToShow = 1
		AND strContractType = 'Sale')
tblAddOrders