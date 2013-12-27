CREATE TABLE [dbo].[gacchmst] (
    [gacch_pur_sls_ind] CHAR (1)       NOT NULL,
    [gacch_cus_no]      CHAR (10)      NOT NULL,
    [gacch_com_cd]      CHAR (3)       NOT NULL,
    [gacch_loc_no]      CHAR (3)       NOT NULL,
    [gacch_cnt_no]      CHAR (8)       NOT NULL,
    [gacch_cnt_seq_no]  SMALLINT       NOT NULL,
    [gacch_cnt_sub_no]  SMALLINT       NOT NULL,
    [gacch_seq_no]      INT            NOT NULL,
    [gacch_type]        CHAR (2)       NULL,
    [gacch_rev_dt]      INT            NULL,
    [gacch_roll_fee]    DECIMAL (9, 5) NULL,
    [gacch_before]      CHAR (30)      NULL,
    [gacch_after]       CHAR (30)      NULL,
    [gacch_user_id]     CHAR (16)      NULL,
    [gacch_user_rev_dt] INT            NULL,
    [A4GLIdentity]      NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gacchmst] PRIMARY KEY NONCLUSTERED ([gacch_pur_sls_ind] ASC, [gacch_cus_no] ASC, [gacch_com_cd] ASC, [gacch_loc_no] ASC, [gacch_cnt_no] ASC, [gacch_cnt_seq_no] ASC, [gacch_cnt_sub_no] ASC, [gacch_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igacchmst0]
    ON [dbo].[gacchmst]([gacch_pur_sls_ind] ASC, [gacch_cus_no] ASC, [gacch_com_cd] ASC, [gacch_loc_no] ASC, [gacch_cnt_no] ASC, [gacch_cnt_seq_no] ASC, [gacch_cnt_sub_no] ASC, [gacch_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gacchmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gacchmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gacchmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gacchmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gacchmst] TO PUBLIC
    AS [dbo];

