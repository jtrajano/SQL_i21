CREATE TABLE [dbo].[gacolmst] (
    [gacol_pur_sls_ind]  CHAR (1)        NOT NULL,
    [gacol_loc_no]       CHAR (3)        NOT NULL,
    [gacol_com_cd]       CHAR (3)        NOT NULL,
    [gacol_cus_no]       CHAR (10)       NOT NULL,
    [gacol_rcpt_no]      CHAR (10)       NOT NULL,
    [gacol_seq_no]       SMALLINT        NOT NULL,
    [gacol_cnt_no]       CHAR (8)        NOT NULL,
    [gacol_open_rev_dt]  INT             NULL,
    [gacol_orig_un]      DECIMAL (11, 3) NULL,
    [gacol_un_bal]       DECIMAL (11, 3) NULL,
    [gacol_close_rev_dt] INT             NULL,
    [gacol_comment]      CHAR (30)       NULL,
    [gacol_adj_rev_dt]   INT             NULL,
    [gacol_adj_un]       DECIMAL (11, 3) NULL,
    [gacol_adj_comment]  CHAR (30)       NULL,
    [gacol_user_id]      CHAR (16)       NULL,
    [gacol_user_rev_dt]  CHAR (8)        NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gacolmst] PRIMARY KEY NONCLUSTERED ([gacol_pur_sls_ind] ASC, [gacol_loc_no] ASC, [gacol_com_cd] ASC, [gacol_cus_no] ASC, [gacol_rcpt_no] ASC, [gacol_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igacolmst0]
    ON [dbo].[gacolmst]([gacol_pur_sls_ind] ASC, [gacol_loc_no] ASC, [gacol_com_cd] ASC, [gacol_cus_no] ASC, [gacol_rcpt_no] ASC, [gacol_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Igacolmst1]
    ON [dbo].[gacolmst]([gacol_cnt_no] ASC);

