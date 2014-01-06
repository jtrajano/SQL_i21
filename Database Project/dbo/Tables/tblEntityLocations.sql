CREATE TABLE [dbo].[tblEntityLocations] (
    [intEntityLocationId] INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]         INT            NOT NULL,
    [strLocationName]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strContactName]      NVARCHAR (MAX) NULL,
    [strAddress]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCity]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCountry]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strState]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strEmail]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strNotes]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strW9Name]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intShipViaId]        INT            NULL,
    [intTaxCodeId]        INT            NULL,
    [intTermsId]          INT            NULL,
    [intWarehouseId]      INT            NULL,
    CONSTRAINT [PK_dbo.tblEntityLocations] PRIMARY KEY CLUSTERED ([intEntityLocationId] ASC),
    CONSTRAINT [FK_dbo.tblEntityLocations_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
);




GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblEntityLocations]([intEntityId] ASC);

