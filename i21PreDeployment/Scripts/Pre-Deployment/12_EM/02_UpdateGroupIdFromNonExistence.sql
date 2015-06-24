
PRINT '*** Update Customer Buyback Group Id ***'

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' AND [COLUMN_NAME] = 'intBuybackGroupId') 
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerGroup' AND [COLUMN_NAME] = 'intCustomerGroupId') 
BEGIN
	EXEC('
	update tblARCustomer set intBuybackGroupId = null where intBuybackGroupId is not null and intBuybackGroupId not in( select intCustomerGroupId from tblARCustomerGroup )
	')
END
PRINT '*** End Update Customer Buyback Group Id ***'

PRINT '*** Update Customer Price Group Id ***'

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' AND [COLUMN_NAME] = 'intPriceGroupId') 
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerGroup' AND [COLUMN_NAME] = 'intCustomerGroupId') 
BEGIN
	EXEC('
	update tblARCustomer set intPriceGroupId  = null where intPriceGroupId is not null and intPriceGroupId not in( select intCustomerGroupId from tblARCustomerGroup )
	')
END

PRINT '*** End Update Customer Price Group Id ***'

PRINT '*** Update Customer Contract Group Id ***'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' AND [COLUMN_NAME] = 'intContractGroupId') 
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerGroup' AND [COLUMN_NAME] = 'intCustomerGroupId') 
BEGIN
	EXEC('
	update tblARCustomer set intContractGroupId = null where intContractGroupId is not null and intContractGroupId not in( select intCustomerGroupId from tblARCustomerGroup )
	')
END
PRINT '*** End Update Customer Contract Group Id ***'