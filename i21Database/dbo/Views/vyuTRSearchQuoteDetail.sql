CREATE VIEW [dbo].[vyuTRSearchQuoteDetail]
	AS
		SELECT 
			Detail.intQuoteDetailId
			, Header.intQuoteHeaderId
			, Header.strQuoteNumber
			, Header.dtmQuoteDate
			, Header.intEntityCustomerId
			, strCustomerName = Customer.strName
			, Header.strQuoteStatus
			, Detail.intShipToLocationId
			, ShipToLocation.strLocationName
			, Detail.intSupplyPointId
			, strSupplyPoint = SupplyPointLoc.strLocationName
			, Detail.intItemId
			, Item.strItemNo
			, dblRackPrice = ISNULL(Detail.dblRackPrice, 0.000000)
			, dblQuotePrice = ISNULL(Detail.dblQuotePrice, 0.000000)
			, Header.dtmQuoteEffectiveDate
			, Customer.strEntityNo
			, Detail.intTerminalId
			, strTerminalNumber = (case when Terminal2.strVendorId = '' then Terminal.strEntityNo else Terminal2.strVendorId end)
			, strTerminalName = Terminal.strName
			, dblDeviationAmount = ISNULL(Detail.dblDeviationAmount, 0.000000)
			, dblTempAdjustment = ISNULL(Detail.dblTempAdjustment, 0.000000)
			, dblFreightRate = ISNULL(Detail.dblFreightRate, 0.000000)
			, dblMargin = ISNULL(Detail.dblMargin, 0.000000)
			, dblQtyOrdered = ISNULL(Detail.dblQtyOrdered, 0.000000)
			, dblExtProfit = ISNULL(Detail.dblExtProfit, 0.000000)
			, dblTax = ISNULL(Detail.dblTax, 0.000000)
		FROM tblTRQuoteDetail Detail
		LEFT JOIN tblTRQuoteHeader Header ON Header.intQuoteHeaderId = Detail.intQuoteHeaderId
		LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = Header.intEntityCustomerId
		LEFT JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
		LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = Detail.intTerminalId
		left join tblAPVendor Terminal2 on Terminal2.intEntityId = Terminal.intEntityId
		LEFT JOIN tblTRSupplyPoint SupplyPoint ON SupplyPoint.intSupplyPointId = Detail.intSupplyPointId
		LEFT JOIN tblEMEntityLocation SupplyPointLoc ON SupplyPointLoc.intEntityLocationId = SupplyPoint.intEntityLocationId
		LEFT JOIN tblEMEntityLocation ShipToLocation ON ShipToLocation.intEntityLocationId = Detail.intShipToLocationId
		LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = Detail.intTaxGroupId
