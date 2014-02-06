CREATE TABLE [dbo].[ssvtxmst] (
    [ssvtx_vnd_no]      CHAR (10)   NOT NULL,
    [ssvtx_itm_no]      CHAR (13)   NOT NULL,
    [ssvtx_cls_no]      CHAR (3)    NOT NULL,
    [ssvtx_fet_yn]      CHAR (1)    NULL,
    [ssvtx_set_yn]      CHAR (1)    NULL,
    [ssvtx_sst_ynp]     CHAR (1)    NULL,
    [ssvtx_if_yn]       CHAR (1)    NULL,
    [ssvtx_lc1_yn]      CHAR (1)    NULL,
    [ssvtx_lc2_yn]      CHAR (1)    NULL,
    [ssvtx_lc3_yn]      CHAR (1)    NULL,
    [ssvtx_lc4_yn]      CHAR (1)    NULL,
    [ssvtx_lc5_yn]      CHAR (1)    NULL,
    [ssvtx_lc6_yn]      CHAR (1)    NULL,
    [ssvtx_lc7_yn]      CHAR (1)    NULL,
    [ssvtx_lc8_yn]      CHAR (1)    NULL,
    [ssvtx_lc9_yn]      CHAR (1)    NULL,
    [ssvtx_lc10_yn]     CHAR (1)    NULL,
    [ssvtx_lc11_yn]     CHAR (1)    NULL,
    [ssvtx_lc12_yn]     CHAR (1)    NULL,
    [ssvtx_user_id]     CHAR (16)   NULL,
    [ssvtx_user_rev_dt] CHAR (8)    NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ssvtxmst] PRIMARY KEY NONCLUSTERED ([ssvtx_vnd_no] ASC, [ssvtx_itm_no] ASC, [ssvtx_cls_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Issvtxmst0]
    ON [dbo].[ssvtxmst]([ssvtx_vnd_no] ASC, [ssvtx_itm_no] ASC, [ssvtx_cls_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[ssvtxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ssvtxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ssvtxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ssvtxmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ssvtxmst] TO PUBLIC
    AS [dbo];

