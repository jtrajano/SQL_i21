CREATE TABLE [dbo].[tblVRProgramCustomer](
	[intProgramCustomerId] [int] IDENTITY(1,1) NOT NULL,
	[intProgramId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRProgramCustomer_intConcurrencyId]  DEFAULT ((0)),
	[intEntityId] [int] NOT NULL,
	CONSTRAINT [PK_tblVRProgramCustomer] PRIMARY KEY CLUSTERED ([intProgramCustomerId] ASC),
	CONSTRAINT [FK_tblVRProgramCustomer_tblARCustomer] FOREIGN KEY([intEntityId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblVRProgramCustomer_tblVRProgram] FOREIGN KEY([intProgramId]) REFERENCES [dbo].[tblVRProgram] ([intProgramId]) ON DELETE CASCADE, 
)
GO
