CREATE TABLE [dbo].[tblSTLotteryBook] (
    [intLotteryBookId]       INT              IDENTITY (1, 1) NOT NULL,
    [intStoreId]             INT              NULL,
    [strBookNumber]          NVARCHAR (500)   COLLATE Latin1_General_CI_AS NULL,
    [strCountDirection]      NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [intLotteryGameId]       INT              NULL,
    [intBinNumber]           INT			  NULL,
    [dtmReceiptDate]         DATETIME         NULL,
    [dtmSoldDate]            DATETIME         NULL,
    [dblQuantityRemaining]   NUMERIC (18, 6) NULL,
    [dtmActivateDate]        DATETIME         NULL,
    [strStatus]              NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [dblTicketValue]         NUMERIC (18, 6) NULL,
    [dblTicketCost]          NUMERIC (18, 6) NULL,
    [dblTotalInventoryValue] NUMERIC (18, 6) NULL,
    [dblTotalInventoryCost]  NUMERIC (18, 6) NULL,
    [intConcurrencyId]       INT              NOT NULL,
    CONSTRAINT [PK_tblSTLotteryBook] PRIMARY KEY CLUSTERED ([intLotteryBookId] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_tblSTLotteryBook_tblSTLotteryGame] FOREIGN KEY ([intLotteryGameId]) REFERENCES [dbo].[tblSTLotteryGame] ([intLotteryGameId]),
    CONSTRAINT [FK_tblSTLotteryBook_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [dbo].[tblSTStore] ([intStoreId]),
	
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [tblSTLotteryBook_UniqueGameAndBookNumber]
    ON [dbo].[tblSTLotteryBook]([intLotteryGameId] ASC, [strBookNumber] ASC);



