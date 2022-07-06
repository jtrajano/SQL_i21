CREATE VIEW [dbo].[vyuICGetShipmentAddWorkOrder]
AS

SELECT   
   strOrderType = 'AG Work Order' COLLATE Latin1_General_CI_AS  
 , strSourceType = 'None' COLLATE Latin1_General_CI_AS  
 , intLocationId = WO.intCompanyLocationId  
 , strShipFromLocation = COMPANYLOCATION.strLocationName  
 , WO.intEntityCustomerId  
 , CUST.strCustomerNumber  
 , EM.strCustomerName  
 , intLineNo = intWorkOrderDetailId  
 , intOrderId = WO.intWorkOrderId  
 , strOrderNumber = WO.strOrderNumber  
 , intSourceId = NULL  
 , strSourceNumber = NULL  
 , WODetail.intItemId  
 , Item.strItemNo  
 , strItemDescription = Item.strDescription  
 , Item.strLotTracking  
 , strBundleType = ISNULL(Item.strBundleType,'')  
 , IC.intCommodityId  
 , DefaultFromItemLocation.intSubLocationId  
 , SubLocation.strSubLocationName  
 , DefaultFromItemLocation.intStorageLocationId  
 , strStorageLocationName = StorageLocation.strName  
 , intOrderUOMId = WODetail.intItemUOMId  
 , strOrderUOM = WODetail.strUnitMeasure  
 , dblOrderUOMConvFactor = ISNULL(IU.[dblUnitQty], 0)   
 , WODetail.intItemUOMId  
 , strItemUOM = WODetail.strUnitMeasure  
 , dblItemUOMConv = ISNULL(IU.[dblUnitQty], 0)   
 , intWeightUOMId = WODetail.intItemUOMId  
 , strWeightUOM = WODetail.strUnitMeasure  
 , dblWeightItemUOMConv = ISNULL(IU.[dblUnitQty], 0)    
 , dblQtyOrdered = ISNULL(dblQtyOrdered, 0)  
 , dblQtyAllocated = ISNULL(dblQtyAllocated, 0)  
 , dblQtyShipped = ISNULL(dblQtyShipped, 0)  
 , dblUnitPrice = ISNULL(dblPrice, 0)  
 , dblDiscount = ISNULL(WODetail.dblDiscount, 0)  
 , dblTotal = ISNULL(dblTotal, 0)  
 , dblQtyToShip = ISNULL(dblQtyOrdered, 0) - ISNULL(dblQtyShipped, 0)  
 , dblPrice = ISNULL(dblPrice, 0)  
 , dblLineTotal =   
   (  
    ISNULL(dblQtyOrdered, 0)   
    - ISNULL(dblQtyShipped, 0)  
   )   
   * dbo.fnCalculateCostBetweenUOM (  
    ISNULL(ItemPriceUOM.intItemUOMId, WODetail.intItemUOMId)   
    ,WODetail.intItemUOMId  
    ,ISNULL(dblPrice, 0)  
   )  
 , intGradeId = NULL  
 , strGrade = NULL  
 , strDestinationGrades = NULL  
 , intDestinationGradeId = NULL  
 , strDestinationWeights = NULL  
 , intDestinationWeightId = NULL  
 , intCurrencyId = Currency.intDefaultCurrencyId   
 , Currency.strCurrency  
 , intShipToLocationId = WO.intCompanyLocationId  
 , intForexRateTypeId = WODetail.intCurrencyExchangeRateTypeId  
 , strForexRateType = currencyRateType.strCurrencyExchangeRateType  
 , dblForexRate = WODetail.dblCurrencyExchangeRate  
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
 , intPriceUOMId = ISNULL(WODetail.intPriceUOMId, WODetail.intItemUOMId)   
 , strPriceUOM = ISNULL(PriceUOM.strUnitMeasure, WODetail.strUnitMeasure)   
 , dblPriceUOMConv = ISNULL(ItemPriceUOM.dblUnitQty, ISNULL(IU.[dblUnitQty], 0)  )  
 FROM vyuAGGetWorkOrderDetail WODetail  
 --INNER JOIN vyuSOSalesOrderSearch SO ON SODetail.intSalesOrderId = SO.intSalesOrderId  
 INNER JOIN tblAGWorkOrder WO ON WO.intWorkOrderId = WODetail.intWorkOrderId
 LEFT JOIN (
	SELECT
	intEntityId 
	,strCustomerNumber
	FROM tblARCustomer WITH (NOLOCK)  
 )  CUST ON CUST.intEntityId = WO.intEntityCustomerId
 LEFT JOIN (
	SELECT 
	intEntityId
	,strName AS strCustomerName
		FROM tblEMEntity WITH (NOLOCK)  
 ) EM ON EM.intEntityId = CUST.intEntityId
 LEFT JOIN (  
 SELECT 
	intItemId  
   , intCommodityId  
   --, strItemNo  
   --, strLotTracking  
 FROM dbo.tblICItem WITH (NOLOCK)  
) IC ON WODetail.intItemId = IC.intItemId  
LEFT JOIN (  
 SELECT intItemUOMId  
   , intUnitMeasureId  
   , dblUnitQty  
 FROM dbo.tblICItemUOM WITH (NOLOCK)  
) IU ON WODetail.intItemUOMId = IU.intItemUOMId  

 LEFT JOIN tblICItem Item ON Item.intItemId = WODetail.intItemId  
 LEFT JOIN dbo.tblICItemLocation DefaultFromItemLocation ON DefaultFromItemLocation.intItemId = WODetail.intItemId  
  AND DefaultFromItemLocation.intLocationId = WO.intCompanyLocationId  
 LEFT JOIN dbo.tblSMCompanyLocationSubLocation SubLocation  
  ON SubLocation.intCompanyLocationSubLocationId = DefaultFromItemLocation.intSubLocationId
   LEFT JOIN  (
	SELECT intCompanyLocationId
	,strLocationName
	FROM tblSMCompanyLocation
 ) COMPANYLOCATION ON COMPANYLOCATION.intCompanyLocationId = WO.intCompanyLocationId  
 LEFT JOIN dbo.tblICStorageLocation StorageLocation
  ON StorageLocation.intStorageLocationId = DefaultFromItemLocation.intStorageLocationId  
 LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType  
  ON currencyRateType.intCurrencyExchangeRateTypeId = WODetail.intCurrencyExchangeRateTypeId  
LEFT JOIN tblEMEntityLocation custLocation 
  ON CUST.intEntityId = custLocation.intEntityId AND custLocation.ysnDefaultLocation = 1  
 LEFT JOIN [tblEMEntityLocation] ShipToLocation   
  ON CUST.intEntityId = ShipToLocation.intEntityId AND ShipToLocation.ysnDefaultLocation = 1   --ShipToLocation.intEntityLocationId = OSO.intShipToLocationId  
  LEFT JOIN tblSMFreightTerms FreightTerms  
  ON FreightTerms.intFreightTermId = ISNULL(ShipToLocation.intFreightTermId, custLocation.intFreightTermId) --OSO.intFreightTermId  
 CROSS APPLY  (
	SELECT TOP 1
	 intDefaultCurrencyId
	,strCurrency
	 FROM tblSMCompanyPreference
 ) Currency
 LEFT JOIN (  
  tblICItemUOM ItemPriceUOM INNER JOIN tblICUnitMeasure PriceUOM  
   ON ItemPriceUOM.intUnitMeasureId = PriceUOM.intUnitMeasureId  
 )  
  ON ItemPriceUOM.intItemUOMId = WODetail.intPriceUOMId  
  
WHERE ISNULL(WODetail.dblQtyShipped, 0) < ISNULL(WODetail.dblQtyOrdered, 0)   
  AND ISNULL(WO.strStatus, '') IN ('Open', 'In Progress')

--SELECT *  
--FROM   
-- vyuICGetShipmentAddSalesOrder -- Please replace it with the 'Ag Work Order' equivalent. You can use vyuICGetShipmentAddSalesOrder as the pattern.   
--WHERE  
-- 1 = 0
