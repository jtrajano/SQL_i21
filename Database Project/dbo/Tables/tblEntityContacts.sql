CREATE TABLE [dbo].[tblEntityContacts] (
    [intEntityContactId] INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]        INT            NOT NULL,
    [strName]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strTitle]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strLocationName]    NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDepartment]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strMobile]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strPhone]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strPhone2]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strEmail]           NVARCHAR (MAX) NULL,
    [strEmail2]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFax]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strNotes]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyID]   INT            NULL,
    CONSTRAINT [PK_dbo.tblEntityContacts] PRIMARY KEY CLUSTERED ([intEntityContactId] ASC),
    CONSTRAINT [FK_dbo.tblEntityContacts_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
);




GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblEntityContacts]([intEntityId] ASC);

