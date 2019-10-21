CREATE TABLE [dbo].[tblGRUnPriced]
(
	[intUnPricedId] INT NOT NULL  IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
	[strTicketType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPriceTicket] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intItemId] INT NULL,
	[intCompanyLocationId] INT NULL, 
	[dblFuturesPrice] NUMERIC(18, 6) NULL,     
	[dblFuturesBasis] NUMERIC(18, 6) NULL,
	[dblCashPrice] NUMERIC(18, 6) NULL,
	[intUnitMeasureId] INT NULL,
	[ysnPosted] [bit] NULL DEFAULT ((0)),
	[intCreatedUserId] INT NULL,
	[dtmCreated] DATETIME NULL,
    CONSTRAINT [PK_tblGRUnPriced_intUnPricedId] PRIMARY KEY ([intUnPricedId]),	
	CONSTRAINT [FK_tblGRUnPriced_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),	
	CONSTRAINT [FK_tblGRUnPriced_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)