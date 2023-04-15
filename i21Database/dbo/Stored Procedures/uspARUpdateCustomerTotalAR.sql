CREATE PROCEDURE [dbo].[uspARUpdateCustomerTotalAR]
AS

TRUNCATE TABLE tblARCustomerAgingStagingTable
EXEC uspARCustomerAgingAsOfDateReport @intEntityUserId = 1

UPDATE CUSTOMER
SET dblARBalance = ISNULL(AGING.dblTotalAR, 0)
FROM dbo.tblARCustomer CUSTOMER 
LEFT JOIN tblARCustomerAgingStagingTable AGING ON CUSTOMER.intEntityId = AGING.intEntityCustomerId AND AGING.intEntityUserId = 1 AND AGING.strAgingType = 'Summary'