﻿CREATE TABLE [dbo].[tblGLCompanyPreferenceOption]
(
	[intCompanyPreferenceOptionId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NULL,
	[PostRemind_Users] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[PostRemind_BeforeAfter] NVARCHAR(10)  COLLATE Latin1_General_CI_AS NULL,
	[PostRemind_Days] INT NULL,
	[OriginConversion_OffsetAccountId] INT NULL,
	[ysnConsolidatingParent] [bit] NULL,
	[intDefaultVisibleOldAccountSystemId] INT NULL,
	[intDBVersion] INT NULL,
	[ysnHistoricalJournalImported] BIT NULL,
	[ysnShowAccountingPeriod] BIT NULL,
	[ysnRequireLocation] BIT NULL,
	[strSubsidiaryCompanyJson] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL ,
	/*Override RE Settings*/
	[ysnREOverride] BIT NULL, --Retained Earnings
	[ysnREOverrideLocation] BIT NULL,
	[ysnREOverrideLOB] BIT NULL,
	[ysnREOverrideCompany] BIT NULL,
	[ysnRevalOverrideLocation] BIT NULL, --Revaluation
	[ysnRevalOverrideLOB] BIT NULL,
	[ysnRevalOverrideCompany] BIT NULL,
	[ysnISOverrideLocation] BIT NULL,
	[ysnISOverrideLOB] BIT NULL,
	[ysnISOverrideCompany] BIT NULL,
	[strOverrideREArray] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strParentCompanyCode] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strOverrideISArray] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[ysnAllowIntraCompanyEntries]	BIT NOT NULL DEFAULT((0)),
	[ysnAllowIntraLocationEntries]	BIT NOT NULL DEFAULT((0)),
	[ysnAllowSingleLocationEntries]	BIT NOT NULL DEFAULT((0)),
	[intDueToAccountId]				INT NULL,
	[intDueFromAccountId]			INT NULL,
	[ysnRequireRERefresh]			BIT NOT NULL DEFAULT(1),
	[strRequireRefreshReason]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strMaskedSegment]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblGLCompanyPreferenceOption] PRIMARY KEY ([intCompanyPreferenceOptionId])
)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCompanyPreferenceOption', @level2type=N'COLUMN',@level2name=N'intCompanyPreferenceOptionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCompanyPreferenceOption', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Users to remind for unposted transactions' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCompanyPreferenceOption', @level2type=N'COLUMN',@level2name=N'PostRemind_Users' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Before/ After fiscal period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCompanyPreferenceOption', @level2type=N'COLUMN',@level2name=N'PostRemind_BeforeAfter' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of Days Before/After Fiscal Period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCompanyPreferenceOption', @level2type=N'COLUMN',@level2name=N'PostRemind_Days' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Offset Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCompanyPreferenceOption', @level2type=N'COLUMN',@level2name=N'OriginConversion_OffsetAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Consolidating Parent' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCompanyPreferenceOption', @level2type=N'COLUMN',@level2name=N'ysnConsolidatingParent' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Default Visible Old Account System Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCompanyPreferenceOption', @level2type=N'COLUMN',@level2name=N'intDefaultVisibleOldAccountSystemId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SQL Database version (year)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCompanyPreferenceOption', @level2type=N'COLUMN',@level2name=N'intDBVersion' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicates if Historical journal importing was already performed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCompanyPreferenceOption', @level2type=N'COLUMN',@level2name=N'ysnHistoricalJournalImported' 
GO