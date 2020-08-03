CREATE TABLE [dbo].[tblSTLotteryProcessError] (
    [intLotteryProcessErrorId]   INT            IDENTITY (1, 1) NOT NULL,
    [intCheckoutId]				 INT            NULL,
    [strBookNumber]				 NVARCHAR(MAX)  NULL,
    [strGame]					 NVARCHAR(MAX)  NULL,
    [strError]					 NVARCHAR(MAX)  NULL,
    [strProcess]				 NVARCHAR(MAX)  NULL,
    CONSTRAINT [PK_tblSTLotteryProcessError] PRIMARY KEY CLUSTERED ([intLotteryProcessErrorId] ASC) WITH (FILLFACTOR = 70),
);