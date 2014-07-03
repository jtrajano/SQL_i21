CREATE TABLE [dbo].[tblARCustomerCommission] (
    [intCommissionId]  INT             IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT             NOT NULL,
    [intItemId]        INT             NOT NULL,
    [dtmEffectiveFrom] DATETIME        NULL,
    [dtmEffectiveTo]   DATETIME        NULL,
    [strRate]          NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
    [dblCommission]    NUMERIC (18, 2) NULL,
    [intSalespersonId] INT             NULL,
    [intConcurrencyId] INT             NOT NULL,
    CONSTRAINT [PK_tblARCustomerCommission] PRIMARY KEY CLUSTERED ([intCommissionId] ASC)
);



