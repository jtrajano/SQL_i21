CREATE TABLE [dbo].[tblEntityGroup]
(
	[intEntityGroupId]          INT				IDENTITY (1, 1) NOT NULL,    
    [strEntityGroupName]		NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT             CONSTRAINT [DF__tmp_tblentitygroup__intEntityGroupId__5132705A] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblEntityGroup] PRIMARY KEY CLUSTERED ([intEntityGroupId] ASC),
	CONSTRAINT [UK_tblEntityGroup_strEntityGroupName] UNIQUE NONCLUSTERED ([strEntityGroupName] ASC),
)
