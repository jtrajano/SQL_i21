CREATE TABLE [dbo].[tblCRMBrand]
(
	[intBrandId]			INT IDENTITY(1,1) NOT NULL,
	[strBrand]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFileType]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strIntegrationObject]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strLoginUrl]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strUserName]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strPassword]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMBrand] PRIMARY KEY CLUSTERED ([intBrandId] ASC),
	CONSTRAINT [UQ_tblCRMBrand_strBrand] UNIQUE ([strBrand])
)