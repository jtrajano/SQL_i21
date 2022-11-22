CREATE TABLE [dbo].[tblSTLotteryBookProcessError] (
    [intLotteryBookProcessErrorId]   INT            IDENTITY (1, 1) NOT NULL,
    [intUserId]						 INT            NULL,
    [strBookNumber]					 NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strGame]						 NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strError]						 NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strProcess]					 NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]				 INT NULL CONSTRAINT [DF_tblSTLotteryBookProcessError_intConcurrencyId]  DEFAULT ((1)),
    CONSTRAINT [PK_tblSTLotteryBookProcessError] PRIMARY KEY CLUSTERED ([intLotteryBookProcessErrorId] ASC) WITH (FILLFACTOR = 70),
);
