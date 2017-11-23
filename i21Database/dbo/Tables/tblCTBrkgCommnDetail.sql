CREATE TABLE [dbo].[tblCTBrkgCommnDetail]
(
	intBrkgCommnDetailId	INT NOT NULL IDENTITY, 
    intBrkgCommnId			INT NOT NULL,
    intContractCostId		INT NOT NULL,
    intCreatedById			INT,
    dtmCreated				DATETIME,
    intLastModifiedById		INT,
    dtmLastModified			DATETIME,
    intConcurrencyId		INT NOT NULL,

	CONSTRAINT [PK_tblCTBrkgCommnDetail_intBrkgCommnDetailId] PRIMARY KEY CLUSTERED (intBrkgCommnDetailId ASC),
	CONSTRAINT [FK_tblCTBrkgCommnDetail_tblCTBrkgCommn_intBrkgCommnId] FOREIGN KEY (intBrkgCommnId) REFERENCES tblCTBrkgCommn(intBrkgCommnId) ON DELETE CASCADE	
)
