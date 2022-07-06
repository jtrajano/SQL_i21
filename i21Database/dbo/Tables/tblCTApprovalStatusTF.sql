
CREATE TABLE [dbo].[tblCTApprovalStatusTF](
	[intApprovalStatusId] [int] NOT NULL,
	[strApprovalStatus] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTApprovalStatusTF_intApprovalStatusId] PRIMARY KEY ([intApprovalStatusId])
)

