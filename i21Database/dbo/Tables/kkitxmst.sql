CREATE TABLE [dbo].[kkitxmst] (
    [kkitx_dep_no]         CHAR (6)    NOT NULL,
    [kkitx_itm_no]         CHAR (13)   NOT NULL,
    [kkitx_comments]       CHAR (30)   NULL,
    [kkitx_budget_acct_yn] CHAR (1)    NULL,
    [kkitx_user_id]        CHAR (16)   NULL,
    [kkitx_user_rev_dt]    CHAR (8)    NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_kkitxmst] PRIMARY KEY NONCLUSTERED ([kkitx_dep_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ikkitxmst0]
    ON [dbo].[kkitxmst]([kkitx_dep_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ikkitxmst1]
    ON [dbo].[kkitxmst]([kkitx_itm_no] ASC);

