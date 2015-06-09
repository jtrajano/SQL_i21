CREATE PROCEDURE [dbo].[uspGLUpdateSegmentCategory]
AS
PRINT 'START UPDATING ACCOUNT SEGMENT CATEGORY ID'
DECLARE @segmentId INT
DECLARE segment_cursor CURSOR FOR 
SELECT s.intAccountSegmentId
FROM tblGLAccountSegment s join tblGLAccountSegmentMapping m on s.intAccountSegmentId = m.intAccountSegmentId
JOIN tblGLAccountStructure u on s.intAccountStructureId = u.intAccountStructureId where u.strType= 'Primary'
GROUP BY s.intAccountSegmentId
ORDER BY s.intAccountSegmentId
OPEN segment_cursor
FETCH NEXT FROM segment_cursor INTO @segmentId
WHILE @@FETCH_STATUS = 0
BEGIN
;WITH accountCat(intAccountCategoryId, intAccountSegmentId)
	AS
	(
		SELECT a.intAccountCategoryId,s.intAccountSegmentId from tblGLAccount a join 
		tblGLAccountSegmentMapping m on a.intAccountId = m.intAccountId join
		tblGLAccountSegment s on m.intAccountSegmentId = s.intAccountSegmentId join
		tblGLAccountStructure u on s.intAccountStructureId = u.intAccountStructureId
		WHERE u.strType = 'Primary' 
		GROUP BY  a.intAccountCategoryId,s.intAccountSegmentId
	)
	UPDATE tblGLAccountSegment SET intAccountCategoryId = 
	(SELECT TOP 1 intAccountCategoryId FROM accountCat	WHERE intAccountSegmentId = @segmentId)
	WHERE intAccountSegmentId = @segmentId
FETCH NEXT FROM segment_cursor INTO @segmentId
END
CLOSE segment_cursor;
DEALLOCATE segment_cursor;
PRINT 'COMPLETED UPDATING ACCOUNT SEGMENT CATEGORY IDS'