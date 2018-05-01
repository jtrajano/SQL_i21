CREATE TABLE [dbo].[tblCTSequenceAmendmentLog]
(
	intSequenceAmendmentLogId	   INT IDENTITY(1,1) NOT NULL,
	intSequenceHistoryId		   INT,
	dtmHistoryCreated		       DATETIME,
    intContractHeaderId		       INT,
    intContractDetailId		       INT,
	intAmendmentApprovalId         INT,
	strItemChanged		  		   NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strOldValue		  		       NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strNewValue				       NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strAmendmentNumber		       NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	intConcurrencyId			   INT,
	ysnSigned					   bit NOT NULL CONSTRAINT [DF_tblCTSequenceAmendmentLog_ysnSigned]  DEFAULT ((0)),
	dtmSigned					   DATETIME,
    CONSTRAINT [PK_tblCTSequenceAmendmentLog_intSequenceAmendmentLogId] PRIMARY KEY CLUSTERED (intSequenceAmendmentLogId ASC),
    CONSTRAINT [FK_tblCTSequenceAmendmentLog_tblCTContractDetail_intContractDetailId] FOREIGN KEY (intContractDetailId) REFERENCES [tblCTContractDetail](intContractDetailId) ON DELETE CASCADE
)