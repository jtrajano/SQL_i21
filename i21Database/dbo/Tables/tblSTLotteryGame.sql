CREATE TABLE [dbo].[tblSTLotteryGame] (
    [intLotteryGameId]  INT              IDENTITY (1, 1) NOT NULL,
    [strState]          NVARCHAR (10)    COLLATE Latin1_General_CI_AS NULL,
    [strGame]           NVARCHAR (200)   COLLATE Latin1_General_CI_AS NULL,
    [intItemId]         INT              NULL,
    [intItemUOMId]      INT              NULL,
    [intStartingNumber] INT              NULL,
    [intEndingNumber]   INT              NULL,
    [intTicketPerPack]  INT              NULL,
    [dtmExpirationDate] DATETIME         NULL,
    [dblInventoryCost]  NUMERIC (18, 6) NULL,
    [dblTicketValue]    NUMERIC (18, 6) NULL,
    [intConcurrencyId]  INT              NOT NULL,
    CONSTRAINT [PK_tblSTLotteryGame] PRIMARY KEY CLUSTERED ([intLotteryGameId] ASC),
    CONSTRAINT [FK_tblSTLotteryGame_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
    CONSTRAINT [AK_tblSTLotteryGame_strState_strGame] UNIQUE NONCLUSTERED ([strState],[strGame])
);