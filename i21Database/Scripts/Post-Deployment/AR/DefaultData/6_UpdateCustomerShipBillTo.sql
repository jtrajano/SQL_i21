
print('/*******************  BEGIN Update Bill To in tblARCustomer  *******************/')
GO

UPDATE
	tblARCustomer
SET
	intBillToId = (SELECT TOP 1 intEntityLocationId FROM [tblEMEntityLocation] WHERE ysnDefaultLocation = 1 AND intEntityId = tblARCustomer.[intEntityId])
WHERE
	intBillToId IS NULL


GO
print('/*******************  END Update Bill To in tblARCustomer  *******************/')


print('/*******************  BEGIN Update Ship To in tblARCustomer  *******************/')
GO

UPDATE
	tblARCustomer
SET
	intShipToId = (SELECT TOP 1 intEntityLocationId FROM [tblEMEntityLocation] WHERE ysnDefaultLocation = 1 AND intEntityId = tblARCustomer.[intEntityId])
WHERE
	intShipToId IS NULL


GO
print('/*******************  END Update Ship To in tblARCustomer  *******************/')