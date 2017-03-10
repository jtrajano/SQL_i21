CREATE VIEW [dbo].[vyuICGetShipmentAddSalesContractPickLot]
AS
-- intKey -intLocationId, intEntityCustomerId, intLineNo
SELECT DISTINCT intKey = CAST(ROW_NUMBER() OVER(ORDER BY PickLot.intCompanyLocationId, PickLot.intCustomerEntityId, PickLotDetail.intSContractDetailId) AS INT)
	, strOrderType = 'Sales Contract'
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
	, strSourceNumber = PickLotDetail.[strPickLotNumber]
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
	, CAST(0 AS NUMERIC(18, 6)) dblQtyAllocated
	, CAST(0 AS NUMERIC(18, 6)) dblQtyShipped
	, dblUnitPrice = ISNULL(dblCashPrice, 0)
	, CAST(0 AS NUMERIC(18, 6)) dblDiscount
	, CAST(0 AS NUMERIC(18, 6)) dblTotal
	, dblQtyToShip = ISNULL(dblAvailableQty, 0)
	, dblPrice = ISNULL(dblCashPrice, 0)
	, dblLineTotal = ISNULL(dblDetailQuantity, 0) * ISNULL(dblCashPrice, 0)
	, intGradeId = NULL
	, strGrade = NULL
	, strDestinationGrades = NULL
	, intDestinationGradeId = NULL
	, strDestinationWeights = NULL
	, intDestinationWeightId = NULL
	/* BEGIN The below multi-currency fields are dummy fields. Use it until LG adjusted to multi-currency. */
	, intCurrencyId = CAST(NULL AS INT) 
	, intForexRateTypeId = CAST(NULL AS INT)
	, strForexRateType = CAST(NULL AS NVARCHAR(50))
	, dblForexRate = CAST(NULL AS NUMERIC(18, 6)) 
	/* END The above multi-currency fields are dummy fields. Use it until LG adjusted to multi-currency. */
FROM vyuLGDeliveryOpenPickLots PickLot
	LEFT JOIN vyuLGDeliveryOpenPickLotDetails PickLotDetail ON PickLotDetail.intPickLotHeaderId = PickLot.intPickLotHeaderId
WHERE PickLot.ysnShipped = 0