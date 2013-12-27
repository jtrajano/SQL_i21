﻿CREATE TABLE [dbo].[paeoymst] (
    [paeoy_cus_no]             CHAR (10)       NOT NULL,
    [paeoy_rfd_type]           TINYINT         NOT NULL,
    [paeoy_vol_amt_1]          DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_2]          DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_3]          DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_4]          DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_5]          DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_6]          DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_7]          DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_8]          DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_9]          DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_10]         DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_11]         DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_12]         DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_13]         DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_14]         DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_15]         DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_16]         DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_17]         DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_18]         DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_19]         DECIMAL (12, 3) NULL,
    [paeoy_vol_amt_20]         DECIMAL (12, 3) NULL,
    [paeoy_vol_rfd_amt_1]      DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_2]      DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_3]      DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_4]      DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_5]      DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_6]      DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_7]      DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_8]      DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_9]      DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_10]     DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_11]     DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_12]     DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_13]     DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_14]     DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_15]     DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_16]     DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_17]     DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_18]     DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_19]     DECIMAL (11, 2) NULL,
    [paeoy_vol_rfd_amt_20]     DECIMAL (11, 2) NULL,
    [paeoy_not_sub_vol_amt_1]  DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_2]  DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_3]  DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_4]  DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_5]  DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_6]  DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_7]  DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_8]  DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_9]  DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_10] DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_11] DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_12] DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_13] DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_14] DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_15] DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_16] DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_17] DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_18] DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_19] DECIMAL (12, 3) NULL,
    [paeoy_not_sub_vol_amt_20] DECIMAL (12, 3) NULL,
    [paeoy_tot_stk_eqty]       DECIMAL (11, 2) NULL,
    [paeoy_tot_stk_issued]     DECIMAL (11, 2) NULL,
    [paeoy_tot_prior_year]     DECIMAL (11, 2) NULL,
    [paeoy_total_refund]       DECIMAL (11, 2) NULL,
    [paeoy_cash_amt]           DECIMAL (10, 2) NULL,
    [paeoy_res_amt]            DECIMAL (10, 2) NULL,
    [paeoy_whole_shares]       DECIMAL (10, 2) NULL,
    [paeoy_hist_tot_un_eqty]   DECIMAL (11, 2) NULL,
    [paeoy_hist_tot_un_res]    DECIMAL (11, 2) NULL,
    [A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_paeoymst] PRIMARY KEY NONCLUSTERED ([paeoy_cus_no] ASC, [paeoy_rfd_type] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ipaeoymst0]
    ON [dbo].[paeoymst]([paeoy_cus_no] ASC, [paeoy_rfd_type] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipaeoymst1]
    ON [dbo].[paeoymst]([paeoy_rfd_type] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[paeoymst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[paeoymst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[paeoymst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[paeoymst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[paeoymst] TO PUBLIC
    AS [dbo];

