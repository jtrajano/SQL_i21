CREATE VIEW [dbo].[vyuPATEntityPatron]
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
		ysnWithholding = ISNULL(B.ysnWithholding, 0),
		ysnCustomer = CAST(A.Customer AS BIT),
		ysnVendor = CAST(A.Vendor AS BIT),
		C.intConcurrencyId AS intCustomerConcurrencyId,
		B.intConcurrencyId AS intVendorConcurrencyId,
		
		--Patronage Setup Preferences
		Patronage.strRefund,
		strRefundDescription = CASE 
					WHEN Patronage.strRefund = 'A' THEN 'All Patrons' 
					WHEN Patronage.strRefund = 'S' THEN 'Stockholders' 
					WHEN Patronage.strRefund = 'V' THEN 'Voting Only' 
				END,
		Patronage.dblMinimumRefund,
		Patronage.dblServiceFee,
		Patronage.dblCutoffAmount,
		Patronage.strCutoffTo,
		Patronage.strPayOnGrain,
		Patronage.strPrintCheck,
		Patronage.dblMinimumDividends,
		Patronage.ysnProRatedDividends,
		Patronage.dtmCutoffDate
FROM vyuEMEntityType A
LEFT JOIN tblAPVendor B
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
CROSS JOIN tblPATCompanyPreference Patronage
WHERE A.Customer = 1