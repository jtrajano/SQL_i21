CREATE TABLE [dbo].[tblCTContractType]
(
	[Value] [int] NOT NULL,
	[Name] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL, 
    CONSTRAINT [PK_tblCTContractType_Value] PRIMARY KEY ([Value])
)
