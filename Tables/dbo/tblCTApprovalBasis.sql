CREATE TABLE [dbo].[tblCTApprovalBasis](
	[intApprovalBasisId] [int] IDENTITY(1,1) NOT NULL,
	[strApprovalBasis] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblCTApprovalBasis_intApprovalBasisId] PRIMARY KEY CLUSTERED ([intApprovalBasisId] ASC),
	CONSTRAINT [UK_tblCTApprovalBasis_strApprovalBasis] UNIQUE ([strApprovalBasis])
)