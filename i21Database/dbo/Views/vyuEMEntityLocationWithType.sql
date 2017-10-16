CREATE VIEW [dbo].[vyuEMEntityLocationWithType]
	AS
		select 
			a.intEntityLocationId,
			a.intEntityId,
			a.strLocationName,
			a.strAddress,
			a.strCity,
			a.strCountry,
			a.strState,
			a.strZipCode,
			strSupplyPoint = a.strLocationName,
			c.intRackPriceSupplyPointId,
			c.strGrossOrNet,
			a.ysnActive,
			b.Vendor,
			b.Customer,
			b.Salesperson,
			b.FuturesBroker,
			b.ForwardingAgent,
			b.Terminal,
			b.ShippingLine,
			b.Trucker,
			b.ShipVia,
			b.Insurer,
			b.Employee,
			b.Producer,
			b.[User],
			b.Prospect,
			b.Competitor,
			b.Buyer,
			b.[Partner],
			b.Lead,
			b.Veterinary,
			b.Lien,
			--Added by Jayson
			strRackPriceSupplyPoint = g.strLocationName,
			e.intTerminalControlNumberId,
			e.strTerminalControlNumber,
			c.strFuelDealerId1,
			c.strFuelDealerId2,
			c.strDefaultOrigin,
			c.ysnMultipleDueDates,
			a.intTaxGroupId,
			h.strTaxGroup,
			c.intSupplyPointId
			--End of Added by Jayson
		from tblEMEntityLocation a
			join vyuEMEntityType b
				on a.intEntityId = b.intEntityId
			left join tblTRSupplyPoint c
				on c.intEntityLocationId = a.intEntityLocationId 
					and c.intEntityVendorId = a.intEntityId
			left join tblTFTerminalControlNumber e
				on e.intTerminalControlNumberId = c.intTerminalControlNumberId
			left join tblTRSupplyPoint f
				on f.intSupplyPointId = c.intRackPriceSupplyPointId
			left join tblEMEntityLocation g
				on g.intEntityLocationId = f.intEntityLocationId
			left join tblSMTaxGroup h
				on h.intTaxGroupId = a.intTaxGroupId