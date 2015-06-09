﻿
--=====================================================================================================================================
-- 	UPDATE NEW FORIEGN KEYS

-- FIELD MAPPING
	-- tblRowDesignCalculation
		-- intRefNoId			=	intRowDetailId
		-- intRefNoCalc			=	intRowDetailRefNo
		-- intRowId
	-- tblFRRowDesignFilterAccount
		-- intRowDetailId		=	intRowDetailId
	-- tblColumnDesignCalculation
		-- intRefNoId			=	intColumnDetailId
		-- intRefNoCalc			=	intColumnDetailRefNo
		-- intColumnId
	-- tblFRColumnDesignSegment
		-- intColumnDetailId	=	intColumnDetailId
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN UPDATE NEW FORIEGN KEYS'
GO

UPDATE tblFRRowDesignCalculation 
	SET intRowDetailId = (SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignCalculation.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignCalculation.intRefNoId),
		intRowDetailRefNo = (SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignCalculation.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignCalculation.intRefNoCalc)
	WHERE intRowDetailId IS NULL

UPDATE tblFRRowDesignFilterAccount 
	SET intRowDetailId = (SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignFilterAccount.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignFilterAccount.intRefNoId)
	WHERE intRowDetailId IS NULL

UPDATE tblFRColumnDesignCalculation 
	SET intColumnDetailId = (SELECT TOP 1 intColumnDetailId FROM tblFRColumnDesign WHERE tblFRColumnDesign.intColumnId = tblFRColumnDesignCalculation.intColumnId and tblFRColumnDesign.intRefNo = tblFRColumnDesignCalculation.intRefNoId),
		intColumnDetailRefNo = (SELECT TOP 1 intColumnDetailId FROM tblFRColumnDesign WHERE tblFRColumnDesign.intColumnId = tblFRColumnDesignCalculation.intColumnId and tblFRColumnDesign.intRefNo = tblFRColumnDesignCalculation.intRefNoCalc)
	WHERE intColumnDetailId IS NULL

UPDATE tblFRColumnDesignSegment 
	SET intColumnDetailId = (SELECT TOP 1 intColumnDetailId FROM tblFRColumnDesign WHERE tblFRColumnDesign.intColumnId = tblFRColumnDesignSegment.intColumnId and tblFRColumnDesign.intRefNo = tblFRColumnDesignSegment.intRefNo)
	WHERE intColumnDetailId IS NULL

GO
	PRINT N'END UPDATE NEW FORIEGN KEYS'
GO


--=====================================================================================================================================
-- 	RENAME COLUMN HEADER AND COLUMN DESCRIPTION TO COLUMN NAME
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN RENAME'
GO

UPDATE tblFRRowDesign SET strRowType = 'Column Name' WHERE strRowType = 'Description Title'
UPDATE tblFRRowDesign SET strRowType = 'Row Name - Center Align' WHERE strRowType = 'Center Title'
UPDATE tblFRRowDesign SET strRowType = 'Row Name - Left Align' WHERE strRowType = 'Left Title'
UPDATE tblFRRowDesign SET strRowType = 'Row Name - Right Align' WHERE strRowType = 'Right Title'
UPDATE tblFRColumnDesign SET strColumnType = 'Row Name' WHERE strColumnType = 'Row Description'
UPDATE tblFRColumnDesign SET strColumnCaption = 'Column Name' WHERE strColumnCaption = 'Column Header'

GO
	PRINT N'END RENAME'
GO


--=====================================================================================================================================
-- 	REMOVE BALANCE SIDE FOR NON-CALCULATION TYPES
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN REMOVE'
GO

UPDATE tblFRRowDesign SET strBalanceSide = '' 
	WHERE strRowType NOT IN ('Calculation','Hidden','Cash Flow Activity','Filter Accounts') AND strBalanceSide <> ''

GO
	PRINT N'END REMOVE'
GO


--=====================================================================================================================================
-- 	RENAME ROW TYPES
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN RENAME ROW TYPES'
GO

UPDATE tblFRRowDesign SET strRowType = 'Filter Accounts' WHERE strRowType = 'Calculation'
UPDATE tblFRRowDesign SET strRowType = 'Row Calculation' WHERE strRowType like '%Total Calculation%'

GO
	PRINT N'END RENAME ROW TYPES'
GO


--=====================================================================================================================================
-- 	DROP TABLE tblFRGroupsDetail
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN DROP TABLE tblFRGroupsDetail'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRGroupsDetail]') AND type in (N'U')) 
BEGIN
	DROP TABLE tblFRGroupsDetail
END

GO
	PRINT N'END DROP TABLE tblFRGroupsDetail'
GO


--=====================================================================================================================================
-- 	SET DEFAULT VALUE FOR NEW FIELD
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN SET VALUE'
GO

UPDATE tblFRRowDesign SET strSource = '' 
	WHERE strRowType NOT IN ('Calculation','Hidden','Cash Flow Activity','Filter Accounts') AND strSource IS NULL

UPDATE tblFRRowDesign SET strSource = 'Column' 
	WHERE strRowType IN ('Calculation','Hidden','Cash Flow Activity','Filter Accounts') AND strSource IS NULL

GO
	PRINT N'END SET VALUE'
GO


--=====================================================================================================================================
-- 	RENAME COLUMN TYPE
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN RENAME COLUMN TYPE'
GO

UPDATE tblFRColumnDesign SET strColumnType = 'GL Amounts' 
	WHERE strColumnType IN ('Calculation','Segment Filter')

GO
	PRINT N'END RENAME COLUMN TYPE'
GO


--=====================================================================================================================================
-- 	RENAME REPORT TYPE
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN RENAME REPORT TYPE'
GO

UPDATE tblFRReport SET strReportType = 'Single' 
	WHERE strReportType = 'Report'

GO
	PRINT N'END RENAME REPORT TYPE'
GO


--=====================================================================================================================================
-- 	FIX: NULL value to EMPTY String
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN NULL TO EMPTY STRING'
GO

UPDATE tblFRRowDesign SET strDescription = '' 
	WHERE strDescription IS NULL
UPDATE tblFRRowDesign SET strBalanceSide = '' 
	WHERE strBalanceSide IS NULL
UPDATE tblFRRowDesign SET strRelatedRows = '' 
	WHERE strRelatedRows IS NULL
UPDATE tblFRRowDesign SET strAccountsUsed = '' 
	WHERE strAccountsUsed IS NULL

GO
	PRINT N'END NULL TO EMPTY STRING'
GO


--=====================================================================================================================================
-- 	FIX: RELATIONSHIP TO SEGMENT FILTER ID
---------------------------------------------------------------------------------------------------------------------------------------

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


--=====================================================================================================================================
-- 	FIX: NULL value to EMPTY String
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN NULL TO EMPTY STRING'
GO

UPDATE tblFRRowDesign SET strDescription = '' 
	WHERE strDescription IS NULL
UPDATE tblFRRowDesign SET strBalanceSide = '' 
	WHERE strBalanceSide IS NULL
UPDATE tblFRRowDesign SET strRelatedRows = '' 
	WHERE strRelatedRows IS NULL
UPDATE tblFRRowDesign SET strAccountsUsed = '' 
	WHERE strAccountsUsed IS NULL

GO
	PRINT N'END NULL TO EMPTY STRING'
GO


--=====================================================================================================================================
-- 	FIX: ORPHAN(NULL) ID
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN FIX ORPHAN(NULL) ID'
GO

UPDATE tblFRRowDesignCalculation 
	SET intRowDetailRefNo = (SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE 
			tblFRRowDesign.intRowId = (SELECT TOP 1 intRowId FROM tblFRRowDesign B WHERE B.intRowDetailId =tblFRRowDesignCalculation.intRowDetailId) 
				and tblFRRowDesign.intRefNo = tblFRRowDesignCalculation.intRefNoCalc)
		WHERE intRowDetailRefNo IS NULL

GO
	PRINT N'END FIX ORPHAN(NULL) ID'
GO
