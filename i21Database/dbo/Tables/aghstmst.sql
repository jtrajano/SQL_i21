CREATE TABLE [dbo].[aghstmst] (
    [aghst_cus_no]       CHAR (10)       NOT NULL,
    [aghst_cnt_no]       CHAR (8)        NOT NULL,
    [aghst_line_no]      SMALLINT        NOT NULL,
    [aghst_hst_seq]      SMALLINT        NOT NULL,
    [aghst_fill_cus_no]  CHAR (10)       NULL,
    [aghst_fill_rev_dt]  INT             NULL,
    [aghst_fill_un]      DECIMAL (13, 4) NULL,
    [aghst_fill_amt]     DECIMAL (11, 2) NULL,
    [aghst_fill_ord_no]  CHAR (8)        NULL,
    [aghst_fill_loc_no]  CHAR (3)        NULL,
    [aghst_fill_comment] CHAR (20)       NULL,
    [aghst_user_id]      CHAR (16)       NULL,
    [aghst_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_aghstmst] PRIMARY KEY NONCLUSTERED ([aghst_cus_no] ASC, [aghst_cnt_no] ASC, [aghst_line_no] ASC, [aghst_hst_seq] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iaghstmst0]
    ON [dbo].[aghstmst]([aghst_cus_no] ASC, [aghst_cnt_no] ASC, [aghst_line_no] ASC, [aghst_hst_seq] ASC);

