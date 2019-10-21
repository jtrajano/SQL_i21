/*
	Delete the records from the backup table. Keep only the last 5 backup ids.
*/
CREATE PROCEDURE [dbo].[uspICRebuildCleanUp]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SET NOCOUNT OFF

DECLARE @intLoop AS INT = 1
WHILE (@intLoop > 0) 
BEGIN 
	BEGIN TRANSACTION 

	DELETE TOP (10000) t 
	FROM 
		tblICBackupDetailInventoryTransaction t 
	WHERE
		t.intBackupId NOT IN (
			SELECT TOP 5 b.intBackupId FROM tblICBackup b ORDER BY b.intBackupId DESC 
		)

	SET @intLoop = @@ROWCOUNT

	COMMIT TRANSACTION 
	CHECKPOINT 
END 