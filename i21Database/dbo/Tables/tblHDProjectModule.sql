﻿CREATE TABLE [dbo].[tblHDProjectModule]
(
	[intProjectModuleId] [int] IDENTITY(1,1) NOT NULL,
	[intProjectId] [int] NOT NULL,
	[intModuleId] [int] NOT NULL,
	[intProjectManagerId] [int] NOT NULL,
	[intContactId] [int] NOT NULL,
	[dblQuotedHours] [numeric](18, 6) NULL,
	[intSort] [int] NULL,
	[intDataConversionExpertId] [int] NULL,
	[intTrainerId] [int] NULL,
	[strPhase] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strComment] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDProjectModule] PRIMARY KEY CLUSTERED ([intProjectModuleId] ASC),
	CONSTRAINT [UNQ_ProjectModule] UNIQUE ([intProjectId],[intModuleId]),
    CONSTRAINT [FK_Project_ProjectModule] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]) on delete cascade,
    CONSTRAINT [FK_Module_ProjectModule] FOREIGN KEY ([intModuleId]) REFERENCES [dbo].[tblHDModule] ([intModuleId]),
	CONSTRAINT [FK_UserEntity_ProjectModule] FOREIGN KEY ([intProjectManagerId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	--CONSTRAINT [FK_EntityContact_ProjectModule] FOREIGN KEY ([intContactId]) REFERENCES [dbo].[tblEMEntityContact] ([intEntityContactId])
	CONSTRAINT [FK_Entity_ProjectModule] FOREIGN KEY ([intContactId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblHDProjectModule_tblEMEntity_intDataConversionExpertId] FOREIGN KEY ([intDataConversionExpertId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
    CONSTRAINT [FK_tblHDProjectModule_tblEMEntity_intTrainerId] FOREIGN KEY ([intTrainerId]) REFERENCES [dbo].tblEMEntity ([intEntityId])

)
