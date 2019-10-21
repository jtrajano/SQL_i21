CREATE TABLE [dbo].[tblCTAmendmentApprovalLog]
(
	intAmendmentApprovalLogId int IDENTITY(1,1) NOT NULL,
	dtmHistoryCreated		      DATETIME,
	strDataField			      NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	ysnOldValue				      BIT,
	ysnNewValue                   BIT,
	intLastModifiedById           INT
)