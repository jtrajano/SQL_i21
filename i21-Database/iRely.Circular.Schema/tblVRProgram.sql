CREATE TABLE [dbo].[tblVRProgram](
	[intProgramId] [int] IDENTITY(1,1) NOT NULL,
	[strProgram] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[intVendorSetupId] [int] NOT NULL,
	[strVendorProgram] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strProgramDescription] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRProgram_intConcurrencyId]  DEFAULT ((0)),
	CONSTRAINT [PK_tblVRProgram] PRIMARY KEY CLUSTERED ([intProgramId] ASC),
	CONSTRAINT [FK_tblVRProgram_tblVRVendorSetup] FOREIGN KEY ([intVendorSetupId]) REFERENCES [dbo].[tblVRVendorSetup] ([intVendorSetupId]) 
)
GO
