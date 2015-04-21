CREATE TABLE [dbo].[tblCFPurchaseOrder] (
    [intPurchaseOrderId] INT            IDENTITY (1, 1) NOT NULL,
    [intAccountId]       INT            NULL,
    [dtmExpirationDate]  DATETIME       NULL,
    [strPurchaseOrderNo] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]   INT            CONSTRAINT [DF_tblCFPurchaseOder_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFPurchaseOder] PRIMARY KEY CLUSTERED ([intPurchaseOrderId] ASC),
    CONSTRAINT [FK_tblCFPurchaseOder_tblCFAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblCFAccount] ([intAccountId]) ON DELETE CASCADE
);



