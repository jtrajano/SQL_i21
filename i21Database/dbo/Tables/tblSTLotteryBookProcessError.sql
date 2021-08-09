CREATE TABLE [dbo].[tblSTLotteryBookProcessError] (
    [intLotteryBookProcessErrorId]   INT            IDENTITY (1, 1) NOT NULL,
    [intUserId]						 INT            NULL,
    [strBookNumber]					 NVARCHAR(MAX)  NULL,
    [strGame]						 NVARCHAR(MAX)  NULL,
    [strError]						 NVARCHAR(MAX)  NULL,
    [strProcess]					 NVARCHAR(MAX)  NULL,
    [intConcurrencyId]				 INT NULL CONSTRAINT [DF_tblSTLotteryBookProcessError_intConcurrencyId]  DEFAULT ((1)),
    CONSTRAINT [PK_tblSTLotteryBookProcessError] PRIMARY KEY CLUSTERED ([intLotteryBookProcessErrorId] ASC) WITH (FILLFACTOR = 70),
);
