CREATE TABLE [dbo].[tblCTIntrCompApproval]
(
	[intIntrCompApprovalId] [int] IDENTITY(1,1) NOT NULL,
	[intContractHeaderId] INT,
	[intPriceFixationId] INT,
	[strName] [nvarchar](200) COLLATE Latin1_General_CI_AS NOT NULL,
	[strUserName] [nvarchar](200) COLLATE Latin1_General_CI_AS NOT NULL,
	[strScreen] [nvarchar](200) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	ysnApproval BIT CONSTRAINT [DF_tblCTIntrCompApproval_ysnApproval] DEFAULT 1,
	CONSTRAINT [PK_tblCTIntrCompApproval_intIntrCompApprovalId] PRIMARY KEY CLUSTERED (intIntrCompApprovalId ASC)
)
