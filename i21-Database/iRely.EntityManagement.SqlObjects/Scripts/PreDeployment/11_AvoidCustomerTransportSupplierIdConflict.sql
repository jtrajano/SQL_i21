PRINT '*** Check and fix for orphan customer transport supply point ***'
IF(
	EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intSupplyPointId' and object_id = OBJECT_ID(N'tblTRSupplyPoint'))
	AND EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intSupplyPointId' and object_id = OBJECT_ID(N'tblARCustomerRackQuoteVendor'))	
)
BEGIN
	EXEC(' ALTER TABLE tblARCustomerRackQuoteVendor ALTER COLUMN intSupplyPointId int NULL')
	EXEC('UPDATE tblARCustomerRackQuoteVendor SET intSupplyPointId = NULL 
			where intSupplyPointId not in ( select intSupplyPointId from tblTRSupplyPoint)') 
END