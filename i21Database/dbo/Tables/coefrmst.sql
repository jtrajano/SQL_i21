CREATE TABLE [dbo].[coefrmst] (
    [coefr_contact_id]       CHAR (20)   NOT NULL,
    [coefr_type]             CHAR (5)    NOT NULL,
    [coefr_form_id]          CHAR (16)   NOT NULL,
    [coefr_init_timestamp]   CHAR (19)   NOT NULL,
    [coefr_lot_no]           SMALLINT    NOT NULL,
    [coefr_company_id]       CHAR (2)    NULL,
    [coefr_notify_email]     CHAR (50)   NULL,
    [coefr_notify_type]      CHAR (5)    NULL,
    [coefr_from_name]        CHAR (25)   NULL,
    [coefr_from_email]       CHAR (64)   NULL,
    [coefr_from_fax]         CHAR (25)   NULL,
    [coefr_to_email]         CHAR (64)   NULL,
    [coefr_to_fax]           CHAR (25)   NULL,
    [coefr_subject]          CHAR (60)   NULL,
    [coefr_body]             CHAR (550)  NULL,
    [coefr_footer]           CHAR (550)  NULL,
    [coefr_read_receipt]     CHAR (1)    NULL,
    [coefr_delivery_receipt] CHAR (1)    NULL,
    [coefr_delv_timestamp]   CHAR (19)   NULL,
    [coefr_status]           CHAR (15)   NOT NULL,
    [coefr_status_msg]       CHAR (50)   NULL,
    [coefr_created_by]       CHAR (16)   NOT NULL,
    [coefr_form_type]        CHAR (3)    NOT NULL,
    [coefr_filename]         CHAR (100)  NULL,
    [coefr_cus_no]           CHAR (10)   NOT NULL,
    [coefr_vnd_no]           CHAR (10)   NOT NULL,
    [coefr_contact_point]    CHAR (20)   NOT NULL,
    [coefr_loc_no]           CHAR (3)    NOT NULL,
    [coefr_init_ts_rev]      CHAR (14)   NOT NULL,
    [coefr_select_yn]        CHAR (1)    NOT NULL,
    [coefr_efi_key]          CHAR (81)   NULL,
    [A4GLIdentity]           NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_coefrmst] PRIMARY KEY NONCLUSTERED ([coefr_contact_id] ASC, [coefr_type] ASC, [coefr_form_id] ASC, [coefr_init_timestamp] ASC, [coefr_lot_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icoefrmst0]
    ON [dbo].[coefrmst]([coefr_contact_id] ASC, [coefr_type] ASC, [coefr_form_id] ASC, [coefr_init_timestamp] ASC, [coefr_lot_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst1]
    ON [dbo].[coefrmst]([coefr_contact_id] ASC, [coefr_init_ts_rev] ASC, [coefr_lot_no] ASC, [coefr_created_by] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst10]
    ON [dbo].[coefrmst]([coefr_loc_no] ASC, [coefr_init_ts_rev] ASC, [coefr_lot_no] ASC, [coefr_created_by] ASC, [coefr_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst11]
    ON [dbo].[coefrmst]([coefr_init_ts_rev] ASC, [coefr_lot_no] ASC, [coefr_created_by] ASC, [coefr_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst12]
    ON [dbo].[coefrmst]([coefr_select_yn] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst2]
    ON [dbo].[coefrmst]([coefr_form_id] ASC, [coefr_init_ts_rev] ASC, [coefr_lot_no] ASC, [coefr_created_by] ASC, [coefr_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst3]
    ON [dbo].[coefrmst]([coefr_lot_no] ASC, [coefr_init_ts_rev] ASC, [coefr_created_by] ASC, [coefr_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst4]
    ON [dbo].[coefrmst]([coefr_status] ASC, [coefr_init_ts_rev] ASC, [coefr_lot_no] ASC, [coefr_created_by] ASC, [coefr_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst5]
    ON [dbo].[coefrmst]([coefr_created_by] ASC, [coefr_init_ts_rev] ASC, [coefr_lot_no] ASC, [coefr_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst6]
    ON [dbo].[coefrmst]([coefr_form_type] ASC, [coefr_init_ts_rev] ASC, [coefr_lot_no] ASC, [coefr_created_by] ASC, [coefr_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst7]
    ON [dbo].[coefrmst]([coefr_cus_no] ASC, [coefr_init_ts_rev] ASC, [coefr_lot_no] ASC, [coefr_created_by] ASC, [coefr_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst8]
    ON [dbo].[coefrmst]([coefr_vnd_no] ASC, [coefr_init_ts_rev] ASC, [coefr_lot_no] ASC, [coefr_created_by] ASC, [coefr_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefrmst9]
    ON [dbo].[coefrmst]([coefr_contact_point] ASC, [coefr_init_ts_rev] ASC, [coefr_lot_no] ASC, [coefr_created_by] ASC, [coefr_contact_id] ASC);

