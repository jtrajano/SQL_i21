﻿CREATE TABLE [dbo].[tblBBProgramCustomer](
	[intProgramCustomerId] [int] IDENTITY(1,1) NOT NULL,
	[intProgramId] INT NOT NULL,
	[intCustomerLocationXrefId] INT NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBProgramCustomer_intConcurrencyId]  DEFAULT ((0)), 
    CONSTRAINT [PK_tblBBProgramCustomer] PRIMARY KEY ([intProgramCustomerId]), 
    CONSTRAINT [FK_tblBBProgramCustomer_tblBBProgram] FOREIGN KEY (intProgramId) REFERENCES [tblBBProgram]([intProgramId]), 
	CONSTRAINT [FK_tblBBProgramCustomer_tblICItem] FOREIGN KEY ([intCustomerLocationXrefId]) REFERENCES [tblBBCustomerLocationXref]([intCustomerLocationXrefId]),
    
)
GO
