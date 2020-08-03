CREATE TABLE [dbo].[tblSTReceiveLottery] (
    [intReceiveLotteryId]   INT            IDENTITY (1, 1) NOT NULL,
    [intCheckoutId]         INT            NULL,
    [intLotteryBookId]      INT            NULL,
    [intInventoryReceiptId] INT            NULL,
    [intStoreId]            INT            NULL,
    [intLotteryGameId]      INT            NULL,
    [strBookNumber]         NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [dtmReceiptDate]        DATETIME       NOT NULL,
    [ysnPosted]             BIT            CONSTRAINT [DF_tblSTReceiveLottery_ysnPosted] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]      INT            CONSTRAINT [DF_tblSTReceiveLottery_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblSTReceiveLottery] PRIMARY KEY CLUSTERED ([intReceiveLotteryId] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_tblSTReceiveLottery_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [dbo].[tblICInventoryReceipt] ([intInventoryReceiptId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSTReceiveLottery_tblSTLotteryBook] FOREIGN KEY ([intLotteryBookId]) REFERENCES [dbo].[tblSTLotteryBook] ([intLotteryBookId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSTReceiveLottery_tblSTLotteryGame] FOREIGN KEY ([intLotteryGameId]) REFERENCES [dbo].[tblSTLotteryGame] ([intLotteryGameId]),
    CONSTRAINT [FK_tblSTReceiveLottery_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [dbo].[tblSTStore] ([intStoreId]),
    CONSTRAINT [FK_tblSTReceiveLottery_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [dbo].[tblSTCheckoutHeader] ([intCheckoutId]) ON DELETE CASCADE,
   
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [tblSTReceiveLottery_UniqueGameAndBookNumber]
    ON [dbo].[tblSTReceiveLottery]([intLotteryGameId] ASC, [strBookNumber] ASC);




-- GO
-- CREATE UNIQUE NONCLUSTERED INDEX [tblSTReceiveLottery_UniqueCheckoutGameAndBookNumber]
--     ON [dbo].[tblSTReceiveLottery]([intCheckoutId] ASC, [intLotteryGameId] ASC, [strBookNumber] ASC);


