CREATE FUNCTION [dbo].[fnARGetCustomerDefaultPayToBankAccount]
(
	 @EntityCustomerId	INT
	,@CurrencyId		INT
	,@CompanyLocationId	INT
)
RETURNS INT
AS
BEGIN
	RETURN	ISNULL((	SELECT TOP 1 
							intBankAccountId
						FROM
							tblARCustomerDefaultPayToBankAccount
						WHERE
							intEntityCustomerId = @EntityCustomerId
						AND intCurrencyId = @CurrencyId
						AND intCompanyLocationId = @CompanyLocationId
					), (SELECT TOP 1
							intBankAccountId
						FROM
							tblARCompanyDefaultPayToBankAccount
						WHERE
							intCurrencyId = @CurrencyId
						AND intCompanyLocationId = @CompanyLocationId
						)
				    )		
END
