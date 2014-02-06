CREATE TABLE [dbo].[agiarmst] (
    [agiar_itm_no]         CHAR (13)       NOT NULL,
    [agiar_loc_no]         CHAR (3)        NOT NULL,
    [agiar_cnv_rev_dt]     INT             NOT NULL,
    [agiar_seq_no]         SMALLINT        NOT NULL,
    [agiar_trans_type]     CHAR (2)        NULL,
    [agiar_rev_dt]         INT             NOT NULL,
    [agiar_alt_loc_no]     CHAR (3)        NOT NULL,
    [agiar_ref_no]         CHAR (8)        NOT NULL,
    [agiar_comments]       CHAR (41)       NULL,
    [agiar_on_hand]        DECIMAL (13, 4) NULL,
    [agiar_un_prc_or_cost] DECIMAL (11, 5) NULL,
    [agiar_audit_no]       CHAR (4)        NULL,
    [agiar_sys_rev_dt]     INT             NULL,
    [agiar_gl_acct]        DECIMAL (16, 8) NULL,
    [agiar_aw_line_no]     CHAR (3)        NULL,
    [agiar_user_id]        CHAR (16)       NULL,
    [agiar_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agiarmst] PRIMARY KEY NONCLUSTERED ([agiar_itm_no] ASC, [agiar_loc_no] ASC, [agiar_cnv_rev_dt] ASC, [agiar_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagiarmst0]
    ON [dbo].[agiarmst]([agiar_itm_no] ASC, [agiar_loc_no] ASC, [agiar_cnv_rev_dt] ASC, [agiar_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagiarmst1]
    ON [dbo].[agiarmst]([agiar_rev_dt] ASC, [agiar_alt_loc_no] ASC, [agiar_ref_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agiarmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agiarmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agiarmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agiarmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agiarmst] TO PUBLIC
    AS [dbo];

