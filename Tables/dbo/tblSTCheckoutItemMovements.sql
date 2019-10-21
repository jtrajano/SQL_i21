CREATE TABLE [dbo].[tblSTCheckoutItemMovements] (
    [intItemMovementId]   INT             IDENTITY (1, 1) NOT NULL,
    [intCheckoutId]       INT             NULL,
    [intItemUPCId]        INT             NULL,
    [strInvalidUPCCode]   NVARCHAR (15)   COLLATE Latin1_General_CI_AS NULL,
    [strDescription]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intVendorId]         INT             NULL,
    [intQtySold]          INT             NULL,
    [dblCurrentPrice]     DECIMAL (18, 6) NULL,
    [dblDiscountAmount]   DECIMAL (18, 6) NULL,
    [dblGrossSales]       DECIMAL (18, 6) NULL,
    [dblTotalSales]       DECIMAL (18, 6) NULL,
    [dblItemStandardCost] DECIMAL (18, 6) NULL,
    [intCalculationId]    INT             NULL,
	[intConcurrencyId]    INT             NULL,
    [ysnLotteryItem]      BIT            	
	CONSTRAINT [DF_tblSTCheckoutItemMovements_ysnLotteryItem] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblSTCheckoutItemMovements_intItemMovementId] PRIMARY KEY CLUSTERED ([intItemMovementId] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_tblSTCheckoutItemMovements_tblICItemUOM] FOREIGN KEY ([intItemUPCId]) REFERENCES [dbo].[tblICItemUOM] ([intItemUOMId]),
    CONSTRAINT [FK_tblSTCheckoutItemMovements_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [dbo].[tblSTCheckoutHeader] ([intCheckoutId]) ON DELETE CASCADE
);


