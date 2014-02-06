CREATE TABLE [dbo].[coefimst] (
    [coefi_pgm_id]            CHAR (12)   NOT NULL,
    [coefi_cus_id]            CHAR (15)   NOT NULL,
    [coefi_form_type]         CHAR (3)    NOT NULL,
    [coefi_id_no]             CHAR (16)   NOT NULL,
    [coefi_loc_no]            CHAR (3)    NOT NULL,
    [coefi_run_date]          INT         NOT NULL,
    [coefi_run_time]          INT         NOT NULL,
    [coefi_user_id]           CHAR (16)   NOT NULL,
    [coefi_batch_no]          SMALLINT    NOT NULL,
    [coefi_delete_date]       INT         NOT NULL,
    [coefi_date_deleted]      INT         NULL,
    [coefi_no_pages]          INT         NULL,
    [coefi_filesize]          BIGINT      NULL,
    [coefi_filename]          CHAR (64)   NULL,
    [coefi_last_printed_dt]   INT         NULL,
    [coefi_select_yn]         CHAR (1)    NOT NULL,
    [coefi_status]            CHAR (2)    NOT NULL,
    [coefi_deleted_by]        CHAR (16)   NULL,
    [coefi_has_esig_yn]       CHAR (1)    NULL,
    [coefi_esig_or_reason]    CHAR (50)   NULL,
    [coefi_bill_to_cus]       CHAR (10)   NULL,
    [coefi_addendum_yn]       CHAR (1)    NULL,
    [coefi_addendum_filename] CHAR (64)   NULL,
    [coefi_chg_user_id]       CHAR (16)   NULL,
    [coefi_chg_user_rev_dt]   INT         NULL,
    [A4GLIdentity]            NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_coefimst] PRIMARY KEY NONCLUSTERED ([coefi_pgm_id] ASC, [coefi_cus_id] ASC, [coefi_form_type] ASC, [coefi_id_no] ASC, [coefi_loc_no] ASC, [coefi_run_date] ASC, [coefi_run_time] ASC, [coefi_user_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icoefimst0]
    ON [dbo].[coefimst]([coefi_pgm_id] ASC, [coefi_cus_id] ASC, [coefi_form_type] ASC, [coefi_id_no] ASC, [coefi_loc_no] ASC, [coefi_run_date] ASC, [coefi_run_time] ASC, [coefi_user_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst1]
    ON [dbo].[coefimst]([coefi_cus_id] ASC, [coefi_form_type] ASC, [coefi_id_no] ASC, [coefi_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst10]
    ON [dbo].[coefimst]([coefi_status] ASC, [coefi_id_no] ASC, [coefi_run_date] ASC, [coefi_run_time] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst11]
    ON [dbo].[coefimst]([coefi_status] ASC, [coefi_form_type] ASC, [coefi_run_date] ASC, [coefi_run_time] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst2]
    ON [dbo].[coefimst]([coefi_run_date] ASC, [coefi_batch_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst3]
    ON [dbo].[coefimst]([coefi_delete_date] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst4]
    ON [dbo].[coefimst]([coefi_select_yn] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst5]
    ON [dbo].[coefimst]([coefi_status] ASC, [coefi_user_id] ASC, [coefi_run_date] ASC, [coefi_run_time] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst6]
    ON [dbo].[coefimst]([coefi_status] ASC, [coefi_run_date] ASC, [coefi_run_time] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst7]
    ON [dbo].[coefimst]([coefi_status] ASC, [coefi_batch_no] ASC, [coefi_run_date] ASC, [coefi_run_time] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst8]
    ON [dbo].[coefimst]([coefi_status] ASC, [coefi_cus_id] ASC, [coefi_run_date] ASC, [coefi_run_time] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefimst9]
    ON [dbo].[coefimst]([coefi_status] ASC, [coefi_loc_no] ASC, [coefi_run_date] ASC, [coefi_run_time] ASC);

