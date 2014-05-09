GO
	PRINT N'BEGIN INSERT DEFAULT TM EVENT TYPE'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMEventType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-001' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-001','Consumption Site Activated', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-002' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-002','Consumption Site Deactivated', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-003' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-003','Consumption Site Gas Checked', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-004' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-004','Consumption Site Leak Checked', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-005' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-005','Consumption Site Reassigned ', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-006' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-006','Device At Customer to be Picked up and Transferred', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-007' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-007','Device Deleted from Consumption Site', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-008' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-008','Device Detached from Consumption Site', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-009' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-009','Device Installed', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-010' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-010','Device Painted', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-011' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-011','Device Picked up and Transferred', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-012' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-012','Device Pick up and Transfer Cancelled', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-013' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-013','Device Repair Note', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-014' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-014','Device Sold', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-015' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-015','Device Transferred to Another Consumption Site', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-016' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-016','General Comment', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-017' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-017','Consumption Site Taken Off Hold', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-018' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-018','Consumption Site Put On Hold', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-021' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-021','Tank Monitor Reading', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-020' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-020','Device Lease Billed', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMEventType WHERE strEventType = 'Event-022' AND ysnDefault = 1) INSERT INTO tblTMEventType (strEventType,strDescription,ysnDefault) VALUES ('Event-022','Season Change', 1)
	
END

GO
	PRINT N'END INSERT DEFAULT TM EVENT TYPE'
GO