CREATE TABLE [dbo].[agcrdmst] (
    [agcrd_cus_no]             CHAR (10)       NOT NULL,
    [agcrd_rev_dt]             INT             NOT NULL,
    [agcrd_seq_no]             SMALLINT        NOT NULL,
    [agcrd_type]               CHAR (1)        NULL,
    [agcrd_ref_no]             CHAR (8)        NULL,
    [agcrd_amt]                DECIMAL (11, 2) NULL,
    [agcrd_amt_used]           DECIMAL (11, 2) NULL,
    [agcrd_cred_ind]           CHAR (1)        NULL,
    [agcrd_acct_no]            DECIMAL (16, 8) NULL,
    [agcrd_loc_no]             CHAR (3)        NULL,
    [agcrd_note]               CHAR (15)       NULL,
    [agcrd_batch_no]           SMALLINT        NULL,
    [agcrd_audit_no]           CHAR (4)        NULL,
    [agcrd_eft_in_progress_yn] CHAR (1)        NULL,
    [agcrd_currency]           CHAR (3)        NULL,
    [agcrd_currency_rt]        DECIMAL (15, 8) NULL,
    [agcrd_currency_cnt]       CHAR (8)        NULL,
    [agcrd_pay_type]           CHAR (1)        NULL,
    [agcrd_user_id]            CHAR (16)       NULL,
    [agcrd_user_rev_dt]        INT             NULL,
    [A4GLIdentity]             NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agcrdmst] PRIMARY KEY NONCLUSTERED ([agcrd_cus_no] ASC, [agcrd_rev_dt] ASC, [agcrd_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagcrdmst0]
    ON [dbo].[agcrdmst]([agcrd_cus_no] ASC, [agcrd_rev_dt] ASC, [agcrd_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agcrdmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agcrdmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agcrdmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agcrdmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agcrdmst] TO PUBLIC
    AS [dbo];

