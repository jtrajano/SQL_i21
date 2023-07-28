--liquibase formatted sql

-- changeset Von:vyuICGetCountGroup.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetCountGroup]
AS

SELECT 
	c.*
	,strCountWithGroup = countWithGroup.strCountGroup	
FROM
	tblICCountGroup c LEFT JOIN tblICCountGroup countWithGroup
		ON c.intCountWithGroupId = countWithGroup.intCountGroupId



