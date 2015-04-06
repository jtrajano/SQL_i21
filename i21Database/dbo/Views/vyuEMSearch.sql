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
SELECT a.intEntityId,
			a.strName,
			case when b.intEntityVendorId is null then 0 else 1 end Vendor,
			case when c.intEntityCustomerId is null then 0 else 1 end Customer
		FROM tblEntity a
			left join tblAPVendor b
				on a.intEntityId = b.intEntityVendorId
			left join tblARCustomer c
				on a.intEntityId = c.intEntityCustomerId
	where (isnull(b.intEntityVendorId,0) + isnull(c.intEntityCustomerId,0) ) > 1
