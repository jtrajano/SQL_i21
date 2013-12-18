IF EXISTS (SELECT TOP 1 1 FROM sys.views WHERE name = 'vwCMBank')
	DROP VIEW [dbo].vwCMBank
GO

CREATE VIEW [dbo].vwCMBank
AS 

SELECT * FROM tblCMBank

GO 