CREATE TABLE [dbo].[tblCTContractType]
(
	[intContractTypeId] [int] NOT NULL,
	[strContractType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL, 
    CONSTRAINT [PK_tblCTContractType_intContractTypeId] PRIMARY KEY ([intContractTypeId])
)
