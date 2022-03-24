CREATE VIEW [dbo].[vyuICGetStoreLocation]
AS

SELECT 
	intCompanyLocationId = CAST(-1 AS INT)
	,strLocationName = CAST('All Locations' AS NVARCHAR(50)) 
WHERE 
	EXISTS  (
		SELECT COUNT(1) 
		FROM 
			tblSTStore ss INNER JOIN tblSMCompanyLocation cl 
				ON ss.intCompanyLocationId = cl.intCompanyLocationId 
		HAVING 
			COUNT(1) > 1
	)

UNION ALL 
	
SELECT 
	cl.intCompanyLocationId
	,cl.strLocationName
FROM 
	tblSTStore ss INNER JOIN tblSMCompanyLocation cl  
		ON ss.intCompanyLocationId = cl.intCompanyLocationId