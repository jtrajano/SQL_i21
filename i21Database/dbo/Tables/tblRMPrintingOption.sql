CREATE TABLE [dbo].[tblRMPrintingOption] (
    [intPrintingOptionId] INT            IDENTITY (1, 1) NOT NULL,
    [strKey]              NVARCHAR (MAX) NULL,
    [strName]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intType]             INT            NULL,
    [strSettings]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblRMPrintingOption_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblRMPrintingOption] PRIMARY KEY CLUSTERED ([intPrintingOptionId] ASC)
);

