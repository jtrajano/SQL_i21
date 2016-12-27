﻿CREATE TABLE [dbo].[tblTFReportingComponentDetail] (
    [intReportingComponentDetailId] INT           IDENTITY (1, 1) NOT NULL,
    [intReportingComponentId]       INT           NULL,
    
    [strIncludeTransactionsWithFET] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strIncludeTransactionsWithSET] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strIncludeTransactionsWithSST] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strLicenseNumber]              NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intCustomerTax]                INT           NULL,
    [intNumberOfCopies]             INT           NULL,
    [intConcurrencyId]              INT           CONSTRAINT [DF_tblTFReportingComponentDetail_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFReportingComponentDetail] PRIMARY KEY CLUSTERED ([intReportingComponentDetailId] ASC)
);





