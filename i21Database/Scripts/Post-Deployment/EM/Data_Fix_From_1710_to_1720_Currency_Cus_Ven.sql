DECLARE @CurrencyId int

SELECT TOP 1 @CurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

IF @CurrencyId IS NOT NULL
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM tblARCustomer WHERE intCurrencyId IS NULL)
	BEGIN
		UPDATE tblARCustomer SET intCurrencyId = @CurrencyId WHERE intCurrencyId IS NULL
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblAPVendor WHERE intCurrencyId IS NULL)
	BEGIN
		UPDATE tblAPVendor SET intCurrencyId = @CurrencyId WHERE intCurrencyId IS NULL
	END
END