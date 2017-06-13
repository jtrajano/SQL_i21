CREATE VIEW [dbo].[vyuPATEntityPatron]
	AS
SELECT	A.intEntityId, 
		D.strName,
		D.strEntityNo,
		C.strStockStatus,
		C.dtmBirthDate,
		C.dtmDeceasedDate,
		C.dtmLastActivityDate,
		C.dtmMembershipDate,
		B.ysnWithholding,
		C.intConcurrencyId AS intCustomerConcurrencyId,
		B.intConcurrencyId AS intVendorConcurrencyId
FROM vyuEMEntityType A
JOIN tblAPVendor B
	ON A.intEntityId = B.intEntityId
JOIN tblARCustomer C
	ON A.intEntityId = C.intEntityId
JOIN tblEMEntity D
	ON A.intEntityId = D.intEntityId
WHERE A.Customer = 1 AND A.Vendor = 1