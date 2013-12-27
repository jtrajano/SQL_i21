CREATE TABLE [dbo].[etitxmst] (
    [etitx_itm_no]      CHAR (13)   NOT NULL,
    [etitx_et_itm_no]   BIGINT      NOT NULL,
    [etitx_comments]    CHAR (30)   NULL,
    [etitx_user_id]     CHAR (16)   NULL,
    [etitx_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_etitxmst] PRIMARY KEY NONCLUSTERED ([etitx_itm_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ietitxmst0]
    ON [dbo].[etitxmst]([etitx_itm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ietitxmst1]
    ON [dbo].[etitxmst]([etitx_et_itm_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[etitxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[etitxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[etitxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[etitxmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[etitxmst] TO PUBLIC
    AS [dbo];

