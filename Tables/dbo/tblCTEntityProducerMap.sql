CREATE TABLE [dbo].[tblCTEntityProducerMap]
(
	[intEntityProducerMapId] INT IDENTITY(1,1) NOT NULL, 
	[intEntityId] INT NOT NULL,
	[intProducerId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL,

	CONSTRAINT [PK_EntityProducerMap_intEntityProducerMapId] PRIMARY KEY CLUSTERED (intEntityProducerMapId ASC),
	CONSTRAINT [UK_EntityProducerMap_intEntityId_intProducerId] UNIQUE ([intEntityId],[intProducerId]),
	CONSTRAINT [FK_EntityProducerMap_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_EntityProducerMap_tblEMEntity_intProducerId] FOREIGN KEY (intProducerId) REFERENCES tblEMEntity([intEntityId])
)
