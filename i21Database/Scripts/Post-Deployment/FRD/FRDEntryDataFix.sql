
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

UPDATE tblFRRowDesignCalculation 
	SET intRowDetailId = (SELECT intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignCalculation.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignCalculation.intRefNoId),
		intRowDetailRefNo = (SELECT intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignCalculation.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignCalculation.intRefNoCalc)

UPDATE tblFRRowDesignFilterAccount 
	SET intRowDetailId = (SELECT intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignFilterAccount.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignFilterAccount.intRefNoId)

UPDATE tblFRColumnDesignCalculation 
	SET intColumnDetailId = (SELECT intColumnDetailId FROM tblFRColumnDesign WHERE tblFRColumnDesign.intColumnId = tblFRColumnDesignCalculation.intColumnId and tblFRColumnDesign.intRefNo = tblFRColumnDesignCalculation.intRefNoId),
		intColumnDetailRefNo = (SELECT intColumnDetailId FROM tblFRColumnDesign WHERE tblFRColumnDesign.intColumnId = tblFRColumnDesignCalculation.intColumnId and tblFRColumnDesign.intRefNo = tblFRColumnDesignCalculation.intRefNoCalc)

UPDATE tblFRColumnDesignSegment 
	SET intColumnDetailId = (SELECT intColumnDetailId FROM tblFRColumnDesign WHERE tblFRColumnDesign.intColumnId = tblFRColumnDesignSegment.intColumnId and tblFRColumnDesign.intRefNo = tblFRColumnDesignSegment.intRefNo)
