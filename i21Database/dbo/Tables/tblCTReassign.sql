CREATE TABLE [dbo].[tblCTReassign]
(
	intReassignId		INT IDENTITY (1, 1) NOT NULL,
    intContractTypeId	INT NOT NULL,
    intEntityId			INT NOT NULL,
    intDonorId			INT NOT NULL,
    intRecipientId		INT NOT NULL,
    intCreatedById		INT	NOT NULL,
	dtmCreated			DATETIME NOT NULL,
	dblUnallocatedQty	NUMERIC(18,6),
	intAllocationUOMId	INT,
	strAllocationUOM	NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
	dblUnpricedLots		NUMERIC(18,6),
	dblUnhedgedLots		NUMERIC(18,6),
	intConcurrencyId	INT NOT NULL,
	strContractType		NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
	strEntityName		NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	strDonorContract	NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
	strRecipientContract NVARCHAR(50)  COLLATE Latin1_General_CI_AS,

    PRIMARY KEY CLUSTERED ([intReassignId] ASC),
    CONSTRAINT [FK_tblCTReassign_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId),
    CONSTRAINT [FK_tblCTReassign_tblCTContractType_intContractTypeId] FOREIGN KEY (intContractTypeId) REFERENCES tblCTContractType(intContractTypeId),
    CONSTRAINT [FK_tblCTReassign_tblCTContractDetail_intDonorId] FOREIGN KEY (intDonorId) REFERENCES tblCTContractDetail(intContractDetailId),
    CONSTRAINT [FK_tblCTReassign_tblCTContractDetail_intRecipientId] FOREIGN KEY (intRecipientId) REFERENCES tblCTContractDetail(intContractDetailId),
    CONSTRAINT [FK_tblCTReassign_tblEMEntity_intCreatedById] FOREIGN KEY (intCreatedById) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_tblCTReassign_tblICUnitMeasure_intAllocationUOMId_intUnitMeasureId] FOREIGN KEY (intAllocationUOMId) REFERENCES tblICUnitMeasure(intUnitMeasureId)
)
