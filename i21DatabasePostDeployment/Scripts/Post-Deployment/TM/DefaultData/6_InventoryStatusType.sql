GO
	PRINT N'BEGIN INSERT DEFAULT TM INVENTORY STATUS TYPE'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMInventoryStatusType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMInventoryStatusType WHERE strInventoryStatusType = 'In' AND ysnDefault = 1) INSERT INTO tblTMInventoryStatusType (strInventoryStatusType,ysnDefault) VALUES ('In', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMInventoryStatusType WHERE strInventoryStatusType = 'Out' AND ysnDefault = 1) INSERT INTO tblTMInventoryStatusType (strInventoryStatusType,ysnDefault) VALUES ('Out', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMInventoryStatusType WHERE strInventoryStatusType = 'Sold' AND ysnDefault = 1) INSERT INTO tblTMInventoryStatusType (strInventoryStatusType,ysnDefault) VALUES ('Sold', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMInventoryStatusType WHERE strInventoryStatusType = 'Not In Service' AND ysnDefault = 1) INSERT INTO tblTMInventoryStatusType (strInventoryStatusType,ysnDefault) VALUES ('Not In Service', 1)
END

GO
	PRINT N'END INSERT DEFAULT TM INVENTORY STATUS TYPE'
GO