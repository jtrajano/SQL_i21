
CREATE TABLE [dbo].[tblSTReturnLottery] (
    [intReturnLotteryId]    INT             IDENTITY (1, 1) NOT NULL,
    [intLotteryBookId]      INT             NULL,
    [intCheckoutId]         INT            NULL,
    [intInventoryReceiptId] INT             NULL,
    [dtmReturnDate]         DATETIME        NOT NULL,
    [dblQuantity]           NUMERIC (18, 6) NULL,
    [dblOriginalQuantity]   NUMERIC (18, 6) NULL,
    [ysnReadyForPosting]    BIT             CONSTRAINT [DF_tblSTReturnLottery_ysnReadyForPosting] DEFAULT ((0)) NOT NULL,
    [ysnPosted]             BIT             CONSTRAINT [DF_tblSTReturnLottery_ysnPosted] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblSTReturnLottery_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblSTReturnLottery] PRIMARY KEY CLUSTERED ([intReturnLotteryId] ASC),
    CONSTRAINT [FK_tblSTReturnLottery_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [dbo].[tblICInventoryReceipt] ([intInventoryReceiptId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSTReturnLottery_tblSTLotteryBook] FOREIGN KEY ([intLotteryBookId]) REFERENCES [dbo].[tblSTLotteryBook] ([intLotteryBookId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSTReturnLottery_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [dbo].[tblSTCheckoutHeader] ([intCheckoutId]) ON DELETE CASCADE
   
);

