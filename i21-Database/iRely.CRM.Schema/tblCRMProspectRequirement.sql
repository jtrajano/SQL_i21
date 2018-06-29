CREATE TABLE [dbo].[tblCRMProspectRequirement]
(
	[intProspectRequirementId] [int] IDENTITY(1,1) NOT NULL,
	[strQuestionType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intLineOfBusinessId] [int] null,
	[ysnActive] [bit] not null default convert(bit,0),
	[intModuleId] [int] null,
	[strQuestion] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblCRMProspectRequirement_intProspectRequirementId] PRIMARY KEY CLUSTERED ([intProspectRequirementId] ASC),
 CONSTRAINT [FK_tblCRMProspectRequirement_tblSMModule_intModuleId] FOREIGN KEY ([intModuleId]) REFERENCES [dbo].[tblSMModule] ([intModuleId]),
 CONSTRAINT [FK_tblCRMProspectRequirement_tblSMLineOfBusiness_intLineOfBusinessId] FOREIGN KEY ([intLineOfBusinessId]) REFERENCES [dbo].[tblSMLineOfBusiness] ([intLineOfBusinessId]),
 CONSTRAINT [UQ_tblCRMProspectRequirement_ProspectRequirement] UNIQUE ([strQuestionType],[intLineOfBusinessId],[intModuleId])
)