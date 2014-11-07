CREATE TABLE [dbo].[tblEntityContact] (
    [intEntityId]      INT            NOT NULL,
    [intContactId]     INT            IDENTITY (1, 1) NOT NULL,
	[strContactNumber]               NVARCHAR (20)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strTitle]         NVARCHAR (35)  COLLATE Latin1_General_CI_AS NULL,
    [strDepartment]    NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strMobile]        NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone]         NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone2]        NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strEmail2]        NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [strFax]           NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strNotes]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strContactMethod] NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strTimezone]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblEntityContact_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntityContact] PRIMARY KEY CLUSTERED ([intEntityId] ASC),
    CONSTRAINT [FK_tblEntityContact_tblEntity1] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
    CONSTRAINT [UKintContactId] UNIQUE NONCLUSTERED ([intContactId] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Used for Origin link to ssconmst.sscon_contact_id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblEntityContact',
    @level2type = N'COLUMN',
    @level2name = N'strContactNumber'