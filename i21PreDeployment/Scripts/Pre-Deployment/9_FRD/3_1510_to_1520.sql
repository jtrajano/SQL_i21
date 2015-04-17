GO
	PRINT 'BEGIN FRD UPDATE SEGMENT CODE'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSegmentFilterGroupId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesign')) 
BEGIN

	UPDATE tblFRColumnDesign SET intSegmentFilterGroupId = NULL WHERE intSegmentFilterGroupId NOT IN (SELECT intSegmentFilterGroupId FROM tblFRSegmentFilterGroup) AND intSegmentFilterGroupId IS NOT NULL

END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSegmentCode' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) 
BEGIN

	UPDATE tblFRReport SET intSegmentCode = NULL WHERE intSegmentCode NOT IN (SELECT intSegmentFilterGroupId FROM tblFRSegmentFilterGroup) AND intSegmentCode IS NOT NULL

END
GO

GO
	PRINT 'END FRD UPDATE SEGMENT CODE'
GO