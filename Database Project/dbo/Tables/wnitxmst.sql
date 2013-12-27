CREATE TABLE [dbo].[wnitxmst] (
    [wnitx_itm_no]      CHAR (13)      NOT NULL,
    [wnitx_wn_itm_no]   CHAR (20)      NOT NULL,
    [wnitx_pak_size]    CHAR (25)      NULL,
    [wnitx_un_desc]     CHAR (2)       NULL,
    [wnitx_un_conv]     DECIMAL (9, 4) NULL,
    [wnitx_comments]    CHAR (43)      NULL,
    [wnitx_xmit_yn]     CHAR (1)       NULL,
    [wnitx_user_id]     CHAR (16)      NULL,
    [wnitx_user_rev_dt] CHAR (8)       NULL,
    [A4GLIdentity]      NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_wnitxmst] PRIMARY KEY NONCLUSTERED ([wnitx_itm_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iwnitxmst0]
    ON [dbo].[wnitxmst]([wnitx_itm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iwnitxmst1]
    ON [dbo].[wnitxmst]([wnitx_wn_itm_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[wnitxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[wnitxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[wnitxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[wnitxmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[wnitxmst] TO PUBLIC
    AS [dbo];

