CREATE TABLE [dbo].[tblBBProgram](
	[intProgramId] [int] IDENTITY(1,1) NOT NULL,
	[strProgramId] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[intVendorSetupId] [int] NOT NULL,
	[strVendorProgramId] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strProgramName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strProgramDescription] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBProgram_intConcurrencyId]  DEFAULT ((0)),
	CONSTRAINT [PK_tblBBProgram] PRIMARY KEY CLUSTERED ([intProgramId] ASC),
	CONSTRAINT [FK_tblBBProgram_tblVRVendorSetup] FOREIGN KEY ([intVendorSetupId]) REFERENCES [dbo].[tblVRVendorSetup] ([intVendorSetupId]) 
)
GO
