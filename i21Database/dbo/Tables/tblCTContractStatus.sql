CREATE TABLE [dbo].[tblCTContractStatus]
(
	[intContractStatusId] [int] NOT NULL,
	[strContractStatus] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL, 
    CONSTRAINT [PK_tblCTContractStatus_intContractStatusId] PRIMARY KEY ([intContractStatusId])
)
