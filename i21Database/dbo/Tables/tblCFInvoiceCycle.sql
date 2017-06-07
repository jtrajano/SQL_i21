CREATE TABLE [dbo].[tblCFInvoiceCycle] (
    [intInvoiceCycleId] INT            IDENTITY (1, 1) NOT NULL,
    [strInvoiceCycle]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]  INT            CONSTRAINT [DF_tblCFInvoiceCycle_intConcurrencyId_1] DEFAULT ((1)) NULL,
    [strDescription]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFInvoiceCycle] PRIMARY KEY CLUSTERED ([intInvoiceCycleId] ASC)
);

GO
CREATE UNIQUE NONCLUSTERED INDEX tblCFInvoiceCycle_UniqueInvoiceCycle
	ON tblCFInvoiceCycle (strInvoiceCycle);