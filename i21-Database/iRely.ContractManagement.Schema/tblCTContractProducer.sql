CREATE TABLE [dbo].[tblCTContractProducer]
(
	intContractProducerId   INT NOT NULL IDENTITY, 
    intContractHeaderId	   INT NOT NULL,
    intProducerId		   INT NOT NULL,
    intConcurrencyId	   INT NULL, 

    CONSTRAINT [PK_tblCTContractProducer_intContractProducerId] PRIMARY KEY CLUSTERED (intContractProducerId ASC), 
    CONSTRAINT [UK_tblCTContractProducer_intContractHeaderId_intProducerId] UNIQUE (intContractHeaderId,intProducerId),
    CONSTRAINT [FK_tblCTContractProducer_tblCTContractHeader_intContractHeaderId] FOREIGN KEY (intContractHeaderId) REFERENCES tblCTContractHeader(intContractHeaderId) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCTContractProducer_tblEMEntity_intProducerId_intEntityId] FOREIGN KEY (intProducerId) REFERENCES tblEMEntity(intEntityId)
)
