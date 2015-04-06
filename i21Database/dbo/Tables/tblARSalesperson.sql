CREATE TABLE [dbo].[tblARSalesperson] (
    [intEntitySalespersonId]             INT             NOT NULL,
    --[intSalespersonId]        INT             IDENTITY (1, 1) NOT NULL,
    [strSalespersonId]        NVARCHAR (3)    COLLATE Latin1_General_CI_AS NULL,
    [dtmBirthDate]            DATETIME        NULL,
    [strGender]               NVARCHAR (6)    COLLATE Latin1_General_CI_AS NULL,
    [strMaritalStatus]        NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
    [strSpouse]               NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strType]                 NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [strTitle]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intTerritoryId]          INT             NULL,
    [strPhone]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strAltPhone]             NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strMobile]               NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strAltEmail]             NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFax]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strAddress]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]              NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strCity]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strState]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strCountry]              NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dtmHired]                DATETIME        NULL,
    [dtmTerminated]           DATETIME        NULL,
    [strReason]               NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnActive]               BIT             CONSTRAINT [DF__tmp_ms_xx__ysnAc__1BBECB93] DEFAULT ((1)) NOT NULL,
    [strCommission]           NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblPercent]              NUMERIC (18, 6) NULL,
    [strDispatchNotification] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strTextMessage]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]        INT             CONSTRAINT [DF_tblARSalesperson_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARSalesperson_intEntityId] PRIMARY KEY CLUSTERED ([intEntitySalespersonId] ASC),
    CONSTRAINT [FK_tblARSalesperson_tblARTerritory_intTerritoryId] FOREIGN KEY ([intTerritoryId]) REFERENCES [dbo].[tblARTerritory] ([intTerritoryId]),
    CONSTRAINT [FK_tblARSalesperson_tblEntity_intEntityId] FOREIGN KEY ([intEntitySalespersonId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
    --CONSTRAINT [UQ_tblARSalesperson_intSalespersonId] UNIQUE NONCLUSTERED ([intSalespersonId] ASC),
    CONSTRAINT [UQ_tblARSalesperson_strSalespersonId] UNIQUE NONCLUSTERED ([strSalespersonId] ASC)

);







