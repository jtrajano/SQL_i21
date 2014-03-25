CREATE TABLE [dbo].[tblEntityLocation] (
    [intEntityLocationId] INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]         INT            NOT NULL,
    [strLocationName]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strAddress]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCity]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCountry]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strState]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strPhone]            NVARCHAR (50)  NULL,
    [strFax]              NVARCHAR (50)  NULL,
    [strNotes]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intShipViaId]        INT            NULL,
    [intTaxCodeId]        INT            NULL,
    [intTermsId]          INT            NULL,
    [intWarehouseId]      INT            NULL,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblEntityLocations_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.tblEntityLocations] PRIMARY KEY CLUSTERED ([intEntityLocationId] ASC),
    CONSTRAINT [FK_dbo.tblEntityLocations_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblEntityLocation]([intEntityId] ASC);

