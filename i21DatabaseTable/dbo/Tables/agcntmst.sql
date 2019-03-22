CREATE TABLE [dbo].[agcntmst] (
    [agcnt_cus_no]          CHAR (10)       NOT NULL,
    [agcnt_cnt_no]          CHAR (8)        NOT NULL,
    [agcnt_line_no]         SMALLINT        NOT NULL,
    [agcnt_alt_cus]         CHAR (10)       NOT NULL,
    [agcnt_itm_or_cls]      CHAR (13)       NOT NULL,
    [agcnt_loc_no]          CHAR (3)        NOT NULL,
    [agcnt_alt_cnt_no]      CHAR (8)        NOT NULL,
    [agcnt_detail_info]     CHAR (147)      NULL,
    [agcnt_amt_orig]        DECIMAL (11, 2) NULL,
    [agcnt_amt_bal]         DECIMAL (11, 2) NULL,
    [agcnt_currency]        CHAR (3)        NULL,
    [agcnt_currency_rt]     DECIMAL (15, 8) NULL,
    [agcnt_currency_cnt]    CHAR (8)        NULL,
    [agcnt_ppd_tax_yn]      CHAR (1)        NULL,
    [agcnt_hdr_src_sys]     CHAR (3)        NULL,
    [agcnt_cnt_rev_dt]      INT             NULL,
    [agcnt_beg_ship_rev_dt] INT             NULL,
    [agcnt_due_rev_dt]      INT             NULL,
    [agcnt_hdr_comments]    CHAR (30)       NULL,
    [agcnt_ppd_yndm]        CHAR (1)        NULL,
    [agcnt_prc_lvl]         CHAR (1)        NULL,
    [agcnt_split_no]        CHAR (4)        NULL,
    [agcnt_pkup_ind]        CHAR (1)        NULL,
    [agcnt_un_orig]         DECIMAL (11, 4) NULL,
    [agcnt_un_prc]          DECIMAL (11, 5) NULL,
    [agcnt_un_bal]          DECIMAL (11, 4) NULL,
    [agcnt_last_hst_seq]    SMALLINT        NULL,
    [agcnt_fet_yn]          CHAR (1)        NULL,
    [agcnt_set_yn]          CHAR (1)        NULL,
    [agcnt_sst_ynp]         CHAR (1)        NULL,
    [agcnt_lc1_yn]          CHAR (1)        NULL,
    [agcnt_lc2_yn]          CHAR (1)        NULL,
    [agcnt_lc3_yn]          CHAR (1)        NULL,
    [agcnt_lc4_yn]          CHAR (1)        NULL,
    [agcnt_lc5_yn]          CHAR (1)        NULL,
    [agcnt_lc6_yn]          CHAR (1)        NULL,
    [agcnt_dtl_comments]    CHAR (34)       NULL,
    [agcnt_txt_no]          CHAR (2)        NULL,
    [agcnt_src_sys]         CHAR (3)        NULL,
    [agcnt_slsmn_id]        CHAR (3)        NULL,
    [agcnt_ppd_dep_per_un]  DECIMAL (11, 5) NULL,
    [agcnt_user_id]         CHAR (16)       NULL,
    [agcnt_user_rev_dt]     INT             NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agcntmst] PRIMARY KEY NONCLUSTERED ([agcnt_cus_no] ASC, [agcnt_cnt_no] ASC, [agcnt_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagcntmst0]
    ON [dbo].[agcntmst]([agcnt_cus_no] ASC, [agcnt_cnt_no] ASC, [agcnt_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagcntmst1]
    ON [dbo].[agcntmst]([agcnt_cnt_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagcntmst2]
    ON [dbo].[agcntmst]([agcnt_alt_cus] ASC, [agcnt_itm_or_cls] ASC, [agcnt_loc_no] ASC, [agcnt_alt_cnt_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagcntmst3]
    ON [dbo].[agcntmst]([agcnt_itm_or_cls] ASC);

