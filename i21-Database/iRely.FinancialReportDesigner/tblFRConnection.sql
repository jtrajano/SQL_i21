CREATE TABLE [dbo].[tblFRConnection] (
    [intConnectionId]   INT            IDENTITY (1, 1) NOT NULL,
    [intUserId]         INT            NOT NULL,
    [intTimeout]        INT            NOT NULL,
    [strConnectionName] NVARCHAR (500) COLLATE Latin1_General_CI_AS NOT NULL,
    [strDataType]       NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strDSN]            NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strAuthentication] NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strUserId]         NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strPassword]       NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strDatabase]       NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strProduct]        NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strPort]           NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strWebServiceURI]  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCompanyName]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [ysnWebService]     BIT            NOT NULL,
    [intConcurrencyId]  INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_dbo.tblFRConnection] PRIMARY KEY CLUSTERED ([intConnectionId] ASC)
);
