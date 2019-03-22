CREATE TABLE [dbo].[tblCTBookVsEntity]
(
	intBookVsEntityId INT IDENTITY(1,1) NOT NULL,
	intBookId INT NOT NULL,
	intSubBookId INT,
	intEntityId INT NOT NULL,
	intMultiCompanyId INT,
	intConcurrencyId INT NOT NULL, 
	CONSTRAINT [PK_tblCTBookVsEntity_intBookVsEntity] PRIMARY KEY CLUSTERED (intBookVsEntityId ASC),
	CONSTRAINT [UK_tblCTBookVsEntity_intEntityid] UNIQUE (intEntityId),
	CONSTRAINT [FK_tblCTBookVsEntity_intBookId] FOREIGN KEY (intBookId) REFERENCES tblCTBook(intBookId),
	CONSTRAINT [FK_tblCTBookVsEntity_intSubBookId] FOREIGN KEY (intSubBookId) REFERENCES tblCTSubBook(intSubBookId),
	CONSTRAINT [FK_tblCTBookVsEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_tblCTBookVsEntity_intMultiCompanyId] FOREIGN KEY (intMultiCompanyId) REFERENCES tblSMMultiCompany(intMultiCompanyId)
)
