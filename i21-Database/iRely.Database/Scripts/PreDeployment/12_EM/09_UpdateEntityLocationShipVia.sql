declare @build_m int
set @build_m = 0

if EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMBuildNumber' and [COLUMN_NAME] = 'strVersionNo')
BEGIN

	exec sp_executesql N'select top 1 @build_m = intVersionID from tblSMBuildNumber where cast(substring(strVersionNo,1,2) as float) >= 16 '  , 
		N'@build_m int output', @build_m output;
END

if @build_m = 0

BEGIN


	PRINT '*** Checking for ship via  ***'
	IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intShipViaID' and object_id = OBJECT_ID(N'tblSMShipVia')))
	BEGIN
		PRINT '*** Update location shipviaid via intShipViaID ***'
		EXEC('
			UPDATE A
				SET A.intShipViaId = ISNULL(B.intEntityShipViaId, A.intShipViaId)
			FROM tblEMEntityLocation A
				INNER JOIN tblSMShipVia B ON A.intShipViaId = B.intShipViaID
			')	
	END
	ELSE
	BEGIN
		print '*** Check for orphan ship via id for Entity Location ***'
		IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intEntityShipViaId' and object_id = OBJECT_ID(N'tblSMShipVia')))
		BEGIN
			print '*** remove the orphan ***'
			EXEC('
				UPDATE A
					SET A.intShipViaId = NULL
				FROM tblEMEntityLocation A
				WHERE A.intShipViaId NOT IN (SELECT intEntityShipViaId FROM tblSMShipVia)
			')
		END
		
	END
END
GO