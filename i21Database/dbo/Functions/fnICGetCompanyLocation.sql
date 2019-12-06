CREATE FUNCTION [dbo].[fnICGetCompanyLocation] (
	@intItemLocationId AS INT = NULL
	,@intInTransitSourceLocationId AS INT = NULL
)
RETURNS TABLE 
AS 

RETURN 

SELECT 
	intCompanyLocationId = ISNULL(inTransit.intCompanyLocationId, itemLocation.intCompanyLocationId) 
FROM (
		SELECT TOP 1 
			[Location].intCompanyLocationId
		FROM 
			tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation [Location] 
				ON [Location].intCompanyLocationId = ItemLocation.intLocationId	
		WHERE
			ItemLocation.intItemLocationId = @intItemLocationId
	) itemLocation 
	FULL OUTER JOIN (
		SELECT TOP 1 
			[Location].intCompanyLocationId
		FROM
			tblICItemLocation InTransitItemLocation INNER JOIN tblSMCompanyLocation [Location] 
				ON [Location].intCompanyLocationId = InTransitItemLocation.intLocationId	
		WHERE 	
			InTransitItemLocation.intItemLocationId = @intInTransitSourceLocationId		
	) inTransit
		ON 1 = 1