CREATE VIEW [dbo].[vyuTRGetQuoteDetail]
AS

SELECT Header.intQuoteHeaderId
	, Header.strQuoteNumber
	, Header.dtmQuoteDate
	, Header.dtmQuoteEffectiveDate
	, Header.intEntityCustomerId
	, Header.strQuoteStatus
	, Customer.strCustomerNumber
	, strCustomerName = Customer.strName
	, ShipToLocation.strLocationName
	, Detail.intQuoteDetailId
	, Detail.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Detail.intTerminalId
	, strTerminalNumber = Terminal.strVendorId
	, strTerminalName = Terminal.strName
	, Detail.intSupplyPointId
	, SupplyPoint.intEntityLocationId
	, SupplyPoint.strSupplyPoint
	, dblRackPrice = ISNULL(Detail.dblRackPrice, 0.000000)
	, dblDeviationAmount = ISNULL(Detail.dblDeviationAmount, 0.000000)
	, dblTempAdjustment = ISNULL(Detail.dblTempAdjustment, 0.000000)
	, dblFreightRate = ISNULL(Detail.dblFreightRate, 0.000000)
	, dblQuotePrice = ISNULL(Detail.dblQuotePrice, 0.000000)
	, dblMargin = ISNULL(Detail.dblMargin, 0.000000)
	, dblQtyOrdered = ISNULL(Detail.dblQtyOrdered, 0.000000)
	, dblExtProfit = ISNULL(Detail.dblExtProfit, 0.000000)
	, Detail.intTaxGroupId
	, TaxGroup.strTaxGroup
	, dblTax = ISNULL(Detail.dblTax, 0.000000)
	, Detail.intShipToLocationId
	, strShipTo = ShipToLocation.strLocationName
FROM tblTRQuoteDetail Detail
LEFT JOIN tblTRQuoteHeader Header ON Header.intQuoteHeaderId = Detail.intQuoteHeaderId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityId = Header.intEntityCustomerId
LEFT JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
LEFT JOIN vyuAPVendor Terminal ON Terminal.intEntityId = Detail.intTerminalId
LEFT JOIN vyuTRSupplyPointView SupplyPoint ON SupplyPoint.intSupplyPointId = Detail.intSupplyPointId
LEFT JOIN tblEMEntityLocation ShipToLocation ON ShipToLocation.intEntityLocationId = Detail.intShipToLocationId
LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = Detail.intTaxGroupId