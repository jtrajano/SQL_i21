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
    [strHost]                          NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intPort]                          INT             NULL,
    [strProtocol]                      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strLogOnType]                     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strUser]                          NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strPassword]                      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strKeyFilePath]                   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPassphrase]                    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strHostKeyFingerPrint]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strBasePath]                      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strRemoteDownloadPath]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strRemoteUploadPath]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDecryptKeyFilePath]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDecryptPassphrase]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]                 INT             CONSTRAINT [DF_tblCFNetwork_intConcurrencyId] DEFAULT ((1)) NULL,
    [strDownloadFileName]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFNetwork] PRIMARY KEY CLUSTERED ([intNetworkId] ASC),
    CONSTRAINT [FK_tblCFNetwork_tblARCustomer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
    CONSTRAINT [FK_tblCFNetwork_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
    CONSTRAINT [FK_tblCFNetwork_tblSMImportFileHeader] FOREIGN KEY ([intImportMapperId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId])
);
















GO
CREATE NONCLUSTERED INDEX [IX_tblCFNetwork_intNetworkId]
    ON [dbo].[tblCFNetwork]([intNetworkId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFNetwork_intNetworkId]
    ON [dbo].[tblCFNetwork]([intNetworkId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFNetwork_intCustomerId]
    ON [dbo].[tblCFNetwork]([intCustomerId] ASC);

