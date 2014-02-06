CREATE TABLE [dbo].[pavxfmst] (
    [pavxf_from_cus_no]      CHAR (10)      NOT NULL,
    [pavxf_desc]             CHAR (30)      NULL,
    [pavxf_to_cus_no_1]      CHAR (10)      NULL,
    [pavxf_to_cus_no_2]      CHAR (10)      NULL,
    [pavxf_to_cus_no_3]      CHAR (10)      NULL,
    [pavxf_to_cus_no_4]      CHAR (10)      NULL,
    [pavxf_to_cus_no_5]      CHAR (10)      NULL,
    [pavxf_to_cus_no_6]      CHAR (10)      NULL,
    [pavxf_to_cus_no_7]      CHAR (10)      NULL,
    [pavxf_to_cus_no_8]      CHAR (10)      NULL,
    [pavxf_to_cus_no_9]      CHAR (10)      NULL,
    [pavxf_to_cus_no_10]     CHAR (10)      NULL,
    [pavxf_pct_1]            DECIMAL (7, 3) NULL,
    [pavxf_pct_2]            DECIMAL (7, 3) NULL,
    [pavxf_pct_3]            DECIMAL (7, 3) NULL,
    [pavxf_pct_4]            DECIMAL (7, 3) NULL,
    [pavxf_pct_5]            DECIMAL (7, 3) NULL,
    [pavxf_pct_6]            DECIMAL (7, 3) NULL,
    [pavxf_pct_7]            DECIMAL (7, 3) NULL,
    [pavxf_pct_8]            DECIMAL (7, 3) NULL,
    [pavxf_pct_9]            DECIMAL (7, 3) NULL,
    [pavxf_pct_10]           DECIMAL (7, 3) NULL,
    [pavxf_last_xfer_rev_dt] INT            NULL,
    [pavxf_user_id]          CHAR (16)      NULL,
    [pavxf_user_rev_dt]      INT            NULL,
    [A4GLIdentity]           NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pavxfmst] PRIMARY KEY NONCLUSTERED ([pavxf_from_cus_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipavxfmst0]
    ON [dbo].[pavxfmst]([pavxf_from_cus_no] ASC);

