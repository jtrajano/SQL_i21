CREATE TABLE [dbo].[tblEMEntityLineOfBusiness]
(
	[intEntityLineOfBusinessId]		INT IDENTITY(1,1) NOT NULL,
	[intEntityId]					INT NOT NULL,
    [intLineOfBusinessId]			INT NOT NULL,	
	[intConcurrencyId]				INT DEFAULT ((0)) NOT NULL,
	CONSTRAINT [FK_tblEMEntityLineOfBusiness_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblEMEntityLineOfBusiness_tblHDLineOfBusiness] FOREIGN KEY ([intLineOfBusinessId]) REFERENCES [dbo].[tblHDLineOfBusiness] ([intLineOfBusinessId]),
)
