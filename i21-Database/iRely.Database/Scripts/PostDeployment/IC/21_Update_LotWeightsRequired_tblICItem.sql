
DECLARE @Count INT = 0
SELECT @Count = COUNT([object_id]) FROM sys.tables WHERE object_id = object_id('tblICItem')

IF @Count = 1
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name  = N'ysnLotWeightsRequired' AND object_id = OBJECT_ID(N'tblICItem'))
	BEGIN
		EXEC('UPDATE tblICItem SET ysnLotWeightsRequired = 1 WHERE ysnLotWeightsRequired IS NULL AND strLotTracking <> ''No''')
	END
END