CREATE TABLE [dbo].[eclogmst] (
    [eclog_username]        CHAR (20)       NOT NULL,
    [eclog_cust_no]         CHAR (10)       NOT NULL,
    [eclog_trx_type]        CHAR (3)        NOT NULL,
    [eclog_date_posted]     INT             NOT NULL,
    [eclog_time_posted]     INT             NOT NULL,
    [eclog_line_no]         SMALLINT        NOT NULL,
    [eclog_dest_system]     CHAR (2)        NULL,
    [eclog_trx_desc]        CHAR (30)       NULL,
    [eclog_ref_no]          CHAR (8)        NULL,
    [eclog_loc_no]          CHAR (3)        NULL,
    [eclog_dest_email_addr] CHAR (50)       NULL,
    [eclog_pmt_amount]      DECIMAL (14, 5) NULL,
    [eclog_pmt_pay_type]    CHAR (3)        NULL,
    [eclog_pmt_rec_type]    CHAR (2)        NULL,
    [eclog_tar_com_cd]      CHAR (3)        NULL,
    [eclog_tar_no_un]       INT             NULL,
    [eclog_tar_un_prc]      DECIMAL (9, 5)  NULL,
    [eclog_tar_due_yyyymm]  INT             NULL,
    [eclog_tar_comments]    CHAR (16)       NULL,
    [eclog_from_email_addr] CHAR (50)       NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_eclogmst] PRIMARY KEY NONCLUSTERED ([eclog_username] ASC, [eclog_cust_no] ASC, [eclog_trx_type] ASC, [eclog_date_posted] ASC, [eclog_time_posted] ASC, [eclog_line_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ieclogmst0]
    ON [dbo].[eclogmst]([eclog_username] ASC, [eclog_cust_no] ASC, [eclog_trx_type] ASC, [eclog_date_posted] ASC, [eclog_time_posted] ASC, [eclog_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ieclogmst1]
    ON [dbo].[eclogmst]([eclog_cust_no] ASC, [eclog_trx_type] ASC, [eclog_date_posted] ASC, [eclog_time_posted] ASC, [eclog_line_no] ASC);

