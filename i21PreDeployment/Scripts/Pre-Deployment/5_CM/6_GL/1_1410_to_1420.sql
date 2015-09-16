
--=====================================================================================================================================
-- 	UPDATE FIELD CASING (ID to Id)
---------------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount'))
    BEGIN
        EXEC sp_rename 'tblGLAccount.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount'))
    BEGIN
        EXEC sp_rename 'tblGLAccount.strAccountID', 'strAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount'))
    BEGIN
        EXEC sp_rename 'tblGLAccount.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccount'))
    BEGIN
        EXEC sp_rename 'tblGLAccount.intAccountUnitID', 'intAccountUnitId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountAllocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountAllocationDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountAllocationDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountAllocationDetail.intAccountAllocationDetailID', 'intAccountAllocationDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountAllocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAllocatedAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAllocatedAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountAllocationDetail.intAllocatedAccountID', 'intAllocatedAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountAllocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountAllocationDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountAllocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountAllocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountAllocationDetail.strJobID', 'strJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefault]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefault.intAccountDefaultID', 'intAccountDefaultId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefault]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSecurityUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSecurityUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefault.intSecurityUserID', 'intSecurityUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefault]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefault'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefault.intGLAccountTemplateID', 'intGLAccountTemplateId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefaultDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefaultDetail.intAccountDefaultDetailID', 'intAccountDefaultDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefaultDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountDefaultID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefaultDetail.intAccountDefaultID', 'intAccountDefaultId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountDefaultDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountDefaultDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountDefaultDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountGroup]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountGroup')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountGroup'))
    BEGIN
        EXEC sp_rename 'tblGLAccountGroup.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountGroup]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intParentGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountGroup')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intParentGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountGroup'))
    BEGIN
        EXEC sp_rename 'tblGLAccountGroup.intParentGroupID', 'intParentGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountReallocation]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocation')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocation'))
    BEGIN
        EXEC sp_rename 'tblGLAccountReallocation.intAccountReallocationID', 'intAccountReallocationId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountReallocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountReallocationDetail.intAccountReallocationDetailID', 'intAccountReallocationDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountReallocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountReallocationID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountReallocationDetail.intAccountReallocationID', 'intAccountReallocationId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountReallocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountReallocationDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountReallocationDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountReallocationDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountReallocationDetail.strJobID', 'strJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegment.intAccountSegmentID', 'intAccountSegmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegment.intAccountStructureID', 'intAccountStructureId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegment'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegment.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegmentMapping]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentMappingId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentMappingID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegmentMapping.intAccountSegmentMappingID', 'intAccountSegmentMappingId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegmentMapping]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegmentMapping.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountSegmentMapping]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountSegmentMapping'))
    BEGIN
        EXEC sp_rename 'tblGLAccountSegmentMapping.intAccountSegmentID', 'intAccountSegmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountStructure]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountStructure')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountStructure'))
    BEGIN
        EXEC sp_rename 'tblGLAccountStructure.intAccountStructureID', 'intAccountStructureId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountStructure]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intOriginLength' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountStructure')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLegacyLength' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountStructure'))
    BEGIN
        EXEC sp_rename 'tblGLAccountStructure.intLegacyLength', 'intOriginLength' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountTemplate]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplate')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplate'))
    BEGIN
        EXEC sp_rename 'tblGLAccountTemplate.intGLAccountTemplateID', 'intGLAccountTemplateId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountTemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTempalteDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTempalteDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountTemplateDetail.intGLAccountTempalteDetailID', 'intGLAccountTempalteDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountTemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLAccountTemplateID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountTemplateDetail.intGLAccountTemplateID', 'intGLAccountTemplateId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountTemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountTemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLAccountTemplateDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLAccountUnit]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitId' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountUnit')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitID' AND OBJECT_ID = OBJECT_ID(N'tblGLAccountUnit'))
    BEGIN
        EXEC sp_rename 'tblGLAccountUnit.intAccountUnitID', 'intAccountUnitId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudget]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBudgetId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBudgetID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget'))
    BEGIN
        EXEC sp_rename 'tblGLBudget.intBudgetID', 'intBudgetId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudget]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget'))
    BEGIN
        EXEC sp_rename 'tblGLBudget.intFiscalYearID', 'intFiscalYearId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudget]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget'))
    BEGIN
        EXEC sp_rename 'tblGLBudget.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudget]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget'))
    BEGIN
        EXEC sp_rename 'tblGLBudget.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudget]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudget'))
    BEGIN
        EXEC sp_rename 'tblGLBudget.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudgetDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudgetDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudgetDetail'))
    BEGIN
        EXEC sp_rename 'tblGLBudgetDetail.cntID', 'cntId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLBudgetDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLBudgetDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLBudgetDetail'))
    BEGIN
        EXEC sp_rename 'tblGLBudgetDetail.strAccountID', 'strAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustment.intCOAAdjustmentID', 'intCOAAdjustmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCOAAdjustmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCOAAdjustmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustment.strCOAAdjustmentID', 'strCOAAdjustmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustment.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustmentDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustmentDetail.intCOAAdjustmentDetailID', 'intCOAAdjustmentDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustmentDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCOAAdjustmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustmentDetail.intCOAAdjustmentID', 'intCOAAdjustmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustmentDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustmentDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustmentDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustmentDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustmentDetail.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCrossReferenceId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCrossReferenceID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.intCrossReferenceID', 'intCrossReferenceId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'inti21Id' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'inti21ID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.inti21ID', 'inti21Id' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'stri21Id' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'stri21ID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.stri21ID', 'stri21Id' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strExternalId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strExternalID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.strExternalID', 'strExternalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCurrentExternalId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCurrentExternalID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.strCurrentExternalID', 'strCurrentExternalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCompanyId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCompanyID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.strCompanyID', 'strCompanyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOACrossReference]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLegacyReferenceId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLegacyReferenceID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOACrossReference'))
    BEGIN
        EXEC sp_rename 'tblGLCOACrossReference.intLegacyReferenceID', 'intLegacyReferenceId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAImportLog]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLog')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLog'))
    BEGIN
        EXEC sp_rename 'tblGLCOAImportLog.intImportLogID', 'intImportLogId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAImportLog]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLog')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLog'))
    BEGIN
        EXEC sp_rename 'tblGLCOAImportLog.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAImportLogDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAImportLogDetail.intImportLogDetailID', 'intImportLogDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAImportLogDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intImportLogID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAImportLogDetail.intImportLogID', 'intImportLogId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAImportLogDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAImportLogDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOAImportLogDetail.strJournalID', 'strJournalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOATemplate]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplate')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplate'))
    BEGIN
        EXEC sp_rename 'tblGLCOATemplate.intAccountTemplateID', 'intAccountTemplateId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOATemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOATemplateDetail.intAccountTemplateDetailID', 'intAccountTemplateDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOATemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountTemplateID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOATemplateDetail.intAccountTemplateID', 'intAccountTemplateId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOATemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOATemplateDetail.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOATemplateDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureId' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountStructureID' AND OBJECT_ID = OBJECT_ID(N'tblGLCOATemplateDetail'))
    BEGIN
        EXEC sp_rename 'tblGLCOATemplateDetail.intAccountStructureID', 'intAccountStructureId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCurrentFiscalYear]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntId' AND OBJECT_ID = OBJECT_ID(N'tblGLCurrentFiscalYear')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntID' AND OBJECT_ID = OBJECT_ID(N'tblGLCurrentFiscalYear'))
    BEGIN
        EXEC sp_rename 'tblGLCurrentFiscalYear.cntID', 'cntId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCurrentFiscalYear]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearId' AND OBJECT_ID = OBJECT_ID(N'tblGLCurrentFiscalYear')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearID' AND OBJECT_ID = OBJECT_ID(N'tblGLCurrentFiscalYear'))
    BEGIN
        EXEC sp_rename 'tblGLCurrentFiscalYear.intFiscalYearID', 'intFiscalYearId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.intGLDetailID', 'intGLDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.strBatchID', 'strBatchId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.strTransactionID', 'strTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.strJobID', 'strJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strProductId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strProductID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.strProductID', 'strProductId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strWarehouseId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strWarehouseID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.strWarehouseID', 'strWarehouseId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetail'))
    BEGIN
        EXEC sp_rename 'tblGLDetail.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.intGLDetailID', 'intGLDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.strTransactionID', 'strTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.intTransactionID', 'intTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.strBatchID', 'strBatchId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.strJobID', 'strJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLDetailRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLDetailRecap'))
    BEGIN
        EXEC sp_rename 'tblGLDetailRecap.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLFiscalYear]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearId' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYear')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearID' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYear'))
    BEGIN
        EXEC sp_rename 'tblGLFiscalYear.intFiscalYearID', 'intFiscalYearId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLFiscalYearPeriod]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLFiscalYearPeriodId' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYearPeriod')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLFiscalYearPeriodID' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYearPeriod'))
    BEGIN
        EXEC sp_rename 'tblGLFiscalYearPeriod.intGLFiscalYearPeriodID', 'intGLFiscalYearPeriodId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLFiscalYearPeriod]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearId' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYearPeriod')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFiscalYearID' AND OBJECT_ID = OBJECT_ID(N'tblGLFiscalYearPeriod'))
    BEGIN
        EXEC sp_rename 'tblGLFiscalYearPeriod.intFiscalYearID', 'intFiscalYearId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.intJournalID', 'intJournalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.strJournalID', 'strJournalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournal]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strSourceId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strSourceID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournal'))
    BEGIN
        EXEC sp_rename 'tblGLJournal.strSourceID', 'strSourceId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalDetail.intJournalDetailID', 'intJournalDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalDetail.intJournalID', 'intJournalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurring]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurring.intJournalRecurringID', 'intJournalRecurringId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurring]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalRecurringId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalRecurringID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurring.strJournalRecurringID', 'strJournalRecurringId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurring]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strStoreId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strStoreID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurring.strStoreID', 'strStoreId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurring]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurring'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurring.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.intJournalRecurringDetailID', 'intJournalRecurringDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJournalRecurringID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.intJournalRecurringID', 'intJournalRecurringId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strNameId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strNameID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.strNameID', 'strNameId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLJournalRecurringDetail]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLJournalRecurringDetail'))
    BEGIN
        EXEC sp_rename 'tblGLJournalRecurringDetail.intJobID', 'intJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLModuleList]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntId' AND OBJECT_ID = OBJECT_ID(N'tblGLModuleList')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntID' AND OBJECT_ID = OBJECT_ID(N'tblGLModuleList'))
    BEGIN
        EXEC sp_rename 'tblGLModuleList.cntID', 'cntId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPostHistoryId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostHistory')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intPostHistoryID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostHistory'))
    BEGIN
        EXEC sp_rename 'tblGLPostHistory.intPostHistoryID', 'intPostHistoryId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostHistory')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostHistory'))
    BEGIN
        EXEC sp_rename 'tblGLPostHistory.strBatchID', 'strBatchId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intGLDetailID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.intGLDetailID', 'intGLDetailId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.strTransactionID', 'strTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.intTransactionID', 'intTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.strBatchID', 'strBatchId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.strAccountID', 'strAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJobID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.strJobID', 'strJobId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCurrencyID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.intCurrencyID', 'intCurrencyId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostRecap]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostRecap'))
    BEGIN
        EXEC sp_rename 'tblGLPostRecap.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostResult]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strBatchID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult'))
    BEGIN
        EXEC sp_rename 'tblGLPostResult.strBatchID', 'strBatchId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostResult]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult'))
    BEGIN
        EXEC sp_rename 'tblGLPostResult.intTransactionID', 'intTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostResult]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTransactionID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult'))
    BEGIN
        EXEC sp_rename 'tblGLPostResult.strTransactionID', 'strTransactionId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLPostResult]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLPostResult'))
    BEGIN
        EXEC sp_rename 'tblGLPostResult.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLRecurringHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRecurringHistoryId' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRecurringHistoryID' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory'))
    BEGIN
        EXEC sp_rename 'tblGLRecurringHistory.intRecurringHistoryID', 'intRecurringHistoryId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLRecurringHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalRecurringId' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalRecurringID' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory'))
    BEGIN
        EXEC sp_rename 'tblGLRecurringHistory.strJournalRecurringID', 'strJournalRecurringId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLRecurringHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalId' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strJournalID' AND OBJECT_ID = OBJECT_ID(N'tblGLRecurringHistory'))
    BEGIN
        EXEC sp_rename 'tblGLRecurringHistory.strJournalID', 'strJournalId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLSummary]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSummaryId' AND OBJECT_ID = OBJECT_ID(N'tblGLSummary')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSummaryID' AND OBJECT_ID = OBJECT_ID(N'tblGLSummary'))
    BEGIN
        EXEC sp_rename 'tblGLSummary.intSummaryID', 'intSummaryId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLSummary]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLSummary')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLSummary'))
    BEGIN
        EXEC sp_rename 'tblGLSummary.intAccountID', 'intAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.cntID', 'cntId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.strAccountID', 'strAccountId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.intAccountGroupID', 'intAccountGroupId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountSegmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAccountSegmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.strAccountSegmentID', 'strAccountSegmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountUnitID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.intAccountUnitID', 'intAccountUnitId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccount]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccount'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccount.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccountToBuild]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'cntID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccountToBuild.cntID', 'cntId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccountToBuild]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountSegmentID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccountToBuild.intAccountSegmentID', 'intAccountSegmentId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccountToBuild]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccountToBuild.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLTempAccountToBuild]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserId' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intUserID' AND OBJECT_ID = OBJECT_ID(N'tblGLTempAccountToBuild'))
    BEGIN
        EXEC sp_rename 'tblGLTempAccountToBuild.intUserID', 'intUserId' , 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCOAAdjustment]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPosted' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnposted' AND OBJECT_ID = OBJECT_ID(N'tblGLCOAAdjustment'))
    BEGIN
        EXEC sp_rename 'tblGLCOAAdjustment.ysnposted', 'ysnPosted' , 'COLUMN'
    END
END
GO

