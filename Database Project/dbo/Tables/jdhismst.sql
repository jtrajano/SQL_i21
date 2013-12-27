CREATE TABLE [dbo].[jdhismst] (
    [jdhis_cus_no]           CHAR (10)      NOT NULL,
    [jdhis_ivc_no]           CHAR (8)       NOT NULL,
    [jdhis_loc_no]           CHAR (3)       NOT NULL,
    [jdhis_type]             CHAR (20)      NOT NULL,
    [jdhis_ord_date]         CHAR (8)       NOT NULL,
    [jdhis_status]           CHAR (1)       NULL,
    [jdhis_amount]           DECIMAL (9, 2) NULL,
    [jdhis_auth_no]          INT            NULL,
    [jdhis_product_line]     CHAR (10)      NULL,
    [jdhis_cus_acct_no]      CHAR (16)      NULL,
    [jdhis_merchant_no]      CHAR (8)       NULL,
    [jdhis_store]            CHAR (4)       NULL,
    [jdhis_terminal]         CHAR (3)       NULL,
    [jdhis_crd_plan_no]      INT            NULL,
    [jdhis_crd_plan_desc]    CHAR (40)      NULL,
    [jdhis_bill_code]        INT            NULL,
    [jdhis_bill_code_desc]   CHAR (40)      NULL,
    [jdhis_terms1]           CHAR (50)      NULL,
    [jdhis_terms2]           CHAR (50)      NULL,
    [jdhis_terms3]           CHAR (50)      NULL,
    [jdhis_terms4]           CHAR (50)      NULL,
    [jdhis_terms5]           CHAR (50)      NULL,
    [jdhis_terms6]           CHAR (50)      NULL,
    [jdhis_terms7]           CHAR (50)      NULL,
    [jdhis_terms_conditions] CHAR (350)     NULL,
    [jdhis_repayment_terms]  CHAR (550)     NULL,
    [jdhis_file_location]    CHAR (64)      NULL,
    [jdhis_timestamp]        CHAR (25)      NOT NULL,
    [jdhis_select_yn]        CHAR (1)       NOT NULL,
    [jdhis_approve_date]     CHAR (8)       NULL,
    [jdhis_orig_ivc_no]      CHAR (8)       NULL,
    [jdhis_manual_auth]      CHAR (1)       NOT NULL,
    [jdhis_status_msg]       CHAR (80)      NULL,
    [jdhis_id]               CHAR (8)       NULL,
    [jdhis_reference]        CHAR (6)       NULL,
    [jdhis_c2client_status]  CHAR (3)       NULL,
    [jdhis_user_id]          CHAR (16)      NULL,
    [jdhis_user_rev_dt]      INT            NULL,
    [A4GLIdentity]           NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_jdhismst] PRIMARY KEY NONCLUSTERED ([jdhis_cus_no] ASC, [jdhis_ivc_no] ASC, [jdhis_loc_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ijdhismst0]
    ON [dbo].[jdhismst]([jdhis_cus_no] ASC, [jdhis_ivc_no] ASC, [jdhis_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdhismst1]
    ON [dbo].[jdhismst]([jdhis_cus_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdhismst2]
    ON [dbo].[jdhismst]([jdhis_ivc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdhismst3]
    ON [dbo].[jdhismst]([jdhis_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdhismst4]
    ON [dbo].[jdhismst]([jdhis_type] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdhismst5]
    ON [dbo].[jdhismst]([jdhis_ord_date] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdhismst6]
    ON [dbo].[jdhismst]([jdhis_timestamp] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdhismst7]
    ON [dbo].[jdhismst]([jdhis_select_yn] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdhismst8]
    ON [dbo].[jdhismst]([jdhis_manual_auth] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[jdhismst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[jdhismst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[jdhismst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[jdhismst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[jdhismst] TO PUBLIC
    AS [dbo];

