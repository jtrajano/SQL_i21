
--=====================================================================================================================================
-- 	UPDATE FIELD CASING (ID to Id)
---------------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRCalculation]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCalculationId' AND OBJECT_ID = OBJECT_ID(N'tblFRCalculation')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCalculationID' AND OBJECT_ID = OBJECT_ID(N'tblFRCalculation'))
    BEGIN
        EXEC sp_rename 'tblFRCalculation.intCalculationID', 'intCalculationId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRCalculation]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intComponentId' AND OBJECT_ID = OBJECT_ID(N'tblFRCalculation')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intComponentID' AND OBJECT_ID = OBJECT_ID(N'tblFRCalculation'))
    BEGIN
        EXEC sp_rename 'tblFRCalculation.intComponentID', 'intComponentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRCalculationFormula]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCalculationFormulaId' AND OBJECT_ID = OBJECT_ID(N'tblFRCalculationFormula')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCalculationFormulaID' AND OBJECT_ID = OBJECT_ID(N'tblFRCalculationFormula'))
    BEGIN
        EXEC sp_rename 'tblFRCalculationFormula.intCalculationFormulaID', 'intCalculationFormulaId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRCalculationFormula]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnId' AND OBJECT_ID = OBJECT_ID(N'tblFRCalculationFormula')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnID' AND OBJECT_ID = OBJECT_ID(N'tblFRCalculationFormula'))
    BEGIN
        EXEC sp_rename 'tblFRCalculationFormula.intColumnID', 'intColumnId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRCalculationFormula]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowId' AND OBJECT_ID = OBJECT_ID(N'tblFRCalculationFormula')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowID' AND OBJECT_ID = OBJECT_ID(N'tblFRCalculationFormula'))
    BEGIN
        EXEC sp_rename 'tblFRCalculationFormula.intRowID', 'intRowId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRColumn]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumn')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnID' AND OBJECT_ID = OBJECT_ID(N'tblFRColumn'))
    BEGIN
        EXEC sp_rename 'tblFRColumn.intColumnID', 'intColumnId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRColumn]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumn')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowID' AND OBJECT_ID = OBJECT_ID(N'tblFRColumn'))
    BEGIN
        EXEC sp_rename 'tblFRColumn.intRowID', 'intRowId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRColumnDesign]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnDetailId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesign')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnDetailID' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesign'))
    BEGIN
        EXEC sp_rename 'tblFRColumnDesign.intColumnDetailID', 'intColumnDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRColumnDesign]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesign')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnID' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesign'))
    BEGIN
        EXEC sp_rename 'tblFRColumnDesign.intColumnID', 'intColumnId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRColumnDesignCalculation]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnCalculationId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignCalculation')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnCalculationID' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignCalculation'))
    BEGIN
        EXEC sp_rename 'tblFRColumnDesignCalculation.intColumnCalculationID', 'intColumnCalculationId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRColumnDesignCalculation]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignCalculation')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnID' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignCalculation'))
    BEGIN
        EXEC sp_rename 'tblFRColumnDesignCalculation.intColumnID', 'intColumnId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRColumnDesignCalculation]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRefNoId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignCalculation')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRefNoID' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignCalculation'))
    BEGIN
        EXEC sp_rename 'tblFRColumnDesignCalculation.intRefNoID', 'intRefNoId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRColumnDesignSegment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnSegmentId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignSegment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnSegmentID' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignSegment'))
    BEGIN
        EXEC sp_rename 'tblFRColumnDesignSegment.intColumnSegmentID', 'intColumnSegmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRColumnDesignSegment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignSegment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnID' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignSegment'))
    BEGIN
        EXEC sp_rename 'tblFRColumnDesignSegment.intColumnID', 'intColumnId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRConnection]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intConnectionId' AND OBJECT_ID = OBJECT_ID(N'tblFRConnection')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intConnectionID' AND OBJECT_ID = OBJECT_ID(N'tblFRConnection'))
    BEGIN
        EXEC sp_rename 'tblFRConnection.intConnectionID', 'intConnectionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRConnection]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblFRConnection')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblFRConnection'))
    BEGIN
        EXEC sp_rename 'tblFRConnection.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRConnection]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strUserId' AND OBJECT_ID = OBJECT_ID(N'tblFRConnection')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strUserID' AND OBJECT_ID = OBJECT_ID(N'tblFRConnection'))
    BEGIN
        EXEC sp_rename 'tblFRConnection.strUserID', 'strUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRGroupsDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGroupDetailId' AND OBJECT_ID = OBJECT_ID(N'tblFRGroupsDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGroupDetailID' AND OBJECT_ID = OBJECT_ID(N'tblFRGroupsDetail'))
    BEGIN
        EXEC sp_rename 'tblFRGroupsDetail.intGroupDetailID', 'intGroupDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRGroupsDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGroupId' AND OBJECT_ID = OBJECT_ID(N'tblFRGroupsDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGroupID' AND OBJECT_ID = OBJECT_ID(N'tblFRGroupsDetail'))
    BEGIN
        EXEC sp_rename 'tblFRGroupsDetail.intGroupID', 'intGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRGroupsDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intReportId' AND OBJECT_ID = OBJECT_ID(N'tblFRGroupsDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intReportID' AND OBJECT_ID = OBJECT_ID(N'tblFRGroupsDetail'))
    BEGIN
        EXEC sp_rename 'tblFRGroupsDetail.intReportID', 'intReportId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRHeader]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHeaderId' AND OBJECT_ID = OBJECT_ID(N'tblFRHeader')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHeaderID' AND OBJECT_ID = OBJECT_ID(N'tblFRHeader'))
    BEGIN
        EXEC sp_rename 'tblFRHeader.intHeaderID', 'intHeaderId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRHeader]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnId' AND OBJECT_ID = OBJECT_ID(N'tblFRHeader')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnID' AND OBJECT_ID = OBJECT_ID(N'tblFRHeader'))
    BEGIN
        EXEC sp_rename 'tblFRHeader.intColumnID', 'intColumnId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRHeaderDesign]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHeaderDetailId' AND OBJECT_ID = OBJECT_ID(N'tblFRHeaderDesign')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHeaderDetailID' AND OBJECT_ID = OBJECT_ID(N'tblFRHeaderDesign'))
    BEGIN
        EXEC sp_rename 'tblFRHeaderDesign.intHeaderDetailID', 'intHeaderDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRHeaderDesign]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHeaderId' AND OBJECT_ID = OBJECT_ID(N'tblFRHeaderDesign')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHeaderID' AND OBJECT_ID = OBJECT_ID(N'tblFRHeaderDesign'))
    BEGIN
        EXEC sp_rename 'tblFRHeaderDesign.intHeaderID', 'intHeaderId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRMapping]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMapId' AND OBJECT_ID = OBJECT_ID(N'tblFRMapping')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMapID' AND OBJECT_ID = OBJECT_ID(N'tblFRMapping'))
    BEGIN
        EXEC sp_rename 'tblFRMapping.intMapID', 'intMapId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRMapping]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intConnectionId' AND OBJECT_ID = OBJECT_ID(N'tblFRMapping')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intConnectionID' AND OBJECT_ID = OBJECT_ID(N'tblFRMapping'))
    BEGIN
        EXEC sp_rename 'tblFRMapping.intConnectionID', 'intConnectionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRReport]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intReportId' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intReportID' AND OBJECT_ID = OBJECT_ID(N'tblFRReport'))
    BEGIN
        EXEC sp_rename 'tblFRReport.intReportID', 'intReportId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRReport]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPageFooterId' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPageFooterID' AND OBJECT_ID = OBJECT_ID(N'tblFRReport'))
    BEGIN
        EXEC sp_rename 'tblFRReport.intPageFooterID', 'intPageFooterId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRReport]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPageHeaderId' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPageHeaderID' AND OBJECT_ID = OBJECT_ID(N'tblFRReport'))
    BEGIN
        EXEC sp_rename 'tblFRReport.intPageHeaderID', 'intPageHeaderId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRReport]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intReportFooterId' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intReportFooterID' AND OBJECT_ID = OBJECT_ID(N'tblFRReport'))
    BEGIN
        EXEC sp_rename 'tblFRReport.intReportFooterID', 'intReportFooterId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRReport]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intReportHeaderId' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intReportHeaderID' AND OBJECT_ID = OBJECT_ID(N'tblFRReport'))
    BEGIN
        EXEC sp_rename 'tblFRReport.intReportHeaderID', 'intReportHeaderId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRReport]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowId' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowID' AND OBJECT_ID = OBJECT_ID(N'tblFRReport'))
    BEGIN
        EXEC sp_rename 'tblFRReport.intRowID', 'intRowId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRReport]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnId' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intColumnID' AND OBJECT_ID = OBJECT_ID(N'tblFRReport'))
    BEGIN
        EXEC sp_rename 'tblFRReport.intColumnID', 'intColumnId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRReport]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMapId' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMapID' AND OBJECT_ID = OBJECT_ID(N'tblFRReport'))
    BEGIN
        EXEC sp_rename 'tblFRReport.intMapID', 'intMapId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRRow]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowId' AND OBJECT_ID = OBJECT_ID(N'tblFRRow')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowID' AND OBJECT_ID = OBJECT_ID(N'tblFRRow'))
    BEGIN
        EXEC sp_rename 'tblFRRow.intRowID', 'intRowId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRRow]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMapId' AND OBJECT_ID = OBJECT_ID(N'tblFRRow')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMapID' AND OBJECT_ID = OBJECT_ID(N'tblFRRow'))
    BEGIN
        EXEC sp_rename 'tblFRRow.intMapID', 'intMapId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRRowDesign]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowDetailId' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesign')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowDetailID' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesign'))
    BEGIN
        EXEC sp_rename 'tblFRRowDesign.intRowDetailID', 'intRowDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRRowDesign]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowId' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesign')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowID' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesign'))
    BEGIN
        EXEC sp_rename 'tblFRRowDesign.intRowID', 'intRowId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRRowDesignCalculation]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowCalculationId' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignCalculation')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowCalculationID' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignCalculation'))
    BEGIN
        EXEC sp_rename 'tblFRRowDesignCalculation.intRowCalculationID', 'intRowCalculationId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRRowDesignCalculation]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowId' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignCalculation')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowID' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignCalculation'))
    BEGIN
        EXEC sp_rename 'tblFRRowDesignCalculation.intRowID', 'intRowId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRRowDesignCalculation]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRefNoId' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignCalculation')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRefNoID' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignCalculation'))
    BEGIN
        EXEC sp_rename 'tblFRRowDesignCalculation.intRefNoID', 'intRefNoId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRRowDesignFilterAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowFilterAccountId' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignFilterAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowFilterAccountID' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignFilterAccount'))
    BEGIN
        EXEC sp_rename 'tblFRRowDesignFilterAccount.intRowFilterAccountID', 'intRowFilterAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRRowDesignFilterAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowId' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignFilterAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRowID' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignFilterAccount'))
    BEGIN
        EXEC sp_rename 'tblFRRowDesignFilterAccount.intRowID', 'intRowId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRRowDesignFilterAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRefNoId' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignFilterAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRefNoID' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignFilterAccount'))
    BEGIN
        EXEC sp_rename 'tblFRRowDesignFilterAccount.intRefNoID', 'intRefNoId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRSegmentFilterGroup]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSegmentFilterGroupId' AND OBJECT_ID = OBJECT_ID(N'tblFRSegmentFilterGroup')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSegmentFilterGroupID' AND OBJECT_ID = OBJECT_ID(N'tblFRSegmentFilterGroup'))
    BEGIN
        EXEC sp_rename 'tblFRSegmentFilterGroup.intSegmentFilterGroupID', 'intSegmentFilterGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRSegmentFilterGroupDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSegmentFilterGroupDetailId' AND OBJECT_ID = OBJECT_ID(N'tblFRSegmentFilterGroupDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSegmentFilterGroupDetailID' AND OBJECT_ID = OBJECT_ID(N'tblFRSegmentFilterGroupDetail'))
    BEGIN
        EXEC sp_rename 'tblFRSegmentFilterGroupDetail.intSegmentFilterGroupDetailID', 'intSegmentFilterGroupDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRSegmentFilterGroupDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSegmentFilterGroupId' AND OBJECT_ID = OBJECT_ID(N'tblFRSegmentFilterGroupDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSegmentFilterGroupID' AND OBJECT_ID = OBJECT_ID(N'tblFRSegmentFilterGroupDetail'))
    BEGIN
        EXEC sp_rename 'tblFRSegmentFilterGroupDetail.intSegmentFilterGroupID', 'intSegmentFilterGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRMappingDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMapDetailId' AND OBJECT_ID = OBJECT_ID(N'tblFRMappingDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMapDetailID' AND OBJECT_ID = OBJECT_ID(N'tblFRMappingDetail'))
    BEGIN
        EXEC sp_rename 'tblFRMappingDetail.intMapDetailID', 'intMapDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRMappingDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMapId' AND OBJECT_ID = OBJECT_ID(N'tblFRMappingDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMapID' AND OBJECT_ID = OBJECT_ID(N'tblFRMappingDetail'))
    BEGIN
        EXEC sp_rename 'tblFRMappingDetail.intMapID', 'intMapId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFREmailFinancial]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intEmailFinancialId' AND OBJECT_ID = OBJECT_ID(N'tblFREmailFinancial')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intEmailFinancialID' AND OBJECT_ID = OBJECT_ID(N'tblFREmailFinancial'))
    BEGIN
        EXEC sp_rename 'tblFREmailFinancial.intEmailFinancialID', 'intEmailFinancialId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFREmailFinancial]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strContactId' AND OBJECT_ID = OBJECT_ID(N'tblFREmailFinancial')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strContactID' AND OBJECT_ID = OBJECT_ID(N'tblFREmailFinancial'))
    BEGIN
        EXEC sp_rename 'tblFREmailFinancial.strContactID', 'strContactId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRGroupOtherReport]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGroupOtherReportId' AND OBJECT_ID = OBJECT_ID(N'tblFRGroupOtherReport')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGroupOtherReportID' AND OBJECT_ID = OBJECT_ID(N'tblFRGroupOtherReport'))
    BEGIN
        EXEC sp_rename 'tblFRGroupOtherReport.intGroupOtherReportID', 'intGroupOtherReportId' , 'COLUMN'
    END
END
GO