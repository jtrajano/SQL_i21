CREATE VIEW [dbo].[vyuICGetCountGroup]
AS

SELECT 
	c.*
	,strCountWithGroup = countWithGroup.strCountGroup	
FROM
	tblICCountGroup c LEFT JOIN tblICCountGroup countWithGroup
		ON c.intCountWithGroupId = countWithGroup.intCountGroupId