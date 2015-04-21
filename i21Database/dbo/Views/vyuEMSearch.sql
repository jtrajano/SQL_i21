CREATE VIEW [dbo].[vyuEMSearch]
as 
/*select * from (
	select a.intEntityId,
		b.strType,
		a.strName,
		1 as bitval
	from tblEntity a
		left join tblEntityType b 
			on a.intEntityId = b.intEntityId
		where b.strType not in ('User')
) d
pivot
(
	min(bitval)
	for strType in (Vendor,Customer)
)piv
*/
SELECT   
	a.intEntityId,    
	a.strName,  
	g.strPhone,  
	e.strAddress,  
	e.strCity,  
	e.strState,  
	e.strZipCode,  
	case when b.intEntityVendorId is null then 0 else 1 end Vendor,    
	case when c.intEntityCustomerId is null then 0 else 1 end Customer ,    
	case when d.intEntitySalespersonId is null then 0 else 1 end Salesperson   
   
FROM tblEntity a    
	left join tblAPVendor b    
		on a.intEntityId = b.intEntityVendorId and b.ysnPymtCtrlActive = 1
	left join tblARCustomer c    
		on a.intEntityId = c.intEntityCustomerId and c.ysnActive = 1
	LEFT JOIN tblARSalesperson d  
		on a.intEntityId = d.intEntitySalespersonId and d.ysnActive = 1
	left join tblEntityLocation e  
		on a.intDefaultLocationId = e.intEntityLocationId  
	left join tblEntityToContact f  
		on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
	left join tblEntity g  
		on f.intEntityContactId = g.intEntityId  
   
 where (isnull(b.intEntityVendorId,0) + isnull(c.intEntityCustomerId,0) +  isnull(d.intEntitySalespersonId,0)) > 1  
