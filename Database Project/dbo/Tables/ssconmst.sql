CREATE TABLE [dbo].[ssconmst] (
    [sscon_contact_id]    CHAR (20)   NOT NULL,
    [sscon_cus_no]        CHAR (10)   NOT NULL,
    [sscon_lead_id]       CHAR (10)   NOT NULL,
    [sscon_loc_id]        CHAR (10)   NOT NULL,
    [sscon_vnd_no]        CHAR (10)   NOT NULL,
    [sscon_salutation]    CHAR (4)    NULL,
    [sscon_first_name]    CHAR (22)   NULL,
    [sscon_mid_initial]   CHAR (1)    NULL,
    [sscon_last_name]     CHAR (25)   NULL,
    [sscon_suffix]        CHAR (2)    NULL,
    [sscon_contact_title] CHAR (50)   NULL,
    [sscon_work_no]       CHAR (15)   NULL,
    [sscon_work_ext]      CHAR (4)    NULL,
    [sscon_home_no]       CHAR (15)   NULL,
    [sscon_home_ext]      CHAR (4)    NULL,
    [sscon_cell_no]       CHAR (15)   NULL,
    [sscon_cell_ext]      CHAR (4)    NULL,
    [sscon_fax_no]        CHAR (15)   NULL,
    [sscon_fax_ext]       CHAR (4)    NULL,
    [sscon_email]         CHAR (64)   NULL,
    [sscon_mail_addr1]    CHAR (30)   NULL,
    [sscon_mail_addr2]    CHAR (30)   NULL,
    [sscon_mail_city]     CHAR (20)   NULL,
    [sscon_mail_state]    CHAR (2)    NULL,
    [sscon_mail_zip]      CHAR (10)   NULL,
    [sscon_mail_country]  CHAR (3)    NULL,
    [sscon_work_addr1]    CHAR (30)   NULL,
    [sscon_work_addr2]    CHAR (30)   NULL,
    [sscon_work_city]     CHAR (20)   NULL,
    [sscon_work_state]    CHAR (2)    NULL,
    [sscon_work_zip]      CHAR (10)   NULL,
    [sscon_work_country]  CHAR (3)    NULL,
    [sscon_home_addr1]    CHAR (30)   NULL,
    [sscon_home_addr2]    CHAR (30)   NULL,
    [sscon_home_city]     CHAR (20)   NULL,
    [sscon_home_state]    CHAR (2)    NULL,
    [sscon_home_zip]      CHAR (10)   NULL,
    [sscon_home_country]  CHAR (3)    NULL,
    [sscon_comments]      CHAR (256)  NULL,
    [sscon_timestamp]     CHAR (19)   NULL,
    [sscon_sales_mailer]  CHAR (1)    NULL,
    [sscon_user_id]       CHAR (16)   NULL,
    [sscon_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ssconmst] PRIMARY KEY NONCLUSTERED ([sscon_contact_id] ASC, [sscon_cus_no] ASC, [sscon_lead_id] ASC, [sscon_loc_id] ASC, [sscon_vnd_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Issconmst0]
    ON [dbo].[ssconmst]([sscon_contact_id] ASC, [sscon_cus_no] ASC, [sscon_lead_id] ASC, [sscon_loc_id] ASC, [sscon_vnd_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Issconmst1]
    ON [dbo].[ssconmst]([sscon_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Issconmst2]
    ON [dbo].[ssconmst]([sscon_cus_no] ASC, [sscon_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Issconmst3]
    ON [dbo].[ssconmst]([sscon_lead_id] ASC, [sscon_loc_id] ASC, [sscon_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Issconmst4]
    ON [dbo].[ssconmst]([sscon_vnd_no] ASC, [sscon_contact_id] ASC);

