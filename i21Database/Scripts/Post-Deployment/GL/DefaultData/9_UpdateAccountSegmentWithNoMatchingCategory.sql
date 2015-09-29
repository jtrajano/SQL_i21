GO
IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountSegment where intAccountCategoryId NOT IN (SELECT intAccountCategoryId FROM tblGLAccountCategory))
BEGIN
--not used in category and account table
	DECLARE @GeneralCategoryId INT
	SELECT @GeneralCategoryId = intAccountCategoryId FROM tblGLAccountCategory where strAccountCategory = 'General'
	UPDATE tblGLAccountSegment SET intAccountCategoryId = @GeneralCategoryId
	WHERE intAccountCategoryId NOT IN (SELECT intAccountCategoryId FROM tblGLAccountCategory)
	AND intAccountSegmentId NOT IN (SELECT intAccountSegmentId FROM tblGLAccountSegmentMapping)
--not used in category but used in account table
	UPDATE t SET intAccountCategoryId =(
	select TOP 1 intAccountCategoryId FROM tblGLAccount where intAccountId =
	 (SELECT TOP 1  intAccountId from tblGLAccountSegmentMapping WHERE intAccountSegmentId = t.intAccountSegmentId ))
	FROM tblGLAccountSegment t
	WHERE intAccountCategoryId NOT IN (SELECT intAccountCategoryId FROM tblGLAccountCategory)
	AND intAccountSegmentId IN (SELECT intAccountSegmentId FROM tblGLAccountSegmentMapping)
	
END
GO