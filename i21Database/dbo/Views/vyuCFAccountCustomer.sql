﻿CREATE VIEW [dbo].[vyuCFAccountCustomer]
AS
SELECT *
FROM  dbo.tblCFAccount AS cfAccount INNER JOIN
dbo.vyuCFCustomerEntity AS emEntity ON emEntity.intEntityCustomerId = cfAccount.intCustomerId
GO


