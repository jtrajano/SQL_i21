
IF EXISTS (SELECT TOP 1 1 FROM sys.views WHERE name = 'apcbkmst')
	DROP VIEW [dbo].apcbkmst
GO

CREATE VIEW [dbo].apcbkmst
AS 

SELECT * FROM apcbkmsti21fied
GO 