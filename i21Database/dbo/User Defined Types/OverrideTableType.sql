CREATE TYPE [dbo].[OverrideTableType] AS TABLE (				
	[intAccountId] INT  NULL,
	intAccountIdOverride INT NULL,
    intLocationSegmentOverrideId INT NULL,
    intLOBSegmentOverrideId INT NULL,
    intCompanySegmentOverrideId INT NULL,
    strNewAccountIdOverride NVARCHAR(40) Collate Latin1_General_CI_AS NULL,
    intNewAccountIdOverride INT NULL,
    strOverrideAccountError NVARCHAR(800) Collate Latin1_General_CI_AS NULL
)