CREATE TABLE [dbo].[tblCTContractDocument]
(
	[intContractDocumentId] INT IDENTITY(1,1) NOT NULL, 
    [intContractHeaderId] INT NOT NULL, 
    [intDocumentId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblCTContractDocument_intContractDocumentId] PRIMARY KEY CLUSTERED ([intContractDocumentId] ASC),
	CONSTRAINT [UQ_tblCTContractDocument_intContractHeaderId_intDocumentId] UNIQUE ([intContractHeaderId], [intDocumentId]), 
	CONSTRAINT [FK_tblCTContractDocument_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractDocument_tblICDocument_intDocumentId] FOREIGN KEY ([intDocumentId]) REFERENCES [tblICDocument]([intDocumentId]) 
)
