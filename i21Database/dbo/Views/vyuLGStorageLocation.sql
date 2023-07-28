CREATE VIEW [dbo].[vyuLGStorageLocation]
AS
SELECT 
	CAST(ROW_NUMBER() OVER(ORDER BY strSubLocationName ASC) AS int) AS intTempId,
	strSubLocationName,
	0 AS intConcurrencyId
FROM tblSMCompanyLocationSubLocation 
GROUP BY strSubLocationName