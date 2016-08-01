CREATE TABLE [dbo].[tblCFNetwork] (
    [intNetworkId]                     INT             IDENTITY (1, 1) NOT NULL,
    [strNetwork]                       NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strNetworkType]                   NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strNetworkDescription]            NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intCustomerId]                    INT             NULL,
    [intCACustomerId]                  INT             NULL,
    [intDebitMemoGLAccount]            INT             NULL,
    [intLocationId]                    INT             NULL,
    [dblFeeRateAmount]                 NUMERIC (18, 6) NULL,
    [dblFeePerGallon]                  NUMERIC (18, 6) NULL,
    [dblFeeTransactionPerGallon]       NUMERIC (18, 6) NULL,
    [dblMonthlyCommisionFeeAmount]     NUMERIC (18, 6) NULL,
    [dblVariableCommisionFeePerGallon] NUMERIC (18, 6) NULL,
    [strImportPath]                    NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [dtmLastImportDate]                DATETIME        NULL,
    [intErrorBatchNumber]              INT             NULL,
    [intPPhostId]                      INT             NULL,
    [intPPDistributionSite]            INT             NULL,
    [strPPFileImportType]              NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnRejectExportCard]              BIT             NULL,
    [strRejectPath]                    NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strParticipant]                   NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strCFNFileVersion]                NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPassOnSSTFromRemotes]          BIT             NULL,
    [ysnExemptFETOnRemotes]            BIT             NULL,
    [ysnExemptSETOnRemotes]            BIT             NULL,
    [ysnExemptLCOnRemotes]             BIT             NULL,
    [strExemptLCCode]                  NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intImportMapperId]                INT             NULL,
    [strIso]                           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strLinkNetwork]                   NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intCardLength]                    INT             NULL,
    [intAccountLength]                 INT             NULL,
    [intConcurrencyId]                 INT             CONSTRAINT [DF_tblCFNetwork_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFNetwork] PRIMARY KEY CLUSTERED ([intNetworkId] ASC),
    CONSTRAINT [FK_tblCFNetwork_tblARCustomer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
    CONSTRAINT [FK_tblCFNetwork_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
    CONSTRAINT [FK_tblCFNetwork_tblSMImportFileHeader] FOREIGN KEY ([intImportMapperId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId])
);







