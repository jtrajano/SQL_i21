CREATE FUNCTION [dbo].[fnARGetCustomerDefaultCurreny]
(
	@EntityCustomerId	INT
)
RETURNS INT
AS
BEGIN
	RETURN	ISNULL((	SELECT TOP 1 
							intDefaultCurrencyId
						FROM
							tblSMCompanyPreference
						WHERE
							intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0
					), (SELECT 
							[intCurrencyId]
						FROM
							tblARCustomer
						WHERE
							[intEntityId] = @EntityCustomerId
						)
				    )		
END
