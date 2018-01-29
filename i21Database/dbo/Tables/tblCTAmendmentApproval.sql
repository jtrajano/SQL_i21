CREATE TABLE [dbo].[tblCTAmendmentApproval]
(
	intAmendmentApprovalId int IDENTITY(1,1) NOT NULL,	
	strDataIndex NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	strDataField NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	ysnAmendment BIT,
	ysnApproval  BIT,
	intConcurrencyId INT NOT NULL,
	strType			 NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblCTAmendmentApproval_intAmendmentApprovalId] PRIMARY KEY CLUSTERED (intAmendmentApprovalId ASC)
)