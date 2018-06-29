GO
PRINT 'BEGIN Drop column strTerminalNumber'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.key_constraints WHERE object_id = OBJECT_ID(N'[dbo].[AK_tblTRSupplyPoint]'))
BEGIN
    ALTER TABLE [dbo].[tblTRSupplyPoint] 
    DROP CONSTRAINT [AK_tblTRSupplyPoint]
END


IF EXISTS(SELECT * FROM sys.columns WHERE name = 'strTerminalNumber' AND object_id = OBJECT_ID('tblTRSupplyPoint'))
	BEGIN
		EXEC ('
			ALTER TABLE tblTRSupplyPoint
			DROP COLUMN strTerminalNumber
		')
	END

IF EXISTS(SELECT * FROM sys.columns WHERE name = 'intTaxGroupId' AND object_id = OBJECT_ID('tblTRSupplyPoint'))
	BEGIN
		exec('alter table tblTRSupplyPoint alter column intTaxGroupId int null');
	END
