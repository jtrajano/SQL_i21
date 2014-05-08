CREATE TABLE [dbo].[tblRMPrintingFilter] (
    [intPrintingFilterId] INT            IDENTITY (1, 1) NOT NULL,
    [strKey]              NVARCHAR (MAX) NULL,
    [strJoin]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFieldName]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFrom]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strTo]               NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCondition]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDataType]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblRMPrintingFilter_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblRMPrintingFilter] PRIMARY KEY CLUSTERED ([intPrintingFilterId] ASC)
);

