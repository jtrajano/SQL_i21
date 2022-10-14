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

IF EXISTS(SELECT * FROM sys.columns WHERE name = 'intSupplyPointProductSearchHeaderId' AND object_id = OBJECT_ID('tblTRSupplyPointProductSearchHeader'))
	BEGIN
		exec('DELETE FROM tblTRSupplyPointProductSearchHeader
			WHERE intSupplyPointProductSearchHeaderId IN (
				SELECT intSupplyPointProductSearchHeaderId FROM (
					SELECT intRowNumber = ROW_NUMBER() OVER (PARTITION BY intItemId, intSupplyPointId ORDER BY intCount DESC, intSupplyPointProductSearchHeaderId ASC)
						, intSupplyPointProductSearchHeaderId
					FROM (
						SELECT sh.intSupplyPointProductSearchHeaderId
							, sh.intItemId
							, sh.intSupplyPointId
							, intCount = COUNT(*)
						FROM tblTRSupplyPointProductSearchHeader sh
						JOIN (
							SELECT intItemId, intSupplyPointId
							FROM tblTRSupplyPointProductSearchHeader
							GROUP BY intItemId, intSupplyPointId
							HAVING COUNT(*) > 1
						) tbl ON tbl.intItemId = sh.intItemId AND tbl.intSupplyPointId = sh.intSupplyPointId
						JOIN tblTRSupplyPointProductSearchDetail sd ON sd.intSupplyPointProductSearchHeaderId = sh.intSupplyPointProductSearchHeaderId
						GROUP BY sh.intSupplyPointProductSearchHeaderId
							, sh.intItemId
							, sh.intSupplyPointId
					) tbl
				) tbl WHERE tbl.intRowNumber <> 1)');
	END