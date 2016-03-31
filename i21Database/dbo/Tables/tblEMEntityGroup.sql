CREATE TABLE [dbo].[tblEMEntityGroup]
(
	[intEntityGroupId]          INT				IDENTITY (1, 1) NOT NULL,    
    [strEntityGroupName]		NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT             CONSTRAINT [DF__tmp_tblEMEntitygroup__intEntityGroupId__5132705A] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblEMEntityGroup] PRIMARY KEY CLUSTERED ([intEntityGroupId] ASC),
	CONSTRAINT [UK_tblEMEntityGroup_strEntityGroupName] UNIQUE NONCLUSTERED ([strEntityGroupName] ASC),
)
