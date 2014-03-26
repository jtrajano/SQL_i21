CREATE TABLE [dbo].[tblARCustomerContractDetail] (
    [intContractDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intContractId]       INT             NOT NULL,
    [strItemNumber]       NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strItemDescription]  NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intPackages]         INT             NULL,
    [dblUnitPrice]        NUMERIC (18, 6) NULL,
    [intConcurrencyId]    INT             NOT NULL,
    CONSTRAINT [PK_tblARCustomerContractDetail] PRIMARY KEY CLUSTERED ([intContractDetailId] ASC)
);

