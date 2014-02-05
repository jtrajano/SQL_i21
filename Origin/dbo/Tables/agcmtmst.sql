CREATE TABLE [dbo].[agcmtmst] (
    [agcmt_cus_no]         CHAR (10)   NOT NULL,
    [agcmt_com_typ]        CHAR (3)    NOT NULL,
    [agcmt_com_cd]         CHAR (3)    NOT NULL,
    [agcmt_com_seq]        CHAR (1)    NOT NULL,
    [agcmt_data]           CHAR (69)   NULL,
    [agcmt_payee_1]        CHAR (30)   NULL,
    [agcmt_payee_2]        CHAR (30)   NULL,
    [agcmt_rc_lic_no]      CHAR (12)   NULL,
    [agcmt_rc_exp_rev_dt]  INT         NULL,
    [agcmt_rc_comment]     CHAR (30)   NULL,
    [agcmt_rc_custom_yn]   CHAR (1)    NULL,
    [agcmt_tr_ins_no]      CHAR (12)   NULL,
    [agcmt_tr_exp_rev_dt]  INT         NULL,
    [agcmt_tr_comment]     CHAR (30)   NULL,
    [agcmt_ord_comment1]   CHAR (30)   NULL,
    [agcmt_ord_comment2]   CHAR (30)   NULL,
    [agcmt_fax_contact]    CHAR (30)   NULL,
    [agcmt_fax_to_fax_num] CHAR (24)   NULL,
    [agcmt_eml_contact]    CHAR (30)   NULL,
    [agcmt_eml_address]    CHAR (39)   NULL,
    [agcmt_stl_lic_no]     CHAR (15)   NULL,
    [agcmt_stl_exp_rev_dt] INT         NULL,
    [agcmt_stl_comment]    CHAR (30)   NULL,
    [agcmt_user_id]        CHAR (16)   NULL,
    [agcmt_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agcmtmst] PRIMARY KEY NONCLUSTERED ([agcmt_cus_no] ASC, [agcmt_com_typ] ASC, [agcmt_com_cd] ASC, [agcmt_com_seq] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagcmtmst0]
    ON [dbo].[agcmtmst]([agcmt_cus_no] ASC, [agcmt_com_typ] ASC, [agcmt_com_cd] ASC, [agcmt_com_seq] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iagcmtmst1]
    ON [dbo].[agcmtmst]([agcmt_com_typ] ASC, [agcmt_cus_no] ASC, [agcmt_com_cd] ASC, [agcmt_com_seq] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agcmtmst] TO PUBLIC
    AS [dbo];

