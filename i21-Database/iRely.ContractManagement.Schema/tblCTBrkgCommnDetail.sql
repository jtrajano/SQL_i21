CREATE TABLE [dbo].[tblCTBrkgCommnDetail]
(
	intBrkgCommnDetailId	INT NOT NULL IDENTITY, 
    intBrkgCommnId			INT NOT NULL,
    intContractCostId		INT NOT NULL,
	dblDueEstimated			NUMERIC(18,6),
	dblReqstdAmount			NUMERIC(18,6),
	dblRcvdPaidAmount		NUMERIC(18,6),
    intCreatedById			INT,
    dtmCreated				DATETIME,
    intLastModifiedById		INT,
    dtmLastModified			DATETIME,
    intConcurrencyId		INT NOT NULL,

	CONSTRAINT [PK_tblCTBrkgCommnDetail_intBrkgCommnDetailId] PRIMARY KEY CLUSTERED (intBrkgCommnDetailId ASC),
	CONSTRAINT [FK_tblCTBrkgCommnDetail_tblCTBrkgCommn_intBrkgCommnId] FOREIGN KEY (intBrkgCommnId) REFERENCES tblCTBrkgCommn(intBrkgCommnId) ON DELETE CASCADE	
)
