CREATE TABLE [dbo].[tblTFTerminalControlNumber] (
    [intTerminalControlNumberId] INT            IDENTITY (1, 1) NOT NULL,
    [intTaxAuthorityId]          INT            NOT NULL,
    [strTerminalControlNumber]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strName]                    NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strAddress]                 NVARCHAR (500) COLLATE Latin1_General_CI_AS NOT NULL,
    [strCity]                    NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmApprovedDate]            DATETIME       NULL,
    [strZip]                     NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
	[intMasterId] INT NULL,
    [intConcurrencyId]           INT            CONSTRAINT [DF_tblTFTerminalControlNumber_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFTerminalControlNumber] PRIMARY KEY CLUSTERED ([intTerminalControlNumberId] ASC),
    CONSTRAINT [FK_tblTFTerminalControlNumber_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [dbo].[tblTFTaxAuthority] ([intTaxAuthorityId])
);

