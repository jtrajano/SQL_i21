/*
* Adds data to tblPREmployeeEarningDistribution table based on the currently 
* selected Expense Account for each Earning, if none exists. This table must
* always have at least 1 row for each Employee Earning Id
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPREmployeeEarningDistribution'))
BEGIN
	EXEC ('
	INSERT INTO tblPREmployeeEarningDistribution 
	(intEmployeeEarningId
	,intExpenseSegmentId
	,intLocation
	,dblPercentage
	,intConcurrencyId)
	SELECT 
	tblPREmployeeEarning.intEmployeeEarningId
	,tblSegmentMapping.intSegmentPrimaryId
	,tblSegmentMapping.intSegmentLocationId
	,100
	,1
	FROM tblPREmployeeEarning
	INNER JOIN (
		SELECT tblPrimary.intAccountId, intSegmentPrimaryId, intSegmentLocationId FROM
			(SELECT intAccountId, intSegmentPrimaryId = A.intAccountSegmentId 
				FROM tblGLAccountSegmentMapping A INNER JOIN tblGLAccountSegment B ON A.intAccountSegmentId = B.intAccountSegmentId 
				WHERE intAccountStructureId = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strStructureName = ''Primary Account'' AND strType = ''Primary'')) tblPrimary
			INNER JOIN
			(SELECT intAccountId, intSegmentLocationId = A.intAccountSegmentId 
				FROM tblGLAccountSegmentMapping A INNER JOIN tblGLAccountSegment B ON A.intAccountSegmentId = B.intAccountSegmentId 
				WHERE intAccountStructureId = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strStructureName = ''Location'' AND strType = ''Segment'')) tblLocation
		ON tblPrimary.intAccountId = tblLocation.intAccountId
	) tblSegmentMapping
	ON tblPREmployeeEarning.intAccountId = tblSegmentMapping.intAccountId
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblPREmployeeEarningDistribution WHERE intEmployeeEarningId = tblPREmployeeEarning.intEmployeeEarningId)
	')
END