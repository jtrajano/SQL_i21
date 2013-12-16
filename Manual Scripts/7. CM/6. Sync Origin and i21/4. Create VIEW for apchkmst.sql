
IF EXISTS (SELECT TOP 1 1 FROM sys.views WHERE name = 'apchkmst')
	DROP VIEW [dbo].apchkmst
GO

CREATE VIEW [dbo].apchkmst
AS 

SELECT * FROM apchkmsti21fied
GO 