GO
	PRINT N'BEGIN INSERT DEFAULT TM WORK TODO ITEM'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMWorkToDoItem]') AND type in (N'U')) 
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'PICK UP TANK' AND ysnDefault <> 1) UPDATE tblTMWorkToDoItem SET ysnDefault = 1 WHERE strToDoItem = 'PICK UP TANK'
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'LEAK CHECK' AND ysnDefault <> 1) UPDATE tblTMWorkToDoItem SET ysnDefault = 1 WHERE strToDoItem = 'LEAK CHECK'
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'GAS CHECK' AND ysnDefault <> 1) UPDATE tblTMWorkToDoItem SET ysnDefault = 1 WHERE strToDoItem = 'GAS CHECK'
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'MARK THE LINE' AND ysnDefault <> 1) UPDATE tblTMWorkToDoItem SET ysnDefault = 1 WHERE strToDoItem = 'MARK THE LINE'
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'LABOR' AND ysnDefault <> 1) UPDATE tblTMWorkToDoItem SET ysnDefault = 1 WHERE strToDoItem = 'LABOR'
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'SET TANK' AND ysnDefault <> 1) UPDATE tblTMWorkToDoItem SET ysnDefault = 1 WHERE strToDoItem = 'SET TANK'
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'BURY LINE' AND ysnDefault <> 1) UPDATE tblTMWorkToDoItem SET ysnDefault = 1 WHERE strToDoItem = 'BURY LINE'


	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'PICK UP TANK') INSERT INTO tblTMWorkToDoItem (strToDoItem,ysnDefault) VALUES ('PICK UP TANK', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'LEAK CHECK') INSERT INTO tblTMWorkToDoItem (strToDoItem,ysnDefault) VALUES ('LEAK CHECK', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'GAS CHECK') INSERT INTO tblTMWorkToDoItem (strToDoItem,ysnDefault) VALUES ('GAS CHECK', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'MARK THE LINE') INSERT INTO tblTMWorkToDoItem (strToDoItem,ysnDefault) VALUES ('MARK THE LINE', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'LABOR') INSERT INTO tblTMWorkToDoItem (strToDoItem,ysnDefault) VALUES ('LABOR', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'SET TANK') INSERT INTO tblTMWorkToDoItem (strToDoItem,ysnDefault) VALUES ('SET TANK', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkToDoItem WHERE strToDoItem = 'BURY LINE') INSERT INTO tblTMWorkToDoItem (strToDoItem,ysnDefault) VALUES ('BURY LINE', 1)
END

GO
	PRINT N'END INSERT DEFAULT TM WORK TODO ITEM'
GO