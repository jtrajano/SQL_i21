CREATE TABLE [dbo].[agopymst] (
    [agopy_cus_no]       CHAR (10)       NOT NULL,
    [agopy_ivc_no]       CHAR (8)        NOT NULL,
    [agopy_ivc_loc_no]   CHAR (3)        NOT NULL,
    [agopy_seq_no]       SMALLINT        NOT NULL,
    [agopy_rev_dt]       INT             NULL,
    [agopy_chk_no]       CHAR (8)        NULL,
    [agopy_amt]          DECIMAL (11, 2) NULL,
    [agopy_acct_no]      DECIMAL (16, 8) NULL,
    [agopy_batch_no]     SMALLINT        NULL,
    [agopy_pay_type]     CHAR (1)        NULL,
    [agopy_currency]     CHAR (3)        NULL,
    [agopy_currency_rt]  DECIMAL (15, 8) NULL,
    [agopy_currency_cnt] CHAR (8)        NULL,
    [agopy_note]         CHAR (15)       NULL,
    [agopy_user_id]      CHAR (16)       NULL,
    [agopy_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agopymst] PRIMARY KEY NONCLUSTERED ([agopy_cus_no] ASC, [agopy_ivc_no] ASC, [agopy_ivc_loc_no] ASC, [agopy_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagopymst0]
    ON [dbo].[agopymst]([agopy_cus_no] ASC, [agopy_ivc_no] ASC, [agopy_ivc_loc_no] ASC, [agopy_seq_no] ASC);

