CREATE TABLE [dbo].[gaspsmst] (
    [gasps_pur_sls_ind] CHAR (1)        NOT NULL,
    [gasps_cus_no]      CHAR (10)       NOT NULL,
    [gasps_com_cd]      CHAR (3)        NOT NULL,
    [gasps_stor_type]   TINYINT         NOT NULL,
    [gasps_tic_no]      CHAR (10)       NOT NULL,
    [gasps_loc_no]      CHAR (3)        NOT NULL,
    [gasps_tie_breaker] SMALLINT        NOT NULL,
    [gasps_seq_no]      SMALLINT        NOT NULL,
    [gasps_rec_type]    CHAR (1)        NULL,
    [gasps_rev_dt]      INT             NULL,
    [gasps_un]          DECIMAL (11, 3) NULL,
    [gasps_user_id]     CHAR (16)       NULL,
    [gasps_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gaspsmst] PRIMARY KEY NONCLUSTERED ([gasps_pur_sls_ind] ASC, [gasps_cus_no] ASC, [gasps_com_cd] ASC, [gasps_stor_type] ASC, [gasps_tic_no] ASC, [gasps_loc_no] ASC, [gasps_tie_breaker] ASC, [gasps_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igaspsmst0]
    ON [dbo].[gaspsmst]([gasps_pur_sls_ind] ASC, [gasps_cus_no] ASC, [gasps_com_cd] ASC, [gasps_stor_type] ASC, [gasps_tic_no] ASC, [gasps_loc_no] ASC, [gasps_tie_breaker] ASC, [gasps_seq_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gaspsmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gaspsmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gaspsmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gaspsmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gaspsmst] TO PUBLIC
    AS [dbo];

