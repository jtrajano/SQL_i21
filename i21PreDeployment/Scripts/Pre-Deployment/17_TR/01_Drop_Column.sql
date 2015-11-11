GO
PRINT 'BEGIN Drop column strTerminalNumber'
GO
IF EXISTS(SELECT * FROM sys.columns WHERE name = 'strTerminalNumber' AND object_id = OBJECT_ID('tblTRSupplyPoint'))
	BEGIN
		EXEC ('
			ALTER TABLE tblTRSupplyPoint
			DROP COLUMN strTerminalNumber
		')
	END
