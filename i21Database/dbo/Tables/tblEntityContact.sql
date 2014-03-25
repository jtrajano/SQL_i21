CREATE TABLE [dbo].[tblEntityContact] (
    [intEntityId]        INT             NOT NULL,
    [intEntityContactId] INT             NOT NULL,
    [strTitle]           NVARCHAR (35)   COLLATE Latin1_General_CI_AS NULL,
    [strDepartment]      NVARCHAR (30)   COLLATE Latin1_General_CI_AS NULL,
    [strMobile]          NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [strPhone]           NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [strEmail]           NVARCHAR (75)   COLLATE Latin1_General_CI_AS NULL,
    [strFax]             NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [strNotes]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strContactMethod]   NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [strPassword]        NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [strUserType]        NVARCHAR (5)    COLLATE Latin1_General_CI_AS NULL,
    [strTimezone]        NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPortalAccess]    BIT             CONSTRAINT [DF_tblEntityContact_ysnPortalAccess] DEFAULT ((0)) NOT NULL,
    [imgContactPhoto]    VARBINARY (MAX) NULL,
    [intConcurrencyId]   INT             CONSTRAINT [DF_tblEntityContacts_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntityContact] PRIMARY KEY CLUSTERED ([intEntityId] ASC),
    CONSTRAINT [FK_tblEntityContact_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId])
);

