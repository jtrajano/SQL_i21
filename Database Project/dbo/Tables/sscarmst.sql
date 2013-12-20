CREATE TABLE [dbo].[sscarmst] (
    [sscar_key]          CHAR (10)   NOT NULL,
    [sscar_name]         CHAR (20)   NULL,
    [sscar_addr]         CHAR (30)   NULL,
    [sscar_city]         CHAR (20)   NULL,
    [sscar_state]        CHAR (2)    NULL,
    [sscar_zip]          CHAR (9)    NULL,
    [sscar_fed_id]       CHAR (15)   NULL,
    [sscar_trans_mode]   CHAR (2)    NULL,
    [sscar_in_sf401_yn]  CHAR (1)    NULL,
    [sscar_trans_lic_no] CHAR (15)   NULL,
    [sscar_ifta_no]      CHAR (15)   NULL,
    [sscar_mi_c3859_yn]  CHAR (1)    NULL,
    [sscar_il_rpt_yn]    CHAR (1)    NULL,
    [sscar_oh_cc22_yn]   CHAR (1)    NULL,
    [sscar_co_owned_yn]  CHAR (1)    NULL,
    [sscar_user_id]      CHAR (16)   NULL,
    [sscar_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sscarmst] PRIMARY KEY NONCLUSTERED ([sscar_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isscarmst0]
    ON [dbo].[sscarmst]([sscar_key] ASC);

