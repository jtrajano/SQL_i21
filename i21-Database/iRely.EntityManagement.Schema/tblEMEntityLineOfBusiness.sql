CREATE TABLE [dbo].[tblEMEntityLineOfBusiness]
(
	[intEntityLineOfBusinessId]		INT IDENTITY(1,1) NOT NULL,
	[intEntityId]					INT NOT NULL,
    [intLineOfBusinessId]			INT NOT NULL,
	[intEntitySalespersonId]		INT NULL,	
	[intConcurrencyId]				INT DEFAULT ((0)) NOT NULL,
	CONSTRAINT [FK_tblEMEntityLineOfBusiness_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblEMEntityLineOfBusiness_tblSMLineOfBusiness] FOREIGN KEY ([intLineOfBusinessId]) REFERENCES [dbo].[tblSMLineOfBusiness] ([intLineOfBusinessId]),
	CONSTRAINT [FK_tblEMEntityLineOfBusiness_tblEMEntity_intEntitySalespersonId] FOREIGN KEY ([intEntitySalespersonId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [PK_tblEMEntityLineOfBusiness] PRIMARY KEY CLUSTERED ([intEntityLineOfBusinessId] ASC),
)
