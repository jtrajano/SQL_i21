CREATE TABLE [dbo].[tblARCustomerFreightXRef] (
    [intFreightXRefId]  INT             IDENTITY (1, 1) NOT NULL,
    [intEntityId]       INT             NOT NULL,
    [intTerminalVendorId] INT			NULL,
    [intCategoryId]      INT				NULL,
    [ysnFreightOnly]    BIT             NOT NULL DEFAULT ((0)),
    [strFreightType]    NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblFreightAmount]  NUMERIC (18, 6) NULL,
    [dblFreightRate]    NUMERIC (18, 6) NULL,
    [dblMinimumUnits]   NUMERIC (18, 6) NULL,
    [ysnFreightInPrice] BIT             NOT NULL DEFAULT ((0)),
    [dblFreightMiles]   NUMERIC (18, 6) NULL,
    [inShipViaId]       INT				NULL,
    [intConcurrencyId]  INT             NOT NULL,
    CONSTRAINT [PK_tblARCustomerFreightXRef] PRIMARY KEY CLUSTERED ([intFreightXRefId] ASC),
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblSMShipVia] FOREIGN KEY ([inShipViaId]) REFERENCES [tblSMShipVia]([intShipViaID])
);

