CREATE TABLE [dbo].[tblCTReassignAllocation]
(
	intReassignAllocationId	INT IDENTITY (1, 1) NOT NULL,
    intReassignId			INT NOT NULL,
	intAllocationDetailId	INT,
    intContractDetailId		INT,
    intAllocationUOMId		INT,
    intReassignUOMId		INT,
    dblAllocatedQty			NUMERIC(18,6),
    dblOpenQty				NUMERIC(18,6),
    dblReassign				NUMERIC(18,6),
    strContractSeq			NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    strReassignUOM			NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    strAllocationUOM		NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    intConcurrencyId		INT NOT NULL,
	intReassignUnitMeasureId INT,
    
    PRIMARY KEY CLUSTERED (intReassignAllocationId ASC),
    CONSTRAINT [FK_tblCTReassignAllocation_tblCTReassign_intReassignId] FOREIGN KEY (intReassignId) REFERENCES tblCTReassign(intReassignId) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCTReassignAllocation_tblCTContractDetail_intContractDetailId] FOREIGN KEY (intContractDetailId) REFERENCES tblCTContractDetail(intContractDetailId),
	CONSTRAINT [FK_tblCTReassignAllocation_tblICItemUOM_intAllocationUOMId_intItemUOMId] FOREIGN KEY (intAllocationUOMId) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTReassignAllocation_tblICItemUOM_intReassignUOMId_intItemUOMId] FOREIGN KEY (intReassignUOMId) REFERENCES [tblICItemUOM]([intItemUOMId])
)
