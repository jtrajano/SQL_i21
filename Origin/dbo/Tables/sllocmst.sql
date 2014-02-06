CREATE TABLE [dbo].[sllocmst] (
    [slloc_lead_id]             CHAR (10)   NOT NULL,
    [slloc_loc_id]              CHAR (10)   NOT NULL,
    [slloc_name]                CHAR (50)   NOT NULL,
    [slloc_addr1]               CHAR (30)   NULL,
    [slloc_addr2]               CHAR (30)   NULL,
    [slloc_city]                CHAR (20)   NULL,
    [slloc_state]               CHAR (2)    NULL,
    [slloc_zip]                 CHAR (10)   NOT NULL,
    [slloc_area]                CHAR (4)    NOT NULL,
    [slloc_slsmn_id]            CHAR (3)    NOT NULL,
    [slloc_phone]               CHAR (15)   NOT NULL,
    [slloc_phone_ext]           CHAR (5)    NULL,
    [slloc_fax_no]              CHAR (15)   NULL,
    [slloc_fax_ext]             CHAR (5)    NULL,
    [slloc_contact_name_1]      CHAR (25)   NULL,
    [slloc_contact_name_2]      CHAR (25)   NULL,
    [slloc_contact_name_3]      CHAR (25)   NULL,
    [slloc_contact_name_4]      CHAR (25)   NULL,
    [slloc_contact_phone_1]     CHAR (15)   NULL,
    [slloc_contact_phone_2]     CHAR (15)   NULL,
    [slloc_contact_phone_3]     CHAR (15)   NULL,
    [slloc_contact_phone_4]     CHAR (15)   NULL,
    [slloc_contact_phone_ext_1] CHAR (5)    NULL,
    [slloc_contact_phone_ext_2] CHAR (5)    NULL,
    [slloc_contact_phone_ext_3] CHAR (5)    NULL,
    [slloc_contact_phone_ext_4] CHAR (5)    NULL,
    [slloc_contact_mail_yn_1]   CHAR (1)    NULL,
    [slloc_contact_mail_yn_2]   CHAR (1)    NULL,
    [slloc_contact_mail_yn_3]   CHAR (1)    NULL,
    [slloc_contact_mail_yn_4]   CHAR (1)    NULL,
    [slloc_lead_type]           CHAR (5)    NULL,
    [slloc_cls_value1]          CHAR (4)    NULL,
    [slloc_cls_value2]          CHAR (4)    NULL,
    [slloc_cls_value3]          CHAR (4)    NULL,
    [slloc_cls_value4]          CHAR (4)    NULL,
    [slloc_cls_value5]          CHAR (4)    NULL,
    [slloc_curr_sls_cyc]        TINYINT     NULL,
    [slloc_last_sale_rev_dt]    INT         NULL,
    [slloc_last_mkt_src]        CHAR (6)    NULL,
    [slloc_uspo_err_cd]         CHAR (5)    NULL,
    [slloc_note1]               CHAR (45)   NULL,
    [slloc_note2]               CHAR (45)   NULL,
    [slloc_note3]               CHAR (45)   NULL,
    [slloc_prc_level]           CHAR (1)    NULL,
    [slloc_src_file]            CHAR (5)    NOT NULL,
    [slloc_src_key]             CHAR (20)   NOT NULL,
    [slloc_email]               CHAR (40)   NULL,
    [slloc_user_id]             CHAR (16)   NULL,
    [slloc_user_rev_dt]         INT         NULL,
    [A4GLIdentity]              NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sllocmst] PRIMARY KEY NONCLUSTERED ([slloc_lead_id] ASC, [slloc_loc_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isllocmst0]
    ON [dbo].[sllocmst]([slloc_lead_id] ASC, [slloc_loc_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Isllocmst1]
    ON [dbo].[sllocmst]([slloc_name] ASC);


GO
CREATE NONCLUSTERED INDEX [Isllocmst2]
    ON [dbo].[sllocmst]([slloc_zip] ASC);


GO
CREATE NONCLUSTERED INDEX [Isllocmst3]
    ON [dbo].[sllocmst]([slloc_area] ASC);


GO
CREATE NONCLUSTERED INDEX [Isllocmst4]
    ON [dbo].[sllocmst]([slloc_slsmn_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Isllocmst5]
    ON [dbo].[sllocmst]([slloc_phone] ASC);


GO
CREATE NONCLUSTERED INDEX [Isllocmst6]
    ON [dbo].[sllocmst]([slloc_src_file] ASC, [slloc_src_key] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[sllocmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sllocmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sllocmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sllocmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sllocmst] TO PUBLIC
    AS [dbo];

