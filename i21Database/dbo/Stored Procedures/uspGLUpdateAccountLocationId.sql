CREATE PROCEDURE uspGLUpdateAccountLocationId
AS
UPDATE A set intLocationSegmentId = S.intAccountSegmentId FROM tblGLAccount A JOIN tblGLAccountSegmentMapping M on A.intAccountId = M.intAccountId
JOIN tblGLAccountSegment S ON S.intAccountSegmentId = M.intAccountSegmentId
JOIN tblGLAccountStructure ST ON ST.intAccountStructureId =  S.intAccountStructureId
JOIN tblGLSegmentType SMT ON SMT.intSegmentTypeId = ST.intStructureType
WHERE strSegmentType = 'Location'
AND intLocationSegmentId IS NULL

IF EXISTS(SELECT 1 FROM tblGLAccountStructure WHERE intStructureType = 6)
BEGIN
	-- Update Company Location
	UPDATE A set A.intCompanySegmentId = S.intAccountSegmentId FROM tblGLAccount A JOIN tblGLAccountSegmentMapping M on A.intAccountId = M.intAccountId
	JOIN tblGLAccountSegment S ON S.intAccountSegmentId = M.intAccountSegmentId
	JOIN tblGLAccountStructure ST ON ST.intAccountStructureId =  S.intAccountStructureId
	JOIN tblGLSegmentType SMT ON SMT.intSegmentTypeId = ST.intStructureType
	WHERE strSegmentType = 'Company'
	AND intCompanySegmentId IS NULL

	EXEC uspGLGenerateAccountStructureWithMaskedPrimaryAndCompany
END