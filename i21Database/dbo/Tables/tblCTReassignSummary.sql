CREATE TABLE [dbo].[tblCTReassignSummary]
(
	intReassignSummaryId	INT IDENTITY (1, 1) NOT NULL,
    intReassignId			INT NOT NULL,
    intContractDetailId		INT,
    intAllocationUOMId		INT,
    dblAllocation			NUMERIC(18,6),
    dblPricedLot			NUMERIC(18,6),
    dblFuturesLot			NUMERIC(18,6),
    strType					NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    strContractSeq			NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	strAllocationUOM		NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
    intConcurrencyId		INT NOT NULL,
    intAllocationUnitMeasureId INT,

    PRIMARY KEY CLUSTERED (intReassignSummaryId ASC),
    CONSTRAINT [FK_tblCTReassignSummary_tblCTReassign_intReassignId] FOREIGN KEY (intReassignId) REFERENCES tblCTReassign(intReassignId) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCTReassignSummary_tblCTContractDetail_intContractDetailId] FOREIGN KEY (intContractDetailId) REFERENCES tblCTContractDetail(intContractDetailId),
	CONSTRAINT [FK_tblCTReassignSummary_tblICItemUOM_intAllocationUOMId_intItemUOMId] FOREIGN KEY (intAllocationUOMId) REFERENCES [tblICItemUOM]([intItemUOMId])
)
