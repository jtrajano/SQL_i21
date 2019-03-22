CREATE VIEW [dbo].[vyuEMEntityBasicWithType]
	AS 

	select 
		a.intEntityId,
		a.Vendor,
		a.Customer,
		a.Salesperson,
		a.FuturesBroker,
		a.ForwardingAgent,
		a.Terminal,
		a.ShippingLine,
		a.Trucker,
		a.ShipVia,
		a.Insurer,
		a.Employee,
		a.Producer,
		[User] = a.[User],
		a.Prospect,
		a.Competitor,
		a.Buyer,
		a.[Partner],
		a.Lead ,
		VendorTerminal = Cast(isnull(b.ysnTransportTerminal,0) as int),
		strEntityNo = c.strEntityNo,
		strEntityName = c.strName,
		strContactName = e.strName,
		intEntityContactId = d.intEntityContactId
from vyuEMEntityType a
	left join tblAPVendor b 
		on a.intEntityId = b.[intEntityId]
	join tblEMEntity c
		on a.intEntityId = c.intEntityId
	join tblEMEntityToContact d
		on c.intEntityId = d.intEntityId and d.ysnDefaultContact = 1
	join tblEMEntity e
		on d.intEntityContactId = e.intEntityId
