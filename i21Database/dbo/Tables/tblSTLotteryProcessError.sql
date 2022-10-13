CREATE TABLE [dbo].[tblSTLotteryProcessError] (
    [intLotteryProcessErrorId]   INT            IDENTITY (1, 1) NOT NULL,
    [intCheckoutId]				 INT            NULL,
    [strBookNumber]				 NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strGame]					 NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strError]					 NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strProcess]				 NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]           INT NULL CONSTRAINT [DF_tblSTLotteryProcessError_intConcurrencyId]  DEFAULT ((1)),
    CONSTRAINT [PK_tblSTLotteryProcessError] PRIMARY KEY CLUSTERED ([intLotteryProcessErrorId] ASC) WITH (FILLFACTOR = 70),
);
