--liquibase formatted sql

-- changeset Von:fnARGetCustomerDefaultCurrency.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARGetCustomerDefaultCurrency]
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



