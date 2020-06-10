CREATE TABLE [dbo].[tblSTCheckoutLotteryCount] (
    [intCheckoutLotteryCountId] INT             IDENTITY (1, 1) NOT NULL,
    [intCheckoutId]             INT             NULL,
    [intLotteryBookId]          INT             NULL,
    [intEndingCount]            INT             NULL,
    [intTotalPack]              INT             NULL,
    [intConcurrencyId]          INT             CONSTRAINT [DF_tblSTCheckoutLotteryCount_intConcurrencyId] DEFAULT ((1)) NULL,
    [strSoldOut]                NVARCHAR (50)	COLLATE Latin1_General_CI_AS   NULL,
    [intBeginCount]             INT             NULL,
    [dblTicketValue]            NUMERIC (18, 6) NULL,
    [dblQuantitySold]           NUMERIC (18, 6) NULL,
    [dblTotalAmount]            NUMERIC (18, 6) NULL,
	[ysnBookSoldOut]			BIT				NULL,
    CONSTRAINT [PK_tblSTCheckoutLotteryCount] PRIMARY KEY CLUSTERED ([intCheckoutLotteryCountId] ASC),
    CONSTRAINT [FK_tblSTCheckoutLotteryCount_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [dbo].[tblSTCheckoutHeader] ([intCheckoutId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSTCheckoutLotteryCount_tblSTLotteryBook] FOREIGN KEY ([intLotteryBookId]) REFERENCES [dbo].[tblSTLotteryBook] ([intLotteryBookId]) ON DELETE SET NULL
);

