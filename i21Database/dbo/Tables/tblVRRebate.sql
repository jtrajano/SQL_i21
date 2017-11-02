﻿CREATE TABLE [dbo].[tblVRRebate](
	[intRebateId] [int] IDENTITY(1,1) NOT NULL,
	[intInvoiceDetailId] [int] NOT NULL,
	[intProgramId] [int] NOT NULL,
	[dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT ((0)),
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblVRRebate_intConcurrencyId]  DEFAULT ((0)),
	[ysnSubmitted] BIT NOT NULL DEFAULT 0, 
    [ysnExcluded] BIT NOT NULL DEFAULT 0, 
    [dtmDate] DATETIME NOT NULL, 
    [dblRebateRate] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblRebateAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblVRRebate] PRIMARY KEY CLUSTERED([intRebateId] ASC), 
    CONSTRAINT [FK_tblVRRebate_tblARInvoiceDetail] FOREIGN KEY (intInvoiceDetailId) REFERENCES [tblARInvoiceDetail]([intInvoiceDetailId]),
	CONSTRAINT [FK_tblVRRebate_tblVRProgram] FOREIGN KEY (intProgramId) REFERENCES [tblVRProgram]([intProgramId]),
);
GO