--liquibase formatted sql

-- changeset Von:vyuICGetShipmentAddSalesOrder.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetShipmentAddSalesOrder]
AS
SELECT 
	--intKey = CAST(ROW_NUMBER() OVER(ORDER BY SODetail.intCompanyLocationId, SODetail.intEntityCustomerId, intSalesOrderDetailId) AS INT)
	 strOrderType = 'Sales Order' COLLATE Latin1_General_CI_AS
	, strSourceType = 'None' COLLATE Latin1_General_CI_AS
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
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Item.strLotTracking
	, strBundleType = ISNULL(Item.strBundleType,'')
	, SODetail.intCommodityId
	, DefaultFromItemLocation.intSubLocationId
	, SubLocation.strSubLocationName
	, DefaultFromItemLocation.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
	, intOrderUOMId = SODetail.intItemUOMId
	, strOrderUOM = SODetail.strUnitMeasure
	, dblOrderUOMConvFactor = dblUOMConversion
	, SODetail.intItemUOMId
	, strItemUOM = SODetail.strUnitMeasure
	, dblItemUOMConv = SODetail.dblUOMConversion
	, intWeightUOMId = SODetail.intItemUOMId
	, strWeightUOM = SODetail.strUnitMeasure
	, dblWeightItemUOMConv = dblUOMConversion
	, dblQtyOrdered = ISNULL(dblQtyOrdered, 0)
	, dblQtyAllocated = ISNULL(dblQtyAllocated, 0)
	, dblQtyShipped = ISNULL(dblQtyShipped, 0)
	, dblUnitPrice = ISNULL(dblPrice, 0)
	, dblDiscount = ISNULL(SODetail.dblDiscount, 0)
	, dblTotal = ISNULL(dblTotal, 0)
	, dblQtyToShip = ISNULL(dblQtyOrdered, 0) - ISNULL(dblQtyShipped, 0)
	, dblPrice = ISNULL(dblPrice, 0)
	, dblLineTotal = 
			(
				ISNULL(dblQtyOrdered, 0) 
				- ISNULL(dblQtyShipped, 0)
			) 
			* dbo.fnCalculateCostBetweenUOM (
				ISNULL(ItemPriceUOM.intItemUOMId, SODetail.intItemUOMId) 
				,SODetail.intItemUOMId
				,ISNULL(dblPrice, 0)
			)
	, intGradeId = NULL
	, strGrade = NULL
	, strDestinationGrades = NULL
	, intDestinationGradeId = NULL
	, strDestinationWeights = NULL
	, intDestinationWeightId = NULL
	, intCurrencyId = SO.intCurrencyId	
	, Currency.strCurrency
	, intShipToLocationId = OSO.intShipToLocationId
	, intForexRateTypeId = SODetail.intCurrencyExchangeRateTypeId
	, strForexRateType = currencyRateType.strCurrencyExchangeRateType
	, dblForexRate = SODetail.dblCurrencyExchangeRate
	, FreightTerms.intFreightTermId
	, FreightTerms.strFreightTerm
	, strShipToLocation = ShipToLocation.strLocationName 
	, strShipToStreet = ShipToLocation.strAddress
	, strShipToCity = ShipToLocation.strCity
	, strShipToState = ShipToLocation.strState
	, strShipToZipCode = ShipToLocation.strZipCode
	, strShipToCountry = ShipToLocation.strCountry
	, strShipToAddress = 
					[dbo].[fnARFormatCustomerAddress](
						DEFAULT
						,DEFAULT 
						,DEFAULT 
						,ShipToLocation.strAddress
						,ShipToLocation.strCity
						,ShipToLocation.strState
						,ShipToLocation.strZipCode
						,ShipToLocation.strCountry
						,DEFAULT 
						,DEFAULT 
					) COLLATE Latin1_General_CI_AS
	, intPriceUOMId = ISNULL(SODetail.intPriceUOMId, SODetail.intItemUOMId) 
	, strPriceUOM = ISNULL(SODetail.strPriceUOM, SODetail.strUnitMeasure) 
	, dblPriceUOMConv = ISNULL(ItemPriceUOM.dblUnitQty, SODetail.dblUOMConversion)
FROM vyuSOSalesOrderDetail SODetail
	INNER JOIN vyuSOSalesOrderSearch SO ON SODetail.intSalesOrderId = SO.intSalesOrderId
	INNER JOIN tblSOSalesOrder OSO ON OSO.intSalesOrderId = SO.intSalesOrderId
	LEFT JOIN tblICItem Item ON Item.intItemId = SODetail.intItemId
	LEFT JOIN dbo.tblICItemLocation DefaultFromItemLocation ON DefaultFromItemLocation.intItemId = SODetail.intItemId
		AND DefaultFromItemLocation.intLocationId = SODetail.intCompanyLocationId
	LEFT JOIN dbo.tblSMCompanyLocationSubLocation SubLocation
		ON SubLocation.intCompanyLocationSubLocationId = DefaultFromItemLocation.intSubLocationId
	LEFT JOIN dbo.tblICStorageLocation StorageLocation
		ON StorageLocation.intStorageLocationId = DefaultFromItemLocation.intStorageLocationId
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = SODetail.intCurrencyExchangeRateTypeId
	LEFT JOIN tblSMFreightTerms FreightTerms
		ON FreightTerms.intFreightTermId = OSO.intFreightTermId
	LEFT JOIN [tblEMEntityLocation] ShipToLocation 
		ON ShipToLocation.intEntityLocationId = OSO.intShipToLocationId
	LEFT JOIN tblSMCurrency Currency 
		ON Currency.intCurrencyID = SO.intCurrencyId
	LEFT JOIN (
		tblICItemUOM ItemPriceUOM INNER JOIN tblICUnitMeasure PriceUOM
			ON ItemPriceUOM.intUnitMeasureId = PriceUOM.intUnitMeasureId
	)
		ON ItemPriceUOM.intItemUOMId = SODetail.intPriceUOMId

WHERE	ISNULL(SODetail.dblQtyShipped, 0) < ISNULL(SODetail.dblQtyOrdered, 0) 
		AND ISNULL(SO.strOrderStatus, '') IN ('Open', 'Partial', 'Pending')



