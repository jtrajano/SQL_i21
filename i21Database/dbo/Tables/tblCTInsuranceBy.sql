CREATE TABLE [dbo].[tblCTInsuranceBy](
	[intInsuranceById] [int] NOT NULL,
	[strInsuranceBy] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblCTInsuranceBy_intInsuranceById] PRIMARY KEY CLUSTERED ([intInsuranceById] ASC)
)