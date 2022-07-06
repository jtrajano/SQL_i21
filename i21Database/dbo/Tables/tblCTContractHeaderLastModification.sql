CREATE TABLE [dbo].[tblCTContractHeaderLastModification]
(
	intContractHeaderLastModificationId INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,intContractHeaderId int not null
	,intEntityId int not null
	,intPositionId int null
	,intFreightTermId int null
	,intTermId int null
	,intGradeId int null
	,intWeightId int null

	, intConcurrencyId int not null default(1)
	, CONSTRAINT [FK_tblCTContractHeaderLastModification_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]) ON DELETE CASCADE,

)
