PRINT '*** Checking for ship via  ***'
IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intShipViaID' and object_id = OBJECT_ID(N'tblSMShipVia')))
BEGIN
	PRINT '*** Update location shipviaid via intShipViaID ***'
	EXEC('
		UPDATE A
			SET A.intShipViaId = ISNULL(B.intEntityShipViaId, A.intShipViaId)
		FROM tblEntityLocation A
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
			FROM tblEntityLocation A
			WHERE A.intShipViaId NOT IN (SELECT intEntityShipViaId FROM tblSMShipVia)
		')
	END
		
END