IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'apcbkmst')
	DROP VIEW apcbkmst

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC ('
		CREATE VIEW [dbo].apcbkmst
		AS 

		SELECT * FROM apcbkmst_origin
	')
END