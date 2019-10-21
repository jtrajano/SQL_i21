CREATE TABLE [dbo].[tblCTIntrCompApproval]
(
	[intIntrCompApprovalId] [int] IDENTITY(1,1) NOT NULL,
	[intContractHeaderId] INT,
	[intPriceFixationId] INT,
	[strName] [nvarchar](200) COLLATE Latin1_General_CI_AS NOT NULL,
	[strUserName] [nvarchar](200) COLLATE Latin1_General_CI_AS NOT NULL,
	[strScreen] [nvarchar](200) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL, 

	CONSTRAINT [PK_tblCTIntrCompApproval_intIntrCompApprovalId] PRIMARY KEY CLUSTERED (intIntrCompApprovalId ASC)
)
