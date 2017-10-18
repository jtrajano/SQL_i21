CREATE TABLE [dbo].[tblVRProgram](
	[intProgramId] [int] IDENTITY(1,1) NOT NULL,
	[strProgram] [nvarchar](20) NULL,
	[intVendorSetupId] [int] NOT NULL,
	[strVendorProgram] [nvarchar](20) NULL,
	[strProgramDescription] [nvarchar](200) NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRProgram_intConcurrencyId]  DEFAULT ((0)),
	CONSTRAINT [PK_tblVRProgram] PRIMARY KEY CLUSTERED ([intProgramId] ASC),
);
GO
