CREATE TABLE [dbo].[tblEMEntityAreaOfInterest]
(
	[intEntityAreaOfInterestId] INT NOT NULL IDENTITY(1,1),
	[intEntityId]				INT NOT NULL,
	[intTicketTypeId]			INT NULL,
	[intConcurrencyId]			INT DEFAULT(0) NOT NULL,

	CONSTRAINT [PK_tblEMEntityAreaOfInterest] PRIMARY KEY CLUSTERED ([intEntityAreaOfInterestId] ASC),
	CONSTRAINT [FK_tblEMEntityAreaOfInterest_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblEMEntityAreaOfInterest_tblHDTicketType] FOREIGN KEY ([intTicketTypeId]) REFERENCES [dbo].[tblHDTicketType]([intTicketTypeId])
)
