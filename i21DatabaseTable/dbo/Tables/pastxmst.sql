CREATE TABLE [dbo].[pastxmst] (
    [pastx_cus_no]           CHAR (10)      NOT NULL,
    [pastx_cert_no]          CHAR (8)       NOT NULL,
    [pastx_stock_status]     CHAR (1)       NULL,
    [pastx_stock_type]       TINYINT        NULL,
    [pastx_no_shares]        DECIMAL (9, 2) NULL,
    [pastx_par_value]        SMALLINT       NULL,
    [pastx_issue_rev_dt]     INT            NULL,
    [pastx_activity_cd]      CHAR (1)       NULL,
    [pastx_chk_no]           CHAR (8)       NULL,
    [pastx_chk_rev_dt]       INT            NULL,
    [pastx_chk_amt]          DECIMAL (9, 2) NULL,
    [pastx_xfer_from_cus_no] CHAR (10)      NULL,
    [pastx_xfer_from_rev_dt] INT            NULL,
    [pastx_user_id]          CHAR (16)      NULL,
    [pastx_user_rev_dt]      INT            NULL,
    [A4GLIdentity]           NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pastxmst] PRIMARY KEY NONCLUSTERED ([pastx_cus_no] ASC, [pastx_cert_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipastxmst0]
    ON [dbo].[pastxmst]([pastx_cus_no] ASC, [pastx_cert_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ipastxmst1]
    ON [dbo].[pastxmst]([pastx_cert_no] ASC);

