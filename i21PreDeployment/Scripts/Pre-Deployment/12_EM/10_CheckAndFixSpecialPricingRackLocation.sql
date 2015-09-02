PRINT '*** Check and fix for orphan rack location for customer special pricing***'
IF(
	EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intEntityLocationId' and object_id = OBJECT_ID(N'tblEntityLocation'))
	AND EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intRackLocationId' and object_id = OBJECT_ID(N'tblARCustomerSpecialPrice'))	
)
BEGIN
	EXEC('UPDATE tblARCustomerSpecialPrice SET intRackLocationId = NULL 
			where intRackLocationId not in ( select intEntityLocationId from tblEntityLocation)') 
END