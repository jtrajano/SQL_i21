
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