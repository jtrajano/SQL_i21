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