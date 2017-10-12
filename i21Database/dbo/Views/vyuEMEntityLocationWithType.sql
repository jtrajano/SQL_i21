CREATE VIEW [dbo].[vyuEMEntityLocationWithType]
	AS



select 
	a.intEntityLocationId,
	a.intEntityId,
	strLocationName,
	strAddress,
	strCity,
	strCountry,
	strState,
	strZipCode,
	strSupplyPoint,
	intRackPriceSupplyPointId,
	strGrossOrNet,
	a.ysnActive,
	Vendor,
	Customer,
	Salesperson,
	FuturesBroker,
	ForwardingAgent,
	Terminal,
	ShippingLine,
	Trucker,
	ShipVia,
	Insurer,
	Employee,
	Producer,
	[User],
	Prospect,
	Competitor,
	Buyer,
	[Partner],
	Lead,
	Veterinary,
	Lien
from tblEMEntityLocation a
	join vyuEMEntityType b
		on a.intEntityId = b.intEntityId
	left join tblTRSupplyPoint c
		on c.intEntityLocationId = a.intEntityLocationId 
			and c.intEntityVendorId = a.intEntityId
	left join tblTRImportRackPriceDetail d
		on d.intSupplyPointId = c.intSupplyPointId