CREATE TABLE [dbo].[aglclmst] (
    [aglcl_tax_state]     CHAR (2)    NOT NULL,
    [aglcl_tax_auth_id1]  CHAR (3)    NOT NULL,
    [aglcl_tax_auth_id2]  CHAR (3)    NOT NULL,
    [aglcl_auth_id1_desc] CHAR (30)   NULL,
    [aglcl_auth_id2_desc] CHAR (30)   NULL,
    [aglcl_fet_ivc_desc]  CHAR (20)   NULL,
    [aglcl_set_ivc_desc]  CHAR (20)   NULL,
    [aglcl_lc1_ivc_desc]  CHAR (20)   NULL,
    [aglcl_lc2_ivc_desc]  CHAR (20)   NULL,
    [aglcl_lc3_ivc_desc]  CHAR (20)   NULL,
    [aglcl_lc4_ivc_desc]  CHAR (20)   NULL,
    [aglcl_lc5_ivc_desc]  CHAR (20)   NULL,
    [aglcl_lc6_ivc_desc]  CHAR (20)   NULL,
    [aglcl_send_to_et_yn] CHAR (1)    NULL,
    [aglcl_user_id]       CHAR (16)   NULL,
    [aglcl_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_aglclmst] PRIMARY KEY NONCLUSTERED ([aglcl_tax_state] ASC, [aglcl_tax_auth_id1] ASC, [aglcl_tax_auth_id2] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iaglclmst0]
    ON [dbo].[aglclmst]([aglcl_tax_state] ASC, [aglcl_tax_auth_id1] ASC, [aglcl_tax_auth_id2] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[aglclmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[aglclmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[aglclmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[aglclmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[aglclmst] TO PUBLIC
    AS [dbo];

