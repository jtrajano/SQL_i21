
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
-- 	UPDATE DATA TYPES

-- FIELD MAPPING

---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN UPDATE DATA TYPES'
GO

UPDATE tblFRRowDesignCalculation 
	SET intRowDetailId = (SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignCalculation.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignCalculation.intRefNoId),
		intRowDetailRefNo = (SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignCalculation.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignCalculation.intRefNoCalc)
	WHERE intRowDetailId IS NULL

GO
	PRINT N'END UPDATE DATA TYPES'
GO


