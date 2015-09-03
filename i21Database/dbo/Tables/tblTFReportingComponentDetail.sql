CREATE TABLE [dbo].[tblTFReportingComponentDetail] (
    [intReportingComponentDetailId] INT           IDENTITY (1, 1) NOT NULL,
    [intReportingComponentId]       INT           NULL,
    [ysnIncludeSalesFreightOnly]    BIT           NULL,
    [strIncludeTransactionsWithFET] NVARCHAR (50) NULL,
    [strIncludeTransactionsWithSET] NVARCHAR (50) NULL,
    [strIncludeTransactionsWithSST] NVARCHAR (50) NULL,
    [strLicenseNumber]              NVARCHAR (50) NULL,
    [intCustomerTax]                INT           NULL,
    [intNumberOfCopies]             INT           NULL,
    [intConcurrencyId]              INT           CONSTRAINT [DF_tblTFReportingComponentDetail_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFReportingComponentDetail] PRIMARY KEY CLUSTERED ([intReportingComponentDetailId] ASC)
);



