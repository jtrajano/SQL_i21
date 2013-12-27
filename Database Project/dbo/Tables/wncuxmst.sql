CREATE TABLE [dbo].[wncuxmst] (
    [wncux_cus_no]      CHAR (10)   NOT NULL,
    [wncux_wn_cus_no]   CHAR (16)   NOT NULL,
    [wncux_hp_cus_no]   CHAR (16)   NULL,
    [wncux_comments]    CHAR (30)   NULL,
    [wncux_xmit_yn]     CHAR (1)    NULL,
    [wncux_user_id]     CHAR (16)   NULL,
    [wncux_user_rev_dt] CHAR (8)    NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iwncuxmst0]
    ON [dbo].[wncuxmst]([wncux_cus_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iwncuxmst1]
    ON [dbo].[wncuxmst]([wncux_wn_cus_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[wncuxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[wncuxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[wncuxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[wncuxmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[wncuxmst] TO PUBLIC
    AS [dbo];

