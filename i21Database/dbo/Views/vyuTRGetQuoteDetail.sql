CREATE VIEW [dbo].[vyuTRGetQuoteDetail]
AS

SELECT 
	Header.intQuoteHeaderId
	, Header.strQuoteNumber
	, Header.dtmQuoteDate
	, Header.dtmQuoteEffectiveDate
	, Header.intEntityCustomerId
	, Header.strQuoteStatus
	, Customer.strCustomerNumber
	, strCustomerName = Customer.strName
	, Detail.intQuoteDetailId
	, Detail.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Detail.intTerminalId
	, strTerminalNumber = Terminal.strVendorId
	, strTerminalName = Terminal.strName
	, Detail.intSupplyPointId
	, SupplyPoint.strSupplyPoint
	, Detail.dblRackPrice
	, Detail.dblDeviationAmount
	, Detail.dblTempAdjustment
	, Detail.dblFreightRate
	, Detail.dblQuotePrice
	, Detail.dblMargin
	, Detail.dblQtyOrdered
	, Detail.dblExtProfit
	, Detail.dblTax
	, Detail.intShipToLocationId
	, ShipToLocation.strLocationName
FROM tblTRQuoteDetail Detail
LEFT JOIN tblTRQuoteHeader Header ON Header.intQuoteHeaderId = Detail.intQuoteHeaderId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = Header.intEntityCustomerId
LEFT JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
LEFT JOIN vyuAPVendor Terminal ON Terminal.intEntityVendorId = Detail.intTerminalId
LEFT JOIN vyuTRSupplyPointView SupplyPoint ON SupplyPoint.intSupplyPointId = Detail.intSupplyPointId
LEFT JOIN [tblEMEntityLocation] ShipToLocation ON ShipToLocation.intEntityLocationId = Detail.intShipToLocationId