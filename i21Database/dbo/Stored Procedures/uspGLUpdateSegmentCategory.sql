--Author		: Trajano, Jeffrey	
--Description	: UPDATES THE tblGLAccountSegment based on the Chart Of Accounts
--Date			: June 9, 2015 
--Version		: 15.3
CREATE PROCEDURE [dbo].[uspGLUpdateSegmentCategory]
AS
PRINT 'START UPDATING ACCOUNT SEGMENT CATEGORY ID'
DECLARE @generalCategoryId INT
SELECT @generalCategoryId = intAccountCategoryId  FROM tblGLAccountCategory WHERE strAccountCategory = 'General'
;WITH categories(segmentId,categoryId)as
(
	SELECT s.intAccountSegmentId, a.intAccountCategoryId from tblGLAccount a join 
	tblGLAccountSegmentMapping m on a.intAccountId = m.intAccountId join
	tblGLAccountSegment s on m.intAccountSegmentId = s.intAccountSegmentId join
	tblGLAccountStructure u on s.intAccountStructureId = u.intAccountStructureId
	WHERE u.strType = 'Primary' and a.intAccountCategoryId <> @generalCategoryId
	GROUP BY  a.intAccountCategoryId,s.intAccountSegmentId
)
UPDATE s SET intAccountCategoryId = c.categoryId
FROM tblGLAccountSegment s
JOIN categories c
on s.intAccountSegmentId = c.segmentId
PRINT 'COMPLETED UPDATING ACCOUNT SEGMENT CATEGORY IDS'