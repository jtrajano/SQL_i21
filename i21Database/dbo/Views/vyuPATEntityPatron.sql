﻿CREATE VIEW [dbo].[vyuPATEntityPatron]
	AS
SELECT	A.intEntityId, 
		D.strName,
		D.strEntityNo,
		strEntityAddress = [dbo].[fnARFormatCustomerAddress](NULL, NULL, NULL, Loc.strAddress, Loc.strCity, Loc.strState, Loc.strZipCode, Loc.strCountry, NULL, NULL),
		strAccountStatus = [dbo].[fnARGetCustomerAccountStatusCodes](A.intEntityId),
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
LEFT OUTER JOIN (
	SELECT	intEntityId,
			strAddress,
			strCity,
			strCountry,
			strState,
			strZipCode
	FROM tblEMEntityLocation
	WHERE ysnDefaultLocation = 1
) Loc ON Loc.intEntityId = D.intEntityId
WHERE A.Customer = 1 AND A.Vendor = 1