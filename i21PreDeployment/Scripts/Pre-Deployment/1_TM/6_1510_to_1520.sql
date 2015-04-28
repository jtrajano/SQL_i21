GO
PRINT N'BEGIN 15.10.x.x to 15.20.x.x'
GO

GO	
print N'BEGIN Update tblTMDevice remove dblTankSize column'
GO

IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = N'dblTankSize' AND Object_ID = Object_ID(N'tblTMDevice'))
BEGIN

	DECLARE @name NVARCHAR(MAX)
	SET @name = (SELECT TOP 1 name
				FROM sys.default_constraints
				WHERE object_id = (SELECT TOP 1 default_object_id 
									FROM sys.columns 
									WHERE name = N'dblTankSize' 
										AND Object_ID = Object_ID(N'tblTMDevice')))
	IF(ISNULL(@name,'') <> '')
	BEGIN
		EXEC ('ALTER TABLE tblTMDevice DROP CONSTRAINT ' +  @name)
	END									
    ALTER TABLE tblTMDevice DROP COLUMN dblTankSize 
END

GO
print N'END Update tblTMDevice remove dblTankSize column'
GO

GO
PRINT N'END 15.10.x.x to 15.20.x.x'
GO