PRINT '*** Checking if exists vyuCPContactMenu ***'
IF EXISTS( SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'vyuCPContactMenu' )
BEGIN	
	PRINT '*** Dropping vyuCPContactMenu: ***'
	EXEC('DROP VIEW vyuCPContactMenu')
		
END
PRINT '*** End Checking if exists vyuCPContactMenu ***'

PRINT '*** Checking if exists tblARCustomerPortalPermission ***'
IF EXISTS( SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerPortalPermission' )
BEGIN	
	PRINT '*** Dropping tblARCustomerPortalPermission: ***'
	EXEC('DROP TABLE tblARCustomerPortalPermission')
		
END
PRINT '*** End Checking if exists tblARCustomerPortalPermission ***'


PRINT '*** Checking if exists tblARCustomerToContact ***'
IF EXISTS( SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerToContact' )
BEGIN
	PRINT '*** Dropping tblARCustomerToContact ***'
	EXEC('DROP TABLE tblARCustomerToContact')
	
END
PRINT '*** End Checking if exists tblARCustomerToContact ***'

PRINT '*** Checking if exists tblAPVendorToContact ***'
IF EXISTS( SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendorToContact' )
BEGIN
	PRINT '*** Dropping tblAPVendorToContact ***'
	EXEC('DROP TABLE tblAPVendorToContact')
	
END
PRINT '*** End Checking if exists tblAPVendorToContact ***'

PRINT '*** Checking if exists tblEntityContact ***'
IF EXISTS( SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityContact' )
BEGIN
	PRINT '*** Dropping tblEntityContact ***'
	EXEC('DROP TABLE tblEntityContact')
	
END
PRINT '*** End Checking if exists tblEntityContact ***'



