CREATE TABLE [dbo].[jdcpxmst] (
    [jdcpx_product_line] CHAR (10)   NOT NULL,
    [jdcpx_crd_plan_no]  INT         NOT NULL,
    [jdcpx_seq_no]       SMALLINT    NOT NULL,
    [jdcpx_bill_code]    INT         NOT NULL,
    [jdcpx_timestamp]    CHAR (25)   NULL,
    [jdcpx_user_id]      CHAR (16)   NULL,
    [jdcpx_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_jdcpxmst] PRIMARY KEY NONCLUSTERED ([jdcpx_product_line] ASC, [jdcpx_crd_plan_no] ASC, [jdcpx_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ijdcpxmst0]
    ON [dbo].[jdcpxmst]([jdcpx_product_line] ASC, [jdcpx_crd_plan_no] ASC, [jdcpx_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdcpxmst1]
    ON [dbo].[jdcpxmst]([jdcpx_bill_code] ASC);

