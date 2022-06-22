GO
	PRINT N'BEGIN INSERT DEFAULT TM FILL METHOD TYPE'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMFillMethod]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMFillMethod WHERE strFillMethod = 'Julian Calendar') 
	BEGIN
		INSERT INTO tblTMFillMethod (strFillMethod,ysnDefault) VALUES ('Julian Calendar',1)
	END
	ELSE
	BEGIN
		UPDATE tblTMFillMethod SET strFillMethod = 'Julian Calendar', ysnDefault = 1 WHERE strFillMethod = 'Julian Calendar'
	END
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMFillMethod WHERE strFillMethod = 'Will Call') 
	BEGIN
		INSERT INTO tblTMFillMethod (strFillMethod,ysnDefault) VALUES ('Will Call',1)
	END
	ELSE
	BEGIN
		UPDATE tblTMFillMethod SET strFillMethod = 'Will Call', ysnDefault = 1 WHERE strFillMethod = 'Will Call'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMFillMethod WHERE strFillMethod = 'Keep Full') 
	BEGIN
		INSERT INTO tblTMFillMethod (strFillMethod,ysnDefault) VALUES ('Keep Full',1)
	END
	ELSE
	BEGIN
		UPDATE tblTMFillMethod SET strFillMethod = 'Keep Full', ysnDefault = 1 WHERE strFillMethod = 'Keep Full'
	END

END

GO
	PRINT N'END INSERT DEFAULT TM FILL METHOD TYPE'
GO