CREATE TABLE [dbo].[tblHDCoworkerSuperVisor]
(
	[intCoworkerSuperVisorId]			INT IDENTITY(1,1) NOT NULL,
	[intEntityId]						INT			   NOT NULL,
	[ysnAutoAdded]						BIT	 NOT NULL	CONSTRAINT [DF_tblHDCoworkerSuperVisor_ysnAutoAdded] DEFAULT ((0)),
	[intConcurrencyId] [int]			NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDCoworkerSuperVisor_intCoworkerSuperVisorId] PRIMARY KEY CLUSTERED ([intCoworkerSuperVisorId] ASC),
	CONSTRAINT [FK_tblHDCoworkerSuperVisor_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [UQ_tblHDCoworkerSuperVisor_intEntityId] UNIQUE ([intEntityId])
)

GO