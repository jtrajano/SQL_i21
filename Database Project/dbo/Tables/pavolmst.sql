CREATE TABLE [dbo].[pavolmst] (
    [pavol_cus_no]             CHAR (10)       NOT NULL,
    [pavol_adj_ytd_vol_amt_1]  DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_2]  DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_3]  DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_4]  DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_5]  DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_6]  DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_7]  DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_8]  DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_9]  DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_10] DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_11] DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_12] DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_13] DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_14] DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_15] DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_16] DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_17] DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_18] DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_19] DECIMAL (11, 3) NULL,
    [pavol_adj_ytd_vol_amt_20] DECIMAL (11, 3) NULL,
    [pavol_user_id]            CHAR (16)       NULL,
    [pavol_user_rev_dt]        INT             NULL,
    [A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pavolmst] PRIMARY KEY NONCLUSTERED ([pavol_cus_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipavolmst0]
    ON [dbo].[pavolmst]([pavol_cus_no] ASC);

