CREATE TABLE [dbo].[tblARCustomerFieldXRef] (
    [intFieldXRefId]   INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT            NOT NULL,
    [strUsage]         NVARCHAR (15)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFieldName]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strSourceData]    NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strTargetData]    NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            NOT NULL,
    CONSTRAINT [PK_tblARCustomerFieldXRef] PRIMARY KEY CLUSTERED ([intFieldXRefId] ASC)
);

