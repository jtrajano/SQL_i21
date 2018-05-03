CREATE PROCEDURE [dbo].[uspARUpdateCustomerTotalAR]
AS

TRUNCATE TABLE tblARCustomerAgingStagingTable
EXEC uspARCustomerAgingAsOfDateReport

UPDATE CUSTOMER
SET dblARBalance = AGING.dblTotalAR
FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
		 , dblTotalAR = ISNULL(dblTotalAR, 0)
	FROM tblARCustomerAgingStagingTable
) AGING ON CUSTOMER.intEntityId = AGING.intEntityCustomerId

TRUNCATE TABLE tblARCustomerAgingStagingTable