CREATE TABLE [dbo].[spprcmst] (
    [spprc_cus_no]          CHAR (10)       NOT NULL,
    [spprc_itm_no]          CHAR (13)       NOT NULL,
    [spprc_class]           CHAR (3)        NOT NULL,
    [spprc_basis_ind]       CHAR (1)        NULL,
    [spprc_begin_rev_dt]    INT             NULL,
    [spprc_end_rev_dt]      INT             NULL,
    [spprc_factor]          DECIMAL (11, 5) NULL,
    [spprc_comment]         CHAR (15)       NULL,
    [spprc_cost_to_use_las] CHAR (1)        NULL,
    [spprc_qty_disc_by_pa]  CHAR (1)        NULL,
    [spprc_units_1]         DECIMAL (11, 4) NULL,
    [spprc_units_2]         DECIMAL (11, 4) NULL,
    [spprc_units_3]         DECIMAL (11, 4) NULL,
    [spprc_disc_per_un_1]   DECIMAL (11, 5) NULL,
    [spprc_disc_per_un_2]   DECIMAL (11, 5) NULL,
    [spprc_disc_per_un_3]   DECIMAL (11, 5) NULL,
    [spprc_fet_yn]          CHAR (1)        NULL,
    [spprc_set_yn]          CHAR (1)        NULL,
    [spprc_sst_ynp]         CHAR (1)        NULL,
    [spprc_lc1_yn]          CHAR (1)        NULL,
    [spprc_lc2_yn]          CHAR (1)        NULL,
    [spprc_lc3_yn]          CHAR (1)        NULL,
    [spprc_lc4_yn]          CHAR (1)        NULL,
    [spprc_lc5_yn]          CHAR (1)        NULL,
    [spprc_lc6_yn]          CHAR (1)        NULL,
    [spprc_user_id]         CHAR (16)       NULL,
    [spprc_user_rev_dt]     CHAR (8)        NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_spprcmst] PRIMARY KEY NONCLUSTERED ([spprc_cus_no] ASC, [spprc_itm_no] ASC, [spprc_class] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ispprcmst0]
    ON [dbo].[spprcmst]([spprc_cus_no] ASC, [spprc_itm_no] ASC, [spprc_class] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[spprcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[spprcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[spprcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[spprcmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[spprcmst] TO PUBLIC
    AS [dbo];

