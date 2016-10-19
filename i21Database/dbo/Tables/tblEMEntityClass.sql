CREATE TABLE [dbo].[tblEMEntityClass]
(
	[intEntityClassId] INT NOT NULL,
	[strClass] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strModule] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[ysnActive] BIT DEFAULT(1),
	[intConcurrencyId] INT DEFAULT ((0)) NOT NULL,	
	CONSTRAINT [PK_tblEMEntityClass] PRIMARY KEY CLUSTERED ([intEntityClassId] ASC),	
	CONSTRAINT [UK_tblEMEntityClass_class_module] UNIQUE NONCLUSTERED ([strClass] ASC, [strModule] ASC),
)
