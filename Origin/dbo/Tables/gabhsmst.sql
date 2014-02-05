CREATE TABLE [dbo].[gabhsmst] (
    [gabhs_loc_no]      CHAR (3)        NOT NULL,
    [gabhs_com_cd]      CHAR (3)        NOT NULL,
    [gabhs_bin_no]      CHAR (5)        NOT NULL,
    [gabhs_cnv_rev_dt]  INT             NOT NULL,
    [gabhs_seq_no]      INT             NOT NULL,
    [gabhs_trans_type]  CHAR (2)        NULL,
    [gabhs_rev_dt]      INT             NULL,
    [gabhs_tic_no]      CHAR (10)       NULL,
    [gabhs_cus_no]      CHAR (10)       NULL,
    [gabhs_un]          DECIMAL (11, 3) NULL,
    [gabhs_user_id]     CHAR (16)       NULL,
    [gabhs_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gabhsmst] PRIMARY KEY NONCLUSTERED ([gabhs_loc_no] ASC, [gabhs_com_cd] ASC, [gabhs_bin_no] ASC, [gabhs_cnv_rev_dt] ASC, [gabhs_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igabhsmst0]
    ON [dbo].[gabhsmst]([gabhs_loc_no] ASC, [gabhs_com_cd] ASC, [gabhs_bin_no] ASC, [gabhs_cnv_rev_dt] ASC, [gabhs_seq_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gabhsmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gabhsmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gabhsmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gabhsmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gabhsmst] TO PUBLIC
    AS [dbo];

