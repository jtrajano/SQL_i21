PRINT N'Set Freight Tariff Type using Customer Header''s Tariff Type'
GO

-- Update Freight's Tariff Type using the Customer's Tariff Type
UPDATE Freight SET Freight.intEntityTariffTypeId = Customer.intEntityTariffTypeId
FROM tblARCustomerFreightXRef Freight 
INNER JOIN tblARCustomer Customer ON Freight.intEntityCustomerId = Customer.intEntityId
WHERE Customer.intEntityTariffTypeId IS NOT NULL
GO

-- Update Customer's Tariff Type to NULL
UPDATE tblARCustomer SET intEntityTariffTypeId = NULL WHERE intEntityTariffTypeId IS NOT NULL
GO
