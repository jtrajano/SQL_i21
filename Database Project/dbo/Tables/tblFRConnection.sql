CREATE TABLE [dbo].[tblFRConnection] (
    [intConnectionID]   INT            IDENTITY (1, 1) NOT NULL,
    [intUserID]         INT            NOT NULL,
    [intTimeout]        INT            NOT NULL,
    [strConnectionName] NVARCHAR (500) COLLATE Latin1_General_CI_AS NOT NULL,
    [strDataType]       NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strDSN]            NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strAuthentication] NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strUserID]         NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strPassword]       NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strDatabase]       NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strProduct]        NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strPort]           NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strWebServiceURI]  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCompanyName]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [ysnWebService]     BIT            NOT NULL,
    CONSTRAINT [PK_dbo.tblFRConnection] PRIMARY KEY CLUSTERED ([intConnectionID] ASC)
);

