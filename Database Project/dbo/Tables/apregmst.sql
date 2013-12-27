CREATE TABLE [dbo].[apregmst] (
    [apreg_cbk_no]               CHAR (2)        NOT NULL,
    [apreg_chk_no]               CHAR (8)        NOT NULL,
    [apreg_vnd_no]               CHAR (10)       NOT NULL,
    [apreg_ivc_no]               CHAR (18)       NOT NULL,
    [apreg_seq_no]               TINYINT         NOT NULL,
    [apreg_chk_type]             CHAR (1)        NULL,
    [apreg_name]                 CHAR (50)       NULL,
    [apreg_addr_1]               CHAR (30)       NULL,
    [apreg_addr_2]               CHAR (30)       NULL,
    [apreg_city]                 CHAR (20)       NULL,
    [apreg_st]                   CHAR (2)        NULL,
    [apreg_zip]                  CHAR (10)       NULL,
    [apreg_tot_chk_amt]          DECIMAL (11, 2) NULL,
    [apreg_chk_rev_dt]           INT             NULL,
    [apreg_man_auto_ind]         CHAR (1)        NULL,
    [apreg_chk_src_ind]          CHAR (1)        NULL,
    [apreg_tot_chk_currency_amt] DECIMAL (11, 2) NULL,
    [apreg_ivc_type]             CHAR (1)        NULL,
    [apreg_wthhld_amt]           DECIMAL (11, 2) NULL,
    [apreg_disc_taken]           DECIMAL (11, 2) NULL,
    [apreg_net_chk_amt]          DECIMAL (11, 2) NULL,
    [apreg_ivc_on_stub_yn]       CHAR (1)        NULL,
    [apreg_currency_rt]          DECIMAL (15, 8) NULL,
    [apreg_ivc_rev_dt]           CHAR (8)        NULL,
    [A4GLIdentity]               NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apregmst] PRIMARY KEY NONCLUSTERED ([apreg_cbk_no] ASC, [apreg_chk_no] ASC, [apreg_vnd_no] ASC, [apreg_ivc_no] ASC, [apreg_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapregmst0]
    ON [dbo].[apregmst]([apreg_cbk_no] ASC, [apreg_chk_no] ASC, [apreg_vnd_no] ASC, [apreg_ivc_no] ASC, [apreg_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iapregmst1]
    ON [dbo].[apregmst]([apreg_vnd_no] ASC, [apreg_ivc_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apregmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apregmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apregmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apregmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apregmst] TO PUBLIC
    AS [dbo];

