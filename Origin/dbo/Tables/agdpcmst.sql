CREATE TABLE [dbo].[agdpcmst] (
    [agdpc_loc_no]                 CHAR (3)        NOT NULL,
    [agdpc_pay_type]               CHAR (1)        NOT NULL,
    [agdpc_cbk_no]                 CHAR (2)        NULL,
    [agdpc_vnd_no]                 CHAR (10)       NULL,
    [agdpc_gl_acct]                DECIMAL (16, 8) NULL,
    [agdpc_batch_no]               SMALLINT        NULL,
    [agdpc_user_id]                CHAR (16)       NULL,
    [agdpc_user_rev_dt]            CHAR (8)        NULL,
    [A4GLIdentity]                 NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    [agdpc_depn_bucket_type_ycrnl] CHAR (1)        NULL,
    [agdpc_detailed_ap_yn]         CHAR (1)        NULL,
    [agdpc_bypass_bdg_upd_yn]      CHAR (1)        NULL,
    CONSTRAINT [k_agdpcmst] PRIMARY KEY NONCLUSTERED ([agdpc_loc_no] ASC, [agdpc_pay_type] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagdpcmst0]
    ON [dbo].[agdpcmst]([agdpc_loc_no] ASC, [agdpc_pay_type] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agdpcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agdpcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agdpcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agdpcmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agdpcmst] TO PUBLIC
    AS [dbo];

