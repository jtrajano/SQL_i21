CREATE FUNCTION [dbo].[fnAPGetVendorPayFromBankAccount]
(
	@vendorId INT,
	@locationId INT,
	@currencyId INT
)
RETURNS TABLE AS RETURN
(
	SELECT TOP 1 intPayFromBankAccountId, strPayFromBankAccount, strSourcedFrom
	FROM (
		--VENDOR PER LOCATION
		SELECT VANL.intPayFromBankAccountId intPayFromBankAccountId, 
			   BA.strBankAccountNo strPayFromBankAccount, 
			   'Vendor Default' strSourcedFrom, 
			   1 intOrder
		FROM tblAPVendor V
		INNER JOIN tblAPVendorAccountNumLocation VANL ON VANL.intEntityVendorId = V.intEntityId
		INNER JOIN vyuCMBankAccount BA ON BA.intBankAccountId = VANL.intPayFromBankAccountId
		WHERE V.intEntityId = @vendorId AND VANL.intCompanyLocationId = @locationId AND BA.intCurrencyId = @currencyId
		--VENDOR DEFAULT
		UNION
		SELECT V.intPayFromBankAccountId intPayFromBankAccountId, 
			   BA.strBankAccountNo strPayFromBankAccount, 
			   'Vendor Default' strSourcedFrom, 
			   2 intOrder
		FROM tblAPVendor V
		INNER JOIN vyuCMBankAccount BA ON BA.intBankAccountId = V.intPayFromBankAccountId
		WHERE V.intEntityId = @vendorId AND BA.intCurrencyId = @currencyId
		--COMPANY CONFIGURATION DEFAULT
		UNION
		SELECT DPFBA.intBankAccountId intPayFromBankAccountId, 
			   BA.strBankAccountNo strPayFromBankAccount, 
			   'Company Default' strSourcedFrom, 
			   3 intOrder
		FROM tblAPDefaultPayFromBankAccount DPFBA
		INNER JOIN vyuCMBankAccount BA ON BA.intBankAccountId = DPFBA.intBankAccountId
		WHERE DPFBA.intCurrencyId = @currencyId
		--NONE
		UNION
		SELECT NULL intPayFromBankAccountId, 
			   NULL strPayFromBankAccount, 
			   'None' strSourcedFrom, 
			   4 intOrder
	) PFBA
	ORDER BY intOrder
)